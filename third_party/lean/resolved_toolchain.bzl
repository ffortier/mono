def _impl(ctx):
    toolchain = ctx.toolchains["//third_party/lean:toolchain_type"]

    return [
        platform_common.TemplateVariableInfo({
            "LEAN": toolchain.tools.lean.path,
            "LEANC": toolchain.tools.leanc.path,
            "LEANCHECKER": toolchain.tools.leanchecker.path,
        }),
        DefaultInfo(files = depset([toolchain.tools.lean, toolchain.tools.leanc, toolchain.tools.leanchecker])),
    ]

resolved_toolchain = rule(
    implementation = _impl,
    toolchains = ["//third_party/lean:toolchain_type"],
)
