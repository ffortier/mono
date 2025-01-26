#pragma once

#ifdef NOSTD
typedef unsigned int size_t;
typedef unsigned char uint8_t;
typedef unsigned short int uint16_t;
typedef unsigned long int uint32_t;
typedef unsigned long long int uint64_t;
typedef signed char int8_t;
typedef signed short int int16_t;
typedef signed long int int32_t;
typedef signed long long int int64_t;
typedef unsigned int uintptr_t;

extern "C" {
void *memset(void *ptr, int value, size_t num);
__extension__ typedef int __guard __attribute__((mode(__DI__)));
int __cxa_guard_acquire(__guard *);
void __cxa_guard_release(__guard *);
void __cxa_guard_abort(__guard *);
}

inline void *operator new(size_t, void *p) noexcept { return p; }
inline void *operator new[](size_t, void *p) noexcept { return p; }
inline void operator delete(void *, void *) noexcept {};
inline void operator delete[](void *, void *) noexcept {};

#else
#include <cstddef>
#include <cstdint>
#include <cstring>
#endif

void panic(int err, const char *msg);
