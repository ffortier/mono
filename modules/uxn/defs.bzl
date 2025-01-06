def _impl(ctx):
    toolchain = ctx.toolchains["@uxn//:toolchain_type"]
    out = ctx.actions.declare_file(ctx.label.name + ".rom") if not ctx.outputs.out else ctx.outputs.out

    args = ctx.actions.args()

    args.add_all(ctx.files.srcs)
    args.add(out)

    ctx.actions.run(
        executable = toolchain.assembler,
        inputs = ctx.files.srcs,
        outputs = [out],
        arguments = [args],
    )

    return [
        DefaultInfo(
            executable = out,
        ),
    ]

uxn_binary = rule(
    implementation = _impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".tal"],
            mandatory = True,
            allow_empty = False,
        ),
        "out": attr.output(),
    },
    executable = True,
    toolchains = [":toolchain_type"],
)

def uxn5_format_js(name, rom, out):
    native.genrule(
        name = name,
        srcs = [rom],
        outs = [out],
        cmd = "$(execpath @uxn5//:format_js) $< > $@",
        tools = ["@uxn5//:format_js"],
    )
