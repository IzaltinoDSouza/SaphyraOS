section .text	

keyboard_enable:
	sti
	call a20wait_input
	mov al,0x0e
	out 0x64,al
	ret
keyboard_disable:
	cli
	call a20wait_input
	mov al,0xad
	out 0x64,al
	ret

a20wait_input:
	in al,0x64
	test al,0b10
	jnz a20wait_input
	ret
a20wait_output:
	in al,0x64
	test al,0b1
	jz a20wait_output
	ret

a20_enable:
	call keyboard_disable
	
	call a20wait_input
	mov al,0xd0			;send a command to read output port
	out 0x64,al			;and it will put on input buffer
	
	call a20wait_output
	in al,0x60			;read input buffer to get output port
	push eax			;and store output port value on stack
	
	call a20wait_input
	mov al,0xd1			;send a command to write output port
	out 0x64,al
	
	call a20wait_input
	pop eax	
	or al,0b10			;enable A20 (2 bit)
	out 0x60,al
	
	call keyboard_enable

	call a20wait_input

	ret

;output
;	cr status
; 		0 = disable
;		1 = enable
a20_check:
 	call keyboard_disable
	
	call a20wait_input
	mov al,0xd0			;send a command to read output port
	out 0x64,al			;and it will put on input buffer
	
	call a20wait_output
	xor eax,eax
	in al,0x60			;read input buffer to get output port
	and al,0b10			;and check output port if 2 bit(A20) is enable
	
	cmp al,0b10
	je .a20_enable
	jmp .a20_disable
	call keyboard_enable
.a20_enable:
	call keyboard_enable
	stc
	jmp .done
.a20_disable:
	clc
	jmp .done
.done:
	ret
