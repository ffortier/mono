#include "clock.h"

#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

clk_t* make_clk(void) {
  clk_t* clock = calloc(1, sizeof(clk_t));

  assert(clock && "Buy more RAM");

  register_clk(clock);
  init_clk(clock);

  return clock;
}

size_t format_clk(char* str, size_t n, const clk_t* clk) {
  return snprintf(str, n, CLOCK_FMT, CLOCK_VALUES(clk));
}

void register_clk(clk_t* clock) { register_component(clock, clk); }

void init_clk(clk_t* clock) {
  // Nothing to do here
}

void clock_pulse(clk_t* clock) {
  clock->q = 1;
  apply();
  clock->q = 0;
  apply();
}
