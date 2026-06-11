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

_DENO_REPOS = {"deno_darwin_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.8.3/deno-aarch64-apple-darwin.zip"], "sha256": "88b350be928fdba0e5d8142ff7c101a17133426371e3cf5ed0e0f74e62476f6c"}, "deno_linux_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.8.3/deno-x86_64-unknown-linux-gnu.zip"], "sha256": "30455b845ffa6082209c3590269c910ad3b7efdf28c9879afd4006c47ae54197"}, "deno_linux_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.8.3/deno-aarch64-unknown-linux-gnu.zip"], "sha256": "d4589cc1ffcbf1995c92a0127d932aaf832ac70cfdcc6d5b7bf38043cf303575"}, "deno_windows_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.8.3/deno-x86_64-pc-windows-msvc.zip"], "sha256": "7fdd1f42e6b0855421ecf27bb406e2492ade1087c85e30ebf0deab6280ea743c"}}

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
