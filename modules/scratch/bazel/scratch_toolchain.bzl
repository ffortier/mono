ScratchToolchainInfo = provider("The toolchain", fields = ["compile_flags", "compiler", "launcher_script", "default_runfiles"])

def _impl(ctx):
    return [platform_common.ToolchainInfo(
        scratch_info = ScratchToolchainInfo(
            compile_flags = [],
            compiler = ctx.executable.compiler,
            launcher_script = "echo {sb3}",
            default_runfiles = depset([]),
        ),
    )]

scratch_toolchain = rule(
    implementation = _impl,
    attrs = dict(
        compiler = attr.label(executable = True, cfg = "exec", mandatory = True),
    ),
)
