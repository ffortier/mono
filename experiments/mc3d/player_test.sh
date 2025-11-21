#!/usr/bin/env bash

set -u

. "${BASH_SOURCE[0]%/*}/base.sh" || exit 1
. "${BASH_SOURCE[0]%/*}/player.sh" || exit 1

main_test() {
    for func in $(compgen -A function | grep '^test_'); do
        echo "Running $func"
        "$func"
    done
}

main_test "$@"