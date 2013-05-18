@ MC404 - Projeto 2 (parte 2)
@ Função para leitura e escrita na entrada e saida padrão
@
@ aluno : Rafael Almeida Erthal Hermano
@ ra    : 121286
@
.extern my_strcmp
.globl put_str
.globl get_str

.data
    chr_address: .space 1

.text
.align 4

@ Coloca na saida padrão o caracter contido no endereco 
@ apontado por r0 e retorna em r0 o status
@
@ entrada   : {r0: endereco do caracter que sera escrito}
@ saida     : {r0: status[#1:escrito, #0:nao escrito]}
@
put_chr:
    push {lr}
    push {r7}

    mov r1, r0
    mov r0, #0x1
    mov r2, #0x1
    mov r7, #0x4
    svc 0

    pop {r7}
    pop {pc}

@ Coloca na saida padrão a string contida no endereco apontado
@ por r0
@
@ entrada   : {r0: endereco da string que sera escrita}
@
put_str:
    push {lr}
    push {r4}

    mov r4, r0

put_str_head:
    ldrb r0, [r4]
    cmp r0, #0
    beq put_str_tail
    mov r0, r4
    bl put_chr
    add r4, r4, #1
    b put_str_head

put_str_tail:
    pop {r4}
    pop {pc}

@ Coloca no endereco apontado por r0 o ultimo caracter lido na
@ entrada padrao e retorna em r0 o status
@
@ entrada   : {r0: endereco do caracter que sera lido}
@ saida     : {r0: status[#1:lido, #0:nao lido]}
@
get_chr:
    push {lr}
    push {r7}

    mov r1, r0
    mov r0, #0x0
    mov r2, #0x1
    mov r7, #0x3
    svc 0

    pop {r7}
    pop {pc}

@ Coloca no endereço apontado por r0 a string lida pela entrada padrão
@
@ entrada   : {r0: endereco do buffer aonde será inserida a string}
@
get_str:
    push {lr}
    push {r4}

    mov r4, r0

get_str_ignore:
    @ignora os caracteres em branco \n e \s
    ldr r0, =chr_address
    bl get_chr

    @ verifique se algum digito foi lido
    cmp r0, #0
    beq get_str_tail

    @ carregue o caracter lido
    ldr r0, =chr_address
    ldrb r0, [r0]

    @ compare se foi digitado apenas uma nova linha
    cmp r0, #10
    beq get_str_ignore

    @ compare se apenas espacos em branco foram digitados
    cmp r0, #32
    beq get_str_ignore

get_str_head:
    @leio as caracteres validos ate um espaco em branco ou nova linha
    mov r1, r4
    strb r0, [r4]
    add r4, r4, #1

    ldr r0, =chr_address
    bl get_chr
    
    @verifique se algum digito foi lido
    cmp r0, #0
    beq get_str_tail

    @carregue o caracter lido
    ldr r0, =chr_address
    ldrb r0, [r0]

    @ compare se foi digitado uma nova linha
    cmp r0, #10
    beq get_str_tail

    @ compare se foi digitado espaco em branco
    cmp r0, #32
    beq get_str_tail

    b get_str_head

get_str_tail:
    mov r0, #0
    mov r1, r4
    strb r0, [r4]
    mov r0, r4

    pop {r4}
    pop {pc}
