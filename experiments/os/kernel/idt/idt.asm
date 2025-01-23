section .asm

global enable_interrupts
global disable_interrupts
global idt_load
global int_21
global no_interrupt

extern int21_handler
extern no_interrupt_handler

enable_interrupts:
    sti
    ret

disable_interrupts:
    cli
    ret

idt_load:
    push ebp
    mov ebp, esp

    mov ebx, [ebp+8]
    lidt [ebx]

    pop ebp
    ret

int_21:
    cli
    pushad
    call int21_handler
    popad
    sti
    iret

no_interrupt:
    cli
    pushad
    call no_interrupt_handler
    popad
    sti
    iret