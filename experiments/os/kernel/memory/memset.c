#include "memory.h"

void *memset(void *ptr, int value, size_t num) {
  unsigned char *dest = ptr;

  for (size_t i = 0; i < num; i++) {
    dest[i] = value;
  }

  return ptr;
}