load(":private/providers.bzl", "ScratchInfo")

def _impl(ctx):
    sb3_file = ctx.actions.declare_file(ctx.label.name + ".sb3")

    ctx.actions.write(output = sb3_file, content = "echo 'hello'", is_executable = True)

    return [DefaultInfo(executable = sb3_file)]

scratch_binary = rule(
    implementation = _impl,
    executable = True,
    attrs = dict(
        deps = attr.label_list(providers = [ScratchInfo]),
    ),
)
