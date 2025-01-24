#pragma once

#include "kernel/nostd/nostd.hh"

class term {
 private:
  volatile uint16_t* video_mem;
  size_t width;
  size_t height;
  size_t cursor;
  uint16_t color;

 public:
  constexpr term(uint16_t* video_mem, size_t width, size_t height) noexcept
      : video_mem(video_mem),
        width(width),
        height(height),
        cursor(0),
        color(15) {}

  term(const term&) = delete;
  term(term&&) = delete;

  term& operator=(const term&) = delete;
  term& operator=(term&&) = delete;

  static term& get();

  inline void set_color(uint8_t color) {
    this->color = static_cast<uint16_t>(color) << 8;
  }

  void clear();

  void write_chars(const char* chars);
};
