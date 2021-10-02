
; input:
;   EBX[] = random stuff, length = ECX bits
;   ECX   = length in BIT's
;   EDI   = prime table

find_prime:             pusha

                        ; we will generate Blum primes
                        ; (dunno who the fuck is it, but such primes are
                        ; 3 mod 4 congruent, i.e. such prime%4==3
                        or      byte ptr [ebx], 3       ; *EBX |= blum?3:1

                        mov     eax, ecx
                        shr     eax, 3
                        or      byte ptr [ebx+eax-1], 0C0h ; set 2 highest bits

                        mov     esi, NP
__x1:                   mov     eax, [edi+esi*4-4]      ; eax = prime[i]
                        call    shortmod
                        push    edx
                        dec     esi
                        jnz     __x1

                        mov     ebp, ecx

__cycle:
                        xor     ecx, ecx

__x2:                   mov     eax, [esp+ecx*4]
                        add     eax, esi
                        xor     edx, edx
                        div     dword ptr [edi+ecx*4]
                        test    edx, edx
                        jz      __false ; (remainder[i]+delta)%prime[i]==0 ?

                        inc     ecx
                        cmp     ecx, NP
                        jb      __x2

                        mov     ecx, ebp
                        call    test_prime
                        jnz     __false

                        add     esp, NP*4       ; free remainders table

                        popa
                        retn

__false:
                        add     esi, 4          ; delta += (blum?4:2)
                        add     dword ptr [ebx], 4   ; *EBX += (blum?4:2)
                        jnc     __cycle
__x3:                   lea     ebx, [ebx+4]
                        adc     dword ptr [ebx], 0
                        jnc     __x3

                        jmp     __cycle
