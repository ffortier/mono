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

  template <class T>
  T* malloc(size_t s) {
    auto total_size = sizeof(T) * s;
    auto required_blocks = total_size % _block_size == 0
                               ? total_size / _block_size
                               : total_size / _block_size + 1;

    size_t count = 0;

    for (auto i = 0; i < _block_count; i++) {
      if (_table_addr[i] == heap::block::FREE) {
        if (++count == required_blocks) {
          for (auto j = i - count + 1; j < i; j++) {
            _table_addr[j] = heap::block::NEXT;
          }

          _table_addr[i] = heap::block::END;

          return reinterpret_cast<T*>(&_base_addr[(i - count + 1) * 4096]);
        }

        continue;
      }
      count = 0;
    }

    return nullptr;
  }

  template <class T>
  void free(T* ptr) {
    if (!ptr) return;

    // TODO: Check range
    auto start = (reinterpret_cast<uint8_t*>(ptr) - _base_addr) / _block_size;

    while (_table_addr[start] != heap::block::END) {
      _table_addr[start++] = heap::block::FREE;
    }

    _table_addr[start] = heap::block::FREE;
  }

  inline size_t block_size() const { return _block_size; };
  inline size_t mem_size() const { return _mem_size; };
};