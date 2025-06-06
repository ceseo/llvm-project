; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 5
; RUN: opt -p loop-idiom -S %s | FileCheck %s

define void @fold_add_zext_to_sext(ptr %dst, i1 %start) {
; CHECK-LABEL: define void @fold_add_zext_to_sext(
; CHECK-SAME: ptr [[DST:%.*]], i1 [[START:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*]]:
; CHECK-NEXT:    [[START_EXT:%.*]] = zext i1 [[START]] to i32
; CHECK-NEXT:    [[TMP0:%.*]] = zext i1 [[START]] to i64
; CHECK-NEXT:    [[TMP1:%.*]] = shl nuw nsw i64 [[TMP0]], 2
; CHECK-NEXT:    [[SCEVGEP:%.*]] = getelementptr i8, ptr [[DST]], i64 [[TMP1]]
; CHECK-NEXT:    [[TMP2:%.*]] = sub i32 25, [[START_EXT]]
; CHECK-NEXT:    [[TMP3:%.*]] = zext nneg i32 [[TMP2]] to i64
; CHECK-NEXT:    [[TMP4:%.*]] = shl nuw nsw i64 [[TMP3]], 2
; CHECK-NEXT:    call void @llvm.memset.p0.i64(ptr align 4 [[SCEVGEP]], i8 0, i64 [[TMP4]], i1 false)
; CHECK-NEXT:    br label %[[LOOP:.*]]
; CHECK:       [[LOOP]]:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ [[START_EXT]], %[[ENTRY]] ], [ [[IV_NEXT:%.*]], %[[LOOP]] ]
; CHECK-NEXT:    [[IV_EXT:%.*]] = zext i32 [[IV]] to i64
; CHECK-NEXT:    [[GEP:%.*]] = getelementptr i32, ptr [[DST]], i64 [[IV_EXT]]
; CHECK-NEXT:    [[IV_NEXT]] = add i32 [[IV]], 1
; CHECK-NEXT:    [[EC:%.*]] = icmp ult i32 [[IV]], 24
; CHECK-NEXT:    br i1 [[EC]], label %[[LOOP]], label %[[EXIT:.*]]
; CHECK:       [[EXIT]]:
; CHECK-NEXT:    ret void
;
entry:
  %start.ext = zext i1 %start to i32
  br label %loop

loop:
  %iv = phi i32 [ %start.ext, %entry ], [ %iv.next, %loop ]
  %iv.ext = zext i32 %iv to i64
  %gep = getelementptr i32, ptr %dst, i64 %iv.ext
  store i32 0, ptr %gep, align 4
  %iv.next = add i32 %iv, 1
  %ec = icmp ult i32 %iv, 24
  br i1 %ec, label %loop, label %exit

exit:
  ret void
}
