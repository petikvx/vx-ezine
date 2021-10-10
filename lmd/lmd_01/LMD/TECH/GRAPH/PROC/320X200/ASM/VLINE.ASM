title	vline.plm
subttl	PLM 1.5  Moscow, 8-Jul-92


.model	tiny, pascal
LOCALS
.code
JUMPS
	.286
	PUBLIC	vline

vline	PROC
	USES	es,di
	ARG	x:word, y:word, len:word, color:byte
	cld
	mov	ax,y
	mov	di,ax
	shl	di,6
	mov	ah,al
	xor	al,al
	add	ax,x
	add	di,ax
	mov	ax,0a000h
	mov	es,ax
	mov	al,color
	mov	cx,len
@@l1:
	stosb
	add	di,319
	loop	@@l1
@@l2:
	ret
vline	ENDP

end	