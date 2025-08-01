; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -mattr=+zdinx -verify-machineinstrs < %s \
; RUN:   -target-abi=ilp32 | FileCheck -check-prefix=RV32ZDINX %s
; RUN: llc -mtriple=riscv32 -mattr=+zdinx,+unaligned-scalar-mem -verify-machineinstrs < %s \
; RUN:   -target-abi=ilp32 | FileCheck -check-prefix=RV32ZDINXUALIGNED %s
; RUN: llc -mtriple=riscv64 -mattr=+zdinx -verify-machineinstrs < %s \
; RUN:   -target-abi=lp64 | FileCheck -check-prefix=RV64ZDINX %s

define void @foo(ptr nocapture %p, double %d) nounwind {
; RV32ZDINX-LABEL: foo:
; RV32ZDINX:       # %bb.0: # %entry
; RV32ZDINX-NEXT:    addi a3, a0, 2044
; RV32ZDINX-NEXT:    sw a1, 2044(a0)
; RV32ZDINX-NEXT:    sw a2, 4(a3)
; RV32ZDINX-NEXT:    ret
;
; RV32ZDINXUALIGNED-LABEL: foo:
; RV32ZDINXUALIGNED:       # %bb.0: # %entry
; RV32ZDINXUALIGNED-NEXT:    addi a3, a0, 2044
; RV32ZDINXUALIGNED-NEXT:    sw a1, 2044(a0)
; RV32ZDINXUALIGNED-NEXT:    sw a2, 4(a3)
; RV32ZDINXUALIGNED-NEXT:    ret
;
; RV64ZDINX-LABEL: foo:
; RV64ZDINX:       # %bb.0: # %entry
; RV64ZDINX-NEXT:    sd a1, 2044(a0)
; RV64ZDINX-NEXT:    ret
entry:
  %add.ptr = getelementptr inbounds i8, ptr %p, i64 2044
  store double %d, ptr %add.ptr, align 8
  ret void
}

define void @foo2(ptr nocapture %p, double %d) nounwind {
; RV32ZDINX-LABEL: foo2:
; RV32ZDINX:       # %bb.0: # %entry
; RV32ZDINX-NEXT:    mv a3, a2
; RV32ZDINX-NEXT:    addi a4, a0, 2044
; RV32ZDINX-NEXT:    mv a2, a1
; RV32ZDINX-NEXT:    fadd.d a2, a2, a2
; RV32ZDINX-NEXT:    sw a3, 4(a4)
; RV32ZDINX-NEXT:    sw a2, 2044(a0)
; RV32ZDINX-NEXT:    ret
;
; RV32ZDINXUALIGNED-LABEL: foo2:
; RV32ZDINXUALIGNED:       # %bb.0: # %entry
; RV32ZDINXUALIGNED-NEXT:    mv a3, a2
; RV32ZDINXUALIGNED-NEXT:    addi a4, a0, 2044
; RV32ZDINXUALIGNED-NEXT:    mv a2, a1
; RV32ZDINXUALIGNED-NEXT:    fadd.d a2, a2, a2
; RV32ZDINXUALIGNED-NEXT:    sw a3, 4(a4)
; RV32ZDINXUALIGNED-NEXT:    sw a2, 2044(a0)
; RV32ZDINXUALIGNED-NEXT:    ret
;
; RV64ZDINX-LABEL: foo2:
; RV64ZDINX:       # %bb.0: # %entry
; RV64ZDINX-NEXT:    fadd.d a1, a1, a1
; RV64ZDINX-NEXT:    sd a1, 2044(a0)
; RV64ZDINX-NEXT:    ret
entry:
  %a = fadd double %d, %d
  %add.ptr = getelementptr inbounds i8, ptr %p, i64 2044
  store double %a, ptr %add.ptr, align 8
  ret void
}

@d = global double 4.2, align 8

