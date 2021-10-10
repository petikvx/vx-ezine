#include <stdio.h>
#include <stdlib.h>
#include <io.h>

typedef unsigned char       BYTE;
typedef unsigned short      WORD;
typedef unsigned long       DWORD;

#define SIGN1  'SBGN'
#define SIGN2  'SEND'

#define swap(x,y)  {int t=x; x=y; y=t;}


typedef struct _count {
   		DWORD	k;
        	BYTE  cnt;
      	       } count;


int s11=0,s12=0,repeat_s;
FILE* f;
BYTE  *buf;
DWORD *used,*regs;
count *a;
int l,scnt,i,r,k;
DWORD curEAX;
int uindex;
int s,first;

int main(int argc,const char* argv[])
{

	if (argc!=3)
	{
		printf("Invalid parameters.\nUssage:\n\n stospack.exe <in.file>,<out.file>\n");
		exit(1);
	}

	if ((f=fopen(argv[1],"rb"))==NULL)
	{	printf("Stospack: File reading error!\n");
		exit(1);
	}

	l=filelength(fileno(f));
	buf=(BYTE*)malloc(l);
	fread(buf,1,l,f);
	fclose(f);

	for (i=0;i<l;i++)
	{
		if (*(DWORD*)&buf[i]==SIGN1) s11=i+4;
		if (*(DWORD*)&buf[i]==SIGN2) s12=i;
	}

	if ((f=fopen(argv[2],"wb"))==NULL)
	{
		printf("Stospack: File creating error!\n");
		exit(1);
	}

	fprintf(f,";께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�\r\n");
	fprintf(f,"	pushad\r\n");
	fprintf(f,"	mov edi,[esp+9*4]\r\n\r\n");

//----------------------------------------------------------------------------

	scnt=(s12-s11)/4;
	if ((s12-s11)%4 != 0) scnt++;

	used=(DWORD*)malloc(scnt*4);
	regs=(DWORD*)malloc(scnt*4);
	a=(count*)malloc(scnt*sizeof(count));

//	printf("Cnt=====%i\n",scnt);

	for (i=0;i<scnt;i++)
	{
		used[i]=0;                            // 
		a[i].cnt=0;                           // Clear count bufer
		a[i].k=0;                             //
	}

	uindex=0;
	for (i=s11;i<s12;i+=4)
	{
   		if (*(DWORD*)&buf[i]!=*(DWORD*)&buf[i+4])
			used[uindex++]=*(DWORD*)&buf[i];

	}

	for (r=scnt/2;r>0;r/=2)
		for (i=r;i<scnt;i++)
	    		for (k=i-r;(k>=0) && (used[k]>used[k+r]);k-=r)
				swap(used[k],used[k+r]);

	i=0;
	while (i<scnt)
	{
   		a[i].k=used[i];
   		k=i;
   		r=0;

   		while ((used[i]==used[k])&&(used[i]!=0xFFFFFFFF)&&(used[i]!=0x0))
		{
			r++;
			k++;
		}

		if (r==0) r++;
   		a[i].cnt=r;
   		i=i+r;
 }

#define swap(x,y)  {count t=x; x=y; y=t;}

	for (r=scnt/2;r>0;r/=2)
		for (i=r;i<scnt;i++)
	    		for (k=i-r;(k>=0) && (a[k].cnt<a[k+r].cnt);k-=r)
				swap(a[k],a[k+r]);

	fprintf(f,"	mov ebx,0%08Xh\r\n",a[0].k);
	fprintf(f,"	mov edx,0%08Xh\r\n",a[1].k);
	fprintf(f,"	mov esi,0%08Xh\r\n",a[2].k);
	fprintf(f,"	mov ebp,0%08Xh\r\n",a[3].k);

	s=s11;
	first=1;
	randomize();
	while (s<s12-1)
	{
		if (*(DWORD*)&buf[s]==a[0].k)
   		{
   			fprintf(f,"	mov eax,ebx\r\n");
			curEAX=*(DWORD*)&buf[s];
   		}

   		else if(*(DWORD*)&buf[s]==a[1].k)
		{
   			fprintf(f,"	mov eax,edx\r\n");
			curEAX=*(DWORD*)&buf[s];
     		}

		else if(*(DWORD*)&buf[s]==a[2].k)
		{
   			fprintf(f,"	mov eax,esi\r\n");
			curEAX=*(DWORD*)&buf[s];
     		}

   		else if(*(DWORD*)&buf[s]==a[3].k)
		{
   			fprintf(f,"	mov eax,ebp\r\n");
			curEAX=*(DWORD*)&buf[s];
     		}

   		else
   		{
			if (*(DWORD*)&buf[s]==0xFFFFFFFF)
   			{
   				fprintf(f,"	xor eax,eax\r\n");
   				fprintf(f,"	dec eax\r\n");
				curEAX=0xFFFFFFFF;
	        	}
			else
			{

				if (first){fprintf(f,"	mov eax,0%08Xh\r\n",*(DWORD*)&buf[s]);
			  		curEAX=*(DWORD*)&buf[s];first=0;}

				else	{
		
					switch (random(3)) {


						case 0:{ 
						fprintf(f,"	xor eax,0%08Xh\r\n",curEAX^*(DWORD*)&buf[s]);
					  	curEAX=*(DWORD*)&buf[s]; 
			  			break;}

						case 1:{ fprintf(f,"	sub eax,0%08Xh\r\n",curEAX-*(DWORD*)&buf[s]);
			  			curEAX=*(DWORD*)&buf[s]; 
			  			break;}

						case 2:{ fprintf(f,"	add eax,0%08Xh\r\n",*(DWORD*)&buf[s]-curEAX);
			  			curEAX=*(DWORD*)&buf[s]; 
			  			break;}
				   			    }
					}
			}
   		}

		repeat_s=1;
		for (i=0;;i++)
    		{
	   		if (*((DWORD*)&buf[s+i*4])==*((DWORD*)&buf[s+(i+1)*4]))
				repeat_s++;
	      		else break;
    		}

	   	s+=repeat_s*4;

	 	if (repeat_s >=5)
		{
	  	 	fprintf(f,"	push %i \r\n	pop ecx\r\n",repeat_s);
	  	 	fprintf(f,"	rep stosd \r\n");
	   	}
		else
			for (;repeat_s!=0;repeat_s--) 
				fprintf(f,"	stosd\r\n");
	}

	fprintf(f,"\r\n	popad\r\n	ret\r\n\r\n");
   	fclose(f);

   	free(a);
   	free(used);
   	free(regs);
   	free(buf);
  	return 0;
}
