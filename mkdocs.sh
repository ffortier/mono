#!/usr/bin/env bash
set -ex

./third_party/python/mkdocs -- "$@" --config-file "$BUILD_WORKING_DIRECTORY/mkdocs.yml"