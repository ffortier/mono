#include <assert.h>
#include <slog/slog.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "clock.h"
#include "latches.h"
#include "logic_gates.h"
#include "observable.h"

typedef struct debug_visitor {
  visitor_t super;
  int depth;
} debug_visitor_t;

void debug_visit_pin(debug_visitor_t* self, observable_t* component,
                     const char* pin_name, size_t pin_index) {
  fprintf(stderr, "%*s.%s = %d,\n", self->depth, " ", pin_name,
          component->pins[pin_index]);
}

void debug_visit_component(debug_visitor_t* self, observable_t* component) {
  int depth = self->depth;

  fprintf(stderr, "%*s%s {\n", depth, " ", component->type_name);

  self->depth = depth + 2;
  visit_children(&self->super, component);
  self->depth = depth;

  fprintf(stderr, "%*s}%s\n", depth, " ", depth == 0 ? "" : ",");
}

int main(void) {
  slog_init("digital", SLOG_FLAGS_ALL - SLOG_TRACE, 0);

  debug_visitor_t debug_visitor = {
      .super =
          (visitor_t){
              .visit_pin = (visit_pin_t)debug_visit_pin,
              .visit_component = (visit_component_t)debug_visit_component,
          },
      .depth = 0,
  };

  sr_latch_t* sr_latch = make_sr_latch();
  apply();

  debug_visit_component(&debug_visitor, &sr_latch->observable);

  // clk_t* clock = make_clk();
  // d_latch_t* d_latch = make_d_latch();

  // connect(SELECT(clock, q), SELECT(d_latch, e));

  // clock_pulse(clock);
  // printf(D_LATCH_FMT "\n", D_LATCH_VALUES(d_latch));

  // d_latch->d = 1;

  // clock->q = 1;
  // apply();
  // printf(D_LATCH_FMT "\n", D_LATCH_VALUES(d_latch));
  // clock->q = 0;
  // apply();

  // // clock_pulse(clock);
  // printf(D_LATCH_FMT "\n", D_LATCH_VALUES(d_latch));

  // d_latch->d = 0;

  // clock_pulse(clock);
  // printf(D_LATCH_FMT "\n", D_LATCH_VALUES(d_latch));

  // visit_d_latch(&debug_visitor, d_latch);

  return 0;
}
