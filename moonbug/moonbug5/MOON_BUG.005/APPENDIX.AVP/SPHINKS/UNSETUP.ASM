Model Tiny
.code
org 100h
start:
     mov al,byte ptr cs:[80h]
     cmp al,0
     jz INFORMATION
     jmp UNINSTALL
INFORMATION:
     lea dx,MSG0
     mov ah,09h
     int 21h
     mov ax,4c00h
     int 21h
MSG0 db 'Usage: unsetup.com filename.com',0ah,0dh,'$'
MSG1 db 'Sphinks not found!',0ah,0dh,'$'
MSG2 db 'Uninstallation is completed!',0ah,0dh,'$'
BIN_NAME db 'sphinks.bin',0h
SF_LEN equ 666
IDENT db 0ah,0dh,'Vaccine Sphinks-2a'
      db 0ah,0dh,'(c) by RedArc // TAVC',0ah,0dh,00h
UNINSTALL:
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
     lea dx,MSG1
     mov ah,09h
     int 21h
     mov ax,4c00h
     int 21h
NEXT:
     mov ax,4202h
     xor cx,cx
     xor dx,dx
     int 21h
     cmp ax,SF_LEN
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
     xchg ax,dx
     sub dx,SF_LEN
     push dx
     mov ax,4200h
     xor cx,cx
     int 21h
     mov ah,3fh
     mov dx,offset NEW_READ
     mov cx,SF_LEN
     int 21h
     mov ax,4200h
     xor cx,cx
     xor dx,dx
     int 21h
     mov ah,40h
     mov cx,SF_LEN
     mov dx,offset NEW_READ
     int 21h
     pop dx
     mov ax,4200h
     xor cx,cx
     int 21h
     mov ah,40h
     xor cx,cx
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
end start
