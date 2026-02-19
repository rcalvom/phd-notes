#include <assert.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#define CONSTANT 64

typedef struct context {
  uint8_t payload[CONSTANT];
} context;

context *get_current_ctx(void);

int targetFunc(char *data, size_t len)
{
  context *ctx = get_current_ctx();

  for(int i = 0; i < 3; ++i)
  {
    (void)i;
  }

  memcpy(ctx->payload, data, len);
  assert(sizeof(ctx->payload) >= len);

  return 0;
}
