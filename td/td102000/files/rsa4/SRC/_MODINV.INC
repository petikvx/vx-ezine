
;----------------------------------------------------------------------------

; input: ESI = bignumber (a), length KEYLEN bits
;        EDI = bignumber (n), length KEYLEN bits
;        EAX = bignumber (i), length KEYLEN bits
; action: i = modinv(a, n)

modinv                  proc    pascal
                        local   _b:DWORD:KEYLEN/32
                        local   _c:DWORD:KEYLEN/32
                        local   _j:DWORD:KEYLEN/32
                        local   _x:DWORD:KEYLEN/32
                        local   _y:DWORD:KEYLEN/32
                        local   _t:DWORD:KEYLEN/32*2 = _localsize
                        pusha

_a_ptr                  =       [esp].pusha_esi
_n_ptr                  =       [esp].pusha_edi
_i_ptr                  =       [esp].pusha_eax

                        lea     edi, [esp+32]
                        xor     eax, eax
                        push    _localsize / 4
                        pop     ecx
                        rep     stosd           ; zerofill locals

                        lea     edi, _b
                        mov     esi, _n_ptr
                        push    KEYLEN/32
                        pop     ecx
                        rep     movsd           ; b=n

                        lea     edi, _c
                        mov     esi, _a_ptr
                        push    KEYLEN/32
                        pop     ecx
                        rep     movsd           ; c=a

                        inc     byte ptr _j     ; j=1

__cycle:                cmp     _c, 0
                        je      __exit

                        lea     esi, _b         ; b
                        lea     edi, _c         ; c
                        lea     eax, _x         ; x
                        lea     edx, _y         ; y
                        call    divmod

                        lea     edi, _b
                        lea     esi, _c
                        push    KEYLEN/32
                        pop     ecx
                        rep     movsd           ; b=c

                        lea     edi, _c
                        lea     esi, _y
                        push    KEYLEN/32
                        pop     ecx
                        rep     movsd           ; c=y

                        lea     edi, _y
                        lea     esi, _j
                        push    KEYLEN/32
                        pop     ecx
                        rep     movsd           ; y=j

                        lea     esi, _j         ; j
                        lea     edi, _x         ; x
                        lea     eax, _t         ; t
                        call    mult            ; t = j * x

                        push    KEYLEN/32
                        pop     ecx
                        xor     ebx, ebx        ; CF=0
                        mov     edx, _i_ptr
__x1:                   mov     eax, [edx+ebx]
                        sbb     eax, _t[ebx]
                        mov     _j[ebx], eax    ; j = i - t
                        lea     ebx, [ebx+4]
                        loop    __x1

                        mov     edi, _i_ptr
                        lea     esi, _y
                        push    KEYLEN/32
                        pop     ecx
                        rep     movsd           ; i=y

                        jmp     __cycle
__exit:
                        mov     eax, _i_ptr
                        cmp     byte ptr [eax+KEYLEN/8-1], 0
                        jge     __skipadd               ; i<0 ?

                        mov     esi, _n_ptr             ; n
                        mov     edi, _i_ptr             ; i
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

