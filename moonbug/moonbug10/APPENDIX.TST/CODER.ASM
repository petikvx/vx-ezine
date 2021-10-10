;Кодировщик файла TST20.COM
;(C) 1999 bY B!Z0n //[BzZ].

model tiny
                org  100h

.code
.startup

crstart         equ     263h

                lea     dx,file
                mov     ax,3d02h
                int     21h                     ;открываем файл на чтение\запись
                jc      exit
                xchg    bx,ax

                mov     cx,-1
                mov     ah,3fh
                int     21h                     ;читаем его целиком в память
                push    ax dx                   ;AX=длина файла

                lea     si, file
                add     si, crstart
                mov     di, si
                mov     cx, ax
                sub     cx, crstart
                shr     cx, 1
                or      cx, 1
                in      ax, 40h
                xchg    dx, ax
crypt:
                lodsw
                xor     ax, dx
                stosw
                loop    crypt

                xor     dx, dx
                mov     ax,4200h
                int     21h                     ;указатель на начало файла

                pop     dx cx
                mov     ah,40h

                int     21h                     ;пишем закодированный участок
                mov     ah,3eh
                int     21h                     ;закрываем файл
exit:           mov     ax,4c00h                ;выход
                int     21h

file            db      'tst20.com',0           ;имя файла

                end
