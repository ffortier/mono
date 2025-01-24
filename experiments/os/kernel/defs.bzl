load("@rules_cc//cc:defs.bzl", _cc_binary = "cc_binary", _cc_library = "cc_library")

def _cc_binary_impl(name, **kwargs):
    native.config_setting(
        name = "%s_kernel" % name,
        constraint_values = [
            "@platforms//os:none",
            "@platforms//cpu:i386",
        ],
    )

    _cc_binary(
        name = name,
        additional_linker_inputs = (kwargs.pop("additional_linker_inputs") or []) + select({
            ":%s_kernel" % name: [
                "@llvm_toolchain_llvm//:bin/lld",
                "@llvm_toolchain_llvm//:bin/ld.lld",
                "//experiments/os/kernel:linker.ld",
            ],
            "//conditions:default": [],
        }),
        copts = (kwargs.pop("copts") or []) + ["-Iexperiments/os"] + select({
            ":%s_kernel" % name: [
                "--target=i386-none-elf",
                "-ffreestanding",
                "-DNOSTD",
            ],
            "//conditions:default": [],
        }),
        cxxopts = (kwargs.pop("cxxopts") or []) + select({
            ":%s_kernel" % name: ["-fno-exceptions", "-fno-rtti"],
            "//conditions:default": [],
        }),
        features = (kwargs.pop("features") or []) + select({
            ":%s_kernel" % name: [
                "-default_link_flags",
                "-default_compile_flags",
                "-macos_default_link_flags",
                "-macos_minimum_os",
            ],
            "//conditions:default": [],
        }),
        linkopts = (kwargs.pop("linkopts") or []) + select({
            ":%s_kernel" % name: [
                "--target=i386-linux-elf",
                "-nostdlib",
                "-Wl,--no-dynamic-linker",
                "-Wl,-T$(rootpath //experiments/os/kernel:linker.ld)",
                "-fuse-ld=lld",
                "-z",
                "notext",
            ],
            "//conditions:default": [],
        }),
        **kwargs
    )

def _cc_library_impl(name, **kwargs):
    native.config_setting(
        name = "%s_kernel" % name,
        constraint_values = [
            "@platforms//os:none",
            "@platforms//cpu:i386",
        ],
    )

    _cc_library(
        name = name,
        copts = (kwargs.pop("copts") or []) + ["-Iexperiments/os"] + select({
            ":%s_kernel" % name: [
                "--target=i386-none-elf",
                "-ffreestanding",
                "-DNOSTD",
            ],
            "//conditions:default": [],
        }),
        cxxopts = (kwargs.pop("cxxopts") or []) + select({
            ":%s_kernel" % name: ["-fno-exceptions", "-fno-rtti"],
            "//conditions:default": [],
        }),
        features = (kwargs.pop("features") or []) + select({
            ":%s_kernel" % name: [
                "-default_link_flags",
                "-default_compile_flags",
                "-macos_default_link_flags",
                "-macos_minimum_os",
            ],
            "//conditions:default": [],
        }),
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
