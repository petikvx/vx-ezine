; Модификация LZSS
; P.S. Естественно,тут можно отказатся от i386 инструкций,но зачем :) ?
; (c) Deviator/HAZARD

BufL	=	5			; Размер пре-буфферирования

EqPos	dw	0			; Некоторая переменная 
					; (регистров не хватило)

LzSSp	proc
	pusha
	mov bp,sp

	xchg ax,cx			; Размер
	stosw

	xor bx,bx

	mov cx,Bufl			; Пре-буфферируем
DoCopy:	push cx
	mov al,1
	mov cx,1
	Call BitStore
	lodsb
	mov cl,8
	Call BitStore
	pop  cx
	loop DoCopy

	mov cx,[bp][12]				; Нужный размер
	add cx,[bp][2]
Pack:	push cx
	push di
	xor  cx,cx
	mov  di,[bp][2]

	mov  dx,si
	xor  ax,ax

Scan:	push si di
NChar:	cmpsb					; Сравниваем байт
	jnz  NotSym				; Не совпали ?
	inc  cx					; Совпал. Увеличим кол-во 
						; совпадений
	cmp  di,dx				; Не дошли до границы ?
	jb   NChar				; нет

NotSym:	cmp  cx,3				; Как мимнимум 3 байта ?
	jl   NFd
	cmp  ax,cx				; То что мы нашли,больше
	ja   NFd				; предидущего найденого ?
	xchg ax,cx				; Да. Максимальный размер
	pop  di
	mov  EqPos,di				; Смещение на найденное
	push di
NFd:	pop  di si
	xor  cx,cx
	inc  di					; Смещаемся
	cmp  di,si
	jb   Scan				; След байт
	push si
	or   ax,ax				; Хоть что-то нашли ?
	jnz  Founded				; Нашли
	pop  si di
	mov	al,1				; Не нашли
	mov	cx,1				; Посылаем 1-ный бит
	Call	BitStore
	lodsb
	mov	cx,8				; Посылаем сам байт
	Call	BitStore
	jmp  nByte
Founded:xchg ax,cx
	pop  si di
	mov  ax,EqPos
	sub  ax,[bp][2]				; Вычислили смещение
	push cx ax
	mov  cx,1
	xor  ax,ax
	Call BitStore				; Посылаем 0-вой бит
	pop  ax
	mov  cl,15				; 15 бит смещение
	Call BitStore				; Смещениe
	pop  cx
	xchg ax,cx
	add  si,ax
	mov  cx,8				; Длина совпадения
	Call BitStore
nByte:	pop  cx
	cmp  si,cx
	jbe  Pack				; Есть еще данные

	shr  bx,3
	inc  bx
	mov  ax,di
	sub  ax,[bp][0]				; Новый размер
	add  ax,bx
	mov  [bp][12],ax
	popa
	ret
LzSSp	endp

LzSSd	proc
	xor bx,bx
	mov dx,di
	lodsw					; Возьмем размер
	push ax
	add ax,di
	xchg ax,bp
UP:	mov cx,1
	Call GetBit				; Берем бит
	dec  ax
	jz  JustCopy				; = 1 ?
	push si
	mov cx,15				; Нет. Берем 15 бит
	Call GetBit
	add  ax,dx				; Добавляем начало буффера
	push ax
	mov cx,8				; Берем 8 бит
	Call GetBit				; Переписываем
	xchg ax,cx
	pop  si
rep	movsb
	pop  si
	jmp  xByte
JustCopy:
	mov  cx,8
	Call GetBit				; Берем 8 бит
	stosb					; Записываем байт
xByte:	cmp  di,bp
	jbe UP
	pop  cx
	ret
LzSSd	endp

BitStore	proc
	push	dx
	xor	dx,dx
tbit:	bt	ax,dx
	inc	dx
	jc	bSetBit
	btr	es:[di],bx
	jmp	xBit
bSetBit:bts	es:[di],bx
xBit:	inc	bx
	cmp	bx,8000h
	jb	bSetOk
	xor	bx,bx
	add	di,4096
bSetOk:	loop	tBit
	pop	dx
	ret
BitStore	endp

GetBit	proc
	push	dx
	xor	dx,dx
	xor	ax,ax
gbit:	bt	[si],bx
	inc	bx
	jnc	gnBit
	bts	ax,dx
gnBit:	inc	dx
	cmp	bx,8000h
	jb	gSetOk
	xor	bx,bx
	add	si,4096
gSetOk:	loop	gBit
	pop	dx
	ret
GetBit	endp