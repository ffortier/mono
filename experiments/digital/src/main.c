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

  sr_latch_t* sr_latch = make_sr_latch();
  apply();

  debug_visitor_t visitor = {
      .super =
          {
              .visit_component = (visit_component_t)debug_visit_component,
              .visit_pin = (visit_pin_t)debug_visit_pin,
          },
      .depth = 0,
  };

  debug_visit_component(&visitor, sr_latch);

  return 0;
}
