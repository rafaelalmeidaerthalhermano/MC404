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

@temporarios para teste
.extern printf
aqui : .asciz "aqui\n"

.text
.align 4

@ Divide um inteiro por outro retornando o valor da divisão e o resto
@
@ entrada   : {r0: dividendo, r1: divisor}
@ saida     : {r0: quociente, r1 : resto}
@
my_div:
    push {lr}

    mov r2, r1
    mov r1, r0
    mov r0, #0

my_div_head:
    cmp r1, r2
    blt my_div_tail

    sub r1, r1, r2
    add r0, r0, #1
    b my_div_head

my_div_tail:
    pop {pc}

@ Converte uma cadeia de caracteres com dígitos hexadecimais terminada em zero
@ para um inteiro de 32 bits.
@
@ entrada   : {r0: endereco da string}
@ saida     : {r0: valor em decimal}
@
my_ahtoi:
    push {lr}
    push {r4}

    mov r1, r0
    mov r0, #0
    mov r3, #16

my_ahtoi_head:
    @ verifico se atingi o final da string
    ldrb r2, [r1], #1
    cmp r2, #0
    beq my_ahtoi_tail

    @ verifico se o caracter esta em [0,9]
    cmp r2, #48
    subge r4, r2, #48
    @ verifico se o caracter esta em [A,F]
    cmp r2, #65
    subge r4, r2, #55
    @ verifico se o caracter esta em [a,f]
    cmp r2, #97
    subge r4, r2, #87

    @ adiciona o mais significativo à r0
    mul r0, r3
    add r0, r4
    b my_ahtoi_head

my_ahtoi_tail:
    pop {r4}
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
    @ verifico se atingi o final da string
    ldrb r2, [r1], #1
    cmp r2, #0
    beq my_atoi_tail

    @ adiciona o mais significativo em r0
    mul r0, r3
    sub r2, r2, #48
    add r0, r2
    b my_atoi_head

my_atoi_tail:
    pop {pc}

@ Converte um inteiro para uma cadeia de caracteres com dígitos decimais
@ representando o inteiro. A cadeia deve ser preenchina na memória a partir do
@ endereço fornecido em buf e deve ser terminada com zero.
@
@ entrada   : {r0: valor do inteiro, r1: endereco da string de saida}
@
my_itoa:
    push {lr}
    push {r4}

    mov r4, r1

    @ insiro na pilha o marcador de final da string
    mov r3, #0
    push {r3}

my_itoa_split:
    @ calculo o digito menos significativo corrente
    mov r1, #10
    bl my_div

    @ insiro o digito corrente na pilha
    add r2, r1, #48
    push {r2}

    @ verifico se terminei a conversao
    cmp r0, #0
    bge my_itoa_split

ldr r0, =aqui
bl printf

my_itoa_print:
    @ removo o digito da pilha
    pop {r0}
    str r0, [r4], #1
    cmp r0, #0
    bne my_itoa_print

my_itoa_tail:
    pop {r4}
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
