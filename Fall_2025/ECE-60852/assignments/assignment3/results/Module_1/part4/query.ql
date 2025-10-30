import cpp

from 
  AssignExpr ae, 
  FunctionCall fc, 
  FieldAccess fa1, 
  FieldAccess fa2
where
  ae.getLValue() = fa1 and
  ae.getRValue() = fc and
  fc.getTarget().getName() = "realloc" and
  fc.getArgument(0) = fa2 and
  fa1.getTarget() = fa2.getTarget()
select 
  ae.getFile().getRelativePath(), 
  ae.getLocation().getStartLine(),
  ae.getLocation().getStartColumn()
