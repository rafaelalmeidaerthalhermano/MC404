@ aluno : Rafael Almeida Erthal Hermano
@ ra    : 121286
@
@ MC404 - Projeto
@ primeira parte do projeto, biblioteca strutils.s

.globl my_ahtoi
.globl my_atoi
.globl my_itoa
.globl my_itoah
.globl my_strcmp
.globl my_strlen

.data
string_end: .byte '\0'
line_break: .byte '\n'

.text
.align 4

@ descricao : converte uma string que representa um hexa em um decimal
@ entrada   : {r0: endereco da string}
@ saida     : {r0: valor em decimal}
my_ahtoi:
    push {ip, lr}

    pop {ip, pc}

@ descricao : converte uma string que representa um decimal em decimal
@ entrada   : {r0: endereco da string}
@ saida     : {r0: valor em decimal}
my_atoi:
    push {ip, lr}

    pop {ip, pc}

@ descricao : converte um inteiro em string
@ entrada   : {r0: valor do inteiro, r1: endereco da string de saida}
my_itoa:
    push {ip, lr}

    pop {ip, pc}

@ descricao : converte um inteiro em uma string que representa um hexadecimal
@ entrada   : {r0: endereco da string, r1: endereco da string de saida}
my_itoah:
    push {ip, lr}

    pop {ip, pc}

@ descricao : compara duas strings
@ entrada   : {r0: endereco da primeira string, r1: endereco da segunda string}
@ saida     : {r0: resultado da compacarao}
my_strcmp:
    push {ip, lr}

    pop {ip, pc}

@ descricao : retorna o tamanho de uma string
@ entrada   : {r0: endereco da string}
@ saida     : {r0: tamanho da string}
my_strlen:
    push {ip, lr}

    pop {ip, pc}
