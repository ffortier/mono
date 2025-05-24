#include "clock.h"

#include <assert.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

clock_t* make_clock(void) {
  clock_t* clock = malloc(sizeof(clock_t));

  assert(clock && "Buy more RAM");
  memset(clock, 0, sizeof(clock_t));

  register_clock(clock);
  init_clock(clock);

  return clock;
}

void register_clock(clock_t* clock) { register_component(clock); }

void init_clock(clock_t* clock) {
  // Nothing to do here
}

void clock_pulse(clock_t* clock) {
  clock->clk = 1;
  apply();
  clock->clk = 0;
  apply();
}
