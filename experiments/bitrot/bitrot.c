#include <stdint.h>

#include "map.h"

extern void update_screen(char* map_data);
extern void screen_move_up(void);
extern void screen_move_down(void);
extern void screen_move_left(void);
extern void screen_move_right(void);

#if defined(__SIM6502__)
#include <sim65.h>
#include <stdio.h>
#include <string.h>

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
  MEASURE_CLOCKCYCLE(update_screen(map_data));
  MEASURE_CLOCKCYCLE(screen_move_up());
  MEASURE_CLOCKCYCLE(screen_move_down());
  MEASURE_CLOCKCYCLE(screen_move_left());
  MEASURE_CLOCKCYCLE(screen_move_right());

  return 0;
}
#elif defined(__C64__)
#include <c64.h>
#include <cbm.h>
#include <conio.h>
#include <peekpoke.h>

int main(void) {
  POKE(53272, 21);  // Enable uppercase + graphics mode

  clrscr();

  // while (1) {
  waitvsync();
  update_screen(map_data);
  screen_move_left();
  // }
}
#endif