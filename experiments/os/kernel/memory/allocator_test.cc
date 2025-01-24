#include "allocator.hh"

#include <gmock/gmock.h>
#include <gtest/gtest.h>

class A {
 private:
  bool* _destroyed;

 public:
  A(bool* destroyed) : _destroyed(destroyed) { *_destroyed = false; }

  ~A() { *_destroyed = true; }
};

TEST(allocator, small_object) {
  char table[2] = {0};
  char mem[2 * 4096] = {0};

  heap test_heap{reinterpret_cast<uintptr_t>(&table[0]),
                 reinterpret_cast<uintptr_t>(&mem[0]), 2 * 4096, 4096};

  allocator a{&test_heap, 4096};

  auto destroyed = false;
  auto ptr = a.alloc<A>(&destroyed);

  a.dealloc(ptr);

  EXPECT_TRUE(destroyed);
}