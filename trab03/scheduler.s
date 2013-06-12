@ MC404 - Projeto 3
@ Este módulo emplementa um escalonador de tarefas, ou seja, a parte do sistema
@ operacional responsável por alternar entre os processos/programas que estão
@ executando a cada momento na cpu do computador. Para isto, você deverá
@ implementar as seguintes syscalls: write(), fork(), getpid() e exit(). 
@
@ alunos : 116330 Bruno Vargas Versignassi de Carvalho &
@          121286 Rafael Almeida Erthal Hermano

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
    @ Configurable STACK values for each ARM core operation mode
    .set USR_STACK, 0x11000
    .set SVC_STACK, 0x10800
    .set UND_STACK, 0x07c00
    .set ABT_STACK, 0x07800
    .set FIQ_STACK, 0x07400
    .set IRQ_STACK, 0x07000

    @ First configure stacks for all modes
    mov sp, #SVC_STACK 
    msr CPSR_c, #0xDF   @ Entrar no modo sistema, FIQ/IRQ disabilitados
    mov sp, #USR_STACK
    msr CPSR_c, #0xD1   @ Entrar no modo fiq, FIQ/IRQ disabilitados
    mov sp, #FIQ_STACK
    msr CPSR_c, #0xD2   @ Entrar no modo irq, FIQ/IRQ disabilitados
    mov sp, #IRQ_STACK
    msr CPSR_c, #0xD7   @ Entrar no modo abort, FIQ/IRQ disabilitados
    mov sp, #ABT_STACK
    msr CPSR_c, #0xDB   @ Entrar no modo undefined, FIQ/IRQ disabilitados
    mov sp, #UND_STACK

    msr CPSR_c, #0xDF   @ Entrar no modo sistema e desabilitar interrupções para setup
    bl tzic_setup
    bl gpt_setup
    bl uart_setup

    
    .set UART1_USR1, 0x53FBC094
    .set UART1_UTXD, 0x53FBC040
    .set TRDY_MASK, 0b01000000000000

write_head:
    @ verifico trdy 
    ldr r0, =UART1_USR1
    ldr r0, [r0]     @ carregando o endereco do UART1_USR1

    ldr r1, =TRDY_MASK
    ldr r1, [r1]     @ carregando o endereco do mascara do trdy

    and r0, r0, r1   @ aplico a mascara
    cmp r0, r1
    bne write_head

    ldr r0, =UART1_UTXD       @ carregando o endereco do UART1_UTXD
    mov r1, #0x1              @ valor a ser escrito
    strb r1, [r0]             @ escrevo

write_tail:
    loop:
    b loop

    msr CPSR_c, #0x13   @ Entrar no modo sistema e habilitar interrupções

@ Configuro a uart para realizar entrada e saida serial no sistema operacional
@
uart_setup:
    push {lr}

    .set UCR1,       0x53FBC080
    .set UCR2,       0x53FBC084
    .set UCR3,       0x53FBC088
    .set UCR4,       0x53FBC08C
    .set UFCR,       0x53FBC090
    .set UBIR,       0x53FBC0A4
    .set UBMR,       0x53FBC0A8

    ldr r0, =UCR1            @ carregando o endereco do UCR1
    mov r1, #0x00000001      @ configurando o UCR1
    str r1, [r0]             @ guardo

    ldr r0, =UCR2            @ carregando o endereco do UCR2
    mov r1, #0x00002127      @ configurando o UCR2
    str r1, [r0]             @ guardo

    ldr r0, =UCR3            @ carregando o endereco do UCR2
    mov r1, #0x00000704      @ configurando o UCR3
    str r1, [r0]             @ guardo

    ldr r0, =UCR4            @ carregando o endereco do UCR4
    mov r1, #0x00007C00      @ configurando o UCR4
    str r1, [r0]             @ guardo

    ldr r0, =UFCR            @ carregando o endereco do UFCR
    mov r1, #0x0000089E      @ configurando o UFCR
    str r1, [r0]             @ guardo

    ldr r0, =UBIR            @ carregando o endereco do UBIR
    mov r1, #0x000008FF      @ configurando o UBIR
    str r1, [r0]             @ guardo

    ldr r0, =UBMR            @ carregando o endereco do UBMR
    mov r1, #0x00000C34      @ configurando o UBMR
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
gtp_setup:
    push {lr}

    .set GPT_CR,     0x53FA0000
    .set PRESCALER,  0x53FA0004
    .set GPT_OCR1,   0x53FA0010
    .set GPT_IR,     0x53FA000C
    .set GPT_CYCLES  0x00010000 @TODO configurar essa bagaça

    ldr r0, =GPT_CR          @ carregando o endereco do GPT_CR
    mov r1, #0x00000041      @ configurando o GPT  
    str r1, [r0]             @ guardo

    ldr r0,=PRESCALER        @ agora devo manter zerado o prescaler
    mov r1, #0x0 
    str r1, [r0]

    ldr r0, =GPT_OCR1        @ seto o número de ciclos para interrupção dos processos
    mov r1, GPT_CYCLES
    str r1, [r0]

    ldr r0, =GPT_IR          @ declarando interece na interrupcao Output Compare Channel 1
    mov r1, #0x1 
    str r1, [r0]             @ guardo 1 no registrador GPT_IR para declarar o interece

    pop {pc}

@ Função para tratamento de todas as interrupções de software realizadas por 
@ syscalls chamadas pelo comando svc
@
@ entrada : {r0-r3: , r7: código da syscal}
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

    pop {pc}

@ A chamada de sistema write() deve escrever os bytes no dispositivo UART.
@ Escreva R2 bytes do buffer cujo ponteiro está em R1. Retorne o número de bytes
@ escritos com sucesso (0 indica que nenhum byte foi escrito) ou -1 caso tenha
@ ocorrido algum erro.
@
@ entrada : {r1: endereco da string, r2: tamanho da string}
@ saida   : {r0: bytes escritos}
@
write:
    push {lr}

    pop {pc}

@ A chamada de sistema fork() cria um novo processo, duplicando o processo que a
@ chamou. O novo processo é referenciado como filho do processo que chamou.
@
@ saida   : {r0: PID do processo criado}
@
fork:
    push {lr}

    pop {pc}

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

    pop {pc}

@ A syscall exit() encerra o processo que a chamar imediatamente. E todo
@ processo filho do processo que chamou a exit() continua de pé.
@
exit:
    push {lr}

    pop {pc}
