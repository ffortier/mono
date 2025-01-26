#include "nostd.hh"
#if NOSTD
extern "C" void *memset(void *ptr, int value, size_t num) {
  auto dest = reinterpret_cast<unsigned char *>(ptr);

  for (auto i = 0; i < num; i++) {
    dest[i] = value;
  }

  return ptr;
}

namespace __cxxabiv1 {
// https://wiki.osdev.org/C%2B%2B
extern "C" int __cxa_guard_acquire(__guard *g) { return !*(char *)(g); }

extern "C" void __cxa_guard_release(__guard *g) { *(char *)g = 1; }

extern "C" void __cxa_guard_abort(__guard *) {}

extern "C" void __cxa_atexit() {}
}  // namespace __cxxabiv1
#endif

void panic(int err, const char *msg) {
  while (true) {
  }
}