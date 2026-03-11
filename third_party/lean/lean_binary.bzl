load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load(":lean_cc_library.bzl", "lean_cc_library")

def lean_binary(name, srcs, **kwargs):
    lean_cc_library(
        name = name + "_cc",
        srcs = srcs,
    )

    cc_binary(
        name = name,
        srcs = [],
        deps = [":" + name + "_cc"],
        **kwargs
    )
