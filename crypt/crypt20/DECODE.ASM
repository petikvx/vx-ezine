.model tiny
.radix 16
.code
        org 100
start:
OpenPicture:        
        mov     ah,3c
        xor     cx,cx
        mov     dx,offset Destfile
        int     21
        jc      erroropen
        mov     Destination,ax
        
        mov     ax,3d00
        mov     dx,offset filename
        int     21
        jc      erroropen
        xchg    bx,ax

GoToPictureData:        
        mov     ax,4200
        mov     dx,300
        xor     cx,cx
        int     21

NotherLoop:        
        mov     dx,offset ReadBuf
        mov     cx,200
        mov     ah,3f
        int     21
        push    bx ax
        call    Decoder
        pop     ax bx
        cmp     ax,200
        je      NotherLoop

CloseFile:
        mov     ah,3e
        int     21
        mov     ah,3e
        mov     bx,destination
        int     21

Terminate:
        mov     ax,4c00
        int     21

ErrorOpen:
        mov     ah,09
        mov     dx,offset error
        int     21
        mov     ax,4c01
        int     21

Decoder:
        mov     si,offset ReadBuf
        mov     di,offset WriteBuf
        mov     cx,40
DecodeIt:        
        push    cx
        call    GetByte
        pop     cx
        mov     al,workbyte
        stosb
        loop    DecodeIt

        mov     dx,offset WriteBuf
        mov     bx,Destination
        mov     cx,40
        mov     ah,40
        int     21
        ret

GetByte:
        mov     workbyte,0
        mov     cx,8        
GetBits:        
        lodsb
        shr     al,1
        rcr     workbyte,1
        loop    GetBits
        ret

workbyte  db    0
error     db      'Error opening files.$'
filename  db      'message.scr',0
destfile  db      'newmess.dat',0

destination     dw      ?

ReadBuf  db      200 dup(?)
WriteBuf db      40 dup(?)

end start
