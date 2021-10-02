
                        public  _modexp
                        public  modexp

_modexp:
modexp                  proc    c
                        arg     l:DWORD         ; length, in BIT's
                        arg     x:DWORD         ; result
                        arg     b:DWORD         ; base
                        arg     e:DWORD         ; exponent
                        arg     m:DWORD         ; modulus
                        local   l_dd:DWORD      ; l/32
                        local   p:DWORD         ; temporary (a^e) mod m
                        local   t:DWORD         ; temporary bgnumber
                        pusha

                        cld

                        mov     ecx, l
                        shr     ecx, 3          ; in BYTE's
                        sub     esp, ecx
                        mov     p, esp
                        sub     esp, ecx
                        mov     t, esp
                        shr     ecx, 2          ; in DWORD's
                        mov     l_dd, ecx

; x = 1
                        mov     edi, x
                        xor     eax, eax
                        inc     eax
                        stosd
                        dec     eax
                        dec     ecx
                        rep     stosd

; p = b
                        mov     edi, p
                        mov     esi, b
                        mov     ecx, l_dd
                        rep     movsd

; ebx = highestbit(e)
                        mov     edi, e
                        call    @@bitscan

; for (edx=0; edx<=ebx; edx++)

                        xor     edx, edx
@@pwr_cycle:            push    edx
                        push    ebx

; if (e.bit[edx])
                        mov     eax, e
                        bt      [eax], edx
                        jnc     @@pwr_nobit

; x=(x*p) mod m
                        mov     edx, x
                        call    @@mulmod

@@pwr_nobit:

; p=(p*p) mod m
                        mov     edx, p
                        call    @@mulmod

; } // for
                        pop     ebx
                        pop     edx

                        inc     edx
                        cmp     edx, ebx
                        jbe     @@pwr_cycle

                        ;;

                        mov     ecx, l
                        shr     ecx, 2
                        add     esp, ecx

                        popa
                        ret

; input:  x in EDX
; action: x=(x*p) mod m
; used:   t

@@mulmod:

; t = 0
                        mov     edi, t
                        mov     ecx, l_dd
                        xor     eax, eax
                        rep     stosd

; ebx = highestbit(p)
                        mov     edi, p
                        call    @@bitscan

; while (ebx >= 0)
; {

@@mul_cycle:

; t *= 2
                        mov     edi, t
                        mov     ecx, l_dd
                        clc
                        RCL_CYCLE
                        ; ecx=0,CF

                        call    @@cmpsub

; if (p.bit[ebx])
                        mov     eax, p
                        bt      [eax], ebx
                        jnc     @@mul_nobit

; t += x
                        mov     edi, t
                        mov     esi, edx
                        mov     ecx, l_dd
                        clc
                        ADC_CYCLE
                        ; ecx=0,CF

                        call    @@cmpsub

; }

@@mul_nobit:            dec     ebx
                        jns     @@mul_cycle

; x = t
                        mov     edi, edx
                        mov     esi, t
                        mov     ecx, l_dd
                        rep     movsd

                        retn

; input:  EDI=bignumber
; output: EBX=number of highest bit (0-based)

@@bitscan:              mov     ebx, l
                        dec     ebx
@@bitscan_cycle:        bt      [edi], ebx
                        jc      @@bitscan_exit
                        dec     ebx
                        jnz     @@bitscan_cycle
@@bitscan_exit:         retn

; if (CF:t >= m) t -= m

@@cmpsub:
                        jc      @@ae

                        mov     edi, t
                        mov     esi, m
                        mov     ecx, l_dd
                        CMP_CYCLE @@b, @@ae
@@ae:
                        mov     edi, t
                        mov     esi, m
                        mov     ecx, l_dd
                        clc
                        SBB_CYCLE
@@b:
                        retn

                        endp
