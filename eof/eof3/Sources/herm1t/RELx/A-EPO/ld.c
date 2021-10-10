#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>
#include <elf.h>

#include "reloc.h"

uint8_t code[16384], data[16384], symstr[16384], rel[16384];
int s_code = 0, s_data = 0, c_rel = 0, s_symstr = 0;
reloc_t *relocs = NULL;

typedef struct _elf elf_t;
struct _elf {
	char *filename;
	union {
		uint8_t *m;
		Elf32_Ehdr *ehdr;
	};
	int h, l, v;
	Elf32_Shdr *shdr;
	char *strtab;
	Elf32_Sym *symtab;
	char *symstr;
	int nsyms;
	uint32_t *offset;
	struct _elf *next;
};


void close_elf(elf_t *elf)
{
	if (elf == NULL)
		return;
	if (elf->v >= 2) {
		if (elf->offset != NULL)
			free(elf->offset);
		munmap(elf->m, elf->l);
		elf->v = 1;
	}
	if (elf->v == 1) {
		close(elf->h);
	}
}

void close_all(elf_t *elf)
{
	elf_t *e;
	while (elf) {
		e = elf->next;
		close_elf(elf);
		free(elf);
		elf = e;
	}
}

elf_t *load_elf(char *filename, elf_t *elf)
{
	elf_t *e, *p;
	e = malloc(sizeof(elf_t));
	if (e == NULL) {
		fprintf(stderr, "%s: OOM\n", filename);
		close_all(elf);
		return NULL;
	}
	if (elf == NULL)
		elf = e;
	else {
		for (p = elf; p->next != NULL; p = p->next)
			;
		p->next = e;
	}
	bzero((char*)e, sizeof(elf_t));
	
	e->filename = filename;
	int h = open(filename, O_RDONLY);
	if (h < 0) {
		fprintf(stderr, "%s: failed to open file!\n", filename);
		return elf;
	}
	e->h = h;
/*1*/	e->v++;
	int l = lseek(h, 0, SEEK_END);
	if (l < sizeof(Elf32_Ehdr)) {
		fprintf(stderr, "%s: invalid file length!\n", filename);
		return elf;
	}
	e->l = l;
	uint8_t *m = mmap(NULL, l, PROT_READ, MAP_SHARED, h, 0);
	if (m == MAP_FAILED) {
		fprintf(stderr, "%s: unable to map file into memory!\n", filename);
		return elf;
	}
	e->m = m;
/*2*/	e->v++;
	if (e->ehdr->e_shnum == 0 || e->ehdr->e_shoff == 0 || e->ehdr->e_shoff + e->ehdr->e_shnum * sizeof(Elf32_Shdr) > l) {
		fprintf(stderr, "%s: Invalid sections table\n", filename);
		return elf;
	}
	Elf32_Shdr *shdr = (Elf32_Shdr*)(m + e->ehdr->e_shoff);

	if (e->ehdr->e_shstrndx == SHN_UNDEF || shdr[e->ehdr->e_shstrndx].sh_offset > l) {
		fprintf(stderr, "%s: Invalid string table\n", filename);
		return elf;
	}
	char *strtab = (char*)(m + shdr[e->ehdr->e_shstrndx].sh_offset);
	e->shdr = shdr;
	e->strtab = strtab;
	e->offset = malloc(e->ehdr->e_shnum * sizeof(uint32_t));
	if (e->offset == NULL)
		return elf;
	int i;
	for (i = 0; i < e->ehdr->e_shnum; i++)
		if (e->shdr[i].sh_type == SHT_SYMTAB) {
			e->symtab = (Elf32_Sym*)(m + shdr[i].sh_offset);
			e->symstr = (char*)(m + shdr[shdr[i].sh_link].sh_offset);
			e->nsyms = shdr[i].sh_size / sizeof(Elf32_Sym);
			break;
		}
	if (e->symtab == NULL)
		return elf;
/*3*/	e->v++;
	return elf;
}

char *memstr(char *haystack, char *needle, int hlen)
{
	int i, l = strlen(needle) + 1;
	for (i = 0; i <= hlen - l; i++) {
		if (! memcmp(haystack, needle, l))
			return haystack;
		haystack++;
	}
	return NULL;
}

#include "rtld_relocate.c"

