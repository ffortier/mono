_EXEC_CONTENT = """#!/usr/bin/env bash
{prolog} {options} {files}
"""

def _impl(ctx):
    prolog = ctx.toolchains["@rules_prolog//:toolchain_type"].prolog

    exec = ctx.actions.declare_file(ctx.label.name)

    options = []

    if ctx.attr.goal:
        options.append("-g")
        options.append(ctx.attr.goal)

    ctx.actions.write(
        output = exec,
        is_executable = True,
        content = _EXEC_CONTENT.format(
            prolog = prolog.tool[DefaultInfo].files_to_run.executable.short_path,
            files = " ".join([f.short_path for f in ctx.files.srcs]),
            options = " ".join(options),
        ),
    )

    return [
        DefaultInfo(
            files = depset([exec]),
            runfiles = ctx.runfiles(ctx.files.srcs + ctx.files.data).merge(prolog.tool[DefaultInfo].default_runfiles),
            executable = exec,
        ),
    ]

prolog_binary = rule(
    implementation = _impl,
    toolchains = ["@rules_prolog//:toolchain_type"],
    attrs = dict(
        srcs = attr.label_list(allow_files = [".pl"], mandatory = True),
        data = attr.label_list(allow_files = True),
        goal = attr.string(),
    ),
    executable = True,
)
