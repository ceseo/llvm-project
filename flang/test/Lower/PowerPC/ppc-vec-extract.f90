! RUN: %flang_fc1 -triple powerpc64le-unknown-unknown -emit-llvm %s -o - | FileCheck --check-prefixes="LLVMIR","LLVMIR-LE" %s
! RUN: %flang_fc1 -triple powerpc64-unknown-unknown -emit-llvm %s -o - | FileCheck --check-prefixes="LLVMIR","LLVMIR-BE" %s
! REQUIRES: target=powerpc{{.*}}

!-------------
! vec_extract
!-------------
! CHECK-LABEL: vec_extract_testf32
subroutine vec_extract_testf32(x, i1, i2, i4, i8)
  vector(real(4)) :: x
  real(4) :: r
  integer(1) :: i1
  integer(2) :: i2
  integer(4) :: i4
  integer(8) :: i8
  r = vec_extract(x, i1)

! LLVMIR: %[[x:.*]] = load <4 x float>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i1:.*]] = load i8, ptr %{{[0-9]}}, align 1
! LLVMIR: %[[u:.*]] = urem i8 %[[i1]], 4
! LLVMIR-BE: %[[s:.*]] = sub i8 3, %[[u]]
! LLVMIR-BE: %[[idx:.*]] = zext i8 %[[s]] to i64
! LLVMIR-LE: %[[idx:.*]] = zext i8 %[[u]] to i64
! LLVMIR: %[[r:.*]] = extractelement <4 x float> %[[x]], i64 %[[idx]]
! LLVMIR: store float %[[r]], ptr %{{[0-9]}}, align 4

  r = vec_extract(x, i2)

! LLVMIR: %[[x:.*]] = load <4 x float>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i2:.*]] = load i16, ptr %{{[0-9]}}, align 2
! LLVMIR: %[[u:.*]] = urem i16 %[[i2]], 4
! LLVMIR-BE: %[[s:.*]] = sub i16 3, %[[u]]
! LLVMIR-BE: %[[idx:.*]] = zext i16 %[[s]] to i64
! LLVMIR-LE: %[[idx:.*]] = zext i16 %[[u]] to i64
! LLVMIR: %[[r:.*]] = extractelement <4 x float> %[[x]], i64 %[[idx]]
! LLVMIR: store float %[[r]], ptr %{{[0-9]}}, align 4

  r = vec_extract(x, i4)

! LLVMIR: %[[x:.*]] = load <4 x float>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i4:.*]] = load i32, ptr %{{[0-9]}}, align 4
! LLVMIR: %[[u:.*]] = urem i32 %[[i4]], 4
! LLVMIR-BE: %[[s:.*]] = sub i32 3, %[[u]]
! LLVMIR-BE: %[[idx:.*]] = zext i32 %[[s]] to i64
! LLVMIR-LE: %[[idx:.*]] = zext i32 %[[u]] to i64
! LLVMIR: %[[r:.*]] = extractelement <4 x float> %[[x]], i64 %[[idx]]
! LLVMIR: store float %[[r]], ptr %{{[0-9]}}, align 4

  r = vec_extract(x, i8)

! LLVMIR: %[[x:.*]] = load <4 x float>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i8:.*]] = load i64, ptr %{{[0-9]}}, align 8
! LLVMIR-BE: %[[u:.*]] = urem i64 %[[i8]], 4
! LLVMIR-BE: %[[idx:.*]] = sub i64 3, %[[u]]
! LLVMIR-LE: %[[idx:.*]] = urem i64 %[[i8]], 4
! LLVMIR: %[[r:.*]] = extractelement <4 x float> %[[x]], i64 %[[idx]]
! LLVMIR: store float %[[r]], ptr %{{[0-9]}}, align 4
end subroutine vec_extract_testf32

! CHECK-LABEL: vec_extract_testf64
subroutine vec_extract_testf64(x, i1, i2, i4, i8)
  vector(real(8)) :: x
  real(8) :: r
  integer(1) :: i1
  integer(2) :: i2
  integer(4) :: i4
  integer(8) :: i8
  r = vec_extract(x, i1)

