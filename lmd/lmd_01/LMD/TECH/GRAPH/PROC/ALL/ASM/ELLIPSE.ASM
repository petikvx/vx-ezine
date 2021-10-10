title	ellipse.plm
subttl	PLM 1.5  Moscow, 8-Jul-92


.model	tiny, pascal
LOCALS
.code
JUMPS
	.386
	extrn  pascal putpix : near
	PUBLIC	ellipse

ellipse	PROC
	USES	
	ARG	xc:word, yc:word, a0:word, b0:word, color:word
	LOCAL	x:word, y:word
	LOCAL	asqr:dword, tasqr:dword
	LOCAL	bsqr:dword, tbsqr:dword
	LOCAL	d:dword
	LOCAL	deltax:dword, deltay:dword
	mov	x,00h
	mov	deltax,00h
	mov	ax,b0
	mov	y,ax
	cwde
	push	eax
	imul	eax
	mov	bsqr,eax
	sal	eax,1
	mov	tbsqr,eax
	mov	ax,a0
	cwde
	imul	eax
	mov	asqr,eax
	sal	eax,1
	mov	tasqr,eax
	pop	ebx
	imul	ebx
	mov	deltay,eax
	mov	eax,asqr
	mov	ecx,eax
	imul	ebx
	sar	ecx,2
	add	eax,ecx
	sub	eax,bsqr
	neg	eax
	mov	d,eax
first:
	mov	eax,deltax
	cmp	eax,deltay
	jge	@@l1
	push	x
	push	y
	push	xc
	push	yc
	push	color
	call	set4pixels
	cmp	d,00h
	jle	@@l2
	dec	y
	mov	eax,tasqr
	sub	deltay,eax
	mov	eax,deltay
	sub	d,eax
@@l2:
	inc	x
	mov	eax,tbsqr
	add	deltax,eax
	mov	eax,deltax
	add	eax,bsqr
	add	d,eax
	jmp	first
@@l1:
	mov	eax,asqr
	sub	eax,bsqr
	sar	eax,1
	imul	eax,3
	sub	eax,deltax
	sub	eax,deltay
	sar	eax,1
	add	d,eax
@@l3:
	cmp	y,00h
	jl	@@l4
	push	x
	push	y
	push	xc
	push	yc
	push	color
	call	set4pixels
	cmp	d,00h
	jge	@@l5
	inc	x
	mov	eax,tbsqr
	add	deltax,eax
	mov	eax,deltax
	add	d,eax
@@l5:
	dec	y
	mov	eax,tasqr
	sub	deltay,eax
	mov	eax,deltay
	sub	eax,asqr
	sub	d,eax
	jmp	@@l3
@@l4:
	ret
ellipse	ENDP

	PUBLIC	set4pixels

set4pixels	PROC
	USES	
	ARG	x:word, y:word, xc:word, yc:word, color:word
	mov	ax,xc
	add	ax,x
	push	ax
	mov	ax,yc
	add	ax,y
	push	ax
	push	color
	call	putpix
	mov	ax,xc
	sub	ax,x
	push	ax
	mov	ax,yc
	add	ax,y
	push	ax
	push	color
	call	putpix
	mov	ax,xc
	add	ax,x
	push	ax
	mov	ax,yc
	sub	ax,y
	push	ax
	push	color
	call	putpix
	mov	ax,xc
	sub	ax,x
	push	ax
	mov	ax,yc
	sub	ax,y
	push	ax
	push	color
	call	putpix
	ret
set4pixels	ENDP

end	