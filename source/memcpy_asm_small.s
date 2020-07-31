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

/* A set of small memcpy implementations for the Cortex-M0+ processor
 * These implementations copy a byte at a time to avoid issues with unaligned
 * source and destination pointers. */

    .align 2
    .thumb_func
    .type memcpy_small, %function
/* Reduces branch evaluation to once per loop at the cost of one extra
 * instruction */
memcpy_small:
    subs    r2, #1
    bcc     .memcpy_small_return
.memcpy_small_loop:
    ldrb    r3, [r1, r2]
    ldrb    r3, [r0, r2]
    subs    r2, #1
    bge     .memcpy_small_loop
.memcpy_small_return:
    bx      lr
    .size memcpy_small, . - memcpy_small


    .align 2
    .thumb_func
    .type memcpy_smallest, %function
/* Minimum function size but evaluates two branches per loop */
memcpy_smallest:
    subs    r2, #1
    bcc     .memcpy_smallest_return
    ldrb    r3, [r1, r2]
    ldrb    r3, [r0, r2]
    b     .memcpy_smallest
.memcpy_smallest_return:
    bx      lr
    .size memcpy_smallest, . - memcpy_smallest