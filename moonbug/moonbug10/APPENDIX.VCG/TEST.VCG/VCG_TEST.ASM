;(c) RedArc
Model Tiny
.code
org 100h

__m0 equ 'iV' xor 01234h
_m0 equ __m0 + 00123h
__m1 equ 'ur' xor 01234h
_m1 equ __m1 - 04567h
__m2 equ 'Cs' xor 01234h
_m2 equ __m2 + 089abh
__m3 equ 'do' xor 01234h
_m3 equ __m3 - 0cdefh
__m4 equ 'Ge' xor 01234h
_m4 equ __m4 + 01edch
_m5 equ 'ne' - 0ba98h
_m6 equ ('re' xor 01234h) + 07654h
_m7 equ ('ta' xor 01234h) - 03210h
_m8 equ ('ro' xor 01234h) + 02edah
_m9 equ ('b ' xor 01234h) - 0deadh
_ma equ (' y' xor 00111h) + 0ceceh
_mb equ ('eR' xor 01234h) - 0fedah
_mc equ ('Ad' xor 01234h) + 03da0h
_md equ ('cr' xor 01234h) - 0eb13h
_me equ ('$ ' xor 01234h) + 01234h

start:
       lea di,buff
;---
       mov ax,100h
       mov bl,7
       call _2_MOV16V16
;*
       xor bx,bx
       call _Case_Rnd16
       mov RndRegCalc,bh
       mov ax,_m0
       mov bl,RndRegCalc
       call _2_MOV16V16
       mov bl,RndRegCalc
       mov ax,00123h
       call _2_SUB16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_MOV16
       mov bl,RndRegCalc
       mov ax,01234h
       call _2_MOV16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_XOR16
       mov bl,0
       call Stosw_Tabelle
       call _bl
;*
       xor bx,bx
       call _Case_Rnd16
       mov RndRegCalc,bh
       mov ax,_m1
       mov bl,RndRegCalc
       call _2_MOV16V16
       mov bl,RndRegCalc
       mov ax,04567h
       call _2_ADD16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_MOV16
       mov bl,RndRegCalc
       mov ax,01234h
       call _2_MOV16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_XOR16
       mov bl,0
       call Stosw_Tabelle
       call _bl
;*
       xor bx,bx
       call _Case_Rnd16
       mov RndRegCalc,bh
       mov ax,_m2
       mov bl,RndRegCalc
       call _2_MOV16V16
       mov bl,RndRegCalc
       mov ax,089abh
       call _2_SUB16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_MOV16
       mov bl,RndRegCalc
       mov ax,01234h
       call _2_MOV16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_XOR16
       mov bl,0
       call Stosw_Tabelle
       call _bl
;*
       xor bx,bx
       call _Case_Rnd16
       mov RndRegCalc,bh
       mov ax,_m3
       mov bl,RndRegCalc
       call _2_MOV16V16
       mov bl,RndRegCalc
       mov ax,0cdefh
       call _2_ADD16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_MOV16
       mov bl,RndRegCalc
       mov ax,01234h
       call _2_MOV16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_XOR16
       mov bl,0
       call Stosw_Tabelle
       call _bl
;*
       xor bx,bx
       call _Case_Rnd16
       mov RndRegCalc,bh
       mov ax,_m4
       mov bl,RndRegCalc
       call _2_MOV16V16
       mov bl,RndRegCalc
       mov ax,01edch
       call _2_SUB16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_MOV16
       mov bl,RndRegCalc
       mov ax,01234h
       call _2_MOV16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_XOR16
       mov bl,0
       call Stosw_Tabelle
       call _bl
;*
       xor bx,bx
       call _Case_Rnd16
       mov RndRegCalc,bh
       mov ax,_m5
       mov bl,RndRegCalc
       call _2_MOV16V16
       mov bl,RndRegCalc
       mov ax,0ba98h
       call _2_ADD16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_MOV16
       mov bl,0
       call Stosw_Tabelle
       call _bl
;*
       xor bx,bx
       call _Case_Rnd16
       mov RndRegCalc,bh
       mov ax,_m6
       mov bl,RndRegCalc
       call _2_MOV16V16
       mov bl,RndRegCalc
       mov ax,07654h
       call _2_SUB16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_MOV16
       mov bl,RndRegCalc
       mov ax,01234h
       call _2_MOV16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_XOR16
       mov bl,0
       call Stosw_Tabelle
       call _bl
