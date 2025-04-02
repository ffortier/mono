def _map_srcs(file):
    return "%s:%s" % (file.short_path, file.path)

def _impl(ctx):
    scratch_info = ctx.toolchains["@scratch//bazel:toolchain_type"].scratch_info

    out = ctx.outputs.out if ctx.outputs.out else ctx.actions.declare_file(ctx.label.name + ".sb3")
    launcher = ctx.outputs.executable

    args = ctx.actions.args()

    args.add("compile")
    args.add_all(scratch_info.compile_flags)
    args.add("-o", out)

    for file in ctx.files.srcs:
        args.add("%s:%s" % (file.short_path.removeprefix(ctx.label.package + "/"), file.path))

    ctx.actions.run(
        executable = scratch_info.compiler,
        inputs = ctx.files.srcs,
        outputs = [out],
        arguments = [args],
    )

    ctx.actions.write(
        output = launcher,
        content = scratch_info.launcher_script.format(sb3 = out),
        is_executable = True,
    )

    return [
        DefaultInfo(
            files = depset([out]),
            executable = launcher,
            runfiles = ctx.runfiles(files = [out], transitive_files = scratch_info.default_runfiles),
        ),
    ]

scratch_binary = rule(
    implementation = _impl,
    attrs = dict(
        srcs = attr.label_list(allow_files = [".sctxt", ".png", ".svg", ".jpg"]),
        extensions = attr.label_list(default = ["@scratch//extensions:std"]),
        out = attr.output(),
    ),
    toolchains = ["@scratch//bazel:toolchain_type"],
    executable = True,
)
