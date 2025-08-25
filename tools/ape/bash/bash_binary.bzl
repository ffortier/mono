_SCRIPT = """
{bash} {runtime_args} {files} "$@"
"""

def _impl(ctx):
    executable = ctx.actions.declare_file(ctx.label.name)

    bash_info = ctx.toolchains[":type"]

    ctx.actions.write(
        output = executable,
        is_executable = True,
        content = _SCRIPT.format(
            bash = bash_info.executable.short_path,
            runtime_args = " ".join(ctx.attr.runtime_args),
            files = " ".join([f.short_path for f in ctx.files.srcs]),
        ),
    )

    return DefaultInfo(executable = executable, runfiles = ctx.runfiles(
        files = ctx.files.srcs,
        transitive_files = depset([data[DefaultInfo].files for data in ctx.attr.data], transitive = [bash_info.default.files]),
    ))

bash_binary = rule(
    implementation = _impl,
    toolchains = [":type"],
    attrs = dict(
        srcs = attr.label_list(allow_files = True, mandatory = True),
        data = attr.label_list(),
        runtime_args = attr.string_list(),
    ),
    executable = True,
)
