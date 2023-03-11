;SaphyraOS © All Right Reserved
;Author  : IzaltinoDSouza
;Date    : February 13,2023

section .bss
;Disk struct to use LBA address
DiskAddressPacket:
	.size_of_packet  resb 1
	.reserved 		 resb 1	
	.sector_total 	 resw 1
	.buffer 		 resd 1
	.lba_lo			 resd 1
	.lba_hi 		 resd 1

section .text
;bios read sector (lba)
;	input
;		ebx = memory address (to where to put read data)
;		eax = lba (sector number start from 0)
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
