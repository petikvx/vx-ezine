//coded by DR-EF

#include <stdafx.h>	//remove if none win32


#include <stdio.h>
#include <string.h>


int main(int argc, char* argv[])
{
	char inputf[50],outputf[50];
	FILE *fin,*fout;
	int xch,xline=1;


	printf("Enter File Name:");
	scanf("%s",&inputf);

	strcpy(outputf,inputf);
	strcat(outputf,".asm_db");

	fin=fopen(inputf,"rb");

	if(fin)
	{
		fout=fopen(outputf,"wb");

		if(fout)
		{

			fprintf(fout,"db ");

			xch=fgetc(fin);

			if(xch!=EOF && xch<=0xF)
				fprintf(fout,"00%xh",xch);
			else if (xch!=EOF)
				fprintf(fout,"0%xh",xch);

			goto g_next;

			do
			{
				if(xline!=1)
					fputc(',',fout);

				if(xch!=EOF && xch<=0xF)
					fprintf(fout,"00%xh",xch);
				else if (xch!=EOF)
					fprintf(fout,"0%xh",xch);

				if(xline==15)
				{
					fprintf(fout,"\r\ndb ");
					xline=0;
				}

g_next:

				xch=fgetc(fin);

				xline++;

			}while(xch!=EOF);


			fclose(fout);
		}

		fclose(fin);
	}


	return 0;
}