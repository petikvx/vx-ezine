;Codegenerator (c) 1999 by RedArc

;---
;Обмен значениями между двумя 8 битовыми регистрами
;Input:  bl - numreg1
;        bh - numreg2
_2_XCHG8:
    call _2_XCHG8_
_2_XCHG8_R1 db ?
_2_XCHG8_R2 db ?
_2_XCHG8_:
    pop bp
    mov byte ptr ds:[bp],bl
    mov byte ptr ds:[bp+1],bh
    mov ah,2
    call RND_Tabelle
;    mov ah,Debug
_2_XCHG8_0:
    cmp ah,0
    jne _2_XCHG8_1
    call Xchg_Reg1_Reg2_8_Tabelle
    call _bx
    ret
_2_XCHG8_1:
    xchg bh,bl
    call Xchg_Reg1_Reg2_8_Tabelle
    call _bx
    ret
;---
;Присвоение регистру R1 значения регистра R2
;Input:  bl - numreg1
;        bh - numreg2
_2_MOV8:
    call _2_MOV8_
_2_MOV8_R1 db ?
_2_MOV8_R2 db ?
_2_MOV8_:
    pop bp
    mov byte ptr ds:[bp],bl
    mov byte ptr ds:[bp+1],bh
    mov ah,10
    call RND_Tabelle
;    mov ah,Debug
_2_MOV8_0:
    cmp ah,0
    jne _2_MOV8_1
    call Mov_Reg1_Reg2_8_Tabelle
    call _bx
    ret
_2_MOV8_1:
    cmp ah,1
    jne _2_MOV8_2
    xchg bh,bl
    call Find8Reg
    push bx
    push bp
    call _2_XCHG8
    pop bp
    pop bx
    mov bl,byte ptr ds:[bp]
    call Mov_Reg1_Reg2_8_Tabelle
    call _bx
    mov bl,byte ptr ds:[bp+1]
    call Find8Reg
    call _2_XCHG8
    ret
_2_MOV8_2:
    cmp ah,2
    jne _2_MOV8_3
    xchg bh,bl
    call Find16Reg
    xchg bh,bl
    call Push_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp+1]
    call Find8Reg
    push bx
    push bp
    call _2_XCHG8
    pop bp
    pop bx
    mov bl,byte ptr ds:[bp]
    push bp
    call _2_XCHG8
    pop bp
    mov bl,byte ptr ds:[bp+1]
    call Find16Reg
    xchg bh,bl
    call Pop_Reg16_Tabelle
    call _bl
    ret
_2_MOV8_3:
    xchg bh,bl
    call Find16Reg
    xchg bh,bl
    call Push_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp]
    call Find8Reg
    xchg ah,bh
    mov bl,byte ptr ds:[bp+1]
    call Find8Reg
    xchg al,bh
    xchg bx,ax
    call Mov_Reg1_Reg2_8_Tabelle
    call _bx
    mov bl,byte ptr ds:[bp+1]
    call Find16Reg
    xchg bh,bl
    push bx
    call Push_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp]
    call Find16Reg
    xchg bh,bl
    call Pop_Reg16_Tabelle
    call _bl
    pop bx
    call Pop_Reg16_Tabelle
    call _bl
    ret
;---
;Прибавление к значению регистра R1 значения регистра R2
;Input:  bl - numreg1
;        bh - numreg2
_2_ADD8:
    call _2_ADD8_
_2_ADD8_R1  db ?
_2_ADD8_R2  db ?
_2_ADD8_:
    pop bp
    mov byte ptr ds:[bp],bl
    mov byte ptr ds:[bp+1],bh
    mov ah,10
    call RND_Tabelle
;    mov ah,Debug
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
_2_ADD8_0:
    cmp ah,0
    jne _2_ADD8_1
    call Add_Reg1_Reg2_8_Tabelle
    call _bx
    ret
_2_ADD8_1:
    push bp
    call _2_XCHG8
    pop bp
    mov bl,byte ptr ds:[bp+1]
    mov bh,byte ptr ds:[bp]
    call Add_Reg1_Reg2_8_Tabelle
    call _bx
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
    call _2_XCHG8
    ret
