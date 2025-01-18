def _nasm_binary_impl(name, srcs, **kwargs):
    native.genrule(
        name = name,
        tools = ["@nasm"],
        srcs = srcs,
        outs = [name + ".bin"],
        cmd = "$(execpath @nasm) -f bin -o $@ $<",
        executable = True,
        **kwargs
    )

nasm_binary = macro(
    implementation = _nasm_binary_impl,
    attrs = dict(
        srcs = attr.label_list(allow_files = [".S", ".asm"]),
        target_compatible_with = attr.label_list(providers = [platform_common.ConstraintValueInfo], default = [
            "@platforms//os:none",
            "@platforms//cpu:i386",
        ]),
    ),
)

def _nasm_library_impl(name, srcs, **kwargs):
    native.genrule(
        name = name,
        tools = ["@nasm"],
        srcs = srcs,
        outs = [name + ".o"],
        cmd = "$(execpath @nasm) -f elf -o $@ $<",
        executable = True,
        **kwargs
    )

nasm_library = macro(
    implementation = _nasm_library_impl,
    attrs = dict(
        srcs = attr.label_list(allow_files = [".S", ".asm"]),
        target_compatible_with = attr.label_list(providers = [platform_common.ConstraintValueInfo], default = [
            "@platforms//os:none",
            "@platforms//cpu:i386",
        ]),
    ),
)
