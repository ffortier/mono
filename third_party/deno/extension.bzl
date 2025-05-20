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

_DENO_REPOS = {"deno_darwin_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.3.3/deno-aarch64-apple-darwin.zip"], "sha256": "a19aa07c960e0329fe32858d1d227f996f56c9ae89d123ac6eaa63adc52541d8"}, "deno_linux_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.3.3/deno-x86_64-unknown-linux-gnu.zip"], "sha256": "cb573ef18e06b6f17db31b7a410143abfebe0c8d1faa99cb934a7c1351c75701"}, "deno_linux_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.3.3/deno-aarch64-unknown-linux-gnu.zip"], "sha256": "5d9dc69fbf324afe62f2c03c1241ae4629fecdb6032a1ded8a907ce480077f61"}, "deno_windows_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.3.3/deno-x86_64-pc-windows-msvc.zip"], "sha256": "a40f0e4c6535834b83faaf8b09e47867ff4cbb7b12d0554bbc58e7355e9cf460"}}

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
