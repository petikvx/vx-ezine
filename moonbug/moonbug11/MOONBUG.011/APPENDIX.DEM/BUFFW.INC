WriteBuff:
       push cx
       mov ah,3ch
       lea dx,FileName
       xor cx,cx
       int 21h
       jc Error
       xchg bx,ax
       lea dx,Buff
       pop cx
       mov ah,40h
       int 21h
       mov ah,3eh
       int 21h
Error:
       ret
