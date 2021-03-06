;Codegenerator (c) 1999 by RedArc

BuffBegin   equ 300h
BlockOffset equ 460 ;153*3+1
CouAllBlock equ 123

;--- ������ ���室�-�����誨.
Jump:
    push ax bx
    call _Calc_Rnd16
    mov al,0e9h
    stosb
    xchg bx,ax
    stosw
    pop bx ax
    ret

;--- ����祭�� ���ﭨ� 䫠�� ��� �����
;Input:  al - block
;Output: al - range
Get_Flag:
    push si cx bx dx
    mov bx,ax
    mov ah,0
    mov cl,3
    mul cl
    xchg si,ax
    mov al,byte ptr ds:[si]
    mov bl,al
    xchg bx,ax
    pop dx bx cx si
    ret

;--- ���⠢����� 䫠�� ��� �����
;Input:  al - block
;Output: none
Put_Flag:
    push ax cx si dx
    mov ah,0
    mov cl,3
    mul cl
    xchg si,ax
    mov byte ptr ds:[si],1
    pop dx si cx ax
    ret

;--- ����祭�� ���� ���室�
;Input:  al - block
;Output: di - addr
Get_Jump:
    push ax si cx
    mov ah,0
    mov cl,3
    mul cl
    xchg si,ax
    mov di,word ptr ds:[si+1]
    pop cx si ax
    ret

;--- ���࠭���� ���� ���室�
;Input:  al - block
;        di - addr
;Output: none
Put_Jump:
    push ax cx si
    mov ah,0
    mov cl,3
    mul cl
    xchg si,ax
    mov word ptr ds:[si+1],di
    pop si cx ax
    ret

;--- ����祭�� ���� �����
;Input:  al - block
;Output: si - addr
Get_Block:
    push di ax
    mov ah,0
    shl ax,1
    xchg di,ax
    add di,BlockOffset
    mov si,word ptr ds:[di]
    pop ax di
    ret

;--- ���࠭���� ���� �����
;Input:  al - block
;        di - addr
;Output: none
Put_Block:
    push ax si
    mov ah,0
    shl ax,1
    xchg si,ax
    add si,BlockOffset
    mov word ptr ds:[si],di
    pop si ax
    ret

;--- ����饭�� 1
Cutter1:
    call Put_Block
    call Put_Flag
    ret

;--- ����饭�� 2
Cutter2:
    call Put_Jump
    call Jump
    pop cx
    inc cx
    jmp _M@Start

;--- �������� ���室�
;Input:  si - ���� ��⪨ ��� ���室�
;        di - ���� ������� ���室�
;        bx - ���� ��砫� ����
;Output: none
CalcJump:
         push ax cx dx
         mov ax,di
         mov dx,si
         sub ax,bx
         sub dx,bx
         cmp ax,dx
         jl JumpDown
JumpUp:
         mov cx,0ffffh
         sub ax,dx
         sub cx,ax
         sub cx,2
         xchg dx,cx
         jmp FormJump
JumpDown:
         add ax,3
         sub dx,ax
FormJump:
         mov word ptr ds:[di+1],dx
         pop dx cx ax
         ret
