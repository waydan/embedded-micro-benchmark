/*  r0 dst
    r1 src
    r2 len
 */
memcpy_fast:
    // Return early if no bytes to copy
    cmp     r2, #0
    beq     ._8_return

    // Check if src and dst are co-aligned
    mov     r3, r0
    eors    r3, r1
    lsrs    r3, #1
    bcs     ._8_aligned     ; src and dst are byte co-aligned

    // check if dst is currently byte or half-word aligned
    push    {r0, lr}        ; Store R0 before modification
    lsrs    r3, r0, #1
    bcc     ._16_aligned    ; dst is already half-word aligned

    // Adust dst and src to be half-word aligned
    ldrb    r3, [r1]
    subs    r2, #1
    strb    r3, [r0]
    beq     ._16_return      ; Only one byte of data to copy: return early
    adds    r0, #1
    adds    r1, #1

._16_aligned:
    // Are odd or even number of bytes left to be copied
    lsrs    r3, r2, #1
    bcc     ._16_loop       ; even number of bytes

    // Copy the odd bit
    subs    r2, #1
    ldrh    r3, [r1, r2]
    ldrh    r3, [r0, r2]
._16_loop
    subs    r2, #2
    ldrh    r3, [r1, r2]
    ldrh    r3, [r0, r2]
    bgt     ._16_loop
._16_return
    pop     {r0, lr}             ; Need to set R0 equal to input R0


._8_aligned:
    subs    r2, #1
    ldrb    r3, [r1, r2]
    ldrb    r3, [r0, r2]
    bgt     ._8_aligned
._8_return:
    bx      lr