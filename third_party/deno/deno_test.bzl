load("@bazel_skylib//rules:native_binary.bzl", "native_test")

def _impl(name, srcs, main = None, allow = [], **kwargs):
    native_test(
        name = name,
        src = "//third_party/deno:resolved",
        data = srcs,
        args = ["test"] + ["--allow-%s" % item for item in allow] + [main],
        **kwargs
    )

deno_test = macro(
    implementation = _impl,
    inherit_attrs = "common",
    attrs = dict(
        srcs = attr.label_list(),
        main = attr.string(configurable = False, mandatory = True),
        allow = attr.string_list(configurable = False),
    ),
)
