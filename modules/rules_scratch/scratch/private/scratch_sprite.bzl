load(":private/providers.bzl", "ScratchExtensionInfo", "ScratchInfo")

scratch_sprite = rule(
    implementation = lambda ctx: [ScratchInfo()],
    provides = [ScratchInfo],
    attrs = dict(
        srcs = attr.label_list(allow_files = [".lsp", ".lisp"]),
        costumes = attr.label_list(allow_files = [".svg", ".png"]),
        deps = attr.label_list(providers = [ScratchInfo, ScratchExtensionInfo]),
        extensions = attr.label_list(providers = [ScratchExtensionInfo]),
    ),
)
