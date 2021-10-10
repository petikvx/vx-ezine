
;----------------------------------------------------------------------------

; input: EBX = bignumber, length = KEYLEN bits, 2nd half = 0s
; output:ZF==1 (jz) -- prime
;        ZF==0 (jnz)-- not a prime

test_prime:             pusha

                        push    KEYLEN/32*3
                        pop     ecx

                        xor     eax, eax
                        push    eax
                        loop    $-1

                        lea     ebp, [esp+KEYLEN/8]
                        lea     edx, [esp+KEYLEN/8*2]

                        mov     esi, ebx
                        mov     edi, edx
                        call    copy_sub1

                        mov     eax, 07050302h  ; nice trick, yeah?

__cycle:                mov     [ebp], al
                        shr     eax, 8

                        push    esp             ; result
                        push    ebp             ; base == 2,3,5,7
                        push    edx             ; exponent == p-1
                        push    ebx             ; modulus
                        push    PRIMELEN        ; e.length in BITs
                        call    modexp

                        dec     dword ptr [esp]
                        jnz     __exit          ; ZF = 0

                        or      eax, eax
                        jnz     __cycle         ; ZF = 1

__exit:                 lea     esp, [esp + KEYLEN/8*3]

                        popa
                        retn

;----------------------------------------------------------------------------
