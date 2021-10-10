title	line.plm
subttl	PLM 1.5  Moscow, 8-Jul-92


.model	tiny, pascal
LOCALS
.code
JUMPS
	.286
	PUBLIC	line

line	PROC
	USES	es,di
	ARG	x1:word, y1:word, x2:word, y2:word, color:byte
	LOCAL	delta1:word, factor1:word
	LOCAL	delta2:word, factor2:word
	cld
	mov	ax,y1
	mov	di,ax
	shl	di,6
	mov	ah,al
	xor	al,al
	add	ax,x1
	add	di,ax
	mov	ax,0a000h
	mov	es,ax
	mov	ax,1
	mov	bx,320
	mov	dx,y2
	sub	dx,y1
	jge	keepy
	neg	bx
	neg	dx
keepy:
	mov	delta1,bx
	mov	cx,x2
	sub	cx,x1
	jge	keepx
	neg	ax
	neg	cx
keepx:
	add	delta1,ax
	cmp	cx,dx
	jge	hors
	xor	ax,ax
	xchg	cx,dx
	jmp	savs
hors:
	xor	bx,bx
savs:
	add	ax,bx
	mov	delta2,ax
	shl	dx,1
	mov	factor2,dx
	sub	dx,cx
	mov	ax,dx
	sub	ax,cx
	mov	factor1,ax
	inc	cx
	mov	al,color
putpixel:
	stosb
	dec	di
	cmp	dx,00h
	jge	dilin
	add	di,delta2
	add	dx,factor2
	loop	putpixel
	ret
dilin:
	add	di,delta1
	add	dx,factor1
	loop	putpixel
	ret
line	ENDP

end	