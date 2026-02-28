#include <c64.h>
#include <cbm.h>
#include <conio.h>
#include <peekpoke.h>
#include <stdint.h>
#include <stdio.h>

#include "screen.h"
typedef struct {
  char* text;
  uint8_t pos;
  int offset;
} text_t;

text_t text = {0};

typedef void (*state_handler)(void);

#define VIDEO_MEM(offset) *((unsigned char*)(0x0400 + offset))
#define STATE (*(state_handler*)0x40)

void first(void);
void second(void);

void dispatch(void) {
  asm("jmp ($40)");
  printf("Unreacheable!\n");
}

char c(void) {
  asm("jmp $ffe4");
  return 0;
}

int main(void) {
  while (1) {
    switch (c()) {
      case 'w':
        screen_move_up();
        break;
      case 's':
        screen_move_down();
        break;
      case 'a':
        screen_move_left();
        break;
      case 'd':
        screen_move_right();
        break;
    }
  }
  // int i;
  // //  POKE(53272, 21);  // Enable uppercase + graphics mode
  // getchar()

  //     STATE = &first;

  // clrscr();

  // text.text = "hellorld";

  // while (1) {
  //   waitvsync();
  //   dispatch();
  // }
}

void first(void) {
  if (text.text[text.pos]) {
    VIDEO_MEM(text.offset++) = text.text[text.pos++];
  } else {
    STATE = &second;
  }
}

void second(void) {
  text.pos = 0;
  while (text.offset % 40) text.offset++;

  text.text = "yup";
  STATE = &first;
}
