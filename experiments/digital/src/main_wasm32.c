#include <stdlib.h>
#include <string.h>

#include "flipflops.h"
#include "observable.h"

void* calloc(size_t count, size_t size) {
  void* ptr = malloc(count * size);
  if (ptr) {
    memset(ptr, 0, count * size);
  }
  return ptr;
}

void _assert(char const* message, char const* filename, unsigned line) {}

int snprintf(char* buffer, size_t bufsz, const char* format, ...) { return 0; }

__attribute__((import_module("env"), import_name("dispatchVisitPin"))) void
dispatch_visit_pin(visitor_t* self, observable_t* component,
                   const char* pin_name, size_t pin_index);

__attribute__((import_module("env"),
               import_name("dispatchVisitComponent"))) void
dispatch_visit_component(visitor_t* self, observable_t* component);

WASM_EXPORT("makeVisitor") visitor_t* make_visitor(void) {
  visitor_t* visitor = malloc(sizeof(visitor_t));
  visitor->visit_pin = dispatch_visit_pin;
  visitor->visit_component = dispatch_visit_component;
  return visitor;
}
