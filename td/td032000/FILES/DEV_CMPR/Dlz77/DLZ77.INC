; DLZ77 procedures

WinLen	=	4096
xDest	dw	?
xSRC	dw	?
xMinLen	dw	?
xPos	dw	?

DLZ77c	proc			; Packer
	mov	ax,cx
	stosw

	mov 	xDest,di
	mov 	xSRC,si
	mov	al,-1
	stosb
	movsw			; Копируем 8 байт
	movsw
	movsw
	movsw

	mov	bx,di		; Резервируем байт
	stosb
	mov	dh,8
PackLoop:
	mov	xMinLen,0
	push	cx di

	mov	di,xSRC
	mov	ax,si
	sub	ax,di
	cmp	ax,WinLen+WinLen/2
	jb	FullWin
	mov	di,si
	sub	di,WinLen
FullWin:mov	cx,si
	sub	cx,di

FxIt:	push	cx si di
rep	cmpsb
	xchg	ax,cx
	pop	di
	mov	bp,di
	pop	si cx
	sub	ax,cx
	neg	ax
	dec	ax
	cmp	ax,xMinLen
	jle	SkipIt
	cmp	ax,3
	jl	SkipIt
	cmp	ax,100h
	ja	xM
	mov	xMinLen,ax
	mov	xPos,bp
	jmp	SkipIt
xM:	mov	xMinLen,0FFh
	mov	xPos,bp
	jmp	NoScan
SkipIt:	dec	cx
	or	cx,cx
	jz	NoScan
	inc	di
	jmp	FxIt
NoScan:	shl	dl,1
	cmp	xMinLen,0
	jz	NoEq
	mov	ax,xMinLen
	mov	bp,xPos
	jmp	PackIt
NoEq:	pop	di
	movsb
	or	dl,1
	jmp	Flush
PackIt:	pop	di
	stosb
	push	ax
	mov	ax,bp
	sub	ax,xSRC
	stosw
	pop	ax
	add	si,ax
	pop	cx
	sub	cx,ax
	inc	cx
	push	cx
Flush:	dec	dh
	jnz	nByte
	mov	[bx],dl
	xor	dx,dx
	mov	dh,8
	mov	bx,di
	stosb
NByte:	pop	cx
	dec	cx
	jl	AllDone
	jmp	PackLoop
AllDone:mov	[bx],dl
	mov	cx,di
	sub	cx,xDest
	ret
DLZ77c	endp

DLZ77u	proc		; DS:Si - Code
	lodsw
	push	ax
	mov	bx,di
	add	bx,ax
	mov	bp,di
Unp:	lodsb
	mov	dh,9
	mov	dl,al
BitLoop:dec	dh
	jz	Unp
	shl	dl,1
	jnc	NoBit
	movsb
	jmp	xByte
NoBit:	push	cx si
	xor	ax,ax
	lodsb
	push	ax
	lodsw
	add	ax,bp
	xchg	ax,si
	pop	cx
rep	movsb
	pop	si cx
	add	si,3
xByte:	cmp	di,bx
	jb	BitLoop
	pop	cx
	ret
DLZ77u	endp