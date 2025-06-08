#include <stdlib.h>
#include <string.h>

#include "flipflops.h"
#include "observable.h"

__attribute__((export_name("add"))) int add(int a, int b) {
  jk_flip_flop_t* jk = make_jk_flip_flop();
  apply();

  return a + b + jk->q;
}

void* calloc(size_t count, size_t size) {
  void* ptr = malloc(count * size);
  if (ptr) {
    memset(ptr, 0, count * size);
  }
  return ptr;
}
void _assert(char const* message, char const* filename, unsigned line) {}

int snprintf(char* buffer, size_t bufsz, const char* format, ...) { return 0; }