
; input: EBX[ECX] = bignumber
;        ECX = length, in BITs
;        EAX = number
; output:EDX = GCD(*EBX, EAX)

shortgcd:               push    eax
                        push    ecx

                        call    shortmod

__cycle:                mov     ecx, edx
                        jecxz   __exit
                        xor     edx, edx
                        div     ecx
                        mov     eax, ecx
                        jmp     __cycle

__exit:                 xchg    edx, eax

                        pop     ecx
                        pop     eax
                        retn
