
; генерация случайных чисел - слишком важный вопрос,
; чтобы оставлять его на волю случая.

; push 10
; call rnd
; jz x00
; dec eax
; jz x01
; ...
; dec eax
; jz x08
; x09:


; input:  RANGE - on the stack
; output: eax=[0..RANGE-1], ZF=0 if EAX==0

rnd:                    mov     eax, randseed
                        imul    eax, 214013
                        add     eax, 2531011
                        mov     randseed, eax
                        shr     eax, 16
                        imul    eax, [esp+4]
                        shr     eax, 16
                        ret     4

randomize:              pusha
                        call    GetTickCount
                        xor     randseed, eax
                        popa
                        ret
