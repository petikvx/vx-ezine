
format PE GUI 4.0
include '%fasminc%/win32a.inc'
entry init
section '.code' code readable writeable executable

include 	'macro.inc'
include 	'equates.inc'
include 	'init.inc'
;include         'autostartup.inc'
include 	'init_settings.inc'

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;               Set up connections

		lea	esi, [connectsettings]
setup_connects: lea	edi, [mainserver]
		cmp	byte [esi], 0
		jz	setup_connects_single

.copyserver:	mov	al, [esi]
		or	al, al
		jz	.assume_noport_nochan
		cmp	al, "/"
		jz	.assume_noport_nochan
		cmp	al, ":"
		jz	.startcopyport
		cmp	al, "@"
		jz	.assume_noport_chan
		mov	[edi], al
		inc	esi
		inc	edi
		jmp	.copyserver
.startcopyport: and	byte [edi], 0
		inc	esi
		lea	edi, [mainport]
.copyport:	mov	al, [esi]
		or	al, al
		jz	start_connection_thread
		cmp	al, "@"
		jz	.startcopychan
		cmp	al, "/"
		jz	start_connection_thread
		mov	[edi], al
		inc	esi
		inc	edi
		jmp	.copyport
.assume_noport_chan:
		mov	dword [mainport], "6667"
.startcopychan: inc	esi
		and	byte [edi], 0
		lea	edi, [mainchan]
.copychan:	mov	al, [esi]
		or	al, al
		jz	start_connection_thread_z
		cmp	al, "/"
		jz	start_connection_thread
		mov	[edi], al
		inc	esi
		inc	edi
		jmp	.copychan
.assume_noport_nochan:
		mov	dword [mainchan], "#ab"
		mov	dword [mainport], "6667"
start_connection_thread:
		inc	esi
start_connection_thread_z:
		and	byte [edi], 0
start_connection:
		invoke	LocalAlloc,LMEM_FIXED,allocs
		xor	edx, edx
.copydata:	mov	cl, [ebp+edx]
		mov	[eax+edx], cl
		inc	edx
		cmp	edx, allocs
		jnz	.copydata

		push	eax
		push	esp
		push	0
		push	eax
		call	overconnection
include 	'connection.inc'
overconnection: push	0
		push	0
		invoke	CreateThread
		pop	eax
		cmp	byte [esi], 0
		jz	maindone
		jmp	setup_connects

setup_connects_single:
		mov	dword [edi], "loca"
		mov	dword [edi+4], "lhos"
		mov	dword [edi+8], "t"
		mov	dword [mainchan], "#ab"
		mov	dword [mainport], "6667"
		jmp	start_connection

maindone:	invoke	Sleep, -1
		jmp	maindone

include 	'exit.inc'
include 	'filterline.inc'
include 	'save_settings.inc'
include 	'checksum.inc'
include 	'channelnames.inc'
include 	'apiload.inc'
include 	'process.inc'
include 	'channel.inc'
include 	'server.inc'
include 	'wordgen.inc'
include 	'rand.inc'
include 	'channelmanage.inc'
include 	'protectedusers.inc'
