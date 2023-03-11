;SaphyraOS © All Right Reserved
;Author  : IzaltinoDSouza
;Date    : February 22,2023

%include "inc/fat32/bpb.i.asm"
%include "inc/fat32/dir.i.asm"
%include "inc/fat32/utils.i.asm"

section .data
fat_init_fail:
	db "Fat32 int fail",0xd,0xa,0

section .bss
	fat_table resb 8*512 ; 4 KB (insted of BPB_BytesPerSec*BPB_FATSz32,
						 ; because realmode memory is too small to fit result of
						 ; BPB_BytesPerSec*BPB_FATSz32)
section .text

fat32_init:
	mov ebx,BPB ;memory address
	mov eax,0 	;lba (sector number start from 0)
	mov cx,1 	;sector_total
	call bios_read_sector_lba
	jc fat_init_fail
	
	mov eax,[BPB.BPB_RsvdSecCnt]	;fat table offset
	mov ebx,fat_table
	mov cx,8						;SEE fat_table (8*512)
	
	call bios_read_sector_lba
	jc fat_init_fail

	ret

;fat32 read cluster
;	input
;		eax = cluster
;		ecx = sector total
;		si  = memory address (its where the data will be loaded)
;	output
;		cf status
;			0 = ok
;			1 = error
;		ah = error code
;
fat32_read_cluster:
	;FORMULA
	;	cluster_sector = ((cluster - 2) * g_bpb->BPB_SecPerClus) + data_sector;
	
	sub eax,2 	;cluster - 2
	
	xor ebx,ebx	;clear bh and bl : to avoid possible garbage
	mov bl,[BPB.BPB_SecPerClus]
	
	mul ebx		;eax * BPB_SecPerClus
				;NOTE : this assume that eax * BPB_SecPerClus will fit eax
	
	mov edx,[fat32_data_sector]
	add eax,edx	;eax + data_sector
	
	;eax = cluster sector
	;cx  = sector total
	lea ebx,[si] ;buffer
	
	call bios_read_sector_lba

.done:
	ret
