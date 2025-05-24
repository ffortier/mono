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
} clock_t;

clock_t* make_clock(void);

void register_clock(clock_t* clock);
void init_clock(clock_t* clock);

void clock_pulse(clock_t* clock);

#endif