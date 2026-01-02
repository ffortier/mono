#include "lexer.h"

void lexer_init(Lexer* lexer, CharStream* stream) {
  lexer->stream = stream;
  lexer->current_token.kind = TOKEN_EOF;
}

Token* lexer_get_token(Lexer* lexer) { return &lexer->current_token; }

TokenKind lexer_next(Lexer* lexer) {
  while (char_stream_next(lexer->stream)) {
    char c = char_stream_get_char(lexer->stream);
    if (c >= '0' && c <= '9') {
      int number = 0;
      do {
        number = number * 10 + (c - '0');
        if (!char_stream_next(lexer->stream)) {
          break;
        }
        c = char_stream_get_char(lexer->stream);
      } while (c >= '0' && c <= '9');
      lexer->current_token.kind = TOKEN_NUMBER;
      lexer->current_token.as.number = number;
      return TOKEN_NUMBER;
    } else if (c == '+') {
      lexer->current_token.kind = TOKEN_PLUS;
      return TOKEN_PLUS;
    } else if (c == '-') {
      lexer->current_token.kind = TOKEN_MINUS;
      return TOKEN_MINUS;
    } else if (c == '*') {
      lexer->current_token.kind = TOKEN_ASTERISK;
      return TOKEN_ASTERISK;
    } else if (c == '/') {
      lexer->current_token.kind = TOKEN_SLASH;
      return TOKEN_SLASH;
    }
  }
  lexer->current_token.kind = TOKEN_EOF;
  return TOKEN_EOF;
}
