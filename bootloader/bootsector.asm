;SaphyraOS © All Right Reserved
;Author  : IzaltinoDSouza
;Date    : February 13,2023

;It's essential to emphasize that due to the lack of real hardware testing.
;I recommend that only run the binary of this code in a virtual machine environment
;such as qemu,bochs or similar.

[bits 16]
[org 0x7c5a]		;0x7c00 + 0x5a  
					;BIOS load bootcode memory address 0x7c00
					;but Fat32 bootcode is on offset 0x5a of that address

jmp start

section .bss

;Disk struct to use LBA address
DiskAddressPacket:
	.size_of_packet  resb 1
	.reserved 		 resb 1	
	.sector_total 	 resw 1
	.buffer 		 resd 1
	.lba_lo			 resd 1
	.lba_hi 		 resd 1

;BIOSParameterBlock see Fat32 spec for more info

BOOTCODE_SIZE		EQU 420
BPB:
	.BS_jmpBoot 	 resb 3
	.BS_OEMName 	 resb 8
	.BPB_BytesPerSec resw 1
	.BPB_SecPerClus  resb 1
	.BPB_RsvdSecCnt  resw 1
	.BPB_NumFATs 	 resb 1
	.BPB_RootEntCnt  resw 1
	.BPB_TotSec16 	 resw 1
	.BPB_Media 		 resb 1
	.BPB_FATSz16 	 resw 1
	.BPB_SecPerTrk 	 resw 1
	.BPB_NumHeads 	 resw 1
	.BPB_HiddSec  	 resd 1
	.BPB_TotSec32 	 resd 1
;FAT32
	.BPB_FATSz32 	 resd 1
	.BPB_ExtFlags 	 resw 1
	.BPB_FSVer 		 resw 1
	.BPB_RootClus 	 resd 1
	.BPB_FSInfo 	 resw 1
	.BPB_BkBootSec 	 resw 1
	.BPB_Reserved 	 resb 12
	.BS_DrvNum 		 resb 1
	.BS_Reserved1 	 resb 1
	.BS_BootSig 	 resb 1
	.BS_VolID 		 resd 1
	.BS_VolLab 		 resb 11
	.BS_FilSysType   resb 8
;boot_code and signature
	.bootcode		resb BOOTCODE_SIZE
	.boot_signature resw 1	

section .data
;welcome_msg:
	;db "SaphyraOS",0x0d,0xa,0
bootsy_filename:
	db "BOOT    SY "
BOOTSY_FILENAME_LEN EQU $-bootsy_filename

drive_num:
	db 0
fat32_data_sector:
	dd 0

;fail message
find_bootsy_fail_msg:
	db "boot.sy not found",0
read_bootsy_fail_msg:
	db "read boot.sy fail",0
fat32_fail_msg:
	db "fat32 fail",0
everything_fail_msg:
	db "Everything fails",0

section .text
start:
	mov [drive_num],dl
	
	;Stack Setup
	mov ax,0x7e00
	mov ss,ax
	
	;mov si,welcome_msg
	;call bios_printstr
		
	;Load BIOSParameterBlock from disk
	mov ebx,BPB
	mov eax,0		;lba
	mov cx,	1		;sector_total

	call bios_read_sector_lba
	jc load_bpb_fail
	
	;debug only
	;it will show SaphyraOS and garbage after it
	;lea si,BPB.BS_VolLab
	;call printstr

	;setup data_sector
	call fat32_calc_and_set_data_sector
		
	mov eax,[BPB.BPB_RootClus]	;root cluster
	mov ecx,1					;number of total sector to be read
	mov si,0x500				;where to put read data
	
	call fat32_read_cluster
	jc fat32_read_cluster_fail_root_cluster
	
	mov si,0x500				;where data was loaded SEE code above
	mov ecx,16					;16 dir_entry 
	call find_bootsy			;try to find boot.sy in short name fat32
	jc bootloader_fail_find_bootsy
	
	;SEE find_bootsy output
	;eax = cluster
	;ecx = size (bytes)

	;'find_bootsy' will return ecx in bytes
	;and 'fat32_read_cluster' expect ecx to be the number of sectors
	;1 sector can have N bytes of size
	call fat32_convert_from_bytes_to_sectors
	
	mov si,0x7e00 ;boot.sy will loaded there
	call fat32_read_cluster
	jc bootloader_fail_read_bootsy_data

	;pass to next stage
	mov eax,[fat32_data_sector]
	mov dl,[drive_num]

	jmp 0x7e00

