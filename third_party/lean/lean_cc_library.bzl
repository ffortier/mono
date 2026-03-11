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

    native.config_setting(
        name = name + "_linux_x86_64",
        constraint_values = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
    )

    native.config_setting(
        name = name + "_linux_aarch64",
        constraint_values = [
            "@platforms//os:linux",
            "@platforms//cpu:aarch64",
        ],
    )

    cc_library(
        name = name,
        srcs = [":" + name + "_source"],
        deps = select({
            "@platforms//os:macos": ["@lean_darwin_aarch64//:leanrt"],
            ":%s_linux_x86_64" % name: ["@lean_linux_x86_64//:leanrt"],
            ":%s_linux_aarch64" % name: ["@lean_linux_aarch64//:leanrt"],
        }),
        **kwargs
    )
