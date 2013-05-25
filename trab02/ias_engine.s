@ MC404 - Projeto 2 (parte 3)
@ Conjunto de funcoes para buscar, decodificar e executar a proxima
@ instrução apontada por PC
@
@ aluno : Rafael Almeida Erthal Hermano
@ ra    : 121286
@
.extern IAS_MEM
.extern PC
.extern AC
.extern MQ

.extern ins_loadmq
.extern ins_loadmqm
.extern ins_storm
.extern ins_loadm
.extern ins_loadminusm
.extern ins_loadmodulusm
.extern ins_jumpmleft
.extern ins_jumpmright
.extern ins_jumpmcondleft
.extern ins_jumpmcondright
.extern ins_addm
.extern ins_addmodulusm
.extern ins_subm
.extern ins_submodulusm
.extern ins_mulm
.extern ins_divm
.extern ins_lsh
.extern ins_rsh
.extern ins_stormleft

.globl step_instruction

.data
    status : .space 8

.text
.align 4

@ Busca, decodifica e executa a proxima instrucao
@
@ entrada   : {r0: o valor do endereco apontado por PC}
@ saida     : {r0: status:[0:instrucao valida, 1: instrucao invalida]}
@
decode_instruction:
    push {lr}
    push {r4}

    @ separo o opcode do endereco

    pop {r4}
    pop {pc}

@ Busca a proxima instrucao apontada por PC
@
@ entrada   : {r0: endereco da memoria aonde sera colocado o status: [0:endereco valido, 1:endereco invalido]}
@ saida     : {r0: valor do endereco de memoria apontado por PC}
@
seek_instruction:
    push {lr}
    push {r4}
    mov r4, r0

    ldr r0, =PC
    ldr r0, [r0]

    @ calculo o lado de pc
    mov r1, #0b01 
    and r1, r0, r1 @r1 = 0 ->esquerda, r1 = 1 ->direita
    mov r0, r0, lsr #1

    @ verifico se a posicao e valida
    cmp r1, #1024
    movhi r2, #1
    strhi r2, [r4]
    bhi seek_instruction_tail
    mov r2, #0
    str r2, [r4]

    @ calculo a posicao no IAS_MEM
    mov r2, #5
    mul r3, r2, r0
    ldr r2, =IAS_MEM
    add r0, r0, r2

    cmp r1, #0
    beq seek_instruction_left
    bne seek_instruction_right

seek_instruction_left:
    @ leio os bytes
    ldrb r1, [r0], #1
    ldrb r2, [r0], #1
    ldrb r3, [r0]

    mov r3, r3, lsr #4
    mov r2, r2, lsl #4
    mov r1, r1, lsl #12

    orr r0, r1, r2
    orr r0, r0, r3

    b seek_instruction_tail

seek_instruction_right:
    add r0, r0, #2
    @ leio os bytes
    ldrb r1, [r0], #1
    ldrb r2, [r0], #1
    ldrb r3, [r0]

    mov r0, #0b0011
    and r1, r1, r0
    mov r1, r1, lsl #16
    mov r2, r2, lsl #8

    orr r0, r1, r2
    orr r0, r0, r3

    b seek_instruction_tail

seek_instruction_tail:
    pop {r4}
    pop {pc}

@ Busca, decodifica e executa a proxima instrucao
@
@ entrada   : {}
@ saida     : {r0: status:[0:executada, 1:opcode invalido, 2:posicao invalida de memoria]}
@
step_instruction:
    push {lr}

    ldr r0, =status
    bl seek_instruction

    ldr r1, =status
    ldr r1, [r0]
    cmp r1, #1
    moveq r1, #2
    beq step_instruction_tail

    bl decode_instruction

step_instruction_tail:
    pop {pc}
