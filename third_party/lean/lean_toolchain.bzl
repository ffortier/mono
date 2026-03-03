def _impl(ctx):
    tools = struct(
        lean = ctx.file.lean,
        leanc = ctx.file.leanc,
        leanchecker = ctx.file.leanchecker,
    )

    return [
        platform_common.ToolchainInfo(tools = tools),
    ]

lean_toolchain = rule(
    implementation = _impl,
    attrs = dict(
        lean = attr.label(mandatory = True, allow_single_file = True),
        leanc = attr.label(mandatory = True, allow_single_file = True),
        leanchecker = attr.label(mandatory = True, allow_single_file = True),
    ),
)

def default_lean_toolchain(*, name, os, arch, repo_name, toolchain_type = ":toolchain_type"):
    lean_toolchain(
        name = name + "_tools",
        lean = "@{}//:lean".format(repo_name),
        leanc = "@{}//:leanc".format(repo_name),
        leanchecker = "@{}//:leanchecker".format(repo_name),
    )

    native.toolchain(
        name = name,
        toolchain = ":{}_tools".format(name),
        toolchain_type = toolchain_type,
        target_compatible_with = [
            "@platforms//os:{}".format(os),
            "@platforms//cpu:{}".format(arch),
        ],
    )
