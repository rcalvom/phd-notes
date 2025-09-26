; ModuleID = 'simple2.ll'
source_filename = "simple2.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @f() #0 !dbg !7 {
entry:
  %x = alloca i32, align 4
  %y = alloca i32, align 4
  %z = alloca i32, align 4
  tail call void @__coverage__(i32 2, i32 7), !dbg !10
  call void @llvm.dbg.declare(metadata i32* %x, metadata !11, metadata !DIExpression()), !dbg !10
  tail call void @__coverage__(i32 2, i32 7), !dbg !10
  store i32 0, i32* %x, align 4, !dbg !10
  tail call void @__coverage__(i32 3, i32 7), !dbg !13
  call void @llvm.dbg.declare(metadata i32* %y, metadata !14, metadata !DIExpression()), !dbg !13
  tail call void @__coverage__(i32 3, i32 7), !dbg !13
  store i32 2, i32* %y, align 4, !dbg !13
  tail call void @__coverage__(i32 4, i32 7), !dbg !15
  call void @llvm.dbg.declare(metadata i32* %z, metadata !16, metadata !DIExpression()), !dbg !15
  tail call void @__coverage__(i32 5, i32 7), !dbg !17
  %0 = load i32, i32* %x, align 4, !dbg !17
  tail call void @__coverage__(i32 5, i32 9), !dbg !19
  %cmp = icmp slt i32 %0, 1, !dbg !19
  tail call void @__coverage__(i32 5, i32 7), !dbg !20
  br i1 %cmp, label %if.then, label %if.else, !dbg !20

if.then:                                          ; preds = %entry
  tail call void @__coverage__(i32 6, i32 9), !dbg !21
  %1 = load i32, i32* %y, align 4, !dbg !21
  tail call void @__coverage__(i32 6, i32 13), !dbg !23
  %2 = load i32, i32* %x, align 4, !dbg !23
  tail call void @__coverage__(i32 6, i32 11), !dbg !24
  tail call void @__sanitize__(i32 %2, i32 6, i32 11), !dbg !24
  %div = sdiv i32 %1, %2, !dbg !24
  tail call void @__coverage__(i32 6, i32 7), !dbg !25
  store i32 %div, i32* %z, align 4, !dbg !25
  tail call void @__coverage__(i32 7, i32 3), !dbg !26
  br label %if.end, !dbg !26

if.else:                                          ; preds = %entry
  tail call void @__coverage__(i32 8, i32 9), !dbg !27
  %3 = load i32, i32* %z, align 4, !dbg !27
  tail call void @__coverage__(i32 8, i32 13), !dbg !29
  %4 = load i32, i32* %x, align 4, !dbg !29
  tail call void @__coverage__(i32 8, i32 11), !dbg !30
  tail call void @__sanitize__(i32 %4, i32 8, i32 11), !dbg !30
  %div1 = sdiv i32 %3, %4, !dbg !30
  tail call void @__coverage__(i32 8, i32 7), !dbg !31
  store i32 %div1, i32* %z, align 4, !dbg !31
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  tail call void @__coverage__(i32 10, i32 1), !dbg !32
  ret void, !dbg !32
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 !dbg !33 {
entry:
  tail call void @__coverage__(i32 13, i32 3), !dbg !36
  call void @f(), !dbg !36
  tail call void @__coverage__(i32 14, i32 1), !dbg !37
  ret i32 0, !dbg !37
}

declare void @__coverage__(i32, i32)

declare void @__sanitize__(i32, i32, i32)

attributes #0 = { noinline nounwind optnone uwtable "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "Ubuntu clang version 12.0.1-19ubuntu3", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "simple2.c", directory: "/workspace/part4/part4_instrumentation/DivZeroInstrument/test")
!2 = !{}
!3 = !{i32 7, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{!"Ubuntu clang version 12.0.1-19ubuntu3"}
!7 = distinct !DISubprogram(name: "f", scope: !1, file: !1, line: 1, type: !8, scopeLine: 1, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!8 = !DISubroutineType(types: !9)
!9 = !{null}
!10 = !DILocation(line: 2, column: 7, scope: !7)
!11 = !DILocalVariable(name: "x", scope: !7, file: !1, line: 2, type: !12)
!12 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!13 = !DILocation(line: 3, column: 7, scope: !7)
!14 = !DILocalVariable(name: "y", scope: !7, file: !1, line: 3, type: !12)
!15 = !DILocation(line: 4, column: 7, scope: !7)
!16 = !DILocalVariable(name: "z", scope: !7, file: !1, line: 4, type: !12)
!17 = !DILocation(line: 5, column: 7, scope: !18)
!18 = distinct !DILexicalBlock(scope: !7, file: !1, line: 5, column: 7)
!19 = !DILocation(line: 5, column: 9, scope: !18)
!20 = !DILocation(line: 5, column: 7, scope: !7)
!21 = !DILocation(line: 6, column: 9, scope: !22)
!22 = distinct !DILexicalBlock(scope: !18, file: !1, line: 5, column: 14)
!23 = !DILocation(line: 6, column: 13, scope: !22)
!24 = !DILocation(line: 6, column: 11, scope: !22)
!25 = !DILocation(line: 6, column: 7, scope: !22)
!26 = !DILocation(line: 7, column: 3, scope: !22)
!27 = !DILocation(line: 8, column: 9, scope: !28)
!28 = distinct !DILexicalBlock(scope: !18, file: !1, line: 7, column: 10)
!29 = !DILocation(line: 8, column: 13, scope: !28)
!30 = !DILocation(line: 8, column: 11, scope: !28)
!31 = !DILocation(line: 8, column: 7, scope: !28)
!32 = !DILocation(line: 10, column: 1, scope: !7)
!33 = distinct !DISubprogram(name: "main", scope: !1, file: !1, line: 12, type: !34, scopeLine: 12, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!34 = !DISubroutineType(types: !35)
!35 = !{!12}
!36 = !DILocation(line: 13, column: 3, scope: !33)
!37 = !DILocation(line: 14, column: 1, scope: !33)
