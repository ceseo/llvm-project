; Validate ThinLTO prelink pipeline when we have Sample PGO
;
; RUN: opt -disable-verify -verify-analysis-invalidation=0 -eagerly-invalidate-analyses=0 -debug-pass-manager \
; RUN:     -pgo-kind=pgo-sample-use-pipeline -profile-file='%S/Inputs/new-pm-thinlto-samplepgo-defaults.prof' \
; RUN:     -passes='thinlto-pre-link<O1>' -S %s 2>&1 \
; RUN:     | FileCheck %s --check-prefixes=CHECK-O,CHECK-O1
; RUN: opt -disable-verify -verify-analysis-invalidation=0 -eagerly-invalidate-analyses=0 -debug-pass-manager \
; RUN:     -pgo-kind=pgo-sample-use-pipeline -profile-file='%S/Inputs/new-pm-thinlto-samplepgo-defaults.prof' \
; RUN:     -passes='thinlto-pre-link<O2>' -S  %s 2>&1 \
; RUN:     | FileCheck %s --check-prefixes=CHECK-O,CHECK-O2,CHECK-O23SZ
; RUN: opt -disable-verify -verify-analysis-invalidation=0 -eagerly-invalidate-analyses=0 -debug-pass-manager \
; RUN:     -pgo-kind=pgo-sample-use-pipeline -profile-file='%S/Inputs/new-pm-thinlto-samplepgo-defaults.prof' \
; RUN:     -passes='thinlto-pre-link<O3>' -S -passes-ep-pipeline-start='no-op-module' %s 2>&1 \
; RUN:     | FileCheck %s --check-prefixes=CHECK-O,CHECK-O3,CHECK-O23SZ,CHECK-EP-PIPELINE-START
; RUN: opt -disable-verify -verify-analysis-invalidation=0 -eagerly-invalidate-analyses=0 -debug-pass-manager \
; RUN:     -pgo-kind=pgo-sample-use-pipeline -profile-file='%S/Inputs/new-pm-thinlto-samplepgo-defaults.prof' \
; RUN:     -passes='thinlto-pre-link<Os>' -S %s 2>&1 \
; RUN:     | FileCheck %s --check-prefixes=CHECK-O,CHECK-O23SZ
; RUN: opt -disable-verify -verify-analysis-invalidation=0 -eagerly-invalidate-analyses=0 -debug-pass-manager \
; RUN:     -pgo-kind=pgo-sample-use-pipeline -profile-file='%S/Inputs/new-pm-thinlto-samplepgo-defaults.prof' \
; RUN:     -passes='thinlto-pre-link<Oz>' -S %s 2>&1 \
; RUN:     | FileCheck %s --check-prefixes=CHECK-O,CHECK-O23SZ
; RUN: opt -disable-verify -verify-analysis-invalidation=0 -eagerly-invalidate-analyses=0 -debug-pass-manager -debug-info-for-profiling \
; RUN:     -pgo-kind=pgo-sample-use-pipeline -profile-file='%S/Inputs/new-pm-thinlto-samplepgo-defaults.prof' \
; RUN:     -passes='thinlto-pre-link<O2>' -S  %s 2>&1 \
; RUN:     | FileCheck %s --check-prefixes=CHECK-O,CHECK-O2,CHECK-O23SZ
;
; CHECK-O: Running pass: Annotation2Metadata
; CHECK-O-NEXT: Running pass: ForceFunctionAttrsPass
; CHECK-O-NEXT: Running analysis: InnerAnalysisManagerProxy
; CHECK-O-NEXT: Running pass: AddDiscriminatorsPass
; CHECK-EP-PIPELINE-START-NEXT: Running pass: NoOpModulePass
; CHECK-O-NEXT: Running pass: InferFunctionAttrsPass
; CHECK-O-NEXT: Running analysis: TargetLibraryAnalysis
; CHECK-O-NEXT: Running pass: CoroEarlyPass
; CHECK-O-NEXT: Running pass: EntryExitInstrumenterPass
; CHECK-O-NEXT: Running pass: LowerExpectIntrinsicPass
; CHECK-O-NEXT: Running pass: SimplifyCFGPass
; CHECK-O-NEXT: Running analysis: TargetIRAnalysis
; CHECK-O-NEXT: Running analysis: AssumptionAnalysis
; CHECK-O-NEXT: Running pass: SROAPass
; CHECK-O-NEXT: Running analysis: DominatorTreeAnalysis
; CHECK-O-NEXT: Running pass: EarlyCSEPass
; CHECK-O-NEXT: Running analysis: TargetLibraryAnalysis
; CHECK-O3-NEXT: Running pass: CallSiteSplittingPass
; CHECK-O-NEXT: Running pass: SampleProfileLoaderPass
; CHECK-O-NEXT: Running analysis: LazyCallGraphAnalysis
; CHECK-O-NEXT: Running analysis: ProfileSummaryAnalysis
; CHECK-O-NEXT: Running pass: RequireAnalysisPass<{{.*}}ProfileSummaryAnalysis
; CHECK-O-NEXT: Running pass: OpenMPOptPass
; CHECK-O-NEXT: Running pass: IPSCCPPass
; CHECK-O-NEXT: Running pass: CalledValuePropagationPass
; CHECK-O-NEXT: Running pass: GlobalOptPass
; CHECK-O-NEXT: Running pass: PromotePass
; CHECK-O-NEXT: Running pass: InstCombinePass
; CHECK-O-NEXT: Running analysis: LastRunTrackingAnalysis
; CHECK-O-NEXT: Running analysis: OptimizationRemarkEmitterAnalysis on foo
; CHECK-O-NEXT: Running analysis: AAManager on foo
; CHECK-O-NEXT: Running analysis: BasicAA
; CHECK-O-NEXT: Running analysis: ScopedNoAliasAA
; CHECK-O-NEXT: Running analysis: TypeBasedAA
; CHECK-O-NEXT: Running analysis: OuterAnalysisManagerProxy
; CHECK-O-NEXT: Running analysis: BlockFrequencyAnalysis on foo
; CHECK-O-NEXT: Running analysis: BranchProbabilityAnalysis on foo
; CHECK-O-NEXT: Running analysis: LoopAnalysis on foo
; CHECK-O-NEXT: Running analysis: PostDominatorTreeAnalysis on foo
; CHECK-O-NEXT: Running pass: SimplifyCFGPass on foo
; CHECK-O-NEXT: Running pass: PGOForceFunctionAttrsPass
; CHECK-O-NEXT: Running pass: PGOEstimateTripCountsPass
; CHECK-O-NEXT: Invalidating analysis: InnerAnalysisManagerProxy
; CHECK-O-NEXT: Invalidating analysis: LazyCallGraphAnalysis
; CHECK-O-NEXT: Running pass: AlwaysInlinerPass
; CHECK-O-NEXT: Running analysis: InnerAnalysisManagerProxy
; CHECK-O-NEXT: Running pass: ModuleInlinerWrapperPass
; CHECK-O-NEXT: Running analysis: InlineAdvisorAnalysis
; CHECK-O-NEXT: Running pass: RequireAnalysisPass<{{.*}}GlobalsAA
; CHECK-O-NEXT: Running analysis: GlobalsAA
; CHECK-O-NEXT: Running analysis: CallGraphAnalysis
; CHECK-O-NEXT: Running pass: InvalidateAnalysisPass<{{.*}}AAManager
; CHECK-O-NEXT: Running pass: RequireAnalysisPass<{{.*}}ProfileSummaryAnalysis
; CHECK-O-NEXT: Running analysis: InnerAnalysisManagerProxy
; CHECK-O-NEXT: Running analysis: LazyCallGraphAnalysis on [module]
; CHECK-O-NEXT: Running analysis: TargetLibraryAnalysis on foo
; CHECK-O-NEXT: Running analysis: FunctionAnalysisManagerCGSCCProxy
; CHECK-O-NEXT: Running analysis: OuterAnalysisManagerProxy<{{.*}}LazyCallGraph::SCC{{.*}}>
; CHECK-O-NEXT: Running pass: DevirtSCCRepeatedPass
; CHECK-O-NEXT: Running pass: InlinerPass
; CHECK-O-NEXT: Running analysis: OptimizationRemarkEmitterAnalysis on foo
; CHECK-O-NEXT: Running pass: PostOrderFunctionAttrsPass
; CHECK-O3-NEXT: Running pass: ArgumentPromotionPass
; CHECK-O2-NEXT: Running pass: OpenMPOptCGSCCPass
; CHECK-O3-NEXT: Running pass: OpenMPOptCGSCCPass
; CHECK-O-NEXT: Running pass: SROAPass
; CHECK-O-NEXT: Running analysis: DominatorTreeAnalysis on foo
; CHECK-O-NEXT: Running analysis: AssumptionAnalysis on foo
; CHECK-O-NEXT: Running analysis: TargetIRAnalysis on foo
; CHECK-O-NEXT: Running pass: EarlyCSEPass
; CHECK-O-NEXT: Running analysis: MemorySSAAnalysis
; CHECK-O-NEXT: Running analysis: AAManager
; CHECK-O-NEXT: Running analysis: BasicAA on foo
; CHECK-O-NEXT: Running analysis: ScopedNoAliasAA on foo
; CHECK-O-NEXT: Running analysis: TypeBasedAA on foo
; CHECK-O-NEXT: Running analysis: OuterAnalysisManagerProxy
; CHECK-O23SZ-NEXT: Running pass: SpeculativeExecutionPass
; CHECK-O23SZ-NEXT: Running pass: JumpThreadingPass
; CHECK-O23SZ-NEXT: Running analysis: LazyValueAnalysis
; CHECK-O23SZ-NEXT: Running pass: CorrelatedValuePropagationPass
; CHECK-O23SZ-NEXT: Invalidating analysis: LazyValueAnalysis
; CHECK-O-NEXT: Running pass: SimplifyCFGPass
; CHECK-O-NEXT: Running pass: InstCombinePass
; CHECK-O-NEXT: Running analysis: LastRunTrackingAnalysis on foo
; CHECK-O-NEXT: Running analysis: BlockFrequencyAnalysis on foo
; CHECK-O-NEXT: Running analysis: BranchProbabilityAnalysis on foo
; CHECK-O-NEXT: Running analysis: LoopAnalysis on foo
; CHECK-O-NEXT: Running analysis: PostDominatorTreeAnalysis on foo
; CHECK-O23SZ-NEXT: Running pass: AggressiveInstCombinePass
; CHECK-O1-NEXT: Running pass: LibCallsShrinkWrapPass
; CHECK-O2-NEXT: Running pass: LibCallsShrinkWrapPass
; CHECK-O3-NEXT: Running pass: LibCallsShrinkWrapPass
; CHECK-O23SZ-NEXT: Running pass: TailCallElimPass
; CHECK-O-NEXT: Running pass: SimplifyCFGPass
; CHECK-O-NEXT: Running pass: ReassociatePass
; CHECK-O23SZ-NEXT: Running pass: ConstraintEliminationPass
; CHECK-O23SZ-NEXT: Running analysis: ScalarEvolutionAnalysis
; CHECK-O-NEXT: Running pass: LoopSimplifyPass
; CHECK-O-NEXT: Running pass: LCSSAPass
; CHECK-O1-NEXT: Running analysis: ScalarEvolutionAnalysis
; CHECK-O-NEXT: Running analysis: InnerAnalysisManagerProxy
; CHECK-O-NEXT: Running pass: LoopInstSimplifyPass
; CHECK-O-NEXT: Running pass: LoopSimplifyCFGPass
; CHECK-O-NEXT: Running pass: LICM
; CHECK-O-NEXT: Running pass: LoopRotatePass
; CHECK-O-NEXT: Running pass: LICM
; CHECK-O-NEXT: Running pass: SimpleLoopUnswitchPass
; CHECK-O-NEXT: Running analysis: OuterAnalysisManagerProxy
; CHECK-O-NEXT: Running pass: SimplifyCFGPass
; CHECK-O-NEXT: Running pass: InstCombinePass
; CHECK-O-NEXT: Running pass: LoopSimplifyPass
; CHECK-O-NEXT: Running pass: LCSSAPass
; CHECK-O-NEXT: Running pass: LoopIdiomRecognizePass
; CHECK-O-NEXT: Running pass: IndVarSimplifyPass
; CHECK-O-NEXT: Running pass: LoopDeletionPass
; CHECK-O-NEXT: Running pass: SROAPass on foo
; CHECK-O23SZ-NEXT: Running pass: VectorCombinePass
; CHECK-O23SZ-NEXT: Running pass: MergedLoadStoreMotionPass
; CHECK-O23SZ-NEXT: Running pass: GVNPass
; CHECK-O23SZ-NEXT: Running analysis: MemoryDependenceAnalysis
; CHECK-O1-NEXT: Running pass: MemCpyOptPass
; CHECK-O-NEXT: Running pass: SCCPPass
; CHECK-O-NEXT: Running pass: BDCEPass
; CHECK-O-NEXT: Running analysis: DemandedBitsAnalysis
; CHECK-O-NEXT: Running pass: InstCombinePass
; CHECK-O23SZ-NEXT: Running pass: JumpThreadingPass
; CHECK-O23SZ-NEXT: Running analysis: LazyValueAnalysis
; CHECK-O23SZ-NEXT: Running pass: CorrelatedValuePropagationPass
; CHECK-O23SZ-NEXT: Invalidating analysis: LazyValueAnalysis
; CHECK-O1-NEXT: Running pass: CoroElidePass
; CHECK-O-NEXT: Running pass: ADCEPass
; CHECK-O23SZ-NEXT: Running pass: MemCpyOptPass
; CHECK-O23SZ-NEXT: Running pass: DSEPass
; CHECK-O23SZ-NEXT: Running pass: MoveAutoInitPass on foo
; CHECK-O23SZ-NEXT: Running pass: LoopSimplifyPass
; CHECK-O23SZ-NEXT: Running pass: LCSSAPass
; CHECK-O23SZ-NEXT: Running pass: LICMPass
; CHECK-O23SZ-NEXT: Running pass: CoroElidePass
; CHECK-O-NEXT: Running pass: SimplifyCFGPass
; CHECK-O-NEXT: Running pass: InstCombinePass
; CHECK-O-NEXT: Running pass: PostOrderFunctionAttrsPass
; CHECK-O-NEXT: Running pass: RequireAnalysisPass<{{.*}}ShouldNotRunFunctionPassesAnalysis
; CHECK-O-NEXT: Running analysis: ShouldNotRunFunctionPassesAnalysis
; CHECK-O-NEXT: Running pass: InvalidateAnalysisPass<{{.*}}ShouldNotRunFunctionPassesAnalysis
; CHECK-O-NEXT: Invalidating analysis: ShouldNotRunFunctionPassesAnalysis
; CHECK-O-NEXT: Invalidating analysis: InlineAdvisorAnalysis
; CHECK-O-NEXT: Running pass: DeadArgumentEliminationPass
; CHECK-O-NEXT: Running pass: GlobalOptPass
; CHECK-O-NEXT: Running analysis: TargetLibraryAnalysis on bar
; CHECK-O-NEXT: Running pass: GlobalDCEPass
; CHECK-O-NEXT: Running pass: AnnotationRemarksPass on foo
; CHECK-O-NEXT: Running pass: CanonicalizeAliasesPass
; CHECK-O-NEXT: Running pass: NameAnonGlobalPass
; CHECK-O-NEXT: Running pass: PrintModulePass

