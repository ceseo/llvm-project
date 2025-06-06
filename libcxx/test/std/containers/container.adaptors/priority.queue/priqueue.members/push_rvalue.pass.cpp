//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// UNSUPPORTED: c++03

// <queue>

// priority_queue();

// void push(value_type&& v);

#include <queue>
#include <cassert>

#include "test_macros.h"
#include "MoveOnly.h"

TEST_CONSTEXPR_CXX26 bool test() {
  std::priority_queue<MoveOnly> q;
  q.push(1);
  assert(q.top() == 1);
  q.push(3);
  assert(q.top() == 3);
  q.push(2);
  assert(q.top() == 3);

  return true;
}

int main(int, char**) {
  assert(test());
#if TEST_STD_VER >= 26
  static_assert(test());
#endif

  return 0;
}
