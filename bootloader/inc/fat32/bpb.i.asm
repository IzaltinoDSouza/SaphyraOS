;SaphyraOS © All Right Reserved
;Author  : IzaltinoDSouza
;Date    : February 22,2023

section .bss
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
