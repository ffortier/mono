load("@platforms//host:constraints.bzl", "HOST_CONSTRAINTS")

_BUILD = """
load("@bazel_skylib//rules/directory:directory.bzl", "directory")

package(default_visibility = ["//visibility:public"])

exports_files(
    glob([
        "bin/**",
        "lib/**",
        "cfg/**",
        "include/**",
        "asminc/**",
        "target/**",
    ])
)

directory(name="bin", srcs = glob(["bin/**"]))
directory(name="include", srcs = glob(["include/**"]))
directory(name="cfg", srcs = glob(["cfg/**"]))
directory(name="lib", srcs = glob(["lib/**"]))
directory(name="asminc", srcs = glob(["asminc/**"]))
directory(name="target", srcs = glob(["target/**"]))
"""

def _impl(rctx):
    """Implementation function for the cc65_sources repository rule."""

    rctx.download_and_extract(
        url = rctx.attr.urls,
        strip_prefix = rctx.attr.strip_prefix,
        sha256 = rctx.attr.sha256,
    )

    rctx.report_progress("Building cc65")

    result = rctx.execute(["make", "-j2"])

    if result.return_code != 0:
        fail("cc65 build failed:\n{}".format(result.stderr))

    rctx.file("BUILD.bazel", _BUILD)
    rctx.file("toolchain_info.bzl", "toolchain_info = struct(common_repo_name = None, constraint_values = %s)" % json.encode(HOST_CONSTRAINTS))

cc65_sources = repository_rule(
    implementation = _impl,
    attrs = dict(
        urls = attr.string_list(),
        strip_prefix = attr.string(),
        sha256 = attr.string(),
    ),
)
