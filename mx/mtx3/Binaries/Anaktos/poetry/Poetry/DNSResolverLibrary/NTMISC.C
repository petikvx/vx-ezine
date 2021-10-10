/* misc routines needed for the WindowsNT port */
#ifdef WINNT
#include <stdio.h>
#include <stdarg.h>
#include <netdb.h>
#include "portability.h"
//#include "../../named/pathnames.h"
#include "log.h"
#include "messages.h"

char	*optarg;
int		optind = 0;
int		optopt;

static char	*scan = NULL;
static char	*prog = "named";
static FILE *servf, *protof;
int _serv_stayopen, _proto_stayopen;
static struct servent serv;
static struct protoent proto;
static char *serv_aliases[MAXALIASES], *proto_aliases[MAXALIASES];
static char line[BUFSIZ+1];
static char *pathprotocol, *pathservices;
int paths_initialized = 0;
     /* 97 lgk new flag to deteremine if we log info and debug messages... 
        if flag is set we DON'T log them */
BOOLEAN nolog_flag_set = FALSE;

// on  win95 put log in system dir
#ifdef WIN95
char dirname[200];
static char logfilename[230];
FILE *logfile = NULL;
#endif


/* lgk new function to initialize path variables that are outside the scope of the main */
void init_paths()
{
  	 
	pathprotocol = (char *)malloc(MAX_PATH);
	if (!ExpandEnvironmentStrings(_PATH_PROTOCOL, pathprotocol, MAX_PATH))
		syslog(LOG_ERR, "ExpandEnvironmentStrings(_PATH_PROTOCOL) failed: %m\n");

	pathservices = (char *)malloc(MAX_PATH);
	if (!ExpandEnvironmentStrings(_PATH_SERVICES, pathservices, MAX_PATH))
		syslog(LOG_ERR, "ExpandEnvironmentStrings(_PATH_SERVICES) failed: %m\n");

        paths_initialized = 1;
}


void
syslog(level, fmt, ...)
	int level;
	char *fmt;
{

#ifdef WIN95
        time_t	now;
        char *timestamp;
        register char *p;
#endif

char *lpszStrings[1];

/*
#define LOG_EMERG       0
#define LOG_ALERT       1
#define LOG_CRIT        2
#define LOG_ERR         3
#define LOG_WARNING     4
#define LOG_NOTICE      5
#define LOG_INFO        6
#define LOG_DEBUG       7
*/
#define EVENTLOG_INFORMATION_TYPE2 0x0005

	static WORD event_type[] = {
		EVENTLOG_ERROR_TYPE, EVENTLOG_ERROR_TYPE, EVENTLOG_ERROR_TYPE, EVENTLOG_ERROR_TYPE,
		EVENTLOG_WARNING_TYPE,
		EVENTLOG_INFORMATION_TYPE, EVENTLOG_INFORMATION_TYPE2, EVENTLOG_INFORMATION_TYPE2
	};
	va_list ap;
	char buf[1025], nfmt[256], xerr[50];
	register int c;
	register char *n, *f;

	va_start(ap, fmt);

	n = nfmt;
	f = fmt;
	while ((c = *f++) != '\0' && c != '\n' && n < &nfmt[252]) {
		if (c != '%') {
			*n++ = c;
			continue;
		}
		if ((c = *f++) != 'm') {
			*n++ = '%';
			*n++ = c;
			continue;
		}
		sprintf(xerr, "error code = %u", GetLastError());
/*		printf("getlasterror = %d errno = %d",GetLastError(),errno); */
		fflush(stdout);
		strcpy(n, xerr);
		n += strlen(xerr);
	}
 	*n = '\0';
	vsprintf(buf, nfmt, ap);

	lpszStrings[0] = buf;

// lgk now report based on type
// but for win95 write to log file
#ifndef WIN95

switch (event_type[level])
 {
   case EVENTLOG_ERROR_TYPE       :
     {
       reportAnEEvent(DNS_ERROR,1,lpszStrings);
       break;
     }
   case EVENTLOG_INFORMATION_TYPE :
     {
       reportAnIEvent(DNS_INFO,1,lpszStrings);
       break;
     }  

   case EVENTLOG_INFORMATION_TYPE2 :
     {
       if (!nolog_flag_set)
         reportAnIEvent(DNS_INFO,1,lpszStrings);
       break;
     }  

   case EVENTLOG_WARNING_TYPE     :
     {
       reportAnWEvent(DNS_WARNING,1,lpszStrings);
       break;
     }
 }
#else
// also add time date
     (void) time(&now);
     timestamp = ctime(&now) + 4;
 
    // for us always append timestamp
    //we must also pull the /n off the timestring
    p = strchr(timestamp,'\n');
    *p = '\0';   

if (logfile == NULL)
{
     (void)GetSystemDirectory((char *)&dirname,200);
     strcpy(logfilename,dirname);
     strcat(logfilename,"\\");
     strcat(logfilename,"named95.log");
     logfile = fopen(logfilename,"a+");
}

   if ((event_type[level] == EVENTLOG_ERROR_TYPE) ||
       (event_type[level] == EVENTLOG_WARNING_TYPE) ||
       (event_type[level] == EVENTLOG_INFORMATION_TYPE))
     {
        fprintf(logfile,"%s %s\n",timestamp,buf);
        fflush(logfile);
     }  

     
  else if (event_type[level] ==  EVENTLOG_INFORMATION_TYPE2)
     {
       if (!nolog_flag_set)
        {
         fprintf(logfile,"%s %s\n",timestamp,buf);
         fflush(logfile);
        }
     }  
#endif 

}


