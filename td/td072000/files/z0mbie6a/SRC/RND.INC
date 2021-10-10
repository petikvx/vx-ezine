
; randomer

my_rnd:                 mov     eax, randseed
                        imul    eax, 214013
                        add     eax, 2531011
                        mov     randseed, eax
                        shr     eax, 16
                        imul    eax, [esp+4]
                        shr     eax, 16
                        test    eax, eax
                        ret

randomize:              pusha
                        call    xxGetTickCount
                        xor     randseed, eax
                        popa
                        ret
