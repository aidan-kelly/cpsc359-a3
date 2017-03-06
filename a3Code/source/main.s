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

	mov	r0, #9
	mov	r1, #1
	bl	Init_GPIO

	mov	r0, #10
	mov	r1, #0
	bl	Init_GPIO

	mov	r0, #11
	mov	r1, #1
	bl	Init_GPIO

	bl	Read_SNES
	
haltLoop$:
	b	haltLoop$

//-----------------------------------------------------------------------------------------------------
//r0 = pin
//r1 = function
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
//r0 = what to write
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
	cmp	r0, #0
	beq	Clock_W_0
	cmp	r0, #1
	beq	Clock_W_1
Clock_W_0:
	ldr	r1, =0x3f200028
	mov	r2, #1
	lsl	r2, #11
	str	r2, [r1]
	b	Write_Clock_DONE
Clock_W_1:	
	ldr	r1, =0x3f20001c
	mov	r2, #1
	lsl	r2, #11
	str	r2, [r1]	
Write_Clock_DONE:
	mov	pc,lr
//-----------------------------------------------------------------------------------------------------
Read_Data:
	ldr	r1, =0x3f200034
	ldr	r2, [r1]
	mov	r3, #1
	lsl	r3, #10
	and	r2, r3
	teq	r2, #0
	moveq	r4, #0
	movne	r4, #1
Read_Data_DONE:
	mov	pc, lr
//-----------------------------------------------------------------------------------------------------
//r0 = time in microseconds
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

	mov	r0, #1
	bl	Write_Clock


startOfLoop:

//	ldr	r0, =PressB
//	mov	r1, #17
//	bl	WriteStringUART
	
	mov	r0, #1
	bl	Write_Latch

	mov	r0, #12
	bl	Wait

	mov	r0, #0
	bl	Write_Latch
	
	
	mov	r5, #0
	mov	r7, #0
	
pulseLoop:
	
	cmp	r5, #16
	bge	pulseLoopDone

	mov	r0, #6
	bl	Wait

	mov	r0, #0
	bl	Write_Clock
	
	mov	r0, #6
	bl	Wait

	bl	Read_Data

	lsl	r4, r5
	orr	r7, r4

	mov	r0, #1
	bl	Write_Clock
	
	add	r5, r5, #1
	b	pulseLoop


pulseLoopDone:	

//PROBLEM ALSO IN HERE SOMEWHERE
	
topCheckLoop:
	mov	r6, #1
	lsl	r6, #0
	and	r8, r6, r7
	cmp	r8, #0
	bne	next1

	ldr	r0, =PressB
	mov	r1, #17
	bl	WriteStringUART
next1:	
	mov	r6, #1
	lsl	r6, #1
	and	r8, r6, r7
	cmp	r8, #0
	bne	next2

	ldr	r0, =PressY
	mov	r1, #17
	bl	WriteStringUART
next2:
	mov	r6, #1
	lsl	r6, #2
	and	r8, r6, r7
	cmp	r8, #0
	bne	next3

	ldr	r0, =PressSelect
	mov	r1, #22
	bl	WriteStringUART
next3:

	mov	r6, #1
	lsl	r6, #3
	and	r8, r6, r7
	cmp	r8, #0
	bne	next4

	ldr	r0, =TermMessage
	mov	r1, #29
	bl	WriteStringUART
	b	haltLoop$
next4:

	mov	r6, #1
	lsl	r6, #4
	and	r8, r6, r7
	cmp	r8, #0
	bne	next5

	ldr	r0, =PressDUp
	mov	r1, #24
	bl	WriteStringUART
next5:
	mov	r6, #1
	lsl	r6, #5
	and	r8, r6, r7
	cmp	r8, #0
	bne	next6

	ldr	r0, =PressDDown
	mov	r1, #26
	bl	WriteStringUART
next6:
	mov	r6, #1
	lsl	r6, #6
	and	r8, r6, r7
	cmp	r8, #0
	bne	next7

	ldr	r0, =PressDLeft
	mov	r1, #26
	bl	WriteStringUART
next7:
	mov	r6, #1
	lsl	r6, #7
	and	r8, r6, r7
	cmp	r8, #0
	bne	next8

	ldr	r0, =PressDRight
	mov	r1, #27
	bl	WriteStringUART
next8:
	mov	r6, #1
	lsl	r6, #8
	and	r8, r6, r7
	cmp	r8, #0
	bne	next9

	ldr	r0, =PressA
	mov	r1, #17
	bl	WriteStringUART