define void @foo3(ptr nocapture %p) nounwind {
; RV32ZDINX-LABEL: foo3:
; RV32ZDINX:       # %bb.0: # %entry
; RV32ZDINX-NEXT:    lui a1, %hi(d)
; RV32ZDINX-NEXT:    lw a2, %lo(d+4)(a1)
; RV32ZDINX-NEXT:    lw a1, %lo(d)(a1)
; RV32ZDINX-NEXT:    addi a3, a0, 2044
; RV32ZDINX-NEXT:    sw a2, 4(a3)
; RV32ZDINX-NEXT:    sw a1, 2044(a0)
; RV32ZDINX-NEXT:    ret
;
; RV32ZDINXUALIGNED-LABEL: foo3:
; RV32ZDINXUALIGNED:       # %bb.0: # %entry
; RV32ZDINXUALIGNED-NEXT:    lui a1, %hi(d)
; RV32ZDINXUALIGNED-NEXT:    lw a2, %lo(d+4)(a1)
; RV32ZDINXUALIGNED-NEXT:    lw a1, %lo(d)(a1)
; RV32ZDINXUALIGNED-NEXT:    addi a3, a0, 2044
; RV32ZDINXUALIGNED-NEXT:    sw a2, 4(a3)
; RV32ZDINXUALIGNED-NEXT:    sw a1, 2044(a0)
; RV32ZDINXUALIGNED-NEXT:    ret
;
; RV64ZDINX-LABEL: foo3:
; RV64ZDINX:       # %bb.0: # %entry
; RV64ZDINX-NEXT:    lui a1, %hi(d)
; RV64ZDINX-NEXT:    ld a1, %lo(d)(a1)
; RV64ZDINX-NEXT:    sd a1, 2044(a0)
; RV64ZDINX-NEXT:    ret
entry:
  %0 = load double, ptr @d, align 8
  %add.ptr = getelementptr inbounds i8, ptr %p, i64 2044
  store double %0, ptr %add.ptr, align 8
  ret void
}

define void @foo4(ptr %p) nounwind {
; RV32ZDINX-LABEL: foo4:
; RV32ZDINX:       # %bb.0: # %entry
; RV32ZDINX-NEXT:    addi sp, sp, -16
; RV32ZDINX-NEXT:    addi a1, a0, 2044
; RV32ZDINX-NEXT:    lw a2, 2044(a0)
; RV32ZDINX-NEXT:    lw a1, 4(a1)
; RV32ZDINX-NEXT:    sw a0, 8(sp)
; RV32ZDINX-NEXT:    lui a0, %hi(d)
; RV32ZDINX-NEXT:    sw a2, %lo(d)(a0)
; RV32ZDINX-NEXT:    sw a1, %lo(d+4)(a0)
; RV32ZDINX-NEXT:    addi sp, sp, 16
; RV32ZDINX-NEXT:    ret
;
; RV32ZDINXUALIGNED-LABEL: foo4:
; RV32ZDINXUALIGNED:       # %bb.0: # %entry
; RV32ZDINXUALIGNED-NEXT:    addi sp, sp, -16
; RV32ZDINXUALIGNED-NEXT:    addi a1, a0, 2044
; RV32ZDINXUALIGNED-NEXT:    lw a2, 2044(a0)
; RV32ZDINXUALIGNED-NEXT:    lw a1, 4(a1)
; RV32ZDINXUALIGNED-NEXT:    sw a0, 8(sp)
; RV32ZDINXUALIGNED-NEXT:    lui a0, %hi(d)
; RV32ZDINXUALIGNED-NEXT:    sw a2, %lo(d)(a0)
; RV32ZDINXUALIGNED-NEXT:    sw a1, %lo(d+4)(a0)
; RV32ZDINXUALIGNED-NEXT:    addi sp, sp, 16
; RV32ZDINXUALIGNED-NEXT:    ret
;
; RV64ZDINX-LABEL: foo4:
; RV64ZDINX:       # %bb.0: # %entry
; RV64ZDINX-NEXT:    addi sp, sp, -16
; RV64ZDINX-NEXT:    ld a1, 2044(a0)
; RV64ZDINX-NEXT:    sd a0, 8(sp)
; RV64ZDINX-NEXT:    lui a0, %hi(d)
; RV64ZDINX-NEXT:    sd a1, %lo(d)(a0)
; RV64ZDINX-NEXT:    addi sp, sp, 16
; RV64ZDINX-NEXT:    ret
entry:
  %p.addr = alloca ptr, align 8
  store ptr %p, ptr %p.addr, align 8
  %0 = load ptr, ptr %p.addr, align 8
  %add.ptr = getelementptr inbounds i8, ptr %0, i64 2044
  %1 = load double, ptr %add.ptr, align 8
  store double %1, ptr @d, align 8
  ret void
}

