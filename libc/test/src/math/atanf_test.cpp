//===-- Unittests for atanf -----------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "hdr/math_macros.h"
#include "hdr/stdint_proxy.h"
#include "src/__support/FPUtil/FPBits.h"
#include "src/__support/libc_errno.h"
#include "src/math/atanf.h"
#include "test/UnitTest/FPMatcher.h"
#include "test/UnitTest/Test.h"
#include "utils/MPFRWrapper/MPFRUtils.h"

using LlvmLibcAtanfTest = LIBC_NAMESPACE::testing::FPTest<float>;

namespace mpfr = LIBC_NAMESPACE::testing::mpfr;

// TODO: This test needs to have its checks for exceptions, errno
// tightened
TEST_F(LlvmLibcAtanfTest, SpecialNumbers) {
  libc_errno = 0;
  LIBC_NAMESPACE::fputil::clear_except(FE_ALL_EXCEPT);
  EXPECT_FP_EQ_ALL_ROUNDING(aNaN, LIBC_NAMESPACE::atanf(aNaN));
  // TODO: Uncomment these checks later, RoundingMode affects running
  // tests in this way https://github.com/llvm/llvm-project/issues/90653.
  // EXPECT_FP_EXCEPTION(0);
  EXPECT_MATH_ERRNO(0);

  LIBC_NAMESPACE::fputil::clear_except(FE_ALL_EXCEPT);
  EXPECT_FP_EQ_ALL_ROUNDING(0.0f, LIBC_NAMESPACE::atanf(0.0f));
  // TODO: Uncomment these checks later, RoundingMode affects running
  // tests in this way https://github.com/llvm/llvm-project/issues/90653.
  // EXPECT_FP_EXCEPTION(0);
  EXPECT_MATH_ERRNO(0);

  LIBC_NAMESPACE::fputil::clear_except(FE_ALL_EXCEPT);
  EXPECT_FP_EQ_ALL_ROUNDING(-0.0f, LIBC_NAMESPACE::atanf(-0.0f));
  // TODO: Uncomment these checks later, RoundingMode affects running
  // tests in this way https://github.com/llvm/llvm-project/issues/90653.
  // EXPECT_FP_EXCEPTION(0);
  EXPECT_MATH_ERRNO(0);
}

TEST_F(LlvmLibcAtanfTest, InFloatRange) {
  constexpr uint32_t COUNT = 100'000;
  const uint32_t STEP = FPBits(inf).uintval() / COUNT;
  for (uint32_t i = 0, v = 0; i <= COUNT; ++i, v += STEP) {
    float x = FPBits(v).get_val();
    EXPECT_MPFR_MATCH_ALL_ROUNDING(mpfr::Operation::Atan, x,
                                   LIBC_NAMESPACE::atanf(x), 0.5);
    EXPECT_MPFR_MATCH_ALL_ROUNDING(mpfr::Operation::Atan, -x,
                                   LIBC_NAMESPACE::atanf(-x), 0.5);
  }
}

// For small values, tanh(x) is x.
TEST_F(LlvmLibcAtanfTest, SpecialValues) {
  uint32_t val_arr[] = {
      0x3d8d6b23U, // x = 0x1.1ad646p-4f
      0x3dbb6ac7U, // x = 0x1.76d58ep-4f
      0x3feefcfbU, // x = 0x1.ddf9f6p+0f
      0x3ffe2ec1U, // x = 0x1.fc5d82p+0f
      0xbd8d6b23U, // x = -0x1.1ad646p-4f
      0xbdbb6ac7U, // x = -0x1.76d58ep-4f
      0xbfeefcfbU, // x = -0x1.ddf9f6p+0f
      0xbffe2ec1U, // x = -0x1.fc5d82p+0
      0x7F800000U, // x = +Inf
      0xFF800000U, // x = -Inf
  };
  for (uint32_t v : val_arr) {
    float x = FPBits(v).get_val();
    EXPECT_MPFR_MATCH_ALL_ROUNDING(mpfr::Operation::Atan, x,
                                   LIBC_NAMESPACE::atanf(x), 0.5);
  }
}
