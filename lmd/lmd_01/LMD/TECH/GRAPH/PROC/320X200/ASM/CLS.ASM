title	cls.plm
subttl	PLM 1.5  Moscow, 8-Jul-92


.model	tiny, pascal
LOCALS
.code
JUMPS
	.286
	PUBLIC	cls

cls	PROC
	USES	es,di
	ARG	color:byte
	mov	ax,0a000h
	mov	es,ax
	xor	di,di
	mov	al,color
	mov	ah,al
	mov	cx,(320*200/2)
	rep	stosw
	ret
cls	ENDP

end	