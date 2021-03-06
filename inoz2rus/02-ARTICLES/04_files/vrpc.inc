include util.inc
include api_const.inc

; ���������, ������� ����� ������� �� ���������� ������
VRPC_server_mem_map struc
	vrpc_mem_addr		sockaddr_in		<>
	vrpc_mem_sock		dd				?
	vrpc_mem_csock		dd				?	
	vrpc_mem_kind		db				?
	vrpc_mem_conv		db				?
	vrpc_mem_fn			dd				?
	vrpc_mem_pcnt		db				?
	vrpc_mem_prms		dd				32 dup (?)
	vrpc_mem_fnn		db				32 dup (?)
	vrpc_mem_lib		db				256 dup (?)
		
	vrpc_mem_buf		db				?
ends

VRPC_call_struct struc
	; ��������� �� ��� ����������, � ����� �� �����
	vrpc_call_lib		dd				?
	; ��� ���������� �������
	vrpc_call_kind		db				?
	; ��������� ������ aka ������
	vrpc_call_cnv		db				?
	vrpc_call_addr		sockaddr_in		<>
ends

VRPC_connect proc
	clc
	; ��������� �����
	push	IPPROTO_IP
	push	SOCK_STREAM
	push	PF_INET
	api		socket, LIB_SOCK
	cmp		EAX, INVALID_SOCKET
	jz		VRPC_connect_exit_err
	mov		EBX, EAX
	
	mov		[EDI.vrpc_call_addr.sin_family], PF_INET
	push	SIZE sockaddr_in
	lea		EAX, [EDI.vrpc_call_addr]
	push	EAX
	push	EBX
	api		connect, LIB_SOCK
	or		EAX, EAX
	jz		VRPC_connect_succ
	
VRPC_connect_close_err:
	push	EBX
	api		closesocket, LIB_SOCK
	
VRPC_connect_exit_err:
	stc
	
VRPC_connect_succ:
	ret		
endp VRPC_connect

vrpc_call proc
; IN:  EDI -> ��������� ������ (VRPC_call_struct)
;	   ESI -> ��� �������, � ����� �� �����
;	   ECX = ���-�� ����������
;	   � ����� ��������� ��� ���������� �������
;
; OUT: EAX = �������� ������� ������� ������� �� ������� �������
; �������� EAX, ECX, ESI
; ��� ������ ������������� carry ���� (CF)

	push	EDX
	push	EBX
	push	ECX

	clc	
	
	call	VRPC_connect
	jc		VRPC_call_exit
	
	; ������� -- �����
	mov		AL, 2
	call	VRPC_send_byte
	jc		VRPC_call_close
	; ��� �������
	mov		AL, [EDI.vrpc_call_kind]
	call	VRPC_send_byte
	jc		VRPC_call_close	
	; ��������� ������
	mov		AL, [EDI.vrpc_call_cnv]
	call	VRPC_send_byte
	jc		VRPC_call_close
	; ������ ����� �������
	push	ESI
	api		lstrlen, LIB_KERN
	call	VRPC_send_dword
	jc		VRPC_call_close

	; ���-�� ����������, �����-�� ������ ������ ECX � � ���� ���� ���: socket
	; ����, ��� � EDX
	pop		ECX
	push	ECX
	mov		AL, CL
	call	VRPC_send_byte
	jc		VRPC_call_close
	
	; ���������
VRPC_call_next_param:	
	or		CL, CL
	jz		VRPC_call_params_sent
	mov		EAX, [ESP + ECX * 4 + 3*4]
	call	VRPC_send_dword
	jc		VRPC_call_close
	dec		CL
	jmp		VRPC_call_next_param
	
VRPC_call_params_sent:

	mov		AL, [EDI.vrpc_call_cnv]
	test	AL, AL
	; ���, ��� ������� �� �������, ������
	; ����� ������� � ���������� �� �����
	jnz		VRPC_call_get_result
	
	; ��� �������
	push	ESI
	api		lstrlen, LIB_KERN
	mov		ECX, EAX
	push	EDI
	mov		EDI, ESI
	call	VRPC_send_buf
	pop		EDI	
	jc		VRPC_call_close
	
	; ������ ����� ���������� � ���� ���
	push	EDI
	mov		EDI, [EDI.vrpc_call_lib]
	push	EDI
	api		lstrlen, LIB_KERN
	mov		ECX, EAX
	call	VRPC_send_byte
	call	VRPC_send_buf
	pop		EDI
	jc		VRPC_call_close	
	
