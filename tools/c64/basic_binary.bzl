def _impl(ctx):
    prg_file = ctx.actions.declare_file(ctx.label.name + ".prg")
    exec_file = ctx.actions.declare_file(ctx.label.name + "_exec.sh")

    petcat_args = ctx.actions.args()

    petcat_args.add("-w2")
    petcat_args.add("-o")
    petcat_args.add(prg_file)
    petcat_args.add("--")
    petcat_args.add_all(ctx.files.srcs)

    ctx.actions.run(
        inputs = ctx.files.srcs,
        outputs = [prg_file],
        executable = ctx.executable._petcat,
        arguments = [petcat_args],
    )

    ctx.actions.write(
        output = exec_file,
        content = "#!/bin/sh\nexec \"{c64upload}\" \"{prg_file}\" --run\n".format(
            c64upload = ctx.executable._c64upload.short_path,
            prg_file = prg_file.short_path,
        ),
        is_executable = True,
    )

    runfiles = ctx.runfiles(
        files = [prg_file],
    ).merge(ctx.attr._c64upload[DefaultInfo].default_runfiles)

    return [DefaultInfo(executable = exec_file, files = depset([prg_file]), runfiles = runfiles)]

basic_binary = rule(
    implementation = _impl,
    attrs = {
        "srcs": attr.label_list(allow_files = [".bas"], mandatory = True),
        "_petcat": attr.label(default = "@vice//:petcat", executable = True, cfg = "exec"),
        "_c64upload": attr.label(default = "//tools/c64:c64upload", executable = True, cfg = "exec"),
    },
    executable = True,
)
