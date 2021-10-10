
/* MUST be compiled in medium memory model cause the function call in
   receiver routine must have CS declared explicitly ! */


#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <alloc.h>
#include <dos.h>
#include <ctype.h>
#include <string.h>


#include "pktdrvr.h"
#include "netool.h"
#include "parse.h"


int intno=96;
int ifclass=11;
int iftype=0xffff;
int ifno=0;
int ver=-1;
int rhandle;
int fun=-1;
int pl=0;


int winh, maxh, xu, yu, xd, yd;
int far save_ds;
int buffer_ready=1;
unsigned char buffer[4000];
struct netpacket pkt;
int llen;
unsigned char volatile myetheraddr[6];  /* from ethernet adress */
unsigned char volatile toetheraddr[6];	/* to ethernet adress */
unsigned char myipaddr[4];		/* from IP adress */
unsigned char toipaddr[4];		/* to IP adress */

FILE * f;

unsigned char tb[4000];
unsigned char *tp;
unsigned char tparp[200];

int volatile ishooked=0;
void (*hookfun) (char *, int, struct netpacket *);


char maskipsrc[4]={0,0,0,0};
char maskipdst[4]={0,0,0,0};
int maskpsrc=0;
int maskpdst=0;
int noother=0;
int masktype=0;

void receiver ()
{

	int flag=_AX;
/*	int handle=_BX; */
	int len=_CX;

	int i;

	asm pop dx;     	/* nasty hack for TC code generation */
	asm pop dx;		/* that idiot always saves di and si */

	_DS=save_ds;

	if (flag)
	{
				/* setup screen */
		xd=wherex();
		yd=wherey();
		window(1,1,80,winh);
		gotoxy(xu,yu);

				/* here the packet in buffer is analyzed */

		analyze(buffer,&pkt);
		if (ishooked) (*hookfun)(buffer,llen,&pkt);
		if (pkt.type==UNKNOWN && !noother)
		{       tp="ETH: from: ";
			cputs(tp);
			if (logging)
				fputs(tp,f);
			sprintf(tb,"%2X",pkt.ethfrom[0]);
			cputs(tb);
			if (logging)
				fputs(tb,f);
			for (i=1;i<6;i++)
			{
				sprintf(tb,":%2X",pkt.ethfrom[i]);
				cputs(tb);
				if (logging)
					fputs(tb,f);
			}
			tp=" to: ";
			cputs(tp);
			if (logging)
				fputs(tp,f);
			sprintf(tb,"%2X",pkt.ethto[0]);
			cputs(tb);
			if (logging)
				fputs(tb,f);
			for (i=1;i<6;i++)
			{
				sprintf(tb,":%2X",pkt.ethto[i]);
			cputs(tb);
			if (logging)
				fputs(tb,f);
			}
			tp=" NOT TCP/IP\n\n";
			cprintf("%s\r",tp);
			if (logging)
				fputs(tp,f);
		}
		if ((
		     ( !maskipsrc[0] || (maskipsrc[0]==pkt.ipfrom[0]) ) &&
		     ( !maskipsrc[1] || (maskipsrc[1]==pkt.ipfrom[1]) ) &&
		     ( !maskipsrc[2] || (maskipsrc[2]==pkt.ipfrom[2]) ) &&
		     ( !maskipsrc[3] || (maskipsrc[3]==pkt.ipfrom[3]) ) &&
		     ( !maskipdst[0] || (maskipdst[0]==pkt.ipto[0]) ) &&
		     ( !maskipdst[1] || (maskipdst[1]==pkt.ipto[1]) ) &&
		     ( !maskipdst[2] || (maskipdst[2]==pkt.ipto[2]) ) &&
		     ( !maskipdst[3] || (maskipdst[3]==pkt.ipto[3]) ) &&
		     ( !maskpdst || (maskpdst==pkt.portto) ) &&
		     ( !maskpsrc || (maskpsrc==pkt.portfrom) ) &&
		     ( !masktype || (masktype==pkt.type) )
		   ) && (pkt.type!=ARP) )

		{
			switch (pkt.type)
			{
				case TCPIP: 	tp="TCPIP: "; 	break;
				case UDPIP: 	tp="UDPIP: "; 	break;
				case ICMP:	tp="ICMP: ";	break;
				case IPUNKNOWN: tp="?IP: ";	break;
			}
			cputs(tp);
			if (logging)
				fputs(tp,f);
			sprintf(tb,"%hu",pkt.ipfrom[0]);
			cputs(tb);
			if (logging)
				fputs(tb,f);

			for (i=1;i<4;i++)
			{
				sprintf(tb,".%hu",pkt.ipfrom[i]);
				cputs(tb);
				if (logging)
					fputs(tb,f);
			}
			if (pkt.type==TCPIP || pkt.type==UDPIP)
			{
				sprintf(tb,":%u",pkt.portfrom);
				cputs(tb);
				if (logging)
					fputs(tb,f);
			}
			tp=" to ";
			cputs(tp);
			if (logging)
				fputs(tp,f);
			sprintf(tb,"%hu",pkt.ipto[0]);
			cputs(tb);
			if (logging)
				fputs(tb,f);
			for (i=1;i<4;i++)
			{
				sprintf(tb,".%hu",pkt.ipto[i]);
				cputs(tb);
				if (logging)
					fputs(tb,f);
			}
			if (pkt.type==TCPIP || pkt.type==UDPIP)
			{
				sprintf(tb,":%u",pkt.portto);
				cputs(tb);
				if (logging)
					fputs(tb,f);
			}
			if (pkt.isfrag)
			{
				tp=" FR";
				cputs(tp);
				if (logging)
					fputs(tp,f);

			}

			if (pkt.issyn && pkt.type==TCPIP)
			{
				tp=" SYN";
				cputs(tp);
				if (logging)
					fputs(tp,f);

			}
			if (pkt.isack && pkt.type==TCPIP)
			{
				tp=" ACK";
				cputs(tp);
				if (logging)
					fputs(tp,f);

			}
			if (pkt.isfin&& pkt.type==TCPIP)
			{
				tp=" FIN";
				cputs(tp);
				if (logging)
					fputs(tp,f);

			}

			tp="\n";
			cprintf("%s\r",tp);
			if (logging)
				fputs(tp,f);
			cputs(pkt.textdata);
			if (logging)
				fputs(pkt.textdata,f);
			tp="\n\n";
			cprintf("%s\r",tp);
			if (logging)
				fputs(tp,f);

		}

		if (pkt.type==ARP)
		{
			strcpy (tparp,"ARP: ");
			if (pkt.proto==1)
				strcat(tparp,"request for ");
			else
				strcat(tparp,"answer for ");
			sprintf(tb,"%hu",pkt.ipto[0]);
			strcat(tparp,tb);
			for (i=1;i<4;i++)
			{
				sprintf(tb,".%hu",pkt.ipto[i]);
				strcat(tparp,tb);
			}
			if (pkt.proto==1)
				sprintf(tb," HW FROM: 0");
			else
				sprintf(tb," IS: 0");
			strcat(tparp,tb);
			for (i=1;i<6;i++)
			{
				sprintf(tb,":%2X",pkt.etharp[i]);
				strcat(tparp,tb);
			}

			strcat(tparp,"\n\r");
			cputs(tparp);
			if (logging)
				fputs(tparp,f);

		}
				/* restore screen */
		xu=wherex();
		yu=wherey();
		window(1,winh+1,80,maxh);
		gotoxy(xd,yd);

		buffer_ready=1;

	}
	else
	{
		if (buffer_ready)
		{
			buffer_ready=0;
			llen=len;
			_ES=FP_SEG(buffer);
			_DI=FP_OFF(buffer);
		}
		else
		{
			pl=1;
			_ES=0;
			_SI=0;
		}
	}

	asm push si;		/* nasty hack as above */
	asm push di;

	return;
}


