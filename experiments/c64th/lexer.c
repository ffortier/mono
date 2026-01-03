#include "lexer.h"

#include <string.h>

void lexer_init(Lexer* lexer, CharStream* stream) {
  lexer->stream = stream;
  lexer->current_token.kind = TOKEN_EOF;
}

Token* lexer_get_token(Lexer* lexer) { return &lexer->current_token; }

static int read_number(Lexer* lexer, char first_char) {
  int number = first_char - '0';
  char c;

  while (char_stream_next(lexer->stream)) {
    c = char_stream_get_char(lexer->stream);
    if (c >= '0' && c <= '9') {
      number = number * 10 + (c - '0');
    } else {
      return number;
    }
  }

  return number;
}

TokenKind lexer_next(Lexer* lexer) {
  memset(&lexer->current_token, 0, sizeof(Token));

  while (char_stream_next(lexer->stream)) {
    char c = char_stream_get_char(lexer->stream);

    switch (c) {
      case '+':
        lexer->current_token.kind = TOKEN_PLUS;
        goto done;
      case '-':
        lexer->current_token.kind = TOKEN_MINUS;
        goto done;
      case '*':
        lexer->current_token.kind = TOKEN_ASTERISK;
        goto done;
      case '/':
        lexer->current_token.kind = TOKEN_SLASH;
        goto done;
      case '.':
        lexer->current_token.kind = TOKEN_DOT;
        goto done;
      default:
        if (c >= '0' && c <= '9') {
          lexer->current_token.kind = TOKEN_NUMBER;
          lexer->current_token.as.number = read_number(lexer, c);
          goto done;
        }

        // Ignore unknown characters

        break;
    }
  }
done:

  return lexer->current_token.kind;
}
