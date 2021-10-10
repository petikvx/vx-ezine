
//#define MAXLOGSIZE      1*1024*1024     // empty logfile when reached

#ifndef LOGGING

#define log1(a)         ;
#define log2(a,b)       ;
#define log3(a,b,c)     ;
#define log4(a,b,c,d)   ;

#else // LOGGING

#define log1(a)         log(a)
#define log2(a,b)       log(a,b)
#define log3(a,b,c)     log(a,b,c)
#define log4(a,b,c,d)   log(a,b,c,d)

void cdecl log(char* format, ...)
{
  char msg[1024];

  sprintf(msg, "[%9s] %s : ", irc_user_nick, irc_gettime());

  va_list ap;
  va_start(ap, format);
  vsprintf(msg+strlen(msg), format, ap);
  va_end(ap);

  HANDLE h = fopen_ap(irc_logfile);
  if (h == INVALID_HANDLE_VALUE) return;

  fappendline(h, msg);

#ifdef MAXLOGSIZE
  int filesize = GetFileSize(h,0);
  CloseHandle(h);
  if (filesize > MAXLOGSIZE)
    DeleteFile(irc_logfile);
#else
  CloseHandle(h);
#endif

} // log

#endif // LOGGING
