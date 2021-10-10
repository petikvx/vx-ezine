;Codegenerator (c) 1999 by RedArc

;Отладка
;Debug equ 4

;---
;Обмен значениями между двумя 16 битовыми регистрами
;Input:  bl - numreg1
;        bh - numreg2
_2_XCHG16:
    push bp
    call _2_XCHG16_
_2_XCHG16_R1 db ?
_2_XCHG16_R2 db ?
_2_XCHG16_:
    pop bp
    mov byte ptr ds:[bp],bl
    mov byte ptr ds:[bp+1],bh
    mov ah,6
    call RND_Tabelle
;    mov ah,Debug
_2_XCHG16_0:
    cmp ah,0
    jne _2_XCHG16_1
    call Xchg_Reg1_Reg_2_16_Tabelle
    call _bx
    pop bp
    ret
_2_XCHG16_1:
    cmp ah,1
    jne _2_XCHG16_2
    xchg bh,bl
    call Xchg_Reg1_Reg_2_16_Tabelle
    call _bx
    pop bp
    ret
_2_XCHG16_2:
    cmp ah,2
    jne _2_XCHG16_3
    call Push_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
    call Mov_Reg1_Reg_2_16_Tabelle
    call _bx
    mov bl,byte ptr ds:[bp+1]
    call Pop_Reg16_Tabelle
    call _bl
    pop bp
    ret
_2_XCHG16_3:
    cmp ah,3
    jne _2_XCHG16_4
    xchg bl,bh
    call Push_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp+1]
    mov bh,byte ptr ds:[bp]
    call Mov_Reg1_Reg_2_16_Tabelle
    call _bx
    mov bl,byte ptr ds:[bp]
    call Pop_Reg16_Tabelle
    call _bl
    pop bp
    ret
_2_XCHG16_4:
    cmp ah,4
    jne _2_XCHG16_5
    call Push_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp]
    mov bh,bl
    call Xor_Reg1_Reg_2_16_Tabelle
    call _bx
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
    call Add_Reg1_Reg_2_16_Tabelle
    call _bx
    mov bl,byte ptr ds:[bp+1]
    call Pop_Reg16_Tabelle
    call _bl
    pop bp
    ret
_2_XCHG16_5:
    xchg bh,bl
    call Push_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp+1]
    mov bh,bl
    call Sub_Reg1_Reg_2_16_Tabelle
    call _bx
    mov bl,byte ptr ds:[bp+1]
    mov bh,byte ptr ds:[bp]
    call Add_Reg1_Reg_2_16_Tabelle
    call _bx
    mov bl,byte ptr ds:[bp]
    call Pop_Reg16_Tabelle
    call _bl
    pop bp
    ret
;---
;Присвоение регистру R1 значения регистра R2
;Input:  bl - numreg1
;        bh - numreg2
_2_MOV16:
    push bp
    call _2_MOV16_
_2_MOV16_R1 db ?
_2_MOV16_R2 db ?
_2_MOV16_:
    pop bp
    mov byte ptr ds:[bp],bl
    mov byte ptr ds:[bp+1],bh
    push bx
    mov ah,6
    call RND_Tabelle
    pop bx
;    mov ah,Debug
_2_MOV16_0:
    cmp ah,0
    jne _2_MOV16_1
    call Mov_Reg1_Reg_2_16_Tabelle
    call _bx
    pop bp
    ret
_2_MOV16_1:
    cmp ah,1
    jne _2_MOV16_2
    xchg bh,bl
    call Push_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
    push bp
    call _2_XCHG16
    pop bp
    mov bl,byte ptr ds:[bp+1]
    call Pop_Reg16_Tabelle
    call _bl
    pop bp
    ret
_2_MOV16_2:
    cmp ah,2
    jne _2_MOV16_3
;    mov bh,bl
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp]
    call Sub_Reg1_Reg_2_16_Tabelle
    call _bx
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
    call Add_Reg1_Reg_2_16_Tabelle
    call _bx
    pop bp
    ret
