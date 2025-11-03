import cpp
import semmle.code.cpp.dataflow.new.DataFlow

module MishandledReallocConfiguration implements DataFlow::ConfigSig {
    
    predicate isSource(DataFlow::Node source) {
        exists(FunctionCall functionCall |
            source.asExpr() = functionCall and
            functionCall.getTarget().hasName("realloc")
        )
    }

    predicate isSink(DataFlow::Node sink) {
        exists(AssignExpr assign |
            sink.asExpr() = assign.getRValue()
        )
    }
}

module MishandledReallocFlow = DataFlow::Global<MishandledReallocConfiguration>;

from 
    DataFlow::Node source,
    DataFlow::Node sink,
    AssignExpr assign,
    FunctionCall functionCall,
    FieldAccess fieldAccess1,
    FieldAccess fieldAccess2
where
    MishandledReallocFlow::flow(source, sink) and
    source.asExpr() = functionCall and
    sink.asExpr() = assign.getRValue() and
    functionCall.getArgument(0) = fieldAccess1 and
    assign.getLValue() = fieldAccess2 and
    fieldAccess1.getTarget() = fieldAccess2.getTarget()
select 
    assign.getFile().getRelativePath(), 
    assign.getLocation().getStartLine(),
    assign.getLocation().getStartColumn()