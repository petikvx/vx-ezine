
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <io.h>

#define infile   "..\\..\\example\\cpp\\example.exe"
#define outfile1 "..\\..\\rpme\\rpme-krn.inc"
#define outfile2 "..\\..\\rpme\\rpme-mut.inc"

void makefile(char*ofile, byte*buf, int idx1,int idx2, char*msg1,char*msg2)
{
  printf("þ writing %s\n", ofile);
  printf("  %i byte(s) of CODE\n",idx2-idx1+1);
  FILE*f=fopen(ofile,"wb");
  fprintf(f,"; ===========================================================================\n");
  fprintf(f,"; %s\n", msg1);
  fprintf(f,"; %i byte(s)\n",idx2-idx1+1);
  fprintf(f,"; GENERATED FILE. DO NOT EDIT!\n");
  fprintf(f,"; ---------------------------------------------------------------------------\n");
  fprintf(f,"%s:\n",msg2);
  for (int i=idx1,j=0; i<=idx2; i++,j++)
  {
    if ((j%8)==0) fprintf(f,"db\x09"); else fprintf(f,",");
    fprintf(f,"0%02Xh",buf[i]);
    if (((j%8)==7)||(i==idx2))
    fprintf(f,"\n");
  }
  fprintf(f,"; ===========================================================================\n");
  fclose(f);
}

void main()
{
  FILE*f=fopen(infile,"rb");
  if (!f)
  {
    printf("***ERROR***: cant open %s\n", infile);
    return;
  }
  DWORD bufsize=filelength(fileno(f));
  printf("þ reading %s, %i byte(s)\n",infile,bufsize);
  BYTE*buf=(BYTE*)malloc(bufsize);
  fread(buf,1,bufsize,f);
  fclose(f);

  int index[256];
  int icount=0;
  for (DWORD i=0; i<bufsize-10; i++)
  {
    if (buf[i+0]==0xEB)
    if (buf[i+1]==0x02)
    if (buf[i+2]==0xFF)
    {
      printf("þ id%i found at %08X\n",buf[i+3],i);
      index[buf[i+3]]=i;
      icount++;
    }
  }

  if (icount!=4)
  {
    printf("***ERROR***: some signature(s) not found\n");
    return;
  }

  makefile(outfile1, buf, index[1]+5,index[2]-1, "Real Permutating Engine (RPME) 1.00 -- kernel","engine");
  makefile(outfile2, buf, index[3]+5,index[4]-1, "Real Permutating Engine (RPME) 1.00 -- mutator","mutate" );

}