;if you will is here, this meaning that load,find and boot 'boot.sy' fail 
everything_fail:
	mov si,everything_fail_msg
	call bios_printstr
	cli
	hlt

load_bpb_fail:
fat32_read_cluster_fail_root_cluster:
	mov si,fat32_fail_msg
	call bios_printstr
	cli
	hlt

bootloader_fail_find_bootsy:
	mov si,find_bootsy_fail_msg
	call bios_printstr
	cli
	hlt

bootloader_fail_read_bootsy_data:
	mov si,read_bootsy_fail_msg
	call bios_printstr
	cli
	hlt

	
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

;find_bootsy
;	input
;		si  = memory address (from where fat32 dir_entry was loaded)
;		ecx = total dir_entry (total dir entry loaded)
;	output
;		cf status
;			0 = found
;			1 = not found
;		eax = boot.sy cluster (where to find it)
;		ecx = boot.sy size (bytes)
;	
find_bootsy:
	;bytes compare
	pusha	;save guard
	mov di,bootsy_filename
	mov ecx,BOOTSY_FILENAME_LEN
	call bytes_compare
	popa	;save guard
	
	jc .skip	;if not equal skip this
		;only for debug
		;call bios_printstr
		;mov al,0xd
		;call bios_printchar
		;mov al,0xa
		;call bios_printchar
		
		;set bootsy useful information		
		;combine cluster HI (bit) and LO (16 bit)
		xor eax,eax
		xor edx,edx
		mov ax,[si+20]		;cluster HI
		mov dx,[si+26]		;cluster LO
		shl eax,16
		or eax,edx
		
		mov ecx,[si+28]		;boot.sy size
		clc
		
		jmp .done
	.skip:
	
	add si,32
	loop find_bootsy
	stc

	.done:
		ret

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

fat32_calc_and_set_data_sector:
	;Formula
	;	BPB_RsvdSecCnt + (BPB_NumFATs*BPB_FATSz32)

	xor eax,eax	;clear ah and al : to avoid possible garbage
	mov byte al,[BPB.BPB_NumFATs]

	mov dword ebx,[BPB.BPB_FATSz32]
	mul ebx

	xor edx,edx ;clear dh and dl : to avoid possible garbage
	mov dx,[BPB.BPB_RsvdSecCnt]
	add eax,edx

	mov [fat32_data_sector],eax

.done:	
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

;bios read sector (lba)
;	input
;		ebx = buffer
;		eax = lba
;		cx = sector_total
;	output
;		cf status
;			0 = supported
;			1 = not supported
;		ah = error code
;
bios_read_sector_lba:
	mov byte [DiskAddressPacket.size_of_packet],16
	mov word [DiskAddressPacket.sector_total],cx
	mov dword [DiskAddressPacket.buffer],ebx
	mov dword [DiskAddressPacket.lba_lo],eax
	mov dword [DiskAddressPacket.lba_hi],0		;FIXME: hardcoded number
	
	mov dl,[drive_num]
	
	mov si,DiskAddressPacket
	mov ah,0x42
	int 0x13

.done:
	ret


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

;bios printchar
;	input
;		al = ascii
;	output
;		none
;bios_printchar:
;	mov ah,0x0e
;	xor bh,bh
;	int 0x10
;	ret
