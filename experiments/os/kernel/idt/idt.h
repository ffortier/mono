#pragma once

#include "nostd/types.h"

#define IDT_COUNT 512

typedef struct {
  uint16_t offset_1;
  uint16_t selector;
  uint8_t zero;
  uint8_t type_attr;
  uint16_t offset_2;
} __attribute__((packed)) idt_desc;

typedef struct {
  uint16_t limit;
  idt_desc* base;
} __attribute__((packed)) idtr_desc;

void idt_init(void);
void idt_set(size_t interrupt_number, void* callback);

void enable_interrupts(void);
void disable_interrupts(void);