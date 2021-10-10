; COM Protector v1.0 Unpacker
; Coded by dR.No // Delirium Tremens Group

model tiny
.code
.386

org 100h
Begin:
        mov     dx,offset Msg
        call    write
        mov     si,81h
        lodsb
        cmp     al,0Dh
        jne     FileOk
        mov     dx,offset Usage
        jmp     short write
FileOk:

        mov     cx,si
        mov     di,cx

@Str:
        mov     al,[di]
        cmp     al,0Dh
        je      _EndStr
        inc     di
        loop    @Str
_EndStr:
        mov     word ptr [di],2400h
        mov     dx,si
        mov     ax,3D02h
        int     21h
        jnc     NoErr
        mov     dx,offset not_found

Write:
        mov     ah,09
        int     21h
        ret
NoErr:
        xchg    bx,ax
        mov     dx,offset Process
        call    write
        mov     dx,si
        int     21h
        xor     cx,cx
        xor     dx,dx
        mov     ax,4200h
        int     21h
        mov     ah,3Fh
        mov     dx,offset Buf
        mov     cx,-1
        int     21h

        cmp     DWord Ptr Buf,5350FA9Ch
        je      CryptOk
        mov     dx,offset NotCrypt
        jmp     short write

CryptOk:
        sub     ax,89
        mov     bp,ax
        xchg    cx,ax
        push    cx
        mov     ah,3Eh
        int     21h

        add     dl,34h
        mov     si,dx
        push    si
        mov     di,si

        pusha
        mov     bx,Word Ptr Buf+0Eh
        mov     dx,bp
        add     dl,18
        mov     si,bx
        mov     cx,dx

@Decode:
        dec     cx
        mov     bx,offset Buf+34
        add     bx,cx
        dec     bx
        xor     [bx],si
        loop    @Decode

        popa

        mov     dx,offset _Out
        mov     ax,3C02h
        xor     cx,cx
        int     21h

        xchg    bx,ax

        pop     dx
        pop     cx
        mov     ah,40h
        int     21h

        mov     ah,3Eh
        int     21h
        mov     dx,offset Oki
        jmp     short write
Msg             db              0dh,0ah,'COM Protector v1.0 Unpacker Coded by dR.No // ViP // DTg ',0dh,0ah,24h
Usage           db              0dh,0ah,'Usage: UNCOMPRT <CRYPTFiLE>',0dh,0ah,24h
Not_found       db              'File not found',0dh,0ah,24h
NotCrypt        db              0dh,0ah,'File is not crypted with COM Protecor v1.0',0dh,0ah,24h
Process         db              'Unpacking the file: $'
Oki             db              '... complete!',0dh,0ah,24h
_Out            db              'UNPACKED.COM',0
Buf:
End Begin