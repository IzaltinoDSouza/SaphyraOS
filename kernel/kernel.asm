;SaphyraOS © All Right Reserved
;Author  : IzaltinoDSouza
;Date    : February 23,2023

[bits 32]
[org 0x10000]

jmp kernel_entry

section .data
welcome_msg:
	db "SaphyraOS (Kernel)",0
	
section .text
kernel_entry:
	;eax = detected memory entry
	;ecx = detected memory number entries
	;ebx = vbe mode information
	;mov esi,welcome_msg
	;call printstr
end:
	cli
	hlt

;not works more,because I switch to 1024x768 graphical mode
;printstr:
;	mov edi,0xB8000
;.printchar:
;	lodsb
;	cmp al,0
;	je .done
;	
;	mov [edi+edx],al
;	mov byte [edi+edx+1],0b0_000_1_010
;	add edx,2
	
;	jmp .printchar

;.done:
;	ret
