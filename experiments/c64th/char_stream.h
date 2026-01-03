#ifndef CHAR_STREAM_H
#define CHAR_STREAM_H

#include <stdbool.h>
#include <stdio.h>

typedef size_t (*CharStreamRead)(char* ptr, size_t count, FILE* stream);

typedef struct {
  FILE* input;
  char buffer[256];
  int pos;
  int count;
  CharStreamRead read;
} CharStream;

void char_stream_init_stdin(CharStream* stream);
char char_stream_get_char(CharStream* stream);
bool char_stream_next(CharStream* stream);

#endif