VRPC_call_get_result:	
	
	; �������� ���������
	call	VRPC_recv_dword
	jmp		VRPC_call_close
	
VRPC_call_close_err:	
	stc

VRPC_call_close:
	push	EAX
	push	EBX
	api		closesocket, LIB_SOCK
	pop		EAX
	jnc		VRPC_call_exit
	
VRPC_call_exit_err:
	stc
	
VRPC_call_exit:
	; �������� 
	pop		ECX
	pop		EBX
	pop		EDX
	pop		ESI
	dec		ECX
	shl		ECX, 2	
	mov		[ESP + ECX], ESI
	lea		ESP, [ESP + ECX]
	ret
endp vrpc_call

vrpc_write proc
; IN:	ESI -> ������ �����
;		EDI -> ��������� ������ (VRPC_call_struct) 
;		EAX = ����� �� ������� ���� ��������
;		ECX = ������� �����

	push	EDX
	push	EBX
	push	EBP
	mov		EBP, EAX
	push	ECX
		
	call	VRPC_connect
	jc		vrpc_write_exit
	
	; ������
	mov		AL, 0
	call	VRPC_send_byte
	jc		vrpc_write_exit

	mov		EAX, EBP	
	call	VRPC_send_dword
	jc		vrpc_write_exit
	
	pop		EAX
	push	EAX
	call	VRPC_send_dword
	jc		vrpc_write_exit
	
	pop		ECX
	push	ECX
	xchg	ESI, EDI
	call	VRPC_send_buf
	xchg	ESI, EDI

vrpc_write_exit:
	push	EBX
	api		closesocket, LIB_SOCK

	pop		ECX
	pop		EBP	
	pop		EBX
	pop		EDX
	ret
endp vrpc_write

vrpc_read proc
; IN:	ESI -> ���� ��������
;		EDI -> ��������� ������ (VRPC_call_struct) 
;		EAX = ����� �� ������� ������ �����
;		ECX = ������� �����

	push	EDX
	push	EBX
	push	EBP
	mov		EBP, EAX
	push	ECX
		
	call	VRPC_connect
	jc		vrpc_read_exit
	
	; ������
	mov		AL, 1
	call	VRPC_send_byte
	jc		vrpc_read_exit

	mov		EAX, EBP	
	call	VRPC_send_dword
	jc		vrpc_read_exit
	
	pop		EAX
	push	EAX
	call	VRPC_send_dword
	jc		vrpc_read_exit
	
	pop		ECX
	push	ECX
	xchg	ESI, EDI
	call	VRPC_recv_buf
	xchg	ESI, EDI

vrpc_read_exit:
	push	EBX
	api		closesocket, LIB_SOCK

	pop		ECX
	pop		EBP	
	pop		EBX
	pop		EDX
	ret
endp vrpc_read

VRPC_recv_buf proc
; ��������� ������ �� ������
; EBX = ����� ������
; ECX = ������� ������
; EDI -> ���� ������

	push	EDI
	
VRPC_recv_next:

	push	ECX
	push	EBX
	push	EDI
	
	; �������� ������
	xor		EAX, EAX
	push	EAX
	push	ECX
	push	EDI
	push	EBX
	api		recv, LIB_SOCK
	pop		EDI
	pop		EBX
	pop		ECX
	test	EAX, EAX
	; ���� ��� ������, ���� ���������, ���� ���������
	jz		VRPC_check_error
	
	sub		ECX, EAX
	; ��� ��������, ������
	jz		VRPC_no_error
	add		EDI, EAX
	; ��� ����-�� ��������
	jmp		VRPC_recv_next
	
VRPC_no_error:
	pop		EDI
	clc
	ret
	
VRPC_check_error:

	api		WSAGetLastError, LIB_SOCK
	test	EAX, EAX
	; ������ ���, ������ �������� ������
	jz		VRPC_no_error
	pop		EDI	
	stc
	ret
	
endp VRPC_recv_buf


VRPC_recv_byte proc
; �����, ��������� ������ �����
	push	EDI
	push	ECX
	push	EAX
	mov		EDI, ESP
	xor		ECX, ECX
	inc		ECX
	call	VRPC_recv_buf
	pop		EAX
	pop		ECX
	pop		EDI
	ret
