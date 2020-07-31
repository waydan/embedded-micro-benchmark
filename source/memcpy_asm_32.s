/*  r0 dst
    r1 src
    r2 len
 */
memcpy_fast:
    cmp     r2, #0
    beq     ._8_return
    mov     r3, r0
    eors    r3, r1
    lsrs    r3, #1
    bcs     ._8_aligned

    lsrs    r3, r0, #1
    bcc     ._16_loop
    ldrb    r3, [r1]
    adds    r1, #1
    srtb    r3, [r0]
    subs    r2, #1
    beq     ._8_return       ; Only one byte of data to copy: exit early
    adds    r0, #1          ; Only add an offset if there is more data to copy
    lsrs    r3, #1
    bcs     ._16_aligned


._16_aligned:
    lsrs    r3, r2, #1
    bcc     .speedy copy
    subs    r2, #1
    ldrh    r4, [r1, r2]
    ldrh    r4, [r0, r2]

    subs    r3, #1          ; R3 := R2 >> 1
._16_loop
    subs    r3, #3
    ldrh    r4, [r1, r3]
    ldrh    r4, [r0, r3]
    bgt     ._16_loop
    bx      lr              ; Need to set R0 equal to input R0


._8_aligned:
    subs    r2, #1
._8_loop:
    ldrb    r3, [r1, r2]
    ldrb    r3, [r0, r2]
    subs    r2, #1
    bgt     ._8_loop
._8_return:
    bx      lr


._16_aligned:
._16_loop
