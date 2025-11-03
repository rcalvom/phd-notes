import cpp

from AllocationFunction allocationFunction, FunctionCall functionCall
where functionCall.getTarget() = allocationFunction and
functionCall.getArgument(allocationFunction.getSizeArg()) instanceof MulExpr
select functionCall, allocationFunction.getSizeArg()