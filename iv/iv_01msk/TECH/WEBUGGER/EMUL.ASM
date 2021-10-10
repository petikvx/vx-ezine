ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³INFECTED MOSCOW ³#1³ JAN'97 ³(C)STEALTH Group MoscoW & Co ³ one@redline.ru~ ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ DrWEB ­  á«ã¦¡¥ ¢¨à¬í©ª¥à®¢                     ³(C)                     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                jumps
                .386p
cseg            segment para use16
                assume  cs:cseg,ds:cseg
                org     100h
start:
                jmp     install

hex_digits      db      '0123456789ABCDEF'

int_AB:
                pushf
                pusha
                push    ds es
                mov     ax,0B800h
                mov     es,ax
                mov     bx,si
                dec     bx
                dec     bx
                ; 174 253 +
                ; 320 325 -
                mov     di,76*2
                mov     cx,4
locloop:
                push    bx
                and     bx,0F000h
                shr     bx,12
                mov     al,cs:[bx][hex_digits]
                stosb
                mov     al,'K'
                stosb
                pop     bx
                shl     bx,4
                loop    locloop


                pop     es ds
                popa
                popf
                push    ax bp   ; +0 - IP, +2 - CS,  +4 flags
                mov     bp,sp   ; +0 - Addr, +2 CS, +4 IP
                mov     ax,[bp][0][4]   ; IP
                mov     [bp][4][4],ax   ; => +4
                mov     ax,es:[bx][3Eh]
                mov     [bp][0][4],ax
                pop     bp ax
                retf
data:
_si             dw      0
filename        db      '\GRAB.DAT',0


install:
                mov     ax,25ABh
                lea     dx,int_AB
                int     21h
                lea     dx,install
                int     27h

cseg            ends
                end  start