_BUILD = """
load("@toolchains_cc65//toolchains:cc65_toolchain.bzl", "cc65_toolchain")
"""

_BUILD_TOOLCHAIN = """
load("@{repo_name}//:toolchain_info.bzl", {repo_name}_info = "toolchain_info")

cc65_toolchain(
    name = "{repo_name}", 
    repo_name = "{repo_name}", 
    common_repo_name = {repo_name}_info.common_repo_name, 
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
