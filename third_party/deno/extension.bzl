_BUILD = """
filegroup(
    name = "{repo_name}",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)
"""

def _repo_impl(rctx):
    rctx.file("BUILD", _BUILD.format(repo_name = rctx.original_name))

    rctx.template("deno.json", rctx.attr.config)
    rctx.template("deno.lock", rctx.attr.lock)

    # TODO: Support more os
    rctx.download_and_extract(
        output = ".",
        url = ["https://github.com/denoland/deno/releases/download/v2.3.1/deno-aarch64-apple-darwin.zip"],
        sha256 = "e3d3d7b21ce89105d96c316e9370b1f05aa6e87687f40faf37a39a613a477014",
    )

    res = rctx.execute(
        ["./deno", "i", "--vendor"],
        environment = {"DENO_DIR": ".deno"},
    )

    if res.return_code != 0:
        fail("Failed to run `DENO_DIR=. deno i`:\n" + res.stderr)

    rctx.delete("deno")
    rctx.delete("deno.json")
    rctx.delete("deno.lock")
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
