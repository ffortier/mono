#!/usr/bin/env bash
set -e

temp="$(mktemp -d)"
pushd "$temp"

git init
mkdir src
cp "$BUILD_WORKSPACE_DIRECTORY/third_party/cpp/slog_wasm32.c" src

git add .
git diff --staged > "$BUILD_WORKSPACE_DIRECTORY/third_party/cpp/slog_wasm32.patch" .

popd
rm -rf "$temp"