//===-- ARMWinCOFFObjectWriter.cpp - ARM Windows COFF Object Writer -- C++ -==//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/ARMFixupKinds.h"
#include "MCTargetDesc/ARMMCAsmInfo.h"
#include "llvm/ADT/Twine.h"
#include "llvm/BinaryFormat/COFF.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCFixup.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCValue.h"
#include "llvm/MC/MCWinCOFFObjectWriter.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

namespace {

class ARMWinCOFFObjectWriter : public MCWinCOFFObjectTargetWriter {
public:
  ARMWinCOFFObjectWriter()
    : MCWinCOFFObjectTargetWriter(COFF::IMAGE_FILE_MACHINE_ARMNT) {
  }

  ~ARMWinCOFFObjectWriter() override = default;

  unsigned getRelocType(MCContext &Ctx, const MCValue &Target,
                        const MCFixup &Fixup, bool IsCrossSection,
                        const MCAsmBackend &MAB) const override;

  bool recordRelocation(const MCFixup &) const override;
};

} // end anonymous namespace

unsigned ARMWinCOFFObjectWriter::getRelocType(MCContext &Ctx,
                                              const MCValue &Target,
                                              const MCFixup &Fixup,
                                              bool IsCrossSection,
                                              const MCAsmBackend &MAB) const {
  auto Spec = Target.getSpecifier();
  unsigned FixupKind = Fixup.getKind();
  bool PCRel = false;
  if (IsCrossSection) {
    if (PCRel || FixupKind != FK_Data_4) {
      Ctx.reportError(Fixup.getLoc(), "Cannot represent this expression");
      return COFF::IMAGE_REL_ARM_ADDR32;
    }
    FixupKind = FK_Data_4;
    PCRel = true;
  }


  switch (FixupKind) {
  default: {
    Ctx.reportError(Fixup.getLoc(), "unsupported relocation type");
    return COFF::IMAGE_REL_ARM_ABSOLUTE;
  }
  case FK_Data_4:
    if (PCRel)
      return COFF::IMAGE_REL_ARM_REL32;
    switch (Spec) {
    case MCSymbolRefExpr::VK_COFF_IMGREL32:
      return COFF::IMAGE_REL_ARM_ADDR32NB;
    case ARM::S_COFF_SECREL:
      return COFF::IMAGE_REL_ARM_SECREL;
    default:
      return COFF::IMAGE_REL_ARM_ADDR32;
    }
  case FK_SecRel_2:
    return COFF::IMAGE_REL_ARM_SECTION;
  case FK_SecRel_4:
    return COFF::IMAGE_REL_ARM_SECREL;
  case ARM::fixup_t2_condbranch:
    return COFF::IMAGE_REL_ARM_BRANCH20T;
  case ARM::fixup_t2_uncondbranch:
  case ARM::fixup_arm_thumb_bl:
    return COFF::IMAGE_REL_ARM_BRANCH24T;
  case ARM::fixup_arm_thumb_blx:
    return COFF::IMAGE_REL_ARM_BLX23T;
  case ARM::fixup_t2_movw_lo16:
  case ARM::fixup_t2_movt_hi16:
    return COFF::IMAGE_REL_ARM_MOV32T;
  }
}

bool ARMWinCOFFObjectWriter::recordRelocation(const MCFixup &Fixup) const {
  return static_cast<unsigned>(Fixup.getKind()) != ARM::fixup_t2_movt_hi16;
}

namespace llvm {

std::unique_ptr<MCObjectTargetWriter>
createARMWinCOFFObjectWriter() {
  return std::make_unique<ARMWinCOFFObjectWriter>();
}

} // end namespace llvm
