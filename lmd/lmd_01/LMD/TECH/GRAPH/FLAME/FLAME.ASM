title	flame.plm
subttl	PLM 1.5  Moscow, 8-Jul-92

 x 	equ	 160
y 	equ	 70
	crlf   equ     0dh, 0ah

.model	tiny, pascal
LOCALS
.code
JUMPS
	org 100h
	.286
	locals _@
flame:
	mov	ax,0013h
	int	10h
	cli
	mov	dx,03c4h
	mov	al,04h
	out	dx,al
	inc	dx
	in	al,dx
	or	al,04h
	and	al,0f7h
	out	dx,al
	mov	dx,03ceh
	mov	al,05h
	out	dx,al
	inc	dx
	in	al,dx
	and	al,0efh
	out	dx,al
	dec	dx
	mov	al,06h
	out	dx,al
	inc	dx
	in	al,dx
	and	al,0fdh
	out	dx,al
	mov	dx,03d4h
	mov	al,14h
	out	dx,al
	inc	dx
	in	al,dx
	and	al,0bfh
	out	dx,al
	dec	dx
	mov	al,17h
	out	dx,al
	inc	dx
	in	al,dx
	or	al,40h
	out	dx,al
	mov	dx,03c4h
	mov	al,01h
	out	dx,al
	inc	dx
	in	al,dx
	or	al,20h
	out	dx,al
	mov	dx,03d4h
	mov	al,09h
	out	dx,al
	inc	dx
	in	al,dx
	and	al,0f0h
	add	al,03h
	out	dx,al
	mov	dx,03c4h
	mov	ax,0f02h
	out	dx,ax
	sti
	mov	ax,0a000h
	mov	es,ax
	xor	di,di
	xor	ax,ax
	mov	cx,(80*100/2)
	rep	stosw
	mov	si,offset cdata
	mov	cx,7
@@l1:
	push	cx
	mov	bx,1
	lodsw
	mov	cx,256
	xchg	ax,cx
	xor	dx,dx
	idiv	cx
	mov	bp,ax
	lodsw
	mov	di,ax
@@l3:
	push	si
	cli
	mov	dx,03c8h
	mov	ax,di
	out	dx,al
	inc	dx
	push	dx
	push	dx
	push	dx
	mov	cx,3
@@l5:
	mov	dx,bx
	lodsw
	imul	dx
	push	cx
	mov	cx,256
	idiv	cx
	pop	cx
	mov	ah,al
	lodsb
	add	al,ah
	pop	dx
	out	dx,al
	loop	@@l5
@@l6:
	sti
	inc	di
	add	bx,bp
	lodsw
	pop	si
	cmp	di,ax
	jbe	@@l3
@@l4:
	pop	cx
	add	si,11
	loop	@@l1
@@l2:
	push	cs
	pop	es
	mov	di,offset startbuffer
	mov	cx,(70*160/2)
	xor	ax,ax
	rep	stosw
	mov	dx,offset int_09h
	mov	ax,3509h
	int	21h
	mov	word ptr [old_int_09h],bx
	mov	word ptr [old_int_09h+2],es
	mov	ah,25h
	int	21h
	mov	al,11111100b
	out	21h,al
	push	cs
	pop	es
	push	cs
	pop	ds
	cli
	mov	dx,03c4h
	mov	al,01h
	out	dx,al
	inc	dx
	in	al,dx
	and	al,0dfh
	out	dx,al
	sti
next:
	mov	dx,03dah
@@l7:
	in	al,dx
	test	al,00001000b
	je	@@l7
@@l8:
	mov	bx,startpos
	add	bx,(y-3)
	cmp	bx,y
	jb	@@l9
	sub	bx,y
@@l9:
	mov	cx,1
@@l10:
	mov	di,offset startbuffer
	mov	ax,x
	mul	bx
	add	di,ax
	add	di,cx
	in	al,40h
	shr	ax,1
	mov	byte ptr ds:[di],255
	jnc	@@l12
	mov	byte ptr ds:[di],20
@@l12:
	inc	cx
	cmp	cx,(x-2)
	jbe	@@l10