; Make sure we get the IR back out without changes when we print the module.
; CHECK-O-LABEL: define void @foo(i32 %n) local_unnamed_addr
; CHECK-O-NEXT: entry:
; CHECK-O-NEXT:   br label %loop
; CHECK-O:      loop:
; CHECK-O-NEXT:   %iv = phi i32 [ 0, %entry ], [ %iv.next, %loop ]
; CHECK-O-NEXT:   %iv.next = add i32 %iv, 1
; CHECK-O-NEXT:   tail call void @bar()
; CHECK-O-NEXT:   %cmp = icmp eq i32 %iv, %n
; CHECK-O-NEXT:   br i1 %cmp, label %exit, label %loop
; CHECK-O:      exit:
; CHECK-O-NEXT:   ret void
; CHECK-O-NEXT: }
;
; Ignore a bunch of intervening metadata containing profile data.
;

declare void @bar() local_unnamed_addr

define void @foo(i32 %n) local_unnamed_addr {
entry:
  br label %loop
loop:
  %iv = phi i32 [ 0, %entry ], [ %iv.next, %loop ]
  %iv.next = add i32 %iv, 1
  tail call void @bar()
  %cmp = icmp eq i32 %iv, %n
  br i1 %cmp, label %exit, label %loop
exit:
  ret void
}
