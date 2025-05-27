extern "C" {
#include "latches.h"

#include "observable.h"
}

#include <gtest/gtest.h>

TEST(sr_latch_t, TruthTable) {
  sr_latch_t* sr_latch = make_sr_latch();

  //   fprintf(stderr, SR_LATCH_FMT "\n", SR_LATCH_VALUES(sr_latch));
  //   fprintf(stderr, NAND_GATE_FMT "\n", NAND_GATE_VALUES(&sr_latch->g1));
  //   fprintf(stderr, NAND_GATE_FMT "\n", NAND_GATE_VALUES(&sr_latch->g2));

  sr_latch->s = 0;
  sr_latch->r = 1;
  apply();
  printf(SR_LATCH_FMT "\n", SR_LATCH_VALUES(sr_latch));
  printf(XOR_GATE_FMT "\n", XOR_GATE_VALUES(&sr_latch->g1));
  printf(XOR_GATE_FMT "\n", XOR_GATE_VALUES(&sr_latch->g2));
  EXPECT_FALSE(sr_latch->q);
  EXPECT_TRUE(sr_latch->q1);

  sr_latch->s = 1;
  sr_latch->r = 0;
  apply();
  printf(SR_LATCH_FMT "\n", SR_LATCH_VALUES(sr_latch));
  printf(XOR_GATE_FMT "\n", XOR_GATE_VALUES(&sr_latch->g1));
  printf(XOR_GATE_FMT "\n", XOR_GATE_VALUES(&sr_latch->g2));
  EXPECT_TRUE(sr_latch->q);
  EXPECT_FALSE(sr_latch->q1);
}