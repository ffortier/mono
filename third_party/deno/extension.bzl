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

_DENO_REPOS = {"deno_darwin_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.4.1/deno-aarch64-apple-darwin.zip"], "sha256": "8324369bd7d246989a83f62ce197678fdd70f7560bc5df0d9b13362416dd3cd8"}, "deno_linux_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.4.1/deno-x86_64-unknown-linux-gnu.zip"], "sha256": "9cd61b07ddd4956aa1ca5b4a0d7f3a404da8e5fd6228d22e1a6486aafcc081a9"}, "deno_linux_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.4.1/deno-aarch64-unknown-linux-gnu.zip"], "sha256": "238d963c41db789b0c871d58ebb4b4f84c042300e162392477071bca1355e5ac"}, "deno_windows_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.4.1/deno-x86_64-pc-windows-msvc.zip"], "sha256": "34b67ef8dfd0e9a0ad06c73b2e22647d5164543e68a2f5fd0673376d8295421b"}}

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
