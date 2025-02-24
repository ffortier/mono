/**
 * Largest Prime Factor
 *
 * The prime factors of 13195 are 5, 7, 13 and 29.
 *
 * What is the largest prime factor of the number 600851475143?
 */

#include <assert.h>
#include <inttypes.h>
#include <math.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

bool is_prime(uint64_t n) {
  uint64_t max = (uint64_t)sqrt((double)n);

  for (uint64_t i = 2; i <= max; i++) {
    if (n % i == 0) return false;
  }

  return true;
}

uint64_t next_prime(uint64_t n) {
  for (int i = n + 1; i < 2 * n; ++i) {
    if (is_prime(i)) {
      return i;
    }
  }

  assert(false && "unreacheable according to Bertrand's postulate");
  abort();
}

uint64_t largest_prime_factor(uint64_t n) {
  assert(n > 2);

  uint64_t max = (uint64_t)sqrt((double)n);
  uint64_t current_prime = 2;
  uint64_t largest_prime = n;

  while (current_prime <= max) {
    if (n % current_prime == 0) {
      largest_prime = current_prime;
    }
    current_prime = next_prime(current_prime);
  }

  return largest_prime;
}

int main(int argc, char** argv) {
  assert(largest_prime_factor(13195) == 29);

  printf("%" PRId64 "\n", largest_prime_factor(600851475143));
}