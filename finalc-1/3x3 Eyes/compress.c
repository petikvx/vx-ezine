/*
        ffh RLE for Win32.3x3Eyes...
        Coded by Bumblebee[UC].

         in:  3x3.bmp
        out:  3x3.inc
*/
#include<stdio.h>

#define BYTE    unsigned char
#define WORD    unsigned short

void
main(void)
{
  FILE *fd_in,*fd_out;
  BYTE buffer[512];
  BYTE rep,lin;
  WORD count,i;

  fd_in=fopen("3x3.bmp","rb");
  fd_out=fopen("3x3.inc","wt");

  lin=1;
  while(!feof(fd_in)) {
        if(lin!=0)
                fprintf(fd_out,"\n\tdb  ");
        count=fread(buffer,sizeof(BYTE),512,fd_in);

        for(i=0,lin=0;i<count;i++) {
                if(buffer[i]==0xff) {
                        i++;
                        for(rep=0;rep<255 && rep+i<count
                                && buffer[i+rep]==0xff;rep++);
                        fprintf(fd_out,"0ffh,0%xh",rep);
                        i--;
                        i+=rep;
                        lin+=2;
                } else {
                        fprintf(fd_out,"0%xh",buffer[i]);
                        lin++;
                  }
                if(lin>12) {
                        lin=0;
                        fprintf(fd_out,"\n\tdb  ");
                } else {
                        if(i<count-1)
                                fprintf(fd_out,",");
                  }
        }
  }

  fclose(fd_in);
  fclose(fd_out);
}
