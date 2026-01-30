#include <c64.h>
#include <cbm.h>
#include <conio.h>
#include <peekpoke.h>
#include <stdint.h>

typedef struct {
  char* text;
  uint8_t pos;
  uint8_t offset;
} text_t;

text_t text = {0};

#define VIDEO_MEM(offset) *((char*)(0x0400 + offset))

int main(void) {
  //  POKE(53272, 21);  // Enable uppercase + graphics mode

  clrscr();

  text.text = "hello world";

  while (1) {
    waitvsync();
    waitvsync();
    waitvsync();
    waitvsync();
    waitvsync();
    waitvsync();
    waitvsync();

    if (text.text[text.pos]) VIDEO_MEM(text.offset++) = text.text[text.pos++];
  }
}
