; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;               Channel names storing

;	in:	nick to add
;		channel
;	out:	pointer to name struct

add_chan_nick:	push	esi edi ebx
		mov	esi, [esp+20]
		stdcall	find_chan_nick,[esp+16+4],esi
		or	eax, eax
		jnz	.done
		stdcall	add_chan,[esp+16]	; create a chan if not existend
		mov	ebx, eax
.start:		inc	ebx
		cmp	byte [ebx], 0
		jnz	.start
		inc	ebx
		xor	edi, edi
.size:		inc	edi
		cmp	byte [esi+edi], 0
		jnz	.size
		add	edi, 3
		mov	esi, ebx
.end:		inc	esi
		cmp	dword [esi], 0
		jnz	.end
		add	edi, esi
.loop:		mov	al, [esi]
		mov	[edi], al
		dec	esi
		dec	edi
		cmp	esi, ebx
		jnz	.loop
		mov	al, [esi]
		mov	[edi], al
		mov	dword [esi], "  "
		add	esi, 2
		mov	eax, [esp+20]
		stdcall	copystring,esi,eax
		mov	byte [esi+eax], 0
		lea	eax, [esi-2]
.done:		pop	ebx edi esi
		ret	8

;	in:	nick to remove
;		channel
;	out:	nothing

remove_chan_nick:push	esi edi
		stdcall	find_chan_nick,[esp+12+4],[esp+16]
		or	eax, eax
		jz	.done
		mov	esi, eax
		mov	edi, esi
.end:		inc	esi
		cmp	byte [esi], 0
		jnz	.end
		inc	esi
.loop:		xor	al, al
		xchg	byte [esi], al
		mov	byte [edi], al
		inc	esi
		inc	edi
		cmp	dword [esi], 0
		jnz	.loop
		and	dword [edi], 0
.done:		pop	edi esi
		ret	8

;	in:	nick to find
;		channel
;	out:	pointer to name or zero

find_chan_nick:	push	esi edi ebx
		mov	esi, [esp+16]		; esi = channel string
		stdcall	find_chan, esi
		or	eax, eax
		jz	.done
		xchg	eax, edi
.loop:		xor	eax, eax
		mov	ebx, edi
		cmp	byte [ebx], 1
		jz	.done
		mov	esi, [esp+20]
		add	edi, 2
		stdcall	comparestring,edi,esi
		jz	.found
.next:		inc	edi
		cmp	byte [edi], 0
		jnz	.next
		inc	edi
		jmp	.loop
.found:		mov	eax, ebx
.done:		pop	ebx edi esi
		ret	8

;	in:	channel to add
;	out:	pointer to start of channel data

add_chan:	push	esi edi
		lea	edi, [channelnames]
		mov	esi, [esp+12]
		stdcall	find_chan, esi
		or	eax, eax
		jnz	.done
.endchannels:	cmp	dword [edi], 0
		jz	.endfound
		inc	edi
		jmp	.endchannels
.endfound:	stdcall	copystring, edi, esi
		mov	byte [edi+eax], 0
		mov	byte [edi+eax+1], 1
		and	dword [edi+eax+2], 0
		xchg	eax, edi
.done:		pop	edi esi
		ret	4

;	in:	channel to remove
;	out:	nothing

remove_chan:	push	esi edi
		mov	esi, [esp+12]
		stdcall	find_chan, esi
		or	eax, eax
		jz	.done
		mov	esi, eax
		mov	edi, eax
.findend:	inc	esi
		cmp	byte [esi], 1
		jnz	.findend
		inc	esi
.loop:		xor	al, al
		xchg	al, [esi]
		mov	byte [edi], al
		inc	esi
		inc	edi
		cmp	dword [esi], 0
		jnz	.loop
.done:		pop	edi esi
		ret	4

;	in:	channel to find
;	out:	pointer to start of channel data

find_chan:	push	esi edi
		lea	edi, [channelnames]
		mov	esi, [esp+12]
.cmpchan:	xor	eax, eax
		cmp	byte [edi], 0
		jz	.done
		stdcall	comparestring,edi,esi
		jz	.found
.nextchan:	inc	edi
		cmp	byte [edi], 1
		jnz	.nextchan
		inc	edi
		jmp	.cmpchan
.found:		xchg	eax, edi
.done:		pop	edi esi
		ret	4
