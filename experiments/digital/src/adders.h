#ifndef __ADDERS_H
#define __ADDERS_H

#include "logic_gates.h"
#include "observable.h"

#define HALF_ADDER_FMT \
  "half_adder_t { .a = %d, .b = %d, .sum = %d, .cout = %d }"

#define HALF_ADDER_VALUES(half_adder) \
  (half_adder)->a, (half_adder)->b, (half_adder)->sum, (half_adder)->carry

#define FULL_ADDER_FMT \
  "full_adder_t { .a = %d, .b = %d, .cin = %d, .sum = %d, .cout = %d }"

#define FULL_ADDER_VALUES(full_adder)                                   \
  (full_adder)->a, (full_adder)->b, (full_adder)->c, (full_adder)->sum, \
      (full_adder)->carry

typedef struct half_adder {
  observable_t observable;

  union {
    int pins[4];
    struct {
      int a;
      int b;
      int sum;
      int carry;
    };
  };

  xor_gate_t xor_gate;
  and_gate_t and_gate;
} half_adder_t;

COMPONENT_INTERFACE(half_adder);

typedef struct full_adder {
  observable_t observable;

  union {
    int pins[5];
    struct {
      int a;
      int b;
      int c;
      int sum;
      int carry;
    };
  };

  or_gate_t or_gate;
  xor_gate_t xor_gate;
  and_gate_t and_gate;
  half_adder_t half_adder;
} full_adder_t;

COMPONENT_INTERFACE(full_adder);

#define ADDER_INTERFACE(bit_count)       \
  typedef struct adder_##bit_count {     \
    observable_t observable;             \
    union {                              \
      int pins[bit_count * 3 + 2];       \
      struct {                           \
        int a_inputs[bit_count];         \
        int b_inputs[bit_count];         \
        int cin;                         \
        int cout;                        \
        int outputs[bit_count];          \
      };                                 \
    };                                   \
    full_adder_t full_adders[bit_count]; \
  } adder_##bit_count##_t;               \
  COMPONENT_INTERFACE(adder_##bit_count);

ADDER_INTERFACE(4)
ADDER_INTERFACE(8)

#define ADDER_8_FMT                                                       \
  "adder_8_t { .a = %d%d%d%d%d%d%d%d, .b = %d%d%d%d%d%d%d%d, .cin = %d, " \
  ".cout = %d, .sum = %d%d%d%d%d%d%d%d }"
#define ADDER_8_VALUES(adder_8)                                               \
  (adder_8)->a_inputs[7], (adder_8)->a_inputs[6], (adder_8)->a_inputs[5],     \
      (adder_8)->a_inputs[4], (adder_8)->a_inputs[3], (adder_8)->a_inputs[2], \
      (adder_8)->a_inputs[1], (adder_8)->a_inputs[0], (adder_8)->b_inputs[7], \
      (adder_8)->b_inputs[6], (adder_8)->b_inputs[5], (adder_8)->b_inputs[4], \
      (adder_8)->b_inputs[3], (adder_8)->b_inputs[2], (adder_8)->b_inputs[1], \
      (adder_8)->b_inputs[0], (adder_8)->cin, (adder_8)->cout,                \
      (adder_8)->outputs[7], (adder_8)->outputs[6], (adder_8)->outputs[5],    \
      (adder_8)->outputs[4], (adder_8)->outputs[3], (adder_8)->outputs[2],    \
      (adder_8)->outputs[1], (adder_8)->outputs[0]

#define ADDER_4_FMT                                       \
  "adder_4_t { .a = %d%d%d%d, .b = %d%d%d%d, .cin = %d, " \
  ".cout = %d, .sum = %d%d%d%d }"
#define ADDER_4_VALUES(adder_8)                                               \
  (adder_8)->a_inputs[3], (adder_8)->a_inputs[2], (adder_8)->a_inputs[1],     \
      (adder_8)->a_inputs[0], (adder_8)->b_inputs[3], (adder_8)->b_inputs[2], \
      (adder_8)->b_inputs[1], (adder_8)->b_inputs[0], (adder_8)->cin,         \
      (adder_8)->cout, (adder_8)->outputs[3], (adder_8)->outputs[2],          \
      (adder_8)->outputs[1], (adder_8)->outputs[0]

#endif