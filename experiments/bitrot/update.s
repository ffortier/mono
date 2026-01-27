.importzp tmp1, tmp2, ptr1, ptr2

.export _update_screen

.if .defined(__SIM6502__)
VIDEO_MEM = sim65_video_mem
.else
VIDEO_MEM = $0400
.endif

.macro render_block offset
.scope
    lda #'a'
    ldx #0
@loop:
    sta VIDEO_MEM + offset, x
    inx
    cpx #250
    bne @loop
.endscope
.endmacro

_update_screen:
    render_block 0
    render_block 250
    render_block 500
    render_block 750

    rts

.segment "BSS"
.if .defined(__SIM6502__)
sim65_video_mem: .res 1024
.endif