! LLVMIR: %[[x:.*]] = load <2 x double>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i1:.*]] = load i8, ptr %{{[0-9]}}, align 1
! LLVMIR: %[[u:.*]] = urem i8 %[[i1]], 2
! LLVMIR-BE: %[[s:.*]] = sub i8 1, %[[u]]
! LLVMIR-BE: %[[idx:.*]] = zext i8 %[[s]] to i64
! LLVMIR-LE: %[[idx:.*]] = zext i8 %[[u]] to i64
! LLVMIR: %[[r:.*]] = extractelement <2 x double> %[[x]], i64 %[[idx]]
! LLVMIR: store double %[[r]], ptr %{{[0-9]}}, align 8

  r = vec_extract(x, i2)

! LLVMIR: %[[x:.*]] = load <2 x double>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i2:.*]] = load i16, ptr %{{[0-9]}}, align 2
! LLVMIR: %[[u:.*]] = urem i16 %[[i2]], 2
! LLVMIR-BE: %[[s:.*]] = sub i16 1, %[[u]]
! LLVMIR-BE: %[[idx:.*]] = zext i16 %[[s]] to i64
! LLVMIR-LE: %[[idx:.*]] = zext i16 %[[u]] to i64
! LLVMIR: %[[r:.*]] = extractelement <2 x double> %[[x]], i64 %[[idx]]
! LLVMIR: store double %[[r]], ptr %{{[0-9]}}, align 8


  r = vec_extract(x, i4)

! LLVMIR: %[[x:.*]] = load <2 x double>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i4:.*]] = load i32, ptr %{{[0-9]}}, align 4
! LLVMIR: %[[u:.*]] = urem i32 %[[i4]], 2
! LLVMIR-BE: %[[s:.*]] = sub i32 1, %[[u]]
! LLVMIR-BE: %[[idx:.*]] = zext i32 %[[s]] to i64
! LLVMIR-LE: %[[idx:.*]] = zext i32 %[[u]] to i64
! LLVMIR: %[[r:.*]] = extractelement <2 x double> %[[x]], i64 %[[idx]]
! LLVMIR: store double %[[r]], ptr %{{[0-9]}}, align 8

  r = vec_extract(x, i8)

! LLVMIR: %[[x:.*]] = load <2 x double>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i8:.*]] = load i64, ptr %{{[0-9]}}, align 8
! LLVMIR-BE: %[[u:.*]] = urem i64 %[[i8]], 2
! LLVMIR-BE: %[[idx:.*]] = sub i64 1, %[[u]]
! LLVMIR-LE: %[[idx:.*]] = urem i64 %[[i8]], 2
! LLVMIR: %[[r:.*]] = extractelement <2 x double> %[[x]], i64 %[[idx]]
! LLVMIR: store double %[[r]], ptr %{{[0-9]}}, align 8
end subroutine vec_extract_testf64

! CHECK-LABEL: vec_extract_testi8
subroutine vec_extract_testi8(x, i1, i2, i4, i8)
  vector(integer(1)) :: x
  integer(1) :: r
  integer(1) :: i1
  integer(2) :: i2
  integer(4) :: i4
  integer(8) :: i8
  r = vec_extract(x, i1)

! LLVMIR: %[[x:.*]] = load <16 x i8>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i1:.*]] = load i8, ptr %{{[0-9]}}, align 1
! LLVMIR: %[[u:.*]] = urem i8 %[[i1]], 16
! LLVMIR-BE: %[[s:.*]] = sub i8 15, %[[u]]
! LLVMIR-BE: %[[idx:.*]] = zext i8 %[[s]] to i64
! LLVMIR-LE: %[[idx:.*]] = zext i8 %[[u]] to i64
! LLVMIR: %[[r:.*]] = extractelement <16 x i8> %[[x]], i64 %[[idx]]
! LLVMIR: store i8 %[[r]], ptr %{{[0-9]}}, align 1

  r = vec_extract(x, i2)

