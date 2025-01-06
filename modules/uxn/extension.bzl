load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

_ATTRS = {
    "urls": attr.string_list(),
    "sha256": attr.string(),
    "strip_prefix": attr.string(default = ""),
}

def _impl(mctx):
    mod = mctx.modules[0]
    sources = mod.tags.sources[0]

    http_archive(
        name = "uxn_sources",
        urls = sources.urls,
        strip_prefix = sources.strip_prefix,
        sha256 = sources.sha256,
        build_file = ":BUILD.uxn.bazel",
    )

uxn = module_extension(
    implementation = _impl,
    tag_classes = {
        "sources": tag_class(attrs = _ATTRS),
    },
)
