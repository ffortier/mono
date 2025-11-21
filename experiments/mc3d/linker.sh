#!/usr/bin/env bash

declare -r pattern='\$\{BASH_SOURCE\[0\]%/\*\}/([^"]+)'
declare -A already_processed=(
    ["$1"]=1
)

GENDIR="$(realpath "$GENDIR")"

cd "$PACKAGE_NAME" || exit 1

resolve() {
    if [[ -f "$1" ]]; then
        echo "$1";
    else
        echo "$GENDIR/$PACKAGE_NAME/$1"
    fi
}

process() {
    local line

    read -r line;

    # Skip shebang
    [[ "$line" == "#!"* ]] || exit 1

    while IFS= read -r line; do
        if [[ "$line" =~ $pattern ]]; then
            if [[ ! -v already_processed["${BASH_REMATCH[1]}"] ]]; then
                already_processed["${BASH_REMATCH[1]}"]=1
                process <"$(resolve "${BASH_REMATCH[1]}")"
            fi
        else
            echo "$line"
        fi
    done   

    [[ -n "$line" ]] && echo "$line"
}

echo "#!/usr/bin/env bash"
process <"$(resolve "$1")"

