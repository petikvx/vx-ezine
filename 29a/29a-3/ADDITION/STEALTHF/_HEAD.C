#include "/usr/include/stdio.h"
#include <fcntl.h>
#ifdef linux
#	include <linux/unistd.h>
#else
#	include <dos.h>
#endif

#include <sys/stat.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>

int virfunc(void);
int Close(int);
int Crypt(char*, int);
int mutate(char *);
#ifdef linux
  int jump2dos(void);
#endif
  
