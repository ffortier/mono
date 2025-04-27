_ROOT_BUILD = """
package(default_visibility=["//visibility:public"])
"""

_BINARY = """
genrule(
    name = "{pkg}",
    cmd = "HOME=$$PWD DOTNET_NOLOGO=1 DOTNET_SKIP_FIRST_RUN_EXPERIENCE=1 DOTNET_CLI_TELEMETRY_OPTOUT=1 $(DOTNET_BIN) tool install {pkg} --tool-path $(RULEDIR) --no-cache --add-source ./external/%s --version {version}"%repo_name(),
    executable = True,
    outs = {commands},
    toolchains = ["@rules_dotnet//dotnet:resolved_toolchain"],
    srcs = ["{pkg}.nupkg"],
)
"""

def _impl(rctx):
    dotnet_tools = json.decode(rctx.read(rctx.attr.dotnet_tools_json))

    rules = []

    for name, spec in dotnet_tools["tools"].items():
        rctx.download(
            url = "https://www.nuget.org/api/v2/package/{name}/{version}".format(name = name, version = spec["version"]),
            output = "%s.nupkg" % name,
        )

        rules.append(
            _BINARY.format(
                pkg = name,
                commands = json.encode(spec["commands"]),
                version = spec["version"],
            ),
        )

    rctx.file("BUILD", _ROOT_BUILD + "\n".join(rules))

tools = repository_rule(
    implementation = _impl,
    attrs = dict(
        dotnet_tools_json = attr.label(mandatory = True),
    ),
)
