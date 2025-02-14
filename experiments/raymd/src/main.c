#include <assert.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "raylib.h"

struct args {
  const char* file_name;
};

struct window {
  int scroll_top;
  int scroll_left;
  int width;
  int height;
};

struct document {
  char* text;
};

struct args parse_args(int argc, char** argv) {
  const char* program = *argv++;
  const char* p = strrchr(program, '/');

  if (p != NULL) {
    program = p + 1;
  }

  argc -= 1;

  if (argc != 1) {
    fprintf(stderr, "Usage: %s <file_name>\n", program);
    fprintf(stderr, "ERROR: Missing file name\n");
    exit(1);
  }

  return (struct args){.file_name = argv[0]};
}

struct document* read_document(const char* file_name) {
  FILE* fd = fopen(file_name, "r");
  char* text = NULL;
  struct document* document = NULL;

  if (fd == NULL) {
    fprintf(stderr, "Failed to open file %s: %s", file_name, strerror(errno));
    goto error;
  }

  if (fseek(fd, 0, SEEK_END) != 0) {
    fprintf(stderr, "Failed to seek to end of file %s: %s", file_name,
            strerror(errno));
    goto error;
  }

  long size = ftell(fd);

  if (size < 0) {
    fprintf(stderr, "Failed to get file size %s: %s", file_name,
            strerror(errno));
    goto error;
  }

  if (fseek(fd, 0, SEEK_SET) != 0) {
    fprintf(stderr, "Failed to seek to begining of file %s: %s", file_name,
            strerror(errno));
    goto error;
  }

  text = malloc(sizeof(char) * size);

  assert(text != 0);

  if (fread(text, sizeof(char), size, fd) != size) {
    if (ferror(fd)) {
      fprintf(stderr, "Failed to read file %s: %s", file_name, strerror(errno));
      goto error;
    }
    fprintf(stderr, "Unexpected end of file %s", file_name);
    goto error;
  }

  document = malloc(sizeof(struct document));
  document->text = text;

  goto defer;

error:
  if (text != NULL) free(text);

defer:
  if (fd != NULL) fclose(fd);

  return document;
}

void free_document(struct document* document) {
  free(document->text);
  free(document);
}

int main(int argc, char** argv) {
  struct args args = parse_args(argc, argv);
  struct window window = {0};
  struct document* document = read_document(args.file_name);

  if (!document) return 1;

  printf("%s\n", document->text);

  InitWindow(800, 600, "raymd");

  SetTargetFPS(60);

  while (!WindowShouldClose()) {
    BeginDrawing();
    ClearBackground(RAYWHITE);
    EndDrawing();
  }

  CloseWindow();

  free_document(document);

  return 0;
}