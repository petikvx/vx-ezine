
rnd                     macro   x   ; rnd(x), ZF if 0, ECX modified
                        push    x
                        call    my_rnd
                        pop     ecx
                        endm

randomize:              pusha
                        callW   GetTickCount
                        add     randseed, eax
                        popa
                        ret

; C calling convention

my_rnd:                 mov     eax, randseed
                        imul    eax, 214013
                        add     eax, 2531011
                        mov     randseed, eax
                        shr     eax, 16
                        imul    eax, [esp+4]
                        shr     eax, 16
                        test    eax, eax
                        ret

