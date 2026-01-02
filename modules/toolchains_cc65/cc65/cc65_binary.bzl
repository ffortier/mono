load("@aspect_bazel_lib//lib:transitions.bzl", "platform_transition_binary")
load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@toolchains_cc65//platforms:platforms.bzl", "find_platform_constraints")

def cc65_binary(name = None, target = None, tags = [], visibility = [], target_compatible_with = [], **kwargs):
    cc_binary(
        name = "%s.prg" % name,
        # target_compatible_with = find_platform_constraints(target),
        tags = tags,
        **kwargs
    )

    platform_transition_binary(
        name = name,
        binary = ":%s.prg" % name,
        target_platform = "@toolchains_cc65//platforms:%s" % target,
        tags = tags,
        visibility = visibility,
        target_compatible_with = target_compatible_with,
    )
