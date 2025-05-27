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
  xor_gate_t g1;
  xor_gate_t g2;
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
  nand_gate_t g1;
  nand_gate_t g2;
  sr_latch_t sr_latch;
} d_latch_t;

#define SR_LATCH_FMT "sr_latch { .s = %d, .r = %d, .q = %d, .q1 = %d }"
#define SR_LATCH_VALUES(latch) (latch)->s, (latch)->r, (latch)->q, (latch)->q1
#define D_LATCH_FMT "d_latch { .d = %d, .e = %d, .q = %d, .q1 = %d }"
#define D_LATCH_VALUES(latch) (latch)->d, (latch)->e, (latch)->q, (latch)->q1

void init_sr_latch(struct sr_latch* latch);
void register_sr_latch(struct sr_latch* latch);

sr_latch_t* make_sr_latch();

void init_d_latch(struct d_latch* latch);
void register_d_latch(struct d_latch* latch);

d_latch_t* make_d_latch();

#endif