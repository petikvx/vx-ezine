
// Statistical Executable Trash Generator -- example #2

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <assert.h>
#include <io.h>
#pragma hdrstop

#define vsnprintf _vsnprintf

#ifdef INSDUMP
#include "INSDUMP/insdump.h"
#endif
#define LOG_TO_CONSOLE
#include "COMMON/log.cpp"
#include "COMMON/zalloc.cpp"
#include "COMMON/list.cpp"
#include "XDE/xde.c"

void main(int argc, char* argv[])
{

  srand(GetTickCount());

  FILE*f=fopen("setg_sample.txt","rb");
  assert(f);
  FILE*o=fopen("setg_sample2.bin","wb");
  assert(o);

  static char t[1024];
  while(char*s=fgets(t,sizeof(t)-1,f))
  {
    while(s[0]&&s[strlen(s)-1]<=32) s[strlen(s)-1]=0; // strip \r\n

    int t, len = strlen(s) / 2;
    static BYTE buf[1024];
    for(t = 0; t < len; t++)
      sscanf(s+t*2, "%02X", &buf[t]);

    struct xde_instr diza;
    xde_disasm(buf, &diza);

    /* nb: this can be highly improved */
    diza.addr_l[0] = (rand() % 100000) & (~3);
    diza.data_l[0] = (rand() % 100000) & (~3);

    len = xde_asm(buf, &diza);

#ifdef INSDUMP
    static char q[1024];
    dump_instr(buf, 0, q);

    s[0]=0;
    for(t = 0; t < len; t++)
      sprintf(s+strlen(s), "%02X", buf[t]);

    printf("%-32s | %s\n", s, q);
#endif

    fwrite(buf,1,len,o);

  }

  fclose(f);
  fclose(o);

} /* main */

/* EOF */
