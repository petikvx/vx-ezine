title	bar.plm
subttl	PLM 1.5  Moscow, 8-Jul-92


.model	tiny, pascal
LOCALS
.code
JUMPS
	.286
	PUBLIC	bar

bar	PROC
	USES	es,di
	ARG	x1:word, y1:word, x2:word, y2:word, color:byte
	cld
	mov	bx,x1
	mov	ax,y1
	mov	dx,ax
	mov	di,ax
	shl	di,6
	mov	ah,al
	xor	al,al
	add	ax,bx
	add	di,ax
	mov	cx,y2
	sub	cx,dx
	inc	cx
	mov	dx,x2
	sub	dx,bx
	inc	dx
	mov	ax,0a000h
	mov	es,ax
	mov	al,color
	mov	ah,al
	shr	dx,1
	jc	_full
@@l1:
	mov	si,di
	mov	bx,cx
	mov	cx,dx
	rep	stosw
	mov	di,si
	add	di,320
	mov	cx,bx
	loop	@@l1
@@l2:
	ret
_full:
@@l3:
	mov	si,di
	mov	bx,cx
	mov	cx,dx
	rep	stosw
	stosb
	mov	di,si
	add	di,320
	mov	cx,bx
	loop	@@l3
@@l4:
	ret
bar	ENDP

end	