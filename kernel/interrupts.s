# Copyright (c) 2015, IBM
# Author(s): Dan Williams <djwillia@us.ibm.com>
#
# Permission to use, copy, modify, and/or distribute this software for
# any purpose with or without fee is hereby granted, provided that the
# above copyright notice and this permission notice appear in all
# copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
# WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
# AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
# DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA
# OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
# TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

    /* error code is just under the 9 caller_save registers, 8 bytes each */ 
    .set ERROR_CODE_OFFSET, 9 * 8
    /* error code is just under the error code (if there is one) */
    .set RIP_OFFSET_E, 10 * 8
    .set RIP_OFFSET_NE, 9 * 8
        
    .macro PUSH_CALLER_SAVE
    pushq %rax
    pushq %rdi
    pushq %rsi
    pushq %rdx
    pushq %rcx
    pushq %r8
    pushq %r9
    pushq %r10
    pushq %r11
    .endm

    .macro POP_CALLER_SAVE
    popq %r11
    popq %r10
    popq %r9
    popq %r8
    popq %rcx
    popq %rdx
    popq %rsi
    popq %rdi
    popq %rax
    .endm

.macro INTERRUPT_E n
.global interrupt\n
.type interrupt\n, @function
interrupt\n:
    PUSH_CALLER_SAVE

    movq $\n, %rdi              # pass interrupt number 
    movq ERROR_CODE_OFFSET(%esp), %rsi # pass error code
    movq RIP_OFFSET_E(%esp), %rdx      # pass faulting rip
    call interrupt_handler

    POP_CALLER_SAVE
    addq $8, %rsp               # discard error code

    iretq
.endm
    
.macro INTERRUPT_NE n
.global interrupt\n
.type interrupt\n, @function
interrupt\n:
    PUSH_CALLER_SAVE

    movq $\n, %rdi              # pass interrupt number
    movq $0, %rsi               # pass 0 as error code
    movq RIP_OFFSET_NE(%esp), %rdx # pass faulting rip        
    call interrupt_handler

    POP_CALLER_SAVE
    iretq
.endm

.include "interrupt_vectors.s"
        
.global idt_load
.type idt_load, @function
idt_load:
    lidt 0(%rdi)
    ret

.global gdt_load
.type gdt_load, @function
gdt_load:
        lgdt 0(%rdi)
        ret

.global tss_load
.type tss_load, @function
tss_load:
        ltr %di
        ret

