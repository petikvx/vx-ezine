
;----------------------------------------------------------------------------

keygen                  proc    pascal
                        arg     _rndbuf
                        arg     _seckey
                        arg     _pubkey
                        local   _primetable:DWORD:NP
                        local   _q1:DWORD:KEYLEN/32
                        local   _p1:DWORD:KEYLEN/32
                        local   _q:DWORD:KEYLEN/32
                        local   _p:DWORD:KEYLEN/32
                        local   _d:DWORD:KEYLEN/32
                        local   _e:DWORD:KEYLEN/32
                        local   _n:DWORD:KEYLEN/32*2
                        local   _m:DWORD:KEYLEN/32*2 = _localsize
                        pusha

                        call    __zerolocals    ; init local vars with 0

                        mov     esi, _rndbuf

                        lea     edi, _p
                        push    PRIMELEN/32
                        pop     ecx
                        rep     movsd           ; p <-- 1st half of rndbuf

                        lea     edi, _q
                        push    PRIMELEN/32
                        pop     ecx
                        rep     movsd           ; q <-- 2nd half of rndbuf

                        lea     edi, _primetable
                        call    gen_prime_table ; init primetable

                        lea     ebx, _p         ; p <-- prime
                        call    find_prime

                        lea     ebx, _q         ; q <-- prime
                        call    find_prime

                        lea     esi, _p
                        lea     edi, _q
                        lea     eax, _m
                        call    mult            ; m = p * q

                        lea     esi, _p
                        lea     edi, _p1
                        call    copy_sub1       ; p1 = p - 1

                        lea     esi, _q
                        lea     edi, _q1
                        call    copy_sub1       ; q1 = q - 1

                        lea     esi, _p1
                        lea     edi, _q1
                        lea     eax, _n
                        call    mult            ; n = p1*q1 = (p-1)*(q-1)

                        ; EAX <-- e,
                        ; such that GCD(p-1,e)==1 && GCD(q-1,e)==1

                        xor     eax, eax
                        inc     eax             ; start at 3

__cycle:                inc     eax
                        inc     eax

                        lea     ebx, _n         ; n, or p1/q1
                        mov     ecx, KEYLEN
                        call    shortgcd        ; EDX = GCD(*EBX, EAX)
                        dec     edx
                        jnz     __cycle

;                       lea     ebx, _q1
;                       call    shortgcd        ; EDX = GCD(*EBX, EAX)
;                       dec     edx
;                       jnz     __cycle

                        mov     _e, eax         ; e <-- EAX

                        lea     esi, _e
                        lea     edi, _n
                        lea     eax, _d
                        call    modinv          ; d = modinv(e, (p-1)*(q-1))

                        mov     edi, _pubkey

                        lea     esi, _m
                        push    KEYLEN/32
                        pop     ecx
                        rep     movsd

                        lea     esi, _e
                        push    KEYLEN/32
                        pop     ecx
                        rep     movsd

                        mov     edi, _seckey

                        lea     esi, _m
                        push    KEYLEN/32
                        pop     ecx
                        rep     movsd

                        lea     esi, _d
                        push    KEYLEN/32
                        pop     ecx
                        rep     movsd

;NEVER EQU TODAY
IFDEF NEVER
                        call    __zzz
                        db      'debug',0
__zzz:                  pop     edx
                        call    fcreate
                        xchg    ebx, eax
                        lea     edx, _m
                        mov     ecx, KEYLEN/8
                        call    fwrite
                        lea     edx, _e
                        mov     ecx, KEYLEN/8
                        call    fwrite
                        lea     edx, _d
                        mov     ecx, KEYLEN/8
                        call    fwrite
                        lea     edx, _p
                        mov     ecx, KEYLEN/8
                        call    fwrite
                        lea     edx, _q
                        mov     ecx, KEYLEN/8
                        call    fwrite
                        lea     edx, _p1
                        mov     ecx, KEYLEN/8
                        call    fwrite
                        lea     edx, _q1
                        mov     ecx, KEYLEN/8
                        call    fwrite
                        lea     edx, _n
                        mov     ecx, KEYLEN/8
                        call    fwrite
                        call    fclose
ENDIF

                        call    __zerolocals    ; burn secret stuff
                        
                        popa
                        ret

__zerolocals:           lea     edi, [esp+32]
                        push    _localsize/4
                        pop     ecx
                        xor     eax, eax
                        cld
                        rep     stosd           ; zerofill locals
                        retn

                        endp

;----------------------------------------------------------------------------
