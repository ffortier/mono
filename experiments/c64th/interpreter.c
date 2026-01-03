#include "interpreter.h"

#include "lexer.h"
#include <stdio.h>
void interpreter_init(Interpreter* interpreter, Lexer* lexer) {
  interpreter->lexer = lexer;
}

void interpreter_run(Interpreter* interpreter) {
  static int stack[256];
  int sp = -1;  // Stack pointer (reset each run)

  while (lexer_next(interpreter->lexer) != TOKEN_EOF) {
    Token* token = lexer_get_token(interpreter->lexer);
    switch (token->kind) {
      case TOKEN_NUMBER:
        stack[++sp] = token->as.number;
        break;
      case TOKEN_PLUS:
        stack[sp - 1] = stack[sp - 1] + stack[sp];
        sp--;
        break;
      case TOKEN_MINUS:
        stack[sp - 1] = stack[sp - 1] - stack[sp];
        sp--;
        break;
      case TOKEN_ASTERISK:
        stack[sp - 1] = stack[sp - 1] * stack[sp];
        sp--;
        break;
      case TOKEN_SLASH:
        stack[sp - 1] = stack[sp - 1] / stack[sp];
        sp--;
        break;
      case TOKEN_DOT:
        printf("%d\n", stack[sp--]);
        break;
      default:
        break;
    }
  }
}
