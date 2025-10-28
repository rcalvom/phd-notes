import cpp

from Variable var, FunctionCall call
where
  call.getTarget().hasName("snprintf") and
  call.getArgument(0).getUnderlyingVariable() = var and
  exists(AssignExpr assign |
    assign.getAnOperand() = var and
    assign.getAnOperand() = call and
    assign.getOperator() = "+=")
select assign, "Variable used as destination and LHS in snprintf: " + var.getName()
