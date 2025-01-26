#pragma once

#include "kernel/memory/heap.hh"
#include "kernel/nostd/nostd.hh"

class allocator {
 private:
  const size_t end_block = ~static_cast<size_t>(0);

  heap *_heap;
  size_t *_node_nexts;
  size_t _free_node;
  size_t _small_obj_mem_size;
  uint8_t *_base;

 public:
  static allocator *kernel();

  allocator(heap *, size_t small_obj_mem_size);

  ~allocator();

  allocator(const allocator &) = delete;
  allocator(allocator &&) = delete;

  allocator &operator=(const allocator &) = delete;
  allocator &operator=(allocator &&) = delete;

  template <class T, class... Args>
  T *alloc(Args... args) {
    auto s = sizeof(T);
    void *mem = 0;

    if (s < _heap->block_size() && _free_node != end_block) {
      auto index = _free_node;

      _free_node = _node_nexts[index];

      mem = _base + index * _heap->block_size();
    } else {
      mem = _heap->malloc<T>(1);
    }

    return new (mem) T(args...);
  }

  template <class T>
  void dealloc(T *ptr) {
    ptr->~T();

    auto ptr_value = reinterpret_cast<uintptr_t>(ptr);
    auto base_value = reinterpret_cast<uintptr_t>(_base);

    if (ptr_value >= base_value &&
        ptr_value < base_value + _small_obj_mem_size) {
      auto index = (ptr_value - base_value) / _heap->block_size();

      _node_nexts[index] = _free_node;
      _free_node = index;
    } else {
      _heap->free(ptr);
    }
  }
};
