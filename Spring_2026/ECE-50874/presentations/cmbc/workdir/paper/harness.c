#include <stdlib.h>

#include "source.c"

context *get_current_ctx(void)
{
  context *ctx = malloc(sizeof(context));
  __CPROVER_assume(ctx != NULL);
  return ctx;
}

void harness(void)
{
  size_t len;
  __CPROVER_assume(len <= CONSTANT);

  char *data = malloc(len);
  __CPROVER_assume(data != NULL);

  targetFunc(data, len);
}
