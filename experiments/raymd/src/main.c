#include <assert.h>
#include <errno.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "raylib.h"

#define DOCUMENT_READER_BUF_LENGTH 4096

#define da_append(da, el)                                                  \
  do {                                                                     \
    if ((da)->count >= (da)->capacity) {                                   \
      if ((da)->capacity == 0) {                                           \
        (da)->capacity = 256;                                              \
        (da)->items = malloc(sizeof((da)->items[0]) * (da)->capacity);     \
      } else {                                                             \
        (da)->capacity = (da)->capacity * 2;                               \
        (da)->items =                                                      \
            realloc((da)->items, sizeof((da)->items[0]) * (da)->capacity); \
      }                                                                    \
      assert((da)->items != 0);                                            \
    }                                                                      \
    (da)->items[(da)->count++] = (el);                                     \
  } while (0)

struct args {
  const char* file_name;
};

struct window {
  int scroll_top;
  int scroll_left;
  int width;
  int height;
};

struct document_reader {
  FILE* fp;
  char buf[DOCUMENT_READER_BUF_LENGTH];
  size_t pos;
  size_t len;
  size_t offset;
};

enum markup_type {
  MARKUP_PARAGRAPH,

  // line
  MARKUP_H1,
  MARKUP_H2,

  // inline
  MARKUP_BOLD
};

bool is_line_markup(enum markup_type type) {
  return type >= MARKUP_H1 && type < MARKUP_BOLD;
}

bool is_inline_markup(enum markup_type type) { return type >= MARKUP_BOLD; }

struct markup {
  enum markup_type type;
  char* begin;
  char* end;
};

struct document {
  char* buffer;
  struct markup* items;
  size_t count;
  size_t capacity;
  long buffer_len;
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

int document_reader_next(struct document_reader* reader) {
  if (reader->pos < reader->len) {
    return reader->buf[reader->pos++];
  }

  if (feof(reader->fp)) {
    return -1;
  }

  size_t cb =
      fread(reader->buf, sizeof(char), DOCUMENT_READER_BUF_LENGTH, reader->fp);

  TraceLog(LOG_INFO, "Read %zu", cb);

  reader->offset += reader->len;
  reader->len = cb;
  reader->pos = 0;

  if (reader->pos < reader->len) {
    return reader->buf[reader->pos++];
  }

  return -1;
}

long file_size(FILE* fp) {
  long cur = ftell(fp);

  if (cur < 0) return -1;
  if (fseek(fp, 0, SEEK_END) != 0) return -1;

  long size = ftell(fp);

  if (size < 0) return -1;
  if (fseek(fp, cur, SEEK_SET) != 0) return -1;

  return size;
}

#define FCHECK(condition, message)                          \
  do {                                                      \
    if (!(condition)) {                                     \
      TraceLog(LOG_FATAL, message ": %s", strerror(errno)); \
      goto error;                                           \
    }                                                       \
  } while (0)

void document_free(struct document* document) {
  free(document->items);
  free(document->buffer);
  free(document);
}

struct document* read_document(const char* file_name) {
  struct document_reader reader;
  struct document* document = calloc(1, sizeof(struct document));

  reader.fp = fopen(file_name, "r");

  FCHECK(reader.fp, "Failed to open file");

  document->buffer_len = file_size(reader.fp);

  FCHECK(document->buffer_len >= 0, "Failed to compute file size");

  document->buffer = malloc((size_t)document->buffer_len);

  int ch = document_reader_next(&reader);

  struct markup current_markup = {
      .type = MARKUP_PARAGRAPH,
      .begin = &document->buffer[0],
      .end = &document->buffer[0],
  };

  bool whitespace = true;
  bool blank_line = true;

  while (ch != -1) {
    switch (ch) {
      case '#':
        printf("heading\n");
        if (!blank_line) goto fallback;
        da_append(document, current_markup);
        *current_markup.end++ = '\0';
        current_markup.type = MARKUP_H1;
        current_markup.begin = current_markup.end;
        blank_line = false;
        whitespace = false;
        break;
      case '\n':
        if (is_line_markup(current_markup.type)) {
          da_append(document, current_markup);
          *current_markup.end++ = '\0';
          current_markup.type = MARKUP_PARAGRAPH;
          current_markup.begin = current_markup.end;
        } else if (blank_line) {
          da_append(document, current_markup);
          *current_markup.end++ = '\0';
          current_markup.type = MARKUP_PARAGRAPH;
          current_markup.begin = current_markup.end;
        }

        blank_line = true;
        goto whitespace;
      case ' ':
      case '\t':
      case '\r':
      whitespace:
        if (!whitespace) {
          *current_markup.end++ = ' ';
          whitespace = true;
        }
        break;
      default:
      fallback:
        whitespace = false;
        blank_line = false;
        *current_markup.end++ = ch;
        break;
    }
    ch = document_reader_next(&reader);
  }
  *current_markup.end = '\0';
  da_append(document, current_markup);

  FCHECK(!ferror(reader.fp), "Failed to read");

  goto defer;

error:
  if (document != NULL) {
    document_free(document);
    document = NULL;
  }

defer:
  if (reader.fp != NULL) fclose(reader.fp);

  return document;
}

void markup_render(struct markup markup, const struct window* window) {
  switch (markup.type) {
    case MARKUP_H1:
      DrawText(markup.begin, 10, 10, 10, RED);
      break;
    case MARKUP_PARAGRAPH:
      DrawText(markup.begin, 10, 10, 10, BLACK);
      break;
    default:
      assert(false && "unreacheable");
      break;
  }
}

int main(int argc, char** argv) {
  struct args args = parse_args(argc, argv);
  struct window window = {0};
  struct document* document = read_document(args.file_name);

  if (!document) return 1;

  fprintf(stderr, "Markup count: %p\n", document);
  InitWindow(800, 600, "raymd");

  SetTargetFPS(60);

  while (!WindowShouldClose()) {
    BeginDrawing();
    ClearBackground(RAYWHITE);

    for (size_t i = 0; i < document->count; i++) {
      markup_render(document->items[i], &window);
    }

    EndDrawing();
  }

  CloseWindow();

  document_free(document);

  return 0;
}