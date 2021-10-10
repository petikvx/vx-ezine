
#include <stdio.h>
#include <string.h>

void err(int l)
{
	printf("Syntax error in line %u\n\n",l);
}



unsigned int in_cksum(unsigned char * addr,unsigned len)
{
	unsigned nleft=len;
	unsigned int *w=(unsigned int *) addr;
	unsigned long sum=0;
	unsigned int answer=0;

	while (nleft>1)
	{
		sum += *(w++);
		nleft -= 2;
	}
	if (nleft==1)
	{
		*(unsigned char *)(&answer)=*(unsigned char *)w; /* ? */
		sum += answer;
	}
	sum = (sum >> 16) + (sum & 0xffff);
	sum += (sum >> 16);
	answer=~sum;
	return(answer);
}
int main(int argc, char * * argv)
{
	FILE *fi, *fo;
	unsigned char s[200], b[2000], *p;
	unsigned int bc, t, l, isudp=0, udpstart, hsize, hsize4, i,
		     udpsize, fbc, isicmp, htemp, istcp,
		     ethstart=0;
	unsigned checksum,sum;

	if (argc!=3) /* was 2 */
	{
		puts("Syntax: doippkt [in] [out] \n\n");
		exit(1);
	}

	if ( !(fi=fopen(argv[1],"r")) || !(fo=fopen(argv[2],"wb")) )
	{
		puts("Troubles with i/o files \n\n");
		exit(1);
	}

	bc=0;
	l=1;
	for (;;l++)
	{
		if (!fgets(s,200,fi)) break;
		switch (s[0])
		{
			case '\n':
			case '\r':
			case '#': break;
			case 'c':
			{
				if (!sscanf(s+1,"%u",&t)) err(l);
				b[bc]= t;
				bc ++;
				break;
			}
			case 'u':
			{
				if (!sscanf(s+1,"%u",&t)) err(l);
				b[bc++]= t >> 8;
				b[bc]= t & 0xff;
				bc ++;
				break;
			}
			case 'b':
			{
				if (!sscanf(s+1,"%x",&t)) err(l);
				b[bc]=(unsigned char) t;
				bc ++;
				break;
			}
			case 'w':
			{
				if (!sscanf(s+1,"%x",&t)) err(l);
				b[bc++]= t >> 8;
				b[bc]= t & 0xff;
				bc ++;
				break;
			}
			case 's':
			{
				strcpy(b+bc,s+1);
				bc+=strlen(s+1)-1;
				break;
			}
			case 'd':
			{
				isudp=1;
				udpstart=bc;
				break;
			}
			case 'i':
			{
				isicmp=1;
				udpstart=bc;
				break;
			}
			case 't':
			{
				istcp=1;
				udpstart=bc;
				break;
			}
			case 'e':
			{
				ethstart=bc;
				break;
			}
		}
	}

	if (!ethstart)
	{
		puts("No ethernet start delimiter!\n");
		exit(1);
	}

	hsize=bc-ethstart;
	p=b+ethstart;

	if (isudp || istcp || isicmp) hsize=udpstart-ethstart;
	if (hsize & 0x03)
	{
		puts("Packet header not aligned on 32bit boundary\n");
		exit(1);
	}
	hsize4=hsize>>2;
	if (hsize4<5)
	{
		puts("Header must be at least 5 dword long\n");
		exit(1);
	}

	p[0] |= hsize4;
	p[2] = (bc-ethstart) >> 8;
	p[3] = (bc-ethstart) & 0xff;
/*	p[2] = (bc-ethstart) >> 8;
	p[3] = (bc-ethstart) & 0xff;*/
	memset(p+10,0,2);
	checksum=in_cksum(p, hsize);
	p[11]=(checksum >> 8);
	p[10]=(checksum & 0xff);



	if (isudp)
	{
		udpsize=bc-hsize-ethstart;
		p[hsize+4]= (udpsize >> 8);
		p[hsize+5]= (udpsize & 0xff);
		p[hsize+6]=0;
		p[hsize+7]=0;
		fbc=bc;
		if ( (fbc&1) )
		{
			p[fbc-ethstart]=0;
			fbc++;
		}
		memcpy(p+fbc-ethstart,p+12,4);
		fbc+=4;
		memcpy(p+fbc-ethstart,p+16,4);
		fbc+=4;
		p[fbc++-ethstart]=0;
		p[fbc++-ethstart]=p[9];
		p[fbc++-ethstart]=p[hsize+4];
		p[fbc++-ethstart]=p[hsize+5];
		sum=in_cksum(p+hsize,fbc-hsize-ethstart);
		if (!sum) sum=0xffff;
		p[hsize+7]= (sum >> 8);
		p[hsize+6]= (sum & 0xff);
	}
	if (istcp)
	{
		udpsize=bc-hsize-ethstart;
/*		p[hsize+12]=6;		     */
/*		p[hsize+5]= (udpsize & 0xff);*/
		p[hsize+16]=0;
		p[hsize+17]=0;
		fbc=bc;
		if ( (fbc&1) )
		{
			p[fbc-ethstart]=0;
			fbc++;
		}
		memcpy(p+fbc-ethstart,p+12,4);
		fbc+=4;
		memcpy(p+fbc-ethstart,p+16,4);
		fbc+=4;
		p[fbc++-ethstart]=0;
		p[fbc++-ethstart]=p[9];
		p[fbc++-ethstart]=(bc-hsize-ethstart) >> 8;
		p[fbc++-ethstart]=(bc-hsize-ethstart) & 0xff;
		sum=in_cksum(p+hsize,fbc-hsize-ethstart);
		if (!sum) sum=0xffff;
		p[hsize+17]= (sum >> 8);
		p[hsize+16]= (sum & 0xff);
	}

	fwrite(b,bc,1,fo);
	fclose(fo);

	return 0;
}