define void @foo5(ptr nocapture %p, double %d) nounwind {
; RV32ZDINX-LABEL: foo5:
; RV32ZDINX:       # %bb.0: # %entry
; RV32ZDINX-NEXT:    addi a3, a0, -2048
; RV32ZDINX-NEXT:    sw a2, -2045(a0)
; RV32ZDINX-NEXT:    sw a1, -1(a3)
; RV32ZDINX-NEXT:    ret
;
; RV32ZDINXUALIGNED-LABEL: foo5:
; RV32ZDINXUALIGNED:       # %bb.0: # %entry
; RV32ZDINXUALIGNED-NEXT:    addi a3, a0, -2048
; RV32ZDINXUALIGNED-NEXT:    sw a2, -2045(a0)
; RV32ZDINXUALIGNED-NEXT:    sw a1, -1(a3)
; RV32ZDINXUALIGNED-NEXT:    ret
;
; RV64ZDINX-LABEL: foo5:
; RV64ZDINX:       # %bb.0: # %entry
; RV64ZDINX-NEXT:    addi a0, a0, -2048
; RV64ZDINX-NEXT:    sd a1, -1(a0)
; RV64ZDINX-NEXT:    ret
entry:
  %add.ptr = getelementptr inbounds i8, ptr %p, i64 -2049
  store double %d, ptr %add.ptr, align 8
  ret void
}

define void @foo6(ptr %p, double %d) nounwind {
; RV32ZDINX-LABEL: foo6:
; RV32ZDINX:       # %bb.0: # %entry
; RV32ZDINX-NEXT:    mv a3, a2
; RV32ZDINX-NEXT:    lui a2, %hi(.LCPI5_0)
; RV32ZDINX-NEXT:    lw a4, %lo(.LCPI5_0)(a2)
; RV32ZDINX-NEXT:    addi a2, a2, %lo(.LCPI5_0)
; RV32ZDINX-NEXT:    lw a5, 4(a2)
; RV32ZDINX-NEXT:    mv a2, a1
; RV32ZDINX-NEXT:    addi a1, a0, 2044
; RV32ZDINX-NEXT:    fadd.d a2, a2, a4
; RV32ZDINX-NEXT:    sw a3, 4(a1)
; RV32ZDINX-NEXT:    sw a2, 2044(a0)
; RV32ZDINX-NEXT:    ret
;
; RV32ZDINXUALIGNED-LABEL: foo6:
; RV32ZDINXUALIGNED:       # %bb.0: # %entry
; RV32ZDINXUALIGNED-NEXT:    mv a3, a2
; RV32ZDINXUALIGNED-NEXT:    lui a2, %hi(.LCPI5_0)
; RV32ZDINXUALIGNED-NEXT:    lw a4, %lo(.LCPI5_0)(a2)
; RV32ZDINXUALIGNED-NEXT:    addi a2, a2, %lo(.LCPI5_0)
; RV32ZDINXUALIGNED-NEXT:    lw a5, 4(a2)
; RV32ZDINXUALIGNED-NEXT:    mv a2, a1
; RV32ZDINXUALIGNED-NEXT:    addi a1, a0, 2044
; RV32ZDINXUALIGNED-NEXT:    fadd.d a2, a2, a4
; RV32ZDINXUALIGNED-NEXT:    sw a3, 4(a1)
; RV32ZDINXUALIGNED-NEXT:    sw a2, 2044(a0)
; RV32ZDINXUALIGNED-NEXT:    ret
;
; RV64ZDINX-LABEL: foo6:
; RV64ZDINX:       # %bb.0: # %entry
; RV64ZDINX-NEXT:    lui a2, %hi(.LCPI5_0)
; RV64ZDINX-NEXT:    ld a2, %lo(.LCPI5_0)(a2)
; RV64ZDINX-NEXT:    fadd.d a1, a1, a2
; RV64ZDINX-NEXT:    sd a1, 2044(a0)
; RV64ZDINX-NEXT:    ret
entry:
  %add = fadd double %d, 3.140000e+00
  %add.ptr = getelementptr inbounds i8, ptr %p, i64 2044
  store double %add, ptr %add.ptr, align 8
  ret void
}

