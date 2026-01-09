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

  X X X X

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

int main() {
  int i;
  char x, y;
  char* input_row;
  char* output_row;

  POKE(53272, 21);  // Enable uppercase + graphics mode

  for (i = 0; i < 1000; i++) {
    mem[i] = SPACE;
  }

  x = 0;
  y = 0;

  for (i = 0; i < sizeof(glider_gun) / sizeof(glider_gun[0]); i++) {
    input_row = glider_gun[i];
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

  while (1) {
    waitvsync();
    update_cells();
  }
}