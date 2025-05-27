#include "latches.h"

#include <assert.h>
#include <slog/slog.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void print_sr_latch_t(void* component) {
  sr_latch_t* sr_latch = component;
  printf(SR_LATCH_FMT, SR_LATCH_VALUES(sr_latch));
}

static void print_d_latch_t(void* component) {
  d_latch_t* d_latch = component;
  printf(D_LATCH_FMT, D_LATCH_VALUES(d_latch));
}

void init_sr_latch(struct sr_latch* latch) {
  connect(SELECT(latch, s), SELECT(&latch->g1, a));
  connect(SELECT(latch, r), SELECT(&latch->g2, b));
  connect(SELECT(&latch->g1, z), SELECT(latch, q));
  connect(SELECT(&latch->g2, z), SELECT(latch, q1));
  connect(SELECT(&latch->g1, z), SELECT(&latch->g2, a));
  connect(SELECT(&latch->g2, z), SELECT(&latch->g1, b));
  init_xor_gate(&latch->g1);
  init_xor_gate(&latch->g2);
}

void register_sr_latch(sr_latch_t* latch) {
  register_component(&latch->g1, xor_gate_t);
  register_component(&latch->g2, xor_gate_t);
  register_component(latch, sr_latch_t);
}

sr_latch_t* make_sr_latch() {
  sr_latch_t* sr_latch = malloc(sizeof(sr_latch_t));
  assert(sr_latch && "Buy more RAM");
  memset(sr_latch, 0, sizeof(sr_latch_t));

  register_sr_latch(sr_latch);
  init_sr_latch(sr_latch);

  return sr_latch;
}

void init_d_latch(d_latch_t* latch) {
  init_not_gate(&latch->n);
  init_nand_gate(&latch->g1);
  init_nand_gate(&latch->g2);
  init_sr_latch(&latch->sr_latch);
  connect(SELECT(latch, d), SELECT(&latch->g1, a));
  connect(SELECT(latch, d), SELECT(&latch->n, a));
  connect(SELECT(latch, e), SELECT(&latch->g1, b));
  connect(SELECT(latch, e), SELECT(&latch->g2, a));
  connect(SELECT(&latch->n, z), SELECT(&latch->g2, b));
  connect(SELECT(&latch->g1, z), SELECT(&latch->sr_latch, s));
  connect(SELECT(&latch->g2, z), SELECT(&latch->sr_latch, r));
  connect(SELECT(&latch->sr_latch, q), SELECT(latch, q));
  connect(SELECT(&latch->sr_latch, q1), SELECT(latch, q1));
}

void register_d_latch(d_latch_t* latch) {
  register_not_gate(&latch->n);
  register_nand_gate(&latch->g1);
  register_nand_gate(&latch->g2);
  register_sr_latch(&latch->sr_latch);
  register_component(latch, d_latch_t);
}

d_latch_t* make_d_latch() {
  d_latch_t* d_latch = malloc(sizeof(d_latch_t));
  assert(d_latch && "Buy more RAM");
  memset(d_latch, 0, sizeof(d_latch_t));

  register_d_latch(d_latch);
  init_d_latch(d_latch);

  return d_latch;
}
