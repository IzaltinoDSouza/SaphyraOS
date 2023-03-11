;SaphyraOS © All Right Reserved
;Author  : IzaltinoDSouza
;Date    : February 22,2023

section .text
;	input
;		si  = address of data1
;		di  = address of data2
;		ecx = how many bytes of data to compare if equal 
;	output
;		cf status
;			0 = equal
;			1 = not equal
bytes_compare:
.compare:
	mov al,[si]
	mov dl,[di]
	cmp al,dl
	jne .not_equal
	inc si
	inc di
	loop .compare
	clc
	ret
.not_equal:
	stc
	ret
