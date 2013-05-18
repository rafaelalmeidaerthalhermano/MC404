@ MC404 - Projeto 2 (parte 1)
@ Interface que controla as entrada do usuario
@
@ aluno : Rafael Almeida Erthal Hermano
@ ra    : 121286
@
.extern my_itoah
.extern get_cmd
.extern put_str

.extern IAS_MEM
.extern PC
.extern AC
.extern MQ

.extern printf

.globl main

.data
    opt1       : .space 8
    opt2       : .space 8
    ac_message : .asciz "AC: 0x"
    mq_message : .asciz "MQ: 0x"
    pc_message : .asciz "PC: 0x"

    str_address: .space 100

.text
.align 4

@ Incrementa em uma posicao PC,AC e MQ
@
step_instruction:
    push {lr}

    ldr r0, =PC
    ldr r1, [r0]
    add r1, r1, #1
    str r1, [r0]

    ldr r0, =AC
    ldr r1, [r0]
    add r1, r1, #1
    str r1, [r0]

    ldr r0, =MQ
    ldr r1, [r0]
    add r1, r1, #1
    str r1, [r0]

    pop {pc}

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

    pop {pc}

@ Interpreta um comando p
@
cmd_p:
    push {lr}

    pop {pc}

@ Interpreta um comando regs
@
cmd_regs:
    push {lr}

    @ imprime AC 
    ldr r0, =ac_message
    bl put_str

    ldr r0, =AC
    ldr r0, [r0]
    ldr r1, =str_address
    bl my_itoah

    ldr r0, =str_address
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

    @ imprime PC 
    ldr r0, =pc_message
    bl put_str

    ldr r0, =PC
    ldr r0, [r0]
    ldr r1, =str_address
    bl my_itoah

    ldr r0, =str_address
    bl put_str

    pop {pc}

@ Principal controle do fluxo de execucao do simulador, ela le o
@ comando digitado pelo usuario e chama as respectivas funcoes
@ para tratar o comando
@
main:
    push {lr}

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
