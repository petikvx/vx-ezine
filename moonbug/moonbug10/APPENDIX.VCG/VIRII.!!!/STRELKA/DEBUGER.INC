;Исключительно для отладки
_Manager:
       push ds
       mov ds,ax
       mov es,ax
       push di
       mov cx,di
       mov di,0
       cld
_M@1:
       stosb
       loop _M@1
       push cs
       pop ds
       mov si,100h
       pop di
       push di
       mov cx,MyLength
_M@2:
      lodsb
      stosb
      loop _M@2
;Возвращаем длину полученного мутанта
       pop cx
       sub di,cx
       xchg di,cx
;Выход из подпрограммы
       pop ds
       pop ax
       push es
       push ax
       push cs
       pop es
       mov bp,cx
       ret
