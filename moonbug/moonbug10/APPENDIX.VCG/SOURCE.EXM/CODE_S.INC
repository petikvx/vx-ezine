;Codegenerator (c) 1999 by RedArc

;Генератор команд второго уровня

;Input:  bl - numreg1
;        bh - numreg2
;Output: none
__MOV_R1_R2_16:
        mov ah,5
        call RND_Tabelle
        cmp ah,0
        jne _MR1R2_1
        call _MOV_R1_R2_16
        ret
_MR1R2_1:
        cmp ah,1
        jne _MR1R2_2
        call _PUSH_R2_POP_R1_16
        ret
_MR1R2_2:
        cmp ah,2
        jne _MR1R2_3
        call _MOV_R1_R2_per_Zerro_16
        ret
_MR1R2_3:
        cmp ah,3
        jne _MR1R2_4
        call _MOV_R1_R2_per_Zerro_16_1
        ret
_MR1R2_4:
        cmp ah,4
        jne _MR1R2_5
        call _MOV_R1_R2_16_per_RND
        ret
_MR1R2_5:
        call _MOV_R1_R2_16_per_RND_1
        ret
;---
;Input:  bl - numreg1
;        bh - numreg2
;Output: none
__XCHG_R1_R2_16:
        mov ah,2
        call RND_Tabelle
        cmp ah,0
        jne _XMR_1
        call _XCHG_R1_R2_16
        ret
_XMR_1:
        cmp ah,1
        jne _XMR_2
        call _XCHG_Privat
        ret
_XMR_2:
        xchg bh,bl
        call _XCHG_Privat
        ret
;---
;Input:  bl - numreg
;        ax - value16
;Output: none
__MOV_R16_V16:
        mov _2_TEMP_16,ax
        mov _2_TEMP_L,bl
        mov ah,5
        call RND_Tabelle
        cmp ah,0
        jne _MRV_1
        mov bl,_2_TEMP_L
        mov ax,_2_TEMP_16
        call Mov_Reg16_Value16_Tabelle
        call _al_bx
        ret
_MRV_1:
        cmp ah,1
        jne _MRV_2
        call _ZERRO_R16
        mov bl,_2_TEMP_L
        mov ax,_2_TEMP_16
        call Add_Reg16_Value16_Tabelle
        call _ax_bx
        ret
_MRV_2:
        cmp ah,2
        jne _MRV_3
        call _Calc_Rnd_R16
        mov _2_RND_Reg16,bh
        mov bl,bh
        call Push_Reg16_Tabelle
        call _bl
        mov bl,_2_RND_Reg16
        mov ax,_2_TEMP_16
        call Mov_Reg16_Value16_Tabelle
        call _al_bx
        mov bl,_2_RND_Reg16
        mov bh,_2_TEMP_L
        call __XCHG_R1_R2_16
        mov bl,_2_RND_Reg16
        call Pop_Reg16_Tabelle
        call _bl
        ret
_MRV_3:
        cmp ah,3
        jne _MRV_4
        call _MRV_Private
        mov bl,_2_RND_Reg16
        mov ax,_2_TEMP_16
        call Add_Reg16_Value16_Tabelle
        call _ax_bx
        mov bl,_2_TEMP_L
        mov bh,_2_RND_Reg16
        call __MOV_R1_R2_16
        mov bl,_2_RND_Reg16
        call Pop_Reg16_Tabelle
        call _bl
        ret
_MRV_4:
        cmp ah,4
        jne _MRV_5
        call _Calc_Rnd_R16
        mov _2_RND_Reg16,bh
        mov bl,bh
        call Push_Reg16_Tabelle
        call _bl
        mov bl,_2_RND_Reg16
        call _ZERRO_R16
        mov bl,_2_RND_Reg16
        mov ax,_2_TEMP_16
        call Add_Reg16_Value16_Tabelle
        call _ax_bx
        call _Calc_Rnd16
        mov _2_RND_16,bx
        xchg bx,ax
        mov bl,_2_RND_Reg16
        call Add_Reg16_Value16_Tabelle
        call _ax_bx
        mov bl,_2_RND_Reg16
        mov bh,_2_TEMP_L
        call Xchg_Reg1_Reg2_16_Tabelle
        call _bx
        mov bl,_2_TEMP_L
        mov ax,_2_RND_16
        call Sub_Reg16_Value16_Tabelle
        call _ax_bx
        mov bl,_2_RND_Reg16
        call Pop_Reg16_Tabelle
        call _bl
        ret
