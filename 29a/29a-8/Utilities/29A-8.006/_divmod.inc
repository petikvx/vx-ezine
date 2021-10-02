
; input:
;   IN  ECX      = length    = l  (in BITs)
;   IN  ESI[ECX] = dividend  = x
;   IN  EDI[ECX] = divisor   = y
;   OUT EAX[ECX] = result    = d
;   OUT EDX[ECX] = remainder = m
; modify:
;   none

x                       =       [esp].pusha_esi
y                       =       [esp].pusha_edi
d                       =       [esp].pusha_eax
m                       =       [esp].pusha_edx

divmod:                 pusha

                        lea     ebx, [ecx-1]    ; for (i=KEYLEN-1; i>=0; i--)

                        shr     ecx, 5          ; EBP = length in DWORD's
                        mov     ebp, ecx

                        mov     edi, eax        ; d = 0
                        xor     eax, eax
                        rep     stosd

                        mov     edi, edx        ; m = 0
                        mov     ecx, ebp
                        rep     stosd
__main_cycle:                                   ; {//for i

                        mov     edi, d          ;   d <<= 1
                        mov     ecx, ebp
                        clc
                        RCL_CYCLE

                        mov     eax, x          ;   CF = x.bit[i]
                        bt      [eax], ebx
                        ; CF

                        mov     edi, edx        ;   m = (m << 1) | CF
                        mov     ecx, ebp
                        RCL_CYCLE

                        mov     edi, edx        ;   if (m >= y)
                        mov     esi, y          ;   {
                        mov     ecx, ebp
                        CMP_CYCLE __b, __ae
__ae:
                        mov     ecx, ebp        ;     m -= y
                        clc
                        SBB_CYCLE

                        mov     eax, d          ;     d |= 1
                        or      byte ptr [eax], 1
__b:                                            ;   }
                        dec     ebx
                        jns     __main_cycle    ; }//for i

                        popa
                        retn
