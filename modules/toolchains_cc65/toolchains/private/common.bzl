# Stolen from https://github.com/bazel-contrib/toolchains_llvm/blob/master/toolchain/internal/common.bzl
def os_from_rctx(rctx):
    name = rctx.os.name
    if name == "linux":
        return "linux"
    elif name == "mac os x":
        return "darwin"
    elif name.startswith("windows"):
        return "windows"
    fail("Unsupported OS: " + name)

def arch_from_rctx(rctx):
    arch = rctx.os.arch
    if arch == "arm64":
        return "aarch64"
    if arch == "amd64":
        return "x86_64"
    return arch

def os_bzl(os):
    return {"darwin": "osx", "linux": "linux", "windows": "windows"}[os]
