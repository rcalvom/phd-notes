import cpp
import semmle.code.cpp.dataflow.new.DataFlow

module DoubleFreeConfiguration implements DataFlow::ConfigSig {
    
    predicate isSource(DataFlow::Node source) {
        exists(FunctionCall functionCall |
            functionCall.getTarget().hasName("free") and
            source.asExpr() = functionCall.getArgument(0)
        )
    }


    predicate isSink(DataFlow::Node sink) {
        exists(FunctionCall functionCall |
            functionCall.getTarget().hasName("free") and
            sink.asExpr() = functionCall.getArgument(0)
        )
    }
}

module DoubleFreeFlow = DataFlow::Global<DoubleFreeConfiguration>;

from 
    DataFlow::Node source,
    DataFlow::Node sink
where
    DoubleFreeFlow::flow(source, sink) and
    source != sink
select 
    sink.asExpr().getFile().getRelativePath(), 
    sink.asExpr().getLocation().getStartLine(),
    sink.asExpr().getLocation().getStartColumn()