#ifndef OBSERVABLE_H
#define OBSERVABLE_H

#include <stdbool.h>
#include <stddef.h>

struct observable;

typedef void (*pin_callback)(struct observable* observable, size_t pin_index,
                             void* user_data);

typedef struct pin_callback_chain {
  pin_callback cb;
  void* user_data;
  struct pin_callback_chain* next;
} pin_callback_chain_t;

struct pin_state {
  int value;
  struct pin_callback_chain* chain;
};

typedef struct observable {
  size_t count;
  struct pin_state* states;
  const char* type_name;
  const char* decl_name;
  void (*print)(void*);
  size_t size;
  int* pins;
} observable_t;

typedef struct observables {
  size_t capacity;
  size_t count;
  struct observable** items;
} observables_t;

#define register_component(component, type)                            \
  register_observable(                                                 \
      &(component)->observable, &(component)->pins[0],                 \
      sizeof((component)->pins) / sizeof((component)->pins[0]), #type, \
      #component, print_##type, sizeof(type))

#define SELECT(component, pin) &(component)->observable, &(component)->pin

void register_observable(struct observable* observable, int* pin0,
                         size_t pin_count, const char* type_name,
                         const char* decl_name, void (*print)(void*),
                         size_t size);

void unregister_observable(struct observable* observable);

bool digest(void);
bool apply(void);

void connect(struct observable* observable1, int* pin1,
             struct observable* observable2, int* pin2);

void append_callback_chain(struct observable* observable, int* pin,
                           struct pin_callback_chain next);
#endif