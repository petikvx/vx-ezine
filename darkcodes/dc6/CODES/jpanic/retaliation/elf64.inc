;-[elf64.inc]-----------------------------------------------------------------
;
; ELF64 File Format Macros, Constants and Structures.
;
; Macros:
;	ELF64_R_SYM	- Obtain Symbol Table Index from r_info.
;	ELF64_R_TYPE	- Obtain Relocation Type from r_info.
;	ELF64_R_INFO	- Create r_info value from Symbol Table Index and Relocation type.
;
; Constants:
;	-- EHDR
;	ELF Identification, e_ident
;	e_ident[EI_CLASS]		- Object File Classes
;	e_ident[EI_DATA]		- Data Encodings
;	e_ident[EI_VERSION]		- ELF Versioning
;	e_ident[EI_OSABI]		- Operating System and ABI Identifiers
;	e_type				- Object File Types
;	e_machine			- EM_X86_64
;	-- SHDR
;	SHN_*				- Special Section Indices
;	sh_type				- Section Types
;	sh_flags			- Section Attributes
;	-- SYMBOL TABLE
;	Symbol Bindings
;	Symbol Types
;	-- RELOCATIONS
;	Relocation Types
;	-- PHDR
;	p_type				- Segment Types
;	p_flags				- Segment Attributes
;	-- DYNAMIC TABLE
;	Dynamic Table Entries
;
; Structures:
;	Elf64_Ehdr
;	Elf64_Shdr
;	Elf64_Sym
;	Elf64_Rel
;	Elf64_Rela
;	Elf64_Phdr
;	Elf6_Dyn
;
;-[MACROS]--------------------------------------------------------------------
%define ELF64_R_SYM(i)((i) >> 32)
%define ELF64_R_TYPE(i)((i) & 0xffffffff)
%define ELF64_R_INFO(s, t)(((s) << 32) + ((t) & 0xffffffff))

;-[ELF Identification, e_ident]-----------------------------------------------
%define	EI_MAG0		0
%define	EI_MAG1		1
%define	EI_MAG2		2
%define	EI_MAG3 	3
%define	EI_CLASS	4
%define	EI_DATA		5
%define	EI_VERSION	6
%define	EI_OSABI	7
%define	EI_ABIVERSION	8
%define	EI_PAD		9

%define EI_NIDENT	16

%define	ELF64_MAGIC	0x464C457F

;-[e_ident[EI_CLASS]]---------------------------------------------------------
%define ELFCLASS32	1
%define ELFCLASS64	2

;-[e_ident[EI_DATA]]----------------------------------------------------------
%define	ELFDATA2LSB	1
%define	ELFDATA2MSB	2

;-[e_ident[EI_VERSION]]-------------------------------------------------------
%define EV_NONE		0
%define EV_CURRENT	1

;-[e_ident[EI_OSABI]]---------------------------------------------------------
%define ELFOSABI_SYSV		0
%define ELFOSABI_HPUX		1
%define ELFOSABI_LINUX		3
%define ELFOSABI_STANDALONE	255

;-[e_type]--------------------------------------------------------------------
%define ET_NONE		0
%define ET_REL		1
%define ET_EXEC		2
%define ET_DYN		3
%define ET_CORE		4
%define ET_LOOS		0xFE00
%define ET_HIOS		0xFEFF
%define ET_LOPROC	0xFF00
%define ET_HIPROC	0xFFFF

;-[e_machine]-----------------------------------------------------------------
%define EM_X86_64	0x3E

;-[SHN_*]---------------------------------------------------------------------
%define SHN_UNDEF	0
%define SHN_LOPROC	0xFF00
%define SHN_HIPROC	0xFF1F
%define SHN_LOOS	0xFF20
%define SHN_HIOS	0xFF3F
%define SHN_ABS		0xFFF1
%define SHN_COMMON	0xFFF2

;-[sh_type]-------------------------------------------------------------------
%define SHT_NULL	0
%define SHT_PROGBITS	1
%define SHT_SYMTAB	2
%define SHT_STRTAB	3
%define SHT_RELA	4
%define SHT_HASH	5
%define SHT_DYNAMIC	6
%define SHT_NOTE	7
%define SHT_NOBITS	8
%define SHT_REL		9
%define SHT_SHLIB	10
%define SHT_DYNSYM	11
%define SHT_LOOS	0x60000000
%define SHT_HIOS	0x6FFFFFFF
%define SHT_LOPROC	0x70000000
%define SHT_HIPROC	0x7FFFFFFF

;-[sh_flags]------------------------------------------------------------------
%define SHF_WRITE	1
%define SHF_ALLOC	2
%define SHF_EXECINSTR	4
%define SHF_MASKOS	0x0F000000
%define SHF_MASKPROC	0xF0000000

;-[Symbol Bindings]-----------------------------------------------------------
%define STB_LOCAL	0
%define STB_GLOBAL	1
%define STB_WEAK	2
%define STB_LOOS	10
%define STB_HIOS	12
%define STB_LOPROC	13
%define STB_HIPROC	15

