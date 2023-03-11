;SaphyraOS © All Right Reserved
;Author  : IzaltinoDSouza
;Date    : February 22,2023

section .data
gdt_descriptor_table:	;(SEE Intel manual IA-32 Chapter 3)
	;Note which descriptor has only 8 bytes

	;========================= Null Descriptor ==============================
	dq 0				;null descriptor need to be fill (8 bytes) with zero


	;====================== Kernel Code Descriptor ==========================
	dw 0xffff			;segment limite from bit 0 to bit 15
	dw 0x0				;base address from bit 0-15
	db 0x0				;base address from bit 16-23
	;---------------------------------------------------------------------
						;type (4 bit)					1010 Read and Execute)
						;descriptor type (1 bit)		1 (code and data)
	db 0b1_00_1_1010
						;privilege level (2 bit)		00 (ring 0 aka kernel mode)
						;segment present (1 bit)		1 (present)
	;---------------------------------------------------------------------
						;segment limite from bit 16-19	0000
						;available for use (1 bit)		0 (used by cpu)
						;reserved (1 bit)				0 (always zero)
	db 0b1_1_0_0_0000
						;operation size	(1 bit)			1 (32 bit segment)
						;granuality (1 bit)				1 (4KB scale of segment limit)
	;---------------------------------------------------------------------
	db 0x0				;base address from bit 24-31


	;====================== Kernel Data Descriptor ==========================
	dw 0xffff			;segment limite from bit 0 to bit 15
	dw 0x0				;base address from bit 0-15
	db 0x0				;base address from bit 16-23
	;---------------------------------------------------------------------
						;type (4 bit)					0010 Read and Write)
						;descriptor type (1 bit)		1 (code and data)
	db 0b1_00_1_0010
						;privilege level (2 bit)		00 (ring 0 aka kernel mode)
						;segment present (1 bit)		1 (present)
	;---------------------------------------------------------------------
						;segment limite from bit 16-19	0000
						;available for use (1 bit)		0 (used by cpu)
						;reserved (1 bit)				0 (always zero)
	db 0b1_1_0_0_0000
						;operation size	(1 bit)			1 (32 bit segment)
						;granuality (1 bit)				1 (4KB scale of segment limit)
	;---------------------------------------------------------------------
	db 0x0				;base address from bit 24-31
	
GDT_DESCRIPTOR_TABLE_SIZE equ $ - gdt_descriptor_table
gdt_descriptor_table_entry:
	dw	GDT_DESCRIPTOR_TABLE_SIZE - 1	;limit of gdt
	dd	gdt_descriptor_table			;base of gdt


;Kernel Code/Data Descriptor Offset
kernel_code EQU 0x8
kernel_data EQU 0x10

section .text
gdt_enable:
	cli
	lgdt [gdt_descriptor_table_entry]
	sti
	ret
