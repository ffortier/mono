#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

#define TARGET_WIDTH 128
#define TARGET_HEIGHT 160
#define TILE_SIZE 32

#define DBG(X, FMT) fprintf(stderr, "%s = " FMT "\n", #X, (X))

void copy_to(uint32_t* dest, int col, int row, const uint32_t* src, int width,
             int height) {
  assert(width >= TILE_SIZE);
  assert(height >= TILE_SIZE);

  int offset_x = col * TILE_SIZE;
  int offset_y = row * TILE_SIZE;
  int src_x = (width - TILE_SIZE) / 2;

  DBG(offset_x, "%d");
  DBG(offset_y, "%d");
  DBG(src_x, "%d");

  for (int y = 0; y < TILE_SIZE; y++) {
    for (int x = 0; x < TILE_SIZE; x++) {
      DBG((offset_y + y) * TARGET_WIDTH + (offset_x + x), "%d");
      dest[(offset_y + y) * TARGET_WIDTH + (offset_x + x)] =
          src[y * width + x + src_x];
    }
  }
}

int main(int argc, char** argv) {
  if (argc != 5 * 4 + 1) {
    fprintf(stderr, "Expected %d args", 5 * 4 + 1);
    return 1;
  }

  uint32_t* pixels = malloc(TARGET_WIDTH * TARGET_HEIGHT * sizeof(uint32_t));
  memset(pixels, 0, TARGET_WIDTH * TARGET_HEIGHT * sizeof(uint32_t));

  int col = 0;
  int row = 0;

  for (size_t i = 1; i < argc; i++) {
    int width;
    int height;
    int comp;

    uint32_t* src = (uint32_t*)stbi_load(argv[i], &width, &height, &comp, 4);

    DBG(argv[i], "%s");
    DBG(width, "%d");
    DBG(height, "%d");

    assert(comp == 4);

    copy_to(pixels, col, row, src, width, height);

    STBI_FREE(src);

    if (++col == 4) {
      row += 1;
      col = 0;
    }
  }

  char path_buf[1024] = {0};
  char* wd = getenv("BUILD_WORKING_DIRECTORY");

  assert(wd != NULL && "Expected to be run via bazel");

  snprintf(path_buf, 1024, "%s/%s", wd, "out.png");

  if (!stbi_write_png(path_buf, TARGET_WIDTH, TARGET_HEIGHT, 4, pixels,
                      TARGET_WIDTH * sizeof(uint32_t))) {
    fprintf(stderr, "Failed to save png to %s", path_buf);
    return 1;
  }

  free(pixels);

  return 0;
}