int main(int argc, char **argv)
{
	elf_t *elf = NULL, *e, *p;
	if (argc < 2) {
		fprintf(stderr, "Usage:\n%s <file.o> ...\n", argv[0]);
		return 2;
	}
	int i, j, k;
	for (i = 1; i < argc; i++)
		elf = load_elf(argv[i], elf);
	for (e = elf; e; e = e->next)
		if (e->v != 3) {
			close_all(elf);
			return 2;
		}
	s_code = s_data = 0;
	for (e = elf; e; e = e->next) {
		for (i = 0; i < e->ehdr->e_shnum; i++)
		if (e->shdr[i].sh_flags & SHF_ALLOC) {	
			if (e->shdr[i].sh_flags & SHF_EXECINSTR) {
				memcpy(code + s_code, e->m + e->shdr[i].sh_offset, e->shdr[i].sh_size);
				e->offset[i] = s_code;
				s_code += e->shdr[i].sh_size;
			} else {
				if (e->shdr[i].sh_type != SHT_NOBITS) /* not .bss */
					memcpy(data + s_data, e->m + e->shdr[i].sh_offset, e->shdr[i].sh_size);
				e->offset[i] = s_data;
				s_data += e->shdr[i].sh_size;
			}
		}
	}
	for (e = elf; e; e = e->next) {
		for (i = 0; i < e->ehdr->e_shnum; i++)
		if (e->shdr[i].sh_type == SHT_REL) {
			Elf32_Rel *rel = (Elf32_Rel*)(e->m + e->shdr[i].sh_offset);
			for (j = 0; j < e->shdr[i].sh_size / sizeof(Elf32_Rel); j++) {
				if (ELF32_R_TYPE(rel[j].r_info) != R_386_32 && ELF32_R_TYPE(rel[j].r_info) != R_386_PC32) {
					fprintf(stderr, "%s: Unable to handle relocation %d <%08x %08x>\n", e->filename, j, rel[j].r_offset, rel[j].r_info);
				}
				uint32_t src_offset, src_type, dst_offset, dst_type, r_type;
				src_type = src_offset = dst_type = dst_offset = -1;
				k = e->shdr[i].sh_info;
				src_type = e->shdr[k].sh_flags & SHF_EXECINSTR ? 0 : 1;
				src_offset = e->offset[k] + rel[j].r_offset;
				Elf32_Sym *sym = &e->symtab[ELF32_R_SYM(rel[j].r_info)];
				if (sym->st_info == 0x10) {
					if (*(uint16_t*)(sym->st_name + e->symstr) != 0x5f5f) {
						for (p = elf; p != NULL; p = p->next) {
							if (p == e)
								continue;
							for (k = 0; k < p->nsyms; k++) 
								if (! strcmp(sym->st_name + e->symstr, p->symtab[k].st_name + p->symstr) && p->symtab[k].st_info != 0x10)
									break;
							if (k != p->nsyms) {
								dst_type = p->shdr[p->symtab[k].st_shndx].sh_flags & SHF_EXECINSTR ? 0 : 1;
								dst_offset = p->offset[p->symtab[k].st_shndx] + p->symtab[k].st_value;
							}
						}
						if (dst_type == -1) {
							dst_type = 2;
							k = strlen(sym->st_name + e->symstr) + 1;
							char *x = memstr((char*)symstr, (char*)(sym->st_name + e->symstr), s_symstr);
							if (x == NULL) {
								memcpy(symstr + s_symstr, sym->st_name + e->symstr, k);
								dst_offset = s_symstr;
								s_symstr += k;
							} else
								dst_offset = x - (char*)symstr;
						}
					} else {
						dst_type = 3;
						char *int_vars[] = {
							"__entry",
							"__data_start",
							"__data_end",
							"__text_start",
							"__text_end",
							NULL
						};
						for (k = 0; int_vars[k] != NULL; k++)
							if (! strcmp(sym->st_name + e->symstr, int_vars[k]))
								break;
						if (int_vars[k] == NULL)
							fprintf(stderr, "Uknown variable\n");
						dst_offset = k;
					}

				} else {
					if (sym->st_shndx == SHN_COMMON) {
						if (ELF32_ST_TYPE(sym->st_info) != STT_OBJECT)
							fprintf(stderr, "\nDon't known how to handle non-object commons\n");
						dst_type = 1;
						dst_offset = s_data;
						s_data += sym->st_size;
					} else {
						if (! (e->shdr[sym->st_shndx].sh_flags & SHF_ALLOC))
							fprintf(stderr, "\nReloc reference non-allocated section!\n");
						dst_type = e->shdr[sym->st_shndx].sh_flags & SHF_EXECINSTR ? 0 : 1;
						dst_offset = e->offset[sym->st_shndx] + sym->st_value;
					}
				}
				if (ELF32_R_TYPE(rel[j].r_info) == R_386_32)
					r_type = 0;
				else
					r_type = 1;
				int32_t add = *(uint32_t*)((src_type ? data : code) + src_offset);
				if (src_type == dst_type && ELF32_R_TYPE(rel[j].r_info) == R_386_PC32) {
					*(uint32_t*)((src_type ? data : code) + src_offset) = dst_offset - (src_offset + 4);
				} else {
					if ((relocs = (reloc_t*)realloc(relocs, (c_rel + 2) * sizeof(reloc_t))) == NULL)
						fprintf(stderr, "OOM\n");
					bzero(&relocs[c_rel], sizeof(reloc_t));
					MK_SRC_FRAG(relocs[c_rel], src_type);
					MK_SRC_TYPE(relocs[c_rel], r_type);
					MK_DST_FRAG(relocs[c_rel], dst_type);
					MK_SRC_OFF(relocs[c_rel], src_offset);
					MK_DST_OFF(relocs[c_rel], dst_offset);
					if (dst_type < 2)
						ADJUST_DST_OFF(relocs[c_rel], add);
					c_rel++;
				}
			}
		}
	}
	MK_FINI(relocs[c_rel++]);
	
	j = c_rel * sizeof(reloc_t);
	for (i = 0; i < c_rel - 1; i++) {
		if (DST_FRAG(relocs[i]) == 2)
			ADJUST_DST_OFF(relocs[i], (s_data + j));
		if (DST_FRAG(relocs[i]) == 1)
			ADJUST_DST_OFF(relocs[i], j);
		if (DST_FRAG(relocs[i]) == 3) {
			reloc_t tmp;
			bzero(&tmp, sizeof(tmp));
			MK_SRC_FRAG(tmp, SRC_FRAG(relocs[i]));
			MK_SRC_TYPE(tmp, SRC_TYPE(relocs[i]));
			MK_SRC_OFF (tmp, SRC_OFF (relocs[i]));
			switch (DST_OFF(relocs[i])) {
				case 0: MK_DST_FRAG(tmp, 3); MK_DST_OFF(tmp, 0);			break;	/* __entry */
				case 1:	MK_DST_FRAG(tmp, 1);						break;	/* data start */
				case 2: MK_DST_FRAG(tmp, 1); MK_DST_OFF(tmp, (s_data + j + s_symstr));	break;	/* data end */
				case 3: MK_DST_FRAG(tmp, 0);						break;	/* code start */
				case 4:	MK_DST_FRAG(tmp, 0); MK_DST_OFF(tmp, s_code);			break;	/* code end */
			}
			if (DST_FRAG(tmp) != 3)
				ADJUST_DST_OFF(tmp, *(uint32_t*)((SRC_FRAG(tmp) == 0 ? code : data) + SRC_OFF(tmp)));
			memcpy(&relocs[i], &tmp, sizeof(tmp));
		}
	}
	memcpy(data + s_data, symstr, s_symstr);
	s_data += s_symstr;
	memmove(data + j, data, s_data);
	memcpy(data, (char*)relocs, c_rel * sizeof(reloc_t));
	s_data += j;
	code[s_code++] = 0xcc;
	
	printf("Text: %d, Data: %d (Symstr: %d, Relocs: %d)\n", s_code, s_data, s_symstr, c_rel);
	
 	relocate(code, data, 0x8048000 + sizeof(Elf32_Ehdr) + sizeof(Elf32_Phdr) * 4, 0x804c000, 0xc0000000);
	
	char *str_interp = "/lib/ld-linux.so.2";
	uint32_t interp = s_data;
	memcpy(data + s_data, str_interp, strlen(str_interp) + 1);
	s_data += strlen(str_interp) + 1;
	uint32_t dynamic = s_data;
	Elf32_Dyn *dyn = (Elf32_Dyn*)(data + s_data);
	s_data += sizeof(Elf32_Dyn) * 8;
	dyn[0].d_tag = DT_PLTGOT;
	dyn[0].d_un.d_val = 0x804c000 + s_data - 12;
	
	dyn[1].d_tag = DT_SYMTAB;
	dyn[2].d_tag = DT_STRTAB;
	dyn[3].d_tag = DT_JMPREL;
	dyn[3].d_un.d_val = 0x804c000 + s_data;
	
	*(uint32_t*)(data + s_data - 12) = 0x804c000 + dynamic;
	
	/* write ELF file */
	int h = creat("a.out", 0777);
	if (h < 0) {
		fprintf(stderr, "Failed to create a.out\n");
		return 2;
	}
	int sx_text = s_code + sizeof(Elf32_Ehdr) + 4 * sizeof(Elf32_Phdr);
	int sa_text = (sx_text + 4095) & 0xfffff000;
	int sa_algn = sa_text - sx_text;
	ftruncate(h, sa_text + s_data + 5 * sizeof(Elf32_Shdr) + 32);
	/* make ELF header */
	Elf32_Ehdr ehdr;
	*(uint32_t*)&ehdr.e_ident = 0x464c457f;
	ehdr.e_type = ET_EXEC;
	ehdr.e_ident[EI_CLASS] = ELFCLASS32;
	ehdr.e_ident[EI_DATA] = ELFDATA2LSB;
	ehdr.e_ident[EI_VERSION] = 1;
	ehdr.e_machine = EM_386;
	ehdr.e_version = EV_CURRENT;
	ehdr.e_entry = 0x8048000 + sizeof(Elf32_Ehdr) + sizeof(Elf32_Phdr) * 4;
	ehdr.e_phoff = sizeof(Elf32_Ehdr);
	ehdr.e_shoff = sa_text + s_data;
	ehdr.e_flags = 0;
	ehdr.e_ehsize = sizeof(Elf32_Ehdr);
	ehdr.e_phentsize = sizeof(Elf32_Phdr);
	ehdr.e_phnum = 4;
	ehdr.e_shentsize = sizeof(Elf32_Shdr);
	ehdr.e_shnum = 5;
	ehdr.e_shstrndx = 3;
	write(h, &ehdr, sizeof(Elf32_Ehdr));
	/* make program headers */
	Elf32_Phdr phdr;
	phdr.p_type = PT_LOAD;
	phdr.p_offset = 0;
	phdr.p_vaddr = 0x8048000;
	phdr.p_paddr = phdr.p_vaddr;
	phdr.p_filesz = sa_text;
	phdr.p_memsz = sa_text;
	phdr.p_flags = 7;
	phdr.p_align = 0x1000;
	write(h, &phdr, sizeof(Elf32_Phdr));

	phdr.p_offset = sa_text;
	phdr.p_vaddr = 0x804c000;
	phdr.p_paddr = phdr.p_vaddr;
	phdr.p_filesz = s_data;
	phdr.p_memsz = phdr.p_filesz;
	phdr.p_flags = 7;
	write(h, &phdr, sizeof(Elf32_Phdr));
	
	phdr.p_type = PT_INTERP;
	phdr.p_offset = sa_text + interp;
	phdr.p_vaddr = phdr.p_paddr = 0x804c000 + interp;
	phdr.p_filesz = phdr.p_memsz = strlen(str_interp) + 1;
	phdr.p_flags = 6;
	phdr.p_align = 1;
	write(h, &phdr, sizeof(Elf32_Phdr));

	bzero(&phdr, sizeof(Elf32_Phdr));	
	phdr.p_type = PT_DYNAMIC;
	phdr.p_vaddr = sa_text + dynamic;
	phdr.p_vaddr = phdr.p_paddr = 0x804c000 + dynamic;
	phdr.p_filesz = phdr.p_memsz = sizeof(Elf32_Dyn) * 8;
	write(h, &phdr, sizeof(Elf32_Phdr));

	write(h, code, s_code);	
	lseek(h, sa_algn, SEEK_CUR);
	write(h, data, s_data);
	
	/* make section headers */
	Elf32_Shdr shdr;
	bzero(&shdr, sizeof(Elf32_Shdr));
	shdr.sh_name = 5;
	write(h, &shdr, sizeof(Elf32_Shdr));
	
	shdr.sh_name = 1;	/* .text */
	shdr.sh_type = SHT_PROGBITS;
	shdr.sh_flags = SHF_ALLOC | SHF_EXECINSTR;
	shdr.sh_addr = 0x8048000 + sizeof(Elf32_Ehdr) + 4 * sizeof(Elf32_Phdr);
	shdr.sh_offset = sizeof(Elf32_Ehdr) + 4 * sizeof(Elf32_Phdr);
	shdr.sh_size = s_code;
	write(h, &shdr, sizeof(Elf32_Shdr));
	
	shdr.sh_name = 7;	/* .data */
	shdr.sh_flags = SHF_ALLOC | SHF_WRITE;
	shdr.sh_addr = 0x804c000;
	shdr.sh_offset = sa_text;
	shdr.sh_size = s_data;
	write(h, &shdr, sizeof(Elf32_Shdr));
	
	shdr.sh_name = 13;	/* .shstrtab */
	shdr.sh_type = SHT_STRTAB;
	shdr.sh_flags = 0;
	shdr.sh_addr = 0;
	shdr.sh_offset = s_data + sa_text + 5 * sizeof(Elf32_Shdr);
	shdr.sh_size = 32;
	write(h, &shdr, sizeof(Elf32_Shdr));
	
	shdr.sh_name = 23;	// NULL
	shdr.sh_type = SHT_DYNAMIC;
	shdr.sh_offset = sa_text + dynamic;
	shdr.sh_addr = 0x804c000 + dynamic;
	shdr.sh_flags = SHF_ALLOC | SHF_WRITE;
	shdr.sh_size = 8 * sizeof(Elf32_Dyn);
	write(h, &shdr, sizeof(Elf32_Shdr));
	
	/* make section names */
	write(h, "", 1);
	write(h, ".text", 6);
	write(h, ".data", 6);
	write(h, ".shstrtab", 10);
	write(h, ".dynamic", 8);

	close(h);
	
	close_all(elf);
	return 0;
}
