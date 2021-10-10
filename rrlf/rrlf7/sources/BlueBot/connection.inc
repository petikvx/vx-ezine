; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;               Connect to server

		mov	ebp, [esp+4]
server: 	invoke	socket,AF_INET,SOCK_STREAM,0
		mov	[hsock], eax
		inc	eax
		jz	closewsa

		lea	eax, [sockaddr]
		mov	dword [eax], 00b1a0002h 	; port 6667 / AF_INET
		mov	dword [eax+4], 0100007Fh	; localhost (0AC87E50h)
		;mov     dword [eax+4], 0AC87E50h
		invoke	connect,[hsock],eax,16
		dec	eax
		jz	exitsocket

		invoke	GetTickCount
		stdcall initrand,eax

		lea	edi, [writebuffer]
		mov	dword [edi], "USER"
		mov	byte [edi+4], " "
		add	edi, 5
		stdcall brandrange,6,11
		stdcall makeword,edi,eax
		add	edi, eax
		mov	dword [edi], " 8 "
		add	edi, 3
		stdcall brandrange,6,11
		stdcall makeword,edi,eax
		add	edi, eax
		mov	byte [edi], "@"
		inc	edi
		stdcall brandrange,6,12
		stdcall makeword,edi,eax
		add	edi, eax
		mov	dword [edi], ".com"
		mov	byte [edi+4], " "
		add	edi, 5
		stdcall brandrange,6,11
		stdcall makeword,edi,eax
		mov	dword [edi+eax], 10
		lea	eax, [writebuffer]
		stdcall sendstring, eax

		lea	edi, [writebuffer]
		mov	dword [edi], "NICK"
		mov	byte [edi+4], " "
		add	edi, 5
		stdcall brandrange,5,9
		lea	esi, [nickname]
		stdcall makeword,esi,eax
		stdcall copystring,edi,esi
		mov	dword [edi+eax], 10

		lea	eax, [writebuffer]
		stdcall sendstring, eax

main:		call	fillqueue
		jz	mainend
mainloop:	lea	edi, [readline]
recvline:	mov	al, [esi]
		mov	[edi], al
		inc	esi
		inc	edi
		dec	ecx
		jnz	recvleft
		call	fillqueue
		jz	mainend
recvleft:	cmp	al, 10
		jnz	recvline
		mov	byte [edi], 0
		pushad
		call	filterline
		popad
		cmp	byte [esi], 0
		jnz	mainloop
		jmp	main
fillqueue:	lea	esi, [readqueue]
		pushad
		mov	ecx, 1024/4
clearqueue:	and	dword [esi+ecx*4-4], 0
		dec	ecx
		jnz	clearqueue
		invoke	recv,[hsock],esi,1024,0
		or	eax, eax
		popad
		mov	ecx, 1024
mainend:	ret

exitsocket:	invoke	closesocket,[hsock]
		invoke	Sleep,1000
		jmp	server

