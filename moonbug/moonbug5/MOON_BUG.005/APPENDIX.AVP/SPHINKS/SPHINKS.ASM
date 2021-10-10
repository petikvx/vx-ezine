Model Tiny
.code
.286
org 100h
ALL_SIZE equ 666
START:
      pusha
      mov es,word ptr ds:[2ch]
      xchg cx,di
      xchg bx,di
      inc al
      repne scasb
      inc di
      push es
      mov MY_NAME,di
      mov ah,1ah
      mov dx,DTA_OFS+100h
      int 21h
      pop ds
      call MOVE_CX
      mov dx, di
      call FIND_FIRST
      jb ERROR_1
      xor cx,cx
      call SET_ATTR
      xor ax,ax
      call OPEN_FILE
      push cs
      xchg ax,bx
      pop ds
      xor cx,cx
      push cx
      xor dx,dx
      mov al,02
      call MOVE_HAND
      mov LEN1, ax
      xchg ax,dx
      xor ax,ax
      pop cx
      call MOVE_HAND
      mov cx, 20h
      call READ_FROM_FILE
      jc ERROR_1
      cmp ax,0
      jnz ERROR_1
      jmp NEXT
MOVE_CX:
      mov cx,0ffffh
      ret
ERROR_1:
      popa
      push cs
      pop ds
      mov ah,09h
      lea dx, MSG1
      int 21h
      mov al,02h
RETURN:
      mov ah,4ch
      int 21h
CLOSE_FILE:
      mov ah, 3eh
      int 21h
      ret
SET_ATTR:
      mov ax,4301h
      int 21h
      ret
NEXT:
      xor cx,cx
      push cx
      call MOVE_HAND1
N1:
      xor cx,cx
      inc cl
      call READ_FROM_FILE
      cmp ah,al
      jz N2
      pop cx
      inc cx
      cmp cx,0ffffh
      jne N_1
      jmp short ERROR_1
OPEN_FILE:
      mov ah,3dh
      int 21h
      ret
N_1:
      push cx
      jmp short N1
FIND_FIRST:
      mov ah,4eh
      int 21h
      ret
N2:
      pop cx
      mov LEN3,cx
      call MOVE_HAND1
      mov cx, 20h
      call READ_FROM_FILE
      jc ERROR_1
      call CLOSE_FILE
      push es
      mov si, DTA_OFS+100h
      mov dx,di
      pop ds
      push dx
      mov cx,word ptr cs:[si+15h]
      call SET_ATTR
      push cs
      mov ax, word ptr cs:[si+1ah]
      pop ds
      mov LEN2,ax
      push es
      call MOVE_CX
      pop ds
      pop dx
      call FIND_FIRST
      push cs
      pop ds
      jnb L1
      jmp ERROR_1
L1:
      mov ax,LEN1
      mov bx,LEN2
      cmp ax,bx
      jz CMP_NEXT
      jmp ERROR_1
CMP_NEXT:
      mov ax, word ptr cs:[si+1ah]
      cmp ax,bx
      jz CMP_NEXT1
      jmp ERROR_1
CMP_NEXT1:
      mov ax,LEN3
      cmp ax,bx
      jz CMP_NEXT2
      jmp ERROR_1
CMP_NEXT2:
      mov ax,LEN0
      cmp ax,bx
      jz CMP_MY_BEG
      jmp ERROR_1
READ_FROM_FILE:
      mov ah, 3fh
      mov dx, offset BUF_READ
      int 21h
      ret
CMP_MY_BEG:
      push es
      push cs
      mov si,100h
      mov di,offset BUF_READ
      mov cx,20h
      pop es
      repe cmpsb
      pop es
      je TESTED_OK
      jmp ERROR_1
MOVE_HAND:
      mov ah,42h
      int 21h
      ret
MOVE_HAND1:
      xor ax,ax
      xor cx,cx
      xor dx,dx
      jmp short MOVE_HAND
TESTED_OK:
      mov dx,MY_NAME
      push es
      pop ds
      mov al,02
      call OPEN_FILE
      xchg ax,bx
      push cs
      pop ds
      mov ax,LEN0
      sub ax,MY_LEN
      push ax
      xchg ax,dx
      xor ax,ax
      call MOVE_HAND
      mov cx,MY_LEN
      call READ_FROM_FILE
      call MOVE_HAND1
      mov dx,offset BUF_READ
      mov cx,MY_LEN
      call WRITE_FILE
      pop dx
      xor cx,cx
      xor ax,ax
      call MOVE_HAND
      xor cx,cx
      xor dx,dx
      call WRITE_FILE
      call CLOSE_FILE
      push es
      push cs
      mov bx, (3 * ALL_SIZE + 100h)/16
      pop es
      mov ah,4ah
      int 21h
      pop es
      mov di,offset BUF_READ
      xor ax,ax
      mov [di], ax
      mov ax, 80h
      mov [di + 2], ax
      mov [di + 4], cs
      mov ax,5ch
      mov [di + 6],ax
      mov [di + 8],cs
      mov ax,6ch
      mov [di + 10],ax
      mov [di + 12],cs
      mov byte ptr [di + 14],0eh
      popa
      mov ax,4b00h
      mov bx,offset BUF_READ
      push cs
      pop ds
      mov dx,MY_NAME
      push es
      mov LEN1,SS
      mov LEN2,SP
      mov LEN3,ES
      pop ds
      push cs
      pop es
      int 21h
      mov ss,word ptr cs:[LEN1]
      mov sp,word ptr cs:[LEN2]
      mov es,word ptr cs:[LEN3]
      push cs
      pop ds
INSTALL_MY:
      mov dx,MY_NAME
      push es
      pop ds
      mov al,02
      call OPEN_FILE
      push cs
      xchg ax,bx
      pop ds
      mov dx,offset BUF_READ
      mov cx,MY_LEN
      push dx
      push cx
      call READ_FROM_FILE
      mov al,2
      xor cx,cx
      xor dx,dx
      call MOVE_HAND
      pop cx
      pop dx
      call WRITE_FILE
      call MOVE_HAND1
      push cs
      mov LEN1,es
      pop es
      mov dx,100h
      mov cx,MY_LEN
      call WRITE_FILE
      call CLOSE_FILE
      xor ax,ax
      jmp RETURN
;-------------------
WRITE_FILE:
      mov ah,40h
      int 21h
      ret
MSG1 db 07,'°',07,'±',07,'²',07,'Û',07,' VACCINE Sphinks2a (c) by RedArc Û²±°',0ah,0dh
     db '      This file is corrupt.      ',0ah,0dh
     db '         Possible virus!         ',0ah,0dh,'$'
LEN0_OFS equ $-START
LEN0 dw 0FFFFh
MY_LEN equ $-START
MY_NAME dw ?
LEN1 dw ?
LEN2 dw ?
LEN3 dw ?
DTA_OFS equ $-START
_DTA db 80h dup (?)
BUF_READ db 20h dup (?)
END START
