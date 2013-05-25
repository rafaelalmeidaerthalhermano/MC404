@ MC404 - Projeto 2 (parte 1)
@ Interface que controla as entrada do usuario
@
@ aluno : Rafael Almeida Erthal Hermano
@ ra    : 121286
@
.extern my_itoah
.extern get_cmd
.extern put_str
.extern my_strlen

.extern IAS_MEM
.extern PC
.extern AC
.extern MQ

.extern ins_subm

.globl main

.data
    opt1       : .space 8
    opt2       : .space 8
    bit_mask   : .word 0b01

    ac_message : .asciz "AC: 0x"
    mq_message : .asciz "MQ: 0x"
    pc_message : .asciz "PC: 0x"
    hex_format : .asciz "0x"
    zero       : .asciz "0"

    new_line   : .asciz "\n"

    pc_right   : .asciz "/D"
    pc_left    : .asciz "/E"

    str_address: .space 100

.text
.align 4

@ Interpreta um comando si
@
cmd_si:
    push {lr}

    bl step_instruction

    pop {pc}

@ Interpreta um comando sn
@
cmd_sn:
    push {lr}

    ldr r0, =opt1
    ldrb r1, [r0, #1]
    cmp r1, #120
    moveq r1, #88
    cmp r1, #88
 
    addeq r0, r0, #2
    bleq my_ahtoi
    blne my_atoi

cmd_sn_head:
    cmp r0, #0
    bls cmd_sn_tail

    push {r0-r4}
    bl step_instruction
    pop {r0-r4}
    sub r0, r0, #1
    b cmd_sn_head

cmd_sn_tail:
    pop {pc}

@ Interpreta um comando stw
@
cmd_stw:
    push {lr}
    push {r4}

    @ leio o primeiro parametro
    ldr r0, =opt1
    ldrb r1, [r0, #1]
    cmp r1, #120
    moveq r1, #88
    cmp r1, #88
 
    addeq r0, r0, #2
    bleq my_ahtoi
    blne my_atoi
    mov r4, r0

    @ leio o segundo parametro
    ldr r0, =opt2
    ldrb r1, [r0, #1]
    cmp r1, #120
    moveq r1, #88
    cmp r1, #88
 
    addeq r0, r0, #2
    bleq my_ahtoi
    blne my_atoi
    mov r1, r0
    mov r0, r4

    @ calculo a posicao real da memoria
    mov r2, #5
    mul r3, r2, r0
    ldr r2, =IAS_MEM
    add r0, r2, r3

    @ insiro o primeiro byte
    cmp r1, #0
    mov r2, #0x00
    movlt r2, #0xff 
    strb r2, [r0], #1

    @ insiro o segundo byte
    mov r2, #0xff000000
    and r2, r1, r2
    mov r2, r2, lsr #24
    strb r2, [r0], #1

    @ insiro o terceiro byte
    mov r2, #0x00ff0000
    and r2, r1, r2
    mov r2, r2, lsr #16
    strb r2, [r0], #1

    @ insiro o quarto byte
    mov r2, #0x0000ff00
    and r2, r1, r2
    mov r2, r2, lsr #8
    strb r2, [r0], #1

    @ insiro o quinto byte
    mov r2, #0x000000ff
    and r2, r1, r2
    strb r2, [r0]

    pop {r4}
    pop {pc}

@ Interpreta um comando p
@
cmd_p:
    push {lr}
    push {r4}

    ldr r0, =hex_format
    bl put_str

    ldr r0, =opt1
    ldrb r1, [r0, #1]
    cmp r1, #120
    moveq r1, #88
    cmp r1, #88
 
    addeq r0, r0, #2
    bleq my_ahtoi
    blne my_atoi

    @ calculo a posicao real da memoria
    mov r2, #5
    mul r3, r2, r0
    ldr r2, =IAS_MEM
    add r4, r2, r3

    @ leio o primeiro byte
    add r4, r4, #0
    ldrb r0, [r4]

    cmp r0, #15
    ldrls r0, =zero
    blls put_str

    ldrb r0, [r4]
    ldr r1, =str_address
    bl my_itoah
    ldr r0, =str_address
    bl put_str 

    @ leio o segundo byte
    add r4, r4, #1
    ldrb r0, [r4]

    cmp r0, #15
    ldrls r0, =zero
    blls put_str

    ldrb r0, [r4]
    ldr r1, =str_address
    bl my_itoah
    ldr r0, =str_address
    bl put_str 

    @ leio o terceiro byte
    add r4, r4, #1
    ldrb r0, [r4]

    cmp r0, #15
    ldrls r0, =zero
    blls put_str

    ldrb r0, [r4]
    ldr r1, =str_address
    bl my_itoah
    ldr r0, =str_address
    bl put_str 

    @ leio o quarto byte
    add r4, r4, #1
    ldrb r0, [r4]

    cmp r0, #15
    ldrls r0, =zero
    blls put_str

    ldrb r0, [r4]
    ldr r1, =str_address
    bl my_itoah
    ldr r0, =str_address
    bl put_str 

    @ leio o quinto byte
    add r4, r4, #1
    ldrb r0, [r4]

    cmp r0, #15
    ldrls r0, =zero
    blls put_str

    ldrb r0, [r4]
    ldr r1, =str_address
    bl my_itoah
    ldr r0, =str_address
    bl put_str 

    ldr r0, =new_line
    bl put_str

    pop {r4}
    pop {pc}

@ Interpreta um comando regs
@
cmd_regs:
    push {lr}
    push {r4}

    @ imprime AC 
    ldr r0, =ac_message
    bl put_str

    ldr r0, =AC
    ldr r0, [r0]
    ldr r1, =str_address
    bl my_itoah

    ldr r0, =str_address
    bl put_str
    ldr r0, =new_line
    bl put_str

    @ imprime MQ
    ldr r0, =mq_message
    bl put_str

    ldr r0, =MQ
    ldr r0, [r0]
    ldr r1, =str_address
    bl my_itoah

    ldr r0, =str_address
    bl put_str
    ldr r0, =new_line
    bl put_str

    @ imprime PC 
    ldr r0, =pc_message
    bl put_str

    ldr r0, =PC
    ldr r0, [r0]

    @ calculo o lado de pc
    ldr r3, =bit_mask
    ldr r3, [r3]
    mov r2, r0    
    and r2, r2, r3
    cmp r2, #0
    ldreq r4, =pc_left
    ldrne r4, =pc_right

    LSR r0, #1
    ldr r1, =str_address
    bl my_itoah

    ldr r0, =str_address
    bl put_str

    mov r0, r4
    bl put_str

    ldr r0, =new_line
    bl put_str

    pop {r4}
    pop {pc}

@ Principal controle do fluxo de execucao do simulador, ela le o
@ comando digitado pelo usuario e chama as respectivas funcoes
@ para tratar o comando
@
main:
    push {lr}

    mov r0, #1
    bl ins_subm
    bl cmd_regs

main_head:
    ldr r0, =opt1
    ldr r1, =opt2
    bl get_cmd

    mov r4, r0

    cmp r4, #1
    bleq cmd_si
    cmp r4, #1
    bleq main_head

    cmp r4, #2
    bleq cmd_sn
    cmp r4, #2
    bleq main_head

    cmp r4, #4
    bleq cmd_stw
    cmp r4, #4
    bleq main_head

    cmp r4, #5
    bleq cmd_p
    cmp r4, #5
    bleq main_head

    cmp r4, #6
    bleq cmd_regs
    cmp r4, #6
    bleq main_head

main_tail:
    mov r0, #0
    pop {pc}
