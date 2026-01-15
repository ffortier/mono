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

_DENO_REPOS = {"deno_darwin_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.6.5/deno-aarch64-apple-darwin.zip"], "sha256": "4052ba436dfbe2e9dc94cef2e113218ce6ae0f11dace651764396a5a8f69de8c"}, "deno_linux_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.6.5/deno-x86_64-unknown-linux-gnu.zip"], "sha256": "e0f109b9ae6d828512bdbfc0524779ea42d7c117efd351860589c07506803436"}, "deno_linux_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.6.5/deno-aarch64-unknown-linux-gnu.zip"], "sha256": "6613f3ccfc7e36d91b1a856d0a3d3a6d1286d09a9f0d775f99e50706e0ebc81d"}, "deno_windows_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.6.5/deno-x86_64-pc-windows-msvc.zip"], "sha256": "7838e9f0cd3c516c973745a0ad8527776d39f60f24d09d77757167652d6b70d8"}}

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
