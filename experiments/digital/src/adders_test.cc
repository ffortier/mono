extern "C" {
#include "adders.h"

#include "observable.h"
}

#include <gtest/gtest.h>
#include <stdio.h>

TEST(half_adder, TruthTable) {
  half_adder_t* adder = make_half_adder();

  adder->a = 0;
  adder->b = 0;
  apply();
  EXPECT_FALSE(adder->sum);
  EXPECT_FALSE(adder->carry);

  adder->a = 1;
  adder->b = 0;
  apply();
  EXPECT_TRUE(adder->sum);
  EXPECT_FALSE(adder->carry);

  adder->a = 0;
  adder->b = 1;
  apply();
  EXPECT_TRUE(adder->sum);
  EXPECT_FALSE(adder->carry);

  adder->a = 1;
  adder->b = 1;
  apply();
  EXPECT_FALSE(adder->sum);
  EXPECT_TRUE(adder->carry);
}

TEST(full_adder, TruthTable) {
  full_adder_t* adder = make_full_adder();

  adder->a = 0;
  adder->b = 0;
  adder->c = 0;
  apply();
  EXPECT_FALSE(adder->sum);
  EXPECT_FALSE(adder->carry);

  adder->a = 0;
  adder->b = 0;
  adder->c = 1;
  apply();
  EXPECT_TRUE(adder->sum);
  EXPECT_FALSE(adder->carry);

  adder->a = 1;
  adder->b = 0;
  adder->c = 0;
  apply();
  EXPECT_TRUE(adder->sum);
  EXPECT_FALSE(adder->carry);

  adder->a = 1;
  adder->b = 0;
  adder->c = 1;
  apply();
  EXPECT_FALSE(adder->sum);
  EXPECT_TRUE(adder->carry);

  adder->a = 0;
  adder->b = 1;
  adder->c = 0;
  apply();
  EXPECT_TRUE(adder->sum);
  EXPECT_FALSE(adder->carry);

  adder->a = 0;
  adder->b = 1;
  adder->c = 1;
  apply();
  EXPECT_FALSE(adder->sum);
  EXPECT_TRUE(adder->carry);

  adder->a = 1;
  adder->b = 1;
  adder->c = 0;
  apply();
  EXPECT_FALSE(adder->sum);
  EXPECT_TRUE(adder->carry);

  adder->a = 1;
  adder->b = 1;
  adder->c = 1;
  apply();
  EXPECT_TRUE(adder->sum);
  EXPECT_TRUE(adder->carry);
}

TEST(adder_8, Sum) {
  adder_8_t* adder = make_adder_8();

  // 42 -> 101010
  adder->a_inputs[0] = 0;
  adder->a_inputs[1] = 1;
  adder->a_inputs[2] = 0;
  adder->a_inputs[3] = 1;
  adder->a_inputs[4] = 0;
  adder->a_inputs[5] = 1;

  // 27 -> 11011
  adder->b_inputs[0] = 1;
  adder->b_inputs[1] = 1;
  adder->b_inputs[2] = 0;
  adder->b_inputs[3] = 1;
  adder->b_inputs[4] = 1;
  adder->b_inputs[5] = 0;

  apply();

  // 69 -> 1000101
  EXPECT_TRUE(adder->outputs[0]);
  EXPECT_FALSE(adder->outputs[1]);
  EXPECT_TRUE(adder->outputs[2]);
  EXPECT_FALSE(adder->outputs[3]);
  EXPECT_FALSE(adder->outputs[4]);
  EXPECT_FALSE(adder->outputs[5]);
  EXPECT_TRUE(adder->outputs[6]);
  EXPECT_FALSE(adder->outputs[7]);
  EXPECT_FALSE(adder->cout);
}