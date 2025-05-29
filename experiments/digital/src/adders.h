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

half_adder_t* make_half_adder();
void init_half_adder(half_adder_t*);
void register_half_adder(half_adder_t*);
void print_half_adder_t(void* adder);

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

full_adder_t* make_full_adder();
void init_full_adder(full_adder_t*);
void register_full_adder(full_adder_t*);
void print_full_adder_t(void* adder);

typedef struct adder_8 {
  observable_t observable;

  union {
    int pins[26];
    struct {
      int a_inputs[8];
      int b_inputs[8];
      int cin;
      int outputs[8];
      int cout;
    };
  };

  full_adder_t full_adders[8];
} adder_8_t;

adder_8_t* make_adder_8();
void init_adder_8(adder_8_t*);
void register_adder_8(adder_8_t*);
void print_adder_8_t(void* adder);

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

#endif