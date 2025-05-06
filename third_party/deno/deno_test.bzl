_SCRIPT = """#!/usr/bin/env bash
DENO="$PWD"/{deno}
cd {pkg} && "$DENO" test --cached-only --vendor --config {config} {main} || exit 1
"""

def _impl(ctx):
    deno_info = ctx.toolchains["//third_party/deno:toolchain_type"]
    runner = ctx.actions.declare_file(ctx.label.name + ".sh")

    ctx.actions.write(
        output = runner,
        content = _SCRIPT.format(
            pkg = ctx.label.package,
            deno = deno_info.default.files_to_run.executable.short_path,
            main = ctx.attr.main,
            config = ("../" * (len(ctx.label.package.split("/")) + 1)) + ctx.attr.vendor.label.repo_name + "/deno.json",
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

deno_test = rule(
    implementation = _impl,
    attrs = dict(
        srcs = attr.label_list(allow_files = True),
        main = attr.string(),
        allow = attr.string_list(),
        vendor = attr.label(default = "@deno", allow_files = True),
    ),
    toolchains = ["//third_party/deno:toolchain_type"],
    test = True,
)
