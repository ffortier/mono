#pragma once

#include "nostd/types.h"

void *memset(void *ptr, int value, size_t num);

void heap_init(void);

void *kmalloc(size_t s);
void kfree(void *ptr);