#ifndef __LOGIC_GATES_H
#define __LOGIC_GATES_H

#include "observable.h"

#define NAND_GATE_FMT "nand_gate { .a = %d, .b = %d, .z = %d }"
#define NAND_GATE_VALUES(gate) (gate)->a, (gate)->b, (gate)->z

#define AND_GATE_FMT "and_gate { .a = %d, .b = %d, .z = %d }"
#define AND_GATE_VALUES(gate) (gate)->a, (gate)->b, (gate)->z

#define OR_GATE_FMT "or_gate { .a = %d, .b = %d, .z = %d }"
#define OR_GATE_VALUES(gate) (gate)->a, (gate)->b, (gate)->z

#define XOR_GATE_FMT "xor_gate { .a = %d, .b = %d, .z = %d }"
#define XOR_GATE_VALUES(gate) (gate)->a, (gate)->b, (gate)->z

#define NOR_GATE_FMT "nor_gate { .a = %d, .b = %d, .z = %d }"
#define NOR_GATE_VALUES(gate) (gate)->a, (gate)->b, (gate)->z

#define NOT_GATE_FMT "not_gate { .a = %d, .z = %d }"
#define NOT_GATE_VALUES(gate) (gate)->a, (gate)->z

struct logic_gate_3 {
  struct observable observable;

  // pins
  union {
    int pins[3];
    struct {
      int a;
      int b;
      int z;
    };
  };
};

struct logic_gate_2 {
  struct observable observable;

  // pins
  union {
    int pins[2];
    struct {
      int a;
      int z;
    };
  };
};

#define LOGIC_GATES \
  X(nand_gate, 3)   \
  X(and_gate, 3)    \
  X(or_gate, 3)     \
  X(xor_gate, 3)    \
  X(nor_gate, 3)    \
  X(not_gate, 2)

#define X(name, pin_count) typedef struct logic_gate_##pin_count name##_t;
LOGIC_GATES
#undef X

#define X(name, pin_count) name##_t* make_##name(void);
LOGIC_GATES
#undef X
#define X(name, pin_count) void init_##name(name##_t* name);
LOGIC_GATES
#undef X
#define X(name, pin_count) void register_##name(name##_t* name);
LOGIC_GATES
#undef X

void print_nand_gate_t(void* component);
void print_and_gate_t(void* component);
void print_or_gate_t(void* component);
void print_xor_gate_t(void* component);
void print_not_gate_t(void* component);
void print_nor_gate_t(void* component);

#endif