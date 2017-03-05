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

//-----------------------------------------------------------------------------------------------------
Init_GPIO:

	cmp	r0, #9
	beq	LATCH
	cmp	r0, #10
	beq	DATA
	cmp	r0, #11
	beq	CLOCK
	b	Init_GPIO_DONE

LATCH:

	ldr	r0, =0x3f200000
	ldr	r2, [r0]
	mov	r3, #7
	lsl	r3, #27
	bic	r2, r3
	lsl	r1, #27
	orr	r2, r1
	str	r2, [r0]

	b	Init_GPIO_DONE
	
DATA:
	ldr	r0, =0x3f200004
	ldr	r2, [r0]
	mov	r3, #7
	lsl	r3, #0
	bic	r2, r3
	lsl	r1, #0
	orr	r2, r1
	str	r2, [r0]

	b	Init_GPIO_DONE
	
CLOCK:	
	ldr	r0, =0x3f200004
	ldr	r2, [r0]
	mov	r3, #7
	lsl	r3, #3
	bic	r2, r3
	lsl	r1, #3
	orr	r2, r1
	str	r2, [r0]

	b	Init_GPIO_DONE

Init_GPIO_DONE:
	
	mov	pc, lr
//-----------------------------------------------------------------------------------------------------
Write_Latch:
	cmp	r0, #0
	beq	Latch_W_0
	cmp	r0, #1
	beq	Latch_W_1
Latch_W_0:
	ldr	r1, =0x3f200028
	mov	r2, #1
	lsl	r2, #9
	str	r2, [r1]
	b	Write_Latch_DONE
Latch_W_1:
	ldr	r1, =0x3f20001c
	mov	r2, #1
	lsl	r2, #9
	str	r2, [r1]
Write_Latch_DONE:
	mov	pc, lr
//-----------------------------------------------------------------------------------------------------
Write_Clock:
Write_Clock_DONE:
	mov	pc,lr
//-----------------------------------------------------------------------------------------------------
Read_Data:
Read_Data_DONE:
	mov	pc, lr
//-----------------------------------------------------------------------------------------------------
Wait:
	ldr	r1, =0x3f003004
	ldr	r2, [r1]
	add	r2, r0
waitLoop:
	ldr	r3, [r1]
	cmp	r2, r3
	bhi	waitLoop
Wait_DONE:
	mov	pc, lr
//-----------------------------------------------------------------------------------------------------
Read_SNES:
Read_SNES_DONE:
	mov	pc, lr
//-----------------------------------------------------------------------------------------------------
Print_Message:
Print_Message_DONE:
	mov	pc, lr
//-----------------------------------------------------------------------------------------------------
	


.section .data  

ABuff:
	.rept	256
	.byte	0
	.endr

Names:
	.ascii	"\r\nCreated by Aidan Kelly, Sodienye Nkwonta and Montasir Bechir Nasir\r\n"
PleasePress:
	.ascii	"\r\nPlease press a button...\r\n"
