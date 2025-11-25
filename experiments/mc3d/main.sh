#!/usr/bin/env bash

. "${BASH_SOURCE[0]%/*}/trig_tables.sh" || exit 1
. "${BASH_SOURCE[0]%/*}/fp.sh" || exit 1
. "${BASH_SOURCE[0]%/*}/player.sh" || exit 1
. "${BASH_SOURCE[0]%/*}/dda.sh" || exit 1

declare -i tick=0

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
    # Kill background jobs first
    jobs -p | xargs -r kill 2>/dev/null
    
    # Close file descriptors (this will unblock any waiting reads)
    exec 3>&-
    exec 4<&-
    
    # Restore terminal BEFORE closing fd 5
    tput cnorm
    tput rmcup
    
    echo TEARDOWN >&5
    exec 5>&-
    
    rm -f "$PIPE"
}

render_frame() {
    local buffer=''
    # local status
    # local ch
    # local -i i j
    # printf -v status "Tick: %d, Position: (%d, %d), Direction: %d" "$tick" "$player_x" "$player_y" "$player_direction"
    # tput cup 0 0
    # for i in $(eval echo "{1..$((LINES-1))}"); do
    #     for j in  $(eval echo "{0..$((COLUMNS-1))}"); do

    #         if [[ $i -eq 1 ]]; then
    #             ch="${status:j:1}"
    #             buffer+="${ch:-"$1"}"
    #         else
    #             buffer+="$1"
    #         fi

    #     done
    #     buffer+=$'\n'
    # done

    local -a dists=()
    local -i angle
    local -i fov_half=30
    local -i i j ray_index dist wall_height

printf "Debug: dists=(%s)\n" "${dists[*]}" >&5
    for (( angle = player_direction - fov_half; angle <= player_direction + fov_half; angle++ )); do
        dists+=("$(dda "$player_x" "$player_y" "$angle")")
    done
printf "Debug: dists=(%s)\n" "${dists[*]}" >&5
    for (( i = 0; i < LINES - 1; i++ )); do
        for (( j = 0; j < COLUMNS; j++ )); do
            ray_index=$(( j * (2 * fov_half + 1) / COLUMNS ))
            dist=${dists[ray_index]}
            wall_height=$(( (CELL_SIZE * FIXED_POINT) / (dist + 1) * LINES / 2 / FIXED_POINT ))

            if (( i < (LINES - wall_height) / 2 )); then
                buffer+='1'
            elif (( i < (LINES + wall_height) / 2 )); then
                buffer+="2"
            else
                buffer+='3'
            fi
        done
        buffer+=$'\n'
    done

    printf "ticks: %d, pos: (%d, %d), dir: %d\n" "$tick" "$player_x" "$player_y" "$player_direction" >&5
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
    exec 5>/dev/tty || die "failed to open tty for writing"

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
                render_frame $'\u2584' 2>&5
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