define void @foo7(ptr nocapture %p) nounwind {
; RV32ZDINX-LABEL: foo7:
; RV32ZDINX:       # %bb.0: # %entry
; RV32ZDINX-NEXT:    lui a1, %hi(d)
; RV32ZDINX-NEXT:    addi a2, a1, %lo(d)
; RV32ZDINX-NEXT:    lw a1, %lo(d+4)(a1)
; RV32ZDINX-NEXT:    lw a2, 8(a2)
; RV32ZDINX-NEXT:    addi a3, a0, 2044
; RV32ZDINX-NEXT:    sw a1, 2044(a0)
; RV32ZDINX-NEXT:    sw a2, 4(a3)
; RV32ZDINX-NEXT:    ret
;
; RV32ZDINXUALIGNED-LABEL: foo7:
; RV32ZDINXUALIGNED:       # %bb.0: # %entry
; RV32ZDINXUALIGNED-NEXT:    lui a1, %hi(d)
; RV32ZDINXUALIGNED-NEXT:    addi a2, a1, %lo(d)
; RV32ZDINXUALIGNED-NEXT:    lw a1, %lo(d+4)(a1)
; RV32ZDINXUALIGNED-NEXT:    lw a2, 8(a2)
; RV32ZDINXUALIGNED-NEXT:    addi a3, a0, 2044
; RV32ZDINXUALIGNED-NEXT:    sw a1, 2044(a0)
; RV32ZDINXUALIGNED-NEXT:    sw a2, 4(a3)
; RV32ZDINXUALIGNED-NEXT:    ret
;
; RV64ZDINX-LABEL: foo7:
; RV64ZDINX:       # %bb.0: # %entry
; RV64ZDINX-NEXT:    lui a1, %hi(d)
; RV64ZDINX-NEXT:    addi a2, a1, %lo(d)
; RV64ZDINX-NEXT:    lw a2, 8(a2)
; RV64ZDINX-NEXT:    lwu a1, %lo(d+4)(a1)
; RV64ZDINX-NEXT:    slli a2, a2, 32
; RV64ZDINX-NEXT:    or a1, a2, a1
; RV64ZDINX-NEXT:    sd a1, 2044(a0)
; RV64ZDINX-NEXT:    ret
entry:
  %p2 = getelementptr inbounds i8, ptr @d, i32 4
  %0 = load double, ptr %p2, align 4
  %add.ptr = getelementptr inbounds i8, ptr %p, i64 2044
  store double %0, ptr %add.ptr, align 8
  ret void
}

define void @foo8(ptr %p) nounwind {
; RV32ZDINX-LABEL: foo8:
; RV32ZDINX:       # %bb.0: # %entry
; RV32ZDINX-NEXT:    addi sp, sp, -16
; RV32ZDINX-NEXT:    sw a0, 8(sp)
; RV32ZDINX-NEXT:    addi a1, a0, 2044
; RV32ZDINX-NEXT:    lw a0, 2044(a0)
; RV32ZDINX-NEXT:    lw a1, 4(a1)
; RV32ZDINX-NEXT:    lui a2, %hi(d)
; RV32ZDINX-NEXT:    addi a3, a2, %lo(d)
; RV32ZDINX-NEXT:    sw a0, %lo(d+4)(a2)
; RV32ZDINX-NEXT:    sw a1, 8(a3)
; RV32ZDINX-NEXT:    addi sp, sp, 16
; RV32ZDINX-NEXT:    ret
;
; RV32ZDINXUALIGNED-LABEL: foo8:
; RV32ZDINXUALIGNED:       # %bb.0: # %entry
; RV32ZDINXUALIGNED-NEXT:    addi sp, sp, -16
; RV32ZDINXUALIGNED-NEXT:    sw a0, 8(sp)
; RV32ZDINXUALIGNED-NEXT:    addi a1, a0, 2044
; RV32ZDINXUALIGNED-NEXT:    lw a0, 2044(a0)
; RV32ZDINXUALIGNED-NEXT:    lw a1, 4(a1)
; RV32ZDINXUALIGNED-NEXT:    lui a2, %hi(d)
; RV32ZDINXUALIGNED-NEXT:    addi a3, a2, %lo(d)
; RV32ZDINXUALIGNED-NEXT:    sw a0, %lo(d+4)(a2)
; RV32ZDINXUALIGNED-NEXT:    sw a1, 8(a3)
; RV32ZDINXUALIGNED-NEXT:    addi sp, sp, 16
; RV32ZDINXUALIGNED-NEXT:    ret
;
; RV64ZDINX-LABEL: foo8:
; RV64ZDINX:       # %bb.0: # %entry
; RV64ZDINX-NEXT:    addi sp, sp, -16
; RV64ZDINX-NEXT:    ld a1, 2044(a0)
; RV64ZDINX-NEXT:    sd a0, 8(sp)
; RV64ZDINX-NEXT:    lui a0, %hi(d)
; RV64ZDINX-NEXT:    addi a2, a0, %lo(d)
; RV64ZDINX-NEXT:    sw a1, %lo(d+4)(a0)
; RV64ZDINX-NEXT:    srli a1, a1, 32
; RV64ZDINX-NEXT:    sw a1, 8(a2)
; RV64ZDINX-NEXT:    addi sp, sp, 16
; RV64ZDINX-NEXT:    ret
entry:
  %p.addr = alloca ptr, align 8
  store ptr %p, ptr %p.addr, align 8
  %0 = load ptr, ptr %p.addr, align 8
  %add.ptr = getelementptr inbounds i8, ptr %0, i64 2044
  %1 = load double, ptr %add.ptr, align 8
  %p2 = getelementptr inbounds i8, ptr @d, i32 4
  store double %1, ptr %p2, align 4
  ret void
}