_2_MOV16_3:
    cmp ah,3
    jne _2_MOV16_4
    mov bh,bl
    call Xor_Reg1_Reg_2_16_Tabelle
    call _bx
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
    call Add_Reg1_Reg_2_16_Tabelle
    call _bx
    pop bp
    ret
_2_MOV16_4:
    cmp ah,4
    jne _2_MOV16_5
    xchg bh,bl
    call Push_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp]
    call Pop_Reg16_Tabelle
    call _bl
    pop bp
    ret
_2_MOV16_5:
    xor ax,ax
    call Mov_Reg16_Value16_Tabelle
    call _al_bx
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
    call Add_Reg1_Reg_2_16_Tabelle
    call _bx
    pop bp
    ret
;---
;Прибавление к значению регистра R1 значения регистра R2
;Input:  bl - numreg1
;        bh - numreg2
_2_ADD16:
    push bp
    call _2_ADD16_
_2_ADD16_R1  db ?
_2_ADD16_R2  db ?
_2_ADD16_RND db ?
_2_ADD16_:
    pop bp
    mov byte ptr ds:[bp],bl
    mov byte ptr ds:[bp+1],bh
_2_ADD16_RND_:
    call _Case_Rnd16
    mov al,byte ptr ds:[bp+1]
    cmp al,bh
    je _2_ADD16_RND_
    mov byte ptr ds:[bp+2],bh
    mov ah,6
    call RND_Tabelle
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
;    mov ah,Debug
_2_ADD16_0:
    cmp ah,0
    jne _2_ADD16_1
    call Add_Reg1_Reg_2_16_Tabelle
    call _bx
    pop bp
    ret
_2_ADD16_1:
    cmp ah,1
    jne _2_ADD16_2
    push bp
    call _2_XCHG16
    pop bp
    mov bl,byte ptr ds:[bp+1]
    mov bh,byte ptr ds:[bp]
    push bx
    call Add_Reg1_Reg_2_16_Tabelle
    call _bx
    pop bx
    call _2_XCHG16
    pop bp
    ret
_2_ADD16_2:
    cmp ah,2
    jne _2_ADD16_3
    xchg bh,bl
    call Push_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp+1]
    mov bh,byte ptr ds:[bp]
    call Add_Reg1_Reg_2_16_Tabelle
    call _bx
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
    push bp
    call _2_MOV16
    pop bp
    mov bl,byte ptr ds:[bp+1]
    call Pop_Reg16_Tabelle
    call _bl
    pop bp
    ret
_2_ADD16_3:
    cmp ah,3
    jne _2_ADD16_4
    push bx
    push bp
    call _2_XCHG16
    pop bp
    mov bl,byte ptr ds:[bp]
    call Push_Reg16_Tabelle
    call _bl
    pop bx
    call Add_Reg1_Reg_2_16_Tabelle
    call _bx
    mov bl,byte ptr ds:[bp+1]
    mov bh,byte ptr ds:[bp]
    push bx
    push bp
    call _2_MOV16
    pop bp
    mov bl,byte ptr ds:[bp]
    call Pop_Reg16_Tabelle
    call _bl
    pop bx
    call _2_XCHG16
    pop bp
    ret
_2_ADD16_4:
    cmp ah,4
    jne _2_ADD16_5
    mov bl,byte ptr ds:[bp+2]
    call Push_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp+2]
    mov bh,byte ptr ds:[bp]
    push bx
    push bp
    call _2_MOV16
    pop bp
    mov bl,byte ptr ds:[bp+2]
    mov bh,byte ptr ds:[bp+1]
    call Add_Reg1_Reg_2_16_Tabelle
    call _bx
    pop bx
    push bp
    call _2_XCHG16
    pop bp
    mov bl,byte ptr ds:[bp+2]
    call Pop_Reg16_Tabelle
    call _bl
    pop bp
    ret
_2_ADD16_5:
    mov bl,byte ptr ds:[bp+2]
    call Push_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp+1]
    call Push_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp+2]
    call Pop_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp+2]
    mov bh,byte ptr ds:[bp]
    push bx
    call Add_Reg1_Reg_2_16_Tabelle
    call _bx
    pop bx
    push bp
    call _2_XCHG16
    pop bp
    mov bl,byte ptr ds:[bp+2]
    call Pop_Reg16_Tabelle
    call _bl
    pop bp
    ret
