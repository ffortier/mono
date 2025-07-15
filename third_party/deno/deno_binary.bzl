_SCRIPT = """#!/usr/bin/env bash
DENO="$PWD"/{deno}
cd {pkg} && "$DENO" run --cached-only --vendor {allow} {main} || exit 1
"""

def _impl(ctx):
    deno_info = ctx.toolchains["//third_party/deno:toolchain_type"]
    runner = ctx.actions.declare_file(ctx.label.name + ".exe")

    if ctx.attr.compile:
        args = ctx.actions.args()

        args.add("compile")
        args.add("--output")
        args.add(runner)
        args.add("--cached-only")
        args.add("--vendor")
        args.add("--config")
        args.add(ctx.attr.vendor.label.workspace_root + "/deno.json")
        args.add(ctx.label.package + "/" + ctx.attr.main)

        ctx.actions.run(
            executable = deno_info.default.files_to_run.executable,
            inputs = ctx.files.srcs + ctx.files.vendor,
            outputs = [runner],
            arguments = [args],
        )

        return [
            DefaultInfo(
                files = depset([runner]),
                executable = runner,
            ),
        ]

    ctx.actions.write(
        output = runner,
        content = _SCRIPT.format(
            pkg = ctx.label.package,
            deno = deno_info.default.files_to_run.executable.short_path,
            main = ctx.attr.main,
            allow = " ".join(["--allow-%s" % allow for allow in ctx.attr.allow]),
        ),
        is_executable = True,
    )

    return [
        DefaultInfo(
            files = depset([runner]),
            executable = runner,
            runfiles = ctx.runfiles(files = [deno_info.default.files_to_run.executable] + ctx.files.srcs + ctx.files.vendor),
        ),
    ]

deno_binary = rule(
    implementation = _impl,
    attrs = dict(
        srcs = attr.label_list(allow_files = True),
        main = attr.string(),
        allow = attr.string_list(),
        vendor = attr.label(default = "@deno", allow_files = True),
        compile = attr.bool(default = False),
    ),
    toolchains = ["//third_party/deno:toolchain_type"],
    executable = True,
)
