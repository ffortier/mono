#include "logic_gates.h"

#include <assert.h>
#include <slog/slog.h>
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

static void or_gate_logic(observable_t* observable, size_t pin_index,
                          void* user_data) {
  or_gate_t* gate = user_data;

  gate->z = gate->a || gate->b;
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

void print_nand_gate_t(void* component) {
  nand_gate_t* nand_gate = component;

  printf(NAND_GATE_FMT, NAND_GATE_VALUES(nand_gate));
}

void print_and_gate_t(void* component) {
  and_gate_t* and_gate = component;

  printf(AND_GATE_FMT, AND_GATE_VALUES(and_gate));
}

void print_or_gate_t(void* component) {
  or_gate_t* or_gate = component;

  printf(OR_GATE_FMT, NAND_GATE_VALUES(or_gate));
}

void print_xor_gate_t(void* component) {
  xor_gate_t* xor_gate = component;

  printf(XOR_GATE_FMT, XOR_GATE_VALUES(xor_gate));
}

void print_not_gate_t(void* component) {
  not_gate_t* not_gate = component;

  printf(NOT_GATE_FMT, NOT_GATE_VALUES(not_gate));
}

#define X(name, pin_count)                     \
  name##_t* make_##name() {                    \
    name##_t* name = malloc(sizeof(name##_t)); \
    assert(name && "Buy more RAM");            \
    memset(name, 0, sizeof(name##_t));         \
    register_##name(name);                     \
    init_##name(name);                         \
    return name;                               \
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
  void register_##name(name##_t* name) { register_component(name, name##_t); }
LOGIC_GATES
#undef X