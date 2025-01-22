#include "idt.h"

#include "kernel/io/io.h"
#include "kernel/memory/memory.h"
// #include "kernel/term/term.h"

#define KERNEL_CODE_SELECTOR 0x08
#define KERNEL_DATA_SELECTOR 0x10

idt_desc idt_descs[IDT_COUNT];
idtr_desc idtr_descriptor;

extern void idt_load(idtr_desc* ptr);
extern void no_interrupt(void);
extern void int_21(void);

void idt_init(void) {
  memset(idt_descs, 0, sizeof(idt_descs));
  idtr_descriptor.limit = sizeof(idt_descs) - 1;
  idtr_descriptor.base = &idt_descs[0];

  for (int i = 0; i < IDT_COUNT; i++) {
    idt_set(i, no_interrupt);
  }

  idt_set(0x21, int_21);

  idt_load(&idtr_descriptor);
}

void idt_set(size_t interrupt_number, void* callback) {
  idt_desc* desc = &idt_descs[interrupt_number];
  desc->offset_1 = (uintptr_t)callback & 0xffff;
  desc->selector = KERNEL_CODE_SELECTOR;
  desc->type_attr = 0xee;
  desc->offset_2 = ((uintptr_t)callback >> 16) & 0xffff;
}

void no_interrupt_handler(void) { outb(0x20, 0x20); }

void int21_handler(void) {
  // term_write_chars(&global_term_state, "K\n");
  outb(0x20, 0x20);
}