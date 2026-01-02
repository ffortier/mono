#include <cbm.h>
#include <conio.h>
#include <stdbool.h>
#include <stdio.h>

#include "char_stream.h"
#include "lexer.h"

int main() {
  static CharStream stream = {0};
  static Lexer lexer = {0};
  char c;

  char_stream_init_stdin(&stream);
  lexer_init(&lexer, &stream);

  clrscr();
  printf("Hello, C64 World!\n");

  while (lexer_next(&lexer) != TOKEN_EOF) {
    Token* token = lexer_get_token(&lexer);
    switch (token->kind) {
      case TOKEN_NUMBER:
        printf("NUMBER: %d\n", token->as.number);
        break;
      case TOKEN_PLUS:
        printf("PLUS\n");
        break;
      case TOKEN_MINUS:
        printf("MINUS\n");
        break;
      case TOKEN_ASTERISK:
        printf("ASTERISK\n");
        break;
      case TOKEN_SLASH:
        printf("SLASH\n");
        break;
      default:
        printf("UNKNOWN TOKEN\n");
        break;
    }
  }

  return 0;
}