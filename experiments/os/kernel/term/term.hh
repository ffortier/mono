#pragma once

#include "nostd/types.h"

class console {
 private:
  volatile uint16_t* video_mem;
  size_t width;
  size_t height;
  size_t cursor;
  uint16_t color;

 public:
  constexpr console(uint16_t* video_mem, size_t width, size_t height) noexcept
      : video_mem(video_mem),
        width(width),
        height(height),
        color(15),
        cursor(0) {}

  console(console&) = delete;
  console(console&&) = delete;

  static console& get();

  inline void set_color(uint8_t color) {
    this->color = static_cast<uint16_t>(color) << 8;
  }

  void clear();

  void write_chars(const char* chars);
};
