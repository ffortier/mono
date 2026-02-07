.export _update_cells

.importzp tmp1, tmp2, ptr1, ptr2, ptr3

ALIVE = 81
DEAD  = 32
COL   = 40
ROW   = 25
VIDEO_MEM = $0400
COLOR_MEM = $d800

;; Renders a block in the video_mem using the count_mem
.macro render offset, size
.scope
    ldx #0

@loop:
    lda VIDEO_MEM + offset, x                       ; if (VIDEO_MEM + offset)[x] == ALIVE
    cmp #ALIVE
    bne @dead

@alive:
    lda count_mem + offset, x                       ;   if (count_mem + offset)[x] != 2 &&  (count_mem + offset)[x] != 3
.if .defined(COLORIZE)
    sta COLOR_MEM + offset, x
.endif
    cmp #2
    beq @touched
    cmp #3
    beq @touched
    lda #DEAD
    sta VIDEO_MEM + offset, x                       ;       (VIDEO_MEM + offset)[x] == DEAD
    jmp @touched

@dead:                                              ; else is dead
    lda count_mem + offset, x
.if .defined(COLORIZE)
    sta COLOR_MEM + offset, x
.endif
    cmp #3                                          ;   if (count_mem + offset)[x] == 3
    bne @touched
    lda #ALIVE
    sta VIDEO_MEM + offset, x                       ;       (VIDEO_MEM + offset)[x] == ALIVE

@touched:
.if .defined(DEBUG)
    lda count_mem + offset, x
    clc
    adc #'0'
    sta VIDEO_MEM + offset, x
.endif

    inx
    cpx #size
    bne @loop
.endscope
.endmacro

.macro init_counts
.scope

    lda #0
    ldx #250
@loop:
    dex
    sta count_mem + 0, x
    sta count_mem + 250, x
    sta count_mem + 500, x
    sta count_mem + 750, x
    bne @loop

.endscope
.endmacro

.macro count_first_row
.scope
count_row_mem = count_mem
video_row_mem = VIDEO_MEM

@top_left:
    lda video_row_mem
    cmp #ALIVE
    bne @end_top_left
    inc count_row_mem + 1
    inc count_row_mem + COL
    inc count_row_mem + COL + 1

@end_top_left:
    ldx #1
@loop:
    lda video_row_mem, x
    cmp #ALIVE
    bne @end_loop
    inc count_row_mem - 1, x
    inc count_row_mem + 1, x
    inc count_row_mem + COL - 1, x
    inc count_row_mem + COL, x
    inc count_row_mem + COL + 1, x

@end_loop:
    inx
    cpx #(COL - 1)
    bne @loop

@top_right:
    lda video_row_mem + COL - 1
    cmp #ALIVE
    bne @end_top_right
    inc count_row_mem + COL - 2
    inc count_row_mem + (2 * COL) - 2
    inc count_row_mem + (2 * COL) - 1

@end_top_right:
.endscope
.endmacro

.macro count_last_row
.scope
count_row_mem = count_mem + (ROW - 1) * COL
video_row_mem = VIDEO_MEM + (ROW - 1) * COL

@top_left:
    lda video_row_mem
    cmp #ALIVE
    bne @end_top_left
    inc count_row_mem + 1
    inc count_row_mem - COL
    inc count_row_mem - COL + 1

@end_top_left:
    ldx #1
@loop:
    lda video_row_mem, x
    cmp #ALIVE
    bne @end_loop
    inc count_row_mem - 1, x
    inc count_row_mem + 1, x
    inc count_row_mem - COL - 1, x
    inc count_row_mem - COL, x
    inc count_row_mem - COL + 1, x

@end_loop:
    inx
    cpx #(COL - 1)
    bne @loop

@top_right:
    lda video_row_mem + COL - 1
    cmp #ALIVE
    bne @end_top_right
    inc count_row_mem + COL - 2
    inc count_row_mem - 2
    inc count_row_mem - 1

@end_top_right:
.endscope
.endmacro

.macro reset_self_mutating_address label
    lda #<(VIDEO_MEM + COL)
    sta label + 1
    lda #>(VIDEO_MEM + COL)
    sta label + 2
.endmacro

.macro inc_self_mutating_address label, value
    lda label + 1
    clc
    adc #value
    sta label + 1
    lda label + 2
    adc #0
    sta label + 2
.endmacro

.macro inc_indirect_y address
    lda (address), y
    clc
    adc #1
    sta (address), y
.endmacro

.macro inc_ptr address, value
    lda address
    clc
    adc #value
    sta address
    lda address + 1
    adc #0
    sta address + 1
.endmacro

.macro count_middle_rows
.scope

    lda #<count_mem                                 ; ptr1 = previous row
    sta ptr1
    lda #>count_mem
    sta ptr1 + 1

    lda #<(count_mem + COL)                         ; ptr2 = current row
    sta ptr2
    lda #>(count_mem + COL)
    sta ptr2 + 1

    lda #<(count_mem + COL * 2)                     ; ptr3 = next row
    sta ptr3
    lda #>(count_mem + COL * 2)
    sta ptr3 + 1

    lda #(ROW - 2)
    sta tmp1                                        ; tmp1 = number of rows to process

    reset_self_mutating_address @left
    reset_self_mutating_address @loop
    reset_self_mutating_address @right

@left:
    lda VIDEO_MEM + COL                             ; Self-mutating address to the first column
    cmp #ALIVE
    bne @center

    ldy #0
    inc_indirect_y ptr1                             ; Update previous row
    inc_indirect_y ptr3                             ; Update next row
    iny
    inc_indirect_y ptr1                             ; Update previous row
    inc_indirect_y ptr2                             ; Update current row
    inc_indirect_y ptr3                             ; Update next row

@center:
    clc                                             ; Clear carry for inc_indirect_y
    ldx #1
@loop:
    lda VIDEO_MEM + COL, x                          ; Self-mutating address to the middle columns
    cmp #ALIVE
    bne @next

    txa
    tay
    dey
    inc_indirect_y ptr1                             ; Update previous row
    inc_indirect_y ptr2                             ; Update current row
    inc_indirect_y ptr3                             ; Update next row
    iny
    inc_indirect_y ptr1                             ; Update previous row
    inc_indirect_y ptr3                             ; Update next row
    iny
    inc_indirect_y ptr1                             ; Update previous row
    inc_indirect_y ptr2                             ; Update current row
    inc_indirect_y ptr3                             ; Update next row
@next:
    inx
    cpx #(COL - 1)
    bne @loop

@right:
    lda VIDEO_MEM + COL, x                          ; Self-mutating address to the last column
    cmp #ALIVE
    bne @end

    ldy #(COL - 2)
    inc_indirect_y ptr1                             ; Update previous row
    inc_indirect_y ptr2                             ; Update current row
    inc_indirect_y ptr3
    iny
    inc_indirect_y ptr1                             ; Update previous row
    inc_indirect_y ptr3                             ; Update next row
@end:
    inc_self_mutating_address @left, COL
    inc_self_mutating_address @loop, COL
    inc_self_mutating_address @right, COL
    inc_ptr ptr1, COL
    inc_ptr ptr2, COL
    inc_ptr ptr3, COL

    dec tmp1
    beq @skip
    jmp @left
@skip:

.endscope
.endmacro

.proc _update_cells

    init_counts

    count_first_row
    count_middle_rows
    count_last_row

    render 0, 250                                   ; Render the symbols, applying the gol logic
    render 250, 250
    render 500, 250
    render 750, 250

    rts
.endproc

.segment "BSS"
count_mem: .res 1024
