#include "winapp32.h"
// Checks if given directory is not write-protected
// Returns TRUE if write allowed
//Declaration
bool RWDir(char* s)
{
 char ss[MAX_PATH];;
 strcpy(ss,s);;
 if (ss[strlen(ss)-1]!='\\') {strcat(ss,"\\");};;
 strcat(ss,"TMPTMP.$11");;
 HANDLE h=CreateFile(ss,GENERIC_READ | GENERIC_WRITE,
	 FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_FLAG_DELETE_ON_CLOSE,NULL);;
 if (h==INVALID_HANDLE_VALUE) return false;;
 CloseHandle(h);;
 return true;;
}

// Looks for temp directory path, returns TRUE if writable dir found
//Declaration
bool GetTempDir(char* s)
{
 GetEnvironmentVariable("TEMP",s,MAX_PATH);;
 if (RWDir(s)) return true;;
 GetEnvironmentVariable("TMP",s,MAX_PATH);;
 if (RWDir(s)) return true;;
 GetWindowsDirectory(s,MAX_PATH);;
 if (RWDir(s)) return true;;
 return false;;
}


// Returns pointer to filename extension (to '\0' if no extension)
//Declaration
char* Ext(char* Name)
{
 char* x = Name;;
 while ((*x)!=0) x++;;
 if ((*(x-1))=='.') return (x);;
 if ((*(x-2))=='.') return (x-2);;
 if ((*(x-3))=='.') return (x-3);;
 if ((*(x-4))=='.') return (x-4);;
 return x;;
};


// Runs specified external application and waits for it's termination
// Returns FALSE if an error occurs
//Declaration
bool Exec(char* Command, char* WorkDir, DWORD TOut)
{
 Log(Command);;
 STARTUPINFO SInfo;;
 GetStartupInfo(&SInfo);;
 SInfo.dwFlags = STARTF_USESHOWWINDOW;;
 SInfo.wShowWindow = SW_HIDE;;
 PROCESS_INFORMATION Executed;;
 bool x = CreateProcess(NULL,Command,NULL,NULL,false,
  CREATE_DEFAULT_ERROR_MODE | CREATE_NEW_PROCESS_GROUP | NORMAL_PRIORITY_CLASS,
  NULL,WorkDir,&SInfo,&Executed);;
 if (!x) return false;;
 WaitForSingleObject(Executed.hProcess,TOut);;
 return true;;
};

//Declaration
bool Readln(HANDLE h, char* s)
{
 if (h==INVALID_HANDLE_VALUE) return false;;
 strcpy(s,"");;
 char shit[]="?";;
 while ((strlen(s)<2)|(s[strlen(s)-2]!='\xD')|(s[strlen(s)-1]!='\xA'))
 {
  DWORD readed = 0;;
  ReadFile(h,&shit,1,&readed,NULL);;
  if (readed!=1) return false;;
  if (shit[0]!='\0') strcat(s,shit);;
 };;
 if (strlen(s)>=2) s[strlen(s)-2]='\0';;
 return true;;
};
//Declaration
bool Writeln(HANDLE h, const char* s)
{
 if (h==INVALID_HANDLE_VALUE) return false;;
 DWORD written1 = 0;;
 DWORD written2 = 0;;
 char ss[] = "\xD\xA";;
 WriteFile(h,s,strlen(s),&written1,0);;
 WriteFile(h,ss,2,&written2,0);;
 return ((written1==strlen(s))&&(written2==2));;
};

//Declaration
