.section    .init
.globl     _start

_start:
    b       main
    
.section .text

main:
    	mov     	sp, #0x8000 // Initializing the stack pointer
	bl		EnableJTAG // Enable JTAG


	mov		r0, #6
	bl		Fibb

haltLoop$:
	b	haltLoop$


// Fibb(n)
// r0: n
// r0: Fibb(n)

Fibb:
	push		{r4, r5, lr}

	//if n ==0
	cmp		r0, #0
	moveq		r0, #1
	beq		end

	// if n == 1
	cmp		r0, #1
	beq		end

	mov		r4, r0

	// fibb(n-1)
	sub		r0, r4, #1
	bl		Fibb

	mov		r5, r0

	// fib(n-2)

	sub		r0, r4, #2
	bl		Fibb

	add		r0, r5

end:

	pop		{r4, r5, pc}




.section .data  