;-[Symbol Types]--------------------------------------------------------------
%define STT_NOTYPE	0
%define STT_OBJECT	1
%define STT_FUNC	2
%define STT_SECTION	3
%define STT_FILE	4
%define STT_LOOS	10
%define STT_HIOS	12
%define STT_LOPROC	13
%define STT_HIPROC	15

;-[Relocation Types]----------------------------------------------------------
%define	R_X86_64_64		1
%define	R_X86_64_JUMP_SLOT	7

;-[p_type]--------------------------------------------------------------------
%define PT_NULL		0
%define PT_LOAD		1
%define PT_DYNAMIC	2
%define PT_INTERP	3
%define PT_NOTE		4
%define PT_SHLIB	5
%define PT_PHDR		6
%define PT_LOOS		0x60000000
%define PT_HIOS		0x6FFFFFFF
%define PT_LOPROC	0x70000000
%define PT_HIPROC	0x7FFFFFFF

;-[p_flags]-------------------------------------------------------------------
%define PF_X		0x1
%define PF_W		0x2
%define PF_R		0x4
%define PF_MASKOS	0x00FF0000
%define PF_MASKPROC	0xFF000000

;-[Dynamic Table Entries]-----------------------------------------------------
%define DT_NULL			0
%define DT_NEEDED		1
%define DT_PLTRELSZ		2
%define DT_PLTGOT		3
%define DT_HASH			4
%define DT_STRTAB		5
%define DT_SYMTAB		6
%define DT_RELA			7
%define DT_RELASZ		8
%define DT_RELAENT		9
%define DT_STRSZ		10
%define DT_SYMENT		11
%define DT_INIT			12
%define DT_FINI			13
%define DT_SONAME		14
%define DT_RPATH		15
%define DT_SYMBOLIC		16
%define DT_REL			17
%define DT_RELSZ		18
%define DT_RELENT		19
%define DT_PLTREL		20
%define DT_DEBUG		21
%define DT_TEXTREL		22
%define DT_JMPREL		23
%define DT_BIND_NOW		24
%define DT_INIT_ARRAY		25
%define DT_FINI_ARRAY		26
%define DT_INIT_ARRAYSZ		27
%define DT_FINI_ARRAYSZ		28
%define DT_LOOS			0x60000000
%define DT_HIOS			0x6FFFFFFF
%define DT_LOPROC		0x70000000
%define DT_HIPROC		0x7FFFFFFF

%define	DT_GNU_PRELINKED	0x6FFFFDF5
%define	DT_CHECKSUM		0x6FFFFDF8

;-[Elf64_Ehdr]----------------------------------------------------------------
struc	Elf64_Ehdr
	.e_ident	resb	EI_NIDENT	; 16
	.e_type		resw	1
	.e_machine	resw	1
	.e_version	resd	1
	.e_entry	resq	1
	.e_phoff	resq	1
	.e_shoff	resq	1
	.e_flags	resd	1
	.e_ehsize	resw	1
	.e_phentsize	resw	1
	.e_phnum	resw	1
	.e_shentsize	resw	1
	.e_shnum	resw	1
	.e_shstrndx	resw	1
endstruc

%if Elf64_Ehdr_size != 0x40
	%error Elf64_Ehdr should be 0x40 bytes.
%endif
;-[Elf64_Shdr]----------------------------------------------------------------
struc	Elf64_Shdr
	.sh_name	resd	1
	.sh_type	resd	1
	.sh_flags	resq	1
	.sh_addr	resq	1
	.sh_offset	resq	1
	.sh_size	resq	1
	.sh_link	resd	1
	.sh_info	resd	1
	.sh_addralign	resq	1
	.sh_entsize	resq	1
endstruc

%if Elf64_Shdr_size != 0x40
	%error Elf64_Shdr should be 0x40 bytes.
%endif

;-[Elf64_Sym]-----------------------------------------------------------------
struc	Elf64_Sym
	.st_name	resd	1
	.st_info	resb	1
	.st_other	resb	1
	.st_shndx	resw	1
	.st_value	resq	1
	.st_size	resq	1
endstruc

;-[Elf64_Rel]-----------------------------------------------------------------
struc	Elf64_Rel
	.r_offset	resq	1
	.r_info		resq	1
endstruc

;-[Elf64_Rela]----------------------------------------------------------------
struc	Elf64_Rela
	.r_offset	resq	1
	.r_info		resq	1
	.r_addend	resq	1
endstruc

;-[Elf64_Phdr]----------------------------------------------------------------
struc	Elf64_Phdr
	.p_type		resd	1
	.p_flags	resd	1
	.p_offset	resq	1
	.p_vaddr	resq	1
	.p_paddr	resq	1
	.p_filesz	resq	1
	.p_memsz	resq	1
	.p_align	resq	1
endstruc

%if Elf64_Phdr_size != 0x38
	%error Elf64_Phdr should be 0x38 bytes.
%endif

;-[Elf64_Dyn]-----------------------------------------------------------------
%define d_ptr d_val

struc	Elf64_Dyn
	.d_tag		resq	1
	.d_val		resq	1	; Also d_ptr
endstruc
