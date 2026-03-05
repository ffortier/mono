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

_DENO_REPOS = {"deno_darwin_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.7.4/deno-aarch64-apple-darwin.zip"], "sha256": "65ccaf62b0e9ded08c02cb102d54c1c9f8249592218cb3cb038eb818a94cfbf8"}, "deno_linux_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.7.4/deno-x86_64-unknown-linux-gnu.zip"], "sha256": "aef56590931e785af10bdab2077a2a01344b620c78b7086b88ebca73962ef25d"}, "deno_linux_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.7.4/deno-aarch64-unknown-linux-gnu.zip"], "sha256": "d2b99d1c072cab6ec8ececda1a1bd5889a9ea5217fafd9a9a9f5b0e56ef5e9cd"}, "deno_windows_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.7.4/deno-x86_64-pc-windows-msvc.zip"], "sha256": "d2a0c8ea92ff852336a5e31293b2224fb75c22c68692c27ede5871ed88bc21fd"}}

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
