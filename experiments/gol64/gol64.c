#include <cbm.h>
#include <peekpoke.h>
#include <stdio.h>
#include <string.h>

char counts[1000] = {0};
char* mem = (char*)0x0400;

#define SPACE 32
#define CIRCLE 81

void update_cells(void) {
  int i = 0;
  signed char x, y;

  memset(&counts[0], 0, 1000);

  for (y = 0; y < 25; y++) {
    for (x = 0; x < 40; x++) {
      if (mem[i] == CIRCLE) {
        // counts[i] += 1;
        if (x > 0) {
          counts[i - 1] += 1;
          if (y > 0) counts[i - 41] += 1;
          if (y < 24) counts[i + 39] += 1;
        }

        if (x < 39) {
          counts[i + 1] += 1;
          if (y > 0) counts[i - 39] += 1;
          if (y < 24) counts[i + 41] += 1;
        }

        if (y > 0) counts[i - 40] += 1;
        if (y < 24) counts[i + 40] += 1;
      }
      i++;
    }
  }

  for (i = 0; i < 1000; i++) {
    // mem[i] = '0' + counts[i];
    if (mem[i] == CIRCLE) {
      if (counts[i] != 2 && counts[i] != 3) mem[i] = SPACE;
    } else {
      if (counts[i] == 3) mem[i] = CIRCLE;
    }
  }
}

int main() {
  int i;

  POKE(53272, 21);  // Enable uppercase + graphics mode

  for (i = 0; i < 1000; i++) {
    mem[i] = SPACE;
  }

  mem[42] = CIRCLE;
  mem[83] = CIRCLE;
  mem[121] = CIRCLE;
  mem[122] = CIRCLE;
  mem[123] = CIRCLE;

  mem[52] = CIRCLE;
  mem[93] = CIRCLE;
  mem[131] = CIRCLE;
  mem[132] = CIRCLE;
  mem[133] = CIRCLE;

  mem[320] = CIRCLE;
  mem[321] = CIRCLE;
  mem[322] = CIRCLE;

  while (1) {
    waitvsync();
    update_cells();
  }
  return 0;
}