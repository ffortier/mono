# gol64

Conway's Game of Life optimized for the Commodore 64, with cross-compilation support for performance metrics and browser visualization.

## Overview

This implementation runs on the C64's 40×25 character display (1000 cells), using direct screen memory manipulation and zero-page optimizations for maximum performance on the 6502 processor.

## Features

- **Multi-target compilation**: C64 native, sim65 profiling, and WebAssembly
- **Performance optimized**: Zero-page pointer arithmetic and unrolled loops
- **Cycle-accurate metrics**: Uses sim65 counters to measure instruction count and clock cycles
- **Browser visualization**: WebAssembly build enables interactive web demo

## Live Demo

<gol64-canvas></gol64-canvas>

## Implementation Details

The core `update_cells()` function is implemented in 6502 assembly for maximum performance, running at approximately 5Hz on real C64 hardware.

### Algorithm Overview

The implementation follows a two-phase approach:

1. **Count Phase**: Count live neighbors for each cell in a separate buffer
2. **Render Phase**: Apply Game of Life rules and update the screen

### Edge Handling

The 40×25 grid is processed in three sections to handle boundaries efficiently:

- **First Row** (`count_first_row`): Special handling for y=0 with reduced neighbor checks
- **Middle Rows** (`count_middle_rows`): Bulk processing with full 8-neighbor checks, using self-modifying code
- **Last Row** (`count_last_row`): Special handling for y=24 with reduced neighbor checks

Each section handles the leftmost (x=0) and rightmost (x=39) columns separately from the interior cells.

### Assembly Optimizations

- **Self-modifying code**: Updates instruction operands to iterate through video memory without index overhead
- **Indirect indexed addressing**: Uses zero-page pointers (`ptr1`, `ptr2`, `ptr3`) with Y-register indexing for efficient neighbor counting
- **Macro-based code generation**: Unrolls loops and generates specialized code blocks
- **Direct video memory access**: Writes directly to `$0400` (screen memory)

The neighbor count buffer (`count_mem`) is a 1024-byte array in BSS, processed in 250-byte chunks for efficient rendering.

### Game of Life Rules

- **Survive**: Live cells with 2 or 3 neighbors stay alive
- **Birth**: Dead cells with exactly 3 neighbors become alive
- **Death**: All other cases result in dead cells

## Building

Built with Bazel using cc65 for C64/sim65 and clang for WebAssembly:

```bash
bazel build //experiments/gol64:c64      # C64 executable
bazel build //experiments/gol64:sim6502  # Profiling build
bazel build //experiments/gol64:wasm     # Browser build
```