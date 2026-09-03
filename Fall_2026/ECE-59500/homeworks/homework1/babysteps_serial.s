.equ UART1_UTXD, 0x02020040

.global _start

_start:
    ldr r0, =message
    ldr r1, =UART1_UTXD

print_character:
    ldrb r2, [r0], #1
    cmp r2, #0
    beq .
    str r2, [r1]
    b print_character

message:
    .asciz "Hello from serial0!\r\n"
