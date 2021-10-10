; Собственно CRC для подсчета сигнатур

crc		proc
		push	si
		xor	ax,ax
		mov	dx,ax
		xchg	bx,bx
		nop

CrcLoop:	xor	dh,dl
		xor	dl,ah
		xor	ah,al
		mov	al,[si]
		inc	si
		xor	al,dh
		dec	cx
		jnz	CrcLoop

		pop	si
		retn
crc		endp
