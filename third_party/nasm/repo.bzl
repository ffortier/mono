def _impl(rctx):
    rctx.download_and_extract(
        url = rctx.attr.urls,
        sha256 = rctx.attr.sha256,
        strip_prefix = rctx.attr.strip_prefix,
    )

    rctx.download(
        url = "https://raw.githubusercontent.com/bazelbuild/bazel-central-registry/refs/heads/main/modules/nasm/%s/overlay/BUILD.bazel" % rctx.attr.version,
        output = "BUILD.bazel",
    )

    rctx.download(
        url = "https://raw.githubusercontent.com/bazelbuild/bazel-central-registry/refs/heads/main/modules/nasm/%s/MODULE.bazel" % rctx.attr.version,
        output = "MODULE.bazel",
    )

    rctx.download(
        url = "https://raw.githubusercontent.com/bazelbuild/bazel-central-registry/refs/heads/main/modules/nasm/%s/overlay/config_linux.h" % rctx.attr.version,
        output = "config_linux.h",
    )

    rctx.download(
        url = "https://raw.githubusercontent.com/bazelbuild/bazel-central-registry/refs/heads/main/modules/nasm/%s/overlay/config_macos.h" % rctx.attr.version,
        output = "config_macos.h",
    )

# Nasm.us website is unrelyable and currently broken
nasm = repository_rule(
    implementation = _impl,
    attrs = dict(
        urls = attr.string_list(mandatory = True),
        sha256 = attr.string(mandatory = True),
        version = attr.string(mandatory = True),
        strip_prefix = attr.string(default = ""),
    ),
)
