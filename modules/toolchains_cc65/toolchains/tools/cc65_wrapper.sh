#!/usr/bin/env bash

args=()
assembler_args=()
compiler_backend=
assembler_backend=
depfile=

die() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

todo() {
    echo "TODO: $*" >&2
    exit 1
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --compiler-backend)
                compiler_backend="$2"
                shift 2
                ;;
            --assembler-backend)
                assembler_backend="$2"
                shift 2
                ;;
            --create-dep|--create-full-dep)
                depfile="$2"
                args+=("$1" "$2")
                shift 2
                ;;
            -o)
                output="$2"
                shift 2
                ;;
            -t)
                args+=("$1" "$2")
                assembler_args+=("$1" "$2")
                shift 2
                ;;
            -C)
                args+=("$1" "$2")
                assembler_args+=("$1" "$2")
                shift 2
                ;;
            *)
                args+=("$1")
                shift
                ;;
        esac
    done

    [[ -n "$compiler_backend" ]] || die "Missing --compiler-backend"
    [[ -n "$assembler_backend" ]] || die "Missing --assembler-backend"
}

# The allowlist_include_directories on the cc65 tool don't seem to work
remove_builtin_headers() {
    local clean_deps=()

    for dep in "$@"
    do
        # TODO: Needs better logic, skipping absolute paths
        [[ "$dep" == "/"* ]] || clean_deps+=("$dep")
    done

    IFS=" " echo "${clean_deps[*]}"
}

# Bazel expect a single rule for the output file like
# out.o: out.c out.h \
#   other.h
#
# But cc65 create more than one rule and uses tab after the semi-colon which is bad
patch_depfile() {
    local out=()
    local on_target=false
    local deps=

    while read -r line
    do
        if [[ "$on_target" == "true" ]]
        then
            out+=("$line")
        elif [[ "$line" == "${output}.s:"* ]]
        then
            deps="${line#"${output}.s:"}"
            deps="${deps#[[:space:]]*}"
            deps="$(remove_builtin_headers $deps)" # TODO: names with spaces?

            out+=("${output}: $deps")
        fi

        if [[ "$line" == *"\\" ]]
        then
            on_target=true
        else
            on_target=false
        fi
    done <"$1"

    IFS=$'\n' echo "${out[*]}" >&2
    IFS=$'\n' echo "${out[*]}" >"$1"
}

main() {
    parse_args "$@"

    # FIXME: cl65 don't produce the expected output, maybe an issue with symlinks?
    "$compiler_backend" -o "${output}.s" "${args[@]}" || die "Failed to compile" $?
    "$assembler_backend"  -o "$output" "${assembler_args[@]}" "${output}.s" || die "Failed to assemble" $?

    if [[ -n "$depfile" && -f "$depfile" ]]
    then
        patch_depfile "$depfile"
    fi
}

main "$@"