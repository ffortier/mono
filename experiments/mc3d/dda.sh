#!/usr/bin/env bash

declare map=(
    "####################"
    "#..................#"
    "#..................#"
    "#..................#"
    "#..................#"
    "#..................#"
    "####################"
)

declare -r MAP_WIDTH=${#map[0]}
declare -r MAP_HEIGHT=${#map[@]}
declare -r CELL_SIZE=10

[[ -v "DDA_SH" ]] && return 0

DDA_SH=1

. "${BASH_SOURCE[0]%/*}/trig_tables.sh" || exit 1
. "${BASH_SOURCE[0]%/*}/fp.sh" || exit 1
. "${BASH_SOURCE[0]%/*}/base.sh" || exit 1

# Calculate the DDA steps (dx, dy) for a given angle to move one cell in the grid.
# Echoes two fixed-point numbers: dx dy
# Arguments:
#   $1: angle in degrees (0-359)
dda_steps() {
    local -i angle="$1"
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

    printf '%d %d\n' "$(fp_mult $dx $((FIXED_POINT * CELL_SIZE)) )" "$(fp_mult $dy $((FIXED_POINT * CELL_SIZE)) )"
}

# Perform DDA to find the distance to the nearest wall from (x1, y1) in the given angle.
# Arguments:
#   $1: x1 in world coordinates
#   $2: y1 in world coordinates
#   $3: angle in degrees (0-359)
dda() {
    local -i x1=$(( $1 / CELL_SIZE * CELL_SIZE * FIXED_POINT ))
    local -i y1=$(( $2 / CELL_SIZE * CELL_SIZE * FIXED_POINT ))
    local -i angle=$(( ($3 + 360) % 360 ))
    local -i dx dy
    local -i x2 y2
    local -i line column
    local -i step

    read -r dx dy < <(dda_steps "$angle")

    x2=$x1
    y2=$y1

    step=$(fp_div $dx "${COSTABLE[$angle]}")
    step=$(( step < 0 ? -step : step ))
    
    while true; do
        x2=$(fp_add $x2 $dx )
        y2=$(fp_add $y2 $dy )

        line=$(( y2 / (CELL_SIZE * FIXED_POINT) ))
        column=$(( x2 / (CELL_SIZE * FIXED_POINT) ))

        if (( line < 0 || line >= MAP_HEIGHT || column < 0 || column >= MAP_WIDTH )); then
            break
        fi

        if [[ "${map[$line]:$column:1}" == "#" ]]; then
            break
        fi
    done

    fp_div $(( x2 - x1 )) "${COSTABLE[$angle]}"
}
