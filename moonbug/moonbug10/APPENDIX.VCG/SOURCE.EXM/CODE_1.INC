;Codegenerator (c) 1999 by RedArc

;Генератор команд первого уровня

;Input:  bl - numreg1
;        bh - numreg2
;Output: none
_XCHG_R1_R2_16:
      call Xchg_Reg1_Reg2_16_Tabelle
      call _bx
      ret
;---
;Input:  bl - numreg1
;        bh - numreg2
;Output: none
_MOV_R1_R2_16:
      call Mov_Reg1_Reg2_16_Tabelle
      call _bx
      ret
;---
;Input:  bl - numreg1
;        bh - numreg2
;Output: none
_PUSH_R2_POP_R1_16:
      push bx
      xchg bh,bl
      call Push_Reg16_Tabelle
      call _bl
      pop bx
      call Pop_Reg16_Tabelle
      call _bl
      ret
;---
;Input:  bl - numreg1
;        bh - numreg2
;Output: none
_XOR_R1_R2_16:
      call Xor_Reg1_Reg2_16_Tabelle
      call _bx
      ret
;---
;Input:  bl - numreg1
;        bh - numreg2
;Output: none
_SUB_R1_R2_16:
      call Sub_Reg1_Reg2_16_Tabelle
      call _bx
      ret
;---
;Input:  bl - numreg1
;        bh - numreg2
;Output: none
_ADD_R1_R2_16:
      call Add_Reg1_Reg2_16_Tabelle
      call _bx
      ret
;---
;Input:  bl - numreg1
;       bh - numreg2
;Output: none
_OR_R1_R2_16:
      call Or_Reg1_Reg2_16_Tabelle
      call _bx
      ret
;---
;Input:  bl - numreg
;Output: none
_ZERRO_R16:
      mov bh,bl
      push ax
      mov ah,3
      call RND_Tabelle
      cmp ah,0
      jne _ZR_1
      call Xor_Reg1_Reg2_16_Tabelle
      call _bx
      jmp short _ZR_end
_ZR_1:
      cmp ah,1
      jne _ZR_2
      call Sub_Reg1_Reg2_16_Tabelle
      call _bx
      jmp short _ZR_end
_ZR_2:
      xor ax,ax
      call Mov_Reg16_Value16_Tabelle
      call _al_bx
_ZR_end:
      pop ax
      ret
;---
;Input:  bl - numreg1
;        bh - numreg2
;Output: none
_MOV_R1_R2_16_per_RND:
      mov _1_TEMP_L,bl
      mov _1_TEMP_H,bh
_MRRpR1:
      mov bl,_1_TEMP_L
      call _Calc_Rnd_R16
      mov bl,_1_TEMP_H
      cmp bh,bl
      je _MRRpR1
      mov _1_RND_Reg16,bh
      mov bl,bh
      call Push_Reg16_Tabelle
      call _bl
      mov bl,_1_RND_Reg16
      call _ZERRO_R16
      mov bl,_1_RND_Reg16
      mov bh,_1_TEMP_H
      call Add_Reg1_Reg2_16_Tabelle
      call _bx
      mov bl,_1_RND_Reg16
      call Push_Reg16_Tabelle
      call _bl
      mov bl,_1_TEMP_L
      call Pop_Reg16_Tabelle
      call _bl
      mov bl,_1_RND_Reg16
      call Pop_Reg16_Tabelle
      call _bl
      ret
;---
;Input:  bl - numreg1
;        bh - numreg2
;Output: none
_MOV_R1_R2_16_per_RND_1:
      mov _1_TEMP_L,bl
      mov _1_TEMP_H,bh
_MRRpR2:
      mov bl,_1_TEMP_L
      call _Calc_Rnd_R16
      mov bl,_1_TEMP_H
      cmp bh,bl
      je _MRRpR2
      mov _1_RND_Reg16,bh
      mov bl,bh
      call Push_Reg16_Tabelle
      call _bl
      mov bl,_1_RND_Reg16
      mov bh,_1_TEMP_H
      call Xor_Reg1_Reg2_16_Tabelle
      call _bx
      mov bl,_1_TEMP_L
      mov bh,_1_RND_Reg16
      call Mov_Reg1_Reg2_16_Tabelle
      call _bx
      mov bl,_1_RND_Reg16
      call Pop_Reg16_Tabelle
      call _bl
      mov bl,_1_TEMP_L
      mov bh,_1_RND_Reg16
      call Xor_Reg1_Reg2_16_Tabelle
      call _bx
      ret
;---
;Input:  bl - numreg1
;        bh - numreg2
;Output: none
_MOV_R1_R2_per_Zerro_16:
        push bx
        call _ZERRO_R16
        pop bx
        call _ADD_R1_R2_16
        ret
;---
;Input:  bl - numreg1
;        bh - numreg2
;Output: none
_MOV_R1_R2_per_Zerro_16_1:
        push bx
        call _ZERRO_R16
        pop bx
        call _OR_R1_R2_16
        ret
;---
