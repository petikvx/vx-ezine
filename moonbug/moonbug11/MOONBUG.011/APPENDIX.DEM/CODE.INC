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
           mov ah,09h
           lea dx,[bp+Msg]
           int 21h
           mov ax,4c00h
           int 21h
Msg equ $-EndCode
db 'Hello World!',0ah,0dh,'$'
@@EndCode equ $-EndCode
