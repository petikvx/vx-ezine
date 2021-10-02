
; input:
;   ECX   = bignumber length, in BIT's
;   ESI[] = bignumber 1, length ECX bits
;   EDI[] = bignumber 2, length ECX bits
;   EAX[] = resulting bignumber, length ECX*2 bits
; output:EAX[] = ESI[] * EDI[]

mult:                   pusha

                        mov     ebp, edi                ; EBP=n2

                        shr     ecx, 3
                        push    ecx                     ; in BYTE's

                        mov     edi, eax
                        shr     ecx, 2                  ; in DWORD's
                        xor     eax, eax
                        rep     stosd

                        mov     ecx, esi                ; ECX=n1

                        xor     esi, esi

__x1:                   xor     edi, edi

__x2:                   mov     eax, [ecx+esi]          ; n1[i]
                        mov     edx, [ebp+edi]          ; n2[j]
                        mul     edx

                        lea     ebx, [esi+edi]
                        add     ebx, [esp+4].pusha_eax  ; r[i+j]
                        add     [ebx], eax
                        lea     ebx, [ebx+4]
                        adc     [ebx], edx
                        jnc     __x4

__x3:                   lea     ebx, [ebx+4]
                        adc     dword ptr [ebx], 0
                        jc      __x3

__x4:                   add     edi, 4
                        cmp     edi, [esp]              ; in BYTE's
                        jb      __x2
__x5:                   add     esi, 4
                        cmp     esi, [esp]
                        jb      __x1

                        pop     eax                     ; in BYTE's

                        popa
                        retn
