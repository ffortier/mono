#include "adders.h"

#include <assert.h>
#include <stddef.h>
#include <stdlib.h>

#include "observable.h"

half_adder_t* make_half_adder() {
  half_adder_t* adder = calloc(1, sizeof(half_adder_t));

  assert(adder && "Buy more RAM");

  register_half_adder(adder);
  init_half_adder(adder);

  return adder;
}

void init_half_adder(half_adder_t* adder) {
  init_and_gate(&adder->and_gate);
  init_xor_gate(&adder->xor_gate);

  connect(SELECT(adder, a), SELECT(&adder->xor_gate, a));
  connect(SELECT(adder, a), SELECT(&adder->and_gate, b));
  connect(SELECT(adder, b), SELECT(&adder->xor_gate, b));
  connect(SELECT(adder, b), SELECT(&adder->and_gate, a));
  connect(SELECT(&adder->and_gate, z), SELECT(adder, carry));
  connect(SELECT(&adder->xor_gate, z), SELECT(adder, sum));
}

void register_half_adder(half_adder_t* adder) {
  register_component(adder, half_adder_t);
  register_component(&adder->and_gate, and_gate_t);
  register_component(&adder->xor_gate, xor_gate_t);
}

void print_half_adder_t(void* adder) {}

full_adder_t* make_full_adder() {
  full_adder_t* full_adder = calloc(1, sizeof(full_adder_t));

  assert(full_adder && "Buy more RAM");

  register_full_adder(full_adder);
  init_full_adder(full_adder);

  return full_adder;
}

void init_full_adder(full_adder_t* full_adder) {
  init_or_gate(&full_adder->or_gate);
  init_xor_gate(&full_adder->xor_gate);
  init_and_gate(&full_adder->and_gate);
  init_half_adder(&full_adder->half_adder);

  connect(SELECT(full_adder, a), SELECT(&full_adder->xor_gate, a));
  connect(SELECT(full_adder, a), SELECT(&full_adder->and_gate, a));
  connect(SELECT(full_adder, b), SELECT(&full_adder->xor_gate, b));
  connect(SELECT(full_adder, b), SELECT(&full_adder->and_gate, b));
  connect(SELECT(full_adder, c), SELECT(&full_adder->half_adder, b));
  connect(SELECT(&full_adder->xor_gate, z), SELECT(&full_adder->half_adder, a));
  connect(SELECT(&full_adder->and_gate, z), SELECT(&full_adder->or_gate, b));
  connect(SELECT(&full_adder->half_adder, carry),
          SELECT(&full_adder->or_gate, a));
  connect(SELECT(&full_adder->half_adder, sum), SELECT(full_adder, sum));
  connect(SELECT(&full_adder->or_gate, z), SELECT(full_adder, carry));
}

void register_full_adder(full_adder_t* full_adder) {
  register_component(full_adder, full_adder_t);
  register_component(&full_adder->or_gate, or_gate_t);
  register_component(&full_adder->xor_gate, xor_gate_t);
  register_component(&full_adder->and_gate, and_gate_t);
  register_half_adder(&full_adder->half_adder);
}

void print_full_adder_t(void* adder) {}

adder_8_t* make_adder_8() {
  adder_8_t* adder_8 = calloc(1, sizeof(adder_8_t));

  assert(adder_8 && "Buy more RAM");

  register_adder_8(adder_8);
  init_adder_8(adder_8);

  return adder_8;
}

void init_adder_8(adder_8_t* adder_8) {
  for (size_t i = 0; i < 8; i++) {
    init_full_adder(&adder_8->full_adders[i]);

    connect(SELECT(adder_8, a_inputs[i]), SELECT(&adder_8->full_adders[i], a));
    connect(SELECT(adder_8, b_inputs[i]), SELECT(&adder_8->full_adders[i], b));
    connect(SELECT(&adder_8->full_adders[i], sum), SELECT(adder_8, outputs[i]));

    if (i < 7) {
      connect(SELECT(&adder_8->full_adders[i], carry),
              SELECT(&adder_8->full_adders[i + 1], c));
    }
  }

  connect(SELECT(adder_8, cin), SELECT(&adder_8->full_adders[0], c));
  connect(SELECT(&adder_8->full_adders[7], carry), SELECT(adder_8, cout));
}

void register_adder_8(adder_8_t* adder_8) {
  register_component(adder_8, adder_8_t);

  for (size_t i = 0; i < 8; i++) {
    register_full_adder(&adder_8->full_adders[i]);
  }
}

void print_adder_8_t(void* adder) {}
