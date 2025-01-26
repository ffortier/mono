#include "disk.hh"

#include "kernel/io/io.hh"

void disk::read_sector(int lba, uint8_t total, uint16_t *buf) {
  outb(0x1f6, (lba >> 24) | 0xe0);
  outb(0x1f2, total);
  outb(0x1f3, lba & 0xff);
  outb(0x1f4, (lba >> 8) & 0xff);
  outb(0x1f5, (lba >> 16) & 0xff);
  outb(0x1f7, 0x20);

  for (int b = 0; b < total; b++) {
    char c = insb(0x1f7);
    while (!(c & 0x08)) {
      c = insb(0x1f7);
    }

    for (int i = 0; i < 256; i++) {
      *buf++ = insw(0x1f0);
    }
  }
}