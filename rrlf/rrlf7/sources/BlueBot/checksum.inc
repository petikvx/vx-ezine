; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;               Checksumming function

	; in:	push byte to checksum to
	;	push ptr to string
	; out:	eax = length checksummed
	;	edx = checksum

checksum:	push	esi ecx ebx edi
		xor	edx, edx
		xor	eax, eax
		mov	ebx, [esp+4*4+4+4]
		mov	esi, [esp+4*4+4+0]
.loop:		mov	bh, [esi+eax]
		cmp	bh, bl
		jz	.done
		mov	ecx, 8
.byteloop:	shr	bh, 1
		jnc	.nobit
		xor	edx, 74AA638Eh
.nobit:		add	edx, 3E45CF73h
		rol	edx, 9
		imul	edx, 2F79E5C9h
		dec	ecx
		jnz	.byteloop
		inc	eax
		jmp	.loop
.done:		pop	edi ebx ecx esi
		ret	8