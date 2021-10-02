
; primality test using Fermat's theorem
; input:
;   IN ECX = length in BIT's
;   IN EBX[ECX] = bignumber to test
; output:
;   ZF==1 (jz ) --> prime
;   ZF==0 (jnz) --> not a prime

                        public  _testprime
                        public  testprime

_testprime:
testprime               proc    c
                        arg     prime_len
                        arg     prime_ptr
                        uses    ebx
                        cld
                        mov     ebx, prime_ptr
                        mov     ecx, prime_len
                        call    test_prime
                        setz    al
                        movzx   eax, al
                        ret
                        endp

test_prime:
                        pusha

                        mov     edi, ecx        ; length, BIT's
                        shr     ecx, 3          ; length, BYTE's

                        sub     esp, ecx        ; EBP[]
                        mov     ebp, esp
                        sub     esp, ecx        ; EDX[]
                        mov     edx, esp
                        sub     esp, ecx        ; ESP[]

                        push    edi             ; length, BIT's

                        shr     ecx, 2          ; length, DWORD's

                        push    ecx

                        mov     edi, ebp        ; EBP[] = 0
                        xor     eax, eax
                        rep     stosd

                        pop     ecx
                        push    ecx

                        mov     edi, edx        ; EDX[] = EBX[] - 1
                        mov     esi, ebx
                        stc
                        COPY_SBB_CYCLE

                        pop     ecx
                        imul    ecx, 3*4        ; frame size, BYTE's

                        pop     edi             ; length, BIT's

                        mov     eax, 07050302h  ; nice trick, yeah?

__cycle:                mov     [ebp], al
                        shr     eax, 8

                        mov     esi, esp
                        push    ebx             ; modulus
                        push    edx             ; exponent == p-1
                        push    ebp             ; base == 2,3,5,7
                        push    esi             ; result
                        push    edi             ; length, BIT's
                        call    modexp
                        add     esp, 5*4

                        dec     dword ptr [esi]
                        jnz     __exit          ; ZF = 0

                        or      eax, eax
                        jnz     __cycle         ; ZF = 1
__exit:
                        lea     esp, [esp+ecx]

                        popa
                        retn
