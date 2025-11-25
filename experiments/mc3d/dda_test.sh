#!/usr/bin/env bash

set -u

. "${BASH_SOURCE[0]%/*}/dda.sh" || exit 1

test_dda_steps() {
    [[ "$(dda_steps 0)" == "10000 0" ]] || die "dda_steps 0 failed"
    [[ "$(dda_steps 45)" == "10000 10000" ]] || die "dda_steps 45 failed"
    [[ "$(dda_steps 90)" == "0 10000" ]] || die "dda_steps 90 failed"
    [[ "$(dda_steps 135)" == "-10000 10000" ]] || die "dda_steps 135 failed"
    [[ "$(dda_steps 180)" == "-10000 0" ]] || die "dda_steps 180 failed"
    [[ "$(dda_steps 225)" == "-10000 -10000" ]] || die "dda_steps 225 failed"
    [[ "$(dda_steps 270)" == "0 -10000" ]] || die "dda_steps 270 failed"
    [[ "$(dda_steps 315)" == "10000 -10000" ]] || die "dda_steps 315 failed"
}


main_test() {
    for func in $(compgen -A function | grep '^test_'); do
        echo "Running $func"
        "$func"
    done

    dda 35 35 45
}

main_test