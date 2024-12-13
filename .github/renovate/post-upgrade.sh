#! /usr/bin/env bash

if ! git diff --exit-code third_party/python/requirements.in >/dev/null; then
    bazel run //third_party/python:requirements.update
fi

REPIN=1 bazel build --nobuild //...

