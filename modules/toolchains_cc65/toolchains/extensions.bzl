load("@toolchains_cc65//toolchains/private:cc65_binaries.bzl", "cc65_binaries")
load("@toolchains_cc65//toolchains/private:cc65_common.bzl", "cc65_common")
load("@toolchains_cc65//toolchains/private:cc65_repo.bzl", "cc65_repo")
load("@toolchains_cc65//toolchains/private:cc65_sources.bzl", "cc65_sources")

_bootstrap_from_sources = tag_class(
    attrs = dict(
        urls = attr.string_list(),
        sha256 = attr.string(default = ""),
        strip_prefix = attr.string(default = ""),
    ),
)

_common_snapshot = tag_class(
    attrs = dict(
        urls = attr.string_list(),
        sha256 = attr.string(default = ""),
        strip_prefix = attr.string(default = ""),
    ),
)

_binary_snapshot = tag_class(
    attrs = dict(
        platform = attr.string(mandatory = True, values = ["linux-x86_64"]),
        urls = attr.string_list(),
        sha256 = attr.string(default = ""),
        strip_prefix = attr.string(default = ""),
    ),
)

def _is_compatible_with_host(os, arch):
    # TODO: Use same logic as toolchains_llvm
    return False

def _impl(mctx):
    if len(mctx.modules) != 1 or not mctx.modules[0].is_root:
        fail("cc65 can only be configured from the root module")

    root_module = mctx.modules[0]

    has_common = False
    has_host_binaries = False

    if len(root_module.tags.common_snapshot) == 1:
        attrs = root_module.tags.common_snapshot[0]

        cc65_common(
            name = "cc65_common",
            urls = attrs.urls,
            sha256 = attrs.sha256,
            strip_prefix = attrs.strip_prefix,
        )

        has_common = True

    toolchain_repos = []

    for attrs in root_module.tags.binary_snapshot:
        [os, arch] = attrs.platform.split("-")

        cc65_binaries(
            name = "cc65_%s_%s" % (os, arch),
            urls = attrs.urls,
            sha256 = attrs.sha256,
            strip_prefix = attrs.strip_prefix,
            exec_os = os,
            exec_arch = arch,
        )

        toolchain_repos.append("cc65_%s_%s" % (os, arch))

        if _is_compatible_with_host(os, arch):
            has_host_binaries = True

    if len(root_module.tags.bootstrap_from_sources) == 1 and (not has_common or not has_host_binaries):
        attrs = root_module.tags.bootstrap_from_sources[0]

        cc65_sources(
            name = "cc65_sources",
            urls = attrs.urls,
            sha256 = attrs.sha256,
            strip_prefix = attrs.strip_prefix,
        )

        toolchain_repos.append("cc65_sources")

    cc65_repo(
        name = "cc65",
        toolchain_repos = toolchain_repos,
    )

cc65 = module_extension(
    implementation = _impl,
    tag_classes = dict(
        bootstrap_from_sources = _bootstrap_from_sources,
        common_snapshot = _common_snapshot,
        binary_snapshot = _binary_snapshot,
    ),
)
