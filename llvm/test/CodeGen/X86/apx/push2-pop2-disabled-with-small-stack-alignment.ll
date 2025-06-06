; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+push2pop2 | FileCheck %s --check-prefix=CHECK

; This test is used to check no push2/pop2 emitted if stack alignment is set to
; the value less than 16 bytes required by push2/pop2 instruction. Here it's set
; to 8 bytes.

define void @csr1() nounwind {
; CHECK-LABEL: csr1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pushq %rbp
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    popq %rbp
; CHECK-NEXT:    retq
entry:
  tail call void asm sideeffect "", "~{rbp},~{dirflag},~{fpsr},~{flags}"()
  ret void
}

define void @csr2() nounwind {
; CHECK-LABEL: csr2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pushq %rbp
; CHECK-NEXT:    pushq %r15
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    popq %r15
; CHECK-NEXT:    popq %rbp
; CHECK-NEXT:    retq
entry:
  tail call void asm sideeffect "", "~{rbp},~{r15},~{dirflag},~{fpsr},~{flags}"()
  ret void
}

define void @csr3() nounwind {
; CHECK-LABEL: csr3:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pushq %rbp
; CHECK-NEXT:    pushq %r15
; CHECK-NEXT:    pushq %r14
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    popq %r14
; CHECK-NEXT:    popq %r15
; CHECK-NEXT:    popq %rbp
; CHECK-NEXT:    retq
entry:
  tail call void asm sideeffect "", "~{rbp},~{r15},~{r14},~{dirflag},~{fpsr},~{flags}"()
  ret void
}

define void @csr4() nounwind {
; CHECK-LABEL: csr4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pushq %rbp
; CHECK-NEXT:    pushq %r15
; CHECK-NEXT:    pushq %r14
; CHECK-NEXT:    pushq %r13
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    popq %r13
; CHECK-NEXT:    popq %r14
; CHECK-NEXT:    popq %r15
; CHECK-NEXT:    popq %rbp
; CHECK-NEXT:    retq
entry:
  tail call void asm sideeffect "", "~{rbp},~{r15},~{r14},~{r13},~{dirflag},~{fpsr},~{flags}"()
  ret void
}

define void @csr5() nounwind {
; CHECK-LABEL: csr5:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pushq %rbp
; CHECK-NEXT:    pushq %r15
; CHECK-NEXT:    pushq %r14
; CHECK-NEXT:    pushq %r13
; CHECK-NEXT:    pushq %r12
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    popq %r12
; CHECK-NEXT:    popq %r13
; CHECK-NEXT:    popq %r14
; CHECK-NEXT:    popq %r15
; CHECK-NEXT:    popq %rbp
; CHECK-NEXT:    retq
entry:
  tail call void asm sideeffect "", "~{rbp},~{r15},~{r14},~{r13},~{r12},~{dirflag},~{fpsr},~{flags}"()
  ret void
}

define void @csr6() nounwind {
; CHECK-LABEL: csr6:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pushq %rbp
; CHECK-NEXT:    pushq %r15
; CHECK-NEXT:    pushq %r14
; CHECK-NEXT:    pushq %r13
; CHECK-NEXT:    pushq %r12
; CHECK-NEXT:    pushq %rbx
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    popq %rbx
; CHECK-NEXT:    popq %r12
; CHECK-NEXT:    popq %r13
; CHECK-NEXT:    popq %r14
; CHECK-NEXT:    popq %r15
; CHECK-NEXT:    popq %rbp
; CHECK-NEXT:    retq
entry:
  tail call void asm sideeffect "", "~{rbp},~{r15},~{r14},~{r13},~{r12},~{rbx},~{dirflag},~{fpsr},~{flags}"()
  ret void
}

!llvm.module.flags = !{!0}
!0 = !{i32 1, !"override-stack-alignment", i32 8}
