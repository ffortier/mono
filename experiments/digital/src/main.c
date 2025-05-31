#include <assert.h>
#include <slog/slog.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "clock.h"
#include "latches.h"
#include "logic_gates.h"
#include "observable.h"

int main(void) {
  slog_init("digital", SLOG_FLAGS_ALL - SLOG_TRACE, 0);

  clk_t* clock = make_clk();
  d_latch_t* d_latch = make_d_latch();

  connect(SELECT(clock, clk), SELECT(d_latch, e));

  clock_pulse(clock);
  printf(D_LATCH_FMT "\n", D_LATCH_VALUES(d_latch));

  d_latch->d = 1;

  clock->clk = 1;
  apply();
  printf(D_LATCH_FMT "\n", D_LATCH_VALUES(d_latch));
  clock->clk = 0;
  apply();

  // clock_pulse(clock);
  printf(D_LATCH_FMT "\n", D_LATCH_VALUES(d_latch));

  d_latch->d = 0;

  clock_pulse(clock);
  printf(D_LATCH_FMT "\n", D_LATCH_VALUES(d_latch));

  return 0;
}