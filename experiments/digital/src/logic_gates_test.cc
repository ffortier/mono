extern "C" {
#include "logic_gates.h"

#include "observable.h"
}

// #include <slog/slog.h>
#include <gtest/gtest.h>

TEST(nand_gate, TruthTable) {
  // slog_init("digital", SLOG_FLAGS_ALL, 0);
  nand_gate_t *gate = make_nand_gate();

  gate->a = 0;
  gate->b = 0;
  apply();
  fprintf(stderr, NAND_GATE_FMT "\n", NAND_GATE_VALUES(gate));
  EXPECT_TRUE(gate->z);

  gate->a = 1;
  gate->b = 0;
  apply();
  fprintf(stderr, NAND_GATE_FMT "\n", NAND_GATE_VALUES(gate));
  EXPECT_TRUE(gate->z);

  gate->a = 0;
  gate->b = 1;
  apply();
  fprintf(stderr, NAND_GATE_FMT "\n", NAND_GATE_VALUES(gate));
  EXPECT_TRUE(gate->z);

  gate->a = 1;
  gate->b = 1;
  apply();
  fprintf(stderr, NAND_GATE_FMT "\n", NAND_GATE_VALUES(gate));
  EXPECT_FALSE(gate->z);

  // TODO: destroy
}

TEST(and_gate, TruthTable) {
  and_gate_t *gate = make_and_gate();

  gate->a = 0;
  gate->b = 0;
  apply();
  EXPECT_FALSE(gate->z);

  gate->a = 1;
  gate->b = 0;
  apply();
  EXPECT_FALSE(gate->z);

  gate->a = 0;
  gate->b = 1;
  apply();
  EXPECT_FALSE(gate->z);

  gate->a = 1;
  gate->b = 1;
  apply();
  EXPECT_TRUE(gate->z);

  // TODO: destroy
}

TEST(or_gate, TruthTable) {
  or_gate_t *gate = make_or_gate();

  gate->a = 0;
  gate->b = 0;
  apply();
  EXPECT_FALSE(gate->z);

  gate->a = 1;
  gate->b = 0;
  apply();
  EXPECT_TRUE(gate->z);

  gate->a = 0;
  gate->b = 1;
  apply();
  EXPECT_TRUE(gate->z);

  gate->a = 1;
  gate->b = 1;
  apply();
  EXPECT_TRUE(gate->z);

  // TODO: destroy
}

TEST(xor_gate, TruthTable) {
  xor_gate_t *gate = make_xor_gate();

  gate->a = 0;
  gate->b = 0;
  apply();
  EXPECT_FALSE(gate->z);

  gate->a = 1;
  gate->b = 0;
  apply();
  EXPECT_TRUE(gate->z);

  gate->a = 0;
  gate->b = 1;
  apply();
  EXPECT_TRUE(gate->z);

  gate->a = 1;
  gate->b = 1;
  apply();
  EXPECT_FALSE(gate->z);

  // TODO: destroy
}

TEST(not_gate, TruthTable) {
  not_gate_t *gate = make_not_gate();

  gate->a = 0;
  apply();
  EXPECT_TRUE(gate->z);

  gate->a = 1;
  apply();
  EXPECT_FALSE(gate->z);

  // TODO: destroy
}
