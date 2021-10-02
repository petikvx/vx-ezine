
; input: EBX[ECX] = bignumber (dividend)
;        ECX = length in BITs
;        EAX = divisor
; output:EDX = remainder
; action:EDX = *EBX % EAX

shortmod:               push    ecx
                        xor     edx, edx        ; resulting remainder
                        dec     ecx
__x1:                   bt      [ebx], ecx      ; remainder = (remainder<<1) | dividend.bit[i]
                        rcl     edx, 1
                        cmp     edx, eax        ; if (remainder >= divisor)
                        jb      __x2
                        sub     edx, eax        ; remainder -= divisor
__x2:                   dec     ecx             ; while (bit--)
                        jns     __x1
                        pop     ecx
                        retn
