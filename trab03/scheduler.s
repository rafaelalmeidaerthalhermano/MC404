@ MC404 - Projeto 3
@ Este módulo emplementa um escalonador de tarefas, ou seja, a parte do sistema
@ operacional responsável por alternar entre os processos/programas que estão
@ executando a cada momento na cpu do computador. Para isto, você deverá
@ implementar as seguintes syscalls: write(), fork(), getpid() e exit(). 
@
@ alunos : 116330 Bruno Vargas Versignassi de Carvalho &
@          121286 Rafael Almeida Erthal Hermano

.data
    @ {r0-r15_usr, cpsr}
    processes: .fill 17*8*8, 0
    @ variável global inteira que informa o pid do processo que esta sendo executado
    running  : .word 2
    @  rotulos que indicam se os processos p8 p7 p6 p5 p4 p3 p2 p1 estao ativos 0 = inativo 1 = ativo 
    process01   : .word 1
    process02   : .word 0
    process03   : .word 0
    process04   : .word 0
    process05   : .word 0
    process06   : .word 0
    process07   : .word 0
    process08   : .word 0

.text
.align 4

.org 0x0
b reset

.org 0x4

.org 0x8
b syscall_trap

.org 0xc

.org 0x10

.org 0x14

.org 0x18
b irq_trap

.org 0x1c

.org 0x20

@ A chamada reset configura o tzic e o gpt e acerta s pilha e apontadores para
@ os processos que serão executados pelo sistema operacional
@
reset:
    @ Código de usuario
    .set user_addr, 0x8000

    @ Pilhas dos modos
    .set PID1_USR_STACK, 0x11000
    .set PID2_USR_STACK, 0x10000
    .set PID3_USR_STACK, 0x0f000
    .set PID4_USR_STACK, 0x0e000
    .set PID5_USR_STACK, 0x0d000
    .set PID6_USR_STACK, 0x0c000
    .set PID7_USR_STACK, 0x0b000
    .set PID8_USR_STACK, 0x0a000
    .set SVC_STACK, 0x09800
    .set UND_STACK, 0x07c00
    .set ABT_STACK, 0x07800
    .set FIQ_STACK, 0x07400
    .set IRQ_STACK, 0x07000

    @ pilha do modo fiq
    msr CPSR_c, #0xD1
    mov sp, #FIQ_STACK
    
    @ pilha do modo irq
    msr CPSR_c, #0xD2
    mov sp, #IRQ_STACK
    
    @ pilha do modo abort
    msr CPSR_c, #0xD7
    mov sp, #ABT_STACK
    
    @ pilha do modo undefined
    msr CPSR_c, #0xDB
    mov sp, #UND_STACK

    @ pilha do modo supervisor
    msr CPSR_c, #0xDF
    mov sp, #SVC_STACK

    @ Entrar no modo sistema e desabilitar interrupções para setup
    bl tzic_setup
    bl gpt_setup
    bl uart_setup

    msr CPSR_c, #0x10
    mov sp, #PID1_USR_STACK

    ldr r0, =user_addr
    bx r0

@ Configuro a uart para realizar entrada e saida serial no sistema operacional
@
uart_setup:
    push {lr}

    .set UCR1,       0x53FBC080
    .set UCR1_value, 0x00000001
    .set UCR2,       0x53FBC084
    .set UCR2_value, 0x00002127
    .set UCR3,       0x53FBC088
    .set UCR3_value, 0x00000704
    .set UCR4,       0x53FBC08C
    .set UCR4_value, 0x00007C00
    .set UFCR,       0x53FBC090
    .set UFCR_value, 0x0000089E
    .set UBIR,       0x53FBC0A4
    .set UBIR_value, 0x000008FF
    .set UBMR,       0x53FBC0A8
    .set UBMR_value, 0x00000C34

    ldr r0, =UCR1            @ carregando o endereco do UCR1
    ldr r1, =UCR1_value
    str r1, [r0]             @ guardo

    ldr r0, =UCR2            @ carregando o endereco do UCR2
    ldr r1, =UCR2_value
    str r1, [r0]             @ guardo

    ldr r0, =UCR3            @ carregando o endereco do UCR2
    ldr r1, =UCR3_value
    str r1, [r0]             @ guardo

    ldr r0, =UCR4            @ carregando o endereco do UCR4
    ldr r1, =UCR4_value
    str r1, [r0]             @ guardo

    ldr r0, =UFCR            @ carregando o endereco do UFCR
    ldr r1, =UFCR_value
    str r1, [r0]             @ guardo

    ldr r0, =UBIR            @ carregando o endereco do UBIR
    ldr r1, =UBIR_value
    str r1, [r0]             @ guardo

    ldr r0, =UBMR            @ carregando o endereco do UBMR
    ldr r1, =UBIR_value
    str r1, [r0]             @ guardo

    pop {pc}

