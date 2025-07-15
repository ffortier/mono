def _impl(name, srcs, entrypoint, out, platform, minify, **kwargs):
    args = ["--platform", platform]

    if minify:
        args.append("--minify")

    args.append("--vendor")
    args.append("--config")
    args.append(Label("@deno").workspace_root + "/deno.json")

    kwargs.pop("expect_failure")  # Not supported
    kwargs.pop("toolchains")  # Not supported

    native.genrule(
        name = name,
        srcs = srcs + ["@deno"],
        outs = [out],
        cmd = "$(DENO) bundle {args} --output $@ $(rootpath {entrypoint})".format(args = " ".join(args), entrypoint = entrypoint),
        toolchains = ["//third_party/deno:resolved"],
        **kwargs
    )

deno_bundle = macro(
    implementation = _impl,
    inherit_attrs = "common",
    attrs = dict(
        srcs = attr.label_list(),
        entrypoint = attr.label(configurable = False, mandatory = True),
        platform = attr.string(configurable = False, default = "browser"),
        minify = attr.bool(configurable = False, default = True),
        out = attr.output(mandatory = True),
    ),
)
