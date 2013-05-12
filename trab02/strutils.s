@ MC404 - Projeto 2 (parte 1)
@ Conjunto de funcoes para manipulacÃ£o de vetores de caracteres
@ e conversÃ£o de bases.
@
@ aluno : Rafael Almeida Erthal Hermano
@ ra    : 121286
@
.globl my_ahtoi
.globl my_atoi
.globl my_itoa
.globl my_itoah
.globl my_strcmp
.globl my_strlen

.text
.align 4

@ Converte uma cadeia de caracteres com dígitos hexadecimais terminada em zero
@ para um inteiro de 32 bits.
@
@ entrada   : {r0: endereco da string}
@ saida     : {r0: valor em decimal}
@
my_ahtoi:
    push {lr}

    pop {pc}

@ Converte uma cadeia de caracteres com dígitos decimais terminada em zero para
@ um inteiro de 32 bits.
@
@ entrada   : {r0: endereco da string}
@ saida     : {r0: valor em decimal}
@
my_atoi:
    push {lr}

    mov r1, r0
    mov r0, #0
    mov r3, #10

my_atoi_head:
    @ adiciono o mais significativo corrente e aponto para próximo digito
    mul r0, r3
    ldrb r2, [r1], #1
    sub r2, r2, #48
    add r0, r2
    @ verifico se atingi o inicio da string
    @cmp r1, r2
    @bne my_atoi_head

    pop {pc}

@ Converte um inteiro para uma cadeia de caracteres com dígitos decimais
@ representando o inteiro. A cadeia deve ser preenchina na memória a partir do
@ endereço fornecido em buf e deve ser terminada com zero.
@
@ entrada   : {r0: valor do inteiro, r1: endereco da string de saida}
@
my_itoa:
    push {lr}

    pop {pc}

@ Converte um inteiro para uma cadeia de caracteres com dígitos hexadecimais
@ representando o inteiro. A cadeia deve ser preenchina na memória a partir do
@ endereço fornecido em buf e deve ser terminada com zero.
@
@ entrada   : {r0: endereco da string, r1: endereco da string de saida}
@
my_itoah:
    push {lr}

    pop {pc}

@ Compara as duas cadeias de caracteres apontadas por s1 e s2. Retorna 0 se
@ ambas forem iguais. -1 Se a primeira for lexicograficamente menor e 1 se a
@ segunda for lexicograficamente menor.
@
@ entrada   : {r0: endereco da primeira string, r1: endereco da segunda string}
@ saida     : {r0: resultado da compacarao}
@
my_strcmp:
    push {lr}
    push {r4}

    mov r3, r1
    mov r4, r0

my_strcmp_head:
    @ carrego os caracteres da memória
    ldrb r1, [r3], #0x1
    ldrb r2, [r4], #0x1

    @ verifico se alguma das strings chegou ao final
    cmp r1, #0
    beq my_strcmp_tail 
    cmp r2, #0
    beq my_strcmp_tail 

    @ verifico se as strings continuam sendo iguais
    cmp r1, r2
    beq my_strcmp_head

my_strcmp_tail:
    @ monto a saida
    cmp r1, r2
    moveq r0, #0
    movgt r0, #1
    movlt r0, #-1

    pop {r4}
    pop {pc}

@ retorna o tamanho de uma string
@
@ entrada   : {r0: endereco da string}
@ saida     : {r0: tamanho da string}
@
my_strlen:
    push {lr}
    mov r2, r0
my_strlen_head:
    ldrb r1, [r0], #0x1
    cmp r1, #0x0
    bne my_strlen_head
    
    sub r0, r0, r2
    sub r0, r0, #0x1

    pop {pc}
