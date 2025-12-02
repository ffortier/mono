_MOCK_TOOLCHAIN = """
load(":cc.bzl", "cc_toolchain_config")

package(default_visibility = ["//visibility:public"])

filegroup(name = "empty")

cc_toolchain_config(name = "linux_x86_64_toolchain_config")

cc_toolchain(
    name = "cc-clang-x86_64-linux",
    toolchain_identifier = "cc-clang-x86_64-linux",
    toolchain_config = ":linux_x86_64_toolchain_config",
    all_files = ":empty",
    compiler_files = ":empty",
    dwp_files = ":empty",
    linker_files = ":empty",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 0,
)

toolchain(
    name = "cc-mock-toolchain",
    toolchain = ":cc-clang-x86_64-linux",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)
"""

_MOCK_TOOLCHAIN_CONFIG = """
def _impl(ctx):
    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        toolchain_identifier = "k8-toolchain",
        host_system_name = "local",
        target_system_name = "local",
        target_cpu = "k8",
        target_libc = "unknown",
        compiler = "clang",
        abi_version = "unknown",
        abi_libc_version = "unknown",
    )

cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {},
    provides = [CcToolchainConfigInfo],
)
"""

_mock_toolchain = repository_rule(
    implementation = lambda rctx: [
        rctx.file("BUILD", _MOCK_TOOLCHAIN, executable = False),
        rctx.file("cc.bzl", _MOCK_TOOLCHAIN_CONFIG, executable = False),
    ],
)

_MOCK_TOOLS = """
load("@bazel_skylib//rules:write_file.bzl", "write_file")

package(default_visibility = ["//visibility:public"])

write_file(
    name = "objcopy",
    is_executable = True,
    out = "objcopy.sh",
    content = ["exit 69"],
)

write_file(
    name = "bin/lld",
    is_executable = True,
    out = "bin/lld.sh",
    content = ["exit 69"],
)

write_file(
    name = "bin/clangd",
    is_executable = True,
    out = "bin/clangd.sh",
    content = ["exit 69"],
)

write_file(
    name = "bin/ld.lld",
    is_executable = True,
    out = "bin/ld.lld.sh",
    content = ["exit 69"],
)
"""

_mock_tools = repository_rule(
    implementation = lambda rctx: rctx.file("BUILD", _MOCK_TOOLS, executable = False),
)

def _impl(mctx):
    for toolchain in mctx.modules[0].tags.toolchain:
        _mock_toolchain(name = toolchain.name)
        _mock_tools(name = toolchain.name + "_llvm")

llvm = module_extension(
    implementation = _impl,
    tag_classes = dict(
        toolchain = tag_class(
            attrs = dict(
                name = attr.string(default = "llvm_toolchain"),
                exec_os = attr.string(),
                exec_arch = attr.string(),
                distribution = attr.string(),
                llvm_version = attr.string(),
                stdlib = attr.string_dict(),
                cxx_standard = attr.string_dict(),
                compile_flags = attr.string_list_dict(),
            ),
        ),
        sysroot = tag_class(
            attrs = dict(
                name = attr.string(),
                label = attr.string(),
                targets = attr.string_list(),
            ),
        ),
    ),
)
