//===- Profile.cpp - XRay Profile Abstraction -----------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Defines the XRay Profile class representing the latency profile generated by
// XRay's profiling mode.
//
//===----------------------------------------------------------------------===//
#include "llvm/XRay/Profile.h"

#include "llvm/Support/DataExtractor.h"
#include "llvm/Support/Error.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/XRay/Trace.h"
#include <memory>

namespace llvm {
namespace xray {

Profile::Profile(const Profile &O) {
  // We need to re-create all the tries from the original (O), into the current
  // Profile being initialized, through the Block instances we see.
  for (const auto &Block : O) {
    Blocks.push_back({Block.Thread, {}});
    auto &B = Blocks.back();
    for (const auto &PathData : Block.PathData)
      B.PathData.push_back({internPath(cantFail(O.expandPath(PathData.first))),
                            PathData.second});
  }
}

Profile &Profile::operator=(const Profile &O) {
  Profile P = O;
  *this = std::move(P);
  return *this;
}

namespace {

struct BlockHeader {
  uint32_t Size;
  uint32_t Number;
  uint64_t Thread;
};

static Expected<BlockHeader> readBlockHeader(DataExtractor &Extractor,
                                             uint64_t &Offset) {
  BlockHeader H;
  uint64_t CurrentOffset = Offset;
  H.Size = Extractor.getU32(&Offset);
  if (Offset == CurrentOffset)
    return make_error<StringError>(
        Twine("Error parsing block header size at offset '") +
            Twine(CurrentOffset) + "'",
        std::make_error_code(std::errc::invalid_argument));
  CurrentOffset = Offset;
  H.Number = Extractor.getU32(&Offset);
  if (Offset == CurrentOffset)
    return make_error<StringError>(
        Twine("Error parsing block header number at offset '") +
            Twine(CurrentOffset) + "'",
        std::make_error_code(std::errc::invalid_argument));
  CurrentOffset = Offset;
  H.Thread = Extractor.getU64(&Offset);
  if (Offset == CurrentOffset)
    return make_error<StringError>(
        Twine("Error parsing block header thread id at offset '") +
            Twine(CurrentOffset) + "'",
        std::make_error_code(std::errc::invalid_argument));
  return H;
}

static Expected<std::vector<Profile::FuncID>> readPath(DataExtractor &Extractor,
                                                       uint64_t &Offset) {
  // We're reading a sequence of int32_t's until we find a 0.
  std::vector<Profile::FuncID> Path;
  auto CurrentOffset = Offset;
  int32_t FuncId;
  do {
    FuncId = Extractor.getSigned(&Offset, 4);
    if (CurrentOffset == Offset)
      return make_error<StringError>(
          Twine("Error parsing path at offset '") + Twine(CurrentOffset) + "'",
          std::make_error_code(std::errc::invalid_argument));
    CurrentOffset = Offset;
    Path.push_back(FuncId);
  } while (FuncId != 0);
  return std::move(Path);
}

static Expected<Profile::Data> readData(DataExtractor &Extractor,
                                        uint64_t &Offset) {
  // We expect a certain number of elements for Data:
  //   - A 64-bit CallCount
  //   - A 64-bit CumulativeLocalTime counter
  Profile::Data D;
  auto CurrentOffset = Offset;
  D.CallCount = Extractor.getU64(&Offset);
  if (CurrentOffset == Offset)
    return make_error<StringError>(
        Twine("Error parsing call counts at offset '") + Twine(CurrentOffset) +
            "'",
        std::make_error_code(std::errc::invalid_argument));
  CurrentOffset = Offset;
  D.CumulativeLocalTime = Extractor.getU64(&Offset);
  if (CurrentOffset == Offset)
    return make_error<StringError>(
        Twine("Error parsing cumulative local time at offset '") +
            Twine(CurrentOffset) + "'",
        std::make_error_code(std::errc::invalid_argument));
  return D;
}

} // namespace

Error Profile::addBlock(Block &&B) {
  if (B.PathData.empty())
    return make_error<StringError>(
        "Block may not have empty path data.",
        std::make_error_code(std::errc::invalid_argument));

  Blocks.emplace_back(std::move(B));
  return Error::success();
}

Expected<std::vector<Profile::FuncID>> Profile::expandPath(PathID P) const {
  auto It = PathIDMap.find(P);
  if (It == PathIDMap.end())
    return make_error<StringError>(
        Twine("PathID not found: ") + Twine(P),
        std::make_error_code(std::errc::invalid_argument));
  std::vector<Profile::FuncID> Path;
  for (auto Node = It->second; Node; Node = Node->Caller)
    Path.push_back(Node->Func);
  return std::move(Path);
}

Profile::PathID Profile::internPath(ArrayRef<FuncID> P) {
  if (P.empty())
    return 0;

  auto RootToLeafPath = reverse(P);

  // Find the root.
  auto It = RootToLeafPath.begin();
  auto PathRoot = *It++;
  auto RootIt =
      find_if(Roots, [PathRoot](TrieNode *N) { return N->Func == PathRoot; });

  // If we've not seen this root before, remember it.
  TrieNode *Node = nullptr;
  if (RootIt == Roots.end()) {
    NodeStorage.emplace_back();
    Node = &NodeStorage.back();
    Node->Func = PathRoot;
    Roots.push_back(Node);
  } else {
    Node = *RootIt;
  }

  // Now traverse the path, re-creating if necessary.
  while (It != RootToLeafPath.end()) {
    auto NodeFuncID = *It++;
    auto CalleeIt = find_if(Node->Callees, [NodeFuncID](TrieNode *N) {
      return N->Func == NodeFuncID;
    });
    if (CalleeIt == Node->Callees.end()) {
      NodeStorage.emplace_back();
      auto NewNode = &NodeStorage.back();
      NewNode->Func = NodeFuncID;
      NewNode->Caller = Node;
      Node->Callees.push_back(NewNode);
      Node = NewNode;
    } else {
      Node = *CalleeIt;
    }
  }

  // At this point, Node *must* be pointing at the leaf.
  assert(Node->Func == P.front());
  if (Node->ID == 0) {
    Node->ID = NextID++;
    PathIDMap.insert({Node->ID, Node});
  }
  return Node->ID;
}

Profile mergeProfilesByThread(const Profile &L, const Profile &R) {
  Profile Merged;
  using PathDataMap = DenseMap<Profile::PathID, Profile::Data>;
  using PathDataMapPtr = std::unique_ptr<PathDataMap>;
  using PathDataVector = decltype(Profile::Block::PathData);
  using ThreadProfileIndexMap = DenseMap<Profile::ThreadID, PathDataMapPtr>;
  ThreadProfileIndexMap ThreadProfileIndex;

  for (const auto &P : {std::ref(L), std::ref(R)})
    for (const auto &Block : P.get()) {
      ThreadProfileIndexMap::iterator It;
      std::tie(It, std::ignore) = ThreadProfileIndex.insert(
          {Block.Thread, std::make_unique<PathDataMap>()});
      for (const auto &PathAndData : Block.PathData) {
        auto &PathID = PathAndData.first;
        auto &Data = PathAndData.second;
        auto NewPathID =
            Merged.internPath(cantFail(P.get().expandPath(PathID)));
        PathDataMap::iterator PathDataIt;
        bool Inserted;
        std::tie(PathDataIt, Inserted) = It->second->insert({NewPathID, Data});
        if (!Inserted) {
          auto &ExistingData = PathDataIt->second;
          ExistingData.CallCount += Data.CallCount;
          ExistingData.CumulativeLocalTime += Data.CumulativeLocalTime;
        }
      }
    }

  for (const auto &IndexedThreadBlock : ThreadProfileIndex) {
    PathDataVector PathAndData;
    PathAndData.reserve(IndexedThreadBlock.second->size());
    copy(*IndexedThreadBlock.second, std::back_inserter(PathAndData));
    cantFail(
        Merged.addBlock({IndexedThreadBlock.first, std::move(PathAndData)}));
  }
  return Merged;
}

Profile mergeProfilesByStack(const Profile &L, const Profile &R) {
  Profile Merged;
  using PathDataMap = DenseMap<Profile::PathID, Profile::Data>;
  PathDataMap PathData;
  using PathDataVector = decltype(Profile::Block::PathData);
  for (const auto &P : {std::ref(L), std::ref(R)})
    for (const auto &Block : P.get())
      for (const auto &PathAndData : Block.PathData) {
        auto &PathId = PathAndData.first;
        auto &Data = PathAndData.second;
        auto NewPathID =
            Merged.internPath(cantFail(P.get().expandPath(PathId)));
        PathDataMap::iterator PathDataIt;
        bool Inserted;
        std::tie(PathDataIt, Inserted) = PathData.insert({NewPathID, Data});
        if (!Inserted) {
          auto &ExistingData = PathDataIt->second;
          ExistingData.CallCount += Data.CallCount;
          ExistingData.CumulativeLocalTime += Data.CumulativeLocalTime;
        }
      }

  // In the end there's a single Block, for thread 0.
  PathDataVector Block;
  Block.reserve(PathData.size());
  copy(PathData, std::back_inserter(Block));
  cantFail(Merged.addBlock({0, std::move(Block)}));
  return Merged;
}

Expected<Profile> loadProfile(StringRef Filename) {
  Expected<sys::fs::file_t> FdOrErr = sys::fs::openNativeFileForRead(Filename);
  if (!FdOrErr)
    return FdOrErr.takeError();

  uint64_t FileSize;
  if (auto EC = sys::fs::file_size(Filename, FileSize))
    return make_error<StringError>(
        Twine("Cannot get filesize of '") + Filename + "'", EC);

  std::error_code EC;
  sys::fs::mapped_file_region MappedFile(
      *FdOrErr, sys::fs::mapped_file_region::mapmode::readonly, FileSize, 0,
      EC);
  sys::fs::closeFile(*FdOrErr);
  if (EC)
    return make_error<StringError>(
        Twine("Cannot mmap profile '") + Filename + "'", EC);
  StringRef Data(MappedFile.data(), MappedFile.size());

  Profile P;
  uint64_t Offset = 0;
  DataExtractor Extractor(Data, true, 8);

  // For each block we get from the file:
  while (Offset != MappedFile.size()) {
    auto HeaderOrError = readBlockHeader(Extractor, Offset);
    if (!HeaderOrError)
      return HeaderOrError.takeError();

    // TODO: Maybe store this header information for each block, even just for
    // debugging?
    const auto &Header = HeaderOrError.get();

    // Read in the path data.
    auto PathOrError = readPath(Extractor, Offset);
    if (!PathOrError)
      return PathOrError.takeError();
    const auto &Path = PathOrError.get();

    // For each path we encounter, we should intern it to get a PathID.
    auto DataOrError = readData(Extractor, Offset);
    if (!DataOrError)
      return DataOrError.takeError();
    auto &Data = DataOrError.get();

    if (auto E =
            P.addBlock(Profile::Block{Profile::ThreadID{Header.Thread},
                                      {{P.internPath(Path), std::move(Data)}}}))
      return std::move(E);
  }

  return P;
}

namespace {

struct StackEntry {
  uint64_t Timestamp;
  Profile::FuncID FuncId;
};

} // namespace

Expected<Profile> profileFromTrace(const Trace &T) {
  Profile P;

  // The implementation of the algorithm re-creates the execution of
  // the functions based on the trace data. To do this, we set up a number of
  // data structures to track the execution context of every thread in the
  // Trace.
  DenseMap<Profile::ThreadID, std::vector<StackEntry>> ThreadStacks;
  DenseMap<Profile::ThreadID, DenseMap<Profile::PathID, Profile::Data>>
      ThreadPathData;

  //  We then do a pass through the Trace to account data on a per-thread-basis.
  for (const auto &E : T) {
    auto &TSD = ThreadStacks[E.TId];
    switch (E.Type) {
    case RecordTypes::ENTER:
    case RecordTypes::ENTER_ARG:

      // Push entries into the function call stack.
      TSD.push_back({E.TSC, E.FuncId});
      break;

    case RecordTypes::EXIT:
    case RecordTypes::TAIL_EXIT:

      // Exits cause some accounting to happen, based on the state of the stack.
      // For each function we pop off the stack, we take note of the path and
      // record the cumulative state for this path. As we're doing this, we
      // intern the path into the Profile.
      while (!TSD.empty()) {
        auto Top = TSD.back();
        auto FunctionLocalTime = AbsoluteDifference(Top.Timestamp, E.TSC);
        SmallVector<Profile::FuncID, 16> Path;
        transform(reverse(TSD), std::back_inserter(Path),
                  std::mem_fn(&StackEntry::FuncId));
        auto InternedPath = P.internPath(Path);
        auto &TPD = ThreadPathData[E.TId][InternedPath];
        ++TPD.CallCount;
        TPD.CumulativeLocalTime += FunctionLocalTime;
        TSD.pop_back();

        // If we've matched the corresponding entry event for this function,
        // then we exit the loop.
        if (Top.FuncId == E.FuncId)
          break;

        // FIXME: Consider the intermediate times and the cumulative tree time
        // as well.
      }

      break;

    case RecordTypes::CUSTOM_EVENT:
    case RecordTypes::TYPED_EVENT:
      // TODO: Support an extension point to allow handling of custom and typed
      // events in profiles.
      break;
    }
  }

  // Once we've gone through the Trace, we now create one Block per thread in
  // the Profile.
  for (const auto &ThreadPaths : ThreadPathData) {
    const auto &TID = ThreadPaths.first;
    const auto &PathsData = ThreadPaths.second;
    if (auto E = P.addBlock({
            TID,
            std::vector<std::pair<Profile::PathID, Profile::Data>>(
                PathsData.begin(), PathsData.end()),
        }))
      return std::move(E);
  }

  return P;
}

} // namespace xray
} // namespace llvm
