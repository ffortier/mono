_SCRIPT = """#!/usr/bin/env bash
DENO="$PWD"/{deno}
cd {pkg} && "$DENO" run --cached-only --vendor {main} || exit 1
"""

def _impl(ctx):
    vendor = ctx.actions.declare_symlink("vendor")

    ctx.actions.symlink(
        output = vendor,
        target_path = ("../" * (len(ctx.label.package.split("/")) + 1)) + ctx.attr.vendor.label.repo_name + "/vendor",
    )

    deno_info = ctx.toolchains["//third_party/deno:toolchain_type"]
    runner = ctx.actions.declare_file(ctx.label.name + ".exe")

    if ctx.attr.compile:
        args = ctx.actions.args()

        args.add(deno_info.default.files_to_run.executable.short_path)
        args.add("compile")
        args.add("--output")
        args.add(runner)
        args.add("--cached-only")
        args.add("--vendor")
        args.add(ctx.attr.main)

        ctx.actions.run_shell(
            command = "cd %s && \"$@\"" % ctx.label.package,
            inputs = [vendor] + ctx.files.srcs + ctx.files.vendor,
            outputs = [runner],
            arguments = [args],
            tools = [deno_info.default.files_to_run.executable],
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
        ),
        is_executable = True,
    )

    return [
        DefaultInfo(
            files = depset([runner]),
            executable = runner,
            runfiles = ctx.runfiles(files = [vendor, deno_info.default.files_to_run.executable] + ctx.files.srcs + ctx.files.vendor),
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
