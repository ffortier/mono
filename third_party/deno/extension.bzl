_BUILD = 'filegroup(name = "{repo_name}", srcs = glob(["**"]), visibility = ["//visibility:public"])'

def _arch_from_rctx(rctx):
    arch = rctx.os.arch
    if arch == "arm64":
        return "aarch64"
    if arch == "amd64":
        return "x86_64"
    return arch

def _os_from_rctx(rctx):
    name = rctx.os.name
    if name == "linux":
        return "linux"
    elif name == "mac os x":
        return "darwin"
    elif name.startswith("windows"):
        return "windows"
    fail("Unsupported OS: " + name)

_DENO_REPOS = {"deno_darwin_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.3.5/deno-aarch64-apple-darwin.zip"], "sha256": "c4b97b260d534b27bd31d0dac1e7d8dd83375b08510d7889b38b734ee932bb75"}, "deno_linux_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.3.5/deno-x86_64-unknown-linux-gnu.zip"], "sha256": "096ddb8b151adb26f34ac6a8f2beb774776e4b80173824181eb2d2f81e00d111"}, "deno_linux_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.3.5/deno-aarch64-unknown-linux-gnu.zip"], "sha256": "8b5c2495aa2e8763acb6fe6f5b03feda4af31a1f2628dede1e41f82a8b950366"}, "deno_windows_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.3.5/deno-x86_64-pc-windows-msvc.zip"], "sha256": "aeebfb104074b94b0fc35a52b306be3ad4275d0f871263b74d0740e9e27e56d2"}}

def _repo_impl(rctx):
    rctx.file("BUILD", _BUILD.format(repo_name = rctx.original_name))
    rctx.template("deno.json", rctx.attr.config)
    rctx.template("deno.lock", rctx.attr.lock)
    repo = _DENO_REPOS["deno_%s_%s" % (_os_from_rctx(rctx), _arch_from_rctx(rctx))]
    rctx.download_and_extract(output = ".", url = repo["urls"], sha256 = repo["sha256"])
    res = rctx.execute(["./deno", "i", "--vendor"], environment = {"DENO_DIR": ".deno"})
    if res.return_code != 0:
        fail("Failed to run `DENO_DIR=. deno i`:\n" + res.stderr)
    rctx.delete("deno")
    rctx.delete(".deno")

_repo = repository_rule(implementation = _repo_impl, attrs = dict(lock = attr.label(mandatory = True), config = attr.label(mandatory = True)))

def _impl(mctx):
    for mod in mctx.modules:
        if len(mod.tags.install) != 1:
            fail("Expected a single install per module")
        install_tag = mod.tags.install[0]
        _repo(name = install_tag.name, lock = install_tag.lock, config = install_tag.config)

deno = module_extension(implementation = _impl, tag_classes = dict(install = tag_class(attrs = dict(name = attr.string(default = "deno"), lock = attr.label(mandatory = True), config = attr.label(mandatory = True)))))
