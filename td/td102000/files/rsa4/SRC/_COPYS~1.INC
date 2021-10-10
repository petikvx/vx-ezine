
;----------------------------------------------------------------------------

; input: ESI=source bignumber
;        EDI=dest   bignumber
; action: *EDI = *ESI - 1

copy_sub1:              pusha
                        push    KEYLEN/32
                        pop     ecx
                        stc
__x1:                   lodsd
                        sbb     eax, 0
                        stosd
                        loop    __x1
                        popa
                        retn

;----------------------------------------------------------------------------
