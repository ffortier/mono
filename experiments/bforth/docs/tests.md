# Tests

Unit tests are written in Forth and run automatically with Bazel:

```
bazel test //experiments/bforth:all
```

## Example Test
```
2 3 + 5 asserteq
: square dup * ;
4 square 16 asserteq
assertempty
```

- `asserteq` checks equality
- `assertempty` ensures the stack is empty after the test

See `bforth_test.f` for the full test suite.
