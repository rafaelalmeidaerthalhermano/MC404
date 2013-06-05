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
    msr     CPSR_c, #0x12    @ IRQ mode, vou setar uma pilha
    ldr sp, =0xffff          @ endereco onde colocarei minha pilha 

    bl gpt_setup
    bl tzic_setup

    msr CPSR_c, #0x13        @ SUPERVISOR mode, IRQ/FIQ enabled habilita interrupcoes

@ Configuro a uart para realizar entrada e saida serial no sistema operacional
@
uart_setup:
    push {lr}

    pop {pc}

@ Configuro o tzic para controlar as interrupções dos dispositivos externos ao
@ núcleo do arm.
@
tzic_setup:
    push {lr}

    @ Constantes para os endereços do TZIC
    @ (não são instruções, são diretivas do montador!)
    .set TZIC_BASE, 0x0FFFC000
    .set TZIC_INTCTRL, 0x0
    .set TZIC_INTSEC1, 0x84 
    .set TZIC_ENSET1, 0x104
    .set TZIC_PRIOMASK, 0xC
    .set TZIC_PRIORITY9, 0x424

    @ Liga o controlador de interrupções
    @ R1 <= TZIC_BASE
    ldr r1, =TZIC_BASE

    @ Configura interrupção 39 do GPT como não segura
    mov r0, #(1 << 7)
    str r0, [r1, #TZIC_INTSEC1]

    @ Habilita interrupção 39 (GPT)
    @ reg1 bit 7 (gpt)
    mov r0, #(1 << 7)
    str r0, [r1, #TZIC_ENSET1]

    @ Configure interrupt39 priority as 1
    @ reg9, byte 3
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
