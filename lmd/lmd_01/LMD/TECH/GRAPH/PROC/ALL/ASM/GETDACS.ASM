title	getdacs.plm
subttl	PLM 1.5  Moscow, 8-Jul-92


.model	tiny, pascal
LOCALS
.code
JUMPS
	.286
	PUBLIC	getdacs

getdacs	PROC
	USES	es,di
	ARG	first:byte, count:word, addr:dword
	mov	al,first
	mov	dx,3c7h
	out	dx,al
	mov	es,(word ptr addr+2)
	mov	di,word ptr addr
	inc	dx
	inc	dx
	mov	ax,count
	mov	cx,ax
	shl	ax,1
	add	cx,ax
	rep	insb
	ret
getdacs	ENDP

end	