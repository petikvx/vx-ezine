#include <stdio.h>
#include <windows.h>

#include "armpoly.c"

unsigned long rnd(unsigned long range){
  return (unsigned long)(rand()%range);
}

unsigned char text[]="0000111122223333";

int main(){
  unsigned char *host;
  unsigned long newentry,size;
  POLY_STRUCT ps;
  FILE *f;

  host=GlobalAlloc(GPTR,4*1024);
  srand(GetTickCount());
  ps.random=(RANDOM)&rnd;
  size=poly(host,(unsigned char *)&text,16,0,&newentry,&ps);
  if((f=fopen("poly.bin","wb"))){
    fwrite(host,1,size,f);
    fclose(f);
  }
  printf("engine size=%d\n",poly_size());
  printf("gen size=%d\n",size);
  printf("encryption=%s\nptr_direction=%s\ncnt_direction=%s\nmix1=%s\nmix2=%s\nmix3=%s\nmix4=%s\nstep=%s\n",
    (ps.opt&P_ENCTYPE)?"ADD":"SUB",
    (ps.opt&P_PTRDIR)?"UP":"DOWN",
    (ps.opt&P_CNTDIR)?"UP":"DOWN",
    (ps.opt&P_INV1)?"0":"0",
    (ps.opt&P_INV2)?"0":"1",
    (ps.opt&P_INV3)?"0":"1",
    (ps.opt&P_INV4)?"0":"1",
    (ps.opt&P_DWORD)?"DWORD":"BYTE"
  );
  GlobalFree(host);
  return 0;
}