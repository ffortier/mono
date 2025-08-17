_BUILD = """
load("@bazel_skylib//rules/directory:directory.bzl", "directory")

package(default_visibility = ["//visibility:public"])

exports_files(
    glob(["bin/**"])
)

directory(name="bin", srcs = glob(["bin/**"]))
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
    rctx.file("toolchain_info.bzl", "toolchain_info = struct(common_repo_name = 'cc65_common', constraint_values = ['@platforms//os:{os}', '@platforms//cpu:{cpu}'])".format(
        os = rctx.attr.exec_os,
        cpu = rctx.attr.exec_arch,
    ))

cc65_binaries = repository_rule(
    implementation = _impl,
    attrs = dict(
        urls = attr.string_list(),
        sha256 = attr.string(default = ""),
        strip_prefix = attr.string(default = ""),
        exec_os = attr.string(mandatory = True),
        exec_arch = attr.string(mandatory = True),
    ),
)
