
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <io.h>
#pragma hdrstop

void process_range(FILE*f,DWORD x, DWORD y)
{
  fprintf(f, "%08x,%08x,%d.%d.%d.%d,%d.%d.%d.%d\n",
      x,
      y,
      (x>>24)&0xFF,
      (x>>16)&0xFF,
      (x>>8)&0xFF,
      x&0xFF,
      (y>>24)&0xFF,
      (y>>16)&0xFF,
      (y>>8)&0xFF,
      y&0xFF );
}

void process_data(FILE*f,BYTE* buf, int len,int v)
{
//  int count = size / 6;
//  DWORD old_a = 0;
//  for(int i=0; i<count; i++)
//  {
//    DWORD a = (buf[count*0+i] << 16) |
//              (buf[count*1+i] <<  8) |
//               buf[count*2+i];
//    a += old_a;
//    DWORD d = (buf[count*3+i] << 16) |
//              (buf[count*4+i] <<  8) |
//               buf[count*5+i];
//    old_a = a;
//    a <<= 8;
//    d = (d << 8);
//    d += a;
//    d |= 0xFF;
//
//    process_range(a, d);
//  }

  int count = len / 6;

  BYTE* tmp = new BYTE[ len+1 ];
  assert(tmp);

//  if (v==4)
//  {
//    memset(tmp,0,len);
//    for(DWORD y=0; y<6; y++)
//    for(DWORD x=0; x<count/8; x++)
//    for(DWORD i=0; i<8; i++)
//    for(DWORD j=0; j<8; j++)
//      tmp[y+(x*8+j)*6] |= ((buf[(y*8+i)*(count/8)+x] >> j) & 1) << i;
//    memcpy(buf,tmp,len);
//    v = 1;
//  }

  if (v==3)
  {
    for(DWORD y=0; y<6; y++)
    for(DWORD x=0; x<count/2; x++)
    {
      tmp[y+(x*2+0)*6] = (buf[(y*2+0)*(count/2)+x] & 0xf0) | (buf[(y*2+1)*(count/2)+x]>>4);
      tmp[y+(x*2+1)*6] = (buf[(y*2+0)*(count/2)+x] <<   4) | (buf[(y*2+1)*(count/2)+x]&15);
    }
    memcpy(buf,tmp,len);
    v = 1;
  }

//  if (v==2)
//  {
//    for(DWORD y=0; y<6; y++)
//    for(DWORD x=0; x<count; x++)
//      tmp[x*6+y] = buf[y*count+x];
//    memcpy(buf,tmp,len);
//    v = 1;
//  }

  delete tmp;

  if (v==1)
  {
    DWORD addr  = 0;
    DWORD ptr   = 0;
    while(count--)
    {
      DWORD a = (buf[ptr+0]<<24) | (buf[ptr+1]<<16) | (buf[ptr+2]<<8);
      DWORD d = (buf[ptr+3]<<24) | (buf[ptr+4]<<16) | (buf[ptr+5]<<8);
      addr += a;
      d    += addr - 1;
      if (count == 0 && addr == 0) break;

      a = addr;
      fprintf(f,"%08x,%08x,%d.%d.%d.%d,%d.%d.%d.%d\n",
        a,
        d,
        a>>24,(a>>16)&0xff,(a>>8)&0xff,a&0xff,
        d>>24,(d>>16)&0xff,(d>>8)&0xff,d&0xff );

      ptr += 6;
    }
  }

}

void main(int argc, char* argv[])
{
  if (argc!=3)
  {
    printf("syntax: EXPAND <binary-in-file> <text-out-file>\n");
    exit(0);
  }
  char* infile  = argv[1];
  char* outfile = argv[2];

  printf("+ reading: %s\n", infile);

  FILE*f=fopen(infile,"rb");
  assert(f);
  int len = filelength(fileno(f));
  BYTE* buf = new BYTE[ len+1 ];
  fread(buf,1,len,f);
  fclose(f);

  printf("+ writing: %s\n", outfile);

  f=fopen(outfile,"wb");
  assert(f);

  process_data(f,buf,len,3);

  fclose(f);
  delete buf;

} // main
