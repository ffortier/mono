load("@platforms//host:constraints.bzl", "HOST_CONSTRAINTS")

_BUILD = """
load("@bazel_skylib//rules/directory:directory.bzl", "directory")

package(default_visibility = ["//visibility:public"])

exports_files(
    glob([
        "bin/**",
    ])
)

directory(name="bin", srcs = glob(["bin/**"]))
directory(name="include", srcs = glob(["include/**"]))
directory(name="cfg", srcs = glob(["cfg/**"]))
directory(name="asminc", srcs = glob(["asminc/**"]))
directory(name="target", srcs = glob(["target/**"]))
directory(name="lib", srcs = glob(["lib/**"]))
"""

def _impl(rctx):
    """Implementation function for the cc65_sources repository rule."""
    rctx.report_progress("Downloading cc65 sources")

    rctx.download_and_extract(
        url = rctx.attr.urls,
        strip_prefix = rctx.attr.strip_prefix,
        sha256 = rctx.attr.sha256,
        type = rctx.attr.type,
    )

    rctx.report_progress("Building cc65")

    make_path = rctx.which("make")
    if make_path == None:
        fail("cc65_sources requires 'make' in PATH on the host; consider using prebuilt binaries")

    make_targets = []

    result = rctx.execute([make_path, "-j2"] + make_targets)

    if result.return_code != 0:
        fail("cc65 build failed:\n{}".format(result.stderr))

    rctx.file("BUILD.bazel", _BUILD)

    rctx.file("toolchain_info.bzl", "toolchain_info = struct(constraint_values = %r)" % HOST_CONSTRAINTS)

    result = rctx.execute([rctx.path(rctx.attr._patch_void_arrays)])

    if result.return_code != 0:
        fail("Failed to patch void arrays: {}".format(result.stderr))

cc65_sources = repository_rule(
    implementation = _impl,
    attrs = dict(
        urls = attr.string_list(mandatory = True),
        strip_prefix = attr.string(mandatory = True),
        sha256 = attr.string(mandatory = True),
        type = attr.string(),
        _patch_void_arrays = attr.label(allow_single_file = True, default = "//toolchains/private:patch_void_arrays.py"),
    ),
)
