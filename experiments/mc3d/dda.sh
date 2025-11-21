#!/usr/bin/env bash

declare -r CELL_SIZE=10

[[ -v "DDA_SH" ]] && return 0

DDA_SH=1

. "${BASH_SOURCE[0]%/*}/trig_tables.sh" || exit 1
. "${BASH_SOURCE[0]%/*}/fp.sh" || exit 1
. "${BASH_SOURCE[0]%/*}/base.sh" || exit 1

dda_steps() {
    local -i x="$1"
    local -i y="$2"
    local -i angle="$3"
    local -i dx dy abs_tan
    local -i sin_sign cos_sign

    sin_sign=$(( "${SINTABLE[$angle]}" < 0 ? -1 : 1 ))
    cos_sign=$(( "${COSTABLE[$angle]}" < 0 ? -1 : 1 ))

    if (( ${COSTABLE[$angle]} == 0 )); then
        dx=0
        dy=$(( FIXED_POINT * sin_sign ))
    elif (( ${SINTABLE[$angle]} == 0 )); then
        dy=0
        dx=$(( FIXED_POINT * cos_sign ))
    else
        abs_tan=$(fp_div "${SINTABLE[$angle]}" "${COSTABLE[$angle]}")
        abs_tan=$(( abs_tan < 0 ? -abs_tan : abs_tan ))

        if (( abs_tan > FIXED_POINT )); then
            dy=$(( FIXED_POINT * sin_sign ))
            dx=$(( abs_tan * cos_sign ))
        else
            dx=$(( FIXED_POINT * cos_sign ))
            dy=$(( $(fp_div FIXED_POINT "$abs_tan") * sin_sign ))
        fi
    fi

    printf '%d %d\n' "$dx" "$dy"
}

dda() {
    local -i x="$1"
    local -i y="$2"
    local -i angle="$3"
    local -i mx=$(( (x / CELL_SIZE) * FIXED_POINT ))
    local -i my=$(( (y / CELL_SIZE) * FIXED_POINT ))
    local -i dx dy

    read -r dx dy < <(dda_steps "$x" "$y" "$angle")
}

# tan(a) = dx / dy
# => dx = tan(a) * dy
# or
# dy = dx / tan(a)
# if dx == 1 => dy = 1 / tan(a)
# if dy == 1 => dx = tan(a) * 1