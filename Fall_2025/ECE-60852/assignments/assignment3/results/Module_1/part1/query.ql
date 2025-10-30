import cpp

from 
  AssignAddExpr aae, 
  FunctionCall fc, 
  VariableAccess va1, 
  VariableAccess va2
where
  aae.getRValue() = fc and
  fc.getArgument(0) = va1 and
  fc.getTarget().getName() = "snprintf" and
  aae.getLValue() = va2 and
  va1.getTarget() = va2.getTarget()
select
  aae.getFile().getRelativePath(),
  aae.getLocation().getStartLine(),
  aae.getLocation().getStartColumn()
