def _impl(ctx):
    return [
        platform_common.ToolchainInfo(
            assembler = ctx.executable.assembler,
            cli = ctx.executable.cli,
        ),
    ]

uxn_toolchain = rule(
    implementation = _impl,
    attrs = {
        "assembler": attr.label(executable = True, mandatory = True, cfg = "exec"),
        "cli": attr.label(executable = True, mandatory = True, cfg = "exec"),
    },
)
