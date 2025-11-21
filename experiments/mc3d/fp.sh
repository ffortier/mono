#!/usr/bin/env bash

[[ -v "FP_SH" ]] && return 0

FP_SH=1

declare -r FIXED_POINT=1000
declare -r FIXED_PLACES=3

fp_add() {
    local a=$1
    local b=$2
    echo $((a + b))
}

fp_sub() {
    local a=$1
    local b=$2
    echo $((a - b))
}

fp_mult() {
    local a=$1
    local b=$2
    echo $(( (a * b) / FIXED_POINT ))
}

fp_div() {
    local -i dividend="$1"
    local -i divisor="$2"
    local -i result quotient i digit remainder sign=1

    if (( dividend < 0 )); then dividend=$(( -dividend )); sign=$(( -sign )); fi
    if (( divisor  < 0 )); then divisor=$(( -divisor  )); sign=$(( -sign  )); fi

    (( divisor != 0 )) || die "Divide by zero"

    quotient=$(( dividend / divisor ))
    result=$(( quotient * 10 ))
    remainder=$(( dividend % divisor ))

    for (( i = 0; i < FIXED_PLACES - 1; i++ ));
    do
        remainder=$(( remainder * 10 ))
        digit=$(( remainder / divisor ))
        result=$(( (result + digit) * 10 ))
        remainder=$(( remainder % divisor ))
    done

    remainder=$(( remainder * 10 ))
    digit=$(( remainder / divisor ))
    result=$(( result + digit ))
    remainder=$(( remainder % divisor ))
    
    if (( remainder * 10 >= 5 * divisor )); then
        result=$(( result + 1 ))
    fi

    echo $(( sign * result ))
}

fp_print() {
    local -i value=$1
    local -i int_part frac_part

    if (( value < 0 )); then
        echo -n "-"
        value=$(( -value ))
    fi

    int_part=$(( value / FIXED_POINT ))
    frac_part=$(( value % FIXED_POINT ))

    printf "%d." "$int_part"
    printf "%0*d" "$FIXED_PLACES" "$frac_part"
}