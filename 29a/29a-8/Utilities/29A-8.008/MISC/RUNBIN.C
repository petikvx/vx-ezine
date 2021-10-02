
#ifdef WIN32
#include <windows.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#pragma hdrstop

typedef void (__cdecl*type_sub)(void);

void help()
{
  printf("syntax: runbin <file.bin> [--int3] [--wsastartup]\n");
  exit(0);
}

int main(int argc, char* argv[])
{
  FILE*f;
  int i, len, do_int3, do_wsa;
  char *buf, *fname, *t;

  do_int3 = 0;
  do_wsa = 0;

  fname   = NULL;
  for(i = 1; i < argc; i++)
  {
    if (!stricmp(argv[i],"--int3")) do_int3=1; else
    if (!stricmp(argv[i],"--wsastartup")) do_wsa=1; else
    if (!fname) fname = argv[i]; else help();
  }
  if (fname == NULL) help();

  f=fopen(fname,"rb");
  if (f==NULL)
  {
    printf("ERROR: cant open file: %s\n", fname);
    exit(0);
  }
  fseek(f,0,SEEK_END);
  len = ftell(f);
  rewind(f);
  buf = (char*)malloc((size_t)len);
  assert(buf);
  assert(fread(buf,1,len,f)==len);
  fclose(f);

  if (do_wsa)
  {
    WSADATA WSAData;
    if (WSAStartup(MAKEWORD(1,1), &WSAData) != 0)
    {
      printf("ERROR: WSAStartup() error\n");
      exit(0);
    }
  }

  printf("executing: %s, %d bytes\n", fname, len);

#ifdef WIN32
  __try
  {
#endif

    if (do_int3) __asm int 3;
    ((type_sub)buf)();

#ifdef WIN32
  }
  __except(1)
  {
    printf("ERROR: gpf\n");
  }
#endif

  return 0;
}
