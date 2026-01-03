#include "char_stream.h"

#include <stdbool.h>
#include <stdio.h>
#include <string.h>

static size_t stdin_read(char* ptr, size_t count, FILE* stream) {
  if (fgets(ptr, count, stream) == NULL) {
    return 0;
  }
  return strlen(ptr);
}

static size_t file_read(char* ptr, size_t count, FILE* stream) {
  return fread(ptr, 1, count, stream);
}

void char_stream_init_stdin(CharStream* stream) {
  stream->input = stdin;
  stream->pos = 0;
  stream->count = 0;
  stream->read = stdin_read;
}

char char_stream_get_char(CharStream* stream) {
  return stream->buffer[stream->pos];
}

bool char_stream_next(CharStream* stream) {
  if (++stream->pos >= stream->count) {
    stream->pos = 0;
    stream->count =
        stream->read(stream->buffer, sizeof(stream->buffer), stream->input);
  }

  return stream->count > 0;
}