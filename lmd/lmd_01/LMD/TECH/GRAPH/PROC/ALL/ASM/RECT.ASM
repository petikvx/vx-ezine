title	rect.plm
subttl	PLM 1.5  Moscow, 8-Jul-92


.model	tiny, pascal
LOCALS
.code
JUMPS
	extrn  pascal putpix : near
	PUBLIC	rect

rect	PROC
	USES	
	ARG	x1:word, y1:word, x2:word, y2:word, color:byte
	mov	bx,x1
	mov	dx,y1
	mov	al,color
	mov	cx,x2
	sub	cx,x1
	push	cx
@@l1:
	push	bx
	push	 dx
	push	 ax
	call	putpix
	inc	bx
	loop	@@l1
@@l2:
	mov	cx,y2
	sub	cx,y1
@@l3:
	push	bx
	push	 dx
	push	 ax
	call	putpix
	inc	dx
	loop	@@l3
@@l4:
	pop	cx
@@l5:
	push	bx
	push	 dx
	push	 ax
	call	putpix
	dec	bx
	loop	@@l5
@@l6:
	mov	cx,y2
	sub	cx,y1
@@l7:
	push	bx
	push	 dx
	push	 ax
	call	putpix
	dec	dx
	loop	@@l7
@@l8:
	ret
rect	ENDP

end	