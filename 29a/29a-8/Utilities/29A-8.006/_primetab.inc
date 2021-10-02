
; input/output: EDI = primetable[]
; action: generate NP primes

gen_prime_table:        pusha

                        push    NP/4            ; *ESP=bitset, alloc+zerofill
                        pop     ecx
                        xor     eax, eax
__x1:                   push    eax
                        loop    __x1

                        mov     ecx, NP         ; # of primes to generate

                        inc     eax             ; prime in EAX, start at 2

__cycle:                inc     eax
;                       cmp     eax, NP*8       ; bitset range reached?
;                       jae     __exit
                        bt      [esp], eax      ; process bitset: skip primes
                        jc      __cycle

                        stosd
                        dec     ecx             ; ECX = # of generated primes
                        jz      __exit

                        mov     edx, eax        ; cross off prime * i
__x2:                   add     edx, eax
                        cmp     edx, NP*8
                        jae     __cycle
                        bts     [esp], edx
                        jmp     __x2

__exit:                 add     esp, NP         ; free bitset

                        popa
                        retn
