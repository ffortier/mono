#include "kernel.hh"

#include "kernel/disk/disk.hh"
#include "kernel/idt/idt.hh"
#include "kernel/io/io.hh"
#include "kernel/memory/allocator.hh"
#include "kernel/memory/heap.hh"
#include "kernel/memory/paging.hh"
#include "kernel/term/term.hh"

extern "C" void kernel_main(void) {
  idt_init();

  paging_directory kernel_vmem(paging_directory::flags::IS_PRESENT |
                               paging_directory::flags::IS_WRITEABLE |
                               paging_directory::flags::ACCESS_FROM_ALL);

  kernel_vmem.load();

  paging_directory::enable();

  enable_interrupts();

  term::get().clear();
  term::get().set_color(2);

  term::get().write_chars("FRANCIS OS++\n\n");
  term::get().write_chars("$ ");

  auto d = allocator::kernel()->alloc<disk>();
  auto buf = heap::kernel()->malloc<uint16_t>(256);

  d->read_sector(0, 1, buf);

  while (true);
}