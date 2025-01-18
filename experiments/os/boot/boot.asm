ORG 0x7c00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_init:
    jmp short _start
    nop

times 33 db 0

_start:
    jmp 0:.begin

.begin:
    cli
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti

.load_protected:
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32

gdt_start:      ; https://wiki.osdev.org/Global_Descriptor_Table
gdt_null:
    dd 0
    dd 0

gdt_code:
    dw 0xffff
    dw 0
    db 0
    db 0x9a
    db 11001111b
    db 0

gdt_data:
    dw 0xffff
    dw 0
    db 0
    db 0x92
    db 11001111b
    db 0

gdt_descriptor:
    dw $ - gdt_start
    dd gdt_start


[BITS 32]
load32:
    mov eax, 1
    mov ecx, 100
    mov edi, 0x00100000
    call ata_lba_read
    jmp CODE_SEG:0x00100000

ata_lba_read:       ; https://wiki.osdev.org/ATA_read/write_sectors
    mov ebx, eax
    
    shr eax, 24
    or eax, 0xe0
    mov dx, 0x1f6
    out dx, al

    mov eax, ecx
    mov dx, 0x1f2
    out dx, al

    mov eax, ebx
    mov dx, 0x1f3
    out dx, al
    
    mov dx, 0x1f4
    mov eax, ebx
    shr eax, 8
    out dx, al

    mov dx, 0x1f5
    mov eax, ebx
    shr eax, 16
    out dx, al

    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

.next:
    push ecx
.again:
    mov dx, 0x1f7
    in al, dx
    test al, 0
    jz .again

    mov ecx, 256
    mov dx, 0x1f0
    rep insw
    pop ecx
    loop .next
    ret



times 510-($ - $$) db 0
dw 0xaa55

buffer: