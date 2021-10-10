
_BN_BIT                 =       KEYLEN

modexp                  proc    pascal
                        arg     _e_len           ; in BITs
                        arg     _m_ptr           ; modulus
                        arg     _e_ptr           ; exponent
                        arg     _a_ptr           ; base   --input
                        arg     _x_ptr           ; result --output
                        pusha

                        push    _BN_BIT
                        push    _a_ptr
                        push    _x_ptr
                        push    _e_ptr
                        push    _m_ptr
                        call    rsa_main

                        popa
                        ret
                        endp

rsa_main                proc    pascal
                        arg     m:DWORD         ; modulus
                        arg     b:DWORD         ; exponent
                        arg     x:DWORD         ; result
                        arg     a:DWORD         ; base
                        arg     bn_bit:DWORD    ; keylen, in BITs
                        local   bn_dword
                        local   p:DWORD:_BN_BIT/32 ; temporary (a^i) mod m
                        local   t:DWORD:_BN_BIT/32 ; temporary bgnumber
                        pusha

                        cld

                        mov     eax, bn_bit
                        shr     eax, 5
                        mov     bn_dword, eax

; x = 1
                        mov     edi, x
                        xor     eax, eax
                        inc     eax
                        stosd
                        mov     ecx, bn_dword
                        dec     ecx
                        dec     eax
                        rep     stosd

; p = a
                        lea     edi, p
                        mov     esi, a
                        mov     ecx, bn_dword
                        rep     movsd

; ebx = highestbit(b)
                        mov     edi, b
                        call    @@bitscan

; for (edx=0; edx<=ebx; edx++)

                        xor     edx, edx
@@pwr_cycle:            push    edx
                        push    ebx

; if (b.bit[edx])
                        mov     eax, b
                        bt      [eax], edx
                        jnc     @@pwr_nobit

; x=(x*p) mod m
                        mov     edx, x
                        call    @@mulmod

@@pwr_nobit:

; p=(p*p) mod m
                        lea     edx, p
                        call    @@mulmod

; } // for
                        pop     ebx
                        pop     edx

                        inc     edx
                        cmp     edx, ebx
                        jbe     @@pwr_cycle

                        popa
                        ret

; input:  x in EDX
; action: x=(x*p) mod m
; used:   t

                        align   4
@@mulmod:

; t = 0
                        lea     edi, t
                        mov     ecx, bn_dword
                        xor     eax, eax
                        rep     stosd

; ebx = highestbit(p)
                        lea     edi, p
                        call    @@bitscan

; while (ebx >= 0)
; {

@@mul_cycle:

; t *= 2
                        lea     edi, t
                        mov     ecx, bn_dword
                        xor     eax, eax
@@shl_cycle:            rcl     dword ptr [edi], 1
                        lea     edi, [edi+4]
                        loop    @@shl_cycle

                        call    @@cmpsub

; if (p.bit[ebx])
                        bt      p, ebx
                        jnc     @@mul_nobit

; t += x
                        mov     esi, edx
                        lea     edi, t
                        xor     eax, eax
                        mov     ecx, bn_dword
@@add_cycle:            mov     eax, [esi]
                        adc     [edi], eax
                        lea     esi, [esi+4]
                        lea     edi, [edi+4]
                        loop    @@add_cycle

                        call    @@cmpsub

; }

@@mul_nobit:            dec     ebx
                        jns     @@mul_cycle

; x = t
                        mov     edi, edx
                        lea     esi, t
                        mov     ecx, bn_dword
                        rep     movsd

                        retn

; input:  EDI=bignumber
; output: EBX=number of highest bit (0-based)

@@bitscan:              mov     ebx, bn_bit
                        dec     ebx
@@bitscan_cycle:        bt      [edi], ebx
                        jc      @@bitscan_exit
                        dec     ebx
                        jnz     @@bitscan_cycle
@@bitscan_exit:         retn

; action: if (t>=m) t-=m;

                        align   4
@@cmpsub:
                        lea     esi, t
                        mov     edi, m
                        mov     ecx, bn_dword
                        dec     ecx
@@cmp_cycle:            mov     eax, [esi+ecx*4]
                        cmp     eax, [edi+ecx*4]
                        jb      @@cmpsub_exit
                        ja      @@sub
                        dec     ecx
                        jns     @@cmp_cycle
@@sub:
                        mov     esi, m
                        lea     edi, t
                        xor     eax, eax
                        mov     ecx, bn_dword
@@sub_cycle:            mov     eax, [esi]
                        sbb     [edi], eax
                        lea     esi, [esi+4]    ; LODSD/SCASD are too slow
                        lea     edi, [edi+4]
                        loop    @@sub_cycle
@@cmpsub_exit:
                        retn

                        endp
