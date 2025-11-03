import cpp
import semmle.code.cpp.dataflow.new.DataFlow

module TroubleSnprintfConfiguration implements DataFlow::ConfigSig {
    
    predicate isSource(DataFlow::Node source) {
        exists(FunctionCall functionCall |
            source.asExpr() = functionCall and
            functionCall.getTarget().hasName("snprintf")
        )
    }

    predicate isSink(DataFlow::Node sink) {
        exists(AssignOperation assign |
            sink.asExpr() = assign.getRValue()
        )
    }
}

module TroubleSnprintfFlow = DataFlow::Global<TroubleSnprintfConfiguration>;

from 
    DataFlow::Node source,
    DataFlow::Node sink,
    AssignOperation assign,
    FunctionCall functionCall,
    VariableAccess variableAccess1,
    VariableAccess variableAccess2
where
    TroubleSnprintfFlow::flow(source, sink) and
    source.asExpr() = functionCall and
    sink.asExpr() = assign.getRValue() and
    functionCall.getArgument(0) = variableAccess1 and
    assign.getLValue() = variableAccess2 and
    variableAccess1.getTarget() = variableAccess2.getTarget()
select 
    assign,
    source,
    sink