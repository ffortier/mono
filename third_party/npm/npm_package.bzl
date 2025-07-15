def _impl(rctx):
    package_lock = json.decode(rctx.read(rctx.attr.package_lock))
    package = package_lock["packages"][rctx.attr.package]

    rctx.download_and_extract(
        url = package["resolved"],
        output = ".",
        strip_prefix = rctx.attr.strip_prefix,
        integrity = package["integrity"],
    )

    rctx.file("BUILD", rctx.attr.build_file_content)

npm_package = repository_rule(
    implementation = _impl,
    attrs = dict(
        package = attr.string(mandatory = True),
        package_lock = attr.label(default = "//third_party/npm:package-lock.json"),
        strip_prefix = attr.string(default = "package"),
        build_file_content = attr.string(),
    ),
)