endp VRPC_recv_byte

VRPC_recv_dword proc
; �����, ��������� ������ ������
	push	EDI
	push	ECX
	push	EAX
	mov		EDI, ESP
	xor		ECX, ECX
	mov		CL, 4
	call	VRPC_recv_buf
	pop		EAX	
	pop		ECX
	pop		EDI
	ret
endp VRPC_recv_dword


VRPC_send_buf proc
; �������� ������ � �����
; EBX = ����� ������
; ECX = ������� ����������
; EDI -> ������ �����

	push	ECX
	xor		EAX, EAX
	push	EAX
	push	ECX
	push	EDI
	push	EBX
	api		send, LIB_SOCK
	pop		ECX
	cmp		EAX, ECX
	; ���� ��������� ������� ������� ������ ������ ���
	jz		VRPC_send_buf_no_error
	stc
	ret
	
VRPC_send_buf_no_error:

	clc
	ret
endp VRPC_send_buf


VRPC_send_byte proc
; �����, �������� ������ �����
	push	EDI
	push	ECX	
	push	EAX
	mov		EDI, ESP
	xor		ECX, ECX
	inc		CL
	call	VRPC_send_buf
	pop		EAX
	pop		ECX	
	pop		EDI
	ret
endp VRPC_send_byte


VRPC_send_dword proc
; �����, �������� ������ ������
	push	EDI
	push	ECX	
	push	EAX
	mov		EDI, ESP
	xor		ECX, ECX
	mov		CL, 4
	call	VRPC_send_buf
	pop		EAX
	pop		ECX	
	pop		EDI
	ret
endp VRPC_send_dword


VRPC_find_proc proc
	lea		EDI, [EBP.vrpc_mem_lib]
	push	EDI
	api		LoadLibraryA, LIB_KERN
	or		EAX, EAX
	jz		VRPC_find_proc_exit
	
	lea		EDI, [EBP.vrpc_mem_fnn]
	push	EDI
	push	EAX
	api		GetProcAddress, LIB_KERN
	
VRPC_find_proc_exit:
	ret
	
endp VRPC_find_proc

VRPC_do_stdcall proc
; ���������� ����� � ������� stdcall, �� �� WINAPI
    push    EBX
    mov     EBX, EAX
    xor		ECX, ECX
    mov		CL, [EBP.vrpc_mem_pcnt]
    test    ECX, ECX
    jz      stdcall_call_func

    lea		EDX, [EBP.vrpc_mem_prms]
    dec		ECX
    mov     EAX, ECX
    shl     EAX, 2
    add     EDX, EAX
    inc     ECX
stdcall_push_next:
    push    4 ptr [EDX]
    sub     EDX, 4
    loop    stdcall_push_next
stdcall_call_func:
    call    EBX
    pop     EBX
	ret
endp VRPC_do_stdcall

VRPC_do_cdecl proc
; ���������� ����� � ������� cdecl
    push    EBX
    push    EDI
    mov     EDI, EAX
    xor		ECX, ECX
    mov		CL, [EBP.vrpc_mem_pcnt]
    mov     EBX, ECX

    test    ECX, ECX
    jz      cdecl_call_func
    
    lea		EDX, [EBP.vrpc_mem_prms]
    dec		ECX
    mov     EAX, ECX
    shl     EAX, 2
    add     EDX, EAX
    inc     ECX
cdecl_push_next:
    push    4 ptr [EDX]
    sub     EDX, 4
    loop    cdecl_push_next
cdecl_call_func:
    call    EDI

    ; stack clean-up
    shl     EBX, 2
    add     ESP, EBX

	pop     EDI
    pop     EBX
	ret
endp VRPC_do_cdecl

VRPC_do_fast proc
; ���������� ����� � ������� fastcall, �� �� register
    push    EBX
    push    EDI
    push    ESI
    
    mov     EBX, EAX
    xor		ECX, ECX
    mov		CL, [EBP.vrpc_mem_pcnt]
    mov     EDI, ECX
	lea		EDX, [EBP.vrpc_mem_prms]    
    mov     ESI, EDX

    test    EDI, EDI
    jz      fast_call_func

    ; EAX
    mov     EAX, 4 ptr [ESI]
    dec     EDI
    jz      fast_call_func

    ; EDX
    add     ESI, 4
    mov     EDX, 4 ptr [ESI]
    dec     EDI
    jz      fast_call_func

    ; ECX
    add     ESI, 4
    mov     ECX, 4 ptr [ESI]
    dec     EDI
    jz      fast_call_func

