#include "clock.h"

#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

clk_t* make_clock(void) {
  clk_t* clock = malloc(sizeof(clk_t));

  assert(clock && "Buy more RAM");
  memset(clock, 0, sizeof(clk_t));

  register_clock(clock);
  init_clock(clock);

  return clock;
}

static void print_clk_t(void* component) {
  clk_t* clock = component;
  printf(CLOCK_FMT, CLOCK_VALUES(clock));
}

void register_clock(clk_t* clock) { register_component(clock, clk_t); }

void init_clock(clk_t* clock) {
  // Nothing to do here
}

void clock_pulse(clk_t* clock) {
  clock->clk = 1;
  apply();
  clock->clk = 0;
  apply();
}
