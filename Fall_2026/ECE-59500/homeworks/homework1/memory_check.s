.global _start

_start:
    ldr r0, =memory_start
    ldr r1, =memory_end

check_memory:
    ldr r2, [r0], #4
    cmp r2, #0
    bne explode
    cmp r0, r1
    bne check_memory

all_zero:
    b .

explode:
    b .

.data
.align 2
memory_start:
    .word 0
    .word 0
    @ .word 1  @ Uncomment this line to test the nonzero path.
    .word 0
    .word 0
memory_end:
