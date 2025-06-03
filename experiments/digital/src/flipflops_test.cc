extern "C" {
#include "flipflops.h"
}

#include <gtest/gtest.h>

TEST(jk_flip_flop, Toggle) {
  jk_flip_flop_t* jk_flip_flop = make_jk_flip_flop();

  jk_flip_flop->j = 1;
  jk_flip_flop->k = 0;
  jk_flip_flop->clk = 1;
  apply();
  jk_flip_flop->clk = 0;
  apply();
  fprintf(stderr, JK_FLIP_FLOP_FMT "\n", JK_FLIP_FLOP_VALUES(jk_flip_flop));
  EXPECT_TRUE(jk_flip_flop->q);

  jk_flip_flop->j = 1;
  jk_flip_flop->k = 1;
  jk_flip_flop->clk = 1;
  apply();
  jk_flip_flop->clk = 0;
  apply();
  fprintf(stderr, JK_FLIP_FLOP_FMT "\n", JK_FLIP_FLOP_VALUES(jk_flip_flop));
  EXPECT_FALSE(jk_flip_flop->q);

  jk_flip_flop->j = 1;
  jk_flip_flop->k = 1;
  jk_flip_flop->clk = 1;
  apply();
  jk_flip_flop->clk = 0;
  apply();
  fprintf(stderr, JK_FLIP_FLOP_FMT "\n", JK_FLIP_FLOP_VALUES(jk_flip_flop));
  EXPECT_TRUE(jk_flip_flop->q);
}