;---
;Вычитание из значения регистра R1 значения регистра R2
;Input:  bl - numreg1
;        bh - numreg2
_2_SUB16:
    push bp
    call _2_SUB16_
_2_SUB16_R1  db ?
_2_SUB16_R2  db ?
_2_SUB16_RND db ?
_2_SUB16_:
    pop bp
    mov byte ptr ds:[bp],bl
    mov byte ptr ds:[bp+1],bh
_2_SUB16_RND_:
    call _Case_Rnd16
    mov al,byte ptr ds:[bp+1]
    cmp al,bh
    je _2_SUB16_RND_
    mov byte ptr ds:[bp+2],bh
    mov ah,6
    call RND_Tabelle
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
;    mov ah,Debug
_2_SUB16_0:
    cmp ah,0
    jne _2_SUB16_1
    call Sub_Reg1_Reg_2_16_Tabelle
    call _bx
    pop bp
    ret
_2_SUB16_1:
    cmp ah,1
    jne _2_SUB16_2
    push bp
    call _2_XCHG16
    pop bp
    mov bl,byte ptr ds:[bp+1]
    mov bh,byte ptr ds:[bp]
    push bx
    call Sub_Reg1_Reg_2_16_Tabelle
    call _bx
    pop bx
    call _2_XCHG16
    pop bp
    ret
_2_SUB16_2:
    cmp ah,2
    jne _2_SUB16_3
    call Inc_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
    push bx
    call Sub_Reg1_Reg_2_16_Tabelle
    call _bx
    pop bx
    call Dec_Reg16_Tabelle
    call _bl
    pop bp
    ret
_2_SUB16_3:
    cmp ah,3
    jne _2_SUB16_4
    call Dec_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
    push bx
    call Sub_Reg1_Reg_2_16_Tabelle
    call _bx
    pop bx
    call Inc_Reg16_Tabelle
    call _bl
    pop bp
    ret
_2_SUB16_4:
    cmp ah,4
    jne _2_SUB16_5
    mov bl,byte ptr ds:[bp+2]
    call Push_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp+2]
    mov bh,byte ptr ds:[bp]
    push bx
    push bp
    call _2_XCHG16
    pop bp
    mov bl,byte ptr ds:[bp+2]
    mov bh,byte ptr ds:[bp+1]
    call Sub_Reg1_Reg_2_16_Tabelle
    call _bx
    pop bx
    push bp
    call _2_XCHG16
    pop bp
    mov bl,byte ptr ds:[bp+2]
    call Pop_Reg16_Tabelle
    call _bl
    pop bp
    ret
_2_SUB16_5:
    mov bl,byte ptr ds:[bp+2]
    call Push_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp+2]
    mov bh,byte ptr ds:[bp]
    push bx
    push bp
    call _2_MOV16
    pop bp
    mov bl,byte ptr ds:[bp+2]
    mov bh,byte ptr ds:[bp+1]
    call Sub_Reg1_Reg_2_16_Tabelle
    call _bx
    pop bx
    xchg bh,bl
    push bp
    call _2_MOV16
    pop bp
    mov bl,byte ptr ds:[bp+2]
    call Pop_Reg16_Tabelle
    call _bl
    pop bp
    ret
;---
;Исключающее ИЛИ значения регистра R1 со значением регистра R2
;Input:  bl - numreg1
;        bh - numreg2
_2_XOR16:
    push bp
    call _2_XOR16_
_2_XOR16_R1  db ?
_2_XOR16_R2  db ?
_2_XOR16_:
    pop bp
    mov byte ptr ds:[bp],bl
    mov byte ptr ds:[bp+1],bh
    mov ah,4
    call RND_Tabelle
;    mov ah,Debug
_2_XOR16_0:
    cmp ah,0
    jne _2_XOR16_1
    call Xor_Reg1_Reg_2_16_Tabelle
    call _bx
    pop bp
    ret
