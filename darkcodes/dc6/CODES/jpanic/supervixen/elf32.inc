/* elf32.inc for RaspberryPi.SuperVixen virus by JPanic, Australia, 2014. */
/* see supervixen.s for more details. */

/* Elf32_Ehdr */
.equ e_ident,			0
.equ e_type,			16
.equ e_machine,			18
.equ e_version,			20
.equ e_entry,			24
.equ e_phoff,			28
.equ e_shoff,			32
.equ e_flags,			36
.equ e_ehsize,			40
.equ e_phentsize,		42
.equ e_phnum,			44
.equ e_shentsize,		46
.equ e_shnum,			48
.equ e_shstrndx,		50
.equ Elf32_Ehdr_size,		52

/* e_ident */
.equ EI_MAG0,		0
.equ EI_MAG1,		1
.equ EI_MAG2,		2
.equ EI_MAG3,		3
.equ EI_CLASS,		4
.equ EI_DATA,		5
.equ EI_VERSION,	6
.equ EI_PAD,		7

/* needed constants */
.equ ELF32_MAGIC,	0x464C457F
.equ ET_EXEC,		2
.equ EM_ARM,		40
.equ EV_CURRENT,	1
.equ ELFCLASS32,	1
.equ ELFDATA2LSB,	1

/* Elf32_Phdr */
.equ p_type,			0
.equ p_offset,			4
.equ p_vaddr,			8
.equ p_paddr,			12
.equ p_filesz,			16
.equ p_memsz,			20
.equ p_flags,			24
.equ p_align,			28
.equ Elf32_Phdr_size,		32

/* needed constants */
.equ PT_LOAD,			1
.equ PT_NOTE,			4

.equ PF_X,			1
.equ PF_W,			2
.equ PF_R,			4
