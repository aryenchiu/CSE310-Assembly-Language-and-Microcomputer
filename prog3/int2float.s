	.cpu arm926ej-s
	.fpu softvfp

	.text
	.align	2   @align 4 byte
	.global	main
main:
    @prologue
	stmfd	sp!, {r4-r10, fp, lr}
	add	fp, sp, #4

    mov r3, #0               @ r3 --- sign bit
    mov r4, #0               @ r4 --- total value (decimal)
    mov r5, #10              @ r5 --- value to be multiplied (or temporary value)
    mov r6, #0               @ r6 --- times of exponent
    mov r9, #0               @ r9 --- number of mantissa
    mov r10, #0              @ r10 -- result

    ldr r2, [r1, #4]         @ load first argument 
    ldrb r0, [r2]            @ load first byte in string 
    cmp r0, #78              @ compare first character with 'N'
    moveq r3, #1             @ indicate sign bit to '1' (negative)
    addeq r2, r2, #1         @ move to next byte in string
    lsl r3, r3, #31          @ left shift sign bit 31-bit
    
loop:
    ldrb r0, [r2], #1        @ load first byte in string
    cmp r0, #0               @ compare with '\0'
    beq count
    sub r0, r0, #48          @ convert from ASCII to decimal
    mul r1, r4, r5           @ multiply total by 10
    add r1, r1, r0           @ add current digit to total
    mov r4, r1
    b loop

count:
    lsr r4, r4, #1           @ divide by 2 until value become 0
    cmp r4, #0
    beq to_binary
    add r6, r6, #1
    b count            
                             
to_binary:
    add r7, r6, #127         @ exponent
    lsl r7, r7, #23          @ left shift 23-bit, r7 --- exponent

    mov r5, #1
    lsl r5, r5, r6           @ left shift r6 bit
    bic r8, r1, r5           @ r8 --- fraction

fraction:
    cmp r6, #23
    rsblt r6, r6, #23        @ lower than 23-bit
    lsllt r8, r8, r6
    subgt r6, r6, #23        @ greater than 23-bit
    lsrgt r8, r8, r6
    orr r10, r7, r8
    orr r10, r10, r3

    mov r7, #'0'
    mov r8, #'1'
    mov r5, #0
    mov r6, #0x80000000
    ldr r2, =string
to_string:
    cmp r5, #32
    beq exit
    and r9, r10, r6, lsr r5
    cmp r9, #0
    streqb r7, [r2], #1
    strneb r8, [r2], #1
    add r5, r5, #1
    b to_string

exit:
    ldr r2, =string
    cmp r3, #0x80000000
    ldrne r0, =positive
    ldreq r0, =negative
    bl printf

	@epilogue
	sub	sp, fp, #4
	ldmfd	sp!, {r4-r10, fp, lr}
	bx	lr

@ data section
positive:
    .ascii "%d is coded by %s\0"
negative:
    .ascii "-%d is coded by %s\0"

string:
    .ascii "                                 \0"

    .end
    