Model Tiny
.code
org 100h
START:
     mov al,byte ptr cs:[80h]
     cmp al,0
     jz INFORMATION
     jmp INSTALL
INFORMATION:
     lea dx,MSG0
     mov ah,09h
     int 21h
     mov ax,4c00h
     int 21h
MSG0 db 'Usage: setup.com filename.com',0ah,0dh,'$'
MSG1 db 'File too big!',0ah,0dh,'$'
MSG2 db 'Installation is completed!',0ah,0dh,'$'
MSG3 db 'Sphinks is already install!',0ah,0dh,'$'
BIN_NAME db 'sphinks.bin',0h
SF_LEN equ 666
IDENT db 0ah,0dh,'Vaccine Sphinks-2a'
      db 0ah,0dh,'(c) by RedArc // TAVC',0ah,0dh,00h
INSTALL:
     mov dx,offset BIN_NAME
     mov ax,3d00h
     int 21h
     xchg ax,bx
     mov ah,3fh
     mov dx,offset BUF_READ
     mov cx,SF_LEN
     int 21h
     mov ah,3eh
     int 21h
     mov dx,82h
     xor ax,ax
     mov si,dx
     dec si
     mov al,byte ptr cs:[80h]
     add si,ax
     mov byte ptr cs:[si],00h
     mov ax,3d02h
     int 21h
     xchg ax,bx
     mov ah,3fh
     mov dx,offset NEW_READ
     mov cx,SF_LEN
     int 21h
     mov si,offset NEW_READ
     mov di,offset BUF_READ
     mov cx,SF_LEN
     repe cmpsb
     jne NEXT
     mov ah,3eh
     int 21h
     lea dx,MSG3
     mov ah,09h
     int 21h
     mov ax,4c03h
     int 21h
NEXT:
     mov ax,4202h
     xor cx,cx
     xor dx,dx
     int 21h
     push ax
     and ax,0f000h
     cmp ax,0f000h
     jnz Len_Tested
     pop ax
     mov ah,3eh
     int 21h
     lea dx,MSG1
     mov ah,09h
     int 21h
     mov ax,4c01h
     int 21h
Len_Tested:
     mov ah,40h
     mov cx,SF_LEN
     mov dx,offset NEW_READ
     int 21h
     mov ax,4200h
     xor cx,cx
     xor dx,dx
     int 21h
     mov di, offset BUF_READ
     pop ax
     add ax,SF_LEN
     mov word ptr cs:[di + SF_LEN - 2],ax
     mov ah,40h
     mov cx,SF_LEN
     xchg dx, di
     int 21h
     mov ah,3eh
     int 21h
     lea dx,MSG2
     mov ah,09h
     int 21h
     mov ax,4c02h
     int 21h
BUF_READ db SF_LEN dup (?)
NEW_READ db SF_LEN dup (?)
END START
