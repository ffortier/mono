#pragma once

#include "kernel/nostd/nostd.hh"

class paging_directory {
 private:
  uintptr_t* _tables;

 public:
  enum flags : uintptr_t {
    CACHE_DISABLED = 0b00010000,
    WRITE_THROUGH = 0b00001000,
    ACCESS_FROM_ALL = 0b00000100,
    IS_WRITEABLE = 0b00000010,
    IS_PRESENT = 0b00000001,
  };

  paging_directory(uintptr_t flags);
  ~paging_directory();

  paging_directory(const paging_directory&) = delete;
  paging_directory(paging_directory&&) = delete;

  paging_directory& operator=(const paging_directory&) = delete;
  paging_directory& operator=(paging_directory&&) = delete;

  static void enable();
  void load();

  void set(uintptr_t virt, uintptr_t physical, uintptr_t flags);
};