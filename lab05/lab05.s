.globl main
.extern scanf
.extern printf

.data
    ipat: .asciz "%x"
    opat: .asciz "%x\n"
    opat2: .asciz "%x\n%x\n"
    numero: .word 0

    bit_mask_1: .word 0b0000001
    bit_mask_2: .word 0b0000010
    bit_mask_3: .word 0b0000100
    bit_mask_4: .word 0b0001000
    bit_mask_5: .word 0b0010000
    bit_mask_6: .word 0b0100000
    bit_mask_7: .word 0b1000000

.text
    .align 4

    @ definicao da funcao main
    main:
        push {ip, lr}

        @ testa parte de codificacao
        @ pede ao usuario para informar um valor
        ldr r0, =ipat
        ldr r1, =numero
        bl scanf

        @ codifica o valor informado
        ldr r0, =numero
        ldr r0, [r0]
        bl codifica

        @ retorna ao usuario o valor codificado
        mov r1, r0
        ldr r0, =opat
        bl printf

        @ testa a parte de DE-codificacao
        @ pede ao usuario para informar um valor
        ldr r0, =ipat
        ldr r1, =numero
        bl scanf

        @ decodifica o valor informado
        ldr r0, =numero
        ldr r0, [r0]
        bl decodifica		

        @ retorna ao usuario o valor decodificado e o status de erro
        mov r2, r1
        mov r1, r0
        ldr r0, =opat2
        bl printf

        mov r0, #0
        pop {ip, pc}

    @ definicao da funcao r0=codifica(r0)
    codifica:
        @aplicando mascara de BITS para pegar d1
        LDR r10, =bit_mask_4
        LDR r10, [r10]
        AND r5, r0, r10
        LSR r5, #3

        @aplicando mascara de BITS para pegar d2
        LDR r10, =bit_mask_3
        LDR r10, [r10]
        AND r6, r0, r10
        LSR r6, #2

        @aplicando mascara de BITS para pegar d3
        LDR r10, =bit_mask_2
        LDR r10, [r10]
        AND r7, r0, r10
        LSR r7, #1

        @aplicando mascara de BITS para pegar d4
        LDR r10, =bit_mask_1
        LDR r10, [r10]
        AND r8, r0, r10
        LSR r8, #0

        @calculando p1
        EOR r9, r5, r6
        EOR r9, r9, r8

        @calculando p2
        EOR r10, r5, r7
        EOR r10, r10, r8

        @calculando p3
        EOR r11, r6, r7
        EOR r11, r11, r8

        @posicionando os bits
        LSL r9 , #6 @p1
        LSL r10, #5 @p2
        LSL r5 , #4 @d1
        LSL r11, #3 @p3
        LSL r6 , #2 @d2
        LSL r7 , #1 @d3
        LSL r8 , #0 @d4

        @montando a saida
        MOV r0, #0
        ORR r0, r0, r5
        ORR r0, r0, r6
        ORR r0, r0, r7
        ORR r0, r0, r8
        ORR r0, r0, r9
        ORR r0, r0, r10
        ORR r0, r0, r11

        MOV pc,lr

    @ definicao da funcao (r0,r1)=decodifica(r0)
    decodifica:
        @aplicando mascara de BITS para pegar d1
        LDR r10, =bit_mask_5
        LDR r10, [r10]
        AND r1, r0, r10
        LSR r1, #4

        @aplicando mascara de BITS para pegar d2
        LDR r10, =bit_mask_3
        LDR r10, [r10]
        AND r2, r0, r10
        LSR r2, #2

        @aplicando mascara de BITS para pegar d3
        LDR r10, =bit_mask_2
        LDR r10, [r10]
        AND r3, r0, r10
        LSR r3, #1

        @aplicando mascara de BITS para pegar d4
        LDR r10, =bit_mask_1
        LDR r10, [r10]
        AND r4, r0, r10
        LSR r4, #0

        @aplicando mascara de BITS para pegar p1
        LDR r10, =bit_mask_7
        LDR r10, [r10]
        AND r5, r0, r10
        LSR r5, #6

        @aplicando mascara de BITS para pegar p2
        LDR r10, =bit_mask_6
        LDR r10, [r10]
        AND r6, r0, r10
        LSR r6, #5

        @aplicando mascara de BITS para pegar p3
        LDR r10, =bit_mask_4
        LDR r10, [r10]
        AND r7, r0, r10
        LSR r7, #3

        @verificando p1
        EOR r8, r1, r2
        EOR r8, r8, r4
        EOR r8, r8, r5

        @verificando p2
        EOR r9, r1, r3
        EOR r9, r9, r4
        EOR r9, r9, r6

        @verificando p3
        EOR r10, r2, r3
        EOR r10, r10, r4
        EOR r10, r10, r7

        @posicionando os bits
        LSL r1, #3 @d1
        LSL r2, #2 @d2
        LSL r3, #1 @d3
        LSL r4, #0 @d4

        @montando a saida do dado descodificado
        MOV r0, #0
        ORR r0, r0, r1
        ORR r0, r0, r2
        ORR r0, r0, r3
        ORR r0, r0, r4

        @montando a saida de verificacao de erro
        MOV r1, #0
        ORR r1, r1, r8
        ORR r1, r1, r9
        ORR r1, r1, r10

        MOV pc,lr
