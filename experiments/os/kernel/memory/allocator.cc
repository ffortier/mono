#include "allocator.hh"

allocator::allocator(heap* __heap, size_t small_obj_mem_size) {
  _heap = __heap;
  _small_obj_mem_size = small_obj_mem_size;

  auto node_count = small_obj_mem_size / _heap->block_size();

  if (node_count == 0) {
    _node_nexts = nullptr;
    _base = nullptr;
    _free_node = allocator::end_block;
  } else {
    _node_nexts = _heap->malloc<size_t>(node_count);
    _base = _heap->malloc<uint8_t>(node_count * _heap->block_size());

    for (auto i = 0; i < node_count - 1; i++) {
      _node_nexts[i] = _node_nexts[i + 1];
    }

    _node_nexts[node_count - 1] = allocator::end_block;
    _free_node = 0;
  }
}

allocator* allocator::kernel() {
  static allocator kernel_allocator(
      heap::kernel(), static_cast<size_t>(.1 * heap::kernel()->mem_size()));

  return &kernel_allocator;
}

allocator::~allocator() {
  _heap->free(_node_nexts);
  _heap->free(_base);
}