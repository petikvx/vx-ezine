title	setdacs.plm
subttl	PLM 1.5  Moscow, 8-Jul-92


.model	tiny, pascal
LOCALS
.code
JUMPS
	.286
	PUBLIC	setdacs

setdacs	PROC
	USES	ds,si
	ARG	first:byte, count:word, addr:dword
	mov	al,first
	mov	dx,3c8h
	out	dx,al
	mov	ds,(word ptr addr+2)
	mov	si,word ptr addr
	inc	dx
	mov	ax,count
	mov	cx,ax
	shl	ax,1
	add	cx,ax
	rep	outsb
	ret
setdacs	ENDP

end	