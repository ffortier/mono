#ifndef LEXER_H
#define LEXER_H

#include <stdbool.h>

#include "char_stream.h"

typedef enum {
  TOKEN_EOF,
  TOKEN_UNKNOWN,
  TOKEN_NUMBER,
  TOKEN_PLUS,
  TOKEN_MINUS,
  TOKEN_ASTERISK,
  TOKEN_SLASH,
} TokenKind;

typedef struct {
  TokenKind kind;
  union {
    int number;
  } as;
} Token;

typedef struct {
  CharStream* stream;
  Token current_token;
} Lexer;

void lexer_init(Lexer* lexer, CharStream* stream);
Token* lexer_get_token(Lexer* lexer);
TokenKind lexer_next(Lexer* lexer);

#endif