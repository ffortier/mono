#ifndef __CLOCK_H
#define __CLOCK_H

#include "observable.h"

typedef struct clk {
  observable_t observable;

  union {
    int pins[1];
    struct {
      int q;
    };
  };
} clk_t;

COMPONENT_INTERFACE(clk);

void clock_pulse(clk_t* clock);

#define CLOCK_FMT "clock { .q = %d }"
#define CLOCK_VALUES(clock) clock->q

#endif