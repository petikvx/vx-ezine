; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;               Random

initrand:	mov	eax, [esp+4]
		imul	eax, 842c4ad1h
		mov	dword [rseed], eax
		ret	4

rand:		mov	eax, [rseed]
		xor	eax, 5c93f8ah
		rol	eax, 7
		bswap	eax
		add	[rseed], eax
		ret

randrange:	push	edx
		xor	edx, edx
		call	rand
		div	dword [esp+8]
		xchg	eax, edx
		pop	edx
		ret	4

brandrange:	mov	eax, [esp+8]
		sub	eax, [esp+4]
		stdcall	randrange, eax
		add	eax, [esp+4]
		ret	8
