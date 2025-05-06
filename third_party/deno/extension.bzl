_BUILD = """
filegroup(
    name = "{repo_name}",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)
"""

def os_from_rctx(rctx):
    name = rctx.os.name
    if name == "linux":
        return "linux"
    elif name == "mac os x":
        return "darwin"
    elif name.startswith("windows"):
        return "windows"
    fail("Unsupported OS: " + name)

_DENO_REPOS = {
    "darwin": {
        "url": "https://github.com/denoland/deno/releases/download/v2.3.1/deno-aarch64-apple-darwin.zip",
        "sha256":"e3d3d7b21ce89105d96c316e9370b1f05aa6e87687f40faf37a39a613a477014",
    },
    "linux": {
        "url":"https://github.com/denoland/deno/releases/download/v2.3.1/deno-x86_64-unknown-linux-gnu.zip",
        "sha256":"b2920265e633215959b09a32b67f46c93362842bbfd27c96e8acc2d24b66f563",
    },
}

def _repo_impl(rctx):
    rctx.file("BUILD", _BUILD.format(repo_name = rctx.original_name))

    rctx.template("deno.json", rctx.attr.config)
    rctx.template("deno.lock", rctx.attr.lock)

    # TODO: Support more os
    repo = _DENO_REPOS[os_from_rctx(rctx)]
    rctx.download_and_extract(
        output = ".",
        url = repo["url"],
        sha256 = repo["sha256"],
    )

    res = rctx.execute(
        ["./deno", "i", "--vendor"],
        environment = {"DENO_DIR": ".deno"},
    )

    if res.return_code != 0:
        fail("Failed to run `DENO_DIR=. deno i`:\n" + res.stderr)

    rctx.delete("deno")

    # rctx.delete("deno.json")
    # rctx.delete("deno.lock")
    rctx.delete(".deno")

_repo = repository_rule(
    implementation = _repo_impl,
    attrs = dict(
        lock = attr.label(mandatory = True),
        config = attr.label(mandatory = True),
    ),
)

def _impl(mctx):
    for mod in mctx.modules:
        if len(mod.tags.install) != 1:
            fail("Expected a single install per module")

        install_tag = mod.tags.install[0]

        _repo(
            name = install_tag.name,
            lock = install_tag.lock,
            config = install_tag.config,
        )

deno = module_extension(
    implementation = _impl,
    tag_classes = dict(
        install = tag_class(
            attrs = dict(
                name = attr.string(default = "deno"),
                lock = attr.label(mandatory = True),
                config = attr.label(mandatory = True),
            ),
        ),
    ),
)
