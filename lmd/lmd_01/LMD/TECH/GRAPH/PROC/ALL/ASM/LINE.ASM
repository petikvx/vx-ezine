title	line.plm
subttl	PLM 1.5  Moscow, 8-Jul-92


.model	tiny, pascal
LOCALS
.code
JUMPS
	extrn  pascal putpix : near
	PUBLIC	line

line	PROC
	USES	si,di
	ARG	x1:word, y1:word, x2:word, y2:word, color:word
	LOCAL	deltax1:word, deltay1:word
	LOCAL	deltax2:word, deltay2:word
	LOCAL	factor1:word, factor2:word
	mov	cx,1
	mov	dx,1
	mov	di,y2
	sub	di,y1
	jge	@@l1
	neg	dx
	neg	di
@@l1:
	mov	deltay1,dx
	mov	si,x2
	sub	si,x1
	jge	@@l2
	neg	cx
	neg	si
@@l2:
	mov	deltax1,cx
	cmp	si,di
	jge	@@l3
	xor	cx,cx
	xchg	si,di
	jmp	savs
@@l3:
	xor	dx,dx
savs:
	mov	deltax2,cx
	mov	deltay2,dx
	mov	ax,di
	shl	ax,1
	mov	factor2,ax
	sub	ax,si
	mov	bx,ax
	sub	ax,si
	mov	factor1,ax
	mov	cx,x1
	mov	dx,y1
	inc	si
	mov	ax,color
putpixel:
	dec	si
	jne	@@l4
	ret
@@l4:
	push	cx
	push	dx
	push	ax
	call	putpix
	or	bx,bx
	jge	@@l5
	add	cx,deltax2
	add	dx,deltay2
	add	bx,factor2
	jmp	putpixel
@@l5:
	add	cx,deltax1
	add	dx,deltay1
	add	bx,factor1
	jmp	putpixel
line	ENDP

end	