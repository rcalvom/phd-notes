import cpp
import semmle.code.cpp.dataflow.new.DataFlow

module TaintedMultiplicationConfiguration implements DataFlow::ConfigSig {
    
    predicate isSource(DataFlow::Node source) {
        exists(AllocationFunction allocationFunction, FunctionCall functionCall |
            functionCall.getTarget() = allocationFunction and
            source.asExpr() = functionCall and
            functionCall.getArgument(allocationFunction.getSizeArg()) instanceof MulExpr
        )
    }

    predicate isSink(DataFlow::Node sink) {
        exists(AssignExpr assign |
            sink.asExpr() = assign.getRValue()
        )
    }
}

module TaintedMultiplicationFlow = DataFlow::Global<TaintedMultiplicationConfiguration>;

from 
    DataFlow::Node source,
    DataFlow::Node sink,
    AssignExpr assign,
    FunctionCall functionCall,
    FieldAccess fieldAccess1,
    FieldAccess fieldAccess2
where
    TaintedMultiplicationFlow::flow(source, sink) and
    source.asExpr() = functionCall and
    sink.asExpr() = assign.getRValue() and
    functionCall.getArgument(0) = fieldAccess1 and
    assign.getLValue() = fieldAccess2 and
    fieldAccess1.getTarget() = fieldAccess2.getTarget()
select
    assign.getFile().getRelativePath(), 
    assign.getLocation().getStartLine(),
    assign.getLocation().getStartColumn()