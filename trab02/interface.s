@ MC404 - Projeto 2 (parte 2)
@ Função para leitura de comandos do simulador
@
@ aluno : Rafael Almeida Erthal Hermano
@ ra    : 121286
@
.extern get_str
.globl get_cmd

.data
    str_exit   : .asciz "exit"
    str_si     : .asciz "si"
    str_sn     : .asciz "sn"
    str_c      : .asciz "c"
    str_stw    : .asciz "stw"
    str_p      : .asciz "p"
    str_regs   : .asciz "regs"

    str_address: .space 100

.text
.align 4

@ Retorna o código da operação lida pela entrada padrão e os parâmetros da operação
@
@ entrada   : {r0: endereco do primeiro parametro, r1: endereco do segundo parametro}
@ saida     : {r0: codigo do comando}
@
get_cmd:
    push {lr}
    push {r4}
    push {r5}

    mov r4, r0
    mov r5, r1

    @le o comando
    ldr r0, =str_address
    bl get_str

@ caso tenha lido um eof
cmd_eof:
    cmp r0, #0
    bne cmd_exit

    mov r0, #8

    b get_cmd_tail

@ caso tenha lido um exit
cmd_exit:
    ldr r0, =str_address
    ldr r1, =str_exit
    bl my_strcmp
    cmp r0, #0
    bne cmd_si

    mov r0, #0

    b get_cmd_tail

@ caso tenha lido um si
cmd_si:
    ldr r0, =str_address
    ldr r1, =str_si
    bl my_strcmp
    cmp r0, #0
    bne cmd_sn

    mov r0, #1

    b get_cmd_tail

@ caso tenha lido um sn
cmd_sn:
    ldr r0, =str_address
    ldr r1, =str_sn
    bl my_strcmp
    cmp r0, #0
    bne cmd_c

    mov r0, r4
    bl get_str

    mov r0, #2

    b get_cmd_tail

@ caso tenha lido um c
cmd_c:
    ldr r0, =str_address
    ldr r1, =str_c
    bl my_strcmp
    cmp r0, #0
    bne cmd_stw

    mov r0, #3

    b get_cmd_tail

@ caso tenha lido um stw
cmd_stw:
    ldr r0, =str_address
    ldr r1, =str_stw
    bl my_strcmp
    cmp r0, #0
    bne cmd_p

    mov r0, r4
    bl get_str

    mov r0, r5
    bl get_str

    mov r0, #4

    b get_cmd_tail

@ caso tenha lido um p
cmd_p:
    ldr r0, =str_address
    ldr r1, =str_p
    bl my_strcmp
    cmp r0, #0
    bne cmd_regs

    mov r0, r4
    bl get_str

    mov r0, #5

    b get_cmd_tail

@ caso tenha lido um regs
cmd_regs:
    ldr r0, =str_address
    ldr r1, =str_regs
    bl my_strcmp
    cmp r0, #0
    bne cmd_nac

    mov r0, #6

    b get_cmd_tail

@ caso tenha lido um comando não reconhecido
cmd_nac:

    mov r0, #7

    b get_cmd_tail

get_cmd_tail:

    pop {r5}
    pop {r4}
    pop {pc}
