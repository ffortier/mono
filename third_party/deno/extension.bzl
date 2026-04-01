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

_DENO_REPOS = {"deno_darwin_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.7.11/deno-aarch64-apple-darwin.zip"], "sha256": "2da6fd51ad6af3b8711ff327b448b76b1dc8ee75678842aff637b6827205d8bd"}, "deno_linux_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.7.11/deno-x86_64-unknown-linux-gnu.zip"], "sha256": "16990cd4f3728b82b0f1432b233214fe793a0e03c27d77a2ee89f27b3e984097"}, "deno_linux_aarch64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.7.11/deno-aarch64-unknown-linux-gnu.zip"], "sha256": "1c9024937e711d17c20bc0fd510147aba6d5315ed6cfbe0fa0e6d3cee8a681b7"}, "deno_windows_x86_64": {"urls": ["https://github.com/denoland/deno/releases/download/v2.7.11/deno-x86_64-pc-windows-msvc.zip"], "sha256": "8bd617ed5d999115eaa249edba493ab313afb32be94fcb2c71db1828a8376eb8"}}

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
