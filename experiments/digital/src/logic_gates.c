#include "logic_gates.h"

#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void nand_gate_logic(observable_t* observable, size_t pin_index,
                            void* user_data) {
  nand_gate_t* gate = user_data;

  gate->z = gate->a && gate->b ? 0 : 1;
}

static void and_gate_logic(observable_t* observable, size_t pin_index,
                           void* user_data) {
  and_gate_t* gate = user_data;

  gate->z = gate->a && gate->b;
}

static void and_gate_3_logic(observable_t* observable, size_t pin_index,
                             void* user_data) {
  and_gate_3_t* gate = user_data;

  gate->z = gate->a && gate->b && gate->c;
}

static void or_gate_logic(observable_t* observable, size_t pin_index,
                          void* user_data) {
  or_gate_t* gate = user_data;

  gate->z = gate->a || gate->b;
}

static void nor_gate_logic(observable_t* observable, size_t pin_index,
                           void* user_data) {
  nor_gate_t* gate = user_data;

  gate->z = gate->a || gate->b ? 0 : 1;
}

static void xor_gate_logic(observable_t* observable, size_t pin_index,
                           void* user_data) {
  xor_gate_t* gate = user_data;

  gate->z = gate->a ^ gate->b;
}

static void not_gate_logic(observable_t* observable, size_t pin_index,
                           void* user_data) {
  not_gate_t* gate = user_data;

  gate->z = gate->a ? 0 : 1;
}

size_t format_nand_gate(char* str, size_t n, const nand_gate_t* component) {
  return snprintf(str, n, NAND_GATE_FMT, NAND_GATE_VALUES(component));
}

size_t format_and_gate(char* str, size_t n, const and_gate_t* component) {
  return snprintf(str, n, AND_GATE_FMT, AND_GATE_VALUES(component));
}

size_t format_and_gate_3(char* str, size_t n, const and_gate_3_t* component) {
  return snprintf(str, n, AND_GATE_3_FMT, AND_GATE_3_VALUES(component));
}

size_t format_or_gate(char* str, size_t n, const or_gate_t* component) {
  return snprintf(str, n, OR_GATE_FMT, OR_GATE_VALUES(component));
}

size_t format_nor_gate(char* str, size_t n, const nor_gate_t* component) {
  return snprintf(str, n, NOR_GATE_FMT, NOR_GATE_VALUES(component));
}

size_t format_xor_gate(char* str, size_t n, const xor_gate_t* component) {
  return snprintf(str, n, XOR_GATE_FMT, XOR_GATE_VALUES(component));
}

size_t format_not_gate(char* str, size_t n, const not_gate_t* component) {
  return snprintf(str, n, NOT_GATE_FMT, NOT_GATE_VALUES(component));
}

#define X(name, pin_count)                        \
  name##_t* make_##name() {                       \
    name##_t* name = calloc(1, sizeof(name##_t)); \
    assert(name && "Buy more RAM");               \
    register_##name(name);                        \
    init_##name(name);                            \
    return name;                                  \
  }
LOGIC_GATES
#undef X

#define X(name, pin_count)                                          \
  void init_##name(name##_t* name) {                                \
    pin_callback_chain_t cb = {                                     \
        .cb = name##_logic,                                         \
        .user_data = name,                                          \
        .next = NULL,                                               \
    };                                                              \
    for (size_t i = 0; i < pin_count - 1; i++) {                    \
      append_callback_chain(&name->observable, &name->pins[i], cb); \
    }                                                               \
  }
LOGIC_GATES
#undef X

#define X(name, pin_count) \
  void register_##name(name##_t* name) { register_component(name, name); }
LOGIC_GATES
#undef X