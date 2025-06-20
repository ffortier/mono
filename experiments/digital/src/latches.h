#ifndef __LATCHES_H
#define __LATCHES_H

#include "logic_gates.h"
#include "observable.h"

typedef struct sr_latch {
  struct observable observable;

  // pins
  union {
    int pins[4];
    struct {
      int s;
      int r;
      int q;
      int q1;
    };
  };

  // nested components
  nor_gate_t g1;
  nor_gate_t g2;
} sr_latch_t;

typedef struct d_latch {
  struct observable observable;

  // pins
  union {
    int pins[4];
    struct {
      int d;
      int e;
      int q;
      int q1;
    };
  };

  // nested components
  not_gate_t n;
  and_gate_t g1;
  and_gate_t g2;
  sr_latch_t sr_latch;
} d_latch_t;

#define SR_LATCH_FMT "sr_latch { .s = %d, .r = %d, .q = %d, .q1 = %d }"
#define SR_LATCH_VALUES(latch) (latch)->s, (latch)->r, (latch)->q, (latch)->q1
#define D_LATCH_FMT "d_latch { .d = %d, .e = %d, .q = %d, .q1 = %d }"
#define D_LATCH_VALUES(latch) (latch)->d, (latch)->e, (latch)->q, (latch)->q1

COMPONENT_INTERFACE(sr_latch);
COMPONENT_INTERFACE(d_latch);

#endif