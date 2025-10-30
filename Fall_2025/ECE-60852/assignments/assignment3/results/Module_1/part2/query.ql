import cpp

from 
  FunctionCall fc, 
  StringLiteral sl
where
  fc.getTarget().getName() in ["sprintf", "sscanf", "fscanf"] and
  fc.getArgument(1) = sl and
  sl.getValue().matches("%%%s%")
select 
  fc.getFile().getRelativePath(), 
  fc.getLocation().getStartLine(),
  fc.getLocation().getStartColumn()
