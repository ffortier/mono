#!/usr/bin/env bash
set -e
exec="$(realpath "$1")"
cd "$BUILD_WORKING_DIRECTORY"
"$exec" "${@:2}"
