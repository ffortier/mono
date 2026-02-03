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

_DENO_REPOS = {"deno_darwin_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.6.8/deno-aarch64-apple-darwin.zip"], "sha256": "9dee1808ebd2c9b95710e2ffd80c756f29df0364b5d6a53df017521cc2383783"}, "deno_linux_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.6.8/deno-x86_64-unknown-linux-gnu.zip"], "sha256": "e24aa1134b220d7185fa78136886b9a2d4014f0fa16ac6bec08b0f8f623344a1"}, "deno_linux_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.6.8/deno-aarch64-unknown-linux-gnu.zip"], "sha256": "09a0a800be639986515540ddae2f2752625ed412f63d36c7152c2a72ee78c2d7"}, "deno_windows_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.6.8/deno-x86_64-pc-windows-msvc.zip"], "sha256": "febe91c13a3bd5509f77058f1376bff99c76b518046ebd46fe385bbf81b836d9"}}

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
