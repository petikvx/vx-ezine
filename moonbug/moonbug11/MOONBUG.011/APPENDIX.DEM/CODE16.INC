;������� ������ � 16-���묨 ॣ���ࠬ�
;1999 (c) by RedArc
;--------------------------------

;-----------------------
;Input:  ah - range
;Output: ah - rnd
RND_Tabelle:
       mov al,ah
       in al,40h
       cmp al,ah
       jnc RND_Tabelle
       xchg ah,al
       ret
;-----------------------
_al:
       stosb
       ret
_bx:
       mov word ptr ds:[di],bx
       add di,2
       ret
_al_bx:
       call _al
       call _bx
       ret
_bl:
       mov byte ptr ds:[di],bl
       inc di
       ret
_ax_bx:
       stosw
       call _bx
       ret
;---
;Input:  none
;Output: bx - Rnd16
_Calc_Rnd16:
         push ax
         mov ah,0ffh
         call RND_Tabelle
         mov al,ah
         push ax
         mov ah,0ffh
         call RND_Tabelle
         xchg bx,ax
         pop ax
         mov bl,al
         pop ax
         ret
;---
;Input:  bl - reg1num
;Output: bh - reg2num
_Calc_Rnd_R16:
         push ax
_Case1:
         mov ah,7
         call RND_Tabelle
         mov bh,ah
         cmp bl,bh
         je _Case1
         cmp ah,4
         je _Case1
         pop ax
         ret
;---

;-----------------------
;Input:  bl - numreg
;Output: bl - code
Push_Reg16_Tabelle:
       add bl,50h
       ret
;-----------------------
;Input:  bl - numreg
;Output: bl - code
Pop_Reg16_Tabelle:
       add bl,58h
       ret
;-----------------------
;Input:  bl - numreg
;        ax - value16
;Output: ax:bx - code
Add_Reg16_Value16_Tabelle:
       add bl,0c0h
       mov bh,081h
       xchg bh,bl
       xchg bx,ax
       ret
;-----------------------
;Input:  bl - numreg
;        ax - value16
;Output: ax:bx - code
Sub_Reg16_Value16_Tabelle:
       add bl,0e8h
       mov bh,081h
       xchg bh,bl
       xchg bx,ax
       ret
;-----------------------
;Input:  bl - numreg
;        ax - value8
;Output: al:bx - code
Add_Reg16_Value8_Tabelle:
       add bl,0c0h
       mov bh,al
       mov al,083h
       ret
;-----------------------
;Input:  bl - numreg
;        ax - value8
;Output: al:bx - code
Sub_Reg16_Value8_Tabelle:
       add bl,0e8h
       mov bh,al
       mov al,083h
       ret
;-----------------------
;Input:  bl - numreg1
;        bh - numreg2
;Output: bl - code
;Remark: used for AddR1R2, SubR1R2, ...
CalculCodeR2ofR1:
         push ax cx dx
         mov al,bl
         mov cx,8
         mul cx
         add al,bh
         xchg bx,ax
         add bl,0c0h
         pop dx cx ax
         ret
;-----------------------
;Input:  bl - numreg1
;        bh - numreg2
;Output: bx - code
Add_Reg1_Reg2_16_Tabelle:
         call CalculCodeR2ofR1
         mov bh,003h
         xchg bh,bl
         ret
;-----------------------
;Input:  bl - numreg1
;        bh - numreg2
;Output: bx - code
Sub_Reg1_Reg2_16_Tabelle:
         call CalculCodeR2ofR1
         mov bh,02bh
         xchg bh,bl
         ret
;-----------------------
;Input:  bl - numreg1
;        bh - numreg2
;Output: bx - code
Xor_Reg1_Reg2_16_Tabelle:
         call CalculCodeR2ofR1
         mov bh,033h
         xchg bh,bl
         ret
;-----------------------
;Input:  bl - numreg
;        bh - value8
;Output: al:bx - code
Xor_Reg16_Value8_Tabelle:
         add bl,0f0h
         mov al,083h
         ret
;-----------------------
;Input:  bl - numreg
;        ax - value16
;Output: ax:bx - code
Xor_Reg16_Value16_Tabelle:
         add bl,0f0h
         mov bh,081h
         xchg bh,bl
         xchg bx,ax
         ret
;-----------------------
;Input:  bl - numreg1
;        bh - numreg2
;Output: bx - code
Mov_Reg1_Reg2_16_Tabelle:
         call CalculCodeR2ofR1
         mov bh,08bh
         xchg bh,bl
         ret
;-----------------------
;Input:  bl - numreg
;        ax - value16
;Output: al:bx - code
Mov_Reg16_Value16_Tabelle:
         add bl,0b8h
         xchg bx,ax
         ret
;-----------------------
;Input:  bl - numreg1
;        bh - numreg2
;Output: bx - code
Xchg_Reg1_Reg2_16_Tabelle:
         call CalculCodeR2ofR1
         mov bh,087h
         xchg bh,bl
         ret
;-----------------------
;Input:  bl - numreg
;Output: bl - code
Inc_Reg16_Tabelle:
         add bl,040h
         ret
;-----------------------
;Input:  bl - numreg
;Output: bl - code
Dec_Reg16_Tabelle:
         add bl,048h
         ret
;-----------------------
;Input:  bl - numreg
;        bh - value8
;Output: al:bx - code
Or_Reg16_Value8_Tabelle:
         add bl,0c8h
         mov al,083h
         ret
;-----------------------
;Input:  bl - numreg
;        ax - value16
;Output: ax:bx - code
Or_Reg16_Value16_Tabelle:
         add bl,0c8h
         mov bh,081h
         xchg bh,bl
         xchg bx,ax
         ret
;-----------------------
;Input:  bl - numreg1
;        bh - numreg2
;Output: bx - code
Or_Reg1_Reg2_16_Tabelle:
         call CalculCodeR2ofR1
         mov bh,00bh
         xchg bh,bl
         ret
;-----------------------
