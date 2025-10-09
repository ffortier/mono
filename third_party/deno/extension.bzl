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

_DENO_REPOS = {"deno_darwin_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.5.4/deno-aarch64-apple-darwin.zip"], "sha256": "ff301a55e9f51306c02eb6da76ceba6ac98109fd11dbd7a1f5b71f5794ad725c"}, "deno_linux_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.5.4/deno-x86_64-unknown-linux-gnu.zip"], "sha256": "8a04bb02a1dcd56ed060e55281df4b306ca4553a0d02b53b666063f465f2193a"}, "deno_linux_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.5.4/deno-aarch64-unknown-linux-gnu.zip"], "sha256": "32a9f397221efd12e9c07534ecbf22af17d610294b9636d4151793d6b7412b29"}, "deno_windows_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.5.4/deno-x86_64-pc-windows-msvc.zip"], "sha256": "1c40c73193960fcbed9341764d43bbd35e381eddbcf7d6cba7c2f3c0cabe96fb"}}

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
