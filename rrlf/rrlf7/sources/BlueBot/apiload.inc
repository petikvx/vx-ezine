; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;               Api checksum lookup function

lookupapi:	pushad
		mov	ebx, edi
		add	edi, [edi+60]
		mov	edx, [edi+120]	; edx = export table rva
		add	edx, ebx	; edx = export table va
		mov	eax, [edx+32]	; eax = rva to function names
		add	eax, ebx	; eax = va to function names
		mov	edi, [edx+36]	; edi = rva to name ordinals
		add	edi, ebx	; edi = va to name ordinals
		mov	edx, [edx+28]	; edx = rva to function addresses
		add	edx, ebx	; edx = va to function addresses
		sub	ecx, ecx	; ecx = 0
		dec	ecx
load_apis:	inc	ecx
first_load:	push	edx
		push	eax
		push	esi
		mov	esi, [eax]	; esi = rva to function name
		add	esi, ebx	; esi = va to function name
		sub	eax, eax	; eax = 0
		xor	edx, edx	; cdq edx = 0
.checksum:	mov	al, [esi]
		inc	esi
		add	edx, eax
		rol	edx, 5
		or	al, al
		jnz	.checksum	; edx = checksum of api
		pop	esi
		pop	eax
		add	eax, 4		; move up va to function names
		cmp	esi, edx	; found?
		pop	edx
		jnz	load_apis	; if not, try more
		movzx	eax, word [edi+ecx*2] ; eax = function ordinal
		mov	eax, [edx+eax*4] ; eax = function address
		add	eax, ebx	; fix to base
		mov	[esp+7*4], eax	; save
		popad
		ret