int
getopt(argc, argv, optstring)
	int argc;
	char *argv[];
	char *optstring;
{
	register char c;
	register char *place;

	prog = argv[0];
	optarg = NULL;

	if (optind == 0) {
		scan = NULL;
		optind++;
	}
	
	if (scan == NULL || *scan == '\0') {
		if (optind >= argc
		    || argv[optind][0] != '-'
		    || argv[optind][1] == '\0') {
			return (EOF);
		}
		if (argv[optind][1] == '-'
		    && argv[optind][2] == '\0') {
			optind++;
			return (EOF);
		}
	
		scan = argv[optind++]+1;
	}

	c = *scan++;
	optopt = c & 0377;
	for (place = optstring; place != NULL && *place != '\0'; ++place)
		if (*place == c)
			break;

	if (place == NULL || *place == '\0' || c == ':' || c == '?') {
		fprintf(stderr, "%s: unknown option - %c\n", prog, c);
		return('?');
	}

	place++;
	if (*place == ':') {
		if (*scan != '\0') {
			optarg = scan;
			scan = NULL;
		} else if (optind >= argc) {
			fprintf(stderr, "%s: option requires argument - %c\n", prog, c);
			return('?');
		} else {
			optarg = argv[optind++];
		}
	}

	return (c & 0377);
}


void
setservent(stayopen)
	int stayopen;
{
        if (!paths_initialized)
          init_paths();
          
	if (servf == NULL)
		servf = fopen(pathservices, "r");
	else
		rewind(servf);
	_serv_stayopen |= stayopen;
}


struct servent *
getservent(void)
{
	char *p;
	register char *cp, **q;

       if (!paths_initialized)
          init_paths();
 
	if (servf == NULL && (servf = fopen(pathservices, "r" )) == NULL)
		return (NULL);
again:
	p = fgets(line, BUFSIZ, servf);
	if (p == NULL)
		return (NULL);
	if (*p == '#')
		goto again;
	cp = strpbrk(p, "#\n");
	if (cp == NULL)
		goto again;
	*cp = '\0';
	serv.s_name = p;
	cp = strpbrk(p, " \t");
	if (cp == NULL)
		goto again;
	*cp++ = '\0';
	while (*cp == ' ' || *cp == '\t')
		cp++;
	p = strpbrk(cp, "/");
	if (p == NULL)
		return(NULL);
	*p++ = '\0';
	
	/* serv.s_port = (short)atoi(cp); */
	   serv.s_port= htons((short) atoi(cp));
	cp = strpbrk(p, " \t");
	if (cp != NULL)
		*cp++ = '\0';
	serv.s_proto = p;
	q = serv.s_aliases = serv_aliases;
	while (cp && *cp) {
		if (*cp == ' ' || *cp == '\t') {
			cp++;
			continue;
		}
		if (q < &serv_aliases[MAXALIASES - 1])
			*q++ = cp;
		cp = strpbrk(cp, " \t");
		if (cp != NULL)
			*cp++ = '\0';
	}
	*q = NULL;
	return (&serv);
}

void
endservent(void)
{
	if (servf) {
		fclose(servf);
		servf = NULL;
	}
	_serv_stayopen = 0;
}


void
setprotoent(stayopen)
	int stayopen;
{
        if (!paths_initialized)
          init_paths();

	if (protof == NULL)
		protof = fopen(pathprotocol, "r");
	else
		rewind(protof);
	_proto_stayopen |= stayopen;
}


struct protoent *
getprotoent(void)
{
	char *p;
	register char *cp, **q;

	if (!paths_initialized)
          init_paths();

	if (protof == NULL && (protof = fopen(pathprotocol, "r" )) == NULL)
		return (NULL);
again:
	p = fgets(line, BUFSIZ, protof);
	if (p == NULL)
		return (NULL);
	if (*p == '#')
		goto again;
	cp = strpbrk(p, "#\n");
	if (cp == NULL)
		goto again;
	*cp = '\0';
	proto.p_name = p;
	cp = strpbrk(p, " \t");
	if (cp == NULL)
		goto again;
	*cp++ = '\0';
	while (*cp == ' ' || *cp == '\t')
		cp++;
	p = strpbrk(cp, " \t");
	if (p != NULL)
		*p++ = '\0';
	proto.p_proto = (short)atoi(cp);
	q = proto.p_aliases = proto_aliases;
	if (p != NULL) 
		cp = p;
	while (cp && *cp) {
		if (*cp == ' ' || *cp == '\t') {
			cp++;
			continue;
		}
		if (q < &proto_aliases[MAXALIASES - 1])
			*q++ = cp;
		cp = strpbrk(cp, " \t");
		if (cp != NULL)
			*cp++ = '\0';
	}
	*q = NULL;
	return (&proto);
}


void
endprotoent(void)
{
	if (protof) {
		fclose(protof);
		protof = NULL;
	}
	_proto_stayopen = 0;
}


BOOL OnWinnt()
 
 {

OSVERSIONINFO myver;
BOOL rval;

myver.dwOSVersionInfoSize = sizeof(myver);
rval = GetVersionEx(&myver);

if (myver.dwPlatformId == VER_PLATFORM_WIN32_NT)
  return TRUE;
else return FALSE;

}


#endif /* WINNT */
