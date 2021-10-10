;Codegenerator (c) 1999 by RedArc

;Служебные подпрограммы

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
;Input:  none
;Output: bh - Rnd8
_Calc_Rnd8:
         push ax
         mov ah,0ffh
         call RND_Tabelle
         mov bh,ah
         pop ax
         ret
;---
;Input:  bl - reg1num
;Output: bh - reg2num
_Calc_Rnd_R8:
         push ax
_Case:
         mov ah,7
         call RND_Tabelle
         mov bh,ah
         cmp bl,bh
         je _Case
         pop ax
         ret
;---
_XCHG_Privat:
        push bx
        call Push_Reg16_Tabelle
        call _bl
        pop bx
        push bx
        call __MOV_R1_R2_16
        pop bx
        xchg bh,bl
        call Pop_Reg16_Tabelle
        call _bl
        ret
;---
_MRV_Private:
        call _Calc_Rnd_R16
        mov _2_RND_Reg16,bh
        mov bl,bh
        call Push_Reg16_Tabelle
        call _bl
        mov bl,_2_RND_Reg16
        call _ZERRO_R16
        ret
;---
_MRV_P_1:
        mov ax,_2_TEMP_16
        call _Calc_Rnd16
        mov _2_RND_16,bx
        xchg bx,ax
        mov bl,_2_RND_Reg16
        ret
;---
_int21h:
       lea si,bytes_1
       mov cx,bytes_1_length
       rep movsb
       ret
