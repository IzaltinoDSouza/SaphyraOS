;SaphyraOS © All Right Reserved
;Author  : IzaltinoDSouza
;Date    : February 22,2023

ATTR_READ_ONLY	EQU 0x01,
ATTR_HIDDEN 	EQU 0x02,
ATTR_SYSTEM 	EQU 0x04,
ATTR_VOLUME_ID	EQU 0x08,
ATTR_DIRECTORY	EQU 0x10,
ATTR_ARCHIVE	EQU 0x20,
ATTR_LONG_NAME 	EQU ATTR_READ_ONLY | ATTR_HIDDEN | ATTR_SYSTEM | ATTR_VOLUME_ID

DIR_NAME_OFFSET 				EQU 0
DIR_Attr_OFFSET 				EQU 11
DIR_NTRes_OFFSET 				EQU 12
DIR_CrtTimeTenth_OFFSET 		EQU 13
DIR_CrtTime_OFFSET 				EQU 14
DIR_CrtDate_OFFSET 				EQU 16
DIR_LstAccDate_OFFSET_OFFSET	EQU 18
DIR_FstClusHI_OFFSET			EQU 20
DIR_WrtTime_OFFSET				EQU 22
DIR_WrtDate_OFFSET 				EQU 24
DIR_FstClusLO_OFFSET 			EQU 26
DIR_FileSize_OFFSET 			EQU 28

DIR_NAME_MAX_SIZE EQU 11

section .data
fat_ls_fail:
	db "Fat32 ls fail",0xd,0xa,0
	
DIR_ENTRY_ADDRESS EQU 0x500 ; 0x500 normaly this address is safe to use
							; but be careful to check dependencies
							; 30*1024 / 512 (assume that sector size is 512)
							; less than 60 sector

section .text
;NOTE only list the short name
;input
;	eax = cluster
;output
;	none
fat32_ls_command:
	xor ecx,ecx
	mov cl,[BPB.BPB_SecPerClus]	;number sectors per cluster
	mov si,DIR_ENTRY_ADDRESS
	call fat32_read_cluster
	jc fat_ls_fail
	
	mov ecx,16
	mov si,DIR_ENTRY_ADDRESS
.ls:
	push si
	push ecx
	
	mov cl,[si+DIR_Attr_OFFSET]
	cmp cl,ATTR_DIRECTORY
	je .show
	mov cl,[si+DIR_Attr_OFFSET]
	cmp cl,ATTR_ARCHIVE
	je .show
	jmp .skip
.show:
		call bios_printstr
		mov al,' '
		call bios_printchar
		mov al,0xd
		call bios_printchar
		mov al,0xa
		call bios_printchar
	.skip:
	pop ecx
	pop si
	add si,32
	loop .ls
.done:
	ret
	
;input
;	eax = cluster
;	di  = file / dir name (fat32 short name)
;output
;	cf status
;		0 = equal
;		1 = not equal
;	si = dir entry
fat32_find:
	xor ecx,ecx
	mov cl,[BPB.BPB_SecPerClus]	;number sectors per cluster
	mov si,DIR_ENTRY_ADDRESS
	call fat32_read_cluster
	jc fat_ls_fail
	
	mov ecx,16
	mov si,DIR_ENTRY_ADDRESS
	
.ls:
	push di
	push si
	push ecx
	mov ecx,DIR_NAME_MAX_SIZE
	call bytes_compare
	pop ecx
	pop si
	pop di
	jc .skip
		clc		;found
		jmp .done
	.skip:
	add si,32
	loop .ls

	stc			;not found
.done:
	ret
	


;input
;	si = dir_entry address
;output
;	eax = cluster
get_dir_entry_cluster:
	xor eax,eax
	xor edx,edx
	mov ax,[si+DIR_FstClusHI_OFFSET]
	mov dx,[si+DIR_FstClusLO_OFFSET]
	shl eax,16
	or eax,edx
