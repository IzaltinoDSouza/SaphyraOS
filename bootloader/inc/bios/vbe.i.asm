;SaphyraOS © All Right Reserved
;Author  : OSDev.org,IzaltinoDSouza
;Date    : February 23,2023

section .data
vbe_information:
	.signature 				db "VBE2"
section .bss
	.version 				resw 1
	.oem_ptr 				resd 1
	.capabilities			resd 1 		
	.video_mode_ptr			resd 1	;ptr to a list of modes(16 bit) end with 0x0ffff
	.video_memory 			resw 1
	.oem_software_rev_ptr  	resw 1
	.oem_vendor_ptr 		resd 1
	.oem_product_name_ptr 	resd 1
	.oem_product_rev_ptr 	resd 1
	.reserved	 			resb 222
	.oem_data 				resb 256

section .bss
vbe_mode_information:
	.attributes 				resw 1
	.window_a 					resb 1
	.window_b 					resb 1
	.granularity 				resw 1
	.window_size 				resw 1
	.segment_a 					resw 1
	.segment_b 					resw 1
	.win_func_ptr 				resd 1
	.pitch 						resw 1
	.width 						resw 1
	.height 					resw 1
	.w_char 					resb 1
	.y_char 					resb 1
	.planes 					resb 1
	.bpp 						resb 1
	.banks 						resb 1
	.memory_model 				resb 1
	.bank_size 					resb 1
	.image_pages 				resb 1
	.reserved0 					resb 1
	.red_mask 					resb 1
	.red_position 				resb 1
	.green_mask 				resb 1
	.green_position 			resb 1
	.blue_mask 					resb 1
	.blue_position 				resb 1
	.reserved_mask 				resb 1
	.reserved_position 			resb 1
	.direct_color_attributes 	resb 1
	.framebuffer 				resd 1
	.off_screen_mem_off 		resd 1
	.off_screen_mem_size 		resw 1
	.reserved1 					resb 206
	
section .text
bios_get_vesa_information:
	mov ax,0x4f00
	mov di,vbe_information
	int 0x10
	cmp ax,0x004F	;magic number on success
	jne .fail
	clc
	jmp .done
.fail:
	stc
.done:
	ret

bios_get_vesa_mode_information:
	mov ax,0x4F01
	mov cx,0x118	;hardcoded mode 118 = 1024*768*24
	mov di,vbe_mode_information
	int 0x10
	cmp ax,0x004F	;magic number on success
	jne .fail
	jmp .done
.fail:
	stc
.done:
	ret
bios_vesa_enable_mode:
mov ax, 0x4F02
mov bx, 0x4_118 ;hardcoded mode 118 = 1024*768*24
	int 0x10
	jne .fail
	jmp .done
.fail:
	stc
.done:
	ret

