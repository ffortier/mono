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

_DENO_REPOS = {"deno_darwin_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.8.0/deno-aarch64-apple-darwin.zip"], "sha256": "dba813b8b69d6218cffb11252b9e4e6036ca2c9d79843cde367b4b369aaf9634"}, "deno_linux_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.8.0/deno-x86_64-unknown-linux-gnu.zip"], "sha256": "be2c8b53c8ca1d66be76feb9b1a524419da708b00d4ca074cf5c633c81c1627b"}, "deno_linux_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.8.0/deno-aarch64-unknown-linux-gnu.zip"], "sha256": "933a6a7d2985957271cd2085a5a5a1832398aa221a354daab5635196cf2cbbae"}, "deno_windows_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.8.0/deno-x86_64-pc-windows-msvc.zip"], "sha256": "9b98d1f456878c8ac5caa55779a04f2f1f91f8e942d6ef3f887681698f634adf"}}

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
