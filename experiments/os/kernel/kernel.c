#include "kernel.h"

typedef struct {
  char ch;
  char color;
} term_char;

typedef struct {
  char color;
  int cursor;
} term_state;

#define VIDEO_MEM ((volatile term_char*)0xb8000)
#define TERM_WIDTH 80
#define TERM_HEIGHT 25

void term_clear_screen(void) {
  term_char blank = {
      .ch = ' ',
      .color = 0,
  };

  volatile term_char* video_mem = VIDEO_MEM;

  for (int i = 0; i < TERM_WIDTH * TERM_HEIGHT; i++) {
    video_mem[i] = blank;
  }
}

void term_write_chars(term_state* state, const char* str) {
  volatile term_char* video_mem = VIDEO_MEM;

  while (*str) {
    switch (*str) {
      case '\n':
        state->cursor = (state->cursor / TERM_WIDTH + 1) * TERM_WIDTH;
        str += 1;
        break;
      default:
        video_mem[state->cursor++] = (term_char){
            .ch = *(str++),
            .color = state->color,
        };
        break;
    }
  }
}

void kernel_main(void) {
  term_clear_screen();
  term_state s = {
      .color = 15,
      .cursor = 0,
  };
  term_write_chars(&s, "hello world\n");
  term_write_chars(&s, "how are you today?\n");
}