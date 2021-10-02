
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <assert.h>
#include <io.h>
#pragma hdrstop

#define MAX_CHAIN       2
#define OPCODE_STEMMING                // XDE-based, used if defined.

#define snprintf _snprintf
#define vsnprintf _vsnprintf

#define LOG_TO_CONSOLE
#include "COMMON/log.cpp"
#include "COMMON/zalloc.cpp"
#include "COMMON/list.cpp"
#include "XDE/xde.c"
#include "MF/mistfall.hpp"
#include "MF/mistfall.cpp"

void process_chain(FILE*f, CMistfall* M, HOOY* h0, unsigned a0)
{

  HOOY* h = h0;
  int i = 0, j, n0 = 0;

  char t[MAX_CHAIN*64];
  t[0] = 0;

  while(h)
  {
    j = 0;

    if ((h->flags&(FL_LABEL|FL_CREF))==(FL_LABEL|FL_CREF))
    {
      // --- label in the middle of the chain ---
    }
    else
    if (h->flags&FL_OPCODE)
    {
      if (i==0)
      {
        // --- start of chain ---
      }

      // -- instruction in the chain --

      struct xde_instr diza;
      xde_disasm(h->dataptr, &diza);
#ifdef OPCODE_STEMMING
      memset(diza.addr_b, 0x00, 8);
      memset(diza.data_b, 0x00, 8);
      h->datalen = xde_asm(h->dataptr, &diza);
#endif

//    static char s[256];
//    dump_instr(h->dataptr, h->oldrva, s);
      if (i == 0)
        sprintf(t,"%02d ",h->datalen);
      if (i > 0)
        strcat(t, " ");
      for(int n=0; n<h->datalen; n++)
        sprintf(t+strlen(t), "%02X", h->dataptr[n]);

      if (i == MAX_CHAIN)
        break;

      if (n0 < 31 &&
          ( (h->datalen == 2 && h->dataptr[0] >= 0x70 && h->dataptr[0] <= 0x7f)
            ||
            (h->datalen == 6 && h->dataptr[0] == 0x0f && h->dataptr[1] >= 0x80 && h->dataptr[1] <= 0x8f) ) &&
          h->arg1 < M->pe->pe_imagesize &&
          M->fasthooy[h->arg1] != NULL)
      {

        if ((a0 & (1 << n0)) == 0)
        {
          h->dataptr[h->datalen==2?0:1] ^= 1;  // inverse jxx
          process_chain(f, M, h0, a0 | (1 << n0) );
          h->dataptr[h->datalen==2?0:1] ^= 1;  // restore jxx
        }
        else
        {
          j = 1;  // normal chain - skip jxx, inversed chain - follow jxx
        }

        n0++;   // # of jxx in the chain
      }

      i++;
      if (diza.flag & C_STOP)
      {
        if (diza.flag & C_REL)
        {
          j = 1; // follow jmp
        }
        else
        {
          // --- end of chain ---
          break;
        }
      }
    }
    else
    {
      // --- end of chain ---
      break;
    }

    h = j ? M->fasthooy[h->arg1] : h->next;
  }

  if (i)
  {
    fprintf(f, "%s\n", t);
  }

}

void process_ctx(FILE*f, FILE*f2, CMistfall* M)
{

  HOOY* h;
  ForEachInList(M->HooyList, HOOY, h)
  {
    if (h->flags&FL_OPCODE)
    {

#ifdef OPCODE_STEMMING
      struct xde_instr diza;
      xde_disasm(h->dataptr, &diza);
      memset(diza.addr_b, 0x00, 8);
      memset(diza.data_b, 0x00, 8);
      h->datalen = xde_asm(h->dataptr, &diza);
#endif

      char t[1024];
      sprintf(t,"%02d ",h->datalen);
      for(int n=0; n<h->datalen; n++)
        sprintf(t+strlen(t), "%02X", h->dataptr[n]);
      fprintf(f2,"%s\n",t);

      process_chain( f, M, h, 0 );
    }
  }

} /* process_ctx() */

void main(int argc, char* argv[])
{
  //log("MISTFALL %s (REVERSER)\n", MISTFALL_VERSION);

  if (argc!=4)
  {
    log("syntax: %s files.lst outfile.txt outfile2.txt\n", argv[0]);
    return;
  }

  char* lstfile = argv[1];
  char* ofile = argv[2];
  char* ofile2 = argv[3];

  log("+ writing: %s\n", ofile);

  FILE*of=fopen(ofile,"wb");
  assert(of);

  log("+ writing: %s\n", ofile2);

  FILE*of2=fopen(ofile2,"wb");
  assert(of2);

  log("+ reading: %s\n", lstfile);

  FILE*f=fopen(lstfile,"rb");
  assert(f);

  static char t[1024];
  while(char*s=fgets(t,sizeof(t)-1,f))
  {
    while(s[0]&&s[strlen(s)-1]<=32) s[strlen(s)-1]=0; // strip \r\n

    log("+ reading: %s\n", s);

    CMistfall* M1 = new CMistfall;
    assert(M1);

    int res = M1->LoadFile(s);
    if (res != MF_ERR_SUCCESS)
    {
      log("CMistfall::LoadFile('%s') error %i\n", s, res);
    }
    else
    {
      res = M1->Disasm(/*DF_FIXUPSREQUIRED |*/
                       /*DF_STDSECT        |*/
                       /*DF_CODEFIRST      |*/
                       /*DF_DISABLEDISASM  |*/
                       /*DF_TRY_DREF       |*/
                       /*DF_TRY_RELREF     |*/
                       /*DF_ENABLE_ERRDISASM*/
                       0);

      if (res != MF_ERR_SUCCESS)
      {
        log("CMistfall::Disasm() error %i\n", res);
      }
      else
      {
        res = M1->N_Asm(1);
        if (res != MF_ERR_SUCCESS)
        {
          log("CMistfall::N_Asm() error %i\n", res);
        }
        else
        {

          process_ctx(of,of2,M1);

        }
      }
    }
    delete M1;
  }

  fclose(f);
  fclose(of);
  fclose(of2);

  log("+ all ok, mem usage: ZCount=%i (%i max), ZTotal=%i (%i max)\n",
    ZCount, ZMaxCount,
    ZTotal, ZMaxTotal);

} /* main */

/* EOF */