! LLVMIR: %[[x:.*]] = load <16 x i8>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i2:.*]] = load i16, ptr %{{[0-9]}}, align 2
! LLVMIR: %[[u:.*]] = urem i16 %[[i2]], 16
! LLVMIR-BE: %[[s:.*]] = sub i16 15, %[[u]]
! LLVMIR-BE: %[[idx:.*]] = zext i16 %[[s]] to i64
! LLVMIR-LE: %[[idx:.*]] = zext i16 %[[u]] to i64
! LLVMIR: %[[r:.*]] = extractelement <16 x i8> %[[x]], i64 %[[idx]]
! LLVMIR: store i8 %[[r]], ptr %{{[0-9]}}, align 1

  r = vec_extract(x, i4)

! LLVMIR: %[[x:.*]] = load <16 x i8>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i4:.*]] = load i32, ptr %{{[0-9]}}, align 4
! LLVMIR: %[[u:.*]] = urem i32 %[[i4]], 16
! LLVMIR-BE: %[[s:.*]] = sub i32 15, %[[u]]
! LLVMIR-BE: %[[idx:.*]] = zext i32 %[[s]] to i64
! LLVMIR-LE: %[[idx:.*]] = zext i32 %[[u]] to i64
! LLVMIR: %[[r:.*]] = extractelement <16 x i8> %[[x]], i64 %[[idx]]
! LLVMIR: store i8 %[[r]], ptr %{{[0-9]}}, align 1

  r = vec_extract(x, i8)

! LLVMIR: %[[x:.*]] = load <16 x i8>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i8:.*]] = load i64, ptr %{{[0-9]}}, align 8
! LLVMIR-BE: %[[u:.*]] = urem i64 %[[i8]], 16
! LLVMIR-BE: %[[idx:.*]] = sub i64 15, %[[u]]
! LLVMIR-LE: %[[idx:.*]] = urem i64 %[[i8]], 16
! LLVMIR: %[[r:.*]] = extractelement <16 x i8> %[[x]], i64 %[[idx]]
! LLVMIR: store i8 %[[r]], ptr %{{[0-9]}}, align 1
end subroutine vec_extract_testi8

! CHECK-LABEL: vec_extract_testi16
subroutine vec_extract_testi16(x, i1, i2, i4, i8)
  vector(integer(2)) :: x
  integer(2) :: r
  integer(1) :: i1
  integer(2) :: i2
  integer(4) :: i4
  integer(8) :: i8
  r = vec_extract(x, i1)

! LLVMIR: %[[x:.*]] = load <8 x i16>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i1:.*]] = load i8, ptr %{{[0-9]}}, align 1
! LLVMIR: %[[u:.*]] = urem i8 %[[i1]], 8
! LLVMIR-BE: %[[s:.*]] = sub i8 7, %[[u]]
! LLVMIR-BE: %[[idx:.*]] = zext i8 %[[s]] to i64
! LLVMIR-LE: %[[idx:.*]] = zext i8 %[[u]] to i64
! LLVMIR: %[[r:.*]] = extractelement <8 x i16> %[[x]], i64 %[[idx]]
! LLVMIR: store i16 %[[r]], ptr %{{[0-9]}}, align 2

  r = vec_extract(x, i2)

! LLVMIR: %[[x:.*]] = load <8 x i16>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i2:.*]] = load i16, ptr %{{[0-9]}}, align 2
! LLVMIR: %[[u:.*]] = urem i16 %[[i2]], 8
! LLVMIR-BE: %[[s:.*]] = sub i16 7, %[[u]]
! LLVMIR-BE: %[[idx:.*]] = zext i16 %[[s]] to i64
! LLVMIR-LE: %[[idx:.*]] = zext i16 %[[u]] to i64
! LLVMIR: %[[r:.*]] = extractelement <8 x i16> %[[x]], i64 %[[idx]]
! LLVMIR: store i16 %[[r]], ptr %{{[0-9]}}, align 2

  r = vec_extract(x, i4)

