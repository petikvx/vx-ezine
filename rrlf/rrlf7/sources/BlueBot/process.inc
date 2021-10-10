; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;		Server response processor

processline:	lea	esi, [readline]
		push	esi
.end:		inc	esi
		cmp	byte [esi], 13
		jz	.endfound
		cmp	byte [esi], 10
		jnz	.end
.endfound:	mov	dword [esi], 10
		pop	esi
.command:	inc	esi
		cmp	byte [esi], " "
		jnz	.command
		inc	esi
		;mov	eax, 47b3a89fh
		;xor	eax, dword [esi]
		mov	eax, dword [esi]
		imul	eax, 07B63002Fh
		cmpx	eax, "001 "
		jz	srv_welcome
		cmpx	eax, "433 "
		jz	srv_nickinuse
		cmpx	eax, "352 "
		jz	srv_whoreply
		cmpx	eax, "353 "
		jz	srv_namereply
		cmpx	eax, "PRIV"
		jz	chn_privmsg
		cmpx	eax, "NICK"
		jz	chn_nick
		cmpx	eax, "JOIN"
		jz	chn_join
		cmpx	eax, "PART"
		jz	chn_part
		cmpx	eax, "MODE"
		jz	chn_mode
		cmpx	eax, "KICK"
		jz	chn_kick
		ret