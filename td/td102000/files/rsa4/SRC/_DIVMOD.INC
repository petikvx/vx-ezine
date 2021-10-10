
;----------------------------------------------------------------------------

; input: ESI = x --dividend, length KEYLEN bits
;        EDI = y --divisor   ...
;        EAX = d --result    ...
;        EDX = m --remainder ...
;

x                       =       [esp].pusha_esi
y                       =       [esp].pusha_edi
d                       =       [esp].pusha_eax
m                       =       [esp].pusha_edx

divmod:                 pusha

                        xor     eax, eax

                        mov     edi, d
                        push    KEYLEN/32
                        pop     ecx
                        rep     stosd                   ; d = 0

                        mov     edi, m
                        push    KEYLEN/32
                        pop     ecx
                        rep     stosd                   ; m = 0

                        push    KEYLEN-1
                        pop     ebx             ; i
__cycle:
                        mov     esi, d
                        call    __shl1          ; d = d<<1

                        mov     eax, x
                        bt      [eax], ebx      ; CF <-- x.bit[i]

                        mov     esi, m
                        call    __rcl1          ; m = (m<<1) | x.bit[i]

                        mov     edi, m
                        mov     esi, y

                        push    KEYLEN/32-1
                        pop     ecx
__cmp_cycle:            mov     eax, [edi+ecx*4]
                        cmp     eax, [esi+ecx*4] ; if (m>y)
                        jb      __cmpsub_exit
                        ja      __sub
                        dec     ecx
                        jns     __cmp_cycle

__sub:
                        push    KEYLEN/32
                        pop     ecx
                        clc
__sub_cycle:            mov     eax, [esi]       ; m -= y
                        sbb     [edi], eax
                        lea     esi, [esi+4]
                        lea     edi, [edi+4]
                        loop    __sub_cycle

                        mov     eax, d
                        or      byte ptr [eax], 1
__cmpsub_exit:
                        dec     ebx
                        jns     __cycle

                        popa
                        retn

__shl1:                 clc
__rcl1:                 mov     ecx, KEYLEN/32
__x1:                   rcl     dword ptr [esi], 1
                        lea     esi, [esi+4]
                        loop    __x1
                        retn

;----------------------------------------------------------------------------
