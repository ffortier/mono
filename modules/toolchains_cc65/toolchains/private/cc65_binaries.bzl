load("@toolchains_cc65//toolchains/private:common.bzl", "os_bzl")

_BUILD = """
load("@bazel_skylib//rules/directory:directory.bzl", "directory")

package(default_visibility = ["//visibility:public"])

exports_files(
    glob(["bin/**"])
)

directory(name="bin", srcs = glob(["bin/**"]))
directory(name="include", srcs = glob(["include/**"]))
directory(name="cfg", srcs = glob(["cfg/**"]))
directory(name="target", srcs = glob(["target/**"]))
directory(name="lib", srcs = glob(["lib/**"]))
directory(name="asminc", srcs = glob(["asminc/**"]))
"""

def _unpack_deb(rctx, urls, sha256, strip_prefix):
    rctx.download_and_extract(
        url = urls,
        sha256 = sha256,
    )

    rctx.extract(
        "data.tar.xz",
        strip_prefix = strip_prefix,
    )

def _unpack_archive(rctx, urls, sha256, strip_prefix):
    rctx.download_and_extract(
        url = urls,
        sha256 = sha256,
        strip_prefix = strip_prefix,
    )

def _unpack(rctx, urls, sha256, strip_prefix):
    if urls[0].endswith(".deb"):
        _unpack_deb(rctx, urls, sha256, strip_prefix)
    else:
        _unpack_archive(rctx, urls, sha256, strip_prefix)

def _impl(rctx):
    _unpack(rctx, rctx.attr.urls, rctx.attr.sha256, rctx.attr.strip_prefix)

    if rctx.attr.common_urls and len(rctx.attr.common_urls) > 0:
        _unpack(rctx, rctx.attr.common_urls, rctx.attr.common_sha256, rctx.attr.common_strip_prefix)

    rctx.file("BUILD.bazel", _BUILD)

    rctx.file("toolchain_info.bzl", "toolchain_info = struct(constraint_values = ['@platforms//os:{os}', '@platforms//cpu:{cpu}'])".format(
        os = os_bzl(rctx.attr.exec_os),
        cpu = rctx.attr.exec_arch,
    ))

cc65_binaries = repository_rule(
    implementation = _impl,
    attrs = dict(
        urls = attr.string_list(mandatory = True),
        sha256 = attr.string(mandatory = True),
        strip_prefix = attr.string(mandatory = True),
        exec_os = attr.string(mandatory = True),
        exec_arch = attr.string(mandatory = True),
        common_urls = attr.string_list(),
        common_sha256 = attr.string(),
        common_strip_prefix = attr.string(),
    ),
)
