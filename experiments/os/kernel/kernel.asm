[BITS 32]

global _start

CODE_SEG equ 0x08
DATA_SEG equ 0x10

_start:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp

    in al, 0x92     ; https://wiki.osdev.org/A20_Line#Fast_A20_Gate
    or al, 2
    out 0x92, al

db "Hello World",0
    jmp $

times 512-($ - $$) db 0