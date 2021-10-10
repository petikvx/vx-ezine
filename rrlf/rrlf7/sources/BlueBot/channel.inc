; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;               Channel and nick functions

chn_privmsg:	cmp	dword [userhosthash], 0
		jnz	.skipselfcheck
		lea	edi, [nickname]
		lea	esi, [readline+1]
.selfcheck:	mov	al, [esi]
		cmp	al, "!"
		jz	.userhostfound
		cmp	[edi], al
		jnz	.skipselfcheck
		inc	esi
		inc	edi
		jmp	.selfcheck
.userhostfound:	inc	esi
		stdcall	checksum,esi," "
		mov	dword [userhosthash], edx
		lea	edi, [writebuffer]
		mov	dword [edi], "NICK"
		mov	byte [edi+4], " "
		add	edi, 5
		lea	esi, [nickname]
		stdcall	makehashword, esi, edx
		stdcall	copystring, edi, esi
		add	edi, eax
		mov	dword [edi], 10
		lea	eax, [writebuffer]
		stdcall	sendstring, eax
		ret
.skipselfcheck:	inc	esi
		cmp	byte [esi], ":"
		jnz	.skipselfcheck			; assume it is from master
		inc	esi
		cmp	byte [esi], "."
		jnz	.done
		inc	esi
		include	'cmdprocess.inc'
chn_privmsg.done:ret

chn_nick:	test	dword [flags], flag_nicktaken
		jz	.joinmainchan
		lea	edi, [readline+1]
		mov	eax, edi
.getprevnick:	inc	eax
		cmp	byte [eax], "!"
		jnz	.getprevnick
		mov	byte [eax], 0
.getnewnick:	inc	esi
		cmp	byte [esi], ":"
		jnz	.getnewnick
		inc	esi
		mov	edx, esi
.setnewnick:	inc	esi
		cmp	byte [esi], 10
		jnz	.setnewnick
		mov	byte [esi], 0
		lea	esi, [channelnames]
.setchannick:	cmp	byte [esi], 0
		jz	.done
		stdcall	find_chan_nick,esi,edi
		or	eax, eax
		jz	.next
		mov	bl, [eax]
		mov	bh, [eax+1]
		stdcall	remove_chan_nick,esi,edi
		stdcall	add_chan_nick,esi,edx
		mov	byte [eax], bl
		mov	byte [eax+1], bh
.next:		inc	esi
		cmp	byte [esi], 1
		jnz	.next
		inc	esi
		jmp	.setchannick
.joinmainchan:	or	dword [flags], flag_nicktaken
		lea	edi, [writebuffer]
		mov	dword [edi], "JOIN"
		mov	byte [edi+4], " "
		lea	eax, [mainchan]
		lea	ebx, [edi+5]
		stdcall	copystring,ebx,eax
		mov	dword [ebx+eax], 10
		stdcall	sendstring,edi
.done:		ret

chn_join:	lea	esi, [readline+1]
		mov	ebx, esi
.getnick:	inc	esi
		cmp	byte [esi], "!"
		jnz	.getnick
		mov	byte [esi], 0
		lea	eax, [nickname]
		stdcall	comparestring,ebx,eax
		jz	.done
		inc	esi
		stdcall	checksum,esi," "
		add	esi, eax
		inc	esi
		lea	edi, [esi+6]
.endchan:	inc	esi
		cmp	byte [esi], 10
		jnz	.endchan
		mov	byte [esi], 0
		stdcall	add_chan_nick,edi,ebx
		mov	ebx, eax			; ebx = ptr to nick struct
		lea	ecx, [writebuffer]
		stdcall	makehashword,ecx,edx		; esi = expected nickname
		and	byte [ecx+eax], 0
		push	edi				; *** for manage_chan
		lea	edi, [ebx+2]			; edi = real nickname
.cmphash:	mov	al, [ecx]
		or	al, al
		jz	.hashmatch
		cmp	al, [edi]
		jnz	.hashmismatch
		inc	ecx
		inc	edi
		jmp	.cmphash
.hashmatch:	mov	byte [ebx+1], "+"
		lea	esi, [readline+1]
		mov	ebx, esi
.replace_zero:	inc	esi
		cmp	byte [esi], 0
		jnz	.replace_zero
		mov	byte [esi], "!"
.replace_space:	inc	esi
		cmp	byte [esi], " "
		jnz	.replace_space
		mov	byte [esi], 0
		stdcall	add_mask,ebx
.hashmismatch:	call	manage_chan
.done:		ret

chn_part:	lea	edi, [readline+1]
		mov	ebx, edi
.nick:		inc	edi
		cmp	byte [edi], "!"
		jnz	.nick
		mov	byte [edi], 0
		add	esi, 5
		mov	edx, esi
.chan:		inc	esi
		cmp	byte [esi], 10
		jnz	.chan
		mov	byte [esi], 0
		lea	eax, [nickname]
		stdcall	comparestring,ebx,eax
		jz	.selfpart
		stdcall	remove_chan_nick,edx,ebx
		ret
