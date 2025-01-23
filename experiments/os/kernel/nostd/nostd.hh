#pragma once

#ifdef NOSTD
typedef unsigned long int size_t;
typedef unsigned char uint8_t;
typedef unsigned short int uint16_t;
typedef unsigned long int uint32_t;
typedef unsigned long long int uint64_t;
typedef signed char int8_t;
typedef signed short int int16_t;
typedef signed long int int32_t;
typedef signed long long int int64_t;
typedef uint32_t uintptr_t;
typedef int32_t intptr_t;

extern "C" {
void *memset(void *ptr, int value, size_t num);
}

#else
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>
#endif
