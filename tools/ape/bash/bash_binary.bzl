_SCRIPT = """
if [[ -f "{bash}" ]]; then
    {bash} {runtime_args} {files} "$@" || exit 1
else
    {files}.runfiles/_main/{bash} {runtime_args} {files} "$@" || exit 1
fi  
"""

def _impl(ctx):
    executable = ctx.actions.declare_file(ctx.label.name)

    if len(ctx.files.srcs) != 1:
        fail("Exactly one entry script is required; got %d" % len(ctx.files.srcs))

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
        transitive_files = depset(ctx.files.data, transitive = [bash_info.default.files]),
    ))

bash_binary = rule(
    implementation = _impl,
    toolchains = [":type"],
    attrs = dict(
        srcs = attr.label_list(allow_files = True, mandatory = True),
        data = attr.label_list(allow_files = True),
        runtime_args = attr.string_list(),
    ),
    executable = True,
)

bash_test = rule(
    implementation = _impl,
    toolchains = [":type"],
    attrs = dict(
        srcs = attr.label_list(allow_files = True, mandatory = True),
        data = attr.label_list(allow_files = True),
        runtime_args = attr.string_list(),
    ),
    test = True,
)
