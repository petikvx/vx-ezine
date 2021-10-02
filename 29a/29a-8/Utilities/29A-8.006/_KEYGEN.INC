
START_E                 equ     3
END_E                   equ     11

_keygen:
keygen                  proc    c
                        arg     _l
                        arg     _rndbuf
                        arg     _ptr_m
                        arg     _ptr_e
                        arg     _ptr_d
                        arg     _ptr_p
                        arg     _ptr_q
                        local   _p:DWORD
                        local   _q:DWORD
                        local   _p1:DWORD
                        local   _q1:DWORD
                        local   _d:DWORD
                        local   _e:DWORD
                        local   _n:DWORD
                        local   _m:DWORD
                        local   _primetable:DWORD
                        local   _rnd:DWORD
                        local   _l_b:DWORD
                        local   _l_half:DWORD
                        local   _l_dd:DWORD
                        local   _l_dd_half:DWORD
                        pusha

                        cld

                        mov     edx, _l
                        shr     edx, 1
                        mov     _l_half, edx
                        shr     edx, 2          ; length in BYTE's
                        mov     _l_b, edx

                        sub     esp, edx
                        mov     _p, esp
                        sub     esp, edx
                        mov     _q, esp
                        sub     esp, edx
                        mov     _p1, esp
                        sub     esp, edx
                        mov     _q1, esp
                        sub     esp, edx
                        mov     _d, esp
                        sub     esp, edx
                        mov     _e, esp
                        sub     esp, edx
                        sub     esp, edx
                        mov     _n, esp
                        sub     esp, edx
                        sub     esp, edx
                        mov     _m, esp
                        sub     esp, edx
                        mov     _rnd, esp
                        sub     esp, NP*4
                        mov     _primetable, esp

                        imul    ebx, edx, 11    ; EBX=stack frame, in BYTE's
                        add     ebx, NP*4       ;

                        shr     edx, 2          ; length in DWORD's
                        mov     _l_dd, edx
                        shr     edx, 1
                        mov     _l_dd_half, edx

                        pusha

                        mov     edi, _primetable
                        mov     ecx, ebx        ; stack frame, in DWORD's
                        shr     ecx, 2          ;
                        xor     eax, eax
                        rep     stosd

                        mov     edi, _primetable
                        call    gen_prime_table ; init primetable

                        ;;
IFDEF   USE_HCRYPTPROV
                        mov     edi, _rndbuf
                        or      edi, edi
                        jnz     __rnd_present
                        mov     edi, _rnd
                        mov     _rndbuf, edi
                        mov     ecx, _l_b
                        call    gen_rndbuf
                        jmp     __rnd_done
__rnd_present:          ;;
ENDIF ; USE_HCRYPTPROV
                        mov     esi, _rndbuf
                        mov     edi, _rnd
                        mov     _rndbuf, edi
                        mov     ecx, _l_dd
                        rep     movsd
__rnd_done:
                        ;;

__restart:
                        mov     esi, _rndbuf

                        mov     eax, [esi+12]         ;
                        xor     [esi], eax            ;
                        shl     dword ptr [esi+0], 1  ;
                        rcl     dword ptr [esi+4], 1  ;
                        rcl     dword ptr [esi+8], 1  ;

                        mov     edi, _p         ; p <-- 1st half of rndbuf
                        mov     ecx, _l_dd_half
                        rep     movsd

                        mov     edi, _q         ; q <-- 2nd half of rndbuf
                        mov     ecx, _l_dd_half
                        rep     movsd

                        ;;

                        mov     ebx, _p         ; p <-- prime
                        mov     edi, _primetable
                        mov     ecx, _l_half
                        call    find_prime

                        mov     ebx, _q         ; q <-- prime
                        call    find_prime

                        mov     edi, _p1        ; p1 = p - 1
                        mov     esi, _p
                        mov     ecx, _l_dd_half
                        stc
                        COPY_SBB_CYCLE

                        mov     edi, _q1        ; q1 = q - 1
                        mov     esi, _q
                        mov     ecx, _l_dd_half
                        stc
                        COPY_SBB_CYCLE

                        mov     eax, START_E-2
__cycle:
                        inc     eax
                        inc     eax

                        cmp     eax, END_E
                        ja      __restart

                        ; find e such that GCD(p-1,e)==1 && GCD(q-1,e)==1
                        mov     ebx, _p1        ; n, or p1,q1
                        mov     ecx, _l_half
                        call    shortgcd        ; EDX = GCD(*EBX, EAX)
                        dec     edx
                        jnz     __cycle

                        mov     ebx, _q1        ; n, or p1/q1
                        call    shortgcd        ; EDX = GCD(*EBX, EAX)
                        dec     edx
                        jnz     __cycle

                        ;;

                        mov     ecx, _e
                        mov     [ecx], eax

                        mov     eax, _m         ; m = p * q
                        mov     esi, _p
                        mov     edi, _q
                        mov     ecx, _l_half
                        call    mult

                        mov     eax, _n         ; n = p1*q1 = (p-1)*(q-1)
                        mov     esi, _p1
                        mov     edi, _q1
                        call    mult

                        ;;

                        mov     eax, _d
                        mov     esi, _e
                        mov     edi, _n
                        mov     ecx, _l
                        call    modinv          ; d = modinv(e, (p-1)*(q-1))

COPY_ONE_DST0           macro
                        local   __skip_cpy
                        or      edi, edi
                        jz      __skip_cpy
                        mov     ecx, _l_dd
                        rep     movsd
__skip_cpy:             endm

                        mov     edi, _ptr_m
                        mov     esi, _m
                        COPY_ONE_DST0

                        mov     edi, _ptr_e
                        mov     esi, _e
                        COPY_ONE_DST0

                        mov     edi, _ptr_d
                        mov     esi, _d
                        COPY_ONE_DST0

                        mov     edi, _ptr_p
                        mov     esi, _p
                        COPY_ONE_DST0

                        mov     edi, _ptr_q
                        mov     esi, _q
                        COPY_ONE_DST0

                        popa

                        add     esp, ebx

                        popa
                        ret

                        endp
