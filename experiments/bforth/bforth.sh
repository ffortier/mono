#!/usr/bin/env bash

#region "utils"
die() {
    caller >&2
    echo "$*">&2
    exit 1
}

log() {
    if [[ "${BFORTH_LOG:-0}" -ne 0 ]]; then
        echo "$*">&2
    fi
}

check_prerequisites() {
    # TODO: Should do feature detection instead
    [[ "${BASH_VERSINFO[0]}" -ge 4 ]] || die "Required bash 4 or more, got $BASH_VERSION"
}
#endregion

#region private ops
check_stack_underflow() {
    local -i n="${1:-1}"

    [[ "${#stack[@]}" -ge "$n" ]] || die "Stack underflow, expected at least $n items"
}

read_token() {
    read -r "$1" || return $?
    local token="${!1}"
    printf -v "$2" '%s' "${token%%:*}"
    printf -v "$3" '%s' "${token#*:}"
}

is_word_defined() {
    [[ -v "udf[$1]" || -v "consts[$1]" ]]
}

pop() {
    printf -v "$1" "%s" "${stack[-1]}"
    unset 'stack[-1]'
}

push() {
    stack+=("$1")
}
#endregion

#region lexer
token_stream() {
    local line
    local len
    local i
    local word
    local type

    while read -r line || [[ -n $line ]];
    do
        log "$line"
        len=${#line}
        word=''
        type=n # n|s|w|c
        
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
            elif [[ $type == 'c' ]]; then
                [[ "${line:i:1}" == " )" ]] && type=n
            else
                case "${line:i:1}" in
                    ' ')
                        [[ -n "$word" ]] && echo "$type:${word,,}"
                        word=''
                        type=n
                        ;;
                    [0-9])
                        word+="${line:i:1}"
                        ;;
                    '"')
                        [[ "${line:i:2}" == '" ' ]] || die "Expected '"'" '"', but got '${line:i:2}'"
                        echo "w:${word,,}"'"'
                        word=''
                        type='s'
                        ((i++))
                        ;;
                    '(')
                        if [[ -z "$word" && "${line:i:2}" == '( ' ]]; then
                            type='c'
                            ((i++))
                        else
                            type=w
                            word+="${line:i:1}"
                        fi
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
#endregion

#region standard ops
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

    local -i a b
    pop b
    pop a
    push $((a+b))
}

op_sub() {
    check_stack_underflow 2

    local -i a b
    pop b
    pop a
    push $((a-b))
}

op_mul() {
    check_stack_underflow 2

    local -i a b
    pop b
    pop a
    push $((a*b))
}

op_div() {
    check_stack_underflow 2

    local -i a b
    pop b
    pop a
    push $((a/b))
}

op_eq() {
    check_stack_underflow 2

    local -i a b
    pop b
    pop a

    if (( a == b)); then 
        push 0 
    else
        push -1
    fi
}

op_dup() {
    check_stack_underflow 1

    push "${stack[-1]}"
}

op_pop() {
    check_stack_underflow 1

    local -i value
    pop value
    echo "$value"
}

op_eq0() {
    check_stack_underflow 1

    local -i value

    pop value

    if (( value == 0 )); then
        push -1
    else
        push 0
    fi
}

op_exit() {
    check_stack_underflow 1

    local code
    pop code
    exit "$code"
}

op_here() {
    push "${#mem[@]}"
}

op_allot() {
    check_stack_underflow 1

    local -i size i len
    pop size

    for (( i = 0; i < size; i++ ));
    do
        mem+=(0)
    done

    if (( size < 0 )); then
        len="${#mem[@]}"
        mem=("${mem[@]:0:$len+$size}")
    fi
}

op_constant() {
    check_stack_underflow 1

    local token type word

    read_token token type word

    [[ "$type" == "w" ]] || die "Expected word after CONSTANT"

    is_word_defined "$word" && die "Word already defined <$word>"

    local -i value

    pop value

    consts[$word]="$value"
}

op_variable() {
    local token type word

    read_token token type word

    [[ "$type" == "w" ]] || die "Expected word after VARIABLE"

    is_word_defined "${word}" && die "Word already defined <$word>"

    consts[$word]="${#mem[@]}"
    mem+=(0)
}

op_store() {
    check_stack_underflow 2
    local value addr
    pop addr
    pop value

    # bad shellcheck, not an issue
    # shellcheck disable=SC2004
    mem[$addr]="$value"
}

op_load() {
    check_stack_underflow 1
    local addr
    pop addr
    push "${mem[$addr]}"
}

op_depth() {
    push "${#stack[@]}"
}
#endregion

#region interpreter
eval_udf() {
    if [[ -v "udf[$1]" ]]; then
        eval_next <<< "${udf[$1]}"
    elif [[ -v "consts[$1]" ]]; then
        push "${consts[$1]}"
    else
        die "Unknown word <$1>"
    fi
}

eval_word_def() {
    local token type word
    local word_body=''

    read_token token type word

    [[ "$type" == 'w' && "$word" != ';' ]] || die "Expected word name, but got ${token}"

    local word_name="$word"

    while read_token token type word
    do
        case "$word" in
            ';')
                is_word_defined "${word_name,,}" && die "Word already defined <$word_name>"
                udf["${word_name,,}"]="$word_body"
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

            while read_token token type word
            do
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

        while read_token token type word
        do
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

    while read_token token type word
    do
        if [[ "$token" == "$end_token1" ]]; then return 1
        elif [[ "$token" == "$end_token2" ]]; then return 2
        fi

        log "$token"
        
        case "$type" in
            n) stack+=("$word") ;;
            w)
                case "${word}" in
                    '.s') op_print_stack ;;
                    '+') op_add ;;
                    '-') op_sub ;;
                    '*') op_mul ;;
                    '/') op_div ;;
                    '=') op_eq ;;
                    '.') op_pop ;;
                    '!') op_store ;;
                    '@') op_load ;;
                    'allot') op_allot ;;
                    'here') op_here ;;
                    'constant') op_constant ;;
                    'variable') op_variable ;;
                    'depth') op_depth ;;
                    '."') string_op='op_print_string' ;;
                    'dup') op_dup ;;
                    '0=') op_eq0 ;;
                    'exit') op_exit ;;
                    ':') eval_word_def ;;
                    'if') eval_if ;;
                    'bye') exit 0 ;;
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
#endregion

#region tests
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

run_all_tests() {
    for fn in $(compgen -A function)
    do
        if [[ "$fn" == "test_"* ]]; then
            echo "Running $fn"
            "$fn"
        fi
    done
}
#endregion

#region interactive mode
run_repl() {
    local line

    while read -rep '> ' line
    do
        eval_next < <(token_stream <<< "$line")
    done
}
#endregion

main() {
    check_prerequisites

    declare -ga stack=()
    declare -ga mem=()
    declare -gA udf
    declare -gA consts

    if [[ $# -eq 1 ]]; then
        eval_next < <(token_stream <"$1")
    elif [[ -t 0 ]]; then
        run_repl
    else
        eval_next < <(token_stream)
    fi    
}


[[ "$0" == "${BASH_SOURCE[0]}" ]] && main "$@"