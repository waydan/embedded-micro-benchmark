// Copyright 2020 Daniel Way
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

    .syntax unified
    .arch armv6-m

    .align 2
    .section .isr_vector, "a"
    .global interupt_vector
interupt_vector:
    /* ARM Core System Handler Vectors */
    .word   __StackTop          @ Stack Pointer
    .word   Reset_Handler       @ Reset
    .word   _def_isr_trap       @ NMI
    .word   _def_isr_trap       @ Hard Fault
    .word   0                   @ reserved
    .word   0                   @ reserved
    .word   0                   @ reserved
    .word   0                   @ reserved
    .word   0                   @ reserved
    .word   0                   @ reserved
    .word   0                   @ reserved
    .word   _def_isr_trap       @ SV Call
    .word   0                   @ reserved
    .word   0                   @ reserved
    .word   _def_isr_trap       @ SRV Pending
    .word   _def_isr_trap       @ SysTick
    /* Non-Core Vectors */
    .word   _def_isr_trap       @ DMA ch 0, 4
    .word   _def_isr_trap       @ DMA ch 1, 5
    .word   _def_isr_trap       @ DMA ch 2, 6
    .word   _def_isr_trap       @ DMA ch 3, 7
    .word   _def_isr_trap       @ DMA errors
    .word   _def_isr_trap       @ FTFA
    .word   _def_isr_trap       @ PMC
    .word   _def_isr_trap       @ LLWU
    .word   _def_isr_trap       @ I2C0
    .word   0                   @ reserved
    .word   _def_isr_trap       @ SPI0
    .word   0                   @ reserved
    .word   _def_isr_trap       @ UART0
    .word   _def_isr_trap       @ UART1
    .word   _def_isr_trap       @ FlexCAN0
    .word   _def_isr_trap       @ ADC0
    .word   _def_isr_trap       @ ADC0
    .word   _def_isr_trap       @ FTM0
    .word   _def_isr_trap       @ FTM1
    .word   _def_isr_trap       @ FTM2
    .word   _def_isr_trap       @ CMP0
    .word   _def_isr_trap       @ CMP1
    .word   _def_isr_trap       @ FTM3
    .word   _def_isr_trap       @ WDOG/EWM
    .word   _def_isr_trap       @ FTM4
    .word   _def_isr_trap       @ DAC0
    .word   _def_isr_trap       @ FTM5
    .word   _def_isr_trap       @ MCG
    .word   _def_isr_trap       @ LPTMR0
    .word   _def_isr_trap       @ PDB0, PDB1
    .word   _def_isr_trap       @ PORT A
    .word   _def_isr_trap       @ PORT B, C, D, E


    .text
    .thumb

/*
 * Default handler to catch unimplemented interrupts and exceptions. No recovery
 * is available if code hits this point, so it should only be used for debug and
 * experimentation.
 *
 * Symbol is not global to avoid erroneous reference outside of this file.
 */
    .align 1
    .thumb_func
    .type _def_isr_trap, %function
_def_isr_trap:
    nop
    b       _def_isr_trap
    .size _def_isr_trap, . - _def_isr_trap

/*
 * Start of code execution
 * Make sure to include "ENTRY(Power_On_Reset)" in the linker script
 * This function should also be referenced by the static NVIC reset handler
 */
    .align 2
    .thumb_func
    .type Reset_Handler, %function
Reset_Handler:
    cpsid   i                   @ disable all interupts during startup

/* Disable Watchdog Timer */
wdog_disble:
    ldr	    r1, =0x40052000     @ Watchdog base address
	ldr	    r0, =0xD928C520     @ Watchdog unlock keys 1 & 2
	strh	r0, [r1, #14]
	lsrs    r0, #16             @ Shift for watchdog unlock key 2
	strh	r0, [r1, #14]
    ldr     r0, =0x01D0         @ Disable watchdog timer
    strh    r0, [r1]            @ write WDOG_STCTRLH


/* Clear BSS section */
bss_init:
    ldr     r0, =__bss_start__
    ldr     r2, =__bss_end__
    subs    r2, r0
    ble     .bss_init_end       @ exit routine if .bss section is empty
    movs    r1, #0
.bss_loop:
    stm     r0!, {r1}
    subs    r1, #4
    bgt     .bss_loop
.bss_init_end:


/* Initialize DATA section */
data_init:
    ldr     r0, =__data_start__
    ldr     r1, =__data_load_addr__
    ldr     r2, =__data_end__
    subs    r2, r0
    ble     .data_init_end
.data_loop:
    ldm     r1!, {r3}
    subs    r2, #4
    stm     r0!, {r3}
    bgt     .data_loop
.data_init_end:

// Enable users to specify a value with which to
// fill the main program stack. If undefined,
// the stack memory will be uninitialized and its
// contents undefined
/*
#ifdef STACK_FILL
stack_init:
    ldr     r0, =__StackLimit
    ldr     r2, =__StackTop
    subs    r2, r0
    ble     .stack_init_end
#if (STACK_FILL < 256)
    movs    r1, #0
#else
    ldr     r1, =STACK_FILL
#endif
    mov     r3, r1
.stack_fill_loop:
    stm     r0!, {r1, r3}
    subs    r2, #8
    bgt     .stack_fill_loop
.stack_init_end:
#endif ; defined(STACK_FILL)
*/

/* Initialize and start the main program */
//    ldr     r0, =startup
//    blx     r0
    ldr     r0, =main
    cpsie   i
    blx     r0

/* if the main program returns, trap it inan infinite loop */
.main_return:
    wfi
    b   .main_return

    .pool
    .size Reset_Handler, . - Reset_Handler

.end