Model Tiny
.code
org 100h
start:
      mov es,word ptr ds:[2ch]
      xchg cx,di
      xchg bx,di
      inc al
      repne scasb
      inc di
      push es
      mov MY_NAME,di
      pop ds
      mov dx,di
      mov ah,4eh
      push sp
      pop cx
      int 21h
      push cs
      pop ds
      jb ERROR_FIND_FILE
      jmp short @0
ERROR_FIND_FILE:
      lea dx,MSG1
      mov ah,09h
      int 21h
      int 20h
@0:
      mov ax,word ptr ds:[9ah]
      mov L1,ax
      mov ax,3d02h
      mov dx,9eh
      int 21h
      xchg bx,ax
      mov ax,4202h
      cwd
      xor cx,cx
      int 21h
      mov L2,ax
      mov ah,3fh
      mov cx,20h
      lea dx,BUF
      int 21h
      jc ERROR_READ_END
      jmp short @@1
ERROR_READ_END:
      lea dx,MSG2
      mov ah,09h
      int 21h
      int 20h
@@1:
      cmp ax,0
      jnz ERROR_READ_END1
      jmp short @@2
ERROR_READ_END1:
      lea dx,MSG3
      mov ah,09h
      int 21h
      int 20h
@@2:
      mov ax,4200h
      xor cx,cx
      cwd
      int 21h
      mov cx,0ffffh
      mov ah,3fh
      lea dx,BUF
      int 21h
      mov L3,ax
      mov ax,4200h
      xor cx,cx
      cwd
      int 21h
      xor di,di
      xor ax,ax
@1:
      mov cx,1
      lea dx,buf
      mov ah,3fh
      int 21h
      cmp ah,al
      je @2
      inc di
      cmp di,0fffeh
      je ERROR_INC
      jmp short @1
ERROR_INC:
      lea dx,MSG4
      mov ah,09h
      int 21h
      int 20h
@2:
      mov L4,di
      xor cx,cx
      mov ax,4200h
      cwd
      int 21h
      mov ah,3fh
      mov cx,MyLength
      lea dx,BUF
      int 21h
      mov ax,word ptr ds:[BUF]
      cmp ax,word ptr ds:[100h]
      jne ERROR_Word
      jmp short @@3
ERROR_Word:
      lea dx,MSG5
      mov ah,09h
      int 21h
      int 20h
@@3:
      xor cx,cx
      mov ax,4200h
      cwd
      int 21h
      mov ah,40h
      lea dx,BUF
      mov cx,MyLength
      int 21h
      mov ah,3fh
      mov cx,20h
      lea dx,BUF
      int 21h
      jc ERROR_READ_END2
      jmp short @@4
ERROR_READ_END2:
      lea dx,MSG6
      mov ah,09h
      int 21h
      int 20h
@@4:
      cmp ax,0
      jnz ERROR_READ_END3
      jmp short @@5
ERROR_READ_END3:
      lea dx,MSG7
      mov ah,09h
      int 21h
      int 20h
@@5:
      mov ax,MyLength
      mov cx,L1
      cmp ax,cx
      jne ERROR_LENGTH
      mov cx,L2
      cmp ax,cx
      jne ERROR_LENGTH
      mov cx,L3
      cmp ax,cx
      jne ERROR_LENGTH
      mov cx,L4
      cmp ax,cx
      jne ERROR_LENGTH
      mov ah,09h
      lea dx,Ok
      int 21h
      int 20h
ERROR_LENGTH:
      mov ah,09h
      lea dx,MSG8
      int 21h
      int 20h
;---
MSG1 db 'Не могу найти собственный файл!',0ah,0dh,'$'
MSG2 db 'Ошибка при чтении за концом файла!',0ah,0dh,'$'
MSG3 db 'Успешное чтение за концом файла!',0ah,0dh,'$'
MSG4 db 'Ошибка при чтении файла побайтно!',0ah,0dh,'$'
MSG5 db 'Байты в памяти не совпадают с байтами на диске!',0ah,0dh,'$'
MSG6 db 'Ошибка чтения после записи!',0ah,0dh,'$'
MSG7 db 'Успешное чтение за концом файла после записи!',0ah,0dh,'$'
MSG8 db 'Длина файла не совпадает с фактической длиной!',0ah,0dh,'$'
Ok   db 'Ok',0ah,0dh,'$'
Ident db '1999 (c) by RedArc'
;---
MyLength equ $-start
MY_NAME dw ?
L1      dw ? ;FindFirst
L2      dw ? ;Move Handle to End
L3      dw ? ;Read Voll File
L4      dw ? ;Read per 1 byte
BUF label byte
end start
