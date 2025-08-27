# Implementation Notes

- Written in Bash 4+, using associative arrays and advanced shell features.
- Lexer and parser are pure Bash, supporting comments and string literals.
- REPL uses process substitution and custom synchronization for prompt/output.
- User-defined words and variables are stored in associative arrays.
- Unit tests are written in Forth and run as part of the Bazel test suite.

## Design Choices
- Minimal external dependencies (pure Bash, no `bc`, `awk`, etc.)
- Stack and memory are Bash arrays
- Control flow and loops are implemented with token lists and recursive evaluation
