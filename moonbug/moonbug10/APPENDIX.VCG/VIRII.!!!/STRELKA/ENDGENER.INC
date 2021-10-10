;Codegenerator (c) 1999 by RedArc
_CopyAsIsGenerator:
       push ax bx cx dx si
       call _NOP
       mov al,1eh                               ;push ds
       stosb
       call _NOP
       mov ax,0d88eh                            ;mov ds,ax
       stosw
       call _NOP
       mov ax,0c08eh                            ;mov es,ax
       stosw
       call _NOP
       mov bl,7                                 ;push di
       call Push_Reg16_Tabelle
       call _bl
       call _NOP
       mov bl,1                                 ;mov cx,di
       mov bh,7
       call _2_MOV16
       call _NOP
       mov bl,7                                 ;mov di,0
       mov ax,0
       call _2_MOV16V16
       call _NOP
       mov al,0fch                              ;cld
       stosb
       call _NOP
       call Stosb_Tabelle                       ;stosb
       call _bl
       mov al,0e2h                              ;loop
       stosb
       mov al,0fdh
       stosb
       call _NOP
       mov al,00eh                              ;push cs
       stosb
       call _NOP
       mov al,01fh                              ;pop ds
       stosb
       call _NOP
       mov bl,6                                 ;mov si,100h
       mov ax,100h
       call _2_MOV16V16
       call _NOP
       mov bl,7                                 ;pop di
       call Pop_Reg16_Tabelle
       call _bl
       call _NOP
       mov bl,7                                 ;push di
       call Push_Reg16_Tabelle
       call _bl
       call _NOP
       mov word ptr ds:[766],di                 ;mov cx,mylength
       mov ax,1234h
       mov bl,1
       call Mov_Reg16_Value16_Tabelle
       call _al_bx
       call _NOP
       call Lodsb_Tabelle                       ;lodsb
       call _bl
       call Stosb_Tabelle                       ;stosb
       call _bl
       mov al,0e2h                              ;loop
       stosb
       mov al,0fch
       stosb
       call _NOP
       mov bl,1                                 ;pop cx
       call Pop_Reg16_Tabelle
       call _bl
       call _NOP
       mov bl,7                                 ;sub di,cx
       mov bh,1
       call _2_SUB16
       call _NOP
       mov bl,7                                 ;xchg di,cx
       mov bh,1
       call _2_XCHG16
       call _NOP
       mov al,01fh                              ;pop ds
       stosb
       call _NOP
       mov bl,0                                 ;pop ax
       call Pop_Reg16_Tabelle
       call _bl
       call _NOP
       mov al,006h                              ;push es
       stosb
       call _NOP
       mov al,050h                              ;push ax
       stosb
       call _NOP
       mov al,00Eh                              ;push cs
       stosb
       call _NOP
       mov al,007h                              ;pop es
       stosb
       call _NOP
       mov bl,5                                 ;mov bp,cx
       mov bh,1
       call _2_MOV16
       call _NOP
       mov al,0c3h                              ;ret
       stosb
       call _NOP
       pop si dx cx bx ax
       ret
