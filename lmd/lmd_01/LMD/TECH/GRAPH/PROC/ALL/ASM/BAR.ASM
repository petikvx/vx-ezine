title	bar.plm
subttl	PLM 1.5  Moscow, 8-Jul-92


.model	tiny, pascal
LOCALS
.code
JUMPS
	extrn  pascal putpix : near
	PUBLIC	bar

bar	PROC
	USES	di
	ARG	x1:word, y1:word, x2:word, y2:word, color:word
	mov	dx,y1
	mov	bx,x1
	mov	ax,x2
	inc	ax
	sub	ax,bx
	mov	di,color
	mov	cx,y2
	sub	cx,dx
	inc	cx
@@l1:
	push	cx
	push	bx
	mov	cx,ax
@@l3:
	push	bx
	push	 dx
	push	 di
	call	putpix
	inc	bx
	loop	@@l3
@@l4:
	pop	bx
	pop	cx
	inc	dx
	loop	@@l1
@@l2:
	ret
bar	ENDP

end	