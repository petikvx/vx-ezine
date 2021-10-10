/* if compilation fails on your system, make new ld script */
/* from ld --verbose and fix the places commented below */

OUTPUT_FORMAT("elf32-i386", "elf32-i386", "elf32-i386")
OUTPUT_ARCH(i386)
ENTRY(virus_start)
SEARCH_DIR("/usr/i386-redhat-linux/lib");
SEARCH_DIR("/usr/local/lib");
SEARCH_DIR("/lib");
SEARCH_DIR("/usr/lib");
SECTIONS
{
	. = 0x08048000 + SIZEOF_HEADERS;
	.interp         : { *(.interp) }
	.gnu.hash       : { *(.gnu.hash) }
	.dynsym         : { *(.dynsym) }
	.dynstr         : { *(.dynstr) }
	.gnu.version    : { *(.gnu.version) }
	.gnu.version_r  : { *(.gnu.version_r) }
	.rel.plt        : { *(.rel.plt) }
	.plt            : { *(.plt) }
/* i inserted, this: */
	__text_start =.;
	_text : {
		stub.o(.text)
		virus.o(.text)
	} =0x90909090
	__text_end =.;
	/* just a stub for crt*.o */
	.crtshit : {
		stub.o(.crtshit)
		PROVIDE_HIDDEN (__preinit_array_start = .);
		PROVIDE_HIDDEN (__preinit_array_end = .);
		PROVIDE_HIDDEN (__init_array_start = .);
		PROVIDE_HIDDEN (__init_array_end = .);
		PROVIDE_HIDDEN (__fini_array_start = .);
		PROVIDE_HIDDEN (__fini_array_end = .);
	}
/**/
	.dynamic        : { *(.dynamic) }
	.got            : { *(.got) }
	.got.plt        : { *(.got.plt) }
/* and this: */
	__data_start =.;
	_data : {
		virus.o(.data .rodata* .bss COMMON)
	}
	__data_end =.;
/**/
	/DISCARD/ : { *(.note.GNU-stack) }
}
