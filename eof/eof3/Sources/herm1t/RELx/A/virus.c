#define _GNU_SOURCE
#include <asm/unistd.h>
#include <elf.h>
#include <fcntl.h>
#include <ftw.h>
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

static uint32_t text_size, data_size, orig_esp;
extern char __text_start, __text_end, __data_start, __data_end;
extern void _recovery();

#include "reloc.h"
#include "../common_libc.c"

static int init(void)
{
	uint32_t s = (uint32_t)&__text_start & 0xfffff000;
	uint32_t l = ((uint32_t)&__text_end - s + 4095) & 0xfffff000;
	reloc_t *rel = (reloc_t*)&__data_start;
	libc_t libc;	
	int (*mprotect)();

	bzero(&libc, sizeof(libc));
	
	/* find libc and mprotect function */
	find_libc(&libc);

	if ((mprotect = (int(*)())resolve(&libc, (char*)"mprotect")) == NULL)
		return 0;
	mprotect(s, l, PROT_READ | PROT_WRITE | PROT_EXEC);
	for ( ; ! IS_FINI(*rel); rel++)
		if (DST_FRAG(*rel) == 2) {
			uint32_t src, dst;
			src = (uint32_t)(SRC_FRAG(*rel) ? &__data_start : &__text_start) + SRC_OFF(*rel);
			dst = resolve(&libc, (char*)&__data_start + DST_OFF(*rel));
			if (dst == 0)
				return 0;
			*(uint32_t*)src = SRC_TYPE(*rel) ? dst - (src + 4) : dst;
		}
	mprotect(s, l, PROT_READ | PROT_EXEC);
	return 1;
}

#include "rtld_relocate.c"

#define	NEW_ENTRY	new_text
#include "../common_main.c"
