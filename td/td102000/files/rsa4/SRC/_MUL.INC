
;----------------------------------------------------------------------------

; input: ESI = bignumber 1, length KEYLEN bits
;        EDI = bignumber 2, length KEYLEN bits
;        EAX = resulting bignumber, length KEYLEN * 2 bits
; action:EAX[] = ESI[] * EDI[]

mult:                   pusha

                        mov     ebp, edi                ; n2

                        mov     edi, eax
                        xor     eax, eax
                        push    KEYLEN/32*2
                        pop     ecx
                        rep     stosd

                        mov     ecx, esi                ; n1

                        xor     esi, esi

__x1:                   xor     edi, edi

__x2:                   mov     eax, [ecx+esi]          ; n1[i]
                        mov     edx, [ebp+edi]          ; n2[j]
                        mul     edx

                        lea     ebx, [esi+edi]
                        add     ebx, [esp].pusha_eax    ; r[i+j]
                        add     [ebx], eax
                        lea     ebx, [ebx+4]
                        adc     [ebx], edx
                        jnc     __x4

__x3:                   lea     ebx, [ebx+4]
                        adc     dword ptr [ebx], 0
                        jc      __x3

__x4:                   add     edi, 4
                        cmp     edi, KEYLEN/8
                        jb      __x2
__x5:                   add     esi, 4
                        cmp     esi, KEYLEN/8
                        jb      __x1

                        popa
                        retn

;----------------------------------------------------------------------------
