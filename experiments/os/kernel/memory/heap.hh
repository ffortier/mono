#pragma once

#include "kernel/nostd/nostd.hh"

class heap {
 public:
  enum class block : unsigned char {
    FREE,
    NEXT,
    END,
  };

 private:
  block* _table_addr;
  uint8_t* _base_addr;
  size_t _mem_size;
  size_t _block_size;
  size_t _block_count;

 public:
  static heap* kernel();

  heap(uintptr_t table_addr, uintptr_t base_addr, size_t mem_size,
       size_t block_size);

  heap(const heap&) = delete;
  heap(heap&&) = delete;

  heap& operator=(const heap&) = delete;
  heap& operator=(heap&&) = delete;

  void* malloc(size_t s);
  void free(void* ptr);

  inline size_t block_size() const { return _block_size; };
  inline size_t mem_size() const { return _mem_size; };
};