_2_XOR16_1:
    cmp ah,2
    jne _2_XOR16_3
    push bx
    xchg bh,bl
    call Push_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp+1]
    mov bh,byte ptr ds:[bp]
    call Xor_Reg1_Reg_2_16_Tabelle
    call _bx
    pop bx
    push bp
    call _2_MOV16
    pop bp
    mov bl,byte ptr ds:[bp+1]
    call Pop_Reg16_Tabelle
    call _bl
    pop bp
    ret
_2_XOR16_3:
    push bx
    push bp
    call _2_XCHG16
    pop bp
    mov bl,byte ptr ds:[bp+1]
    mov bh,byte ptr ds:[bp]
    call Xor_Reg1_Reg_2_16_Tabelle
    call _bx
    pop bx
    call _2_XCHG16
    pop bp
    ret
;---
;Присвоение регистру R значения Value16
;Input:  bl - numreg
;        ax - Value16
_2_MOV16V16:
    push bp
    call _2_MOV16V16_
_2_MOV16V16_R    db ?
_2_MOV16V16_RND  db ?
_2_MOV16V16_V    dw ?
_2_MOV16V16_VRND dw ?
_2_MOV16V16_:
    pop bp
    mov byte ptr ds:[bp],bl
    mov word ptr ds:[bp+2],ax
_2_MOV16V16_RND_:
    call _Case_Rnd16
    mov byte ptr ds:[bp+1],bh
_2_MOV16V16_RND_1:
    call _Calc_Rnd16
    cmp bx,0
    je _2_MOV16V16_RND_1
    mov word ptr ds:[bp+4],bx
    mov ah,10
    call RND_Tabelle
    mov bl,byte ptr ds:[bp]
;    mov ah,Debug
_2_MOV16V16_0:
    cmp ah,1
    jne _2_MOV16V16_1
    mov ax,word ptr ds:[bp+2]
    call Mov_Reg16_Value16_Tabelle
    call _al_bx
    pop bp
    ret
_2_MOV16V16_1:
    cmp ah,2
    jne _2_MOV16V16_2
    mov ax,word ptr ds:[bp+4]
    push ax
    call Mov_Reg16_Value16_Tabelle
    call _al_bx
    mov bl,byte ptr ds:[bp]
    mov ax,word ptr ds:[bp+2]
    call Add_Reg16_Value16_Tabelle
    call _ax_bx
    mov bl,byte ptr ds:[bp]
    pop ax
    call Sub_Reg16_Value16_Tabelle
    call _ax_bx
    pop bp
    ret
_2_MOV16V16_2:
    cmp ah,3
    jne _2_MOV16V16_3
    mov bl,byte ptr ds:[bp+1]
    call Push_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
    push bx
    push bp
    call _2_XCHG16
    pop bp
    mov bl,byte ptr ds:[bp+1]
    mov ax,word ptr ds:[bp+2]
    call Mov_Reg16_Value16_Tabelle
    call _al_bx
    pop bx
    push bp
    call _2_XCHG16
    pop bp
    mov bl,byte ptr ds:[bp+1]
    call Pop_Reg16_Tabelle
    call _bl
    pop bp
    ret
_2_MOV16V16_3:
    cmp ah,4
    jne _2_MOV16V16_4
    mov bh,byte ptr ds:[bp+1]
    push bp
    call _2_MOV16
    pop bp
    mov bl,byte ptr ds:[bp]
    mov ax,word ptr ds:[bp+2]
    call Add_Reg16_Value16_Tabelle
    call _ax_bx
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
    call _2_SUB16
    pop bp
    ret
_2_MOV16V16_4:
    cmp ah,5
    jne _2_MOV16V16_5
    mov bh,byte ptr ds:[bp+1]
    push bx
    push bp
    call _2_XCHG16
    pop bp
    mov bl,byte ptr ds:[bp+1]
    mov ax,word ptr ds:[bp+2]
    call Mov_Reg16_Value16_Tabelle
    call _al_bx
    pop bx
    call _2_XCHG16
    pop bp
    ret
