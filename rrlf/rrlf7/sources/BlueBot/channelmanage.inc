; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;               Channel managing function

	; in:	channel

manage_chan:	lea	eax, [nickname]
		stdcall	find_chan_nick,[esp+4+4],eax
		or	eax, eax
		jz	.end
		cmp	byte [eax+0], "@"		; am I +o ?
		jnz	.end
		stdcall	find_chan,[esp+4]
		xchg	eax, esi
.loop:		cmp	byte [esi], 1
		jz	.end
		cmp	byte [esi+1], "+"
		jnz	.skip
		cmp	byte [esi], " "
		jnz	.skip
		lea	edi, [writebuffer+5]
		mov	dword [edi-5], "MODE"
		mov	byte [edi-1], " "
		stdcall	copystring,edi,[esp+4]
		add	edi, eax
		mov	dword [edi], " +o "
		add	edi, 4
		add	esi, 2
		stdcall	copystring,edi,esi
		mov	dword [edi+eax], 10
		lea	eax, [writebuffer]
		stdcall	sendstring,eax
.skip:		inc	esi
		cmp	byte [esi-1], 0
		jnz	.skip
		jmp	.loop
.end:		ret	4