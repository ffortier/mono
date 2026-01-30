#include <sim65.h>
#include <stdio.h>
#include <string.h>

#include "screen.h"

static uint32_t counter_values[2];

#define MEASURE_CLOCKCYCLE(fn)                                               \
  do {                                                                       \
    peripherals.counter.latch = 0;                                           \
    peripherals.counter.select = COUNTER_SELECT_CLOCKCYCLE_COUNTER;          \
    memcpy(&counter_values[0], (const void*)&peripherals.counter.value32[0], \
           sizeof(counter_values));                                          \
    fn;                                                                      \
    peripherals.counter.latch = 0;                                           \
    peripherals.counter.select = COUNTER_SELECT_CLOCKCYCLE_COUNTER;          \
    printf(#fn "\t0x%08lx%08lx\t0x%08lx%08lx\n", counter_values[1],          \
           counter_values[0], peripherals.counter.value32[1],                \
           peripherals.counter.value32[0]);                                  \
  } while (0)

int main(void) {
  MEASURE_CLOCKCYCLE(screen_move_up());
  MEASURE_CLOCKCYCLE(screen_move_down());
  MEASURE_CLOCKCYCLE(screen_move_left());
  MEASURE_CLOCKCYCLE(screen_move_right());

  return 0;
}