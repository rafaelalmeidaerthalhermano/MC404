@ MC404 - Projeto 2 (parte 1)
@ Interface que controla as entrada do usuario
@
@ aluno : Rafael Almeida Erthal Hermano
@ ra    : 121286
@
.extern my_itoah
.extern get_cmd
.extern put_str
.extern strlen

.extern IAS_MEM
.extern PC
.extern AC
.extern MQ

.globl main

.data
    opt1       : .space 8
    opt2       : .space 8
    bit_mask   : .word 0b01

    ac_message : .asciz "AC: 0x"
    mq_message : .asciz "MQ: 0x"
    pc_message : .asciz "PC: 0x"
    hex_format : .asciz "0x"

    new_line   : .asciz "\n"

    pc_right   : .asciz "/D"
    pc_left    : .asciz "/E"

    str_address: .space 100

.text
.align 4


@ Formata uma string para possuir 8 caracteres
@
@ entrada   : {r0: endereco do caracter que sera formatado}
@
format:
    push {pc}
    push {r4}
    push {r5}
    push {r6}

    mov r4, r0
    mov r6, r0
    bl strlen

    @verifico se o numero é negativo
    ldrb r5, [r4]
    mov r5, #48
    cmp r5, #70
    moveq r5, #70
    cmp r5, #102
    moveq r5, #70

format_head:
    cmp r0, #8
    bhi format_read
    push {r5}
    add r0, r0, #1
    b format_head

format_read:
    ldrb r5, [r4], #1
    push {r5}
    cmp r5, #0
    beq format_print
    b format_read

format_print:
    @ removo o digito da pilha
    pop {r0}
    strb r0, [r6], #1
    cmp r0, #0
    bne format_print

    pop {r6}
    pop {r5}
    pop {r4}
    pop {lr}

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

    @ coloco na memoria o valor
    str r1, [r0]
    mov r1, #0
    @strb r1, [r0, #4]

    pop {r4}
    pop {pc}

@ Interpreta um comando p
@
cmd_p:
    push {lr}

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
    add r0, r2, r3

    ldr r0, [r0]
    ldr r1, =str_address
    bl my_itoah

    ldr r1, =str_address
    format

    ldr r0, =hex_format
    bl put_str
    ldr r0, =str_address
    bl put_str
    ldr r0, =new_line
    bl put_str

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
