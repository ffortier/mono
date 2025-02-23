#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

int main(int argc, char** argv) {
  uint64_t a = 0;
  uint64_t b = 1;
  uint64_t sum = 0;

  while (a < 4000000) {
    if ((a & 1) == 0) {
      sum += a;
    }
    uint64_t c = a + b;
    a = b;
    b = c;
  }

  printf("%" PRId64 "\n", sum);

  return 0;
}