_MRV_5:
        call _Calc_Rnd_R16
        mov _2_RND_Reg16,bh
        mov bl,bh
        call Push_Reg16_Tabelle
        call _bl
        mov bl,_2_RND_Reg16
        mov ax,_2_TEMP_16
        call Mov_Reg16_Value16_Tabelle
        call _al_bx
        call _Calc_Rnd16
        mov _2_RND_16,bx
        xchg bx,ax
        mov bl,_2_RND_Reg16
        call Xor_Reg16_Value16_Tabelle
        call _ax_bx
        mov bl,_2_TEMP_L
        mov bh,_2_RND_Reg16
        call __MOV_R1_R2_16
        mov bl,_2_TEMP_L
        mov ax,_2_RND_16
        call Xor_Reg16_Value16_Tabelle
        call _ax_bx
        mov bl,_2_RND_Reg16
        call Pop_Reg16_Tabelle
        call _bl
        ret
;---
;Input:  bl - numreg
;        ax - value16
;Output: none
__ADD_R16_V16:
        mov _3_TEMP_16,ax
        mov _3_TEMP_L,bl
        mov ah,5
        call RND_Tabelle
        cmp ah,0
        jne _ARV_1
        mov bl,_3_TEMP_L
        mov ax,_3_TEMP_16
        call Add_Reg16_Value16_Tabelle
        call _ax_bx
        ret
_ARV_1:
        cmp ah,1
        jne _ARV_2
        call _Calc_Rnd_R16
        mov _3_RND_Reg16,bh
        mov bl,bh
        call Push_Reg16_Tabelle
        call _bl
        mov bl,_3_RND_Reg16
        call _ZERRO_R16
        mov bl,_3_RND_Reg16
        mov ax,_3_TEMP_16
        call __MOV_R16_V16
        mov bl,_3_TEMP_L
        mov bh,_3_RND_Reg16
        call Add_Reg1_Reg2_16_Tabelle
        call _bx
        mov bl,_3_RND_Reg16
        call Pop_Reg16_Tabelle
        call _bl
        ret
_ARV_2:
        cmp ah,2
        jne _ARV_3
        call _Calc_Rnd_R16
        mov _3_RND_Reg16,bh
        mov bl,bh
        call Push_Reg16_Tabelle
        call _bl
        mov bl,_3_RND_Reg16
        mov bh,_3_TEMP_L
        call __XCHG_R1_R2_16
        mov bl,_3_TEMP_L
        mov ax,_3_TEMP_16
        call __MOV_R16_V16
        mov bl,_3_RND_Reg16
        mov bh,_3_TEMP_L
        call __XCHG_R1_R2_16
        mov bh,_3_RND_Reg16
        mov bl,_3_TEMP_L
        call Add_Reg1_Reg2_16_Tabelle
        call _bx
        mov bl,_3_RND_Reg16
        call Pop_Reg16_Tabelle
        call _bl
        ret
_ARV_3:
        cmp ah,3
        jne _ARV_4
        call _Calc_Rnd_R16
        mov _3_RND_Reg16,bh
        mov bl,bh
        call Push_Reg16_Tabelle
        call _bl
        mov bl,_3_RND_Reg16
        call _ZERRO_R16
        mov bl,_3_RND_Reg16
        mov bh,_3_TEMP_L
        call Or_Reg1_Reg2_16_Tabelle
        call _bx
        mov bl,_3_TEMP_L
        mov ax,_3_TEMP_16
        call __MOV_R16_V16
        mov bl,_3_RND_Reg16
        mov bh,_3_TEMP_L
        call Add_Reg1_Reg2_16_Tabelle
        call _bx
        mov bl,_3_RND_Reg16
        mov bh,_3_TEMP_L
        call __XCHG_R1_R2_16
        mov bl,_3_RND_Reg16
        call Pop_Reg16_Tabelle
        call _bl
        ret
_ARV_4:
        cmp ah,4
        jne _ARV_5
        call _Calc_Rnd_R16
        mov _3_RND_Reg16,bh
        mov bl,bh
        call Push_Reg16_Tabelle
        call _bl
        mov ax,_3_TEMP_16
        call _Calc_Rnd16
        mov _3_RND_16,bx
        xchg bx,ax
        mov bl,_3_RND_Reg16
        call __MOV_R16_V16
        mov bl,_3_RND_Reg16
        mov ax,_3_TEMP_16
        call Add_Reg16_Value16_Tabelle
        call _ax_bx
        mov bl,_3_RND_Reg16
        mov bh,_3_TEMP_L
        call __XCHG_R1_R2_16
        mov bh,_3_RND_Reg16
        mov bl,_3_TEMP_L
        call Sub_Reg1_Reg2_16_Tabelle
        call _bx
        mov bl,_3_RND_Reg16
        call Pop_Reg16_Tabelle
        call _bl
        ret
