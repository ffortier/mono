#ifndef OBSERVABLE_H
#define OBSERVABLE_H

#include <stdbool.h>
#include <stddef.h>

typedef struct observable observable_t;
typedef struct visitor visitor_t;

typedef void (*visit_pin_t)(visitor_t* self, observable_t* component,
                            const char* pin_name, size_t pin_index);

typedef void (*visit_component_t)(visitor_t* self, observable_t* component);

typedef struct visitor {
  visit_pin_t visit_pin;
  visit_component_t visit_component;
} visitor_t;

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
  format_t formatter;
  visit_component_t visit_component;
  size_t size;
  int* pins;
  void* component;
} observable_t;

typedef struct observables {
  size_t capacity;
  size_t count;
  struct observable** items;
} observables_t;

#define register_component(component, component_type)           \
  register_observable(                                          \
      &(component)->observable, &(component)->pins[0],          \
      sizeof((component)->pins) / sizeof((component)->pins[0]), \
      #component_type, (format_t)format_##component_type,       \
      sizeof(component_type##_t), (visit_component_t)visit_##component_type)

#define COMPONENT_INTERFACE(name)                        \
  name##_t* make_##name();                               \
  void destroy_##name(name##_t* name);                   \
  void init_##name(name##_t* name);                      \
  void register_##name(name##_t* name);                  \
  void visit_##name(visitor_t* visitor, name##_t* name); \
  size_t format_##name(char* str, size_t n, const name##_t* name);

#define SELECT(component, pin) &(component)->observable, &(component)->pin

void register_observable(struct observable* observable, int* pin0,
                         size_t pin_count, const char* type_name,
                         format_t formatter, size_t size,
                         visit_component_t visit_component);

void unregister_observable(struct observable* observable);

bool digest(void);
bool apply(void);

void connect(struct observable* observable1, int* pin1,
             struct observable* observable2, int* pin2);

void append_callback_chain(struct observable* observable, int* pin,
                           struct pin_callback_chain next);

void visit_pin(visitor_t* visitor, observable_t* component,
               const char* pin_name, size_t pin_index);

void visit_component(visitor_t* visitor, observable_t* component);

void visit_children(visitor_t* visitor, observable_t* component);

#endif