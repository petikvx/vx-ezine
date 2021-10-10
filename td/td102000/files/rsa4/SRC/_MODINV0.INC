
;----------------------------------------------------------------------------

; þ very, very bad subroutine... too hard to code

; input: ESI = bignumber (a), length KEYLEN bits
;        EDI = bignumber (n), length KEYLEN bits
;        EAX = bignumber (x), length KEYLEN bits
; action: x = modinv(a, n)

modinv                  proc    pascal
                        local   _iminus1
                        local   _i
                        local   _iplus1
                        local   _y:DWORD:KEYLEN/32
                        local   _t:DWORD:KEYLEN/32*2
                        local   _g:DWORD:KEYLEN/32*4
                        local   _v:DWORD:KEYLEN/32*4 = _localsize
                        pusha

_a_ptr                  =       [esp].pusha_esi
_n_ptr                  =       [esp].pusha_edi
_x_ptr                  =       [esp].pusha_eax

                        lea     edi, [esp+32]
                        xor     eax, eax
                        push    _localsize / 4
                        pop     ecx
                        rep     stosd           ; zerofill locals

                        lea     edi, _g

                        mov     esi, _n_ptr
                        push    KEYLEN/32
                        pop     ecx
                        rep     movsd           ; g[0]=n

                        mov     esi, _a_ptr
                        push    KEYLEN/32
                        pop     ecx
                        rep     movsd           ; g[1]=a

                        inc     byte ptr [_v+KEYLEN/8]  ; v[1]=1

                        mov     _iminus1, 0
                        mov     _i, KEYLEN/8            ; i=1
                        mov     _iplus1, KEYLEN/8*2

__cycle:                mov     ebx, _i
                        cmp     _g[ebx], 0
                        je      __exit

                        mov     esi, _iminus1
                        lea     esi, _g[esi]            ; g[i-1]
                        lea     edi, _g[ebx]            ; g[i]
                        lea     eax, _y                 ; y
                        mov     edx, _iplus1
                        lea     edx, _g[edx]            ; g[i+1]
                        call    divmod

                        lea     esi, _y                 ; y
                        lea     edi, _v[ebx]            ; v[i]
                        lea     eax, _t                 ; t
                        call    mult

                        mov     esi, _iminus1
                        lea     esi, _v[esi]            ; v[i-1]
                        mov     edi, _iplus1
                        lea     edi, _v[edi]            ; v[i+1]
                        push    KEYLEN/8/4
                        pop     ecx
                        rep     movsd

                        mov     edi, _iplus1
                        lea     edi, _v[edi]            ; v[i+1]
                        lea     esi, _t                 ; t
                        push    KEYLEN/8/4
                        pop     ecx
                        clc
__x1:                   lodsd
                        sbb     [edi], eax
                        lea     edi, [edi+4]
                        loop    __x1

                         ; i=i+1
                        mov     eax, _iminus1
                        mov     ebx, _i
                        mov     ecx, _iplus1
                        mov     _iminus1, ebx
                        mov     _i,       ecx
                        mov     _iplus1,  eax

                        jmp     __cycle
__exit:
                        mov     esi, _iminus1
                        lea     esi, _v[esi]            ; v[i-1]
                        mov     edi, _x_ptr             ; x
                        push    KEYLEN/32
                        pop     ecx
                        rep     movsd

                        mov     eax, _x_ptr             ; x
                        ; unused high bits requred to do this. of course,
                        ; highest bit (instead of byte) may be used here
                        cmp     byte ptr [eax+KEYLEN/8-1], 0
                        jge     __skipadd               ; x<0 ?

                        mov     esi, _n_ptr             ; n
                        mov     edi, _x_ptr             ; x
                        push    KEYLEN/32
                        pop     ecx
                        clc
__x2:                   lodsd
                        adc     eax, [edi]
                        stosd
                        loop    __x2
__skipadd:

                        popa
                        ret
                        endp

;----------------------------------------------------------------------------

