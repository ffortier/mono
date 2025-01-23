#pragma once

#include "kernel/nostd/nostd.hh"

class kernel_allocator {
 public:
  kernel_allocator(const kernel_allocator &) = delete;
  kernel_allocator(kernel_allocator &&) = delete;

  kernel_allocator &operator=(const kernel_allocator &) = delete;
  kernel_allocator &operator=(kernel_allocator &&) = delete;

  template <class T>
  T *alloc() {
    return nullptr;
  }
};
