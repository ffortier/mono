_BUILD = """
load("@bazel_skylib//rules/directory:directory.bzl", "directory")

package(default_visibility = ["//visibility:public"])

exports_files(
    glob([
        "lib/**",
        "cfg/**",
        "include/**",
        "asminc/**",
        "target/**",
    ])
)

directory(name="include", srcs = glob(["include/**"]))
directory(name="cfg", srcs = glob(["cfg/**"]))
directory(name="lib", srcs = glob(["lib/**"]))
directory(name="asminc", srcs = glob(["asminc/**"]))
directory(name="target", srcs = glob(["target/**"]))
"""

def _impl(rctx):
    if not rctx.attr.urls[0].endswith(".deb"):
        fail("Expected .deb file")

    rctx.download_and_extract(
        url = rctx.attr.urls,
        sha256 = rctx.attr.sha256,
    )

    rctx.extract(
        "data.tar.xz",
        strip_prefix = rctx.attr.strip_prefix,
    )

    rctx.file("BUILD", _BUILD)

cc65_common = repository_rule(
    implementation = _impl,
    attrs = dict(
        urls = attr.string_list(),
        sha256 = attr.string(default = ""),
        strip_prefix = attr.string(default = ""),
    ),
)
