! RUN: bbc -emit-fir -hlfir=false %s -o - | FileCheck %s

subroutine test_dimag(r, c)
  real(8), intent(out) :: r
  complex(8), intent(in) :: c

! CHECK-LABEL: func @_QPtest_dimag(
! CHECK-SAME: %[[ARG_0:.*]]: !fir.ref<f64> {fir.bindc_name = "r"},
! CHECK-SAME: %[[ARG_1:.*]]: !fir.ref<complex<f64>> {fir.bindc_name = "c"}) {
! CHECK:   %[[VAL_0:.*]] = fir.load %[[ARG_1]] : !fir.ref<complex<f64>>
! CHECK:   %[[VAL_1:.*]] = fir.extract_value %[[VAL_0]], [1 : index] : (complex<f64>) -> f64
! CHECK:   fir.store %[[VAL_1]] to %[[ARG_0]] : !fir.ref<f64>
! CHECK:   return
! CHECK: }

  r = dimag(c)
end
