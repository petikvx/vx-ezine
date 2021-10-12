
; A pseudo random numbers generator
;  for use with the MuTation Engine <tm>

; Version 1.03 (11-2-92)
; (C) 1991 CrazySoft, Inc.

	.model	tiny
	.code

	public	rnd_init, rnd_get, rnd_buf, data_top

rnd_init:
	push	ds si dx cx bx
	xor	ah,ah
	int	1ah
	in	al,[40h]
	mov	ah,al
	in	al,[40h]
	xor	ax,cx
	xor	dx,ax
	push	cs
	pop	ds
	mov	si,offset rnd_buf
	xor	bh,bh
	jmp	short rnd_put
rnd_get:
	push	ds si dx cx bx
	push	cs
	pop	ds
	mov	si,offset rnd_buf
        mov     bl,[bx]
	xor	bh,bh
	mov	ax,[bx+si+2]
	mov	dx,[bx+si+4]
	add	byte ptr [si],4
        mov     cx,17
rnd_lup:
	shl	ax,1
	rcl	dx,1
	mov	bl,al
	xor	bl,dh
	jns	nxt_bit
	inc	al
nxt_bit:
	loop	rnd_lup
rnd_put:
	mov	bl,[si+1]
	add	bl,4
	mov	[si+1],bl
	mov	al,dl
	cmp	bl,[si]
	jnz	rnd_done
	add	byte ptr [si],4
rnd_done:
	pop	bx cx dx si ds
	ret

	.data

rnd_buf dw	129 dup(?)

data_top:

	end
