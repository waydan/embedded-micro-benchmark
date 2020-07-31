/* Copyright 2020 Daniel Way
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

    .syntax unified
    .arch armv6-m
    .text
    .thumb


/* Constants used in this module */
    .equ    SYST_BASE,       0xE000_E010    ; Base address of the SysTick counter
    .equ    TIMER_RESET_VAL, 0x00FF_FFFF    ; Reset value for the SysTick counter


    .align 2
    .thumb_func
    .type timer_init, %function
/* Configures the timer used to measure function execution time */
timer_init:
    ldr     r0, =SYST_BASE
    /* The timer is a 24-bit count down, so it should be reloaded to the
     * maximum value */
    ldr     r1, =TIMER_RESET_VAL
    str     r1, [r0, #4]
    /* Enable the timer, disable the interrupt, and use the processor clock */
    movs    r1, 0b101
    strh    r1, [r0]
    bx      lr
    .size timer_init, . - timer_init


    .align 2
    .thumb_func
    .type time_execution, %function
/* The timing function is designed to work with the standard memcpy function
 * which takes three parameters. A fourth parameter, the pointer to the
 * function under test, must allso be called when calling this timing
 * funciton */
time_execution:
    push    {r4, r5, lr}
    /* Store the SysTick base address and counter reset value in
     * non-volatile registers */
    ldr     r4, =SYST_BASE
    ldr     r5, =TIMER_RESET_VAL
    /* Reset the counter and overflow bit by writing to SYST_CVR */
    str     r0, [r4, #8]
    /* Call the function under test */
    blx     r3
    /* Check if the timer overflowed */
    ldrh    r1, [r4, #2]
    /* Read the counter value and calculate elapsed time*/
    ldr     r2, [r4, #8]
    subs    r0, r5, r2
    .size time_execution, . - time_execution


    .align 2
    .thumb_func
    .type tare, %function
/* Test the function call overhead with a function that returns immediately*/
tare:
    bx      lr
    .size tare, . - tare
