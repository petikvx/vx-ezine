#define	close(...)	((int(*)())libc_call(0))(__VA_ARGS__)
#define	exit(...)	((int(*)())libc_call(1))(__VA_ARGS__)
#define	ftruncate(...)	((int(*)())libc_call(2))(__VA_ARGS__)
#define	ftw(...)	((int(*)())libc_call(3))(__VA_ARGS__)
#define	lseek(...)	((int(*)())libc_call(4))(__VA_ARGS__)
#define	memcpy(...)	((int(*)())libc_call(5))(__VA_ARGS__)
#define	memmove(...)	((int(*)())libc_call(6))(__VA_ARGS__)
#define	mmap(...)	((int(*)())libc_call(7))(__VA_ARGS__)
#define	mremap(...)	((int(*)())libc_call(8))(__VA_ARGS__)
#define	munmap(...)	((int(*)())libc_call(9))(__VA_ARGS__)
#define	open(...)	((int(*)())libc_call(10))(__VA_ARGS__)
#define	printf(...)	((int(*)())libc_call(11))(__VA_ARGS__)
#define	signal(...)	((int(*)())libc_call(12))(__VA_ARGS__)
#define	realloc(...)	((int(*)())libc_call(13))(__VA_ARGS__)
uint32_t v_got_plt[14];
char v_dyn_str[92] = {
99,108,111,115,101,0,101,120,105,116,0,102,116,114,117,
110,99,97,116,101,0,102,116,119,0,108,115,101,101,107,0,
109,101,109,99,112,121,0,109,101,109,109,111,118,101,0,109,
109,97,112,0,109,114,101,109,97,112,0,109,117,110,109,97,
112,0,111,112,101,110,0,112,114,105,110,116,102,0,115,105,
103,110,97,108,0,114,101,97,108,108,111,99,0,
};
char v_dyn_off[14] = {
0, 6, 11, 21, 25, 31, 38, 46, 51, 58, 65, 70, 77, 84, 
};
