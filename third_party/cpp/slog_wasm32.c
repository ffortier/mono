// #include <stdarg.h>

#include "slog.h"

#define va_start(v, l) __builtin_va_start(v, l)
#define va_end(v) __builtin_va_end(v)
#define va_arg(v, l) __builtin_va_arg(v, l)
#define va_copy(d, s) __builtin_va_copy(d, s)
typedef __builtin_va_list va_list;

__attribute__((import_module("env"), import_name("console_log"))) void
console_log(const char* msg);

__attribute__((import_module("env"), import_name("console_debug"))) void
console_debug(const char* msg);

__attribute__((import_module("env"), import_name("console_warn"))) void
console_warn(const char* msg);

__attribute__((import_module("env"), import_name("console_error"))) void
console_error(const char* msg);

slog_config_t slog_config = {0};

const char* slog_version(uint8_t nShort) { return NULL; }
void slog_config_get(slog_config_t* pCfg) {}
void slog_config_set(slog_config_t* pCfg) {}

void slog_separator_set(const char* pFormat, ...) {}
void slog_callback_set(slog_cb_t callback, void* pContext) {}
size_t slog_get_full_path(char* pFilePath, size_t nSize) { return 0; }

void slog_enable(slog_flag_t eFlag) {}
void slog_disable(slog_flag_t eFlag) {}

void slog_init(const char* pName, uint16_t nFlags, uint8_t nTdSafe) {}
void slog_display(slog_flag_t eFlag, uint8_t nNewLine, const char* pFormat,
                  ...) {
  va_list args;

  for (va_start(args, pFormat); *pFormat != '\0'; ++pFormat) {
    switch (*pFormat) {
      case 'd': {
        int i = va_arg(args, int);
        // printf("%d\n", i);
        break;
      }
      case 'c': {
        // A 'char' variable will be promoted to 'int'
        // A character literal in C is already 'int' by itself
        int c = va_arg(args, int);
        // printf("%c\n", c);
        break;
      }
      case 'f': {
        double d = va_arg(args, double);
        // printf("%f\n", d);
        break;
      }
      default:
        // puts("Unknown formatter!");
        goto END;
    }
  }
END:
  va_end(args);
}
void slog_destroy() {}