! LLVMIR: %[[x:.*]] = load <8 x i16>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i4:.*]] = load i32, ptr %{{[0-9]}}, align 4
! LLVMIR: %[[u:.*]] = urem i32 %[[i4]], 8
! LLVMIR-BE: %[[s:.*]] = sub i32 7, %[[u]]
! LLVMIR-BE: %[[idx:.*]] = zext i32 %[[s]] to i64
! LLVMIR-LE: %[[idx:.*]] = zext i32 %[[u]] to i64
! LLVMIR: %[[r:.*]] = extractelement <8 x i16> %[[x]], i64 %[[idx]]
! LLVMIR: store i16 %[[r]], ptr %{{[0-9]}}, align 2

  r = vec_extract(x, i8)

! LLVMIR: %[[x:.*]] = load <8 x i16>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i8:.*]] = load i64, ptr %{{[0-9]}}, align 8
! LLVMIR-BE: %[[u:.*]] = urem i64 %[[i8]], 8
! LLVMIR-BE: %[[idx:.*]] = sub i64 7, %[[u]]
! LLVMIR-LE: %[[idx:.*]] = urem i64 %[[i8]], 8
! LLVMIR: %[[r:.*]] = extractelement <8 x i16> %[[x]], i64 %[[idx]]
! LLVMIR: store i16 %[[r]], ptr %{{[0-9]}}, align 2
end subroutine vec_extract_testi16

! CHECK-LABEL: vec_extract_testi32
subroutine vec_extract_testi32(x, i1, i2, i4, i8)
  vector(integer(4)) :: x
  integer(4) :: r
  integer(1) :: i1
  integer(2) :: i2
  integer(4) :: i4
  integer(8) :: i8
  r = vec_extract(x, i1)

! LLVMIR: %[[x:.*]] = load <4 x i32>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i1:.*]] = load i8, ptr %{{[0-9]}}, align 1
! LLVMIR: %[[u:.*]] = urem i8 %[[i1]], 4
! LLVMIR-BE: %[[s:.*]] = sub i8 3, %[[u]]
! LLVMIR-BE: %[[idx:.*]] = zext i8 %[[s]] to i64
! LLVMIR-LE: %[[idx:.*]] = zext i8 %[[u]] to i64
! LLVMIR: %[[r:.*]] = extractelement <4 x i32> %[[x]], i64 %[[idx]]
! LLVMIR: store i32 %[[r]], ptr %{{[0-9]}}, align 4

  r = vec_extract(x, i2)

! LLVMIR: %[[x:.*]] = load <4 x i32>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i2:.*]] = load i16, ptr %{{[0-9]}}, align 2
! LLVMIR: %[[u:.*]] = urem i16 %[[i2]], 4
! LLVMIR-BE: %[[s:.*]] = sub i16 3, %[[u]]
! LLVMIR-BE: %[[idx:.*]] = zext i16 %[[s]] to i64
! LLVMIR-LE: %[[idx:.*]] = zext i16 %[[u]] to i64
! LLVMIR: %[[r:.*]] = extractelement <4 x i32> %[[x]], i64 %[[idx]]
! LLVMIR: store i32 %[[r]], ptr %{{[0-9]}}, align 4

  r = vec_extract(x, i4)

! LLVMIR: %[[x:.*]] = load <4 x i32>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i4:.*]] = load i32, ptr %{{[0-9]}}, align 4
! LLVMIR: %[[u:.*]] = urem i32 %[[i4]], 4
! LLVMIR-BE: %[[s:.*]] = sub i32 3, %[[u]]
! LLVMIR-BE: %[[idx:.*]] = zext i32 %[[s]] to i64
! LLVMIR-LE: %[[idx:.*]] = zext i32 %[[u]] to i64
! LLVMIR: %[[r:.*]] = extractelement <4 x i32> %[[x]], i64 %[[idx]]
! LLVMIR: store i32 %[[r]], ptr %{{[0-9]}}, align 4

  r = vec_extract(x, i8)