;---
;Вычитание из значения регистра R1 значения регистра R2
;Input:  bl - numreg1
;        bh - numreg2
_2_SUB8:
    call _2_SUB8_
_2_SUB8_R1  db ?
_2_SUB8_R2  db ?
_2_SUB8_:
    pop bp
    mov byte ptr ds:[bp],bl
    mov byte ptr ds:[bp+1],bh
    mov ah,10
    call RND_Tabelle
;    mov ah,Debug
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
_2_SUB8_0:
    cmp ah,0
    jne _2_SUB8_1
    call Sub_Reg1_Reg2_8_Tabelle
    call _bx
    ret
_2_SUB8_1:
    push bp
    call _2_XCHG8
    pop bp
    mov bl,byte ptr ds:[bp+1]
    mov bh,byte ptr ds:[bp]
    push bx
    call Sub_Reg1_Reg2_8_Tabelle
    call _bx
    pop bx
    call _2_XCHG8
    ret
;---
;Исключающее ИЛИ значения регистра R1 со значением регистра R2
;Input:  bl - numreg1
;        bh - numreg2
_2_XOR8:
    call _2_XOR8_
_2_XOR8_R1  db ?
_2_XOR8_R2  db ?
_2_XOR8_:
    pop bp
    mov byte ptr ds:[bp],bl
    mov byte ptr ds:[bp+1],bh
    mov ah,10
    call RND_Tabelle
;    mov ah,Debug
_2_XOR8_0:
    cmp ah,0
    jne _2_XOR8_1
    call Xor_Reg1_Reg2_8_Tabelle
    call _bx
    ret
_2_XOR8_1:
    push bp
    call _2_XCHG8
    pop bp
    mov bl,byte ptr ds:[bp+1]
    mov bh,byte ptr ds:[bp]
    push bx
    call Xor_Reg1_Reg2_8_Tabelle
    call _bx
    pop bx
    call _2_XCHG8
    ret
;---
;Присвоение регистру R значения Value8
;Input:  bl - numreg
;        bh - Value8
_2_MOV8V8:
    call _2_MOV8V8_
_2_MOV8V8_R    db ?
_2_MOV8V8_RND  db ?
_2_MOV8V8_V    db ?
_2_MOV8V8_VRND db ?
_2_MOV8V8_:
    pop bp
    mov byte ptr ds:[bp],bl
    mov byte ptr ds:[bp+2],bh
    push bx
_2_MOV8V8_RND_:
    call _Case_Rnd16
    mov byte ptr ds:[bp+1],bh
_2_MOV8V8_RND_1:
    mov ah,0ffh
    call RND_Tabelle
    pop bx
    cmp ah,0
    je _2_MOV8V8_RND_1
    mov byte ptr ds:[bp+3],ah
    mov ah,10
    call RND_Tabelle
;    mov ah,Debug
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+2]
_2_MOV8V8_0:
    cmp ah,1
    jne _2_MOV8V8_1
    call Mov_Reg8_Value8_Tabelle
    call _bx
    ret
_2_MOV8V8_1:
    cmp ah,2
    jne _2_MOV8V8_2
    push bx
    mov bh,byte ptr ds:[bp+3]
    call Mov_Reg8_Value8_Tabelle
    call _bx
    pop bx
    call Add_Reg8_Value8_Tabelle
    call _al_bx
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+3]
    call Sub_Reg8_Value8_Tabelle
    call _al_bx
    ret
_2_MOV8V8_2:
    cmp ah,3
    jne _2_MOV8V8_3
    mov ah,byte ptr ds:[bp+3]
    push ax
    add ah,bh
    xchg bh,ah
    call Mov_Reg8_Value8_Tabelle
    call _bx
    pop bx
    mov bl,byte ptr ds:[bp]
    call Sub_Reg8_Value8_Tabelle
    call _al_bx
    ret