@e = global double 4.2, align 4

define void @foo9(ptr nocapture %p) nounwind {
; RV32ZDINX-LABEL: foo9:
; RV32ZDINX:       # %bb.0: # %entry
; RV32ZDINX-NEXT:    lui a1, %hi(e)
; RV32ZDINX-NEXT:    addi a2, a1, %lo(e)
; RV32ZDINX-NEXT:    lw a1, %lo(e)(a1)
; RV32ZDINX-NEXT:    lw a2, 4(a2)
; RV32ZDINX-NEXT:    addi a3, a0, 2044
; RV32ZDINX-NEXT:    sw a1, 2044(a0)
; RV32ZDINX-NEXT:    sw a2, 4(a3)
; RV32ZDINX-NEXT:    ret
;
; RV32ZDINXUALIGNED-LABEL: foo9:
; RV32ZDINXUALIGNED:       # %bb.0: # %entry
; RV32ZDINXUALIGNED-NEXT:    lui a1, %hi(e)
; RV32ZDINXUALIGNED-NEXT:    addi a2, a1, %lo(e)
; RV32ZDINXUALIGNED-NEXT:    lw a1, %lo(e)(a1)
; RV32ZDINXUALIGNED-NEXT:    lw a2, 4(a2)
; RV32ZDINXUALIGNED-NEXT:    addi a3, a0, 2044
; RV32ZDINXUALIGNED-NEXT:    sw a1, 2044(a0)
; RV32ZDINXUALIGNED-NEXT:    sw a2, 4(a3)
; RV32ZDINXUALIGNED-NEXT:    ret
;
; RV64ZDINX-LABEL: foo9:
; RV64ZDINX:       # %bb.0: # %entry
; RV64ZDINX-NEXT:    lui a1, %hi(e)
; RV64ZDINX-NEXT:    addi a2, a1, %lo(e)
; RV64ZDINX-NEXT:    lw a2, 4(a2)
; RV64ZDINX-NEXT:    lwu a1, %lo(e)(a1)
; RV64ZDINX-NEXT:    slli a2, a2, 32
; RV64ZDINX-NEXT:    or a1, a2, a1
; RV64ZDINX-NEXT:    sd a1, 2044(a0)
; RV64ZDINX-NEXT:    ret
entry:
  %0 = load double, ptr @e, align 4
  %add.ptr = getelementptr inbounds i8, ptr %p, i64 2044
  store double %0, ptr %add.ptr, align 8
  ret void
}

