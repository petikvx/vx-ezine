
// RSA key generator
// (x) 2000 Z0MBiE

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <windows.h>
#include <conio.h>

#pragma hdrstop

#include "vlong.cpp"
#include "rsa.cpp"

#include "random.cpp"

void fdump_vlong(FILE*f, char* s, const vlong &x, unsigned long maxlen)
{
  fprintf(f,"rsa_%s label dword ; %i dword(s)\n",s,x.value->z);
  for (unsigned i=0; i<x.value->z; i++)
    fprintf(f,"dd 0%08Xh\n",x.value->a[i]);
  for (unsigned i=x.value->z; i<maxlen; i++)
    fprintf(f,"dd 0\n");
  fprintf(f,"\n");
}

void help()
{
  printf("\nsyntax:\n  KEYGEN keylengthinbits timer|keyboard filename.inc\n");
  exit(0);
}

void main(int argc, char* argv[])
{
  randseed = GetTickCount();
  printf("RSA KEYGEN  (x) 2000 Z0MBiE  http://z0mbie.cjb.net\n");

  if (argc!=4) help();

  unsigned keylen = atol(argv[1]);
  int usetimer = !stricmp(argv[2],"timer");
  char* keyfile = strdup(argv[3]);

  private_key key;

  unsigned long rsize = (keylen+15)/16;
  char* r1 = (char*)malloc(rsize+1);
  char* r2 = (char*)malloc(rsize+1);
  r1[rsize]=0;
  r2[rsize]=0;

  if (usetimer)
  {
    for (unsigned long i=0; i<rsize; i++)
    {
      r1[i]=1+my_random(255);
      r2[i]=1+my_random(255);
    }
    //printf("r1=[%s]\n",r1);
    //printf("r2=[%s]\n",r2);
  }
  else
  {
    printf("þ now put your ass onto keyboard and jump...\n");
    for (int j=0; j<2; j++)
    for (unsigned long i=0; i<rsize; i++)
    {
      printf("%5i of %5i\x0D",j*rsize+i,rsize*2);
      unsigned long t = GetTickCount();
      char c = getch();
      t -= GetTickCount();
      c ^= t;
      c += c==0;
      if (j) r1[i]=c; else r2[i]=c;
    }
  }

  printf("þ generating keys...\n");

  key.create(r1,r2);

  vlong d = modinv( key.e, (key.p-(vlong)1)*(key.q-(vlong)1) );

#define MAX(a,b)        a>b?a:b
  unsigned long maxlen = MAX(key.m.value->z, d.value->z);

  printf("þ writing %s...\n", keyfile);
  FILE*f=fopen(keyfile,"wb");
  assert(f);
  fprintf(f,"; GENERATED FILE. DO NOT EDIT!\n\n");
  fprintf(f,"rsa_bit equ %i\n\n", maxlen * 32);
  fdump_vlong(f,"n",key.m, maxlen);
  fdump_vlong(f,"e",key.e, maxlen);
  fdump_vlong(f,"d",d, maxlen);
  fclose(f);

  printf("þ testing key (encrypting/decrypting string)...\n");
  vlong x = from_str("abc");
  vlong y = key.encrypt(x);
  vlong z = key.decrypt(y);
  printf(((x.value->z==z.value->z)&&(x.value->a[0]==z.value->a[0])) ?
         "þ success\n":"***ERROR***\n");
}
