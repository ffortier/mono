#!/usr/bin/env bash

[[ -v "PLAYER_SH" ]] && return 0

PLAYER_SH=1

. "${BASH_SOURCE[0]%/*}/trig_tables.sh" || exit 1
. "${BASH_SOURCE[0]%/*}/fp.sh" || exit 1

declare -r PLAYER_TURN_ANGLE=15
declare -r PLAYER_SPEED=5000

declare -i player_x=0
declare -i player_y=0
declare -i player_direction=0

player_move() {
    local distance=$1
    local dx dy
    
    dx=$(fp_mult "${COSTABLE[$player_direction]}" "$distance")
    dy=$(fp_mult "${SINTABLE[$player_direction]}" "$distance")

    player_x=$(( player_x + dx / FIXED_POINT ))
    player_y=$(( player_y + dy / FIXED_POINT ))
}

player_input() {
    case "$1" in
        key-up) 
            player_move "$PLAYER_SPEED"
            ;;
        key-down) 
            player_move "$(( -PLAYER_SPEED ))"
            ;;
        key-left) 
            player_direction=$(( (player_direction + (360 - PLAYER_TURN_ANGLE)) % 360 ))
            ;;
        key-right) 
            player_direction=$(( (player_direction + PLAYER_TURN_ANGLE) % 360 ))
            ;;
    esac
}