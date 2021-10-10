;This program will display the picture file "message.scr"

.model tiny
.radix 16
.code

        org 100
start:

SetScreenMode:
        mov     ax,13
        int     10

OpenFile:
        mov     dx,offset Filename
        mov     ax,3d00
        int     21
        jc      DoneScreen
        xchg    bx,ax

LoadColors:
        mov     dx,offset colors
        mov     cx,300
        mov     ah,3f
        int     21

        push    bx
SetColors:
        mov     dx,offset colors
        xor     bx,bx
        mov     cx,0ff
        mov     ax,1012
        int     10
        pop     bx

LoadPicture:
        mov     dx,0a000
        mov     ds,dx
        xor     dx,dx
        mov     cx,320d*200d
        mov     ah,3f
        int     21


CloseFile:
        mov     ah,3e
        int     21

DoneScreen:
        xor     ax,ax
        int     16
        mov     ax,3
        int     10
        int     20

Filename        db      'message.scr',0
Colors  db      300 dup(?)

end start
