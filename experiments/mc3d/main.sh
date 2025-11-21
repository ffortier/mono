#!/usr/bin/env bash

. "${BASH_SOURCE[0]%/*}/trig_tables.sh" || exit 1
. "${BASH_SOURCE[0]%/*}/fp.sh" || exit 1
. "${BASH_SOURCE[0]%/*}/player.sh" || exit 1

declare -i tick=0

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

read_keypress() {
    local fd=$1

    local escape_char=$'\u1b'
	while true; do
		local data=
		read -rsn1 data 2>/dev/null || return

		if [[ $data == "$escape_char" ]]; then
			read -rsn2 data 2>/dev/null || return
		fi

		local output=
        
		case "$data" in
			'[A' | w) output='key-up';;
			'[B' | s) output='key-down';;
			'[D' | a) output='key-left';;
			'[C' | d) output='key-right';;
			''      ) output='key-enter';;
		esac

		if [[ -n $output ]]; then
			echo "$output" >&"$fd"
		fi
	done
}

clock() {
    local fd="$1"
    while true; do
        echo ".">&"$fd"
        sleep 0.1
    done
}

teardown() {
    echo TEARDOWN >&2
    
    tput cnorm
    tput rmcup
    reset
    exec 3>&-
    exec 4<&-
    rm -f "$PIPE"
}

render_frame() {
    local buffer=''
    local status
    local ch
    local -i i j
    printf -v status "Tick: %d, Position: (%d, %d), Direction: %d" "$tick" "$player_x" "$player_y" "$player_direction"
    tput cup 0 0
    for i in $(eval echo "{1..$((LINES-1))}"); do
        for j in  $(eval echo "{0..$((COLUMNS-1))}"); do

            if [[ $i -eq 1 ]]; then
                ch="${status:j:1}"
                buffer+="${ch:-"$1"}"
            else
                buffer+="$1"
            fi

        done
        buffer+=$'\n'
    done

    printf "%s" "$buffer"
}

main() {
    local event

    enable sleep 2>/dev/null

    shopt -s checkwinsize

    (:)

    PIPE="/tmp/probe-$$.fifo"

    mkfifo "$PIPE" || die "failed to create fifo"
    exec 3<> "$PIPE" || die "failed to open fifo"
    exec 4</dev/tty || die "failed to open tty"

    trap teardown exit
    tput smcup
    tput civis

    read_keypress 3 <&4 &
    clock 3 &

    player_x=$(( MAP_WIDTH * CELL_SIZE / 2 ))
    player_y=$(( MAP_HEIGHT * CELL_SIZE / 2 ))

    while read -r event
    do
        case $event in
            .) 
                ((tick++))
                render_frame $'\u2584'
                ;;
            *)
                player_input "$event"
                ;;
        esac
    done <&3
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi