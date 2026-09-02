.equ UART1_UTXD, 0x02020040

.section .text
.global _start

_start:
    ldr r0, =message
    ldr r1, =UART1_UTXD

print_character:
    ldrb r2, [r0], #1
    cmp r2, #0
    beq finished
    str r2, [r1]
    b print_character

finished:
    b finished

message:
    .asciz "Hello from serial0!\r\n"
