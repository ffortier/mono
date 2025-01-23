#include "kernel.hh"

#include "kernel/idt/idt.hh"
#include "kernel/io/io.hh"
#include "kernel/memory/allocator.hh"
#include "kernel/memory/heap.hh"
#include "kernel/term/term.hh"

extern "C" void kernel_main(void) {
  idt_init();
  enable_interrupts();
  // heap_init();

  console::get().clear();
  console::get().set_color(2);

  console::get().write_chars("FRANCIS OS++\n\n");
  console::get().write_chars("$ ");

  // auto test = kmalloc(10);
  // // test[0] = test_hello();
  // kfree(test);
}