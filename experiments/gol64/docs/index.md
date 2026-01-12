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

The `update_cells()` function handles edge cases explicitly to avoid boundary checks in the main loop. The 40×25 grid is processed in segments:

- Top/bottom row edges (x=0, x=39)
- Left/right column edges (y=0, y=24)
- Interior bulk processing (optimized inner loop)

Neighbor counts are accumulated in a separate buffer, then cells are updated in a single pass using Game of Life rules (survive: 2-3 neighbors, birth: 3 neighbors).

## Building

Built with Bazel using cc65 for C64/sim65 and clang for WebAssembly:

```bash
bazel build //experiments/gol64:c64      # C64 executable
bazel build //experiments/gol64:sim6502  # Profiling build
bazel build //experiments/gol64:wasm     # Browser build
```