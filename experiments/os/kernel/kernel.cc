#include "kernel.hh"

// #include "hello.h"
extern "C" {
#include "kernel/idt/idt.h"
#include "kernel/io/io.h"
#include "kernel/memory/memory.h"
}
#include "kernel/term/term.hh"

extern "C" void kernel_main(void) {
  idt_init();
  enable_interrupts();
  heap_init();

  console::get().clear();
  console::get().set_color(2);

  console::get().write_chars("FRANCIS OS++\n\n");
  console::get().write_chars("$ ");

  auto test = kmalloc(10);
  // test[0] = test_hello();
  kfree(test);
}