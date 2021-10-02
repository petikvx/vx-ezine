
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <assert.h>
#include <io.h>
#pragma hdrstop

void main(int argc, char* argv[])
{

  if (argc!=3)
  {
    printf("syntax: %s infile.txt outfile.bin\n", argv[0]);
    exit(0);
  }

  char* ifile = argv[1];
  char* ofile = argv[2];

  printf("+ reading: %s\n", ifile);

  FILE*f=fopen(ifile,"rb");
  assert(f);

  printf("+ writing: %s\n", ofile);

  FILE*of=fopen(ofile,"wb");
  assert(of);

  static char t0[1024];
  t0[0]=0;
  int c = 0;
  static char t[1024];
  while(char*s=fgets(t,sizeof(t)-1,f))
  {
    while(s[0]&&s[strlen(s)-1]<=32) s[strlen(s)-1]=0; // strip \r\n

    int res = strcmp(t0, s);
    if (res == 0)
    {
      c++;
    }
    else
    {
      if (c)
        fprintf(of,"%08d %s\n",c,&t0[3]);
      strcpy(t0, s);
      c = 1;
    }
    ;;
  }
  if (c)
    fprintf(of,"%08d %s\n",c,&t0[3]);

  fclose(f);
  fclose(of);

} /* main */

/* EOF */
