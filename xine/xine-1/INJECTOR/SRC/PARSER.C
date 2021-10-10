
#include <string.h>
#include <ctype.h>
#include <conio.h>
#include <stdlib.h>
#include <stdio.h>

#include "parse.h"
#include "external.h"
#include "netool.h"

int logging;

#define MAXVARS 50

char * vars[MAXVARS][2];

extern char myetheraddr[6];
extern char volatile toetheraddr[6];
extern char maskipsrc[4];
extern char maskipdst[4];
extern char myipaddr[4];
extern char toipaddr[4];
extern int maskpsrc;
extern int maskpdst;
extern int noother;
extern int masktype;

void initparser(void)
{
	int i;

	for (i=0;i<MAXVARS;i++) vars[i][0]=NULL;

	initexternals();
}

int getvari(char * name)
{
	int i;

	for (i=0;i<MAXVARS;i++)
	{
		if ( !vars[i][0] ) return i;
		if ( !strcmp(vars[i][0],name) ) return i+MAXVARS;
	}
	return -1;
}

void delvar(char * name)
{
	int f=getvari(name);
	vars[f-MAXVARS][1]=NULL;
}


void setvar(char * name, char * value)
{
	int f=getvari(name);

	if (f==-1) return;

	if (f>MAXVARS)
	{
		f=f-MAXVARS;
		vars[f][1]=realloc(vars[f][1],strlen(value)+1);
	}
	else
	{
	   if (getvar(name)==NULL)
	    {
		vars[f][0]=malloc(strlen(name)+1);
		strcpy(vars[f][0],name);
		vars[f][1]=malloc(strlen(value)+1);
	    }
	   else
	    {
		f=getvari(name)-MAXVARS;
	    }
	}
	strcpy(vars[f][1],value);
}

char * getvar(char * name)
{
	int i=getvari(name);

	if ( (i==-1) | (i<MAXVARS) )
		return NULL;
	else
		return vars[i-MAXVARS][1];
}

int breakline (char * l, char ** p)
/* returns number of parsed arguments or  -1 for error */
{
	char temp[100];
	char *s=l, *t=temp;
	int i;

	for (i=0;i<10;i++)
	{
		while (isspace(*s)) s++;
		if (!*s) return i;
		if (*s=='"')
		{
			s++;
			while ( *s && (*s!='"') ) *(t++)=*(s++);
			if (*s=='"') s++;
		}
		else
			while ( *s && !isspace(*s) ) *(t++)=*(s++);
		*t='\0';
		strcpy(p[i],temp);
		t=temp;
	}
	return i;
}

int docmd (char * in)
{
	char *a[10];
	char buff[500];
	int i,t1,t2,t3,t4,t5,t6;


	for (i=0;i<10;i++)
	{
		a[i]=buff+i*50;
		*a[i]='\0';
	}
	breakline(in,a);
	if (!strcmp(a[0],"quit"))
	{
		return 1;
	}
	else if (!strcmp(a[0],"logon"))
	{
		logging=1;
	}
	else if (!strcmp(a[0],"logoff"))
	{
		logging=0;
	}
	else if (!strcmp(a[0],"onlytcp"))
	{
		masktype=TCPIP;
	}
	else if (!strcmp(a[0],"allpkt"))
	{
		masktype=0;
	}
	else if (!strcmp(a[0],"set"))
	{
		setvar(a[1],a[2]);
	}
	else if (!strcmp(a[0],"unset"))
	{
		delvar(a[1]);
	}
	else if (!strcmp(a[0],"onlyip"))
	{
		noother=1;;
	}
	else if (!strcmp(a[0],"allpack"))
	{
		noother=0;
	}
	else if (!strcmp(a[0],"setmyip"))
	{
		t1=t2=t3=t4=0;
		sscanf(a[1],"%u.%u.%u.%u",&t1,&t2,&t3,&t4);
		myipaddr[0]=t1;
		myipaddr[1]=t2;
		myipaddr[2]=t3;
		myipaddr[3]=t4;
	}
	else if (!strcmp(a[0],"settoip"))
	{
		t1=t2=t3=t4=0;
		sscanf(a[1],"%u.%u.%u.%u",&t1,&t2,&t3,&t4);
		toipaddr[0]=t1;
		toipaddr[1]=t2;
		toipaddr[2]=t3;
		toipaddr[3]=t4;
	}
	else if (!strcmp(a[0],"setmyeth"))
	{
		t1=t2=t3=t4=t5=t6=0;
		sscanf(a[1],"%u:%u:%u:%u:%u:%u",&t1,&t2,&t3,&t4,&t5,&t6);
		myetheraddr[0]=t1;
		myetheraddr[1]=t2;
		myetheraddr[2]=t3;
		myetheraddr[3]=t4;
		myetheraddr[4]=t5;
		myetheraddr[5]=t6;
	}
	else if (!strcmp(a[0],"setethto"))
	{
		t1=t2=t3=t4=t5=t6=0;
		sscanf(a[1],"%u:%u:%u:%u:%u:%u",&t1,&t2,&t3,&t4,&t5,&t6);
		toetheraddr[0]=t1;
		toetheraddr[1]=t2;
		toetheraddr[2]=t3;
		toetheraddr[3]=t4;
		toetheraddr[4]=t5;
		toetheraddr[5]=t6;
	}
	else if (!strcmp(a[0],"show"))
	{
		cprintf("%s has value:%s\n\r",a[1],getvar(a[1]));
	}
	else if (!strcmp(a[0],"maskpsrc"))
	{
		t1=0;
		sscanf(a[1],"%u",&t1);
		maskpsrc=t1;
	}
	else if (!strcmp(a[0],"maskpdst"))
	{
		t1=0;
		sscanf(a[1],"%u",&t1);
		maskpdst=t1;
	}
	else if (!strcmp(a[0],"maskipsrc"))
	{
		t1=t2=t3=t4=0;
		sscanf(a[1],"%u.%u.%u.%u",&t1,&t2,&t3,&t4);
		maskipsrc[0]=t1;
		maskipsrc[1]=t2;
		maskipsrc[2]=t3;
		maskipsrc[3]=t4;
	}
	else if (!strcmp(a[0],"maskipdst"))
	{
		t1=t2=t3=t4=0;
		sscanf(a[1],"%u.%u.%u.%u",&t1,&t2,&t3,&t4);
		maskipdst[0]=t1;
		maskipdst[1]=t2;
		maskipdst[2]=t3;
		maskipdst[3]=t4;
	}
	else if (!strcmp(a[0],"do"))
	{
		if (doext(a[1])) cputs("Function not found!\n\r");
	}
	else
	{
		cprintf("Unknown command:%s\n\r",a[0]);
	}

	return 0;
}






