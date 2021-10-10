/*
 Huffman compresser
         with dynamic scheme

 (d) 451 2002/03
*/

#include <stdio.h>
#include <stdlib.h>
#include <io.h>
#include <string.h>
#include "huffman.h"

dword size1,size2,index;
struct tree_node hhtables[513];
FILE *f;

void main(int argc,char *argv[])
{

if (argc!=4)
{
printf("\nDynamic Huffman compressing program (c) 451 2002/03\n");
printf("Ussage : huffman.exe [/d][/c] src dest\n /c-compress\n /d-decompress\n");
exit(1);
}

if ((f=fopen(argv[2],"rb"))==NULL){printf("File opening error!\n");exit(1);}
int l=filelength(fileno(f));

byte* in_buf= new byte[l+33];
byte* out_buf= new byte[l*10];


if (!strcmp(argv[1],"/c"))
 {

	fread(in_buf,1,l,f);
	fclose(f);

	printf("Init...\n");
	index=huffman_init(in_buf,hhtables,l);

	printf("Tree size = %i*6 = %i\n",index,index*6);

	printf("Compress...\n");
	size1=huffman_compress(hhtables,in_buf,out_buf,index,l);

	if ((f=fopen(argv[3],"wb"))==NULL){printf("File creating error!\n");exit(1);}

	index++;
	fwrite(&size1,4,1,f);      			//write index
	fwrite(&index,4,1,f);      			//write index
   fwrite(hhtables,6,index,f);         //write table
	fwrite(out_buf,1,(size1/8+1),f);
	fclose(f);
 }
 else if (!strcmp(argv[1],"/d"))
 {

   fread(&size1,4,1,f);
   fread(&index,4,1,f);
   fread(hhtables,6,index,f);
	fread(in_buf,1,(l-6*index),f);
   index--;

   printf("index:%i\n",index);

	fclose(f);

	printf("Decompress...\n");
	size2=huffman_decompress(hhtables,in_buf,out_buf,index,size1);

	if ((f=fopen(argv[3],"wb"))==NULL){printf("File creating error!\n");exit(1);}
	fwrite(out_buf,1,size2,f);
	fclose(f);
 }

delete in_buf;
delete out_buf;
}
