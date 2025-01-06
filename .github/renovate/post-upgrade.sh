#! /usr/bin/env bash

if ! git diff --exit-code third_party/python/requirements.in >/dev/null; then
    bazel run //third_party/python:requirements.update
    bazel run //third_party/python:requirements_3_9.update
fi

REPIN=1 bazel build --nobuild //...