_2_MOV16V16_5:
    cmp ah,6
    jne _2_MOV16V16_6
    mov bl,byte ptr ds:[bp+1]
    call Push_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp+1]
    mov ax,word ptr ds:[bp+2]
    call Mov_Reg16_Value16_Tabelle
    call _al_bx
    mov bl,byte ptr ds:[bp+1]
    mov ax,word ptr ds:[bp+4]
    call Sub_Reg16_Value16_Tabelle
    call _ax_bx
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
    push bp
    call _2_XCHG16
    pop bp
    mov bl,byte ptr ds:[bp]
    mov ax,word ptr ds:[bp+4]
    call Add_Reg16_Value16_Tabelle
    call _ax_bx
    mov bl,byte ptr ds:[bp+1]
    call Pop_Reg16_Tabelle
    call _bl
    pop bp
    ret
_2_MOV16V16_6:
    cmp ah,7
    jne _2_MOV16V16_7
    mov ax,word ptr ds:[bp+2]
    mov bx,word ptr ds:[bp+4]
    push bx
    add ax,bx
    mov bl,byte ptr ds:[bp]
    call Mov_Reg16_Value16_Tabelle
    call _al_bx
    pop ax
    mov bl,byte ptr ds:[bp]
    call Sub_Reg16_Value16_Tabelle
    call _ax_bx
    pop bp
    ret
_2_MOV16V16_7:
    cmp ah,8
    jne _2_MOV16V16_8
    mov ax,word ptr ds:[bp+2]
    mov bx,word ptr ds:[bp+4]
    push bx
    sub ax,bx
    mov bl,byte ptr ds:[bp]
    call Mov_Reg16_Value16_Tabelle
    call _al_bx
    pop ax
    mov bl,byte ptr ds:[bp]
    call Add_Reg16_Value16_Tabelle
    call _ax_bx
    pop bp
    ret
_2_MOV16V16_8:
    mov ax,word ptr ds:[bp+2]
    mov bx,word ptr ds:[bp+4]
    push bx
    xor ax,bx
    mov bl,byte ptr ds:[bp]
    call Mov_Reg16_Value16_Tabelle
    call _al_bx
    pop ax
    mov bl,byte ptr ds:[bp]
    call Xor_Reg16_Value16_Tabelle
    call _ax_bx
    pop bp
    ret
;---
;Добавление к значению регистра R значения Value16
;Input:  bl - numreg
;        ax - Value16
_2_ADD16V16:
    push bp
    call _2_ADD16V16_
_2_ADD16V16_R    db ?
_2_ADD16V16_RND  db ?
_2_ADD16V16_V    dw ?
_2_ADD16V16_VRND dw ?
_2_ADD16V16_:
    pop bp
    mov byte ptr ds:[bp],bl
    mov word ptr ds:[bp+2],ax
_2_ADD16V16_RND_:
    call _Case_Rnd16
    mov byte ptr ds:[bp+1],bh
_2_ADD16V16_RND_1:
    call _Calc_Rnd16
    cmp bx,0
    je _2_ADD16V16_RND_1
    mov word ptr ds:[bp+4],bx
    mov ah,10
    call RND_Tabelle
    mov bl,byte ptr ds:[bp]
;    mov ah,Debug
_2_ADD16V16_0:
    cmp ah,1
    jne _2_ADD16V16_1
    mov ax,word ptr ds:[bp+2]
    call Add_Reg16_Value16_Tabelle
    call _ax_bx
    pop bp
    ret
_2_ADD16V16_1:
    cmp ah,2
    jne _2_ADD16V16_2
    mov ax,word ptr ds:[bp+4]
    call Add_Reg16_Value16_Tabelle
    call _ax_bx
    mov bl,byte ptr ds:[bp]
    mov ax,word ptr ds:[bp+2]
    call Add_Reg16_Value16_Tabelle
    call _ax_bx
    mov bl,byte ptr ds:[bp]
    mov ax,word ptr ds:[bp+4]
    call Sub_Reg16_Value16_Tabelle
    call _ax_bx
    pop bp
    ret
