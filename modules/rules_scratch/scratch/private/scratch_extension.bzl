load(":private/providers.bzl", "ScratchExtensionInfo")

scratch_extension = rule(
    implementation = lambda ctx: [
        ScratchExtensionInfo(
            name = ctx.attr.extension_name if ctx.attr.extension_name else ctx.label.name,
        ),
        DefaultInfo(files = depset(ctx.files.srcs)),
    ],
    provides = [ScratchExtensionInfo, DefaultInfo],
    attrs = dict(
        extension_name = attr.string(),
        srcs = attr.label_list(allow_files = [".pl"]),
    ),
)
