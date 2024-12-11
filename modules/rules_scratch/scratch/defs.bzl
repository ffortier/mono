load(":private/providers.bzl", _ScratchExtensionInfo = "ScratchExtensionInfo", _ScratchInfo = "ScratchInfo")
load(":private/scratch_binary.bzl", _scratch_binary = "scratch_binary")
load(":private/scratch_extension.bzl", _scratch_extension = "scratch_extension")
load(":private/scratch_sprite.bzl", _scratch_sprite = "scratch_sprite")

ScratchInfo = _ScratchInfo
ScratchExtensionInfo = _ScratchExtensionInfo

scratch_binary = _scratch_binary
scratch_sprite = _scratch_sprite
scratch_extension = _scratch_extension
