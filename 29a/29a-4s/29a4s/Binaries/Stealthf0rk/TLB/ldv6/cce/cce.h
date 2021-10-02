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

