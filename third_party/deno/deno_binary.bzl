load("@bazel_skylib//rules:native_binary.bzl", "native_binary")

def _impl(name, srcs, main = None, allow = [], **kwargs):
    native_binary(
        name = name,
        src = "//third_party/deno:resolved",
        data = srcs,
        args = ["--allow-%s" % item for item in allow] + [main],
        **kwargs
    )

deno_binary = macro(
    implementation = _impl,
    inherit_attrs = "common",
    attrs = dict(
        srcs = attr.label_list(),
        main = attr.string(configurable = False, mandatory = True),
        allow = attr.string_list(configurable = False),
    ),
)
