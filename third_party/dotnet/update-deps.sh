#! /usr/bin/env bash
set -e

[[ -n "$BUILD_WORKSPACE_DIRECTORY" ]] || exit 1

cd "$BUILD_WORKSPACE_DIRECTORY/third_party/dotnet"

dotnet tool restore
dotnet paket install

bazel run @rules_dotnet//tools/paket2bazel -- --dependencies-file "$(pwd)"/paket.dependencies --output-folder "$(pwd)"