_2_ADD16V16_2:
    cmp ah,3
    jne _2_ADD16V16_3
    mov bh,byte ptr ds:[bp+1]
    push bp
    call _2_XCHG16
    pop bp
    mov bl,byte ptr ds:[bp+1]
    mov ax,word ptr ds:[bp+2]
    call Add_Reg16_Value16_Tabelle
    call _ax_bx
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
    call _2_XCHG16
    pop bp
    ret
_2_ADD16V16_3:
    cmp ah,4
    jne _2_ADD16V16_4
    mov bh,byte ptr ds:[bp+1]
    push bp
    call _2_SUB16
    pop bp
    mov bl,byte ptr ds:[bp]
    mov ax,word ptr ds:[bp+2]
    call Add_Reg16_Value16_Tabelle
    call _ax_bx
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
    call _2_ADD16
    pop bp
    ret
_2_ADD16V16_4:
    cmp ah,5
    jne _2_ADD16V16_5
    mov bh,byte ptr ds:[bp+1]
    push bx
    push bp
    call _2_ADD16
    pop bp
    mov bl,byte ptr ds:[bp]
    mov ax,word ptr ds:[bp+2]
    call Add_Reg16_Value16_Tabelle
    call _ax_bx
    pop bx
    call _2_SUB16
    pop bp
    ret
_2_ADD16V16_5:
    cmp ah,6
    jne _2_ADD16V16_6
    mov bl,byte ptr ds:[bp+1]
    call Push_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp+1]
    mov ax,word ptr ds:[bp+2]
    push bp
    call _2_MOV16V16
    pop bp
    mov bl,byte ptr ds:[bp+1]
    mov bh,byte ptr ds:[bp]
    push bp
    call _2_ADD16
    pop bp
    mov bl,byte ptr ds:[bp]
    mov ax,word ptr ds:[bp+4]
    push bp
    call _2_MOV16V16
    pop bp
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
    push bp
    call _2_ADD16
    pop bp
    mov bl,byte ptr ds:[bp]
    mov ax,word ptr ds:[bp+4]
    call Sub_Reg16_Value16_Tabelle
    call _ax_bx
    mov bl,byte ptr ds:[bp+1]
    call Pop_Reg16_Tabelle
    call _bl
    pop bp
    ret
_2_ADD16V16_6:
    cmp ah,7
    jne _2_ADD16V16_7
    mov ax,word ptr ds:[bp+2]
    mov bx,word ptr ds:[bp+4]
    push bx
    add ax,bx
    mov bl,byte ptr ds:[bp]
    call Add_Reg16_Value16_Tabelle
    call _ax_bx
    pop ax
    mov bl,byte ptr ds:[bp]
    call Sub_Reg16_Value16_Tabelle
    call _ax_bx
    pop bp
    ret
_2_ADD16V16_7:
    mov ax,word ptr ds:[bp+2]
    mov bx,word ptr ds:[bp+4]
    push bx
    sub ax,bx
    mov bl,byte ptr ds:[bp]
    call Add_Reg16_Value16_Tabelle
    call _ax_bx
    pop ax
    mov bl,byte ptr ds:[bp]
    call Add_Reg16_Value16_Tabelle
    call _ax_bx
    pop bp
    ret
;---
;Вычитание из значения регистра R значения Value16
;Input:  bl - numreg
;        ax - Value16
_2_SUB16V16:
    push bp
    call _2_SUB16V16_
_2_SUB16V16_R    db ?
_2_SUB16V16_RND  db ?
_2_SUB16V16_V    dw ?
_2_SUB16V16_VRND dw ?
_2_SUB16V16_:
    pop bp
    mov byte ptr ds:[bp],bl
    mov word ptr ds:[bp+2],ax
_2_SUB16V16_RND_:
    call _Case_Rnd16
    mov byte ptr ds:[bp+1],bh
_2_SUB16V16_RND_1:
    call _Calc_Rnd16
    cmp bx,0
    je _2_SUB16V16_RND_1
    mov word ptr ds:[bp+4],bx
    mov ah,10
    call RND_Tabelle
    mov bl,byte ptr ds:[bp]