_2_MOV8V8_3:
    cmp ah,4
    jne _2_MOV8V8_4
    mov ah,byte ptr ds:[bp+3]
    push ax
    sub bh,ah
    call Mov_Reg8_Value8_Tabelle
    call _bx
    pop bx
    mov bl,byte ptr ds:[bp]
    call Add_Reg8_Value8_Tabelle
    call _al_bx
    ret
_2_MOV8V8_4:
    cmp ah,5
    jne _2_MOV8V8_5
    mov ah,byte ptr ds:[bp+3]
    push ax
    xor bh,ah
    call Mov_Reg8_Value8_Tabelle
    call _bx
    pop bx
    mov bl,byte ptr ds:[bp]
    call Xor_Reg8_Value8_Tabelle
    call _al_bx
    ret
_2_MOV8V8_5:
    cmp ah,6
    jne _2_MOV8V8_6
    mov bh, byte ptr ds:[bp+1]
    push bx
    push bp
    call _2_XCHG8
    pop bp
    mov bl,byte ptr ds:[bp+1]
    mov bh,byte ptr ds:[bp+2]
    call Mov_Reg8_Value8_Tabelle
    call _bx
    pop bx
    call _2_XCHG8
    ret
_2_MOV8V8_6:
    push bx
    mov bh,byte ptr ds:[bp+1]
    push bp
    call _2_MOV8
    pop bp
    pop bx
    call Add_Reg8_Value8_Tabelle
    call _al_bx
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
    call _2_SUB8
    ret
;---
;Добавление к значению регистра R значения Value8
;Input:  bl - numreg
;        bh - Value8
_2_ADD8V8:
    call _2_ADD8V8_
_2_ADD8V8_R    db ?
_2_ADD8V8_RND  db ?
_2_ADD8V8_V    db ?
_2_ADD8V8_VRND db ?
_2_ADD8V8_:
    pop bp
    mov byte ptr ds:[bp],bl
    mov byte ptr ds:[bp+2],bh
    push bx
_2_ADD8V8_RND_:
    call _Case_Rnd16
    mov byte ptr ds:[bp+1],bh
_2_ADD8V8_RND_1:
    mov ah,0ffh
    call RND_Tabelle
    pop bx
    cmp ah,0
    je _2_ADD8V8_RND_1
    mov byte ptr ds:[bp+3],ah
    mov ah,10
    call RND_Tabelle
;    mov ah,Debug
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+2]
_2_ADD8V8_0:
    cmp ah,1
    jne _2_ADD8V8_1
    call Add_Reg8_Value8_Tabelle
    call _al_bx
    ret
_2_ADD8V8_1:
    cmp ah,2
    jne _2_ADD8V8_2
    push bx
    mov bh,byte ptr ds:[bp+3]
    call Add_Reg8_Value8_Tabelle
    call _al_bx
    pop bx
    call Add_Reg8_Value8_Tabelle
    call _al_bx
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+3]
    call Sub_Reg8_Value8_Tabelle
    call _al_bx
    ret
_2_ADD8V8_2:
    cmp ah,3
    jne _2_ADD8V8_3
    mov bh,byte ptr ds:[bp+1]
    push bx
    push bp
    call _2_XCHG8
    pop bp
    mov bl,byte ptr ds:[bp+1]
    mov bh,byte ptr ds:[bp+2]
    call Add_Reg8_Value8_Tabelle
    call _al_bx
    pop bx
    call _2_XCHG8
    ret
_2_ADD8V8_3:
    cmp ah,4
    jne _2_ADD8V8_4
    mov bh,byte ptr ds:[bp+1]
    push bx
    push bp
    call _2_SUB8
    pop bp
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+2]
    call Add_Reg8_Value8_Tabelle
    call _al_bx
    pop bx
    call _2_ADD8 ;!!!
    ret
_2_ADD8V8_4:
    cmp ah,5
    jne _2_ADD8V8_5
    mov bh,byte ptr ds:[bp+1]
    push bx
    push bp
    call _2_ADD8
    pop bp
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+2]
    call Add_Reg8_Value8_Tabelle
    call _al_bx
    pop bx
    call _2_SUB8
    ret
