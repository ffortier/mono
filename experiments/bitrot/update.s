.importzp tmp1, tmp2, ptr1, ptr2

.export _update_screen

MAP_DATA = $c000 ; temp, not in zp

.if .defined(__SIM6502__)
VIDEO_MEM = sim65_video_mem
.else
VIDEO_MEM = $0400
.endif

.macro render_block offset
.scope

    lda ptr1
    sta @loop+1
    lda ptr1+1
    sta @loop+2

    ldx #0
@loop:
    lda MAP_DATA + offset, x
    sta VIDEO_MEM + offset, x
    inx
    cpx #250
    bne @loop

    lda #250
    clc
    adc ptr1
    sta ptr1
    lda #0
    adc ptr1+1
    sta ptr1+1
.endscope
.endmacro

.proc _update_screen
    sta ptr1
    txa
    sta ptr1+1

    render_block 0
    render_block 250
    render_block 500
    render_block 750

    rts
.endproc

.segment "BSS"


.if .defined(__SIM6502__)
sim65_video_mem: .res 1024
.endif