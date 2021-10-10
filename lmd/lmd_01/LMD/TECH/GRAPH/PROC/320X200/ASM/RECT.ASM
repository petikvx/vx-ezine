title	rect.plm
subttl	PLM 1.5  Moscow, 8-Jul-92


.model	tiny, pascal
LOCALS
.code
JUMPS
	.286
	PUBLIC	rect

rect	PROC
	USES	es,di
	ARG	x1:word, y1:word, x2:word, y2:word, color:byte
	cld
	mov	bx,x1
	mov	ax,y1
	mov	cx,ax
	mov	di,ax
	shl	di,6
	mov	ah,al
	xor	al,al
	add	ax,bx
	add	di,ax
	mov	dx,y2
	sub	dx,cx
	mov	cx,x2
	sub	cx,bx
	mov	ax,0a000h
	mov	es,ax
	mov	al,color
	mov	ah,al
	shr	cx,1
	mov	bx,cx
	rep	stosw
	jc	_full
	mov	cx,dx
@@l1:
	stosb
	add	di,319
	loop	@@l1
@@l2:
	mov	cx,bx
	dec	di
	std
	rep	stosw
	cld
	inc	di
	mov	cx,dx
@@l3:
	stosb
	sub	di,321
	loop	@@l3
@@l4:
	ret
_full:
	stosb
	mov	cx,dx
@@l5:
	stosb
	add	di,319
	loop	@@l5
@@l6:
	mov	cx,bx
	dec	di
	std
	rep	stosw
	inc	di
	stosb
	cld
	mov	cx,dx
@@l7:
	stosb
	sub	di,321
	loop	@@l7
@@l8:
	ret
rect	ENDP

end	