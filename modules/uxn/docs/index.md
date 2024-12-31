```python
load("@uxn//:defs.bzl", "uxn_binary")

uxn_binary(
    name = "hello",
    srcs = ["hello.tal"],
    out = "hello.rom",
)
```

```shell
bazel run @uxn//examples:gol --run_under=@uxn//juxn
bazel run @uxn//examples:hello --run_under @uxn//:uxncli
```