.globl main
.extern scanf
.extern printf

.data
    decimal_format: .asciz "%d"
    print_format  : .asciz "%05d"
    space         : .asciz " "
    line_break    : .asciz "\n"
    value_address : .word 0
    error_message : .asciz "Matrizes incompativeis.\n"

.bss
    A: .space 400

.bss
    B: .space 400

.bss
    result: .space 400

.text
    .align 4

    @ leitura da matriz
    @ entrada {r0 = endereco da matriz}
    @ saida {r0 = endereco, r1 = linhas, r2 = colunas}
    read_matrix:
        push {ip, lr}

        mov r5, r0 @r5 := inicio da matriz

        @le numero de linhas
        ldr r0, =decimal_format
        ldr r1, =value_address
        bl scanf
        ldr r6, =value_address
        ldr r6, [r6] @ r6 := numero de linhas

        @le numero de colunas
        ldr r0, =decimal_format
        ldr r1, =value_address
        bl scanf
        ldr r7, =value_address
        ldr r7, [r7] @ r7 := numero de colunas

        @inicializando contador 
        mul r10, r6, r7 @ r10 := numero de elementos
        mov r8, r5 @r8 := posicao corrente na matriz

        @leitura dos elementos da matriz
        start_read:
            cmp r10, #0
            beq end_read

            ldr r0, =decimal_format
            ldr r1, =value_address
            bl scanf
            ldr r2, =value_address
            ldr r1, [r2]

            str r1, [r8]

            add r8, r8, #4
            sub r10, r10, #1

            b start_read
        end_read :

        mov r0, r5
        mov r1, r6
        mov r2, r7

        pop {ip, pc}

    @ impressao da matriz
    @ entrada {r0 = endereco da matriz, r1 = linhas, r2 = colunas}
    print_matrix:
        push {ip, lr}

        mov r5, r0
        mov r6, r1
        mov r7, r2

        @inicializando contador 
        mul r10, r6, r7
        mov r8, #0

        @imprimindo dos elementos da matriz
        start_print:
            cmp r10, #0
            beq end_print
            add r8, r8, #1

            ldr r0, =print_format
            ldr r1, [r5]
            bl printf

            cmp r8, r7
            beq print_newline
            print_space:
                ldr r0, =space
                b print
            print_newline:
                mov r8, #0
                ldr r0, =line_break
                b print
            print:
                bl printf

            add r5, r5, #4
            sub r10, r10, #1
            b start_print
        end_print :

        pop {ip, pc}

    @ multiplicacao de matrizes
    @ entrada {r0 = endereco da matriz resultado, r1 = endereco da matriz A, r2 = endereco da matriz B, r3 = linhas de A, r4 = colunas de A/linhas de B, r5 = colunas de B}
    @ saida {r0 = endereco do resultado}
    multiply_matrix:
        push {ip, lr}

        mov r6, #0
        @interando em cada elemento da matriz resultado
        start_calculate_line:
             cmp r6, r3
             beq end_calculate_line

             mov r7, #0
             start_calculate_column:
                 cmp r7, r5
                 beq end_calculate_column

                 @calculando o elemento [r6, r7] da matriz resultado
                 mov r8, #0
                 mov r9, #0
                 start_calculate_element:
                     cmp r9, r4
                     beq end_calculate_element

                     @lendo o valor em A
                     mul r10, r4, r6
                     add r10, r10, r9
                     push {r8}
                     push {r7}
                     mov r8, #4
                     mul r7, r10, r8
                     mov r10, r7
                     pop {r7}
                     pop {r8}
                     add r10, r10, r1
                     ldr r10, [r10]

                     @lendo o valor em B
                     mul r12, r5, r9
                     add r11, r7, r12
                     push {r8}
                     push {r7}
                     mov r8, #4
                     mul r7, r11, r8
                     mov r11, r7
                     pop {r7}
                     pop {r8}
                     add r11, r11, r2
                     ldr r11, [r11]

                     mul r12, r10, r11
                     add r8, r8, r12

                     add r9, r9, #1
                     b start_calculate_element
                 end_calculate_element:

                 @gravando o valor na matriz
                 mul r9, r5, r6
                 add r9, r9, r7
                 push {r8}
                 push {r7}
                 mov r8, #4
                 mul r7, r9, r8
                 mov r9, r7
                 pop {r7}
                 pop {r8}
                 add r9, r9, r0
                 str r8, [r9]

                 add r7, r7, #1
                 b start_calculate_column
             end_calculate_column:

             add r6, r6, #1
             b start_calculate_line
        end_calculate_line:

        pop {ip, pc}

    @ definicao da funcao main
    main:
        push {ip, lr}

        ldr r0, =A
        bl read_matrix

        mov r11, r1
        mov r12, r2

        ldr r0, =B
        bl read_matrix
       
        cmp r12, r1
        beq start_compatible_matrix
            ldr r0, =error_message
            bl printf
            b end_compatible_matrix
        start_compatible_matrix:
            mov r5, r2
            mov r4, r1
            mov r3, r11
            ldr r0, =result
            ldr r1, =A
            ldr r2, =B
            bl multiply_matrix

            ldr r0, =result
            mov r1, r3
            mov r2, r5
            bl print_matrix
        end_compatible_matrix:

        mov r0, #0
        pop {ip, pc}
