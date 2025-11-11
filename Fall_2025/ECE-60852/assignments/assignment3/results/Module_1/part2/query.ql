import cpp
import semmle.code.cpp.dataflow.new.DataFlow

module StringFormattingConfiguration implements DataFlow::ConfigSig {
    
    predicate isSource(DataFlow::Node source) {
        exists(StringLiteral stringLiteral |
            source.asExpr() = stringLiteral and
            stringLiteral.getValue().matches("%\\%s%")
        )
    }

    predicate isSink(DataFlow::Node sink) {
        exists(FunctionCall functionCall |
            functionCall.getTarget().getName() in ["sprintf", "sscanf", "fscanf"] and 
            functionCall.getNumberOfArguments() > 1 and
            sink.asExpr() = functionCall.getArgument(1)
        )
    }
}

module StringFormattingFlow = DataFlow::Global<StringFormattingConfiguration>;

from 
    DataFlow::Node source,
    DataFlow::Node sink,
    FunctionCall functionCall
where
    StringFormattingFlow::flow(source, sink) and
    sink.asExpr().getParent() = functionCall
select
    functionCall.getFile().getRelativePath(), 
    functionCall.getLocation().getStartLine(),
    functionCall.getLocation().getStartColumn()