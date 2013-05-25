@ This is a macro definition to help setting entries in the
@ IAS memory map
.macro mm_entry byte1 byte2 byte3 byte4 byte5
	.byte 0x\byte1
	.byte 0x\byte2
	.byte 0x\byte3
	.byte 0x\byte4
	.byte 0x\byte5
.endm

@ This .data section defines the architectural state
@ of the IAS machine
.data
	.align 4
	.globl IAS_MEM
	.globl PC
	.globl AC
	.globl MQ

PC:
	.word	0

AC:
	.word	1

MQ:
	.word	0

IAS_MEM:
	mm_entry 01 02 03 04 05
	mm_entry 00 00 00 00 03
	mm_entry 01 02 03 04 05
	mm_entry 01 02 03 04 05
	mm_entry 01 02 03 04 05
	mm_entry 01 02 03 04 05
	mm_entry 01 02 03 04 05
	mm_entry 01 02 03 04 05
	mm_entry 01 02 03 04 05
	mm_entry 01 02 03 04 05
	mm_entry 01 02 03 04 05
	mm_entry 01 02 03 04 05
	mm_entry 01 02 03 04 05
	mm_entry 01 02 03 04 05
	mm_entry 01 02 03 04 05
	mm_entry 01 02 03 04 05
	mm_entry 01 02 03 04 05
	mm_entry 01 02 03 04 05
	mm_entry 01 02 03 04 05
	mm_entry 01 02 03 04 05
	.fill	1004, 5, 0
