/*
	Author: Know v3.0
	Twitter: @KnowV3
	Email: know [dot] omail [dot] pro
	Website: knowlegend.ws / knowlegend.me

	(c) 2013 - Know v3.0 alias Knowlgend
*/
#include "Loader.h"

int __stdcall WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
	DWORD pid;
	HANDLE thread;
	HANDLE process;
	char *dll = "path/to/dll";
	unsigned long LoadLib;
	LPVOID DataAddress;

	pid = Loader::getPIDByName(L"PROCESS_NAME.exe");
	if(pid == NULL) {
		char buffer[100];
		sprintf_s(buffer, "Error Code: %d", GetLastError());
		(new API())->ONE(0, buffer, "Error", 0);
	
	}

	process = Loader::getProcess(pid);
	if(process == NULL) {
		char buffer[100];
		sprintf_s(buffer, "Error Code: %d", GetLastError());
		(new API())->ONE(0, buffer, "Error", 0);
	
	}


	LoadLib = (unsigned long)(new API())->___NUL(GetModuleHandleA("kernel32.dll"), "LoadLibraryA");
	
	DataAddress = Loader::allocAndWriteInProcess(process, strlen(dll), dll);

	thread = Loader::NtCreateThreadEx(process, (LPTHREAD_START_ROUTINE)LoadLib, DataAddress);
	
	if (thread !=0 ) {
			   WaitForSingleObject(thread, INFINITE);   
			   VirtualFree(dll, 0, MEM_RELEASE); 
			   VirtualFree(DataAddress, 0, MEM_RELEASE); 
	   		   CloseHandle(thread);
			   CloseHandle(process); 
			   (new API())->ONE(0, "Injection completed!", "Success", 0);
	 
	} else {
		(new API())->ONE(0, "Injection failed!", "Error", 0);
		char buffer[100];
		sprintf_s(buffer, "Error Code: %d", GetLastError());
		(new API())->ONE(0, buffer, "Error", 0);
	
	}
	return 0;
}