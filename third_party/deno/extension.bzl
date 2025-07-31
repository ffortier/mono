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

_DENO_REPOS = {"deno_darwin_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.4.3/deno-aarch64-apple-darwin.zip"], "sha256": "fb5cc12a2001ab11cfc2240ba705c7fdda9cb58154c59d6c0ee3330e569ed328"}, "deno_linux_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.4.3/deno-x86_64-unknown-linux-gnu.zip"], "sha256": "6ac18c7d95bedce23477adaccc2beeccdab05123fd1d7488bd62dff805d42f74"}, "deno_linux_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.4.3/deno-aarch64-unknown-linux-gnu.zip"], "sha256": "93eae794e4122edd88ae5602fa3d4919d23c9ba1af0fbb3aa78fb1d6c0423116"}, "deno_windows_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.4.3/deno-x86_64-pc-windows-msvc.zip"], "sha256": "c58e3545e59d3fa9fd608a8f8e4a162eaa9fa137de3f0d4740321abec40357c9"}}

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
