@this is comment

@the information that tells arm-none-eabi-as what arch. to assemble to 
	.cpu arm926ej-s
	.fpu softvfp

@this is code section
@note, we must have the main function for the simulator's linker script
	.text
	.align	2   @align 4 byte
	.global	main
main:

    @prologue
	stmfd	sp!, {r9, r10, fp, lr}
	add	fp, sp, #4

    @code body
	ldr	r10, [r1, #4]      @ load argv[1]
	mov r9, r10
loop:
	ldrb r0, [r10]
	cmp r0, #0
	addne r10, r10, #1
	bne loop
	sub r10, r10, #1

swap:
	cmp r9, r10
	bgt exit
	ldrb r0, [r10]
	cmp r0, #65
	blt less1
	cmpge r0, #90
	addle r0, r0, #32
less1:
	ldrb r3, [r9]
	cmp r3, #65
	blt less2
	cmpge r3, #90
	addle r3, r3, #32
less2:
	strb r0, [r9]
	strb r3, [r10]
	add r9, r9, #1
	sub r10, r10, #1
	b swap

exit:
	ldr r0, [r1, #4]
	bl printf
	
	@epilogue
	sub	sp, fp, #4
	ldmfd	sp!, {r9, r10, fp, lr}
	bx	lr

    .end
    
    