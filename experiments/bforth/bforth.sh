#!/usr/bin/env bash
stack=()
declare -A udf

die() {
    caller >&2
    echo "$*">&2
    exit 1
}

log() {
    echo "$*">&2
}

token_stream() {
    local line
    local len
    local i
    local word
    local type

    while read -r line;
    do
        len=${#line}
        word=''
        type=n # n|s|w
        
        for (( i = 0; i < len; i++ ))
        do
            if [[ $type == 's' ]]; then
                case "${line:i:1}" in
                    '"')
                        echo "$type:$word"
                        type=n
                        word=''
                        ;;
                    *)
                        word+="${line:i:1}"
                        ;;
                esac
            else
                case "${line:i:1}" in
                    ' ')
                        [[ -n "$word" ]] && echo "$type:$word"
                        word=''
                        type=n
                        ;;
                    [0-9])
                        word+="${line:i:1}"
                        ;;
                    '"')
                        [[ "${line:i:2}" == '" ' ]] || die "Expected '"'" '"', but got '${line:i:2}'"
                        echo "w:$word"'"'
                        word=''
                        type='s'
                        ((i++))
                        ;;
                    '-')
                        [[ -z "$word" && "${line:i+1:1}" == [0-9] ]] || type=w
                        word+="${line:i:1}"
                        ;;
                    *)
                        type=w
                        word+="${line:i:1}"
                        ;;
                esac
            fi
        done

        [[ $type != 's' ]] || die "Unexpected end of line, unclosed string literal"
        [[ -n "$word" ]] && echo "$type:$word"
    done
}

check_stack_underflow() {
    local -i n="${1:-1}"

    [[ "${#stack[@]}" -ge "$n" ]] || die "Stack underflow, expected at least $n items"
}

pop() {
    check_stack_underflow 1
    local -n var="$1"
    # shellcheck disable=SC2034
    var="${stack[-1]}"
    unset 'stack[-1]'
}

push() {
    stack+=("$1")
}

op_print_stack() {
    local content
    content="$(printf "<%d> " "${stack[@]}")"
    printf "(%d) %s\n" "${#stack[@]}" "$content"
}

op_print_string() {
    echo "$1"
}

op_add() {
    check_stack_underflow 2

    local a b
    pop b
    pop a
    push $((a+b))
}

op_sub() {
    check_stack_underflow 2

    local a b
    pop b
    pop a
    push $((a-b))
}

op_mul() {
    check_stack_underflow 2

    local a b
    pop b
    pop a
    push $((a*b))
}

op_div() {
    check_stack_underflow 2

    local a b
    pop b
    pop a
    push $((a/b))
}

op_dup() {
    check_stack_underflow 1

    push "${stack[-1]}"
}

op_pop() {
    check_stack_underflow 1

    local value
    pop value
    echo "$value"
}

eval_udf() {
    [[ -v "udf[$1]" ]] || die "Unknown word <$1>"

    eval_next <<< "${udf[$1]}"
}

eval_word_def() {
    local token type word
    local word_body=''

    read -r token
    type="${token%%:*}"
    word="${token#*:}"

    [[ "$type" == 'w' && "$word" != ';' ]] || die "Expected word name, but got ${token}"

    local word_name="$word"

    while read -r token
    do
        type="${token%%:*}"
        word="${token#*:}"

        case "$word" in
            ';')
                udf["$word_name"]="$word_body"
                return 0
                ;;
            ':')
                die "Cannot define a word in a word"
                ;;
            *)
                word_body+="$type:$word"$'\n'
                ;;
        esac
    done
}

eval_if() {
    check_stack_underflow 1

    local token type word
    local -i eval_ret depth condition

    pop condition

    # condition is true
    if [[ "$condition" -eq 0 ]]; then
        eval_next "w:else" "w:then"

        eval_ret="$?"

        # token <else> encountered, need to skip until we reach <then>
        if [[ $eval_ret -eq 1 ]]; then
            depth=1

            while read -r token
            do
                type="${token%%:*}"
                word="${token#*:}"

                case "$word" in
                    'if') (( depth++ )) ;;
                    'then') (( --depth == 0 )) && return 0 ;;
                esac
            done
        elif [[ $eval_ret -ne 2 ]]; then
            die "Unexpected end of input, token <then> expected"
        fi
    else
        # condition is false, need to skip until we reach <else> or <then>
        depth=1

        while read -r token
        do
            type="${token%%:*}"
            word="${token#*:}"

            case "$word" in
                'if') (( depth++ )) ;;
                'else') (( depth == 1 )) && break ;;
                'then') (( --depth == 0 )) && return 0 ;;
            esac
        done

        eval_next "w:then"

        eval_ret="$?"

        if [[ "$eval_ret" -ne 1 ]]; then
            die "Unexpected end of input, token <then> expected"
        fi
    fi
}

eval_next() {
    local token
    local type
    local word
    local string_op
    local word_name
    local word_body
    local end_token1="${1:-''}"
    local end_token2="${2:-''}"

    while read -r token
    do
        if [[ "$token" == "$end_token1" ]]; then return 1
        elif [[ "$token" == "$end_token2" ]]; then return 2
        fi

        type="${token%%:*}"
        word="${token#*:}"
        
        case "$type" in
            n) stack+=("$word") ;;
            w)
                case "${word,,}" in
                    '.s') op_print_stack ;;
                    '+') op_add ;;
                    '-') op_sub ;;
                    '*') op_mul ;;
                    '/') op_div ;;
                    '.') op_pop ;;
                    '."') string_op='op_print_string' ;;
                    'dup') op_dup ;;
                    ':') eval_word_def ;;
                    'if') eval_if ;;
                    *) eval_udf "${word}" ;;
                esac
                ;;
            s)
                [[ -n "$string_op" ]] || die "Expected string op before string literal"
                "$string_op" "$word"
                string_op=''
                ;;
        esac	
    done
}

check_prerequisites() {
    [[ "${BASH_VERSINFO[0]}" -ge 4 ]] || die "Required bash 4 or more, got $BASH_VERSION"
}

main() {
    local line

    check_prerequisites

    while read -rep '> ' line
    do
        eval_next < <(token_stream <<< "$line")
    done
}


[[ "$0" == "${BASH_SOURCE[0]}" ]] && main "$@"