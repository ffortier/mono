#include "paging.hh"

#include "heap.hh"

#define ENTRIES_PER_TABLE 1024
#define TABLES_PER_DIRECTORY 1024
#define PAGE_SIZE 4096

extern "C" void paging_load_directory(uintptr_t*);
extern "C" void paging_enable(void);

paging_directory::paging_directory(uintptr_t flags) {
  _tables = heap::kernel()->malloc<uintptr_t>(TABLES_PER_DIRECTORY);

  uintptr_t offset = 0;

  for (int i = 0; i < TABLES_PER_DIRECTORY; i++) {
    auto entry = heap::kernel()->malloc<uintptr_t>(ENTRIES_PER_TABLE);

    for (int b = 0; b < ENTRIES_PER_TABLE; b++) {
      entry[b] = (offset + (b * PAGE_SIZE)) | flags;
    }
    offset += (ENTRIES_PER_TABLE * PAGE_SIZE);
    _tables[i] = reinterpret_cast<uintptr_t>(entry) | flags;
  }
}

paging_directory::~paging_directory() {
  for (int i = 0; i < TABLES_PER_DIRECTORY; i++) {
    heap::kernel()->free(reinterpret_cast<uintptr_t*>(
        _tables[i] & (~static_cast<uintptr_t>(0xfff))));
  }
  heap::kernel()->free(_tables);
}

void paging_directory::set(uintptr_t virt, uintptr_t physical,
                           uintptr_t flags) {
  if (virt % PAGE_SIZE != 0) panic(69, "unaligned virtual address");

  auto dir_index = virt / (TABLES_PER_DIRECTORY * PAGE_SIZE);
  auto table_index = virt % (TABLES_PER_DIRECTORY * PAGE_SIZE) / PAGE_SIZE;

  auto entry = _tables[dir_index];
  auto table =
      reinterpret_cast<uintptr_t*>(entry & (~static_cast<uintptr_t>(0xfff)));

  table[table_index] = physical | flags;
}

void paging_directory::enable() { paging_enable(); }
void paging_directory::load() { paging_load_directory(_tables); }
