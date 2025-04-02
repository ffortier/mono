ScratchExtensionInfo = provider("Scratch Extension", fields = ["file", "name"])

scratch_extension = rule(
    implementation = lambda ctx: [
        ScratchExtensionInfo(
            file = ctx.file.src,
            name = ctx.attr.extension_name or ctx.label.name,
        ),
    ],
    attrs = dict(
        extension_name = attr.string(),
        src = attr.label(allow_single_file = [".json"], mandatory = True),
    ),
    provides = [ScratchExtensionInfo],
)
