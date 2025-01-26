#include "heap.hh"

heap* heap::kernel() {
  static heap kernel_heap{0x00007e00, 0x01000000, 100 * 1024 * 1024, 4096};

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
