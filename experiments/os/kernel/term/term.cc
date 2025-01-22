#include "term.hh"

console& console::get() {
  static console instance(reinterpret_cast<uint16_t*>(0xb8000), 80, 25);
  return instance;
}

void console::clear() {
  for (int i = 0; i < width * height; i++) {
    video_mem[i] = color | ' ';
  }

  cursor = 0;
}

void console::write_chars(const char* chars) {
  while (*chars) {
    switch (*chars) {
      case '\n':
        cursor = (cursor / width + 1) * width;
        chars += 1;
        break;
      default:
        video_mem[cursor++] = color | *(chars++);
        break;
    }
  }
}
