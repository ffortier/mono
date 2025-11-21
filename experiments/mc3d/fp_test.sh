#!/usr/bin/env bash

set -u

. "${BASH_SOURCE[0]%/*}/base.sh" || exit 1
. "${BASH_SOURCE[0]%/*}/fp.sh" || exit 1

test_fp_add() {
    local result
    result=$(fp_add 1500 2500)
    [[ $result -eq 4000 ]] || die "fp_add failed: expected 4.000, got $(fp_print "$result")"
}

test_fp_sub() {
    local result
    result=$(fp_sub 2500 1500)
    [[ $result -eq 1000 ]] || die "fp_sub failed: expected 1.000, got $(fp_print "$result")"
}

test_fp_mult() {
    local result
    result=$(fp_mult 1500 2000)
    [[ $result -eq 3000 ]] || die "fp_mult failed: expected 3.000, got $(fp_print "$result")"
}

test_fp_div() {
    local result
    result=$(fp_div 2500 1500)
    [[ $result -eq 1667 ]] || die "fp_div failed: expected 1.667, got $(fp_print "$result")"
}

main_test() {
    for func in $(compgen -A function | grep '^test_'); do
        echo "Running $func"
        "$func"
    done
}

main_test "$@"