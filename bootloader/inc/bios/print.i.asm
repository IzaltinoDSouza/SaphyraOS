;SaphyraOS © All Right Reserved
;Author  : IzaltinoDSouza
;Date    : February 13,2023

section .text
	
;bios printstr
;	input
;		si = string
;	output
;		none
bios_printstr:
	lodsb	 ;load string byte from DS:(E)SI to register al
			 ;it will load the next charactere byte
			 ;NOTE : direction flag (DF) will determine the direction data
			 
	cmp al,0 ;check if its end of string
	je .done

	mov ah,0x0e
	xor bh,bh
	int 0x10
	
	jmp bios_printstr
		
.done:
	ret
	
;bios printstr
;	input
;		al = ascii
;	output
;		none
bios_printchar:
	mov ah,0x0e
	xor bh,bh
	int 0x10
	
.done:
	ret
