load("@rules_cc//cc:find_cc_toolchain.bzl", "find_cc_toolchain", "use_cc_toolchain")

_SIM65_EXEC_TEMPLATE = """
#!/usr/bin/env bash
"{sim65}" "{binary}" "$@"
"""

def _sim65_transition_impl(_, attr):
    return {"//command_line_option:platforms": "@toolchains_cc65//platforms:sim%s" % attr.cpu}

_sim65_transition = transition(
    implementation = _sim65_transition_impl,
    inputs = [],
    outputs = ["//command_line_option:platforms"],
)

_SIM65_ATTRS = dict(
    binary = attr.label(
        mandatory = True,
        executable = True,
        cfg = _sim65_transition,
        allow_single_file = True,
    ),
    cpu = attr.string(default = "6502", values = ["6502", "65C02"]),
)

def _sim65_tool_impl(ctx):
    cc_toolchain = find_cc_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
    )
    simulator_path = cc_common.get_tool_for_action(
        feature_configuration = feature_configuration,
        action_name = "run_simulator",
    )
    simulator = None
    for f in cc_toolchain.all_files.to_list():
        if f.path == simulator_path:
            simulator = f
            break

    return [DefaultInfo(files = depset([simulator]))]

_sim65_tool = rule(
    implementation = _sim65_tool_impl,
    attrs = dict(
        action_name = attr.string(mandatory = True),
    ),
    fragments = ["cpp"],
    toolchains = use_cc_toolchain(),
)

def _sim65_binary_impl(ctx):
    executable = ctx.actions.declare_file(ctx.label.name + "-sim65.sh")
    ctx.actions.write(
        output = executable,
        content = _SIM65_EXEC_TEMPLATE.format(
            sim65 = ctx.file.tool.short_path,
            binary = ctx.file.binary.short_path,
        ),
        is_executable = True,
    )
    return DefaultInfo(
        executable = executable,
        runfiles = ctx.runfiles(files = [ctx.file.tool, ctx.file.binary]),
    )

_sim65_binary = rule(
    implementation = _sim65_binary_impl,
    attrs = dict(
        tool = attr.label(mandatory = True, cfg = _sim65_transition, allow_single_file = True),
        **_SIM65_ATTRS
    ),
    executable = True,
)

def _sim65_binary_macro(name, **kwargs):
    _sim65_tool(
        name = "%s_sim65" % name,
        action_name = "run_simulator",
        tags = ["manual"],
    )
    return _sim65_binary(
        name = name,
        tool = ":%s_sim65" % name,
        **kwargs
    )

sim65_binary = macro(
    implementation = _sim65_binary_macro,
    attrs = _SIM65_ATTRS,
)

def _sim65_test_impl(ctx):
    test_script = ctx.actions.declare_file(ctx.label.name + "-sim65-test.sh")
    ctx.actions.write(
        output = test_script,
        content = _SIM65_EXEC_TEMPLATE.format(
            sim65 = ctx.file.tool.short_path,
            binary = ctx.file.binary.short_path,
        ),
        is_executable = True,
    )
    return DefaultInfo(
        executable = test_script,
        runfiles = ctx.runfiles(files = [ctx.file.tool, ctx.file.binary]),
    )

_sim65_test = rule(
    implementation = _sim65_test_impl,
    attrs = dict(
        tool = attr.label(mandatory = True, cfg = _sim65_transition, allow_single_file = True),
        **_SIM65_ATTRS
    ),
    test = True,
)

def _sim65_test_macro(name, **kwargs):
    _sim65_tool(
        name = "%s_sim65" % name,
        action_name = "run_simulator",
        tags = ["manual"],
    )
    return _sim65_test(
        name = name,
        tool = ":%s_sim65" % name,
        **kwargs
    )

sim65_test = macro(
    implementation = _sim65_test_macro,
    attrs = _SIM65_ATTRS,
)
