;This file will encode the message from message.dat into the picture file
;called message.scr.

;Note: Message.dat MUST be < 8000 bytes for the entire message to be 
;preserved.

.model tiny
.radix 16
.code
        org 100
start:
      
LoadMessage:
        mov     ax,3d00
        mov     dx,offset DataFile
        int     21
        jc      Error
        xchg    bx,ax
        mov     dx,offset MessageData
        mov     cx,8000d
        mov     ah,3f
        int     21
        mov     MessageSize,ax
        mov     ah,3e
        int     21


AddEOF:
        mov     bx,Messagesize
        mov     [MessageData+bx],1a

        jmp     EncodeMessage

Error:
        mov     dx,offset Error1
        mov     ah,09
        int     21
        mov     ax,4c01
        int     21

EncodeMessage:
        mov     si,offset MessageData
        mov     bp,si
        add     bp,messagesize

   OpenPict:
        mov     ax,3d02
        mov     dx,offset PictFile
        int     21
        jc      Error
        xchg    bx,ax
        
SkipColorMap:
        mov     ax,4200
        mov     dx,300
        mov     cx,0
        int     21
        

ReadPict:
        mov     ax,4201
        xor     cx,cx
        xor     dx,dx
        int     21
        push    ax dx

        mov     ah,3f
        mov     cx,200
        mov     dx,offset PictBuffer
        int     21

JumpBackToRead:        
        pop     cx dx
        push    ax
        mov     ax,4200
        int     21

        call    convertdata

        pop     cx
        mov     ah,40
        mov     dx,offset PictBuffer
        int     21

        cmp     si,bp
        jae     DoneEncode
        cmp     ax,200
        jb      DoneEncode

        jmp     ReadPict

DoneEncode:


ClosePict:        
        mov     ah,3e
        int     21

Done:
        mov     ax,4c00
        int     21


ConvertData:
        mov     di,offset PictBuffer
        mov     cx,40

ConvertByte:
        push    cx
        
        lodsb
        mov     cx,8
ConvertBit:        
        xor     ah,ah
        shr     al,1
        rcl     ah,1

        and     byte ptr es:[di],0fe
        or      byte ptr es:[di],ah
        inc     di
        loop    ConvertBit

        pop     cx
        loop    Convertbyte
        ret





Error1  db      'Error opening Message files!$'
DataFile        db      'message.dat',0
PictFile        db      'message.scr',0

MessageSize     dw      ?
MessageData     db      8000d   dup(?)
PictBuffer      db      200 dup(?)

end start

