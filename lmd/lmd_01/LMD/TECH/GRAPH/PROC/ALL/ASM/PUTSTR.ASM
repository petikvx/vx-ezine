title	putstr.plm
subttl	PLM 1.5  Moscow, 8-Jul-92


.model	tiny, pascal
LOCALS
.code
JUMPS
	extrn  pascal putchar : near
	PUBLIC	putstr

putstr	PROC
	USES	ds,si
	ARG	straddr:dword,x:word,y:word,color:word
	cld
	mov	ds,(word ptr straddr+2)
	mov	si,word ptr straddr
	mov	bx,x
	mov	dx,y
	xor	ax,ax
	mov	cx,color
@@l1:
	lodsb
	or	al,al
	je	@@l2
	push	ax
	push	 bx
	push	 dx
	push	 cx
	call	putchar
	add	bx,8
	jmp	@@l1
@@l2:
	ret
putstr	ENDP

end	