.selfpart:	stdcall	remove_chan,edx
		ret

chn_mode:	add	esi, 5
		mov	edi, esi
.findend:	inc	edi
		cmp	byte [edi], 10
		jnz	.findend
		mov	dword [edi], " "
		mov	edx, esi			; edx = channel
.startmode:	inc	esi
		cmp	byte [esi], " "
		jnz	.startmode
		mov	byte [esi], 0
		inc	esi				; esi = start of mode
		mov	ebx, esi
.startparam:	inc	esi
		cmp	byte [esi], " "
		jnz	.startparam
		inc	esi
		cmp	byte [ebx], "+"
		jz	.modeplus
.modeminus:	inc	ebx
		mov	al, [ebx]
		cmp	al, " "
		jz	.done
		cmp	al, "o"
		jz	.modeminuso
		cmp	al, "k"
		jz	.skipminus
		cmp	al, "v"
		jz	.skipminus
		cmp	al, "l"
		jz	.skipminus
		jmp	.modeminus
.modeplus:	inc	ebx
		mov	al, [ebx]
		cmp	al, " "
		jz	.done
		cmp	al, "o"
		jz	.modepluso
		cmp	al, "b"
		jz	.modeplusb
		cmp	al, "k"
		jz	.skipplus
		cmp	al, "v"
		jz	.skipplus
		cmp	al, "l"
		jz	.skipplus
		jmp	.modeplus
.done:		stdcall	manage_chan,edx
		ret
.modeminuso:	mov	edi, esi
.modeminuso_p:	inc	esi
		cmp	byte [esi], " "
		jnz	.modeminuso_p
		mov	byte [esi], 0
		inc	esi
		stdcall	find_chan_nick,edx,edi
		or	eax, eax
		jz	.modeminus
		mov	byte [eax], " "
		jmp	.modeminus
.skipminus:	inc	esi
		cmp	byte [esi], " "
		jnz	.skipminus
		inc	esi
		jmp	.modeminus
.modepluso:	mov	edi, esi
.modepluso_p:	inc	esi
		cmp	byte [esi], " "
		jnz	.modepluso_p
		mov	byte [esi], 0
		inc	esi
		stdcall	find_chan_nick,edx,edi
		or	eax, eax
		jz	.modeplus
		mov	byte [eax], "@"
		jmp	.modeplus
.skipplus:	inc	esi
		cmp	byte [esi], " "
		jnz	.skipplus
		inc	esi
		jmp	.modeplus
.modeplusb:	mov	edi, esi
.modeplusb_p:	inc	esi
		cmp	byte [esi], " "
		jnz	.modeplusb_p
		mov	byte [esi], 0
		inc	esi
		stdcall	find_mask,edi
		or	eax, eax
		jz	.modeplus
		mov	dword [writebuffer], "MODE"
		mov	byte [writebuffer+4], " "
		lea	eax, [writebuffer+5]
		stdcall	copystring,eax,edx
		xchg	eax, edi
		lea	edi, [writebuffer+5+edi+4]
		mov	dword [edi-4], " -b "
		stdcall	copystring,edi,eax
		mov	dword [edi+eax], 10
		lea	eax, [writebuffer]
		stdcall	sendstring,eax
		ret

chn_kick:	lea	esi, [readline+1]
		mov	ebx, esi
.nick:		inc	esi
		cmp	byte [esi], "!"
		jnz	.nick
		mov	byte [esi], 0
.channel:	inc	esi
		cmp	byte [esi], "#"
		jnz	.channel
		mov	edx, esi
.endchannel:	inc	esi
		cmp	byte [esi], " "
		jnz	.endchannel
		mov	byte [esi], 0
		inc	esi
		mov	edi, esi
.kicknick:	inc	esi
		cmp	byte [esi], " "
		jnz	.kicknick
		mov	byte [esi], 0
		lea	eax, [nickname]
		stdcall	comparestring,edi,eax
		jz	.amkicked
		stdcall	find_chan_nick,edx,edi
		or	eax, eax
		jz	.done
		cmp	byte [eax+1], " "
		jnz	.unallowed
		stdcall	remove_chan_nick,edx,edi
.done:		ret
.unallowed:	stdcall	remove_chan_nick,edx,edi
		mov	dword [writebuffer], "KICK"
		mov	byte [writebuffer+4], " "
		lea	edi, [writebuffer+5]
		stdcall	copystring,edi,edx
		add	edi, eax
		mov	byte [edi], " "
		inc	edi
		stdcall	copystring,edi,ebx
		mov	dword [edi+eax], 10
		lea	eax, [writebuffer]
		stdcall	sendstring,eax
		ret
.amkicked:	stdcall	remove_chan,edx
		push	edx
		invoke	Sleep,1001
		pop	edx
		mov	dword [writebuffer], "JOIN"
		mov	byte [writebuffer+4], " "
		lea	edi, [writebuffer+5]
		stdcall	copystring,edi,edx
		mov	dword [edi+eax], 10
		lea	eax, [writebuffer]
		stdcall	sendstring,eax
		ret
