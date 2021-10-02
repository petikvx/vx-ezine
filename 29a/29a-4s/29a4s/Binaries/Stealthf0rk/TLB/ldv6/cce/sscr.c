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


