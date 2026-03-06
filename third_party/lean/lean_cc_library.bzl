load("@rules_cc//cc:cc_library.bzl", "cc_library")

def lean_cc_library(name, srcs, **kwargs):
    native.genrule(
        name = name + "_source",
        srcs = srcs,
        outs = [s + ".c" for s in srcs],
        # TODO: Lean don't like symlinks. When building the actual rules, we will need to create a proper source root with hardlinks or copies.
        cmd = "mkdir $(RULEDIR)/src && cp $(SRCS) $(RULEDIR)/src && $(LEAN) -c $@ $(RULEDIR)/src/*",
        toolchains = ["//third_party/lean:resolved"],
    )

    cc_library(
        name = name,
        srcs = [":" + name + "_source"],
        deps = select({
            "@platforms//os:macos": ["@lean_darwin_aarch64//:leanrt"],
            "@platforms//os:linux": ["@lean_linux_aarch64//:leanrt"],
        }),
        **kwargs
    )
