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

_DENO_REPOS = {"deno_darwin_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.3.6/deno-aarch64-apple-darwin.zip"], "sha256": "2d539dd5df70f0195bd51b746fd7696f74fdd401e32a4b2f51c0901ed295015e"}, "deno_linux_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.3.6/deno-x86_64-unknown-linux-gnu.zip"], "sha256": "b263e0989e5ceb169f5b91b96de6b1cf6ce4951d54b58b7ea29c6248bf075342"}, "deno_linux_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.3.6/deno-aarch64-unknown-linux-gnu.zip"], "sha256": "2f3d086d42e1be40457dd738c660f68cabe26a2a7005d3c8d53a3cb221118f61"}, "deno_windows_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.3.6/deno-x86_64-pc-windows-msvc.zip"], "sha256": "e52678586efef33bf0520b617a42d21946f7e9d2464c97ecc56c8f8316df7479"}}

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
