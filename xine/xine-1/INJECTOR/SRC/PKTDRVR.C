/* Turbo C Driver for FTP Software's packet driver interface.
 * Graciously donated to the public domain by Phil Karn.
 */
#include <stdio.h>
#include <dos.h>
#include <string.h>
#include "pktdrvr.h"

int Derr;
static char Pkt_sig[] = "PKT DRVR";	/* Packet driver signature */

/* Test for the presence of a packet driver at an interrupt number.
 * Return 0 if no packet driver.
 */
int
test_for_pd(int intno)
{
	long drvvec;
	char sig[8];	/* Copy of driver signature "PKT DRVR" */

	/* Verify that there's really a packet driver there, so we don't
	 * go off into the ozone (if there's any left)
	 */
	drvvec = (long)getvect(intno);
	movedata(FP_SEG(drvvec),FP_OFF(drvvec)+3,FP_SEG(sig), FP_OFF(sig),
		strlen(Pkt_sig));
	return !strncmp(sig,Pkt_sig,strlen(Pkt_sig));
}

int
access_type(int intno,int if_class,int if_type,int if_number,char far * type,unsigned typelen)
{
	union REGS regs;
	struct SREGS sregs;

	segread(&sregs);
	regs.h.dl = if_number;		/* Number */
	sregs.ds = FP_SEG(type);	/* Packet type template */
	regs.x.si = FP_OFF(type);
	regs.x.cx = typelen;		/* Length of type */
	sregs.es = FP_SEG(receiver);	/* Address of receive handler */
	regs.x.di = FP_OFF(receiver);
	regs.x.bx = if_type;		/* Type */
	regs.h.ah = ACCESS_TYPE;	/* Access_type() function */
	regs.h.al = if_class;		/* Class */
	int86x(intno,&regs,&regs,&sregs);
	if(regs.x.cflag){
		Derr = regs.h.dh;
		return -1;
	} else
		return regs.x.ax;
}
int
release_type(int intno,int handle)
{
	union REGS regs;

	regs.x.bx = handle;
	regs.h.ah = RELEASE_TYPE;
	int86(intno,&regs,&regs);
	if(regs.x.cflag){
		Derr = regs.h.dh;
		return -1;
	} else
		return 0;
}
int
send_pkt(int intno,char far * buffer,unsigned length)
{
	union REGS regs;
	struct SREGS sregs;

	segread(&sregs);
	sregs.ds = FP_SEG(buffer);
	sregs.es = FP_SEG(buffer); /* for buggy univation pkt driver - CDY */
	regs.x.si = FP_OFF(buffer);
	regs.x.cx = length;
	regs.h.ah = SEND_PKT;
	int86x(intno,&regs,&regs,&sregs);
	if(regs.x.cflag){
		Derr = regs.h.dh;
		return -1;
	} else
		return 0;
}
int
driver_info(int intno,int handle,int *version,int *cclass,int *type,int *number,int *basic)
{
	union REGS regs;

	regs.x.bx = handle;
	regs.h.ah = DRIVER_INFO;
	regs.h.al = 0xff;
	int86(intno,&regs,&regs);
	if(regs.x.cflag){
		Derr = regs.h.dh;
		return -1;
	}
	if(version != NULL)
		*version = regs.x.bx;
	if(cclass != NULL)
		*cclass = regs.h.ch;
	if(type != NULL)
		*type = regs.x.dx;
	if(number != NULL)
		*number = regs.h.cl;
	if(basic != NULL)
		*basic = regs.h.al;
	return 0;
}
int
get_mtu(int intno)
{
	union REGS regs;
	struct SREGS sregs;
	char far *param;

	regs.h.ah = GET_PARAMETERS;
	int86x(intno,&regs,&regs,&sregs);
	if(regs.x.cflag){
		Derr = regs.h.dh;
		return -1;
	}
	param = (char *) MK_FP(sregs.es, regs.x.di);
	return ((unsigned char)param[4]) + 256 * ((unsigned char)param[5]);
}
int
get_address(int intno,int handle,unsigned char far * buf,int len)
{
	union REGS regs;
	struct SREGS sregs;

	segread(&sregs);
	sregs.es = FP_SEG(buf);
	regs.x.di = FP_OFF(buf);
	regs.x.cx = len;
	regs.x.bx = handle;
	regs.h.ah = GET_ADDRESS;
	int86x(intno,&regs,&regs,&sregs);
	if(regs.x.cflag){
		Derr = regs.h.dh;
		return -1;
	}
	return 0;
}
/* set the mode -- returns the old mode or -1 if error. */
int
set_mode(int intno, int handle, int mode)
{
	union REGS regs;
	int oldmode;

	regs.h.ah = GET_RCV_MODE;
	regs.x.bx = handle;
	int86(intno,&regs,&regs);
	if(regs.x.cflag){
		Derr = regs.h.dh;
		return -1;
	}
	oldmode = regs.x.ax;

	regs.h.ah = SET_RCV_MODE;
	regs.x.cx = mode;
	regs.x.bx = handle;
	int86(intno,&regs,&regs);
	if(regs.x.cflag){
		Derr = regs.h.dh;
		return -1;
	}
	return oldmode;
}
