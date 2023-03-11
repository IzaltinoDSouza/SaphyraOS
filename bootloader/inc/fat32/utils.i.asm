;SaphyraOS © All Right Reserved
;Author  : IzaltinoDSouza
;Date    : February 22,2023

section .text
;fat32 convert from bytes to number of sectors
;input
;	ecx = size(bytes)
;output
;	ecx = number of sector
fat32_convert_from_bytes_to_sectors:
	;convert size in bytes to number of sectors
	push eax	;save eax because it will change the value of it
	push edx	;save edx because it will change the value of it
	xor edx,edx ;clear for avoid garbage
	xor eax,eax	;clear for avoid garbage
	mov ax,[BPB.BPB_BytesPerSec]	;0x200
	xchg eax,ecx	;swap value eax into ecx / ecx into eax
	div ecx			;this was need bacause order of division

	;edx will contain value of remainder of above division
	cmp edx,0
	je skip
		inc eax	;increment number of sector,
				;because division contains remainder not zero
	skip:
	mov ecx,eax
	pop edx		;get back the old value of edx
	pop eax		;get back the old value of eax
.done:
	ret