void reset_card(void)
{
	release_type(intno,rhandle);
}


void setup_card(void)
{
	int err,i;

	cprintf("Injector version 0.666BETA\n\r");

	if (!test_for_pd(intno))
	{
		cprintf ("\nNo packet driver on int. %d\r\n",intno);
		exit(1);
	}


	driver_info(intno,0,&ver,&ifclass,&iftype,&ifno,&fun);
	cprintf("PD Info: ver: %d, class: %d, type: %d, no: %d, fun: %d\n\r",
		ver,ifclass,iftype,ifno,fun);

	if (!(rhandle=access_type(intno,ifclass,iftype,ifno, NULL,0)))
	{
		cprintf ("\nCannot get needed class %d pd access\n\r", ifclass);
		exit(1);
	}

	atexit(reset_card);


	if (!(set_mode (intno,rhandle,6)))
	{
		cprintf("\nCannot put pd in promiscuous mode\n\r");
		exit(1);
	}

	err=get_address(intno,rhandle,myetheraddr,6);
	if (err)
	{
		cprintf("\nCannot get my ethernet address! error:%i\n\r",err);
		exit(1);
	}
	else
	{
		cprintf("My ethernet address is: %2X",myetheraddr[0]);
		for (i=1;i<6;i++)
		{
			cprintf(":%2X",myetheraddr[i]);
		}
		cprintf("\n\r");
	}
}

void main (void)
{

	struct text_info ti;
	unsigned char cl[100], *c=cl, ch; /* no unsigned */

	save_ds=_DS;
	initparser();
	textmode(C4350);
	gettextinfo(&ti);
	maxh=ti.screenheight;
	winh=maxh-10;
	clrscr();
	window(1,winh+1,80,maxh);
	setup_card();
	f=fopen("injector.log","a");

	for (;;)
	{
		if (pl)
		{
			cputs("Packet Lost!\n\r");
			pl=0;
		}

		if (kbhit())
		{
			ch=getch();
			if (isprint(ch))
			{
				*(c++)=ch;
				putch(ch);
			}
			if (ch=='\b' && (c!=cl) )
			{
				c--;
				gotoxy(wherex()-1,wherey());
				putch(' ');
				gotoxy(wherex()-1,wherey());
			}
			if (ch=='\r')
			{
				*c='\0';
				cputs("\n\r");
				if (docmd(cl))
				{
					reset_card();
					fclose(f);
					exit(0);
				}
				c=cl;
			}
		}
	}

}