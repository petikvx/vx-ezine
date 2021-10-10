;Codegenerator (c) 1999 by RedArc

;Демка по использованию кодогенератора

Model Tiny
.code
org 100h
start:
       mov ah,09h
       lea dx,msg
       int 21h
       cld
       lea di,buff
       call __NOP
       mov bl,4
       mov bh,4eh
       call __MOV_R8_V8
       call __NOP
       mov Punkt_1,di
       mov bl,2
       mov ax,1234h
       call Mov_Reg16_Value16_Tabelle
       call _al_bx
       call __NOP
       mov Punkt_2,di
       call _int21h
       call __NOP
       lea si,bytes_2
       mov cx,bytes_2_length
       rep movsb
       call __NOP
       xor bx,bx
       mov ax,3d02h
       call __MOV_R16_V16
       call __NOP
       mov bl,2
       call _ZERRO_R16
       call __NOP
       mov bl,2
       mov bh,9eh
       call __MOV_R8_V8
       call __NOP
       call _int21h
       call __NOP
       mov bl,3
       mov bh,0
       call __XCHG_R1_R2_16
       call __NOP
       mov bl,4
       mov bh,40h
       call __MOV_R8_V8
       call __NOP
       mov Punkt_3,di
       mov bl,1
       mov ax,1234h
       call Mov_Reg16_Value16_Tabelle
       call _al_bx
       call __NOP
       mov bl,2
       mov ax,100h
       call __MOV_R16_V16
       call __NOP
       call _int21h
       call __NOP
       mov bl,4
       mov bh,3eh
       call __MOV_R8_V8
       call __NOP
       call _int21h
       call __NOP
       xor bx,bx
       mov ax,4301h
       call __MOV_R16_V16
       call __NOP
       mov bl,1
       call _ZERRO_R16
       call __NOP
       mov bl,1
       mov bh,1
       call __MOV_R8_V8
       call __NOP
       mov bl,2
       call _ZERRO_R16
       call __NOP
       mov bl,2
       mov bh,9eh
       call __MOV_R8_V8
       call __NOP
       call _int21h
       call __NOP
       mov bl,4
       mov bh,4fh
       call __MOV_R8_V8
       call __NOP
       mov Punkt_4,di
       mov bl,6
       mov ax,1234h
       call Mov_Reg16_Value16_Tabelle
       call _al_bx
       call __NOP
       mov bl,6
       call Push_Reg16_Tabelle
       call _bl
       call __NOP
       lea si,bytes_3
       mov cx,bytes_3_length
       rep movsb
       call __NOP
       mov Punkt_5,di
       lea si,bytes_4
       mov cx,bytes_4_length
       rep movsb
       call __NOP
;----------------------------
        push di
        mov di,Punkt_1
        inc di
        mov ax,Punkt_5
        lea dx,buff
        sub ax,dx
        inc ah
        mov word ptr ds:[di],ax
        pop di
;---
        lea dx,buff
        mov ax,Punkt_2
        sub ax,dx
        inc ah
        mov si,Punkt_4
        inc si
        mov word ptr ds:[si],ax
;---
        mov ax,di
        lea dx,buff
        sub ax,dx
        mov si,Punkt_3
        inc si
        mov word ptr ds:[si],ax
;----------------------------
       mov ah,3ch
       lea dx,filename
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
       int 20h
;---
include code16.inc
include code8.inc
include code_0.dat
include code_0.inc
include code_1.inc
include code_s.inc
buff label byte
end start
