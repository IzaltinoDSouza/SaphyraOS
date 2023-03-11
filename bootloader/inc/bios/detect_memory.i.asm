;SaphyraOS © All Right Reserved
;Author  : IzaltinoDSouza
;Date    : February 15,2023

section .bss
detected_memory_chunk:
	.base_address_lo	resd 1
	.base_address_hi 	resd 1
	.length_lo			resd 1
	.length_hi			resd 1	
	.type				resd 1
detected_memory_chunk_size  EQU $-detected_memory_chunk
detected_memory_max_entries EQU 32	;What is the maximum entries for e820?
detected_memory_entry:
	resb detected_memory_chunk_size*detected_memory_max_entries
detected_memory_number_entries:	resw 1

section .text
;input
;	none
;output
;	cr status
;		0 = ok
;		1 = error
;	ax : number of entries detected
bios_detect_memory:
	mov ebx,0
	mov di,detected_memory_entry
.detecting:
	mov eax,0x0000e820
	mov edx,0x534d4150
	mov ecx,detected_memory_chunk_size
	
	int 0x15
	
	jc .error
	
	cmp eax,0x534d4150
	jne .error
	
	;only for debug
	;pusha
	;mov si,di
	;mov ecx,20
	;call hexdump
	;popa
							;ebx has offset of next chunk, 
	cmp ebx,0				;if ebx is equal to zero,indicate no more chunk available
	je .done
	
	add di,detected_memory_chunk_size	;the place where to put the next chunk
	
	jmp .detecting
	
	jmp .done
.error:
	stc
	ret
.done:
	;Formula
	;	number of entries = (last entry - first entry) / detected_memory_chunk_size
	xor edx,edx		;because of division this need to be clear 
	mov si,detected_memory_entry
	sub di,si								;(last entry - first entry)
	lea eax,[di]
	mov ecx,detected_memory_chunk_size
	div ecx									;eax / detected_memory_chunk_size
	mov [detected_memory_number_entries],ax
	ret