_2_ADD8V8_5:
    cmp ah,6
    jne _2_ADD8V8_6
    mov ah,byte ptr ds:[bp+3]
    add bh,ah
    call Add_Reg8_Value8_Tabelle
    call _al_bx
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+3]
    call Sub_Reg8_Value8_Tabelle
    call _al_bx
    ret
_2_ADD8V8_6:
    mov ah,byte ptr ds:[bp+3]
    sub bh,ah
    call Add_Reg8_Value8_Tabelle
    call _al_bx
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+3]
    call Add_Reg8_Value8_Tabelle
    call _al_bx
    ret
;---
;Вычитание из значения регистра R значения Value8
;Input:  bl - numreg
;        bh - Value8
_2_SUB8V8:
    call _2_SUB8V8_
_2_SUB8V8_R    db ?
_2_SUB8V8_RND  db ?
_2_SUB8V8_V    db ?
_2_SUB8V8_VRND db ?
_2_SUB8V8_:
    pop bp
    mov byte ptr ds:[bp],bl
    mov byte ptr ds:[bp+2],bh
    push bx
_2_SUB8V8_RND_:
    call _Case_Rnd16
    mov byte ptr ds:[bp+1],bh
_2_SUB8V8_RND_1:
    mov ah,0ffh
    call RND_Tabelle
    pop bx
    cmp ah,0
    je _2_SUB8V8_RND_1
    mov byte ptr ds:[bp+4],ah
    mov ah,10
    call RND_Tabelle
;    mov ah,Debug
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+2]
_2_SUB8V8_0:
    cmp ah,1
    jne _2_SUB8V8_1
    call Sub_Reg8_Value8_Tabelle
    call _al_bx
    ret
_2_SUB8V8_1:
    cmp ah,2
    jne _2_SUB8V8_2
    mov ah,byte ptr ds:[bp+3]
    add bh,ah
    call Sub_Reg8_Value8_Tabelle
    call _al_bx
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+3]
    call _2_ADD8V8
    ret
_2_SUB8V8_2:
    cmp ah,3
    jne _2_SUB8V8_3
    mov ah,byte ptr ds:[bp+3]
    sub bh,ah
    call Sub_Reg8_Value8_Tabelle
    call _al_bx
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+3]
    call Sub_Reg8_Value8_Tabelle
    call _al_bx
    ret
_2_SUB8V8_3:
    cmp ah,4
    jne _2_SUB8V8_4
    push bx
    mov bh,byte ptr ds:[bp+3]
    call Sub_Reg8_Value8_Tabelle
    call _al_bx
    pop bx
    call Sub_Reg8_Value8_Tabelle
    call _al_bx
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+3]
    call _2_ADD8V8
    ret
_2_SUB8V8_4:
    cmp ah,5
    jne _2_SUB8V8_5
    push bx
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+3]
    push bp
    call _2_ADD8V8
    pop bp
    pop bx
    call Sub_Reg8_Value8_Tabelle
    call _al_bx
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+3]
    call Sub_Reg8_Value8_Tabelle
    call _al_bx
    ret
_2_SUB8V8_5:
    cmp ah,6
    jne _2_SUB8V8_6
    mov bl,byte ptr ds:[bp+1]
    call Find16Reg
    xchg bh,bl
    push bx
    call Push_Reg16_Tabelle
    call _bl
    mov bl,byte ptr ds:[bp+1]
    mov bh,byte ptr ds:[bp+2]
    push bp
    call _2_MOV8V8
    pop bp
    mov bl,byte ptr ds:[bp]
    mov bh,byte ptr ds:[bp+1]
    push bp
    call _2_SUB8
    pop bp
    pop bx
    call Pop_Reg16_Tabelle
    call _bl
    ret
_2_SUB8V8_6:
    mov bh,byte ptr ds:[bp+1]
    push bx
    push bp
    call _2_XCHG8
    pop bp
    mov bl,byte ptr ds:[bp+1]
    mov bh,byte ptr ds:[bp+2]
    call Sub_Reg8_Value8_Tabelle
    call _al_bx
    pop bx
    call _2_XCHG8
    ret
;---
