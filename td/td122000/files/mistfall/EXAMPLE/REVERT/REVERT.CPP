
#include <windows.h>

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <io.h>

#pragma hdrstop

/************/

#include "..\..\SRC\engine.hpp"
#include "..\..\SRC\engine.cpp"
#include "..\..\SRC\mutate.cpp"

/************/

extern "C"
int __cdecl disasm_main(BYTE*);   // length-disassembler interface

int __cdecl my_disasm(DWORD,BYTE* x)
{
  return disasm_main(x);
}

void* __cdecl my_malloc(DWORD,DWORD size)
{
  void* t = HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, size);
  //GlobalAlloc(GPTR, size);
  assert(t);
  return t;
}

DWORD randseed = GetTickCount();

DWORD __cdecl my_random(DWORD,DWORD range)
{
  return
    range == 0 ? 0 : (randseed = randseed * 214013 + 2531011) % range;
}

void main(int argc, char* argv[])
{
  /***********/
  id1();                // register
  id2();
  id3();
  id4();
  /***********/

  printf("REVERT 1.00  PE-EXE/DLL revertor  based on MISTFALL %s engine  (x) 2000\n", MISTFALL_VERSION);

  if ((argc != 2) && (argc != 3))
  {
    printf("\nsyntax: REVERT [infile.EXE [outfile.EXE]]\n");
    exit(0);
  }

  char *ifile, *ofile;

  if (argc==2)
  {
    ifile = argv[1];
    ofile = (char*)malloc(strlen(ifile)+16);
    strcpy(ofile, ifile);
    char* c = strrchr(ofile,'.');
    if (c) *c = 0;
    strcat(ofile, "!.exe");
  }

  if (argc==3)
  {
    ifile = argv[1];
    ofile = argv[2];
  }

  printf("� reading %s\n", ifile);
  FILE*f=fopen(ifile,"rb");
  assert(f);
  DWORD bufsize = filelength(fileno(f));
  DWORD maxbufsize = bufsize * 2 + 131072;
  BYTE* buf = new BYTE[maxbufsize];
  assert(buf);
  fread(buf, 1,bufsize, f);
  fclose(f);

  int res;

  __try
  {
  res = engine(0x12345678,      // user-parameter
               buf,             // buffer
               bufsize,         // input buffer size
               &bufsize,        // ptr to output buffer size
               maxbufsize,      // maximal buffer size
               my_disasm,       // disassembler
               my_malloc,       // malloc
               my_random,       // random
               my_mutate        // mutator
              );
  }
  __except (1)
  {
  res = -1;
  }

  printf("  engine() returns %s\n",
    res == -1           ? "***EXCEPTION***" :
    res == ERR_SUCCESS  ? "success" :
    res == ERR_BADFILE  ? "ERR_BADFILE" :
    res == ERR_NOMEMORY ? "ERR_NOMEMORY" :
    res == ERR_SHORTSUX ? "ERR_SHORTSUX":
    res == ERR_MUTATE   ? "ERR_MUTATE" :
    res == ERR_1        ? "ERR_1" :
    "???");

  if (res==ERR_SUCCESS)
  {

    printf("� writing %s\n", ofile);
    f=fopen(ofile,"wb");
    assert(f);
    fwrite(buf, 1,bufsize, f);
    fclose(f);

  }

  printf("� exiting\n");
}
