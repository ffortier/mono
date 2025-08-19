load("@rules_cc//cc/toolchains:args.bzl", "cc_args")
load("@rules_cc//cc/toolchains:tool.bzl", "cc_tool")
load("@rules_cc//cc/toolchains:tool_map.bzl", "cc_tool_map")
load("@rules_cc//cc/toolchains:toolchain.bzl", "cc_toolchain")

def cc65_toolchain(*, name, repo_name, exec_compatible_with, **kwargs):
    cc_tool(
        name = "%s_cc65" % name,
        src = "@toolchains_cc65//toolchains/tools:cc65_wrapper",
        data = [
            "@%s//:include" % repo_name,
            "@%s//:cfg" % repo_name,
            "@%s//:target" % repo_name,
            "@%s//:bin/cc65" % repo_name,
            "@%s//:bin/ca65" % repo_name,
        ],
        allowlist_include_directories = [
            "@%s//:include" % repo_name,
        ],
    )

    cc_tool(
        name = "%s_ca65" % name,
        src = "@%s//:bin/ca65" % repo_name,
        data = [
            "@%s//:asminc" % repo_name,
            "@%s//:cfg" % repo_name,
            "@%s//:target" % repo_name,
        ],
    )

    cc_tool(
        name = "%s_ld65" % name,
        src = "@%s//:bin/ld65" % repo_name,
        data = [
            "@%s//:lib" % repo_name,
            "@%s//:cfg" % repo_name,
            "@%s//:target" % repo_name,
        ],
    )

    cc_tool(
        name = "%s_ar65" % name,
        src = "@%s//:bin/ar65" % repo_name,
    )

    cc_tool_map(
        name = "%s_tool_map" % name,
        tags = ["manual"],
        tools = {
            "@rules_cc//cc/toolchains/actions:ar_actions": ":%s_ar65" % name,
            "@rules_cc//cc/toolchains/actions:assembly_actions": ":%s_ca65" % name,
            "@rules_cc//cc/toolchains/actions:c_compile": ":%s_cc65" % name,
            "@rules_cc//cc/toolchains/actions:link_actions": ":%s_ld65" % name,
        },
    )

    cc_args(
        name = "%s_compiler_backend" % name,
        actions = [
            "@rules_cc//cc/toolchains/actions:compile_actions",
        ],
        args = [
            "--compiler-backend",
            "external/{repo_name}/bin/cc65".format(repo_name = native.package_relative_label("@%s" % repo_name).repo_name),
        ],
    )

    cc_args(
        name = "%s_assembler_backend" % name,
        actions = [
            "@rules_cc//cc/toolchains/actions:compile_actions",
        ],
        args = [
            "--assembler-backend",
            "external/{repo_name}/bin/ca65".format(repo_name = native.package_relative_label("@%s" % repo_name).repo_name),
        ],
    )

    cc_toolchain(
        name = "%s_cc_toolchain" % name,
        enabled_features = [
            "@toolchains_cc65//toolchains/args",
            "@rules_cc//cc/toolchains/features/legacy:build_interface_libraries",
            "@rules_cc//cc/toolchains/features/legacy:compiler_output_flags",
            "@rules_cc//cc/toolchains/features/legacy:dynamic_library_linker_tool",
            "@rules_cc//cc/toolchains/features/legacy:fission_support",
            "@rules_cc//cc/toolchains/features/legacy:legacy_compile_flags",
            "@rules_cc//cc/toolchains/features/legacy:legacy_link_flags",
            "@rules_cc//cc/toolchains/features/legacy:library_search_directories",
            "@rules_cc//cc/toolchains/features/legacy:linkstamps",
            "@rules_cc//cc/toolchains/features/legacy:output_execpath_flags",
            "@rules_cc//cc/toolchains/features/legacy:strip_debug_symbols",
            "@rules_cc//cc/toolchains/features/legacy:unfiltered_compile_flags",
            "@rules_cc//cc/toolchains/features/legacy:user_compile_flags",
            "@rules_cc//cc/toolchains/features/legacy:user_link_flags",
            "@rules_cc//cc/toolchains/args/archiver_flags:feature",
            "@rules_cc//cc/toolchains/args/linker_param_file:feature",
            "@rules_cc//cc/toolchains/args/preprocessor_defines:feature",
            "@rules_cc//cc/toolchains/args/runtime_library_search_directories:feature",
            "@rules_cc//cc/toolchains/args/shared_flag:feature",
            "@rules_cc//cc/toolchains/args/link_flags:feature",
        ],
        known_features = [
            "@toolchains_cc65//toolchains/args",
            # Unsupported features
            "@rules_cc//cc/toolchains/args/random_seed:feature",
        ],
        tags = ["manual"],
        args = [
            ":%s_compiler_backend" % name,
            ":%s_assembler_backend" % name,
        ],
        tool_map = ":%s_tool_map" % name,
    )

    native.toolchain(
        name = name,
        exec_compatible_with = exec_compatible_with,
        target_compatible_with = ["@toolchains_cc65//platforms/compiler:cc65"],
        toolchain = ":%s_cc_toolchain" % name,
        toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
        **kwargs
    )