! LLVMIR: %[[x:.*]] = load <4 x i32>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i8:.*]] = load i64, ptr %{{[0-9]}}, align 8
! LLVMIR-BE: %[[u:.*]] = urem i64 %[[i8]], 4
! LLVMIR-BE: %[[idx:.*]] = sub i64 3, %[[u]]
! LLVMIR-LE: %[[idx:.*]] = urem i64 %[[i8]], 4
! LLVMIR: %[[r:.*]] = extractelement <4 x i32> %[[x]], i64 %[[idx]]
! LLVMIR: store i32 %[[r]], ptr %{{[0-9]}}, align 4
end subroutine vec_extract_testi32

! CHECK-LABEL: vec_extract_testi64
subroutine vec_extract_testi64(x, i1, i2, i4, i8)
  vector(integer(8)) :: x
  integer(8) :: r
  integer(1) :: i1
  integer(2) :: i2
  integer(4) :: i4
  integer(8) :: i8
  r = vec_extract(x, i1)

! LLVMIR: %[[x:.*]] = load <2 x i64>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i1:.*]] = load i8, ptr %{{[0-9]}}, align 1
! LLVMIR: %[[u:.*]] = urem i8 %[[i1]], 2
! LLVMIR-BE: %[[s:.*]] = sub i8 1, %[[u]]
! LLVMIR-BE: %[[idx:.*]] = zext i8 %[[s]] to i64
! LLVMIR-LE: %[[idx:.*]] = zext i8 %[[u]] to i64
! LLVMIR: %[[r:.*]] = extractelement <2 x i64> %[[x]], i64 %[[idx]]
! LLVMIR: store i64 %[[r]], ptr %{{[0-9]}}, align 8

  r = vec_extract(x, i2)

! LLVMIR: %[[x:.*]] = load <2 x i64>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i2:.*]] = load i16, ptr %{{[0-9]}}, align 2
! LLVMIR: %[[u:.*]] = urem i16 %[[i2]], 2
! LLVMIR-BE: %[[s:.*]] = sub i16 1, %[[u]]
! LLVMIR-BE: %[[idx:.*]] = zext i16 %[[s]] to i64
! LLVMIR-LE: %[[idx:.*]] = zext i16 %[[u]] to i64
! LLVMIR: %[[r:.*]] = extractelement <2 x i64> %[[x]], i64 %[[idx]]
! LLVMIR: store i64 %[[r]], ptr %{{[0-9]}}, align 8

  r = vec_extract(x, i4)

! LLVMIR: %[[x:.*]] = load <2 x i64>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i4:.*]] = load i32, ptr %{{[0-9]}}, align 4
! LLVMIR: %[[u:.*]] = urem i32 %[[i4]], 2
! LLVMIR-BE: %[[s:.*]] = sub i32 1, %[[u]]
! LLVMIR-BE: %[[idx:.*]] = zext i32 %[[s]] to i64
! LLVMIR-LE: %[[idx:.*]] = zext i32 %[[u]] to i64
! LLVMIR: %[[r:.*]] = extractelement <2 x i64> %[[x]], i64 %[[idx]]
! LLVMIR: store i64 %[[r]], ptr %{{[0-9]}}, align 8

  r = vec_extract(x, i8)

! LLVMIR: %[[x:.*]] = load <2 x i64>, ptr %{{[0-9]}}, align 16
! LLVMIR: %[[i8:.*]] = load i64, ptr %{{[0-9]}}, align 8
! LLVMIR-BE: %[[u:.*]] = urem i64 %[[i8]], 2
! LLVMIR-BE: %[[idx:.*]] = sub i64 1, %[[u]]
! LLVMIR-LE: %[[idx:.*]] = urem i64 %[[i8]], 2
! LLVMIR: %[[r:.*]] = extractelement <2 x i64> %[[x]], i64 %[[idx]]
! LLVMIR: store i64 %[[r]], ptr %{{[0-9]}}, align 8
end subroutine vec_extract_testi64