@@l11:
	mov	di,offset startbuffer
	push	di
	push	di
	xor	ax,ax
	xor	bx,bx
	add	di,x
	mov	dh,(y-2)
@@l13:
	mov	cx,x
@@l15:
	mov	al,[di]
	add	al,[di+1]
	adc	ah,bl
	add	al,[di-x]
	adc	ah,bl
	add	al,[di+x]
	adc	ah,bl
	shr	ax,2
	je	@@l17
	dec	al
@@l17:
	stosb
	loop	@@l15
@@l16:
	dec	dh
	jne	@@l13
@@l14:
	pop	di
	xor	ax,ax
	mov	cx,x
@@l18:
	mov	al,[di]
	add	al,[di+1]
	adc	ah,bl
	add	al,[di+x*(y-1)]
	adc	ah,bl
	add	al,[di+x]
	adc	ah,bl
	shr	ax,2
	je	@@l20
	dec	al
@@l20:
	stosb
	loop	@@l18
@@l19:
	pop	di
	add	di,(x*(y-1))
	xor	ax,ax
	mov	cx,(x-1)
@@l21:
	mov	al,[di]
	add	al,[di+1]
	adc	ah,bl
	add	al,[di-x*(y-1)]
	adc	ah,bl
	add	al,[di-x]
	adc	ah,bl
	shr	ax,2
	je	@@l23
	dec	al
@@l23:
	stosb
	loop	@@l21
@@l22:
	mov	dx,03c4h
	mov	ax,0302h
	out	dx,ax
	mov	dx,x
	mov	ax,startpos
	imul	dx
	push	ax
	mov	si,ax
	call	drawbuffer
	mov	dx,03c4h
	mov	ax,0c02h
	out	dx,ax
	pop	ax
	mov	si,ax
	inc	si
	call	drawbuffer
	inc	startpos
	cmp	startpos,y
	jne	@@l24
	mov	startpos,00h
@@l24:
	jmp	next
int_09h:
	push	ax
	in	al,60h
	test	al,10000000b
	pop	ax
	je	exit
	db	0eah
old_int_09h	db	4 dup(?)
exit:
	add	sp,6
	lds	dx,dword ptr old_int_09h
	mov	ax,2509h
	int	21h
	xor	al,al
	out	21h,al
	mov	ax,0003h
	int	10h
	int	09h
	mov	ah,09h
	mov	dx,offset copyrightmsg
	push	cs
	pop	ds
	int	21h
finish:
	mov	ax,4c00h
	int	21h
	PUBLIC	drawbuffer

drawbuffer	PROC
	USES	es
	mov	ax,0a000h
	mov	es,ax
	mov	di,(80*35)
	add	si,offset startbuffer
	mov	dx,startpos
	mov	ax,(y-4)
@@l25:
	mov	cx,(x/2)
	push	ax
@@l27:
	movsb
	inc	si
	loop	@@l27
@@l28:
	inc	dx
	cmp	dx,y
	jb	@@l29
	xor	dx,dx
	sub	si,(y*x)
@@l29:
	pop	ax
	dec	ax
	jne	@@l25
@@l26:
	ret
drawbuffer	ENDP

cdata 	label	word
	dw	4,0
	dw	0
	db	0
	dw	0
	db	0
	dw	0
	db	0
	dw	4
	dw	4,5
	dw	0
	db	0
	dw	0
	db	0
	dw	6
	db	0
	dw	9
	dw	35,10
	dw	43
	db	0
	dw	0
	db	0
	dw	-6
	db	6
	dw	45
	dw	29,46
	dw	20
	db	43
	dw	30
	db	0
	dw	10
	db	0
	dw	75
	dw	9,76
	dw	0
	db	63
	dw	30
	db	30
	dw	0
	db	10
	dw	85
	dw	63,86
	dw	0
	db	63
	dw	3
	db	60
	dw	53
	db	10
	dw	149
	dw	105,150
	dw	0
	db	63
	dw	-20
	db	63
	dw	-63
	db	63
	dw	255
copyrightmsg	db	"Flame Copyright (C) 1997 by Scout, SPS.",crlf,"$"
startpos	dw	0
startbuffer	db	x*y dup(?)
end	flame