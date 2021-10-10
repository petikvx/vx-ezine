; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;               Word generator

	;	push hash
	;	push ptr to output

makehashword:	push	ecx
		mov	eax, [esp+8+4]
		mov	ecx, eax
		and	ecx, 011b
		add	ecx, 5
		shr	eax, 2
		push	ecx
		push	dword [esp+4+4+4]
		call	makeword.in
		pop	ecx
		ret	8

	;	push nicklen
	;	push ptr to output

makeword:	call	rand
makeword.in:	push	ecx edi ebx edx
		mov	edi, [esp+20]
		mov	ecx, [esp+24]
		xchg	eax, ebx
		stdcall	.nexthash3,3
		dec	edi
.loop:		inc	edi
		dec	eax
		jz	.gen1
		dec	eax
		jz	.gen2
.gen0:		stdcall	.nexthash7, 5
		mov	al, byte [worddata+eax]
		mov	byte [edi], al
		stdcall	.nexthash3, 2
		inc	eax
		cmp	ecx, 2
		jnz	.next
		mov	eax, 2
		jmp	.next
.gen1:		stdcall	.nexthash3, 3
		mov	al, byte [worddata+5+eax]
		mov	byte [edi], al
		xor	eax, eax
		jmp	.next
.gen2:		stdcall	.nexthash7, 4
		mov	al, byte [worddata+8+eax]
		mov	byte [edi], al
		stdcall	.nexthash3, 2
		cmp	ecx, 2
		jz	.next
		xor	eax, eax
.next:		dec	ecx
		jnz	.loop
		sub	edi, [esp+20]
		xchg	eax, edi
		pop	edx ebx edi ecx
		ret	8

.nexthash3:	mov	eax, ebx
		rol	ebx, 2
		and	eax, 3
		jmp	.mainnexthash
.nexthash7:	mov	eax, ebx
		rol	ebx, 3
		and	eax, 7
.mainnexthash:	xor	edx, edx
		div	dword [esp+4]
		xchg	eax, edx
		ret	4
