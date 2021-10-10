title	vexample.plm
subttl	PLM 1.5  Moscow, 8-Jul-92

_videomode 	equ	 0449h
_columns 	equ	 044ah
_rows  	equ	 0484h
_videooffset 	equ	 044eh
_videopage 	equ	 0462h

.model	tiny, pascal
LOCALS
.code
JUMPS
	org    100h
vexample:
	locals _@
	jmp	initialize
flags	db	00000000b
videopage	db	?
columns	dw	?
rows	dw	?
videooffset	dw	?
oldcursor	dd	?
	PUBLIC	main

main	PROC
	USES	ds,es,ax,bx,cx,dx
	push	cs
	pop	ds
	xor	ax,ax
	mov	es,ax
	test	flags,00001000b
	je	@@l1
	mov	dx,03ceh
	in	al,dx
	mov	ah,al
	mov	al,6
	out	dx,al
	inc	dx
	in	al,dx
	dec	dx
	test	al,1
	mov	al,ah
	out	dx,al
	jne	error
	jmp	@@l2
@@l1:
	mov	al,byte ptr es:[_videomode]
	cmp	al,3
	jbe	chkok
	cmp	al,7
	je	chkok
error:
	mov	ax,0e07h
	int	10h
	jmp	exitmain
chkok:
@@l2:
	mov	ax,es:[_videooffset]
	mov	videooffset,ax
	mov	ax,es:[_columns]
	shl	ax,1
	mov	columns,ax
	mov	al,es:[_rows]
	xor	ah,ah
	cmp	al,24
	jae	@@l3
	mov	al,24
@@l3:
	inc	ax
	mov	rows,ax
	mov	al,es:[_videopage]
	mov	videopage,al
	test	byte ptr es:[0463h],01000000b
	mov	ax,0b800h
	jne	@@l4
	mov	ax,0b000h
@@l4:
	mov	es,ax
	mov	ah,03h
	mov	bh,videopage
	int	10h
	mov	word ptr oldcursor,cx
	mov	(word ptr oldcursor+2),dx
	mov	cx,2000h
	mov	ah,01h
	int	10h
	mov	ax,2
	int	33h
	cld
	mov	cx,word ptr oldcursor
	mov	ah,01h
	int	10h
	mov	ah,02h
	mov	bh,videopage
	mov	dx,(word ptr oldcursor+2)
	int	10h
	mov	ax,1
	int	33h
exitmain:
	ret
main	ENDP

initialize:
	mov	ax,1a00h
	int	10h
	cmp	al,1ah
	jne	@@l5
	cmp	bl,8
	jne	@@l5
	or	flags,00001000b
@@l5:
	ret
end	vexample