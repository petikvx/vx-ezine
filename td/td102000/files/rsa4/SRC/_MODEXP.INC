
;----------------------------------------------------------------------------

; modexp -- main, time critical subroutine.

; þ fixed keylength
; þ lots of code (depending on keylength)
; þ main operations: MUL,CMP,SBB
;   (used CPU's multiplication, 2 times faster than v1.00)

_BN_BIT                 =       KEYLEN
_BN_DWORD               =       _BN_BIT/32
_T_BIT                  =       KEYLEN*2

; action:     x = (a^e) mod m

modexp                  proc    pascal
                        arg     _e_len           ; in BITs
                        arg     _m_ptr           ; modulus
                        arg     _e_ptr           ; exponent
                        arg     _a_ptr           ; base   --input
                        arg     _x_ptr           ; result --output
                        local   _x1
                        local   _x2
                        local   _p_tmp:DWORD:_BN_DWORD
                        local   _t_tmp:DWORD:_T_BIT/32
                        pusha

; x = 1
                        mov     edi, _x_ptr
                        mov     edx, edi
                        xor     eax, eax
                        mov     ecx, _BN_DWORD
                        rep     stosd
                        inc     dword ptr [edx]

; p = a
                        mov     esi, _a_ptr
                        lea     edi, _p_tmp
                        mov     ecx, _BN_DWORD
                        rep     movsd

; for (x1 = 0; x1 < e_len; x1++)

                        mov     _x1, 0

                        align   4
__exp_cycle:

; if (e.bit[x1])
                        mov     eax, _e_ptr
                        mov     edx, _x1
                        inc     _x1
                        bt      [eax], edx
                        jnc     __exp_nobit

; x=(x*p) mod m
                        mov     ecx, _x_ptr
                        call    __mulmod

                        align   4
__exp_nobit:

                        dec     _e_len
                        jz      __exp_exit
; p=(p*p) mod m
                        lea     ecx, _p_tmp
                        call    __mulmod

; } // for
                        jmp     __exp_cycle
__exp_exit:
                        popa
                        ret

; input:  x in ECX
; action: t = x * p
; used:   x = t mod m

                        align   4
__mulmod:

; t = 0
                        xor     eax, eax

                        lea     edi, _t_tmp
                        i=0
                        rept    _T_BIT/32
                        mov     [edi+i], eax
                        i=i+4
                        endm

; esi = maxdword(edx)
                        mov     esi, (_BN_DWORD-1)*4
                        align   4
__x2:                   cmp     [ecx+esi], eax
                        jne     __x1
                        sub     esi, 4
                        jnz     __x2
                        align   4
__x1:

; edi = maxdword(p)
                        mov     edi, (_BN_DWORD-1)*4
                        lea     ebx, _p_tmp
                        align   4
__x3:                   cmp     [ebx+edi], eax
                        jne     __x4
                        sub     edi, 4
                        jnz     __x3
                        align   4
__x4:
                        mov     _x2, edi

; for (int i=maxi; i>=0; i-=4)
; for (int j=maxj; j>=0; j-=4)

                        align   4
__cycle_1:
                        mov     edi, _x2

                        align   4
__cycle_2:

; t[j+1]:t[j] += x[i] * p[j];

                        mov     eax, [esi+ecx]      ; x[i]
                        lea     edx, _p_tmp
                        mov     edx, [edx+edi]      ; p[j]
                        nop
                        mul     edx

;                       lea     ebx, t[esi+edi]         ; t[i+j]
                        lea     ebx, _t_tmp
                        add     ebx, esi
                        add     ebx, edi
                        add     [ebx], eax
                        lea     ebx, [ebx+4]
                        adc     [ebx], edx

                        align   4
__x5:                   lea     ebx, [ebx+4]
                        adc     dword ptr [ebx], 0
                        jc      __x5

; }; // for
; }; // for
                        sub     edi, 4
                        jns     __cycle_2
                        sub     esi, 4
                        jns     __cycle_1

; action: x = t % m
                        lea     esi, _t_tmp

; x = hi(t)
                        k = 1            ; _BN_DWORD..0, ok=1

                        i=0
                        rept    _BN_DWORD-k ; <-- *** MUST BE: _BN_DWORD-1 ***
                        mov     eax, [esi+_T_BIT/8-(_BN_DWORD-k)*4+i]
                        mov     [ecx+i], eax
                        i=i+4
                        endm
                        j=i
                        rept    k
                        if j eq i
                        xor     eax, eax
                        endif
                        mov     [ecx+j], eax
                        j=j+4
                        endm


; for (int i=scanmaxbit(t); i>=0; i--)
; {
                        mov     ebx, _T_BIT - 1 - i*8

                        align   4
__cycle_3:

; x = (x<<1) | bn_getbit(t,i);
                        bt      [esi], ebx

                        i=0
                        rept    _BN_DWORD
                        rcl     dword ptr [ecx+i], 1
                        i=i+4
                        endm

; if (x>=m) x-=m;
                        mov     edx, _m_ptr

                        i       = (_BN_DWORD - 1) * 4
                        rept    _BN_DWORD
                        mov     eax, [ecx+i]
                        cmp     eax, [edx+i]
                        jb      __nosub
                        ja      __sub
                        i       = i - 4
                        endm

                        align   4
__sub:
                        i=0
                        rept    _BN_DWORD
                        mov     eax, [edx+i]
                        if i eq 0
                        sub     [ecx+i], eax
                        else
                        sbb     [ecx+i], eax
                        endif
                        i=i+4
                        endm

                        align   4
__nosub:

; }; // for
                        dec     ebx
                        jns     __cycle_3

                        retn

                        endp

;----------------------------------------------------------------------------
