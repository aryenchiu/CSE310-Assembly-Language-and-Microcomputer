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
	stmfd	sp!, {fp, lr}
	add	fp, sp, #4
    bl start_deasm
    b finish
    .include "test.s"
    
start_deasm:
    stmfd sp!, {r4, r5, r6, r10, lr}
    mov r4, #0                @ pc = 0 
    add r5, r14, #4           @ address of first line in "test.s"
    ldr	r0, =title
	bl printf                 @ print title
    ldr r10, =start_deasm     @ address of last line in "test.s"
loop:
    cmp r5, r10
    beq s_exit
    ldr r6, [r5], #4          @ load instruction in "test.s"
    bl condition_code
    bl instruction
    mov r1, r4
    ldr r0, =string
    bl printf
    add r4, r4, #4            @ pc + 4
    b loop
s_exit:
    ldmfd sp!, {r4, r5, r6, r10, lr}
    bx lr

condition_code:
    stmfd sp!, {r6, r7, r8, lr}
    bic r7, r6, #0x0fffffff    @ check [31:28]
    lsr r7, r7, #28            @ right shift 28-bit
    ldr r8, =CONDITION         @ r8 point to CONDITION label
    add r8, r8, r7, lsl #2     
    mov r2, r8
    ldmfd sp!, {r6, r7, r8, lr}
    bx lr

instruction:
    stmfd sp!, {lr}
    mov r3, #0
    bl b_inst
    bl data_proc_immd_shift
    bl data_proc_immd
    bl load_store_immd
    bl load_store_reg
    cmp r3, #0                 @ check for undefined instruction
    ldreq r3, =UNDEFINED_INST
    ldmfd sp!, {lr}
    bx lr

@ check for "branch instruction"
b_inst:
    stmfd sp!, {r6, r9, lr}
    bic r6, r6, #0xf0ffffff   @ check 1(27), 0(26), 1(25)
    lsr r6, r6, #24
    cmp r6, #0x0000000a       @ B
    blt b_exit
    cmp r6, #0x0000000b       @ BL
    bgt b_exit
    ldr r9, =BRANCH_INST      @ r9 point to BRANCH_INST label
    addeq r9, r9, #4          @ BL
    mov r3, r9
b_exit:
    ldmfd sp!, {r6, r9, lr}
    bx lr

@ check for "data processing immediate shift"
data_proc_immd_shift:
    stmfd sp!, {r6, r7, r9, lr}
    bic r7, r6, #0xf1ffffff   @ check 0(27), 0(26), 0(25)
    lsr r7, r7, #25
    cmp r7, #0x00000000   
    bne dpis_exit
    bic r7, r6, #0xfe1fffff   @ check opcode
    lsr r7, r7, #21
    ldr r9, =DATA_PROC_INST
    add r9, r9, r7, lsl #2
    mov r3, r9
    b data_proc_reg_shift
dpis_exit:    
    ldmfd sp!, {r6, r7, r9, lr}
    bx lr

@ check for "data processing register shift"
data_proc_reg_shift:
    bic r7, r6, #0xffffff6f
    lsr r7, r7, #4
    cmp r7, #0x00000009           @ check 1(7), 0(6), 0(5), 1(4)
    ldreq r9, =UNDEFINED_INST
    moveq r3, r9
    b dpis_exit

@ check for "data processing immediate"
data_proc_immd:
    stmfd sp!, {r6, r7, r9, lr}
    bic r7, r6, #0xf1ffffff   @ check 0(27), 0(26), 1(25)
    lsr r7, r7, #25
    cmp r7, #0x00000001   
    bne dp_immd_exit
    bic r7, r6, #0xfe1fffff   @ check opcode
    lsr r7, r7, #21
    ldr r9, =DATA_PROC_INST
    add r9, r9, r7, lsl #2
    mov r3, r9
dp_immd_exit:
    ldmfd sp!, {r6, r7, r9, lr}
    bx lr

@ check for "load store immediate offset"
load_store_immd:
    stmfd sp!, {r6, r7, r9, lr}
    bic r7, r6, #0xf1ffffff            @ check 0(27), 1(26), 0(25)
    lsr r7, r7, #25
    cmp r7, #0x00000002
    bne ls_i_exit

    bic r7, r6, #0xffefffff            @ check load/store
    lsr r7, r7, #20
    cmp r7, #0x00000000
    ldr r9, =LOAD_STORE_INST
    addeq r9, r9, #16

    bic r7, r6, #0xffbfffff            @ check byte 
    lsr r7, r7, #22
    cmp r7, #0x00000001
    addeq r9, r9, #8
    mov r3, r9
ls_i_exit:
    ldmfd sp!, {r6, r7, r9, lr}
    bx lr

@ check for "load store register offset"
load_store_reg:
    stmfd sp!, {r6, r7, r9, lr}
    bic r7, r6, #0xf1ffffff            @ check 0(27), 1(26), 1(25)
    lsr r7, r7, #25
    cmp r7, #0x00000003
    bne ls_reg_exit

    bic r7, r6, #0xffefffff            @ check load/store
    lsr r7, r7, #20
    cmp r7, #0x00000000
    ldr r9, =LOAD_STORE_INST
    addeq r9, r9, #16

    bic r7, r6, #0xffbfffff            @ check byte 
    lsr r7, r7, #22
    cmp r7, #0x00000001
    addeq r9, r9, #8    

    bic r7, r6, #0xffffffef
    lsr r7, r7, #4
    cmp r7, #0x00000001
    ldreq r9, =UNDEFINED_INST
    mov r3, r9
ls_reg_exit:
    ldmfd sp!, {r6, r7, r9, lr}
    bx lr

finish:
    sub	sp, fp, #4
	ldmfd	sp!, {fp, lr}
	bx	lr

@data section
title:
    .asciz "PC  condition   instruction\n"

string:
    .ascii "%-4d%-12s%s\n\0"

CONDITION:
    .ascii "EQ \0"
    .ascii "NE \0"
    .ascii "CS \0"
    .ascii "CC \0"
    .ascii "MI \0"
    .ascii "PL \0"
    .ascii "VS \0"
    .ascii "VC \0"
    .ascii "HI \0"
    .ascii "LS \0"
    .ascii "GE \0"
    .ascii "LT \0"
    .ascii "GT \0"
    .ascii "LE \0"
    .ascii "AL \0"

UNDEFINED_INST:
    .ascii "UND\0"

BRANCH_INST:
    .ascii "B  \0"
    .ascii "BL \0"

DATA_PROC_INST:
    .ascii "AND\0"
    .ascii "EOR\0"
    .ascii "SUB\0"
    .ascii "RSB\0"
    .ascii "ADD\0"
    .ascii "ADC\0"
    .ascii "SBC\0"
    .ascii "RSC\0"
    .ascii "TST\0"
    .ascii "TEQ\0"
    .ascii "CMP\0"
    .ascii "CMN\0"
    .ascii "ORR\0"
    .ascii "MOV\0"
    .ascii "BIC\0"
    .ascii "MVN\0"

LOAD_STORE_INST:
    .ascii "LDR    \0"
    .ascii "LDRB   \0"
    .ascii "STR    \0"
    .ascii "STRB   \0"

    .end