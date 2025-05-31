#include "latches.h"

#include <assert.h>
#include <slog/slog.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

size_t format_sr_latch(char* str, size_t n, const sr_latch_t* component) {
  return snprintf(str, n, SR_LATCH_FMT, SR_LATCH_VALUES(component));
}

void init_sr_latch(struct sr_latch* latch) {
  connect(SELECT(latch, s), SELECT(&latch->g1, a));
  connect(SELECT(latch, r), SELECT(&latch->g2, b));
  connect(SELECT(&latch->g1, z), SELECT(latch, q1));
  connect(SELECT(&latch->g2, z), SELECT(latch, q));
  connect(SELECT(&latch->g1, z), SELECT(&latch->g2, a));
  connect(SELECT(&latch->g2, z), SELECT(&latch->g1, b));
  init_nor_gate(&latch->g1);
  init_nor_gate(&latch->g2);
}

void register_sr_latch(sr_latch_t* latch) {
  register_component(&latch->g1, nor_gate);
  register_component(&latch->g2, nor_gate);
  register_component(latch, sr_latch);
}

sr_latch_t* make_sr_latch() {
  sr_latch_t* sr_latch = calloc(1, sizeof(sr_latch_t));
  assert(sr_latch && "Buy more RAM");

  register_sr_latch(sr_latch);
  init_sr_latch(sr_latch);

  return sr_latch;
}

void init_d_latch(d_latch_t* latch) {
  init_not_gate(&latch->n);
  init_and_gate(&latch->g1);
  init_and_gate(&latch->g2);
  init_sr_latch(&latch->sr_latch);
  connect(SELECT(latch, d), SELECT(&latch->g2, b));
  connect(SELECT(latch, d), SELECT(&latch->n, a));
  connect(SELECT(latch, e), SELECT(&latch->g1, b));
  connect(SELECT(latch, e), SELECT(&latch->g2, a));
  connect(SELECT(&latch->n, z), SELECT(&latch->g1, a));
  connect(SELECT(&latch->g1, z), SELECT(&latch->sr_latch, r));
  connect(SELECT(&latch->g2, z), SELECT(&latch->sr_latch, s));
  connect(SELECT(&latch->sr_latch, q), SELECT(latch, q));
  connect(SELECT(&latch->sr_latch, q1), SELECT(latch, q1));
}

void register_d_latch(d_latch_t* latch) {
  register_not_gate(&latch->n);
  register_and_gate(&latch->g1);
  register_and_gate(&latch->g2);
  register_sr_latch(&latch->sr_latch);
  register_component(latch, d_latch);
}

d_latch_t* make_d_latch() {
  d_latch_t* d_latch = calloc(1, sizeof(d_latch_t));
  assert(d_latch && "Buy more RAM");

  register_d_latch(d_latch);
  init_d_latch(d_latch);

  return d_latch;
}

size_t format_d_latch(char* str, size_t n, const d_latch_t* component) {
  return snprintf(str, n, D_LATCH_FMT, D_LATCH_VALUES(component));
}

void init_jk_flip_flop(jk_flip_flop_t* jk_flip_flop) {
  init_and_gate_3(&jk_flip_flop->g1);
  init_and_gate_3(&jk_flip_flop->g2);
  init_sr_latch(&jk_flip_flop->sr_latch);

  connect(SELECT(jk_flip_flop, k), SELECT(&jk_flip_flop->g1, a));
  connect(SELECT(jk_flip_flop, j), SELECT(&jk_flip_flop->g2, c));
  connect(SELECT(jk_flip_flop, clk), SELECT(&jk_flip_flop->g1, c));
  connect(SELECT(jk_flip_flop, clk), SELECT(&jk_flip_flop->g2, a));
  connect(SELECT(&jk_flip_flop->g1, z), SELECT(&jk_flip_flop->sr_latch, r));
  connect(SELECT(&jk_flip_flop->g2, z), SELECT(&jk_flip_flop->sr_latch, s));
  connect(SELECT(&jk_flip_flop->sr_latch, q), SELECT(jk_flip_flop, q));
  connect(SELECT(&jk_flip_flop->sr_latch, q), SELECT(&jk_flip_flop->g1, b));
  connect(SELECT(&jk_flip_flop->sr_latch, q1), SELECT(jk_flip_flop, q1));
  connect(SELECT(&jk_flip_flop->sr_latch, q1), SELECT(&jk_flip_flop->g2, b));
}

void register_jk_flip_flop(jk_flip_flop_t* jk_flip_flop) {
  register_and_gate_3(&jk_flip_flop->g1);
  register_and_gate_3(&jk_flip_flop->g2);
  register_sr_latch(&jk_flip_flop->sr_latch);
  register_component(jk_flip_flop, jk_flip_flop);
}

jk_flip_flop_t* make_jk_flip_flop() {
  jk_flip_flop_t* jk_flip_flop = calloc(1, sizeof(jk_flip_flop_t));
  assert(jk_flip_flop && "Buy more RAM");

  register_jk_flip_flop(jk_flip_flop);
  init_jk_flip_flop(jk_flip_flop);

  return jk_flip_flop;
}

size_t format_jk_flip_flop(char* str, size_t n,
                           const jk_flip_flop_t* component) {
  return snprintf(str, n, JK_FLIP_FLOP_FMT, JK_FLIP_FLOP_VALUES(component));
}
