;Процедуры для работы с файлами
;(c) RedArc

;GotoStart - смещение в файле от начала
;GotoEnd   - смещение в файле от конца
;ReadFromFile - чтение из файла

;────────────────────────────────────────────────────────────────────────────
GotoStart proc near
       mov ax,4200h
       int 21h
       ret
GotoStart endp

;────────────────────────────────────────────────────────────────────────────
GotoEnd proc near
       mov ax,4202h
       int 21h
       ret
GotoEnd endp

;────────────────────────────────────────────────────────────────────────────
ReadFromFile proc near
       mov ah,3fh
       int 21h
       ret
ReadFromFile endp
