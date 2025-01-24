#include "heap.hh"

heap* heap::kernel() {
  static heap kernel_heap{0x00007e00, 0x0100000, 100 * 1024 * 1024, 4096};

  return &kernel_heap;
}

heap::heap(uintptr_t table_addr, uintptr_t base_addr, size_t mem_size,
           size_t block_size)
    : _table_addr{reinterpret_cast<heap::block*>(table_addr)},
      _base_addr{reinterpret_cast<uint8_t*>(base_addr)},
      _mem_size{mem_size},
      _block_size{block_size} {
  _block_count = mem_size / block_size;

  memset(_table_addr, 0, _block_count * sizeof(heap::block));
}

void* heap::malloc(size_t s) {
  auto required_blocks =
      s % _block_size == 0 ? s / _block_size : s / _block_size + 1;

  size_t count = 0;

  for (auto i = 0; i < _block_count; i++) {
    if (_table_addr[i] == heap::block::FREE) {
      if (++count == required_blocks) {
        for (auto j = i - count + 1; j < i; j++) {
          _table_addr[j] = heap::block::NEXT;
        }

        _table_addr[i] = heap::block::END;

        return &_base_addr[(i - count + 1) * 4096];
      }

      continue;
    }
    count = 0;
  }

  return nullptr;
}

void heap::free(void* ptr) {
  if (!ptr) return;

  // TODO: Check range
  auto start = (reinterpret_cast<uint8_t*>(ptr) - _base_addr) / _block_size;

  while (_table_addr[start] != heap::block::END) {
    _table_addr[start++] = heap::block::FREE;
  }

  _table_addr[start] = heap::block::FREE;
}