SUPPORTED_PLATFORMS = [
    ("c64", "6502"),
    ("vic20", "6502"),
    ("pet", "6502"),
    ("plus4", "6502"),
    ("cbm610", "6502"),
    ("apple2", "6502"),
    ("apple2enh", "65c02"),
    ("atari", "6502"),
    ("atari2600", "6502"),
    ("atari5200", "6502"),
    ("atarixl", "6502"),
    ("nes", "6502"),
    ("supervision", "6502"),
    ("bbc", "6502"),
    ("c16", "6502"),
    ("geos", "6502"),
    ("lunix", "6502"),
    ("osic1p", "6502"),
    ("sim6502", "6502"),
    ("sim65c02", "65c02"),
    ("telestrat", "6502"),
    ("none", "6502"),
    ("none", "65c02"),
]

def find_platform_constraints(name):
    if name == "none":
        fail("Ambiguous platform: none")

    if name == "none-6502":
        return [
            "@toolchains_cc65//platforms/os:none",
            "@toolchains_cc65//platforms/cpu:6502",
        ]

    if name == "none-65c02":
        return [
            "@toolchains_cc65//platforms/os:none",
            "@toolchains_cc65//platforms/cpu:65c02",
        ]

    for os, cpu in SUPPORTED_PLATFORMS:
        if os == name:
            return [
                "@toolchains_cc65//platforms/os:%s" % os,
                "@toolchains_cc65//platforms/cpu:%s" % cpu,
            ]

    fail("Unsupported platform: %s" % name)
