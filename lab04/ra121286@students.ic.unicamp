.globl main
.extern scanf
.extern printf

.data
    format: .asciz "%d"
    address: .word 0

.text
    .align 4

    main:
        push {ip, lr}

        @lendo A
        LDR r1, =address
        LDR r0, =format
        bl scanf
        LDR r2, =address
        LDR r4, [r2]

        @lendo B
        LDR r1, =address
        LDR r0, =format
        bl scanf
        LDR r2, =address
        LDR r5, [r2]

        @lendo C
        LDR r1, =address
        LDR r0, =format
        bl scanf
        LDR r2, =address
        LDR r6, [r2]

        @lendo D
        LDR r1, =address
        LDR r0, =format
        bl scanf
        LDR r2, =address
        LDR r7, [r2]

        @A * B
        MUL r8, r4, r5
        @C * D
        MUL r9, r6, r7

        @A * B + C * D
        ADD r1, r8, r9
        LDR r0, =format
        bl printf

        mov r0, #0
        pop {ip, pc}

