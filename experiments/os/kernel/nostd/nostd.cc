#include "nostd.hh"

extern "C" void *memset(void *ptr, int value, size_t num) {
  auto dest = reinterpret_cast<unsigned char *>(ptr);

  for (auto i = 0; i < num; i++) {
    dest[i] = value;
  }

  return ptr;
}