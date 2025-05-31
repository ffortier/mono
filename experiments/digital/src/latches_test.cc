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

// TEST(jk_flip_flop, Toggle) {
//   slog_init("digital", SLOG_FLAGS_ALL, 0);
//   jk_flip_flop_t* jk_flip_flop = make_jk_flip_flop();

//   jk_flip_flop->j = 1;
//   jk_flip_flop->k = 1;

//   jk_flip_flop->clk = 1;
//   apply();
//   fprintf(stderr, JK_FLIP_FLOP_FMT "\n", JK_FLIP_FLOP_VALUES(jk_flip_flop));
//   EXPECT_TRUE(jk_flip_flop->q);

//   jk_flip_flop->clk = 0;
//   apply();
//   fprintf(stderr, JK_FLIP_FLOP_FMT "\n", JK_FLIP_FLOP_VALUES(jk_flip_flop));
//   EXPECT_TRUE(jk_flip_flop->q);

//   jk_flip_flop->clk = 1;
//   apply();
//   fprintf(stderr, JK_FLIP_FLOP_FMT "\n", JK_FLIP_FLOP_VALUES(jk_flip_flop));
//   EXPECT_FALSE(jk_flip_flop->q);

//   jk_flip_flop->clk = 0;
//   apply();
//   fprintf(stderr, JK_FLIP_FLOP_FMT "\n", JK_FLIP_FLOP_VALUES(jk_flip_flop));
//   EXPECT_FALSE(jk_flip_flop->q);

//   jk_flip_flop->clk = 1;
//   apply();
//   EXPECT_TRUE(jk_flip_flop->q);

//   jk_flip_flop->clk = 0;
//   apply();
//   EXPECT_TRUE(jk_flip_flop->q);

//   jk_flip_flop->clk = 1;
//   apply();
//   EXPECT_FALSE(jk_flip_flop->q);

//   jk_flip_flop->clk = 0;
//   apply();
//   EXPECT_FALSE(jk_flip_flop->q);
// }