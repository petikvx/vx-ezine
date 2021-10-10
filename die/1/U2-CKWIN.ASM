        .386p
        .Radix 16
        .model  tiny
        .code
        org     100h

start:
        mov     ah,9h
        mov     dx,offset Intro
        int     21h             ;Show Intro Text!

        mov     ax,150Ch
        xor     bx,bx
        int     2Fh             ;Get MSCDEX Version!
        cmp     bx,25Fh         ;It is only set to this in Windozy!
                                ;Currently anyway! :)
        jne     WeareDos        ;It's not this, we're in DOS

        mov     ah,9h
        mov     dx,offset win
        int     21h
        jmp     quit

WeareDos:
        mov     ah,9h
        mov     dx,offset dos
        int     21h
quit:
        int     20h

Intro   db      'Rat Heart''s CheckWin',0Dh,0Ah
        db      '~~~~~~~~~~~~~~~~~~~~',0Dh,0Ah
        db      ' Are we in Windozy or DOS?',0Dh,0Ah,0Dh,0Ah,'$'
win     db      'We''re in Windozy!$'
dos     db      'We''re in DOS!$'

        end     start
