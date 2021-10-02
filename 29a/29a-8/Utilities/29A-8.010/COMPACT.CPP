
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <io.h>
#pragma hdrstop

#define MAXIP   1000000

#define MIN(a,b)        ((a)<(b)?(a):(b))
#define MAX(a,b)        ((a)>(b)?(a):(b))
#define IP_STR(x)       (((x)>>24)&255), (((x)>>16)&255), (((x)>>8)&255), ((x)&255)

DWORD range[MAXIP][2];
BYTE x1[MAXIP][6];
//BYTE x1t[MAXIP][6];
//BYTE x2[6][MAXIP];
BYTE x3[6*2][MAXIP];
//BYTE x4[6*8][MAXIP];

void main(int argc, char* argv[])
{
  if (argc!=4&&argc!=5)
  {
    printf("syntax: COMPACT all_ip.lst <+->xx[;yy[;zz[...]]] <bin-out-file> [txt-out-file]\n");
    printf("        ** instead of country means unused address (not listed in src bases)\n");
    printf("example:\n");
    printf("        compact all_ip.lst +** binfile      -- only unused space\n");
    printf("        compact all_ip.lst -** binfile      -- all except unused space\n");
    printf("        compact all_ip.lst +FR;DE binfile   -- only fr && de countries\n");
    printf("        compact all_ip.lst -RU;CN binfile   -- all except ru/cn\n");
    exit(0);
  }
  char* all_ip  = argv[1];
  char* cy_mask = argv[2];
  assert(cy_mask[0] == '+' || cy_mask[0] == '-');
  char* outfile = argv[3];
  char* txtfile = argc==5?argv[4]:NULL;

  printf("+ reading: '%s', search for country='%s'\n", all_ip, cy_mask);

  FILE*f=fopen(all_ip, "rb");
  assert(f);

  DWORD old_a = 0, old_d = 0, old_b = 0;
  DWORD count = 0, sum = 0;
  memset(x1,0,sizeof(x1));
  for(;;)
  {
    static char s[1024], src[1024], cn[1024];
    if (fgets(s,sizeof(s),f)==NULL) break;
    while(s[0]&&(s[strlen(s)-1]<32)) s[strlen(s)-1]=0;
    if (s[0]&&(s[0]!='#'))
    {
      DWORD a,b,a1,a2,a3,a4, b1,b2,b3,b4, dt, cn1,cn2;
      assert(sscanf(s,"%x,%x,%d.%d.%d.%d,%d.%d.%d.%d,%d,%c%c,%s",
                      &a,&b,
                      &a1,&a2,&a3,&a4,
                      &b1,&b2,&b3,&b4,
                      &dt,
                      &cn1,&cn2,
                      src)==14);
      assert(a == ((a1<<24)|(a2<<16)|(a3<<8)|a4));
      assert(b == ((b1<<24)|(b2<<16)|(b3<<8)|b4));
      cn[0]=cn1;
      cn[1]=cn2;
      cn[2]=0;
      int match = strstr(cy_mask,cn) != NULL;

      if ( ((cy_mask[0] == '+') && ( match)) ||
           ((cy_mask[0] == '-') && (!match)) )
      {

        a &= 0xffffff00;
        b |= 255;

        if (count)
        {
          if (a <= (range[count-1][1]+1))
          {
            a = MIN(a, range[count-1][0]);
            b = MAX(b, range[count-1][1]);
            count--;
          }
        }

        assert(count < MAXIP);
        range[count][0] = a;
        range[count][1] = b;
        count++;

      }
    }
  }
  fclose(f);

  FILE*of=NULL;
  if (txtfile)
  {
    of=fopen(txtfile, "wb");
    assert(of);
    for(int t=0; t<count; t++)
    {
      DWORD a = range[t][0];
      DWORD b = range[t][1];
      fprintf(of,"%08x,%08x,%d.%d.%d.%d,%d.%d.%d.%d\n",
        a,b,IP_STR(a),IP_STR(b) );
    }
    fclose(of);
  }

  if (count & 1)
  {
    range[count][0] = 0;
    range[count][1] = 255;
    count++;
  }

  DWORD a0 = 0;
  for(int t=0; t<count; t++)
  {
    DWORD a = range[t][0];
    DWORD b = range[t][1];

    DWORD d = b - a + 1;

    sum += d;

    assert( (a&0xFF)==0x00 );
    assert( (d&0xFF)==0x00 );
    x1[t][0] = (a-a0)>>24;
    x1[t][1] = (a-a0)>>16;
    x1[t][2] = (a-a0)>>8;
    x1[t][3] = (d)>>24;
    x1[t][4] = (d)>>16;
    x1[t][5] = (d)>>8;

    a0 = a;
  }

//  f=fopen("v1","wb");
//  assert(f);
//  fwrite(x1,1,count*6,f);
//  fclose(f);

  int x,y,i,j;

//  for(x=0; x<count; x++)
//  {
//    for(y=0; y<6; y++)
//    {
//      x2[y][x] = x1[x][y];
//    }
//  }
//
//  f=fopen("v2","wb");
//  assert(f);
//  for(i=0; i<6; i++)
//    fwrite(x2[i],1,count,f);
//  fclose(f);

  for(x=0; x<count/2; x++)
  {
    for(y=0; y<6; y++)
    {
      x3[y*2+0][x] = ((x1[x*2+0][y] >> 4) << 4) | (x1[x*2+1][y] >> 4);
      x3[y*2+1][x] = ((x1[x*2+0][y] & 0x0F) << 4) | (x1[x*2+1][y] & 0x0F);
    }
  }

  printf("+ writing file: '%s'\n", outfile);

  f=fopen(outfile,"wb");
  assert(f);
  for(i=0; i<6*2; i++)
    fwrite(x3[i],1,count/2,f);
  fflush(f);
  int fsz = filelength(fileno(f));
  fclose(f);

  printf("  %d entries, %u ip addresses, %d bytes\n", count, sum, fsz);

//  count&=~7; // one more lucky motherfuckers
//
//  memset(x4,0x00,sizeof(x4));
//  for(x=0; x<count/8; x++)
//    for(y=0; y<6; y++)
//      for(i = 0; i < 8; i++)
//      for(j = 0; j < 8; j++)
//        x4[y*8+i][x] |= ((x1[x*8+j][y] >> i) & 1) << j;
//
//  DWORD cx1=0,cx4=0;
//  for(x=0; x<count; x++)
//    for(y=0; y<6; y++)
//      for(i=0; i<8; i++)
//        if (x1[x][y] & (1<<i))
//          cx1++;
//  for(x=0; x<count/8; x++)
//    for(y=0; y<48; y++)
//      for(i=0; i<8; i++)
//        if (x4[y][x] & (1<<i))
//          cx4++;
//  assert(cx1==cx4);
//  memset(x1t,0,sizeof(x1t));
//  for(x=0; x<count/8; x++)
//    for(y=0; y<6; y++)
//      for(i = 0; i < 8; i++)
//      for(j = 0; j < 8; j++)
//        x1t[x*8+j][y] |= ((x4[y*8+i][x] >> j) & 1) << i;
//  assert(memcmp(x1,x1t,sizeof(x1))==0);
//
//  f=fopen("v4","wb");
//  assert(f);
//  for(i=0; i<6*8; i++)
//    fwrite(x4[i],1,count/8,f);
//  fclose(f);
//
//  assert(memcmp(x1,x1t,MAXIP*6)==0);

} // main
