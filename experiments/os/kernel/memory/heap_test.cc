#include "heap.hh"

#include <gmock/gmock.h>
#include <gtest/gtest.h>

TEST(heap, malloc) {
  char table[2] = {0};
  char mem[2 * 4096] = {0};

  heap test_heap{reinterpret_cast<uintptr_t>(&table[0]),
                 reinterpret_cast<uintptr_t>(&mem[0]), 2 * 4096, 4096};

  EXPECT_EQ(table[0], static_cast<char>(heap::block::FREE));
  EXPECT_EQ(table[1], static_cast<char>(heap::block::FREE));

  char* v1 = test_heap.malloc<char>(20);
  char* v2 = test_heap.malloc<char>(20);

  v1[0] = '1';
  v1[1] = '\0';
  v2[0] = '2';
  v2[1] = '\0';

  EXPECT_EQ(table[0], static_cast<char>(heap::block::END));
  EXPECT_EQ(table[1], static_cast<char>(heap::block::END));

  EXPECT_EQ(&mem[0], v1);
  EXPECT_EQ(&mem[4096], v2);

  test_heap.free(v1);

  EXPECT_EQ(table[0], static_cast<char>(heap::block::FREE));
  EXPECT_EQ(table[1], static_cast<char>(heap::block::END));

  test_heap.free(v2);

  EXPECT_EQ(table[0], static_cast<char>(heap::block::FREE));
  EXPECT_EQ(table[1], static_cast<char>(heap::block::FREE));

  v1 = test_heap.malloc<char>(20 + 4096);

  EXPECT_EQ(table[0], static_cast<char>(heap::block::NEXT));
  EXPECT_EQ(table[1], static_cast<char>(heap::block::END));

  EXPECT_EQ(test_heap.malloc<char>(20), nullptr);

  test_heap.free(v1);
}