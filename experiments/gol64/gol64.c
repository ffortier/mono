#include <cbm.h>
#include <peekpoke.h>
#include <stdio.h>
#include <string.h>

char counts[1000] = {0};
char* mem = (char*)0x0400;

#define SPACE 32
#define CIRCLE 81

void update_cells(void) {
  unsigned char x, y;
  char* current_count;
  char* current_mem;

  memset(&counts[0], 0, 1000);

  current_mem = mem;
  current_count = &counts[0];

  for (y = 0; y < 25; y++) {
    for (x = 0; x < 40; x++) {
      if (*current_mem == CIRCLE) {
        if (x > 0) {
          *(current_count - 1) += 1;
          if (y > 0) *(current_count - 41) += 1;
          if (y < 24) *(current_count + 39) += 1;
        }

        if (x < 39) {
          *(current_count + 1) += 1;
          if (y > 0) *(current_count - 39) += 1;
          if (y < 24) *(current_count + 41) += 1;
        }

        if (y > 0) *(current_count - 40) += 1;
        if (y < 24) *(current_count + 40) += 1;
      }
      current_mem++;
      current_count++;
    }
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

  X X X X

#undef X
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
}