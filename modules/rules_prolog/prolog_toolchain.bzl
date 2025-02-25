PrologInfo = provider("Prolog", fields = ["tool"])

def _impl(ctx):
    return [
        platform_common.ToolchainInfo(
            prolog = PrologInfo(
                tool = ctx.attr.tool,
            ),
        ),
    ]

prolog_toolchain = rule(
    implementation = _impl,
    attrs = dict(
        tool = attr.label(executable = True, cfg = "exec", mandatory = True),
    ),
)