fast_push_next:
    add     ESI, 4
    push    4 ptr [ESI]
    dec     EDI
    jnz     fast_push_next
    
fast_call_func:
    call    EBX
    pop     ESI
    pop     EDI
    pop     EBX

	ret
endp VRPC_do_fast

VPRC_do_action proc
	; �������� ����� ������
	mov		EBX, EAX
	
	; ������� ����, ������� �������� ��� ���������
	; �������: ������, ������ ��� ���������
	call	VRPC_recv_byte
	
	test	AL, AL
	jnz		VRPC_test_for_read
	
	; ������
	; ������ ����� ������
	call	VRPC_recv_dword
	jc		VRPC_close_sock
	
	; ���� ����� ����� ���� �� ����� �� ���������� ������
	test	EAX, EAX
	jnz		VRPC_buf_write_is_set
	lea		EAX, [EBP.vrpc_mem_buf]
	
VRPC_buf_write_is_set:

	; ������ ������� ��������� ������
	mov		EDI, EAX
	call	VRPC_recv_dword
	jc		VRPC_close_sock
	
	; ������ ������ ���-��
	mov		ECX, EAX
	call	VRPC_recv_buf

	jmp		VRPC_close_sock	
	
VRPC_test_for_read:
	dec		AL
	jnz		VRPC_test_for_exec
	
	; ������
	
	call	VRPC_recv_dword
	jc		VRPC_close_sock
	
	; ���� ����� ����� ���� �� ������ �� ����������� ������
	test	EAX, EAX
	jnz		VRPC_buf_read_is_set
	lea		EAX, [EBP.vrpc_mem_buf]
	
VRPC_buf_read_is_set:

	; ������ ������� ��������� ������
	mov		EDI, EAX
	call	VRPC_recv_dword
	jc		VRPC_close_sock
	
	; ���������� ������ ���-��
	mov		ECX, EAX
	call	VRPC_send_buf

	jmp		VRPC_close_sock	
	
VRPC_test_for_exec:
	dec		AL
	jnz		VRPC_close_sock
	
	; ����������
	
	; ������ ����� �����
	lea		EDI, [EBP.vrpc_mem_kind]
	; kind, conv, fn, pcnt
	mov		ECX, 1 + 1 + 4 + 1
	call	VRPC_recv_buf
	jc		VRPC_close_sock
	
	; �������� ���������
	xor		ECX, ECX
	mov		CL, [EBP.vrpc_mem_pcnt]
	lea		EDI, [EBP.vrpc_mem_prms]
	
VRPC_recv_param:
	or		ECX, ECX
	jz		VRPC_no_more_params
	call	VRPC_recv_dword
	jc		VRPC_close_sock
	mov		[EDI], EAX
	add		EDI, 4
	dec		ECX
	jmp		VRPC_recv_param

VRPC_no_more_params:
	; ��� �� ���?
	mov		AL, [EBP.vrpc_mem_kind]
	test	AL, AL
	jnz		VRPC_test_internal
	
	; ��� �������
	mov		ECX, [EBP.vrpc_mem_fn]
	lea		EDI, [EBP.vrpc_mem_fnn]
	mov		1 ptr [EDI + ECX], 0
	call	VRPC_recv_buf
	jc		VRPC_close_sock	
	
	; ������ ����� ����������
	call	VRPC_recv_byte
	jc		VRPC_close_sock
	
	; ��� ����������
	xor		ECX, ECX
	mov		CL, AL
	lea		EDI, [EBP.vrpc_mem_lib]
	mov		1 ptr [EDI + ECX], 0
	call	VRPC_recv_buf
	jc		VRPC_close_sock
	
	call	VRPC_find_proc
	
	; EAX = proc addr
	jmp		VRPC_do_call
	
VRPC_test_internal:
	dec		AL
	test	AL, AL
	jnz		VRPC_test_addr
	
	call	VRPC_get_internal
	
	; EAX = proc addr
	jmp		VRPC_do_call
	
VRPC_test_addr:
	dec		AL
	test	AL, AL
	jnz		VRPC_close_sock
	
	mov		EAX, [EBP.vrpc_mem_fn]
	
