;SaphyraOS © All Right Reserved
;Author  : IzaltinoDSouza
;Date    : February 15,2023

[bits 16]
[org 0x7e00]

jmp start

section .bss
drive_num 			resb 1
fat32_data_sector 	resd 1

section .data
welcome_msg:
	db "SaphyraOS Stage 2",0x0d,0xa,0
a20_enable_msg:
	db "A20 enable",0x0d,0xa,0
a20_disable_msg:
	db "A20 disable",0x0d,0xa,0
kernel_not_found_msg:
	db "'sy/kernel.sy' not found",0x0d,0xa,0
sy_path_name:
	db "SY         "
bootsy_filename:
	db "BOOT    SY "
kernelsy_filename:
	db "KERNEL  SY "
section .text
start:
	;information pass to us (from bootloader)
	;eax = data sector
	;dl = drive number
	
	mov [fat32_data_sector],eax
	mov [drive_num],dl
	
	;stack setup
	mov ax,0x7c00	;512 bytes (NOTE need to be increased in future)
	mov ss,ax
	
	mov si,welcome_msg
	call bios_printstr
	
	call bios_detect_memory
	jc detect_memory_fail
	
	;debug only
	;lea si,[detected_memory_entry+0*20]
	;mov ecx,detected_memory_chunk_size
	;call hexdump
	

	call a20_enable
	call a20_check
	jnc a20_disable

	mov si,a20_enable_msg
	call bios_printstr
	
	call fat32_init
	
	;list file / dir on root cluster
	mov eax,[BPB.BPB_RootClus]	;root cluster
	call fat32_ls_command
	
	call find_kernel
	jc not_found_kernel
	
	call bios_get_vesa_information
	call bios_get_vesa_mode_information
	call bios_vesa_enable_mode
	;call bios_printstr
	call switch_to_protected_mode

end:
	cli
	hlt
not_found_kernel:
	mov si,kernel_not_found_msg
	call bios_printstr
	cli
	hlt 
a20_disable:
	mov si,a20_disable_msg
	call bios_printstr
	cli
	hlt

;input
;	none
;output
;	ecx = kernel size (in bytes)
find_kernel:
	mov eax,[BPB.BPB_RootClus]	;root cluster
	mov di,sy_path_name
	call fat32_find
	jc .not_found
	call get_dir_entry_cluster
	mov di,kernelsy_filename
	call fat32_find
	jc .not_found
	
	call get_dir_entry_cluster
	mov ecx,[si+DIR_FileSize_OFFSET]
	
	push ecx;save kernel size (in bytes)

	call fat32_convert_from_bytes_to_sectors
	mov si,0x500
	call fat32_read_cluster
	jc	end
	pop ecx
	clc
	ret
.not_found:
	stc
	ret

detect_memory_fail:
	cli
	hlt

switch_to_protected_mode:
	call gdt_enable
	
	mov eax, cr0
	or eax, 1			;enable paging
	mov cr0, eax
	
	jmp kernel_code:protected_mode


%include "inc/bios/print.i.asm"
%include "inc/bios/detect_memory.i.asm"
%include "inc/io/keyboard.i.asm"
%include "inc/gdt.i.asm"
;%include "debug.i.asm"
%include "inc/bios/disk.i.asm"
%include "inc/fat32/fat32.i.asm"
%include "inc/utils/compare.i.asm"
%include "inc/bios/vbe.i.asm"

[bits 32]

section .bss
		
section .text
protected_mode:
	cli	;disable interrupt,because it is not yet implement
	
	;setup
	mov ax,kernel_data
	mov ds,ax
	mov ss,ax
	mov es,ax
	
	call move_kernel_upper_address
	
	mov eax,detected_memory_entry
	xor ecx,ecx
	mov cx,[detected_memory_number_entries]
		
	mov ebx,vbe_mode_information
	
	jmp kernel_code:0x10000
	
	hlt

move_kernel_upper_address:
	mov esi,0x500
	mov edi,0x10000
.move:
	mov al,[esi]
	mov [edi],al
	inc edi
	inc esi
	loop .move
	ret
	
section .bss
	video_size resd 1