next9:
	mov	r6, #1
	lsl	r6, #9
	and	r8, r6, r7
	cmp	r8, #0
	bne	next10

	ldr	r0, =PressX
	mov	r1, #17
	bl	WriteStringUART
next10:
	mov	r6, #1
	lsl	r6, #10
	and	r8, r6, r7
	cmp	r8, #0
	bne	next11

	ldr	r0, =PressLeft
	mov	r1, #20
	bl	WriteStringUART
next11:
	mov	r6, #1
	lsl	r6, #11
	and	r8, r6, r7
	cmp	r8, #0
	bne	next12

	ldr	r0, =PressRight
	mov	r1, #21
	bl	WriteStringUART
next12:	
		
CheckLoopDone:	

	b	startOfLoop
	
Read_SNES_DONE:
	mov	pc, lr
//-----------------------------------------------------------------------------------------------------
//WEIRD PROBLEM LIES WITHIN
Print_Message:
	cmp	r0, #0
	beq	BPUSH
	
	cmp	r0, #1
	beq	YPUSH
	
	cmp	r0, #2
	beq	SELPUSH
	
	cmp	r0, #3
	beq	STAPUSH
	
	cmp	r0, #4
	beq	DUPPUSH
	
	cmp	r0, #5
	beq	DDOWNPUSH
	
	cmp	r0, #6
	beq	DLEFTPUSH
	
	cmp	r0, #7
	beq	DRIGHTPUSH
	
	cmp	r0, #8
	beq	APUSH
	
	cmp	r0, #9
	beq	XPUSH
	
	cmp	r0, #10
	beq	LEFTPUSH
	
	cmp	r0, #11
	beq	RIGHTPUSH
	
	b	Print_Message_DONE	
BPUSH:
	ldr	r0, =PressB
	mov	r1, #17
	bl	WriteStringUART
	b	Print_Message_DONE
YPUSH:

	ldr	r0, =PressY
	mov	r1, #17
	bl	WriteStringUART
	b	Print_Message_DONE
	
SELPUSH:

	ldr	r0, =PressSelect
	mov	r1, #22
	bl	WriteStringUART
	b	Print_Message_DONE
	
DUPPUSH:
	ldr	r0, =PressDUp
	mov	r1, #24
	bl	WriteStringUART
	b	Print_Message_DONE
DDOWNPUSH:
	ldr	r0, =PressDDown
	mov	r1, #26
	bl	WriteStringUART
	b	Print_Message_DONE
	
DLEFTPUSH:
	ldr	r0, =PressDLeft
	mov	r1, #26
	bl	WriteStringUART
	b	Print_Message_DONE
DRIGHTPUSH:
	ldr	r0, =PressDRight
	mov	r1, #27
	bl	WriteStringUART
	b	Print_Message_DONE
APUSH:
	ldr	r0, =PressA
	mov	r1, #17
	bl	WriteStringUART
	b	Print_Message_DONE
	
XPUSH:
	ldr	r0, =PressX
	mov	r1, #17
	bl	WriteStringUART
	b	Print_Message_DONE
	
LEFTPUSH:
	ldr	r0, =PressLeft
	mov	r1, #20
	bl	WriteStringUART
	b	Print_Message_DONE
RIGHTPUSH:
	ldr	r0, =PressRight
	mov	r1, #21
	bl	WriteStringUART
	b	Print_Message_DONE
STAPUSH:
	ldr	r0, =TermMessage
	mov	r1, #29
	bl	WriteStringUART
	b	haltLoop$

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
PressB:
	.ascii	"\r\nYou pressed B\r\n"
PressY:
	.ascii	"\r\nYou pressed Y\r\n"
PressSelect:
	.ascii	"\r\nYou pressed SELECT\r\n"
PressDUp:
	.ascii	"\r\nYou pressed D-Pad UP\r\n"
PressDDown:
	.ascii	"\r\nYou pressed D-Pad DOWN\r\n"
PressDLeft:
	.ascii	"\r\nYou pressed D-Pad LEFT\r\n"
PressDRight:
	.ascii	"\r\nYou pressed D-Pad RIGHT\r\n"
PressA:
	.ascii	"\r\nYou pressed A\r\n"
PressX:
	.ascii	"\r\nYou pressed X\r\n"
PressLeft:
	.ascii	"\r\nYou pressed LEFT\r\n"
PressRight:
	.ascii	"\r\nYou pressed RIGHT\r\n"
TermMessage:
	.ascii	"\r\nProgram is terminating...\r\n"
