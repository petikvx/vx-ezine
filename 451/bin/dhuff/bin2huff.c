#include <stdio.h>
#include <io.h>

typedef unsigned char       BYTE;
typedef unsigned short      WORD;
typedef unsigned long       DWORD;

#define SIGN1 	 	'[S1]'
#define SIGN2  		'[S2]'

#define SIGN11	  	'[S11'
#define SIGN22	 	'[S22'

#define SIGN111	  	'S111'
#define SIGN222	  	'S222'

   int to1=0,to2=0,o1=0,o2=0,xo1=0,xo2;

int main(void)
{
	FILE *f;
	if ((f=fopen("huffman.exe","rb"))==NULL){printf("File opening error!\n"); return 1;}
	int l=filelength(fileno(f));
	BYTE* buf= new BYTE[l];

   fread(buf,1,l,f);
   fclose(f);

   for (int i=0;i<l;i++)
   {
   	if ( *(DWORD*)&buf[i] == SIGN1 )   to1=i+4;
   	if ( *(DWORD*)&buf[i] == SIGN2 )   to2=i;

   	if ( *(DWORD*)&buf[i] == SIGN11 )  o1=i+4;
   	if ( *(DWORD*)&buf[i] == SIGN22 )  o2=i;

   	if ( *(DWORD*)&buf[i] == SIGN111 ) xo1=i+4;
   	if ( *(DWORD*)&buf[i] == SIGN222 ) xo2=i;
   }

   f=fopen("huffbin.inc","wb");				//asm include


	fprintf(f,";===================================================================\r\n");
	fprintf(f,";  Dynamic Huffman compress/decompress library\r\n");
	fprintf(f,";  size is %i + %i + %i bytes\r\n",to2-to1-1,o2-o1-1,xo2-xo1);
	fprintf(f,";===================================================================\r\n");
	fprintf(f,"huffman_init:");

   for(int i=0;i<(to2-to1);i++)
  	{
		if (i%10 == 0)	fprintf(f,"\r\n		db ");
			
	        fprintf(f,"0%02Xh",buf[to1+i]);
		if ((i%10 != 9)&&(i!=(to2-to1-1))) fprintf(f,",");
        }

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	fprintf(f,"\r\nhuffman_compress:");


   for(int i=0;i<(o2-o1);i++)
  	{
		if (i%10 == 0) fprintf(f,"\r\n		db "); 
			
	        fprintf(f,"0%02Xh",buf[o1+i]);
		if ((i%10 != 9)&&(i!=(o2-o1-1))) fprintf(f,",");
   }

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	fprintf(f,"\r\nhuffman_decompress:");


   for(int i=0;i<(xo2-xo1);i++)
  	{
		if (i%10 == 0) fprintf(f,"\r\n		db "); 
			
	        fprintf(f,"0%02Xh",buf[xo1+i]);
		if ((i%10 != 9)&&(i!=(xo2-xo1-1))) fprintf(f,",");
   }


      delete buf;
      fclose(f);
      return 0;
}