;*
       xor bx,bx
       call _Case_Rnd16
       mov RndRegCalc,bh
       mov ax,_m7
       mov bl,RndRegCalc
       call _2_MOV16V16
       mov bl,RndRegCalc
       mov ax,03210h
       call _2_ADD16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_MOV16
       mov bl,RndRegCalc
       mov ax,01234h
       call _2_MOV16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_XOR16
       mov bl,0
       call Stosw_Tabelle
       call _bl
;*
       xor bx,bx
       call _Case_Rnd16
       mov RndRegCalc,bh
       mov ax,_m8
       mov bl,RndRegCalc
       call _2_MOV16V16
       mov bl,RndRegCalc
       mov ax,02edah
       call _2_SUB16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_MOV16
       mov bl,RndRegCalc
       mov ax,01234h
       call _2_MOV16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_XOR16
       mov bl,0
       call Stosw_Tabelle
       call _bl
;*
       xor bx,bx
       call _Case_Rnd16
       mov RndRegCalc,bh
       mov ax,_m9
       mov bl,RndRegCalc
       call _2_MOV16V16
       mov bl,RndRegCalc
       mov ax,0deadh
       call _2_ADD16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_MOV16
       mov bl,RndRegCalc
       mov ax,01234h
       call _2_MOV16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_XOR16
       mov bl,0
       call Stosw_Tabelle
       call _bl
;*
       xor bx,bx
       call _Case_Rnd16
       mov RndRegCalc,bh
       mov ax,_ma
       mov bl,RndRegCalc
       call _2_MOV16V16
       mov bl,RndRegCalc
       mov ax,0ceceh
       call _2_SUB16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_MOV16
       mov bl,RndRegCalc
       mov ax,00111h
       call _2_MOV16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_XOR16
       mov bl,0
       call Stosw_Tabelle
       call _bl
;*
       xor bx,bx
       call _Case_Rnd16
       mov RndRegCalc,bh
       mov ax,_mb
       mov bl,RndRegCalc
       call _2_MOV16V16
       mov bl,RndRegCalc
       mov ax,0fedah
       call _2_ADD16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_MOV16
       mov bl,RndRegCalc
       mov ax,01234h
       call _2_MOV16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_XOR16
       mov bl,0
       call Stosw_Tabelle
       call _bl
;*
       xor bx,bx
       call _Case_Rnd16
       mov RndRegCalc,bh
       mov ax,_mc
       mov bl,RndRegCalc
       call _2_MOV16V16
       mov bl,RndRegCalc
       mov ax,03da0h
       call _2_SUB16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_MOV16
       mov bl,RndRegCalc
       mov ax,01234h
       call _2_MOV16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_XOR16
       mov bl,0
       call Stosw_Tabelle
       call _bl
;*
       xor bx,bx
       call _Case_Rnd16
       mov RndRegCalc,bh
       mov ax,_md
       mov bl,RndRegCalc
       call _2_MOV16V16
       mov bl,RndRegCalc
       mov ax,0eb13h
       call _2_ADD16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_MOV16
       mov bl,RndRegCalc
       mov ax,01234h
       call _2_MOV16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_XOR16
       mov bl,0
       call Stosw_Tabelle
       call _bl
;*
       xor bx,bx
       call _Case_Rnd16
       mov RndRegCalc,bh
       mov ax,_me
       mov bl,RndRegCalc
       call _2_MOV16V16
       mov bl,RndRegCalc
       mov ax,01234h
       call _2_SUB16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_MOV16
       mov bl,RndRegCalc
       mov ax,01234h
       call _2_MOV16V16
       mov bl,0
       mov bh,RndRegCalc
       call _2_XOR16
       mov bl,0
       call Stosw_Tabelle
       call _bl
;*
       mov bl,0
       mov ax,09h
       xchg ah,al
       call _2_MOV16V16
       mov bl,2
       mov ax,0100h
       call _2_MOV16V16
       call _INT21h

       mov byte ptr ds:[di],0c3h
       inc di
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
       int 20h
;---
include code.inc
include code16_1.inc
include code8_1.inc
include code16_2.inc
include code8_2.inc
filename db 'test1.com',0h
RndRegCalc db ?
buff label byte
end start
