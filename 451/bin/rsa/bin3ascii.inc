

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;In:    ESI = data block (3 bytes(4))
;       EDI = out bufer (4 bytes)
;Out:   filled bufer
bin3ascii:
        pushad

        lodsd
        mov ecx,4

b3a_main:
        push eax
        and al,00111111b
        add al,40h
        stosb
        pop eax

        shr eax,6
        loop b3a_main

        popad
        ret

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;In:    ESI = ascii block (4 bytes)
;       EDI = out bufer   (3 bytes)
;Out:   filled bufer
ascii3bin:
        pushad

        lodsd
        xor edx,edx
        mov ecx,4
a3b_main:
        sub al,40h
        shrd edx,eax,6
        shr eax,8
        loop a3b_main

        xchg edx,eax
        shr eax,8
        stosw
        shr eax,16
        stosb

        popad
        ret




