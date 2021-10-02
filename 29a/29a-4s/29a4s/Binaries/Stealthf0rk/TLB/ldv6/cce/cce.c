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
                     
