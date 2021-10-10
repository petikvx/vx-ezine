#include <stdio.h>
#include <io.h>
#include <stdlib.h>
#include <string.h>

typedef unsigned char       BYTE;
typedef unsigned short      WORD;
typedef unsigned long       DWORD;

#define __S11  'SBGN'
#define __S12  'SEND'

unsigned int s11=0,s12=0;
char ct_name1[256]; 
char ct_name2[256]; 
char ct_cfgname[256]; 
FILE *f,*h,*cfg;


void  main(int argc,const char *argv[])
{

	if (argc!=3)
	{printf("Invalid parameters.\nUssage:\n\n ct.exe <in.name>,<out.name>\n");
	exit(1);}


	strcpy(ct_name1,argv[2]);
	strcpy(ct_name2,argv[2]);
	strcpy(ct_cfgname,argv[2]);

	strcat(ct_name1,".inc");
	strcat(ct_name2,".c");
	strcat(ct_cfgname,".cfg");

        if ((f=fopen(argv[1],"rb"))==NULL) {printf("File opening error!\n"); exit(0);}

        unsigned int l=filelength(fileno(f));;
        BYTE* buf =(BYTE*)malloc(l);
	fread(buf,1,l,f);
   	fclose(f);


   	for (unsigned int i=0;i<l;i++)
   	{
        if ( *(DWORD*)&buf[i] == __S11 ) s11=i+4;
        if ( *(DWORD*)&buf[i] == __S12 ) s12=i;
   	}

   	unsigned int i=0,k=0;

   	if ((f=fopen(ct_name1,"wb"))==NULL)   // Asm include
           {printf("File #1 creating error!\n"); exit(0);}

   	if ((h=fopen(ct_name2,"wb"))==NULL)     // C include
	   {printf("File #2 creating error!\n"); exit(0);}	

   	if ((cfg=fopen(ct_cfgname,"rb"))!=NULL) // Config
	   {

        	l=filelength(fileno(cfg));;
        	BYTE* cfgbuf =(BYTE*)malloc(l);
		fread(cfgbuf,1,l,cfg);
   		fclose(cfg);

		for (int j=0;j<5;j++)
		{	
			for (i=0;i<l;i++)
	 			if (cfgbuf[k+i]==0x0D) break;
				fwrite(&cfgbuf[k],1,i+2,f);
			k+=i+2;
		}

		for (int j=0;j<5;j++)
		{	
			for (i=0;i<(l-k-2);i++)
	 			if (cfgbuf[k+i]==0x0D) break;
				fwrite(&cfgbuf[k],1,i+2,h);
			k+=i+2;
		}
	free(cfgbuf);
	}

        fprintf(f,"\r\n; Size = %i\r\n",s12-s11-1);
        fprintf(f,"%s:\r\n",argv[2]);

        fprintf(h,"\r\n// Size = %i\r\n",s12-s11-1);
        fprintf(h,"BYTE _%s[] = { \r\n         ",argv[2]);

   for(i=0;i<(s12-s11);i++)
        {
                if (i%10 == 0) {
                                fprintf(f,"\r\n         db ");
                                if (i) fprintf(h,",\r\n         ");
                                }

                fprintf(f,"0%02Xh",buf[s11+i]);
                fprintf(h,"0x%02X",buf[s11+i]);
                if ((i%10 != 9)&&(i!=(s12-s11-1))) {fprintf(f,",");fprintf(h,",");}
        }

//------------------------------------------------------------------------------

      fprintf(h,"\r\n };");
      fclose(f);
      fclose(h);
      free(buf);

}
