; ModuleID = 'simple3.ll'
source_filename = "simple3.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 !dbg !7 {
entry:
  %retval = alloca i32, align 4
  %a = alloca i32, align 4
  %b = alloca i32, align 4
  %d = alloca i32, align 4
  %c = alloca i32, align 4
  %e = alloca i32, align 4
  store i32 0, i32* %retval, align 4
  tail call void @__coverage__(i32 2, i32 7), !dbg !11
  call void @llvm.dbg.declare(metadata i32* %a, metadata !12, metadata !DIExpression()), !dbg !11
  tail call void @__coverage__(i32 2, i32 7), !dbg !11
  store i32 0, i32* %a, align 4, !dbg !11
  tail call void @__coverage__(i32 3, i32 7), !dbg !13
  call void @llvm.dbg.declare(metadata i32* %b, metadata !14, metadata !DIExpression()), !dbg !13
  tail call void @__coverage__(i32 3, i32 7), !dbg !13
  store i32 0, i32* %b, align 4, !dbg !13
  tail call void @__coverage__(i32 4, i32 7), !dbg !15
  call void @llvm.dbg.declare(metadata i32* %d, metadata !16, metadata !DIExpression()), !dbg !15
  tail call void @__coverage__(i32 4, i32 7), !dbg !15
  store i32 5, i32* %d, align 4, !dbg !15
  tail call void @__coverage__(i32 5, i32 7), !dbg !17
  call void @llvm.dbg.declare(metadata i32* %c, metadata !18, metadata !DIExpression()), !dbg !17
  tail call void @__coverage__(i32 5, i32 11), !dbg !19
  %0 = load i32, i32* %a, align 4, !dbg !19
  tail call void @__coverage__(i32 5, i32 16), !dbg !20
  %1 = load i32, i32* %b, align 4, !dbg !20
  tail call void @__coverage__(i32 5, i32 13), !dbg !21
  %cmp = icmp eq i32 %0, %1, !dbg !21
  tail call void @__coverage__(i32 5, i32 13), !dbg !21
  %conv = zext i1 %cmp to i32, !dbg !21
  tail call void @__coverage__(i32 5, i32 7), !dbg !17
  store i32 %conv, i32* %c, align 4, !dbg !17
  tail call void @__coverage__(i32 6, i32 7), !dbg !22
  call void @llvm.dbg.declare(metadata i32* %e, metadata !23, metadata !DIExpression()), !dbg !22
  tail call void @__coverage__(i32 6, i32 11), !dbg !24
  %2 = load i32, i32* %d, align 4, !dbg !24
  tail call void @__coverage__(i32 6, i32 16), !dbg !25
  %3 = load i32, i32* %c, align 4, !dbg !25
  tail call void @__coverage__(i32 6, i32 18), !dbg !26
  %mul = mul nsw i32 %3, 0, !dbg !26
  tail call void @__coverage__(i32 6, i32 13), !dbg !27
  tail call void @__sanitize__(i32 %mul, i32 6, i32 13), !dbg !27
  %div = sdiv i32 %2, %mul, !dbg !27
  tail call void @__coverage__(i32 6, i32 7), !dbg !22
  store i32 %div, i32* %e, align 4, !dbg !22
  tail call void @__coverage__(i32 7, i32 3), !dbg !28
  ret i32 0, !dbg !28
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

declare void @__coverage__(i32, i32)

declare void @__sanitize__(i32, i32, i32)

attributes #0 = { noinline nounwind optnone uwtable "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "Ubuntu clang version 12.0.1-19ubuntu3", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "simple3.c", directory: "/workspace/part4/part4_instrumentation/DivZeroInstrument/test")
!2 = !{}
!3 = !{i32 7, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{!"Ubuntu clang version 12.0.1-19ubuntu3"}
!7 = distinct !DISubprogram(name: "main", scope: !1, file: !1, line: 1, type: !8, scopeLine: 1, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!8 = !DISubroutineType(types: !9)
!9 = !{!10}
!10 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!11 = !DILocation(line: 2, column: 7, scope: !7)
!12 = !DILocalVariable(name: "a", scope: !7, file: !1, line: 2, type: !10)
!13 = !DILocation(line: 3, column: 7, scope: !7)
!14 = !DILocalVariable(name: "b", scope: !7, file: !1, line: 3, type: !10)
!15 = !DILocation(line: 4, column: 7, scope: !7)
!16 = !DILocalVariable(name: "d", scope: !7, file: !1, line: 4, type: !10)
!17 = !DILocation(line: 5, column: 7, scope: !7)
!18 = !DILocalVariable(name: "c", scope: !7, file: !1, line: 5, type: !10)
!19 = !DILocation(line: 5, column: 11, scope: !7)
!20 = !DILocation(line: 5, column: 16, scope: !7)
!21 = !DILocation(line: 5, column: 13, scope: !7)
!22 = !DILocation(line: 6, column: 7, scope: !7)
!23 = !DILocalVariable(name: "e", scope: !7, file: !1, line: 6, type: !10)
!24 = !DILocation(line: 6, column: 11, scope: !7)
!25 = !DILocation(line: 6, column: 16, scope: !7)
!26 = !DILocation(line: 6, column: 18, scope: !7)
!27 = !DILocation(line: 6, column: 13, scope: !7)
!28 = !DILocation(line: 7, column: 3, scope: !7)