define void @foo10(ptr %p) nounwind {
; RV32ZDINX-LABEL: foo10:
; RV32ZDINX:       # %bb.0: # %entry
; RV32ZDINX-NEXT:    addi sp, sp, -16
; RV32ZDINX-NEXT:    sw a0, 8(sp)
; RV32ZDINX-NEXT:    lw a1, 2044(a0)
; RV32ZDINX-NEXT:    addi a0, a0, 2044
; RV32ZDINX-NEXT:    lw a0, 4(a0)
; RV32ZDINX-NEXT:    lui a2, %hi(e)
; RV32ZDINX-NEXT:    sw a1, %lo(e)(a2)
; RV32ZDINX-NEXT:    addi a1, a2, %lo(e)
; RV32ZDINX-NEXT:    sw a0, 4(a1)
; RV32ZDINX-NEXT:    addi sp, sp, 16
; RV32ZDINX-NEXT:    ret
;
; RV32ZDINXUALIGNED-LABEL: foo10:
; RV32ZDINXUALIGNED:       # %bb.0: # %entry
; RV32ZDINXUALIGNED-NEXT:    addi sp, sp, -16
; RV32ZDINXUALIGNED-NEXT:    sw a0, 8(sp)
; RV32ZDINXUALIGNED-NEXT:    lw a1, 2044(a0)
; RV32ZDINXUALIGNED-NEXT:    addi a0, a0, 2044
; RV32ZDINXUALIGNED-NEXT:    lw a0, 4(a0)
; RV32ZDINXUALIGNED-NEXT:    lui a2, %hi(e)
; RV32ZDINXUALIGNED-NEXT:    sw a1, %lo(e)(a2)
; RV32ZDINXUALIGNED-NEXT:    addi a1, a2, %lo(e)
; RV32ZDINXUALIGNED-NEXT:    sw a0, 4(a1)
; RV32ZDINXUALIGNED-NEXT:    addi sp, sp, 16
; RV32ZDINXUALIGNED-NEXT:    ret
;
; RV64ZDINX-LABEL: foo10:
; RV64ZDINX:       # %bb.0: # %entry
; RV64ZDINX-NEXT:    addi sp, sp, -16
; RV64ZDINX-NEXT:    ld a1, 2044(a0)
; RV64ZDINX-NEXT:    sd a0, 8(sp)
; RV64ZDINX-NEXT:    lui a0, %hi(e)
; RV64ZDINX-NEXT:    sw a1, %lo(e)(a0)
; RV64ZDINX-NEXT:    addi a0, a0, %lo(e)
; RV64ZDINX-NEXT:    srli a1, a1, 32
; RV64ZDINX-NEXT:    sw a1, 4(a0)
; RV64ZDINX-NEXT:    addi sp, sp, 16
; RV64ZDINX-NEXT:    ret
entry:
  %p.addr = alloca ptr, align 8
  store ptr %p, ptr %p.addr, align 8
  %0 = load ptr, ptr %p.addr, align 8
  %add.ptr = getelementptr inbounds i8, ptr %0, i64 2044
  %1 = load double, ptr %add.ptr, align 8
  store double %1, ptr @e, align 4
  ret void
}

define void @foo11(ptr nocapture %p, double %d) nounwind {
; RV32ZDINX-LABEL: foo11:
; RV32ZDINX:       # %bb.0: # %entry
; RV32ZDINX-NEXT:    addi a0, a0, 2047
; RV32ZDINX-NEXT:    addi a3, a0, 2045
; RV32ZDINX-NEXT:    sw a1, 2045(a0)
; RV32ZDINX-NEXT:    sw a2, 4(a3)
; RV32ZDINX-NEXT:    ret
;
; RV32ZDINXUALIGNED-LABEL: foo11:
; RV32ZDINXUALIGNED:       # %bb.0: # %entry
; RV32ZDINXUALIGNED-NEXT:    addi a0, a0, 2047
; RV32ZDINXUALIGNED-NEXT:    addi a3, a0, 2045
; RV32ZDINXUALIGNED-NEXT:    sw a1, 2045(a0)
; RV32ZDINXUALIGNED-NEXT:    sw a2, 4(a3)
; RV32ZDINXUALIGNED-NEXT:    ret
;
; RV64ZDINX-LABEL: foo11:
; RV64ZDINX:       # %bb.0: # %entry
; RV64ZDINX-NEXT:    addi a0, a0, 2047
; RV64ZDINX-NEXT:    sd a1, 2045(a0)
; RV64ZDINX-NEXT:    ret
entry:
  %add.ptr = getelementptr inbounds i8, ptr %p, i64 4092
  store double %d, ptr %add.ptr, align 8
  ret void
}

