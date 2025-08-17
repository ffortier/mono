load("@aspect_bazel_lib//lib:transitions.bzl", "platform_transition_binary")
load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@rules_cc//cc/private/rules_impl:cc_binary.bzl", _cc_binary_rule = "cc_binary")
load("@toolchains_cc65//platforms:platforms.bzl", "find_platform_constraints")

def _impl(name, target, tags, visibility, target_compatible_with, **kwargs):
    cc_binary(
        name = "%s_cc_binary" % name,
        target_compatible_with = find_platform_constraints(target),
        tags = tags,
        **kwargs
    )

    platform_transition_binary(
        name = name,
        binary = ":%s_cc_binary" % name,
        target_platform = "@toolchains_cc65//platforms:%s" % target,
        tags = tags,
        visibility = visibility,
        target_compatible_with = target_compatible_with,
    )

cc65_binary = macro(
    implementation = _impl,
    inherit_attrs = _cc_binary_rule,
    attrs = dict(
        target = attr.string(mandatory = True, configurable = False),
    ),
)
