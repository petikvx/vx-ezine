
#ifndef _APP_DIAG_CPP_
#define _APP_DIAG_CPP_

#include "winapp32.h"
//Declaration
void DiagInit()
{
 char ss[MAX_PATH];;
 Prompt=(GetProfileInt(WinApp32,ShowDotsOn,0)==1);;
 GetProfileString(WinApp32,Logging,"NO",ss,MAX_PATH);;
 if (stricmp("YES",ss)==0) LoggingEnabled=true;;
 GetWindowsDirectory(ss,MAX_PATH);;
 strcat(ss,"\\WINAPP32.LOG");;
 GetProfileString(WinApp32,LogPath,ss,LogFileName,MAX_PATH);;
};
//Declaration
void DiagMsg(char* ss)
{
 if (LoggingEnabled)
  MessageBox(0,ss,"",MB_OK | MB_ICONINFORMATION | MB_TASKMODAL);;
};
//Declaration
void Log(char* ss)
{
  HANDLE h=CreateFile(LogFileName,GENERIC_READ | GENERIC_WRITE,
	 FILE_SHARE_READ,NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL);;
  if (h==INVALID_HANDLE_VALUE) return;;
  SetFilePointer(h,0,NULL,FILE_END);;
  char xx[MAX_PATH+666];;
  time_t timer;;
  struct tm *tblock;;
  timer = time(NULL);;
  tblock = localtime(&timer);;
  char glu[30];;
  strcpy(glu,asctime(tblock));;
  glu[24]=0x0;;
  char   Drive[MAX_PATH];;
  char   Dir[MAX_PATH];;
  char   Name[MAX_PATH];;
  char   Ext[MAX_PATH];;
  fnsplit(MyName,Drive,Dir,Name,Ext);;
  sprintf(xx," %08s at  %s : %s\xD\xA",Name,glu,ss);;
  DWORD z;;
  WriteFile(h,xx,strlen(xx),&z,NULL);;
  CloseHandle(h);;
};
//Declaration
bool AskBoss(char* ss)
{
 if (!Prompt) return true;;
 return (MessageBox(0,ss,"?",
  MB_YESNO | MB_ICONQUESTION)==IDYES);;
};

#endif
