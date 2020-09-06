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

MEMORY {
    FLASH (rx)  : ORIGIN = 0x00000000,  LENGTH = 0x20000 /* 128K */
    RAM (rwx)   : ORIGIN = 0x1FFFF000,  LENGTH = 0x4000  /*  16K */
}

/* The following symbols are referenced by this linker script and
 * must be declared somewhere in the source code:
 *      Reset_Handler : Entry of reset handler
 *
 * The following symbols are defined by this linker script and may
 * be used by source code without additional definition:
 *      __exidx_start
 *      __exidx_end
 *      __data_load_addr__
 *      __data_start__
 *      __data_end__
 *      __bss_start__
 *      __bss_end__
 *      __end__
 *      end
 *      __HeapLimit
 *      __StackLimit
 *      __StackTop
 *      __stack
 */

ENTRY(Reset_Handler)

__heap_size__  = 0x0000;
__stack_size__ = 0x0400;

SECTIONS {

    /* The interrupt vector used during startup must be placed at
     * address 0. */
    .isr_vector 0x0 : {
        KEEP(*(.isr_vector))
    } > FLASH

    /* The Kinetis device includes flash security features. Default
     * settings are loaded during power up reset from specific memory
     * addresses in flash. */
    .flash_config 0x400 : {
        KEEP(*(.flash_config*))
    } > FLASH

	.text : {
		*(.text*)
		*(.rodata*)
		*(.eh_frame*)
	} > FLASH

	.ARM.extab : {
		*(.ARM.extab* .gnu.linkonce.armextab.*)
	} > FLASH

	.ARM.exidx : {
	    __exidx_start = .;
		*(.ARM.exidx* .gnu.linkonce.armexidx.*)
	    __exidx_end = .;
	} > FLASH

	HIDDEN(__etext = ALIGN (4));
    /* The stack will be placed at the low address of RAM. In case
     * the stack overflows, it will colide with an unwritable
     * address space causing a hard fault instead of data corruption
     *
     * Per the ARM standard, the stack must be aligned on an eight-
     * byte Boundary. */
	. = ORIGIN(RAM);

	.stack ALIGN(8) (NOLOAD): {
		__StackLimit = .;
		*(.stack*)
		. += __stack_size__;
		. = ALIGN(8);
		__StackTop = .;
	    PROVIDE(__stack = __StackTop);
	} > RAM


    /* The data section must be aligned to a four-byte boundary */
	.data ALIGN(4) : AT(__etext) {
	 	__data_load_addr__ = LOADADDR(.data);
		__data_start__ = .;
		*(.data*)
		. = ALIGN(4);
		__data_end__ = .;
		HIDDEN(__data_size__ = __data_end__ - __data_start__);
	} > RAM


    /* The bss section must be aligned to a four-byte boundary */
	.bss ALIGN(4) : {
		__bss_start__ = .;
		*(.bss*)
		*(COMMON)
		. = ALIGN(4);
		__bss_end__ = .;
		HIDDEN(__bss_size__ = __bss_end__ - __bss_start__);
	} > RAM


    /* The heap is located at the end of ROM and will occupy at least
     * the length given by __heap_size__ or give an erro at build
     * time.
     *
     * Per the ARM standard, the heap must be aligned on an eight-
     * byte Boundary. */
	/*
	.heap ALIGN(8) : {
        __end__ = .;
		PROVIDE(end = .);
		*(.heap*)
        . = ORIGIN(RAM) + LENGTH(RAM);
		__HeapLimit = .;
	} > RAM
	*/
	/* Check that the heap has sufficient size*/
/*	ASSERT(SIZEOF(.heap) >= __heap_size__, "The heap section has insufficient size")
*/
}
