#include "flipflops.h"

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

jk_flip_flop_t* make_jk_flip_flop() {
  jk_flip_flop_t* jk_flip_flop = calloc(1, sizeof(jk_flip_flop_t));

  assert(jk_flip_flop && "Buy more RAM");

  register_jk_flip_flop(jk_flip_flop);
  init_jk_flip_flop(jk_flip_flop);

  return jk_flip_flop;
}

void destroy_jk_flip_flop(jk_flip_flop_t* jk_flip_flop) {
  // TODO:
}

void init_jk_flip_flop(jk_flip_flop_t* jk_flip_flop) {
  connect(SELECT(jk_flip_flop, j), SELECT(&jk_flip_flop->and_gate_3s[0], b));
  connect(SELECT(jk_flip_flop, k), SELECT(&jk_flip_flop->and_gate_3s[1], b));

  connect(SELECT(jk_flip_flop, clk), SELECT(&jk_flip_flop->and_gate_3s[0], c));
  connect(SELECT(jk_flip_flop, clk), SELECT(&jk_flip_flop->and_gate_3s[1], a));
  connect(SELECT(jk_flip_flop, clk), SELECT(&jk_flip_flop->not_gate, a));

  connect(SELECT(&jk_flip_flop->and_gate_3s[0], z),
          SELECT(&jk_flip_flop->sr_latches[0], s));
  connect(SELECT(&jk_flip_flop->and_gate_3s[1], z),
          SELECT(&jk_flip_flop->sr_latches[0], r));

  connect(SELECT(&jk_flip_flop->not_gate, z),
          SELECT(&jk_flip_flop->and_gates[0], b));
  connect(SELECT(&jk_flip_flop->not_gate, z),
          SELECT(&jk_flip_flop->and_gates[1], a));
  connect(SELECT(&jk_flip_flop->sr_latches[0], q1),
          SELECT(&jk_flip_flop->and_gates[0], a));
  connect(SELECT(&jk_flip_flop->sr_latches[0], q),
          SELECT(&jk_flip_flop->and_gates[1], b));

  connect(SELECT(&jk_flip_flop->and_gates[0], z),
          SELECT(&jk_flip_flop->sr_latches[1], r));
  connect(SELECT(&jk_flip_flop->and_gates[1], z),
          SELECT(&jk_flip_flop->sr_latches[1], s));

  connect(SELECT(&jk_flip_flop->sr_latches[1], q), SELECT(jk_flip_flop, q));
  connect(SELECT(&jk_flip_flop->sr_latches[1], q1), SELECT(jk_flip_flop, q1));
  connect(SELECT(&jk_flip_flop->sr_latches[1], q),
          SELECT(&jk_flip_flop->and_gate_3s[1], c));
  connect(SELECT(&jk_flip_flop->sr_latches[1], q1),
          SELECT(&jk_flip_flop->and_gate_3s[0], a));

  init_sr_latch(&jk_flip_flop->sr_latches[0]);
  init_sr_latch(&jk_flip_flop->sr_latches[1]);
  init_and_gate_3(&jk_flip_flop->and_gate_3s[0]);
  init_and_gate_3(&jk_flip_flop->and_gate_3s[1]);
  init_and_gate(&jk_flip_flop->and_gates[0]);
  init_and_gate(&jk_flip_flop->and_gates[1]);
  init_not_gate(&jk_flip_flop->not_gate);
}

void register_jk_flip_flop(jk_flip_flop_t* jk_flip_flop) {
  register_sr_latch(&jk_flip_flop->sr_latches[0]);
  register_sr_latch(&jk_flip_flop->sr_latches[1]);
  register_and_gate_3(&jk_flip_flop->and_gate_3s[0]);
  register_and_gate_3(&jk_flip_flop->and_gate_3s[1]);
  register_and_gate(&jk_flip_flop->and_gates[0]);
  register_and_gate(&jk_flip_flop->and_gates[1]);
  register_not_gate(&jk_flip_flop->not_gate);
  register_component(jk_flip_flop, jk_flip_flop);
}

size_t format_jk_flip_flop(char* str, size_t n,
                           const jk_flip_flop_t* jk_flip_flop) {
  return snprintf(str, n, JK_FLIP_FLOP_FMT, JK_FLIP_FLOP_VALUES(jk_flip_flop));
}