#include <stdint.h>
#if defined(__clang__)
// ignore for clangd
#define __fastcall__
#endif

#include <stddef.h>
#if defined(__C64__)
#include <cbm.h>
#include <peekpoke.h>
#elif defined(__SIM6502__)
#include <sim65.h>
#include <stdio.h>
#endif

#include <string.h>

char counts[1000] = {0};

#if defined(__C64__)
char* mem = (char*)0x0400;
#elif defined(__SIM6502__)
char mem[1000];  // for sim65
#endif

#define SPACE 32
#define CIRCLE 81

// Using zp outside of the ZEROPAGE segment for cc65 because I'm too lazy to
// override the config
#define x (*(unsigned char*)0x20)
#define y (*(unsigned char*)0x21)
#define current_count (*(char**)0x22)
#define current_mem (*(char**)0x24)

void update_cells(void) {
  memset(&counts[0], 0, 1000);
  current_mem = mem;
  current_count = &counts[0];

  // x = 0, y = 0
  if (*current_mem == CIRCLE) {
    *(current_count + 1) += 1;
    *(current_count + 40) += 1;
    *(current_count + 41) += 1;
  }

  current_mem++;
  current_count++;

  // bluk of the first row
  for (x = 1; x < 39; x++) {
    if (*current_mem == CIRCLE) {
      *(current_count - 1) += 1;
      *(current_count + 1) += 1;
      *(current_count + 40) += 1;
      *(current_count + 39) += 1;
      *(current_count + 41) += 1;
    }
    current_mem++;
    current_count++;
  }

  // x = 39, y = 0
  if (*current_mem == CIRCLE) {
    *(current_count - 1) += 1;
    *(current_count + 40) += 1;
    *(current_count + 39) += 1;
  }

  current_mem++;
  current_count++;

  // every row in between
  for (y = 1; y < 24; y++) {
    for (x = 1; x < 39; x++) {
      if (*current_mem == CIRCLE) {
        *(current_count - 1) += 1;
        *(current_count + 1) += 1;
        *(current_count - 40) += 1;
        *(current_count + 40) += 1;
        *(current_count - 41) += 1;
        *(current_count - 39) += 1;
        *(current_count + 39) += 1;
        *(current_count + 41) += 1;
      }
      current_mem++;
      current_count++;
    }
    current_mem += 2;
    current_count += 2;
  }

  // x = 0, y = 24
  if (*current_mem == CIRCLE) {
    *(current_count + 1) += 1;
    *(current_count - 40) += 1;
    *(current_count - 39) += 1;
  }

  current_mem++;
  current_count++;

  // bluk of the last row
  for (x = 1; x < 39; x++) {
    if (*current_mem == CIRCLE) {
      *(current_count - 1) += 1;
      *(current_count + 1) += 1;
      *(current_count - 40) += 1;
      *(current_count - 39) += 1;
      *(current_count - 41) += 1;
    }
    current_mem++;
    current_count++;
  }

  // x = 39, y = 24
  if (*current_mem == CIRCLE) {
    *(current_count - 1) += 1;
    *(current_count - 40) += 1;
    *(current_count - 41) += 1;
  }

  current_mem = mem;
  current_count = &counts[0];

#define X                                                                   \
  for (x = 0; x < 250; x++, current_mem++, current_count++) {               \
    if (*current_mem == CIRCLE) {                                           \
      if (*current_count != 2 && *current_count != 3) *current_mem = SPACE; \
    } else {                                                                \
      if (*current_count == 3) *current_mem = CIRCLE;                       \
    }                                                                       \
  }

  X X X X;

#undef X
}

char* glider_gun[] = {
    "                        #",
    "                      # #",
    "            ##      ##            ##",
    "           #   #    ##            ##",
    "##        #     #   ##",
    "##        #   # ##    # #",
    "          #     #       #",
    "           #   #",
    "            ##",
};

void init_mem(char** pattern, size_t len) {
  int i;
  // unsigned char _x, _y;
  char* input_row;
  char* output_row;

  for (i = 0; i < 1000; i++) {
    mem[i] = SPACE;
  }

  x = 0;
  y = 0;

  for (i = 0; i < len; i++) {
    input_row = pattern[i];
    output_row = &mem[y * 40 + x];

    while (*input_row) {
      switch (*input_row) {
        case ' ':
          *output_row = SPACE;
          break;
        case '#':
          *output_row = CIRCLE;
          break;
      }

      input_row++;
      output_row++;
    }

    y++;
  }
}

#if defined(__C64__)
int main(void) {
  POKE(53272, 21);  // Enable uppercase + graphics mode

  init_mem(&glider_gun[0], sizeof(glider_gun) / sizeof(glider_gun[0]));

  while (1) {
    waitvsync();
    update_cells();
  }
}
#elif defined(__SIM6502__)

static void print_current_counters(void) {
  peripherals.counter.latch = 0; /* latch values */

  peripherals.counter.select = COUNTER_SELECT_CLOCKCYCLE_COUNTER;
  printf("clock cycles ............... : %08lx %08lx\n",
         peripherals.counter.value32[1], peripherals.counter.value32[0]);
  peripherals.counter.select = COUNTER_SELECT_INSTRUCTION_COUNTER;
  printf("instructions ............... : %08lx %08lx\n",
         peripherals.counter.value32[1], peripherals.counter.value32[0]);
  peripherals.counter.select = COUNTER_SELECT_WALLCLOCK_TIME;
  printf("wallclock time ............. : %08lx %08lx\n",
         peripherals.counter.value32[1], peripherals.counter.value32[0]);
  peripherals.counter.select = COUNTER_SELECT_WALLCLOCK_TIME_SPLIT;
  printf("wallclock time, split ...... : %08lx %08lx\n",
         peripherals.counter.value32[1], peripherals.counter.value32[0]);
  printf("\n");
}

static uint8_t res;
int main(void) {
  init_mem(&glider_gun[0], sizeof(glider_gun) / sizeof(glider_gun[0]));

  print_current_counters();
  update_cells();
  print_current_counters();
  return 0;
}
#endif