define void @foo12(ptr nocapture %p, double %d) nounwind {
; RV32ZDINX-LABEL: foo12:
; RV32ZDINX:       # %bb.0: # %entry
; RV32ZDINX-NEXT:    lui a3, 2
; RV32ZDINX-NEXT:    addi a3, a3, 2047
; RV32ZDINX-NEXT:    add a0, a0, a3
; RV32ZDINX-NEXT:    sw a1, 0(a0)
; RV32ZDINX-NEXT:    sw a2, 4(a0)
; RV32ZDINX-NEXT:    ret
;
; RV32ZDINXUALIGNED-LABEL: foo12:
; RV32ZDINXUALIGNED:       # %bb.0: # %entry
; RV32ZDINXUALIGNED-NEXT:    lui a3, 2
; RV32ZDINXUALIGNED-NEXT:    addi a3, a3, 2047
; RV32ZDINXUALIGNED-NEXT:    add a0, a0, a3
; RV32ZDINXUALIGNED-NEXT:    sw a1, 0(a0)
; RV32ZDINXUALIGNED-NEXT:    sw a2, 4(a0)
; RV32ZDINXUALIGNED-NEXT:    ret
;
; RV64ZDINX-LABEL: foo12:
; RV64ZDINX:       # %bb.0: # %entry
; RV64ZDINX-NEXT:    lui a2, 2
; RV64ZDINX-NEXT:    add a0, a0, a2
; RV64ZDINX-NEXT:    sd a1, 2047(a0)
; RV64ZDINX-NEXT:    ret
entry:
  %add.ptr = getelementptr inbounds i8, ptr %p, i64 10239
  store double %d, ptr %add.ptr, align 8
  ret void
}

@f = global double 4.2, align 16

define double @foo13(ptr nocapture %p) nounwind {
; RV32ZDINX-LABEL: foo13:
; RV32ZDINX:       # %bb.0: # %entry
; RV32ZDINX-NEXT:    lui a1, %hi(f)
; RV32ZDINX-NEXT:    lw a0, %lo(f+4)(a1)
; RV32ZDINX-NEXT:    lw a1, %lo(f+8)(a1)
; RV32ZDINX-NEXT:    ret
;
; RV32ZDINXUALIGNED-LABEL: foo13:
; RV32ZDINXUALIGNED:       # %bb.0: # %entry
; RV32ZDINXUALIGNED-NEXT:    lui a1, %hi(f)
; RV32ZDINXUALIGNED-NEXT:    lw a0, %lo(f+4)(a1)
; RV32ZDINXUALIGNED-NEXT:    lw a1, %lo(f+8)(a1)
; RV32ZDINXUALIGNED-NEXT:    ret
;
; RV64ZDINX-LABEL: foo13:
; RV64ZDINX:       # %bb.0: # %entry
; RV64ZDINX-NEXT:    lui a0, %hi(f)
; RV64ZDINX-NEXT:    lw a1, %lo(f+8)(a0)
; RV64ZDINX-NEXT:    lwu a0, %lo(f+4)(a0)
; RV64ZDINX-NEXT:    slli a1, a1, 32
; RV64ZDINX-NEXT:    or a0, a1, a0
; RV64ZDINX-NEXT:    ret
entry:
  %add.ptr = getelementptr inbounds i8, ptr @f, i64 4
  %0 = load double, ptr %add.ptr, align 4
  ret double %0
}

define double @foo14(ptr nocapture %p) nounwind {
; RV32ZDINX-LABEL: foo14:
; RV32ZDINX:       # %bb.0: # %entry
; RV32ZDINX-NEXT:    lui a1, %hi(f)
; RV32ZDINX-NEXT:    lw a0, %lo(f+8)(a1)
; RV32ZDINX-NEXT:    lw a1, %lo(f+12)(a1)
; RV32ZDINX-NEXT:    ret
;
; RV32ZDINXUALIGNED-LABEL: foo14:
; RV32ZDINXUALIGNED:       # %bb.0: # %entry
; RV32ZDINXUALIGNED-NEXT:    lui a1, %hi(f)
; RV32ZDINXUALIGNED-NEXT:    lw a0, %lo(f+8)(a1)
; RV32ZDINXUALIGNED-NEXT:    lw a1, %lo(f+12)(a1)
; RV32ZDINXUALIGNED-NEXT:    ret
;
; RV64ZDINX-LABEL: foo14:
; RV64ZDINX:       # %bb.0: # %entry
; RV64ZDINX-NEXT:    lui a0, %hi(f)
; RV64ZDINX-NEXT:    ld a0, %lo(f+8)(a0)
; RV64ZDINX-NEXT:    ret
entry:
  %add.ptr = getelementptr inbounds i8, ptr @f, i64 8
  %0 = load double, ptr %add.ptr, align 8
  ret double %0
}
