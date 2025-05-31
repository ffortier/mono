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

typedef size_t (*format_t)(char* str, size_t n, void* component);

typedef struct observable {
  size_t count;
  struct pin_state* states;
  const char* type_name;
  const char* decl_name;
  format_t formatter;
  size_t size;
  int* pins;
} observable_t;

typedef struct observables {
  size_t capacity;
  size_t count;
  struct observable** items;
} observables_t;

#define register_component(component, component_type)                 \
  register_observable(                                                \
      &(component)->observable, &(component)->pins[0],                \
      sizeof((component)->pins) / sizeof((component)->pins[0]),       \
      #component_type, #component, (format_t)format_##component_type, \
      sizeof(component_type##_t))

#define COMPONENT_INTERFACE(name)       \
  name##_t* make_##name();              \
  void destroy_##name(name##_t* name);  \
  void init_##name(name##_t* name);     \
  void register_##name(name##_t* name); \
  size_t format_##name(char* str, size_t n, const name##_t* name);

#define SELECT(component, pin) &(component)->observable, &(component)->pin

void register_observable(struct observable* observable, int* pin0,
                         size_t pin_count, const char* type_name,
                         const char* decl_name, format_t formatter,
                         size_t size);

void unregister_observable(struct observable* observable);

bool digest(void);
bool apply(void);

void connect(struct observable* observable1, int* pin1,
             struct observable* observable2, int* pin2);

void append_callback_chain(struct observable* observable, int* pin,
                           struct pin_callback_chain next);
#endif