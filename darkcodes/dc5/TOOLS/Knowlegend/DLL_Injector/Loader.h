/*
	Author: Know v3.0
	Twitter: @KnowV3
	Email: know [dot] omail [dot] pro
	Website: knowlegend.ws / knowlegend.me

	(c) 2013 - Know v3.0 alias Knowlgend
*/
#pragma once
#include "init.h"
#include "api.h"
#include <tlhelp32.h>
#include "MemoryModule.h"
#include <fstream>

typedef struct {
	int NumberOfSection;
	char* Name;
	long ActualSize;
	long RVA;
	long SizeOfRawData;
	long PointerToRawData;
	long PointerToRelocations;
	long PointerToLinenumbers;
	long NumberOfRelocations;
	long NumberOfLinenumbers;
	bool isExecutableCode;

} SECTION_INFORMATION, *PSECTION_INFORMATION;

typedef NTSTATUS (WINAPI *LPFUN_NtCreateThreadEx)
(
  OUT PHANDLE hThread,
  IN ACCESS_MASK DesiredAccess,
  IN LPVOID ObjectAttributes,
  IN HANDLE ProcessHandle,
  IN LPTHREAD_START_ROUTINE lpStartAddress,
  IN LPVOID lpParameter,
  IN BOOL CreateSuspended,
  IN DWORD StackZeroBits,
  IN DWORD SizeOfStackCommit,
  IN DWORD SizeOfStackReserve,
  OUT LPVOID lpBytesBuffer
);

struct NtCreateThreadExBuffer
{
  ULONG Size;
  ULONG Unknown1;
  ULONG Unknown2;
  unsigned long long *Unknown3;
  ULONG Unknown4;
  ULONG Unknown5;
  ULONG Unknown6;
  PULONG Unknown7;
  ULONG Unknown8;
};

class Loader
{
public:
	Loader(void);
	~Loader(void);

	static DWORD getPIDByName(wchar_t* name) {
		 HANDLE hsnap;
	   PROCESSENTRY32 pt;
	   hsnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
	   pt.dwSize = sizeof(PROCESSENTRY32);
	   do{
			  if(wcscmp(pt.szExeFile, name) == 0){
				 DWORD pid = pt.th32ProcessID;
				 CloseHandle(hsnap);
				 return pid;
			  }
	   } while(Process32Next(hsnap, &pt));
	   CloseHandle(hsnap);
	   return 0;		  
	
	}

	static HANDLE getProcess(DWORD pid) {
		return OpenProcess(PROCESS_ALL_ACCESS, false, pid);
	
	}

	static LPVOID allocAndWriteInProcess(HANDLE process, int size, LPCVOID buffer) {
		LPVOID DataAddress = VirtualAllocEx(process, NULL, size + 1, MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);
		if(DataAddress == NULL) {
			(new API())->ONE(0, "Can't alloc space", "Error", 0);
		
		}
		WriteProcessMemory(process, DataAddress, buffer, size, NULL);
		return DataAddress;
	}

	static char* getFileContent(char* file) {
		char* buffer;
		int length;
		
		std::ifstream is;
		is.open (file, std::ios::binary );
	
		is.seekg (0, std::ios::end);
		length = (int)is.tellg();
		is.seekg (0, std::ios::beg);

		buffer = new char [length];

		is.read (buffer,length);
		is.close();
		return buffer;
	}

	static HANDLE NtCreateThreadEx(HANDLE process, LPTHREAD_START_ROUTINE Start, LPVOID lpParameter){
		HMEMORYMODULE handle;

		handle = MemoryLoadLibrary(Loader::getFileContent("C:\\Windows\\System32\\ntdll.dll"));
		if (handle == NULL){
			(new API())->ONE(0, "Can't load library from memory.\n", "LOL", 0);
			
		}
		
		LPFUN_NtCreateThreadEx aNtCreateThreadEx = (LPFUN_NtCreateThreadEx)MemoryGetProcAddress(handle, "NtCreateThreadEx");

		if(!aNtCreateThreadEx){
		  (new API())->ONE(0, "Error loading NtCreateThreadEx()", "Error", 0);
		   return 0;
		}
		NtCreateThreadExBuffer ntbuffer;

		memset (&ntbuffer,0,sizeof(NtCreateThreadExBuffer));
		DWORD blub = 0;
		unsigned long long bla = 0;

		ntbuffer.Size = sizeof(NtCreateThreadExBuffer);
		ntbuffer.Unknown1 = 0x10003;
		ntbuffer.Unknown2 = 0x8;
		ntbuffer.Unknown3 = &bla;
		ntbuffer.Unknown4 = 0;
		ntbuffer.Unknown5 = 0x10004;
		ntbuffer.Unknown6 = 4;
		ntbuffer.Unknown7 = &blub;

		HANDLE hThread;  
		NTSTATUS status = aNtCreateThreadEx(&hThread,	0x1FFFFF, NULL,	process, (LPTHREAD_START_ROUTINE) Start, lpParameter, FALSE, 0,	0, 0, &ntbuffer);

		MemoryFreeLibrary(handle);

		return hThread;
	}
};