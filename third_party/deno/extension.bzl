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

_DENO_REPOS = {"deno_darwin_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.7.9/deno-aarch64-apple-darwin.zip"], "sha256": "647e44e3e9b4a905727b988f82ae33b598b7711795a68f12780ecc466c91dacd"}, "deno_linux_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.7.9/deno-x86_64-unknown-linux-gnu.zip"], "sha256": "1d7e719118120b6e9bc6e3e76624a25732970e661d740d09bb930a3bc01119ff"}, "deno_linux_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.7.9/deno-aarch64-unknown-linux-gnu.zip"], "sha256": "f8e13d1670ed0b3d955e7a218386e1b2c6b98c3eb7923d4cfa04f1bc73404ed9"}, "deno_windows_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.7.9/deno-x86_64-pc-windows-msvc.zip"], "sha256": "f2cb68a66bce2d4828429545ea7c2265b9f165e612629fc67e3dd39f13b87471"}}

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
