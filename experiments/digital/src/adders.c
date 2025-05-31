#include "adders.h"

#include <assert.h>
#include <stddef.h>
#include <stdio.h>
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
  register_component(adder, half_adder);
  register_component(&adder->and_gate, and_gate);
  register_component(&adder->xor_gate, xor_gate);
}

size_t format_half_adder(char* str, size_t n, const half_adder_t* adder) {
  return snprintf(str, n, HALF_ADDER_FMT, HALF_ADDER_VALUES(adder));
}

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
  register_component(full_adder, full_adder);
  register_component(&full_adder->or_gate, or_gate);
  register_component(&full_adder->xor_gate, xor_gate);
  register_component(&full_adder->and_gate, and_gate);
  register_half_adder(&full_adder->half_adder);
}

size_t format_full_adder(char* str, size_t n, const full_adder_t* adder) {
  return snprintf(str, n, FULL_ADDER_FMT, FULL_ADDER_VALUES(adder));
}

#define ADDER_IMPLEMENTATION(bit_count)                                       \
  adder_##bit_count##_t* make_adder_##bit_count() {                           \
    adder_##bit_count##_t* adder_##bit_count =                                \
        calloc(1, sizeof(adder_##bit_count##_t));                             \
    assert(adder_##bit_count && "Buy more RAM");                              \
                                                                              \
    register_adder_##bit_count(adder_##bit_count);                            \
    init_adder_##bit_count(adder_##bit_count);                                \
                                                                              \
    return adder_##bit_count;                                                 \
  }                                                                           \
                                                                              \
  void init_adder_##bit_count(adder_##bit_count##_t* adder_##bit_count) {     \
    for (size_t i = 0; i < bit_count; i++) {                                  \
      init_full_adder(&adder_##bit_count->full_adders[i]);                    \
                                                                              \
      connect(SELECT(adder_##bit_count, a_inputs[i]),                         \
              SELECT(&adder_##bit_count->full_adders[i], a));                 \
      connect(SELECT(adder_##bit_count, b_inputs[i]),                         \
              SELECT(&adder_##bit_count->full_adders[i], b));                 \
      connect(SELECT(&adder_##bit_count->full_adders[i], sum),                \
              SELECT(adder_##bit_count, outputs[i]));                         \
                                                                              \
      if (i < bit_count - 1) {                                                \
        connect(SELECT(&adder_##bit_count->full_adders[i], carry),            \
                SELECT(&adder_##bit_count->full_adders[i + 1], c));           \
      }                                                                       \
    }                                                                         \
                                                                              \
    connect(SELECT(adder_##bit_count, cin),                                   \
            SELECT(&adder_##bit_count->full_adders[0], c));                   \
    connect(SELECT(&adder_##bit_count->full_adders[bit_count - 1], carry),    \
            SELECT(adder_##bit_count, cout));                                 \
  }                                                                           \
                                                                              \
  void register_adder_##bit_count(adder_##bit_count##_t* adder_##bit_count) { \
    register_component(adder_##bit_count, adder_##bit_count);                 \
                                                                              \
    for (size_t i = 0; i < bit_count; i++) {                                  \
      register_full_adder(&adder_##bit_count->full_adders[i]);                \
    }                                                                         \
  }                                                                           \
                                                                              \
  size_t format_adder_##bit_count(char* str, size_t n,                        \
                                  const adder_##bit_count##_t* adder) {       \
    return snprintf(str, n, ADDER_##bit_count##_FMT,                          \
                    ADDER_##bit_count##_VALUES(adder));                       \
  }

ADDER_IMPLEMENTATION(4)
ADDER_IMPLEMENTATION(8)
