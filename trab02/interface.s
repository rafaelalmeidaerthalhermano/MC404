@ MC404 - Projeto 2 (parte 1)
@ Função para leitura de comandos do simulador
@
@ aluno : Rafael Almeida Erthal Hermano
@ ra    : 121286
@
.extern my_strcmp
.globl get_cmd

.data
	str_exit   : .asciz "exit"
	str_si     : .asciz "si"
	str_sn     : .asciz "sn"
	str_c      : .asciz "c"
	str_stw    : .asciz "stw"
	str_p      : .asciz "p"
	str_regs   : .asciz "regs"

	chr_address: .space 1
	str_address: .space 100

.text
.align 4


@ Coloca em r0 a string lida pela entrada padrão
@
@ entrada   : {r0: endereco do buffer aonde será inserida a string}
@
get_str:
    push {lr}
    push {r4}

    mov r4, r0

get_str_ignore:
    @ignora os caracteres em branco \n e \s
    mov r0, =chr_address
    bl get_chr 
    @condição para nova linha
    beq get_str_ignore
    @condição espaço em branco
    beq get_str_ignore
    @condição para fim de arquivo
    beq get_str_exit_eof

get_str_head:
    @ignora os caracteres em branco \n e \s
    mov r0, =chr_address
    bl get_chr
    @condição para nova linha
    beq get_str_tail
    @condição espaço em branco
    beq get_str_tail

    @ gravo o caracter lido
    ldr r0, =chr_address
    ldr r0, [r0]
    mov r1, r4
    strb r0, [r4]
    add r4, r4, #1
    b get_str_head

get_str_tail:
    mov r0, #0
    mov r1, r4
    strb r0, [r4]
    mov r0, r4

    pop {r4}
    pop {pc}

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
    mov r0, =str_address
    bl get_str

@ caso tenha lido um exit
cmd_exit:
    ldr r0, =str_address
    mov r1, =str_exit
    bl my_strcmp
    cmp r0, #0
    bne cmd_si

    mov r0, #0

    b get_cmd_tail

@ caso tenha lido um si
cmd_si:
    ldr r0, =str_address
    mov r1, =str_si
    bl my_strcmp
    cmp r0, #0
    bne cmd_sn

    mov r0, #1

    b get_cmd_tail

@ caso tenha lido um sn
cmd_sn:
    ldr r0, =str_address
    mov r1, =str_sn
    bl my_strcmp
    cmp r0, #0
    bne cmd_c

    mov r0, #2

    b get_cmd_tail

@ caso tenha lido um c
cmd_c:
    ldr r0, =str_address
    mov r1, =str_c
    bl my_strcmp
    cmp r0, #0
    bne cmd_stw

    mov r0, #3

    b get_cmd_tail

@ caso tenha lido um stw
cmd_stw:
    ldr r0, =str_address
    mov r1, =str_stw
    bl my_strcmp
    cmp r0, #0
    bne cmd_p

    mov r0, #4

    b get_cmd_tail

@ caso tenha lido um p
cmd_p:
    ldr r0, =str_address
    mov r1, =str_p
    bl my_strcmp
    cmp r0, #0
    bne cmd_regs

    mov r0, #5

    b get_cmd_tail

@ caso tenha lido um regs
cmd_regs:
    ldr r0, =str_address
    mov r1, =str_regs
    bl my_strcmp
    cmp r0, #0
    bne cmd_eof

    mov r0, #6

    b get_cmd_tail

@ caso tenha sido eof
cmd_eof:
    ldr r0, =str_address
    mov r1, =str_eof
    bl my_strcmp
    cmp r0, #0
    bne cmd_nac

    mov r0, #8

    b get_cmd_tail

@ caso tenha lido um comando não reconhecido
cmd_nac:

    mov r0, #7

    b get_cmd_tail

get_cmd_tail:

    pop {r5}
    pop {r4}
    pop {pc}