@ Constantes para os endereços do TZIC
	@ (não são instruções, são diretivas do montador!)
	.set TZIC_BASE, 0x0FFFC000
	.set TZIC_INTCTRL, 0x0
	.set TZIC_INTSEC1, 0x84 
	.set TZIC_ENSET1, 0x104
	.set TZIC_PRIOMASK, 0xC
	.set TZIC_PRIORITY9, 0x424

.text
.align 4

.org 0x0
b start_system

.org 0x18
bl tzic_trap

.org 0xD000
clock: .word 0x0

tzic_trap:
	mov GPT_SR, #0x1
	push {r0}
	push {r1}

	ldr r0, =clock
	ldr r1, [r0]
	add r1, r1, #1
	str r1, [r0]

	pop {r1}
	pop {r0}
	sub lr, lr, #4
	movs pc, lr

start_system:
	msr CPSR_c, #0x13
	
	mov GPT_CR, #0x00000041

	@ Liga o controlador de interrupções
	ldr	r1, =TZIC_BASE
	@ Configura interrupção 39 do GPT como não segura
	mov	r0, #(1 << 7)
	str	r0, [r1, #TZIC_INTSEC1]
	@ Habilita interrupção 39 (GPT)
	mov	r0, #(1 << 7)
	str	r0, [r1, #TZIC_ENSET1]
	@ Configure interrupt39 priority as 1
	ldr r0, [r1, #TZIC_PRIORITY9]
	bic r0, r0, #0xFF000000
	mov r2, #1
	orr r0, r0, r2, lsl #24
	str r0, [r1, #TZIC_PRIORITY9]
	@ Configure PRIOMASK as 0
	eor r0, r0, r0
	str r0, [r1, #TZIC_PRIOMASK]
	@ Habilita o controlador de interrupções
	mov	r0, #1
	str	r0, [r1, #TZIC_INTCTRL]