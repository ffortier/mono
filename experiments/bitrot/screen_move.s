.export _screen_move_up
.export _screen_move_down
.export _screen_move_left
.export _screen_move_right

.importzp ptr1, ptr2

.if .defined(__SIM6502__)
VIDEO_MEM = sim65_video_mem
.else
VIDEO_MEM = $0400
.endif

.macro move_up offset
.scope
    ldx #0
@loop:
    lda VIDEO_MEM + offset + 40, x
    sta VIDEO_MEM + offset, x
    inx
    cpx #240
    bne @loop
.endscope
.endmacro

.macro move_down offset
.scope
    ldx #240
@loop:
    lda VIDEO_MEM + offset, x
    sta VIDEO_MEM + offset + 40, x
    dex
    bne @loop
.endscope
.endmacro

.proc _screen_move_up
    move_up 0
    move_up 240
    move_up 480
    move_up 720
    rts
.endproc

.proc _screen_move_down
    move_down 720
    move_down 480
    move_down 240
    move_down 0
    rts
.endproc

.macro incrow addr
    clc
    lda addr
    adc #40
    sta addr
    lda addr + 1
    adc #0
    sta addr + 1
.endmacro

.macro resetmem ptr, addr
    lda #<(addr)
    sta ptr
    lda #>(addr)
    sta ptr + 1
.endmacro

.proc _screen_move_left
    resetmem @innerloop + 1, VIDEO_MEM + 1
    resetmem @innerloop + 4, VIDEO_MEM

    ldy #25
@outerloop:
    ldx #0
@innerloop:
    lda VIDEO_MEM + 1, x
    sta VIDEO_MEM, x
    inx
    cpx #39
    bne @innerloop
    incrow @innerloop + 1
    incrow @innerloop + 4
    dey
    bne @outerloop
    rts
.endproc

.proc _screen_move_right
    resetmem @innerloop + 1, VIDEO_MEM - 1
    resetmem @innerloop + 4, VIDEO_MEM

    ldy #25
@outerloop:
    ldx #39
@innerloop:
    lda VIDEO_MEM, x
    sta VIDEO_MEM + 1, x
    dex
    bne @innerloop
    incrow @innerloop + 1
    incrow @innerloop + 4
    dey
    bne @outerloop
    rts
.endproc

.segment "BSS"


.if .defined(__SIM6502__)
sim65_video_mem: .res 1024
.endif