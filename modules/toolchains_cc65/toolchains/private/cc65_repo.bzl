_BUILD = """
load("@toolchains_cc65//toolchains:cc65_toolchain.bzl", "cc65_toolchain")

alias(
    name = "cc65",
    actual = select({
        "//conditions:default": ":cc65_sources_cc65",
        ":windows_x86_64": ":cc65_windows_x86_64_cc65",
        ":linux_x86_64": ":cc65_linux_x86_64_cc65",
    }),
    visibility = ["//visibility:public"],
)

alias(
    name = "ca65",
    actual = select({
        "//conditions:default": ":cc65_sources_ca65",
        ":windows_x86_64": ":cc65_windows_x86_64_ca65",
        ":linux_x86_64": ":cc65_linux_x86_64_ca65",
    }),
    visibility = ["//visibility:public"],
)

alias(
    name = "ar65",
    actual = select({
        "//conditions:default": ":cc65_sources_ar65",
        ":windows_x86_64": ":cc65_windows_x86_64_ar65",
        ":linux_x86_64": ":cc65_linux_x86_64_ar65",
    }),
    visibility = ["//visibility:public"],
)

alias(
    name = "ld65",
    actual = select({
        "//conditions:default": ":cc65_sources_ld65",
        ":windows_x86_64": ":cc65_windows_x86_64_ld65",
        ":linux_x86_64": ":cc65_linux_x86_64_ld65",
    }),
    visibility = ["//visibility:public"],
)

alias(
    name = "sim65",
    actual = select({
        "//conditions:default": ":cc65_sources_sim65",
        ":windows_x86_64": ":cc65_windows_x86_64_sim65",
        ":linux_x86_64": ":cc65_linux_x86_64_sim65",
    }),
    visibility = ["//visibility:public"],
)

config_setting(
    name = "windows_x86_64",
    constraint_values = [
        "@platforms//os:windows",
        "@platforms//cpu:x86_64",
    ],
)

config_setting(
    name = "linux_x86_64",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
)
"""

_BUILD_TOOLCHAIN = """
load("@{repo_name}//:toolchain_info.bzl", {repo_name}_info = "toolchain_info")

cc65_toolchain(
    name = "{repo_name}",
    repo_name = "{repo_name}",
    exec_compatible_with = {repo_name}_info.constraint_values,
)
"""

def _impl(rctx):
    rctx.file("BUILD.bazel", _BUILD + "\n".join([
        _BUILD_TOOLCHAIN.format(repo_name = repo_name)
        for repo_name in rctx.attr.toolchain_repos
    ]))

cc65_repo = repository_rule(
    implementation = _impl,
    attrs = dict(
        toolchain_repos = attr.string_list(),
    ),
)
