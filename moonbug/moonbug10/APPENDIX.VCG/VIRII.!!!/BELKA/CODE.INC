;Codegenerator (c) 1999 by RedArc

_al:
       mov byte ptr ds:[di],al
       inc di
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
       mov word ptr ds:[di],ax
       add di,2
       call _bx
       ret
;---
;�롮� ��砩���� 16 ��⮢��� ॣ����
;Input:  bl - reg1num
;Output: bh - reg2num
_Case_Rnd16:
         push ax
_Case:
         mov ah,7
         call RND_Tabelle
         mov bh,ah
         cmp bl,bh
         je _Case
         cmp ah,4
         je _Case
         pop ax
         ret
;---
;����祭�� 16 ��⮢��� ��砩���� �᫠
;Input:  none
;Output: bx - Rnd16
_Calc_Rnd16:
         push ax
         mov ah,0ffh
         call RND_Tabelle
         mov al,ah
         mov ah,0ffh
         call RND_Tabelle
         xchg bx,ax
         pop ax
         ret
;---
;��⠢�� ���⮣� ������
;Input:  none
;Output: none
_NOP:
       push ax bx cx dx si
       mov ah,6
       call RND_Tabelle
       cmp ah,0
       jne _NOP1
       pop si dx cx bx ax
       ret
_NOP1:
       mov byte ptr ds:[di],90h
       inc di
       pop si dx cx bx ax
       ret
;---
;��⠢�� ���뢠��� 21h
;Input:  none
;Output: none
_INT21h:
       call _NOP
       mov word ptr ds:[di],021cdh
       add di,2
       call _NOP
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
;Input:  bl - numreg
;        bh - value8
;Output: bx - code
Mov_Reg8_Value8_Tabelle:
         add bl,0b0h
         ret
