@ MC404 - Projeto 2 (parte 3)
@ Função para simulação de instruções do ias
@
@ aluno : Rafael Almeida Erthal Hermano
@ ra    : 121286
@
.extern IAS_MEM
.extern PC
.extern AC
.extern MQ

.globl ins_loadmq
.globl ins_loadmqm
.globl ins_storm
.globl ins_loadm
.globl ins_loadminusm
.globl ins_loadmodulusm
.globl ins_jumpmleft
.globl ins_jumpmright
.globl ins_jumpmcondleft
.globl ins_jumpmcondright
.globl ins_addm
.globl ins_addmodulusm
.globl ins_subm
.globl ins_submodulusm
.globl ins_mulm
.globl ins_divm
.globl ins_lsh
.globl ins_rsh
.globl ins_stormleft

.text
.align 4

@ Transfere o conteúdo do registrador MQ para AC
@
ins_loadmq:
    push {lr}

    ldr r0, =MQ
    ldr r0, [r0]
    ldr r1, =AC
    str r0, [r1]

    pop {pc}

@ Transfere o conteúdo da memória apontado por m para o registrador mq
@
@ entrada   : {r0: endereço m}
@
ins_loadmqm:
    push {lr}
    push {r4}

    @ calculo a posicao no IAS_MEM
    mov r2, #5
    mul r3, r2, r0
    ldr r2, =IAS_MEM
    add r0, r0, r2
    add r0, r0, #1

    ldrb r1, [r0], #1
    mov r1, r1, lsl #24

    ldrb r2, [r0], #1
    mov r2, r2, lsl #16

    ldrb r3, [r0], #1
    mov r3, r3, lsl #8

    ldrb r4, [r0], #1
    mov r4, r4, lsl #0

    orr r1, r1, r2
    orr r1, r1, r3
    orr r1, r1, r4

    ldr r2, =MQ
    str r1, [r2]

    pop {r4}
    pop {pc}

@ Transfere o conteúdo do registrador ac para a memória no endereço m
@
@ entrada   : {r0: endereço m}
@
ins_storm:
    push {lr}
    
    pop {pc}

@ Transfere o conteúdo da memória apontado por m para o registrador ac
@
@ entrada   : {r0: endereço m}
@
ins_loadm:
    push {lr}
    push {r4}

    @ calculo a posicao no IAS_MEM
    mov r2, #5
    mul r3, r2, r0
    ldr r2, =IAS_MEM
    add r0, r0, r2
    add r0, r0, #1

    ldrb r1, [r0], #1
    mov r1, r1, lsl #24

    ldrb r2, [r0], #1
    mov r2, r2, lsl #16

    ldrb r3, [r0], #1
    mov r3, r3, lsl #8

    ldrb r4, [r0], #1
    mov r4, r4, lsl #0

    orr r1, r1, r2
    orr r1, r1, r3
    orr r1, r1, r4

    ldr r2, =AC
    str r1, [r2]

    pop {r4}
    pop {pc}

@ Transfere o negativo do conteúdo da memória apontado por m para ac
@
@ entrada   : {r0: endereço m}
@
ins_loadminusm:
    push {lr}
    push {r4}

    @ calculo a posicao no IAS_MEM
    mov r2, #5
    mul r3, r2, r0
    ldr r2, =IAS_MEM
    add r0, r0, r2
    add r0, r0, #1

    ldrb r1, [r0], #1
    mov r1, r1, lsl #24

    ldrb r2, [r0], #1
    mov r2, r2, lsl #16

    ldrb r3, [r0], #1
    mov r3, r3, lsl #8

    ldrb r4, [r0], #1
    mov r4, r4, lsl #0

    orr r1, r1, r2
    orr r1, r1, r3
    orr r1, r1, r4

    mov r2, #-1
    mul r0, r1, r2

    ldr r2, =MQ
    str r1, [r2]

    pop {r4}
    pop {pc}

@ Transfere o absoluto do conteúdo da memória apontado por m para ac
@
@ entrada   : {r0: endereço m}
@
ins_loadmodulusm:
    push {lr}
    
    pop {pc}

@ Salta para a instrução da esquerda na palavra contida no endereço m da memoria
@
@ entrada   : {r0: endereço m}
@
ins_jumpmleft:
    push {lr}

    pop {pc}

@ Salta para a instrução da direita na palavra contida no endereço m da memoria
@
@ entrada   : {r0: endereço m}
@
ins_jumpmright:
    push {lr}

    pop {pc}

@ Se o valor em AC ffor não negativo, salta para a instrução da esquerda na
@ palavra contida no endereço m da memoria
@
@ entrada   : {r0: endereço m}
@
ins_jumpmcondleft:
    push {lr}

    pop {pc}

@ Se o valor em AC ffor não negativo, salta para a instrução da direita na
@ palavra contida no endereço m da memoria
@
@ entrada   : {r0: endereço m}
@
ins_jumpmcondright:
    push {lr}

    pop {pc}

@ Soma o valor contido no endereço m da memoria com o valor de ac e coloca o
@ resultado em ac 
@
@ entrada   : {r0: endereço m}
@
ins_addm:
    push {lr}

    pop {pc}

@ Soma o valor absoluto contido no endereço m da memoria com o valor de ac e
@ coloca o resultado em ac  
@
@ entrada   : {r0: endereço m}
@
ins_addmodulusm:
    push {lr}

    pop {pc}

@ Subtrai o valor contido no endereço m da memoria do valor de ac e coloca o
@ resultado em ac 
@
@ entrada   : {r0: endereço m}
@
ins_subm:
    push {lr}

    pop {pc}

@ Subtrai o valor absoluto contido no endereço m da memoria do valor de ac e
@ coloca o resultado em ac  
@
@ entrada   : {r0: endereço m}
@
ins_submodulusm:
    push {lr}

    pop {pc}

@ Multiplica o valor contido no endereço m da memoria com o valor de mq e coloca
@ os os bits mais significativos em ac e os menos significativos em mq
@
@ entrada   : {r0: endereço m}
@
ins_mulm:
    push {lr}

    pop {pc}

@ Divide o valor em ac pelo valor no endereco m da memória e coloca o quociente
@ em mq e o resto em ac
@
@ entrada   : {r0: endereço m}
@
ins_divm:
    push {lr}

    pop {pc}

@ Desloca os bits de ac para a esquerda
@
@ entrada   : {r0: endereço m}
@
ins_lsh:
    push {lr}

    pop {pc}

@ Desloca os bits de ac para a direita
@
@ entrada   : {r0: endereço m}
@
ins_rsh:
    push {lr}

    pop {pc}

@ Move os 12 bits mais significativos de ac para o segmento de endereço na
@ posição à esquerda do endereço m
@
@ entrada   : {r0: endereço m}
@
ins_stormleft:
    push {lr}

    pop {pc}

@ Move os 12 bits mais significativos de ac para o segmento de endereço na
@ posição à direita do endereço m 
@
@ entrada   : {r0: endereço m}
@
ins_stormright:
    push {lr}

    pop {pc}
