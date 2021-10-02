
; not very kewl stuff, really.

; input: ESI = bignumber (a), length ECX bits
;        EDI = bignumber (n), length ECX bits
;        EAX = bignumber (i), length ECX bits
;        ECX = length in BIT's
; action: i = modinv(a, n)

_a                      =       [esp].pusha_esi
_n                      =       [esp].pusha_edi
_i                      =       [esp].pusha_eax
_l                      =       [esp].pusha_ecx
_l_dd                   =       [esp].pusha_edx

modinv                  proc    pascal
                        local   _b:DWORD
                        local   _c:DWORD
                        local   _j:DWORD
                        local   _x:DWORD
                        local   _y:DWORD
                        local   _t:DWORD
                        local   _l_dd:DWORD
                        pusha

                        mov     edx, ecx
                        shr     edx, 3          ; EDX=length in BYTE's

                        sub     esp, edx
                        mov     _b, esp
                        sub     esp, edx
                        mov     _c, esp
                        sub     esp, edx
                        mov     _j, esp
                        sub     esp, edx
                        mov     _x, esp
                        sub     esp, edx
                        mov     _y, esp
                        sub     esp, edx
                        sub     esp, edx
                        mov     _t, esp

                        imul    ebx, edx, 7     ; EBX=frame size, in BYTE's

                        shr     edx, 2          ; length in DWORD's
                        mov     _l_dd, edx

                        pusha

                        mov     edi, _t
                        mov     ecx, ebx
                        shr     ecx, 2          ; frame size, in DWORD's
                        xor     eax, eax
                        rep     stosd           ; zerofill locals

                        mov     edi, _b         ; b=n
                        mov     esi, _n
                        mov     ecx, _l_dd
                        rep     movsd

                        mov     edi, _c         ; c=a
                        mov     esi, _a
                        mov     ecx, _l_dd
                        rep     movsd

                        mov     eax, _j
                        inc     byte ptr [eax]  ; j=1

__cycle:                mov     eax, _c
                        cmp     dword ptr [eax], 0
                        je      __exit

                        mov     esi, _b         ; b
                        mov     edi, _c         ; c
                        mov     eax, _x         ; x
                        mov     edx, _y         ; y
                        mov     ecx, _l
                        call    divmod

                        mov     edi, _b         ; b=c
                        mov     esi, _c
                        mov     ecx, _l_dd
                        rep     movsd

                        mov     edi, _c         ; c=y
                        mov     esi, _y
                        mov     ecx, _l_dd
                        rep     movsd

                        mov     edi, _y         ; y=j
                        mov     esi, _j
                        mov     ecx, _l_dd
                        rep     movsd

                        mov     esi, _j         ; j
                        mov     edi, _x         ; x
                        mov     eax, _t         ; t
                        mov     ecx, _l
                        call    mult            ; t = j * x

                        mov     ecx, _l_dd      ; j = i - t
                        mov     edi, _j
                        mov     esi, _i
                        mov     edx, _t
                        xor     ebx, ebx        ; CF=0
__x1:                   mov     eax, [esi+ebx]
                        sbb     eax, [edx+ebx]
                        mov     [edi+ebx], eax
                        lea     ebx, [ebx+4]
                        loop    __x1

                        mov     edi, _i         ; i=y
                        mov     esi, _y
                        mov     ecx, _l_dd
                        rep     movsd

                        jmp     __cycle
__exit:
                        mov     eax, _l
                        shr     eax, 3
                        add     eax, _i
                        cmp     byte ptr [eax-1], 0
                        jge     __skipadd       ; i < 0 ?

                        mov     edi, _i         ; i += n
                        mov     esi, _n
                        mov     ecx, _l_dd
                        clc
                        ADC_CYCLE
__skipadd:
                        popa

                        add     esp, ebx

                        popa
                        ret
                        endp
