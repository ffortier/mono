load("@aspect_bazel_lib//lib:base64.bzl", "base64")
load("@aspect_bazel_lib//lib/private:strings.bzl", "INT_TO_CHAR")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

_HEX_CHARS = "0123456789abcdef"

def _hex_to_bytes(s):
    bytes = []
    offset = 0

    if len(s) % 2 != 0:
        bytes.append(INT_TO_CHAR[_HEX_CHARS.index(s[0].lower())])
        offset = 1

    for i in range(offset, len(s), 2):
        bytes.append(INT_TO_CHAR[_HEX_CHARS.index(s[i].lower()) * 16 + _HEX_CHARS.index(s[i + 1].lower())])

    return "".join(bytes)

_SYSROOT_BUILD_FILE = """
filegroup(
    name = "sysroot",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)
"""
_SYSROOT_DARWIN_BUILD_FILE = """
filegroup(
    name = "sysroot",
    srcs = glob(
        include = ["**"],
        exclude = ["**/*:*"],
    ),
    visibility = ["//visibility:public"],
)
"""

def _impl(module_ctx):
    for mod in module_ctx.modules:
        if not mod.is_root:
            fail("Only the root module can use the 'sysroots' extension")

        http_archive(
            name = "sysroot_darwin_universal",
            build_file_content = _SYSROOT_DARWIN_BUILD_FILE,
            sha256 = "11870a4a3d382b78349861081264921bb883440a7e0b3dd4a007373d87324a38",
            strip_prefix = "sdk-macos-11.3-ccbaae84cc39469a6792108b24480a4806e09d59/root",
            urls = ["https://github.com/hexops-graveyard/sdk-macos-11.3/archive/ccbaae84cc39469a6792108b24480a4806e09d59.tar.gz"],
        )

        for install in mod.tags.install:
            sysroots = json.decode(module_ctx.read(install.sysroots_json))

            for target in install.targets:
                base_url = sysroots[target]["URL"]
                sha1sum = sysroots[target]["Sha1Sum"]
                tarball = sysroots[target]["Tarball"]
                url = base_url + "/" + sha1sum + "/" + tarball

                http_archive(
                    name = install.name + "_" + target,
                    url = url,
                    integrity = "sha1-" + base64.encode(_hex_to_bytes(sha1sum)),
                    build_file_content = _SYSROOT_BUILD_FILE,
                )

sysroots = module_extension(
    implementation = _impl,
    tag_classes = {
        "install": tag_class(
            attrs = {
                "name": attr.string(default = "sysroots"),
                "sysroots_json": attr.label(default = ":sysroots.json", allow_single_file = [".json"]),
                "targets": attr.string_list(),
            },
        ),
    },
)