VRPC_do_call:
	or		EAX, EAX
	; ������� �� �����, ��� ����, ������ �� ����� :)
	jz		VRPC_close_sock
	mov		CL, [EBP.vrpc_mem_conv]
	
	test	CL, CL
	jnz		VRPC_test_cdecl
	call	VRPC_do_stdcall
	jmp		VRPC_send_result
	
VRPC_test_cdecl:
	dec		CL
	test	CL, CL
	jnz		VRPC_test_fast
	call	VRPC_do_cdecl
	jmp		VRPC_send_result

VRPC_test_fast:
	dec		CL
	test	CL, CL
	jnz		VRPC_close_sock
	call	VRPC_do_fast
	
VRPC_send_result:
	call	VRPC_send_dword
	
VRPC_close_sock:
	; ������� �����
	push	EBX
	api		closesocket, LIB_SOCK

	ret
endp VPRC_do_action


VRPC_ThreadProc proc
	; �������� ������ ��� ���������� � �.�.
	push	4096 * 2
	push	GMEM_FIXED
	api		LocalAlloc, LIB_KERN
	test	EAX, EAX
	jz		VRPC_exit_thread
	mov		EBP, EAX
	
	; �������������� ���������� �������
	push	EBP
	push	101h
    api		WSAStartup, LIB_SOCK
	test	EAX, EAX
	jnz		VRPC_exit_thread

	; ������� �����
	push	IPPROTO_IP
	push	SOCK_STREAM
	push	PF_INET
	api		socket, LIB_SOCK
	cmp		EAX, INVALID_SOCKET
	jz		VRPC_exit_thread
	mov		[EBP.vrpc_mem_sock], EAX

	; ��������� ��������� ���������������
	; ��������� ������
	mov		[EBP.vrpc_mem_addr.sin_family], PF_INET
	mov		EBX, [ESP + 4]
	mov		[EBP.vrpc_mem_addr.sin_port], BX
	mov		[EBP.vrpc_mem_addr.sin_addr], INADDR_ANY
	
	; ����������� ����� � �����	
	push	SIZE sockaddr_in
	push	EBP
	push	EAX
	api		bind, LIB_SOCK
	test	EAX, EAX
	jnz		VRPC_exit_thread
	
	; �������� ��������� �����
	push	SOMAXCONN
	push	[EBP.vrpc_mem_sock]
	api		listen, LIB_SOCK
	test	EAX, EAX
	jnz		VRPC_exit_thread


VRPC_main_loop:

	; ���� ������� ������
	xor		EAX, EAX
	push	EAX
	push	EAX
	push	[EBP.vrpc_mem_sock]
	api		accept, LIB_SOCK
	cmp		EAX, INVALID_SOCKET
	jz		VRPC_main_loop
	
	; ����-�� �������� -- ������������	
	; � EAX ������ ����� ������ ��� ������ ���������� ������
	call	VPRC_do_action
	
	; ���� �����
	jmp		VRPC_main_loop
	
VRPC_exit_thread:

	api		WSACleanup, LIB_SOCK

	retn	4
endp VRPC_ThreadProc


VRPC_get_internal proc
; �� ������ ������ ���������� ������� ��� ���,
; �� ��� �������� ������� ����� ��� ����� �����������
; �������, ������������� ������� ����� ����� ���: 
; mov EAX, [EBP.vrpc_mem_fn]
; ��� ��������� ������ ���������� ������ ��������� �������,
; ������� ����� ����� ������� � ����������� ����������� ���
; ����� ����� ����-�� ��������� � ����������� �� ID ������� �
; �� ����������, � ����� ������� ����, ����� ������ ���������� �� �����,
; �� ��� ����� ���������� ���������� ������ ��������� ��� ��� ������� ���
; �� ���� �� �����, � ���� �� ������ �������� ����������� �� ������,
; ������ �� ����� ������ ������.
; �������: ���� ��� ����� ���������� ���� ������� ��������, ����, ���
; ���� ID ������� � ��������� �� 32 �� 64.

	xor		EAX, EAX
	ret
endp VRPC_get_internal


VRPC_RunServer proc
	; ������� �����, ��� �� ������ �� ����� �������� ������ 
	push	EAX
	xor		EAX, EAX	
	push	EAX
	push	EBX
	push	offset VRPC_ThreadProc
	push	EAX
	push	EAX
	api		CreateThread, LIB_KERN
	
	retn
endp VRPC_RunServer