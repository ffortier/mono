load("@rules_cc//cc:defs.bzl", _cc_binary = "cc_binary", _cc_library = "cc_library")

def _cc_binary_impl(name, features, copts, additional_linker_inputs, deps, linkopts, target_compatible_with, **kwargs):
    if not features:
        features = []
    if not copts:
        copts = []
    if not deps:
        deps = []
    if not additional_linker_inputs:
        additional_linker_inputs = []
    if not linkopts:
        linkopts = []
    if not target_compatible_with:
        target_compatible_with = [
            "@platforms//os:none",
            "@platforms//cpu:i386",
        ]

    additional_deps = ["//experiments/os/nostd"] if native.package_name() != "experiments/os/nostd" else []

    _cc_binary(
        name = name,
        additional_linker_inputs = additional_linker_inputs + [
            "@llvm_toolchain_llvm//:bin/lld",
            "@llvm_toolchain_llvm//:bin/ld.lld",
            "//experiments/os:linker.ld",
        ],
        copts = copts + [
            "--target=i386-none-elf",
            "-ffreestanding",
            "-Iexperiments/os",
            "-DNOSTD",
        ],
        features = features + [
            "-default_link_flags",
            "-default_compile_flags",
            "-macos_default_link_flags",
            "-macos_minimum_os",
        ],
        linkopts = linkopts + [
            "--target=i386-linux-elf",
            "-nostdlib",
            "-Wl,--no-dynamic-linker",
            "-Wl,-T$(rootpath //experiments/os:linker.ld)",
            "-fuse-ld=lld",
            "-z",
            "notext",
        ],
        deps = deps + additional_deps,
        target_compatible_with = target_compatible_with,
        **kwargs
    )

def _cc_library_impl(name, features, copts, target_compatible_with, deps, **kwargs):
    if not features:
        features = []
    if not copts:
        copts = []
    if not deps:
        deps = []
    if not target_compatible_with:
        target_compatible_with = [
            "@platforms//os:none",
            "@platforms//cpu:i386",
        ]

    additional_deps = ["//experiments/os/nostd"] if native.package_name() != "experiments/os/nostd" else []

    _cc_library(
        name = name,
        copts = copts + [
            "--target=i386-none-elf",
            "-ffreestanding",
            "-Iexperiments/os",
            "-DNOSTD",
        ],
        features = features + [
            "-default_link_flags",
            "-default_compile_flags",
            "-macos_default_link_flags",
            "-macos_minimum_os",
        ],
        deps = deps + additional_deps,
        target_compatible_with = target_compatible_with,
        **kwargs
    )

cc_binary = macro(
    implementation = _cc_binary_impl,
    inherit_attrs = native.cc_binary,
)

cc_library = macro(
    implementation = _cc_library_impl,
    inherit_attrs = native.cc_library,
)