_ARV_5:
        call _Calc_Rnd_R16
        mov _3_RND_Reg16,bh
        mov bl,bh
        call Push_Reg16_Tabelle
        call _bl
        mov bl,_3_RND_Reg16
        mov ax,_3_TEMP_16
        call __MOV_R16_V16
        mov ax,_3_TEMP_16
        call _Calc_Rnd16
        mov _3_RND_16,bx
        xchg bx,ax
        mov bl,_3_RND_Reg16
        call Xor_Reg16_Value16_Tabelle
        call _ax_bx
        mov bl,_3_TEMP_L
        mov bh,_3_RND_Reg16
        call __MOV_R1_R2_16
        mov bl,_3_TEMP_L
        mov bh,_3_RND_Reg16
        call Xor_Reg1_Reg2_16_Tabelle
        call _bx
        mov bl,_3_RND_Reg16
        call Pop_Reg16_Tabelle
        call _bl
        ret
;---
;Input:  bl - numreg
;        bh - value8
;Output: none
__MOV_R8_V8:
        mov _1_TEMP_L,bl
        mov _1_TEMP_H,bh
        mov ah,5
        call RND_Tabelle
        cmp ah,0
        jne _MRV8_1
        call Mov_Reg8_Value8_Tabelle
        call _bx
        ret
_MRV8_1:
        cmp ah,1
        jne _MRV8_2
        mov bh,bl
        call Sub_Reg1_Reg2_8_Tabelle
        call _bx
        mov bl,_1_TEMP_L
        mov bh,_1_TEMP_H
        call Add_Reg8_Value8_Tabelle
        call _al_bx
        ret
_MRV8_2:
        cmp ah,2
        jne _MRV8_3
        mov bh,bl
        call Xor_Reg1_Reg2_8_Tabelle
        call _bx
        mov bl,_1_TEMP_L
        mov bh,_1_TEMP_H
        call Add_Reg8_Value8_Tabelle
        call _al_bx
        ret
_MRV8_3:
        cmp ah,3
        jne _MRV8_4
        call _Calc_Rnd8
        mov _1_RND_8,bh
        call Mov_Reg8_Value8_Tabelle
        call _bx
        mov bl,_1_TEMP_L
        mov bh,_1_TEMP_H
        call Xor_Reg8_Value8_Tabelle
        call _al_bx
        mov bl,_1_TEMP_L
        mov bh,_1_RND_8
        call Xor_Reg8_Value8_Tabelle
        call _al_bx
        ret
_MRV8_4:
        cmp ah,4
        jne _MRV8_5
        call _Calc_Rnd8
        mov _1_RND_8,bh
        call Mov_Reg8_Value8_Tabelle
        call _bx
        mov bl,_1_TEMP_L
        mov bh,_1_TEMP_H
        call Add_Reg8_Value8_Tabelle
        call _al_bx
        mov bl,_1_TEMP_L
        mov bh,_1_RND_8
        call Sub_Reg8_Value8_Tabelle
        call _al_bx
        ret
_MRV8_5:
        call _Calc_Rnd_R8
        mov _1_RND_Reg8,bh
        call Mov_Reg1_Reg2_8_Tabelle
        call _bx
        mov bl,_1_TEMP_L
        mov bh,_1_TEMP_H
        call Add_Reg8_Value8_Tabelle
        call _al_bx
        mov bl,_1_TEMP_L
        mov bh,_1_RND_Reg8
        call Sub_Reg1_Reg2_8_Tabelle
        call _bx
        ret
;---
;Input:  none
;Output: none
__NOP:
        mov ah,5
        call RND_Tabelle
        cmp ah,0
        jne _NOP1
        ret
_NOP1:
        cmp ah,1
        jne _NOP2
        mov al,90h
        call _al
        ret
_NOP2:
        cmp ah,2
        jne _NOP3
        mov ah,7
        mov bl,4
        call _Calc_Rnd_R16
        mov bl,ah
        call _Calc_Rnd_R16
        mov TEMP_L,bh
        mov TEMP_H,bl
        call __XCHG_R1_R2_16
        mov bl,TEMP_L
        mov bh,TEMP_H
        call __XCHG_R1_R2_16
        ret
_NOP3:
        cmp ah,3
        jne _NOP4
        mov ah,7
        mov bl,4
        call _Calc_Rnd_R16
        mov bl,ah
        xor ax,ax
        call __ADD_R16_V16
        ret
_NOP4:
        cmp ah,4
        jne _NOP5
        mov ah,7
        mov bl,4
        call _Calc_Rnd_R16
        mov bl,ah
        mov bh,ah
        call __XCHG_R1_R2_16
        ret
_NOP5:
        xor bx,bx
        call _Calc_Rnd_R16
        mov _1_RND_Reg16,bh
        call _Calc_Rnd16
        mov _1_RND_16,bx
        mov bl,_1_RND_Reg16
        xchg bx,ax
        call Xor_Reg16_Value16_Tabelle
        call _ax_bx
        call _NOP1
        mov bl,_1_RND_Reg16
        mov ax,_1_RND_16
        call Xor_Reg16_Value16_Tabelle
        call _ax_bx
        ret
;---
