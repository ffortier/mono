#ifndef __CLOCK_H
#define __CLOCK_H

#include "observable.h"

typedef struct clock {
  observable_t observable;

  union {
    int pins[1];
    struct {
      int clk;
    };
  };
} clk_t;

clk_t* make_clock(void);

void register_clock(clk_t* clock);
void init_clock(clk_t* clock);

void clock_pulse(clk_t* clock);

#define CLOCK_FMT "clock { .clk = %d }"
#define CLOCK_VALUES(clock) clock->clk

#endif