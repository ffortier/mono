_EXEC_CONTENT = """#!/usr/bin/env bash
{prolog} {main}
"""

def _impl(ctx):
    prolog = ctx.toolchains["@rules_prolog//:toolchain_type"].prolog

    exec = ctx.actions.declare_file(ctx.label.name)

    ctx.actions.write(
        output = exec,
        is_executable = True,
        content = _EXEC_CONTENT.format(
            prolog = prolog.tool[DefaultInfo].files_to_run.executable.short_path,
            main = ctx.file.main.short_path,
        ),
    )

    return [
        DefaultInfo(
            files = depset([exec]),
            runfiles = ctx.runfiles([ctx.file.main]).merge(prolog.tool[DefaultInfo].default_runfiles),
            executable = exec,
        ),
    ]

prolog_binary = rule(
    implementation = _impl,
    toolchains = ["@rules_prolog//:toolchain_type"],
    attrs = dict(
        main = attr.label(allow_single_file = [".pl"], mandatory = True),
    ),
    executable = True,
)
