
; генерация случайных чисел - слишком важный вопрос,
; чтобы оставлять его на волю случая.

my_rnd:                 mov     eax, randseed
                        imul    eax, 214013
                        add     eax, 2531011
                        mov     randseed, eax

                        or      al, al
                        jnz     __1
                        call    randomize
__1:
                        shr     eax, 16
                        imul    eax, [esp+4]
                        shr     eax, 16
                        test    eax, eax
                        ret

randomize:              pusha
                        call    xxGetTickCount
                        xchg    esi, eax
                        rol     esi, 16
                        call    get_old_eip
                        xor     esi, eax
                        mov     eax, fs
                        sub     eax, esi
                        downgrade __dn
                        imul    eax, 100001
__dn:                   add     randseed, eax
                        popa
                        ret
