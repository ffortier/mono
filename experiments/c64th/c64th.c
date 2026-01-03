#include <cbm.h>
#include <conio.h>
#include <stdbool.h>
#include <stdio.h>

#include "char_stream.h"
#include "interpreter.h"
#include "lexer.h"

int main() {
  static CharStream stream = {0};
  static Lexer lexer = {0};
  static Interpreter interpreter = {0};

  char_stream_init_stdin(&stream);
  lexer_init(&lexer, &stream);
  interpreter_init(&interpreter, &lexer);

  clrscr();
  printf("Hello, C64 World!\n");

  interpreter_run(&interpreter);

  return 0;
}