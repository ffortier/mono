#!/usr/bin/env bash
# shellcheck source=bforth.sh
source "$(dirname "$0")/bforth.sh"

test_token_stream() {
    local expected_tokens=(
        'w:hello'
        'w:world'
        'n:42'
        'n:69'
        'w:foo'
        'w:."'
        's:bar baz'
        'n:-1'
    )

    local i=0

    while read -r token
    do
        [[ "$token" == "${expected_tokens[$i]}" ]] || die "Unexpected value <$token>, expected <${expected_tokens[$i]}>"
        (( i++ ))
    done < <(token_stream <<< 'hello   world 42 69'$'\n'' foo ." bar baz" -1')

    [[ $i -eq ${#expected_tokens[@]} ]] || die "Expected values: " "${expected_tokens[@]:i}"
}

test_arithmetic() {
    [[ "$(token_stream <<< '3 2 + .' | eval_next)" -eq 5 ]] || die "Failed to add numbers"
    [[ "$(token_stream <<< '3 2 - .' | eval_next)" -eq 1 ]] || die "Failed to sub numbers"
    [[ "$(token_stream <<< '3 2 * .' | eval_next)" -eq 6 ]] || die "Failed to mul numbers"
    [[ "$(token_stream <<< '3 2 / .' | eval_next)" -eq 1 ]] || die "Failed to div numbers"
}

test_udf() {
    [[ "$(token_stream <<< ': mul2 2 * ; 4 mul2 .' | eval_next)" -eq 8 ]] || die "Failed udf"
}

test_if() {
    [[ "$(token_stream <<< '0 if ." true" then' | eval_next)" == "true" && "$?" -eq 0 ]] || die "Failed simple if (true)"
    [[ "$(token_stream <<< '0 if ." true" else ." false" then' | eval_next)" == "true" && "$?" -eq 0 ]] || die "Failed simple if-else (true)"
    [[ -z "$(token_stream <<< '1 if ." true" then' | eval_next)" && "$?" -eq 0 ]] || die "Failed simple if (false)"
    [[ "$(token_stream <<< '1 if ." true" else ." false" then' | eval_next)" == "false" && "$?" -eq 0 ]] || die "Failed simple if-else (false)"
    [[ "$(token_stream <<< '0 if 3 3 - if ." true" then then' | eval_next)" == "true" && "$?" -eq 0 ]] || die "Failed nested if (true)"
    [[ "$(token_stream <<< '0 if 1 if ." true" else ." false" then then' | eval_next)" == "false" && "$?" -eq 0 ]] || die "Failed nested if-else (false)"
}

main() {
    check_prerequisites

    for fn in $(compgen -A function)
    do
        if [[ "$fn" == "test_"* ]]; then
            echo "Running $fn"
            "$fn"
        fi
    done
}


[[ "$0" == "${BASH_SOURCE[0]}" ]] && main "$@"