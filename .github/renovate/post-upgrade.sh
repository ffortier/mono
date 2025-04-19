#! /usr/bin/env bash
set -xe

bzl_opts=(
    --override_module=toolchains_llvm=./third_party/cpp/no_toolchains_llvm
)

if ! git diff --exit-code third_party/python/requirements.in >/dev/null; then
    bazel run //third_party/python:requirements.update "${bzl_opts[@]}"
fi

if ! git diff --exit-code third_party/java/deps.MODULE.bazel >/dev/null; then
    REPIN=1 bazel run @maven//:pin "${bzl_opts[@]}"
fi

if ! git diff --exit-code third_party/dotnet/paket.dependencies >/dev/null; then
    bazel run //third_party/dotnet:update-deps "${bzl_opts[@]}"
fi

REPIN=1 bazel build --nobuild //... "${bzl_opts[@]}"

