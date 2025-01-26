#pragma once

#include "kernel/nostd/nostd.hh"

class disk {
 public:
  void read_sector(int lba, uint8_t total, uint16_t *buf);
};