#!/usr/bin/env bash

set -u

. "${BASH_SOURCE[0]%/*}/dda.sh" || exit 1

test_dda_steps() {
    [[ "$(dda_steps 5 5 0)" == "1000 0" ]] || die "dda_steps 5 5 0 failed"
    [[ "$(dda_steps 5 5 45)" == "1000 1000" ]] || die "dda_steps 5 5 45 failed"
    [[ "$(dda_steps 5 5 90)" == "0 1000" ]] || die "dda_steps 5 5 90 failed"
    [[ "$(dda_steps 5 5 135)" == "-1000 1000" ]] || die "dda_steps 5 5 135 failed"
    [[ "$(dda_steps 5 5 180)" == "-1000 0" ]] || die "dda_steps 5 5 180 failed"
    [[ "$(dda_steps 5 5 225)" == "-1000 -1000" ]] || die "dda_steps 5 5 225 failed"
    [[ "$(dda_steps 5 5 270)" == "0 -1000" ]] || die "dda_steps 5 5 270 failed"
    [[ "$(dda_steps 5 5 315)" == "1000 -1000" ]] || die "dda_steps 5 5 315 failed"
}


main_test() {
    for func in $(compgen -A function | grep '^test_'); do
        echo "Running $func"
        "$func"
    done
}

main_test