

#include "netool.h"

#include <string.h>
#include <ctype.h>
#include <conio.h>
#include <stdio.h>


#define getw(X) (( (unsigned char) *(X) << 8) + (unsigned char) *(X+1) )

void analyze (char * buffer, struct netpacket * pkt)
{
	unsigned int off,tlen,hlen,tcphlen,i;
	char *p;

	strcpy(pkt->textdata,"\0");
	memcpy(pkt->ethfrom,buffer,6);
	memcpy(pkt->ethto,buffer+6,6);
	/* only for ethenret, NOT for IEEE 802.3 */
	off=14;
	pkt->issyn=0;
	pkt->isfin=0;
	if ( (*(buffer+12) != 0x08 ) || (*(buffer+13) != 0 ) )
	{
		if ( (*(buffer+12) == 0x08 ) && (*(buffer+13) == 0x06 ) )
		{
			pkt->type=ARP;
			pkt->proto=*(buffer+off+7);
			if (pkt->proto==1)
				memcpy(pkt->ipto,buffer+off+24,4);
			else
				memcpy(pkt->ipto,buffer+off+14,4);
			memcpy(pkt->etharp,buffer+off+8,6);
			return;
		}
		pkt->type=UNKNOWN;
		return;
	}
	/* */
	memcpy(pkt->ipfrom,buffer+off+12,4);
	memcpy(pkt->ipto,buffer+off+16,4);
	tlen= getw(buffer+off+2) ;
	if (tlen>3000)
	 {
		tlen=3000;
		cputs("TRASHING!!!\n\r");
	 }
	hlen= ( *(buffer+off) & 0x0f ) * 4;
	pkt->fragoff=( getw(buffer+off+6) & 0x1fff ) * 8;
	pkt->ismorefrag= *(buffer+off+6) & 0x20;
	if ( (!pkt->ismorefrag) && (pkt->fragoff==0) )
		pkt->isfrag=0;
	else
		pkt->isfrag=1;
	pkt->id=getw(buffer+off+4);
	pkt->proto=*(buffer+off+9);
	if (pkt->proto==1)
	{
		pkt->type=ICMP;
		return;
	}
	if (pkt->proto==6)
	{
		pkt->type=TCPIP;
		pkt->portfrom=getw(buffer+off+hlen);
		pkt->portto=getw(buffer+off+hlen+2);
		tcphlen=(( *(buffer+off+hlen+12) & 0xf0 ) >> 2);
			/* & 0xf0 shouldn't be neccessary just to be sure */
		for (i=(off+hlen+tcphlen),p=(pkt->textdata);
		     i<(off+tlen); i++,p++)
		{
			if ( isprint(*(buffer+i)) )
				*p=*(buffer+i);
			else
				*p='.';
		}
		*p='\0';
		if (*(buffer+off+hlen+13) & 0x02)
			pkt->issyn=1;
		if (*(buffer+off+hlen+13) & 0x05)
			pkt->isack=1;
		if (*(buffer+off+hlen+13) & 0x01)
			pkt->isfin=1;
		return;
	}
	if (pkt->proto==17)
	{
		pkt->type=UDPIP;
		pkt->portfrom=getw(buffer+off+hlen);
		pkt->portto=getw(buffer+off+hlen+2);
		tcphlen=8;
		for (i=(off+hlen+tcphlen),p=(pkt->textdata);
		     i<(off+tlen); i++,p++)
		{
			if ( isprint(*(buffer+i)) )
				*p=*(buffer+i);
			else
				*p='.';
		}
		*p='\0';

		return;
	}
	pkt->type=IPUNKNOWN;

}

int atoip(char * s, char * ip)
{
	int ip0,ip1,ip2,ip3;
	if (sscanf(s,"%u.%u.%u.%u",&ip0,&ip1,&ip2,&ip3)==4)
	{
		ip[0]=ip0;
		ip[1]=ip1;
		ip[2]=ip2;
		ip[4]=ip3;
		return 1;
	}
	else return 0;
}