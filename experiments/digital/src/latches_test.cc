extern "C" {
#include "latches.h"

#include "observable.h"
}

#include <gtest/gtest.h>
#include <slog/slog.h>

TEST(sr_latch_t, TruthTable) {
  sr_latch_t* sr_latch = make_sr_latch();

  sr_latch->s = 0;
  sr_latch->r = 1;
  apply();
  EXPECT_FALSE(sr_latch->q);
  EXPECT_TRUE(sr_latch->q1);

  sr_latch->s = 0;
  sr_latch->r = 0;
  apply();
  EXPECT_FALSE(sr_latch->q);
  EXPECT_TRUE(sr_latch->q1);

  sr_latch->s = 1;
  sr_latch->r = 0;
  apply();
  EXPECT_TRUE(sr_latch->q);
  EXPECT_FALSE(sr_latch->q1);

  sr_latch->s = 0;
  sr_latch->r = 0;
  apply();
  EXPECT_TRUE(sr_latch->q);
  EXPECT_FALSE(sr_latch->q1);
}

TEST(d_latch_t, TruthTable) {
  d_latch_t* d_latch = make_d_latch();

  d_latch->d = 0;
  d_latch->e = 1;
  apply();
  EXPECT_FALSE(d_latch->q);
  EXPECT_TRUE(d_latch->q1);

  d_latch->d = 0;
  d_latch->e = 0;
  apply();
  EXPECT_FALSE(d_latch->q);
  EXPECT_TRUE(d_latch->q1);

  d_latch->d = 1;
  d_latch->e = 1;
  apply();
  EXPECT_TRUE(d_latch->q);
  EXPECT_FALSE(d_latch->q1);

  d_latch->d = 0;
  d_latch->e = 0;
  apply();
  EXPECT_TRUE(d_latch->q);
  EXPECT_FALSE(d_latch->q1);
}
