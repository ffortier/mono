#include "memory.h"

typedef struct block_node {
  void* ptr;
  struct block_node* next;
} block_node;

#define BASE 0x01000000
#define BLOCK_SIZE 4096
#define HEAP_SIZE (1024 * 1024 * 100)
#define BLOCK_COUNT (HEAP_SIZE / BLOCK_SIZE)
#define HEAP_BASE \
  heap_align(BASE + sizeof(block_node) * BLOCK_COUNT, BLOCK_SIZE)

block_node* all_blocks;
block_node* free_list = 0;

static uintptr_t heap_align(uintptr_t p, size_t block_size) {
  int res = p % block_size;

  if (res == 0) {
    return res;
  }

  return res + (block_size - res);
}

static block_node* heap_create(block_node* all_blocks, size_t block_count,
                               size_t block_size, uintptr_t base) {
  for (int i = 0; i < block_count - 1; i++) {
    all_blocks[i].ptr = (void*)base;
    all_blocks[i].next = &all_blocks[i + 1];
    base += block_size;
  }

  return &all_blocks[0];
}

void heap_init(void) {
  all_blocks = (block_node*)BASE;

  free_list = heap_create(all_blocks, BLOCK_COUNT, BLOCK_SIZE, HEAP_BASE);
}

void* kmalloc(size_t s) {
  if (!free_list) {
    while (true) { /* panic */
    }
  }

  block_node* node = free_list;
  free_list = node->next;
  node->next = NULL;
  return node->ptr;
}

void kfree(void* ptr) {
  if (!ptr) return;
  uintptr_t ptr_value = (uintptr_t)ptr;
  int index = (ptr_value - HEAP_BASE) / BLOCK_SIZE;

  if (index >= BLOCK_COUNT || all_blocks[index].next) {
    while (true) { /* panic */
    }
  }

  all_blocks[index].next = free_list;
  free_list = &all_blocks[index];
}