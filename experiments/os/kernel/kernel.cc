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

  term::get().clear();
  term::get().set_color(2);

  term::get().write_chars("FRANCIS OS++\n\n");
  term::get().write_chars("$ ");

  char* test = reinterpret_cast<char*>(heap::kernel()->malloc(10));
  test[0] = 'y';
  heap::kernel()->free(test);
  // // test[0] = test_hello();
  // kfree(test);
}