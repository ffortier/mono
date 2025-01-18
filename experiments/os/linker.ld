ENTRY(_start)

SECTIONS
{
	. = 0x100000;

	.text : {
		*(multiboot)
		*(.kernel)
		*(.text)
	}
	.data ALIGN(4096) : {
		*(.data)
	}
	.rodata ALIGN(4096) : {
		*(.rodata)
	}
	.bss ALIGN(4096) : {
		*(COMMON)
		*(.bss)
	}
	.asm ALIGN(4096) : {
		*(.asm)
	}
}