;    mov ah,Debug
_2_SUB16V16_0:
    cmp ah,1
    jne _2_SUB16V16_1
    mov ax,word ptr ds:[bp+2]
    call Sub_Reg16_Value16_Tabelle
    call _ax_bx
    pop bp
    ret
_2_SUB16V16_1:
    cmp ah,2
    jne _2_SUB16V16_2
    mov ax,word ptr ds:[bp+4]
    call Sub_Reg16_Value16_Tabelle
    call _ax_bx
    mov bl,byte ptr ds:[bp]
    mov ax,word ptr ds:[bp+2]
    call Sub_Reg16_Value16_Tabelle
    call _ax_bx
    mov bl,byte ptr ds:[bp]
    mov ax,word ptr ds:[bp+4]
    call _2_ADD16V16
    pop bp
    ret
_2_SUB16V16_2:
    cmp ah,3
    jne _2_SUB16V16_3
    mov ax,word ptr ds:[bp+4]
    push bp
    call _2_ADD16V16
    pop bp
    mov bl,byte ptr ds:[bp]
    mov ax,word ptr ds:[bp+2]
    call Sub_Reg16_Value16_Tabelle
    call _ax_bx
    mov bl,byte ptr ds:[bp]
    mov ax,word ptr ds:[bp+4]
    call Sub_Reg16_Value16_Tabelle
    call _ax_bx
    pop bp
    ret
_2_SUB16V16_3:
    cmp ah,4
    jne _2_SUB16V16_4
    mov bl,byte ptr ds:[bp+1]
    call Push_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp+1]
    mov ax,word ptr ds:[bp+2]
    push bp
    call _2_MOV16V16
    pop bp
    mov bl,byte ptr ds:[bp+1]
    mov ax,word ptr ds:[bp+4]
    call Sub_Reg16_Value16_Tabelle
    call _ax_bx
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
    push bp
    call _2_SUB16
    pop bp
    mov bl,byte ptr ds:[bp]
    mov ax,word ptr ds:[bp+4]
    call Sub_Reg16_Value16_Tabelle
    call _ax_bx
    mov bl,byte ptr ds:[bp+1]
    call Pop_Reg16_Tabelle
    call _bl
    pop bp
    ret
_2_SUB16V16_4:
    cmp ah,5
    jne _2_SUB16V16_5
    mov bl,byte ptr ds:[bp+1]
    call Push_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp+1]
    mov ax,word ptr ds:[bp+2]
    push bp
    call _2_MOV16V16
    pop bp
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
    push bp
    call _2_SUB16
    pop bp
    mov bl,byte ptr ds:[bp+1]
    call Pop_Reg16_Tabelle
    call _bl
    pop bp
    ret
_2_SUB16V16_5:
    cmp ah,6
    jne _2_SUB16V16_6
    mov bh,byte ptr ds:[bp+1]
    push bp
    call _2_XCHG16
    pop bp
    mov bl,byte ptr ds:[bp+1]
    mov ax,word ptr ds:[bp+2]
    call Sub_Reg16_Value16_Tabelle
    call _ax_bx
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
    call _2_XCHG16
    pop bp
    ret
_2_SUB16V16_6:
    cmp ah,7
    jne _2_SUB16V16_7
    mov ax,word ptr ds:[bp+2]
    mov bx,word ptr ds:[bp+4]
    add ax,bx
    push bx
    mov bl,byte ptr ds:[bp]
    call Sub_Reg16_Value16_Tabelle
    call _ax_bx
    pop ax
    mov bl,byte ptr ds:[bp]
    call _2_ADD16V16
    pop bp
    ret
_2_SUB16V16_7:
    mov ax,word ptr ds:[bp+2]
    mov bx,word ptr ds:[bp+4]
    sub ax,bx
    push bx
    mov bl,byte ptr ds:[bp]
    call Sub_Reg16_Value16_Tabelle
    call _ax_bx
    pop ax
    mov bl,byte ptr ds:[bp]
    call Sub_Reg16_Value16_Tabelle
    call _ax_bx
    pop bp
    ret
;---
