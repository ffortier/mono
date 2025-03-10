#include <stdbool.h>
#include <stdio.h>

char* increment(char* end) {
  for (;;) {
    switch (*end) {
      case '9':
        *end-- = '0';
        break;
      case '\0':
        *end = '1';
        return end;
      default:
        *end += 1;
        while (*(end - 1) != '\0') {
          end -= 1;
        }
        return end;
    }
  }
}

const char* keylog[] = {
    "319", "680", "180", "690", "129", "620", "762", "689", "762", "318",
    "368", "710", "720", "710", "629", "168", "160", "689", "716", "731",
    "736", "729", "316", "729", "729", "710", "769", "290", "719", "680",
    "318", "389", "162", "289", "162", "718", "729", "319", "790", "680",
    "890", "362", "319", "760", "316", "729", "380", "319", "728", "716"};

bool test(const char* begin, const char* end, const char* key) {
  size_t offset = 0;

  while (offset < 3 && begin <= end) {
    if (*begin++ == key[offset]) offset += 1;
  }

  return offset == 3;
}

int main() {
  char buffer[256] = {0};

  char* end = &buffer[254];
  char* begin;
  bool success;

  do {
    begin = increment(end);
    success = true;

    for (size_t i = 0; i < sizeof(keylog) / sizeof(*keylog); i++) {
      if (!test(begin, end, keylog[i])) {
        success = false;
        break;
      }
    }
  } while (!success);

  printf("%s\n", begin);

  return 0;
}