#include "observable.h"

#include <assert.h>
#include <slog/slog.h>
#include <stdio.h>
#include <stdlib.h>

#ifndef MAX_ITERATION
#define MAX_ITERATION 50
#endif

static struct observables observables = {0};

void register_observable(struct observable* observable, int* pin0,
                         size_t pin_count) {
  // TODO: Make dynamic
  if (observables.capacity == 0) {
    observables.capacity = 100;
    observables.count = 0;
    observables.items = malloc(sizeof(struct observable*) * 100);
  }

  observable->count = pin_count;
  observable->states = malloc(sizeof(struct pin_state) * pin_count);
  observable->pins = pin0;

  assert(observable->states && "buy more ram");

  for (size_t i = 0; i < pin_count; i++) {
    observable->states->value = -1;  // observable->pins[i];
  }

  observables.items[observables.count++] = observable;
}

void unregister_observable(struct observable* component) {
  // TODO: Clean memory
}

static void invoke_chain(struct observable* observable, size_t pin_index) {
  struct pin_callback_chain* chain = observable->states[pin_index].chain;

  while (chain) {
    // TODO: Not necessarily the component
    chain->cb(observable, pin_index, chain->user_data);
    chain = chain->next;
  }
}

bool digest(void) {
  bool stable = true;
  for (size_t i = 0; i < observables.count; i++) {
    struct observable* current = observables.items[i];

    for (size_t j = 0; j < current->count; j++) {
      if (current->pins[j] != current->states[j].value) {
        // TODO: Invoke at the end maybe
        invoke_chain(current, j);
        current->states[j].value = current->pins[j];
        stable = false;
      }
    }
  }
  return stable;
}

/**
 * Run the digest cycle until everything is stable again. Returns false if the
 * MAX_ITERATION is reached
 */
bool apply(void) {
  for (size_t i = 0; i < MAX_ITERATION; i++) {
    if (digest()) {
      slog("apply %zu", i);
      return true;
    }
  }

  slog("apply MAX_ITERATION %zu", MAX_ITERATION);
  return false;
}

static void copy_value(struct observable* observable, size_t pin_index,
                       void* user_data) {
  int* target = user_data;

  *target = observable->pins[pin_index];
}

void append_callback_chain(struct observable* observable, int* pin,
                           struct pin_callback_chain next) {
  size_t pin_index = pin - observable->pins;
  struct pin_callback_chain** current = &observable->states[pin_index].chain;

  while (*current != NULL) {
    current = &(*current)->next;
  }

  *current = malloc(sizeof(struct pin_callback_chain));
  **current = next;
}

void connect(struct observable* observable1, int* pin1,
             struct observable* observable2, int* pin2) {
  append_callback_chain(observable1, pin1,
                        (struct pin_callback_chain){
                            .cb = copy_value,
                            .next = NULL,
                            .user_data = pin2,
                        });

  append_callback_chain(observable2, pin2,
                        (struct pin_callback_chain){
                            .cb = copy_value,
                            .next = NULL,
                            .user_data = pin1,
                        });
}
