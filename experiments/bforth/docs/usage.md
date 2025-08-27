# Usage

## Running the Interpreter

You can run the interpreter interactively or pass a Forth file as input.

```
bazel run //experiments/bforth:bforth
./bforth.sh myscript.f
```

## REPL Features
- Command history
- Stack inspection with `.s`
- Immediate feedback and error reporting

## Defining Words
```
: square dup * ;
5 square . \ prints 25
```

## Comments
Use `( ... )` for comments:
```
( this is a comment )
```
