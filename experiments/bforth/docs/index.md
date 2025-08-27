# Bash Forth

A minimal, interactive Forth interpreter written in pure Bash.

- **Author:** Francis Fortier
- **Features:** Stack operations, arithmetic, variables, user-defined words, control flow, loops, REPL, and more.

## Quick Start

```sh
bazel run //experiments/bforth:bforth
```

Or run the script directly:

```sh
./bforth.sh
```

## Example

```
2 3 + . \ prints 5
: square dup * ;
4 square . \ prints 16
```
