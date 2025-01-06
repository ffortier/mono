# uxn

Rules to build [uxn](https://100r.co/site/uxn.html)

## Usage

````starlark
load("@uxn//:defs.bzl", "uxn_binary")

uxn_binary(
    name = "hello",
    srcs = ["hello.tal"],
)
``

```shell
bazel run :hello --run_under @uxn//:uxncli

# uxnemu is not currently distributed by those rules because of its dependency
# on sdl2, but it can be used to run the binary if locally available
bazel run :hello --run_under uxnemu
```
````
