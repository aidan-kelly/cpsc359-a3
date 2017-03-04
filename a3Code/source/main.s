.section    .init
.globl     _start

_start:
    b       main
    
.section .text

main:
    	mov     	sp, #0x8000 // Initializing the stack pointer
	bl		EnableJTAG // Enable JTAG
	bl	InitUART

	ldr	r0, =Names
	mov	r1, #70
	bl	WriteStringUART
	ldr	r0, =PleasePress
	mov	r1, #28
	bl	WriteStringUART
	
haltLoop$:
	b	haltLoop$


.section .data  

ABuff:
	.rept	256
	.byte	0
	.endr

Names:
	.ascii	"\r\nCreated by Aidan Kelly, Sodienye Nkwonta and Montasir Bechir Nasir\r\n"
PleasePress:
	.ascii	"\r\nPlease press a button...\r\n"
