#ifndef __FLIPFLOPS_H
#define __FLIPFLOPS_H

#include "latches.h"
#include "observable.h"

#define JK_FLIP_FLOP_FMT \
  "jk_flip_flop_t { .j = %d, .k = %d, .clk = %d, .q = %d, .q1 = %d }"
#define JK_FLIP_FLOP_VALUES(jk) (jk)->j, (jk)->k, (jk)->clk, (jk)->q, (jk)->q1

typedef struct jk_flip_flop {
  observable_t observable;

  union {
    int pins[5];
    struct {
      int j;
      int k;
      int clk;
      int q;
      int q1;
    };
  };

  sr_latch_t sr_latches[2];
  and_gate_3_t and_gate_3s[2];
  and_gate_t and_gates[2];
  not_gate_t not_gate;
} jk_flip_flop_t;

COMPONENT_INTERFACE(jk_flip_flop);

#endif