
;----------------------------------------------------------------------------

; input: EBX = random bignumber
;        EDI = prime table

find_prime:             pusha

                        ; we will generate Blum primes
                        ; (dunno who the fuck is it, but such primes are
                        ; 3 mod 4 congruent, i.e. such prime%4==3
                        or      byte ptr [ebx], 3       ; *EBX |= blum?3:1

;                       mov     eax, PRIMELEN-1
;                       btr     [ebx], eax              ; set highest bit
                        and     byte ptr [ebx+PRIMELEN/8-1], 0 ; lastbyte=0

                        mov     esi, NP
                        mov     ecx, PRIMELEN
__x1:                   mov     eax, [edi+esi*4-4]      ; eax = prime[i]
                        call    shortmod
                        push    edx
                        dec     esi
                        jnz     __x1

__cycle:                xor     ecx, ecx

__x2:                   mov     eax, [esp+ecx*4]
                        add     eax, esi
                        xor     edx, edx
                        mov     ebp, [edi+ecx*4]
                        div     ebp
                        test    edx, edx
                        jz      __false ; (remainder[i]+delta)%prime[i]==0 ?

                        inc     ecx
                        cmp     ecx, NP
                        jb      __x2

                        call    test_prime
                        jnz     __false

                        add     esp, NP*4       ; free remainders table

                        popa
                        retn

__false:                push    4               ; blum?4:2
                        pop     eax

                        add     esi, eax        ; delta += 4

                        add     dword ptr [ebx], eax ; *EBX += 4
                        jnc     __cycle
__x3:                   lea     ebx, [ebx+4]
                        adc     dword ptr [ebx], 0
                        jnc     __x3

                        jmp     __cycle

;----------------------------------------------------------------------------
