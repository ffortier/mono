#include <assert.h>
#include <inttypes.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFFER_SIZE ((size_t)2 * (size_t)1024 * (size_t)1024 * (size_t)1024)

size_t count_summations(uint8_t n) {
  uint8_t *buffer = malloc(BUFFER_SIZE);
  size_t buffer_offset = 0;
  size_t *solution_sizes = calloc(n + 1, sizeof(size_t));
  uint8_t **solution_values = calloc(n + 1, sizeof(uint8_t));

  solution_sizes[0] = 0;
  solution_sizes[1] = 1;
  solution_values[1] = &buffer[buffer_offset++];
  *solution_values[1] = 1;

  for (uint8_t i = 2; i <= n; i++) {
    assert(buffer_offset < BUFFER_SIZE);

    solution_values[i] = &buffer[buffer_offset];
    solution_values[i][solution_sizes[i]++] = i;

    for (uint8_t j = 1; j < i; j++) {
      for (size_t x = 0; x < solution_sizes[i - j]; x++) {
        if (solution_values[i - j][x] <= j) {
          assert(buffer_offset + solution_sizes[i] < BUFFER_SIZE);

          solution_values[i][solution_sizes[i]++] = j;
        }
      }
    }

    buffer_offset += solution_sizes[i];

    fprintf(stderr, "%" PRIu8 ": %zu\n", i, solution_sizes[i] - 1);
  }

  size_t res = solution_sizes[n] - 1;

  free(buffer);
  free(solution_sizes);
  free(solution_values);

  return res;
}

int main(void) {
  size_t res = count_summations(100);

  printf("\n%zu\n", res);

  return 0;
}