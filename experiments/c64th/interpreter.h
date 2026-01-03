#ifndef INTERPRETER_H
#define INTERPRETER_H

#include "lexer.h"

typedef struct {
  Lexer* lexer;
} Interpreter;

void interpreter_init(Interpreter* interpreter, Lexer* lexer);
void interpreter_run(Interpreter* interpreter);

#endif