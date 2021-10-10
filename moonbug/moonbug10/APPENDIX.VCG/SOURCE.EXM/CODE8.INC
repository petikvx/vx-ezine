;Codegenerator (c) 1999 by RedArc

;Генератор команд с 8-битными регистрами

;---NumReg8 Tabelle
;numreg|  0  1  2  3  4  5  6  7
;regs8 |  AL CL DL BL AH CH DH BH

;---R2 of R1 Tabelle
;code| C0 C1 C2 C3 C4 C5 C6 C7 | C8 C9 CA CB CC CD CE CF
; R2 | AL CL DL BL AH CH DH BH | AL CL DL BL AH CH DH BH
; R1 |            AL           |            CL
;-------------------------------------------------------
;code| D0 D1 D2 D3 D4 D5 D6 D7 | D8 D9 DA DB DC DD DE DF
; R2 | AL CL DL BL AH CH DH BH | AL CL DL BL AH CH DH BH
; R1 |            DL           |            BL
;-------------------------------------------------------
;code| E0 E1 E2 E3 E4 E5 E6 E7 | E8 E9 EA EB EC ED EE EF
; R2 | AL CL DL BL AH CH DH BH | AL CL DL BL AH CH DH BH
; R1 |            AH           |            CH
;-------------------------------------------------------
;code| F0 F1 F2 F3 F4 F5 F6 F7 | F8 F9 FA FB FC FD FE FF
; R2 | AL CL DL BL AH CH DH BH | AL CL DL BL AH CH DH BH
; R1 |            DH           |            BH

;-----------------------
;Input:  bl - numreg
;        bh - value8
;Output: bx - code
Mov_Reg8_Value8_Tabelle:
         add bl,0b0h
         ret
;-----------------------
;Input:  bl - numreg
;        bh - value8
;Output: al:bx - code
Add_Reg8_Value8_Tabelle:
       add bl,0c0h
       mov al,080h
       ret
;-----------------------
;Input:  bl - numreg
;        bh - value8
;Output: al:bx - code
Sub_Reg8_Value8_Tabelle:
       add bl,0e8h
       mov al,080h
       ret
;-----------------------
;Input:  bl - numreg
;        bh - value8
;Output: al:bx - code
Xor_Reg8_Value8_Tabelle:
         add bl,0f0h
         mov al,080h
         ret
;-----------------------
;Input:  bl - numreg
;        bh - value8
;Output: al:bx - code
Or_Reg8_Value8_Tabelle:
         add bl,0c8h
         mov al,080h
         ret
;-----------------------
;Input:  bl - numreg1
;        bh - numreg2
;Output: bx - code
Add_Reg1_Reg2_8_Tabelle:
         call CalculCodeR2ofR1
         mov bh,002h
         xchg bh,bl
         ret
;-----------------------
;Input:  bl - numreg1
;        bh - numreg2
;Output: bx - code
Sub_Reg1_Reg2_8_Tabelle:
         call CalculCodeR2ofR1
         mov bh,02ah
         xchg bh,bl
         ret
;-----------------------
;Input:  bl - numreg1
;        bh - numreg2
;Output: bx - code
Xor_Reg1_Reg2_8_Tabelle:
         call CalculCodeR2ofR1
         mov bh,032h
         xchg bh,bl
         ret
;-----------------------
;Input:  bl - numreg1
;        bh - numreg2
;Output: bx - code
Xchg_Reg1_Reg2_8_Tabelle:
         call CalculCodeR2ofR1
         mov bh,086h
         xchg bh,bl
         ret
;-----------------------
;Input:  bl - numreg1
;        bh - numreg2
;Output: bx - code
Mov_Reg1_Reg2_8_Tabelle:
         call CalculCodeR2ofR1
         mov bh,08ah
         xchg bh,bl
         ret
;-----------------------
;Input:  bl - numreg1
;        bh - numreg2
;Output: bx - code
Or_Reg1_Reg2_8_Tabelle:
         call CalculCodeR2ofR1
         mov bh,00ah
         xchg bh,bl
         ret
;-----------------------
;Input:  bl - numreg1
;Output: bx - code
Inc_Reg8_Tabelle:
         add bl,0c0h
         mov bh,0feh
         xchg bh,bl
         ret
;-----------------------
;Input:  bl - numreg1
;Output: bx - code
Dec_Reg8_Tabelle:
         add bl,0c8h
         mov bh,0feh
         xchg bh,bl
         ret
;-----------------------
;Input:  none
;Output: bl - code
Stosb_Tabelle:
         mov bl,0aah
         ret
;-----------------------
;Input:  none
;Output: bl - code
Stosw_Tabelle:
         mov bl,0abh
         ret
;-----------------------
;Input:  none
;Output: bl - code
Lodsb_Tabelle:
         mov bl,0ach
         ret
;-----------------------
;Input:  none
;Output: bl - code
Lodsw_Tabelle:
         mov bl,0adh
         ret
;-----------------------