@ Configuro o tzic para controlar as interrupções dos dispositivos externos ao
@ núcleo do arm.
@
tzic_setup:
    push {lr}

    .set TZIC_BASE, 0x0FFFC000
    .set TZIC_INTCTRL, 0x0
    .set TZIC_INTSEC1, 0x84 
    .set TZIC_ENSET1, 0x104
    .set TZIC_PRIOMASK, 0xC
    .set TZIC_PRIORITY9, 0x424

    @ Liga o controlador de interrupções
    ldr r1, =TZIC_BASE

    @ Configura interrupção 39 do GPT como não segura
    mov r0, #(1 << 7)
    str r0, [r1, #TZIC_INTSEC1]

    @ Habilita interrupção 39 (GPT)
    mov r0, #(1 << 7)
    str r0, [r1, #TZIC_ENSET1]

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
    mov r0, #1
    str r0, [r1, #TZIC_INTCTRL]

    pop {pc}

@ Configuro o GPT para interromper a execução de qualquer código de usuário com
@ uma frequência fixa para escalonar os processos que estão sendo executados
@
gpt_setup:
    push {lr}

    .set GPT_CR,     0x53FA0000
    .set PRESCALER,  0x53FA0004
    .set GPT_OCR1,   0x53FA0010
    .set GPT_IR,     0x53FA000C
    .set GPT_CYCLES, 0x00001000 @TODO configurar essa bagaça

    ldr r0, =GPT_CR          @ carregando o endereco do GPT_CR
    mov r1, #0x00000041      @ configurando o GPT  
    str r1, [r0]             @ guardo

    ldr r0,=PRESCALER        @ agora devo manter zerado o prescaler
    mov r1, #0x0 
    str r1, [r0]

    ldr r0, =GPT_OCR1        @ seto o número de ciclos para interrupção dos processos
    ldr r1, =GPT_CYCLES
    ldr r1, [r1]
    str r1, [r0]

    ldr r0, =GPT_IR          @ declarando interece na interrupcao Output Compare Channel 1
    mov r1, #0x1 
    str r1, [r0]             @ guardo 1 no registrador GPT_IR para declarar o interece

    pop {pc}

@ Função para tratamento de todas as interrupções de software realizadas por 
@ syscalls chamadas pelo comando svc
@
@ entrada : {r0-r3: , r7: código da syscal[exit: 1, fork: 2, write: 4, getpid: 20]}
@ saida   : {r0: bytes escritos}
@
syscall_trap:
    push {lr}

    pop {pc}

@ Função para tratamento de todas as interrupções geradas pelo irq, as
@ interrupções do gpt também entram aqui, portanto, caso a interrupção tenha
@ vindo do gpt, devemos escalonar o processo a ser executado
@
irq_trap:
    push {lr}

    bl str_context
    add sp, sp, #4    @descartando o lr anterior

    @ busca proximo processo a ser excutado
    ldr r0, =running
    ldr r1, [r0]
    @ verifico processo ativo
    str r1, [r0]
    
    @ carrego a posicao no vetor de valores
    ldr r1, [r0]
    mov r2, #136
    mul r0, r1, r2
    ldr r1, =processes
    add r0, r0, r1

    @carregar o lr e o spsr em irq
    msr CPSR_c, #0xD2
    msr spsr, [r0, #64]
    ldr lr  , [r0, #56]
    msr CPSR_c, #0xDF

    @ carrego os resgistrados r0-r10 do vetor
    mov r14, r0
    ldr r0,  [r14], #4
    ldr r1,  [r14], #4
    ldr r2,  [r14], #4
    ldr r3,  [r14], #4
    ldr r4,  [r14], #4
    ldr r5,  [r14], #4
    ldr r6,  [r14], #4
    ldr r7,  [r14], #4
    ldr r8,  [r14], #4
    ldr r9,  [r14], #4
    ldr r10, [r14], #4
    ldr r11, [r14], #4
    ldr r12, [r14], #4
    ldr r13, [r14], #4
    ldr r14, [r14], #4

    msr CPSR_c, #0xD2
    movs pc, lr

@ Salva o contexto que vai sair de execução, salvo o que estava no lr do
@ modo original e retorno da função no modo svc
@
str_context:
    push {lr}

    push {r10-r12}
    @ carrego a posicao no vetor de valores
    ldr r11, =running
    ldr r11, [r11]
    mov r10, #136
    mul r12, r11, r10
    ldr r11, =processes
    add r12, r12, r11

    @ salvo do r0 ao r9 no vetor de processos
    str r0,  [r12], #4
    str r1,  [r12], #4
    str r2,  [r12], #4
    str r3,  [r12], #4
    str r4,  [r12], #4
    str r5,  [r12], #4
    str r6,  [r12], #4
    str r7,  [r12], #4
    str r8,  [r12], #4
    str r9,  [r12], #4

    @ salvo spsr no vetor de processos
    mrs spsr, [r12, #6]

    @ salvo o pc que veio de [SP + 16] -4 
    mov r0, SP
    add r0, r0, #4
    ldr r0, [r0]
    sub r0, r0, #4
    str r0, [r12, #5]
    
    @ salvo r0, r1 e r2 nas posição de r10, r11 e r12 no vetor de processos
    pop {r0-r2}
    str r0, [r12], #4
    str r1, [r12], #4
    str r2, [r12], #4

    @ vou para o modo sistema
    msr CPSR_c, #0xDF

    @ salvo r13 e r14 no vetor de processos
    str r13, [r12], #4
    str r14, [r12], #4

    pop {pc}


@ A chamada de sistema write() deve escrever os bytes no dispositivo UART.
@ Escreva R2 bytes do buffer cujo ponteiro está em R1. Retorne o número de bytes
@ escritos com sucesso (0 indica que nenhum byte foi escrito) ou -1 caso tenha
@ ocorrido algum erro.
@
@ entrada : {r0: endereco da string, r1: tamanho da string}
@ saida   : {r0: bytes escritos}
@
write:
    push {lr}

    .set UART1_USR1, 0x53FBC094
    .set UART1_UTXD, 0x53FBC040
    .set TRDY_MASK, 0b010000000000000

write_head:
    cmp r1, #0
    beq write_tail
    sub r1, r1, #1

trdy_check:
    @ verifico trdy 
    ldr r2, =UART1_USR1
    ldr r2, [r2]     @ carregando o endereco do UART1_USR1
    ldr r3, =TRDY_MASK

    and r2, r2, r3   @ aplico a mascara
    cmp r2, r3
    bne trdy_check

write_body:
    ldr r2, =UART1_UTXD       @ carregando o endereco do UART1_UTXD
    ldrb r3, [r0], #1          @ caracter a ser escrito
    strb r3, [r2]              @ escrevo

    b write_head

write_wait:
    b write_wait

@ A chamada de sistema fork() cria um novo processo, duplicando o processo que a
@ chamou. O novo processo é referenciado como filho do processo que chamou.
@
@ saida   : {r0: PID do processo criado}
@
fork:
    push {lr}

    ldr r0,=process01
    ldr r0, [r0] 
    cmp r0, #0
    moveq r0, #1
    bleq str_context
    msreq CPSR_c, #0x10
    moveq sp, #PID1_USR_STACK
    beq fork_wait

    ldr r0,=process02
    ldr r0, [r0] 
    cmp r0, #0
    moveq r0, #2
    bleq str_context
    msreq CPSR_c, #0x10
    moveq sp, #PID2_USR_STACK
    beq fork_wait

    ldr r0,=process03
    ldr r0, [r0] 
    cmp r0, #0
    moveq r0, #3
    bleq str_context
    msreq CPSR_c, #0x10
    moveq sp, #PID3_USR_STACK
    beq fork_wait

    ldr r0,=process04
    ldr r0, [r0] 
    cmp r0, #0
    moveq r0, #4
    bleq str_context
    msreq CPSR_c, #0x10
    moveq sp, #PID4_USR_STACK
    beq fork_wait

    ldr r0,=process05
    ldr r0, [r0] 
    cmp r0, #0
    moveq r0, #5
    bleq str_context
    msreq CPSR_c, #0x10
    moveq sp, #PID5_USR_STACK
    beq fork_wait

    ldr r0,=process06
    ldr r0, [r0] 
    cmp r0, #0
    moveq r0, #6
    bleq str_context
    msreq CPSR_c, #0x10
    moveq sp, #PID6_USR_STACK
    beq fork_wait

    ldr r0,=process07
    ldr r0, [r0] 
    cmp r0, #0
    moveq r0, #7
    bleq str_context
    msreq CPSR_c, #0x10
    moveq sp, #PID7_USR_STACK
    beq fork_wait

    ldr r0,=process08
    ldr r0, [r0] 
    cmp r0, #0
    moveq r0, #8
    bleq str_context
    msreq CPSR_c, #0x10
    moveq sp, #PID8_USR_STACK
    beq fork_wait
    
    mov r0, #-2
    bl str_context

fork_wait:
    b fork_wait

@ A syscall getpid() simplesmente retorna a identificação do processo (process
@ ID) do processo que a chamar. Para responder a essa chamada, basta consultar
@ seu escalonador para conhecer qual o número do processo em execução
@ atualmente. Repare que, no trabalho, esse número só pode assumir os valores de
@ 1 a 8.
@
@ saida   : {r0: PID do processo}
@
getpid:
    push {lr}

    ldr r0, =running
    ldr r0, [r0]
    bleq str_context

getpid_wait:
    b getpid_wait

@ A syscall exit() encerra o processo que a chamar imediatamente. E todo
@ processo filho do processo que chamou a exit() continua de pé.
@
exit:
    ldr r0, =running
    ldr r0, [r0]

    mov r2, #0

    cmp r0, #1
    ldreq r1, =process01
    streq r2, [r1]

    cmp r0, #2
    ldreq r1, =process02
    streq r2, [r1]

    cmp r0, #3
    ldreq r1, =process03
    streq r2, [r1]

    cmp r0, #4
    ldreq r1, =process04
    streq r2, [r1]

    cmp r0, #5
    ldreq r1, =process05
    streq r2, [r1]

    cmp r0, #6
    ldreq r1, =process06
    streq r2, [r1]

    cmp r0, #7
    ldreq r1, =process07
    streq r2, [r1]

    cmp r0, #8
    ldreq r1, =process08
    streq r2, [r1]

exit_wait:
    b exit_wait
