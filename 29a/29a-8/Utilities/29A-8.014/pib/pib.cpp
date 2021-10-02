// pib.cpp : Defines the entry point for the application.
//

//=================================
//
// pib - PackItBitch is a complex
// file compressor and encryptor,
// it has:
//  - apLib compression
//  - RC4 encryption
//  - resource e/c pres. icons
//  - adv. plugin system
//     * softice detect
//     * olly detect
//     * etc.
//  - pibpoly Polymorphic engine
// PE's: EXE, DLL's
//
//=================================

#include "stdafx.h"
#include "resource.h"
#include <malloc.h>
#include <commctrl.h>
#include <Commdlg.h>
#include <Imagehlp.h>
#include "aplib/aplib.h"
#include "pibpoly/pibpoly.cpp"

#define SMAIN "smain.dat"
#define IMAGE_PIB_SIG 988
#define ASEC_NAME "fuck"

#define FPIB_POLY 1
#define FRSRC_GO 2
#define FICON 4

#define LSIZE_STUB 1524
#define LOFFSET_RING0 0xDB
#define LOFFSET_RING3 0x103
#define LOFFSET_EXP 0x18C
#define LOFFSET_EXPSIZE 0x190
#define LOFFSET_ONAME 0xC
#define LOFFSET_FTHUNK 0x10
#define LOFFSET_AFTHUNK 0x35
#define LOFFSET_ASTHUNK 0x39
#define LOFFSET_FENTRY 0x41
#define LOFFSET_SENTRY 0x50
#define LOFFSET_DLLNAME 0x28
#define LOFFSET_INDEX 0x69
#define LOFFSET_CALLBACKS 0x6D
#define LOFFSET_AINDEX 0x79
#define LOFFSET_ACALLBACKS 0x7D
#define LOFFSET_TLS	0x61
#define LOFFSET_RVATBL 0x8B
#define LOFFSET_SIZETBL 0xB3
#define LOFFSET_BASERELOC 0x151
#define LOFFSET_TLSENTRY 0x15D
#define LOFFSET_ORIGDESC 0x161
#define LOFFSET_ENTRYPOINT 0x169
#define LOFFSET_RSRCENTRY 0x16D

typedef struct _PIB_PLUG_INFO
{
	char szPluginName[256];
	char szPluginDesc[256];
	BYTE dwHiVer;
	BYTE dwLowVer;
	BYTE dwRing;
} PIB_PLUG_INFO, *PPIB_PLUG_INFO;

typedef VOID (*INFOPROC)(PPIB_PLUG_INFO);
typedef VOID (*PFUNC)(); 
typedef VOID (*PCLIENT)();
typedef VOID (*PCLIENTFUNC)(DWORD,DWORD);
typedef DWORD (*PSIZEFUNC)(); 

HINSTANCE ghInstance;
HWND xmhwndDlg;
HWND hwndDlgSubA;
HWND hwndDlgSubB;
IMAGE_TLS_DIRECTORY TlsDir;
DWORD dwFlags;
DWORD dwRvaTbl[10];
DWORD dwSizeTbl[10];
DWORD dwGlobalCount=0;
DWORD dwOrigEntrypoint;
DWORD dwOrigRsrcRVA;
DWORD dwPluginCount=0;
DWORD dwActualPlugin;
DWORD dwSizeIcon;
DWORD dwSizeGroupIcon;
DWORD dwSeperCalc;
DWORD dwIconBox[2];
DWORD dwGroupIconBox[2];
BOOL boolRsrc=FALSE;
BOOL boolPresRsrc=FALSE;
LPVOID lpIconAddr;
LPVOID lpGroupIconAddr;
LPVOID lpPluginActual[20];
HMODULE hModuleCallback[20];
char *lpPluginBlock[20];
char *lpPluginName[20];
char szCurrentDir[256];

// By Iczelion (win32asm.cjb.net), port to C
DWORD RvaToOffset(DWORD rva, int seccount, LPVOID secaddr)
{
	int i;
	DWORD dwSecAddr;
	DWORD dwHolderVal;
	DWORD dwRetVal=0;
	PIMAGE_SECTION_HEADER pSecHdr;

	dwSecAddr = (DWORD) secaddr;
	pSecHdr = (PIMAGE_SECTION_HEADER) dwSecAddr;

	for (i = 0; i < seccount; i++)
	{
		dwRetVal = 0;

		if (rva >= pSecHdr->VirtualAddress)
		{
			dwHolderVal = pSecHdr->VirtualAddress;
			dwHolderVal += pSecHdr->SizeOfRawData;

			if (rva < dwHolderVal)
			{
				dwRetVal = rva;
				dwRetVal -= pSecHdr->VirtualAddress;
				dwRetVal += pSecHdr->PointerToRawData;

				return dwRetVal;
			}
		}

		dwSecAddr += sizeof(IMAGE_SECTION_HEADER);
		pSecHdr = (PIMAGE_SECTION_HEADER) dwSecAddr;
	}

	return 0;
}

int PibPolyBuild(LPVOID lpBuild, DWORD dwCurrentPoint, DWORD dwSizeSpace, PIMAGE_SECTION_HEADER pSecHdr, PIMAGE_NT_HEADERS pNtHdr)
{
	DWORD dwEntryAddr;
	DWORD dwEncryptTotalSize;
	DWORD dwEncryptVirtAddr;
	DWORD dwCpyDword;
	DWORD dwPatchJEPoint;
	DWORD dwFinalDelta;
	DWORD dwRealEntryPoint;
	BYTE bCpyByte;
	BYTE xrand, bcpybyte;
	int i;

	rt.dwECX = 1;
	rt.dwESI = 1;
	rt.dwEDX = 1;

	wrt.dwCH = 1;
	wrt.dwCL = 1;
	wrt.dwDH = 1;
	wrt.dwDL = 1;

	dwRealEntryPoint = pNtHdr->OptionalHeader.AddressOfEntryPoint;
	dwRealEntryPoint += pNtHdr->OptionalHeader.ImageBase;

	dwEntryAddr = dwSizeSpace;
	dwEntryAddr += LSIZE_STUB;
	dwEntryAddr += pSecHdr->VirtualAddress;

	dwEncryptVirtAddr = pSecHdr->VirtualAddress;
	dwEncryptVirtAddr += pNtHdr->OptionalHeader.ImageBase;
	dwEncryptVirtAddr += 0x85;

	pNtHdr->OptionalHeader.AddressOfEntryPoint = dwEntryAddr;

	srand(GetTickCount());

	RandomizeAgain:
	xrand = (BYTE) 255 * rand() / (RAND_MAX + 1.0);

	if (xrand == 0)
	{
		goto RandomizeAgain;
	}

	dwEncryptTotalSize = LSIZE_STUB;
	dwEncryptTotalSize -= 0x85;

	for (i = 0; i <= dwEncryptTotalSize; i++)
	{
		memcpy(&bcpybyte, (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + i + 0x85), 1);
		bcpybyte ^= xrand;
		memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + i + 0x85), &bcpybyte, 1);
	}

	srand(GetTickCount());

	bCpyByte = 0xB9;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB), &bCpyByte, 1);
	dwIndexInto++;
	dwCpyDword = dwEncryptTotalSize;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + 1), &dwCpyDword, 4);
	dwIndexInto += 4;
	_PolyGenerate( (LPVOID) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB));
	
	bCpyByte = 0xBE;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &bCpyByte, 1);
	dwIndexInto++;
	dwCpyDword = dwEncryptVirtAddr;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &dwCpyDword, 4);
	dwIndexInto += 4;
	_PolyGenerate( (LPVOID) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB));
	
	bCpyByte = 0xE8;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &bCpyByte, 1);
	dwIndexInto++;
	dwCpyDword = 0;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &dwCpyDword, 4);
	dwIndexInto += 4;
	bCpyByte = 0x5A;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &bCpyByte, 1);
	dwIndexInto++;
	
	// ADD EDX, 4
	bCpyByte = 0x83;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &bCpyByte, 1);
	dwIndexInto++;
	bCpyByte = 0xC2;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &bCpyByte, 1);
	dwIndexInto++;
	bCpyByte = 0x04;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &bCpyByte, 1);
	dwIndexInto++;
	_PolyGenerate( (LPVOID) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB));
	
	// TEST ECX, ECX
	bCpyByte = 0x85;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &bCpyByte, 1);
	dwIndexInto++;
	bCpyByte = 0xC9;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &bCpyByte, 1);
	dwIndexInto++;

	// JE XXXXXXXXX
	bCpyByte = 0x0F;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &bCpyByte, 1);
	dwIndexInto++;
	bCpyByte = 0x84;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &bCpyByte, 1);
	dwIndexInto++;
	dwCpyDword = 0;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &dwCpyDword, 4);
	dwPatchJEPoint = (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto;
	dwIndexInto += 4;
	_PolyGenerate( (LPVOID) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB));	

	// XOR BYTE PTR [ESI], XX
	bCpyByte = 0x80;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &bCpyByte, 1);
	dwIndexInto++;
	bCpyByte = 0x36;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &bCpyByte, 1);
	dwIndexInto++;
	bCpyByte = xrand;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &bCpyByte, 1);
	dwIndexInto++;
	_PolyGenerate( (LPVOID) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB));
	
	// INC ESI
	bCpyByte = 0x46;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &bCpyByte, 1);
	dwIndexInto++;
	_PolyGenerate( (LPVOID) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB));
	
	// DEC ECX
	bCpyByte = 0x49;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &bCpyByte, 1);
	dwIndexInto++;
	_PolyGenerate( (LPVOID) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB));
	
	// JMP EDX
	bCpyByte = 0xFF;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &bCpyByte, 1);
	dwIndexInto++;
	bCpyByte = 0xE2;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &bCpyByte, 1);
	dwIndexInto++;
	_PolyGenerate( (LPVOID) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB));	

	memset(&rt, 0, sizeof(rt));
	memset(&wrt, 0, sizeof(wrt));

	rt.dwEDX = 1;
	wrt.dwDH = 1;
	wrt.dwDL = 1;

	// MOV EDX, XXXXXXXXX
	dwFinalDelta = ((DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto - (dwPatchJEPoint + 4));
	bCpyByte = 0xBA;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &bCpyByte, 1);
	dwIndexInto++;
	dwCpyDword = dwRealEntryPoint;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &dwCpyDword, 4);
	dwIndexInto += 4;
	_PolyGenerate( (LPVOID) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB));	

	// JMP EDX
	bCpyByte = 0xFF;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &bCpyByte, 1);
	dwIndexInto++;
	bCpyByte = 0xE2;
	memcpy( (void *) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB + dwIndexInto), &bCpyByte, 1);
	dwIndexInto++;
	_PolyGenerate( (LPVOID) ( (DWORD) lpBuild + pSecHdr->PointerToRawData + dwSizeSpace + LSIZE_STUB));	

	memcpy( (void *) (dwPatchJEPoint), &dwFinalDelta, 4);
	return dwIndexInto;
}

int PluginRemoveItem(HWND hwndDlg)
{
	int x;
	int i;
	char szPluginFile[256];

	x = ListView_GetNextItem(GetDlgItem(hwndDlg, IDC_LISTPLUG), -1, LVNI_ALL|LVNI_SELECTED);

	if (x == -1)
	{
		return -1;
	}

	ListView_GetItemText(GetDlgItem(hwndDlg, IDC_LISTPLUG), x, 0, szPluginFile, 255);

	for (i = 0; i < 20; i++)
	{
		if (lstrcmpi(lpPluginName[i], szPluginFile) == 0)
		{
			memset(lpPluginName[i], 0, 256);
			memset(lpPluginBlock[i], 0, 256);
		}
	}

	ListView_DeleteItem(GetDlgItem(hwndDlg, IDC_LISTPLUG), x);

	return 0;
}

int ParseAndBuildRsrc(LPVOID lpMapping)
{
	PIMAGE_DOS_HEADER pDosHdr;
	PIMAGE_NT_HEADERS pNtHdr;
	PIMAGE_SECTION_HEADER pSecHdr;
	PIMAGE_RESOURCE_DIRECTORY pRsrcDir;
	PIMAGE_RESOURCE_DIRECTORY_ENTRY pRsrcEnt;
	PIMAGE_RESOURCE_DATA_ENTRY pRsrcData;
	LONG lJmp;
	DWORD dwKatSup, dwSecStart, dwRvaResources, dwResourceOffset;
	DWORD dwCount, dwCalcFinalAddr, dwTrueSecBegin;
	DWORD dwBeginRsrc, dwCalcAddr, dwCountEnt, dwCountEntx;
	WORD wNumSections, wSizeO;
	int i, x, c;

	pDosHdr = (PIMAGE_DOS_HEADER) lpMapping;

	if (pDosHdr->e_magic != IMAGE_DOS_SIGNATURE)
	{
		MessageBox(0, "Missing MZ Signature, Exiting..", "Error", MB_OK|MB_ICONEXCLAMATION);
	 	return -1;
	}

	lJmp = pDosHdr->e_lfanew;
	dwKatSup = (DWORD) lpMapping;

	dwKatSup += lJmp;
	pNtHdr = (PIMAGE_NT_HEADERS) dwKatSup;

	wNumSections = pNtHdr->FileHeader.NumberOfSections;
	wSizeO = pNtHdr->FileHeader.SizeOfOptionalHeader;

	dwSecStart = (DWORD) pNtHdr;
	dwSecStart += 24;
	dwSecStart += wSizeO;
	dwTrueSecBegin = dwSecStart;

	pSecHdr = (PIMAGE_SECTION_HEADER) dwSecStart;

	for (i = 0; i < wNumSections; i++)
	{
		pSecHdr = (PIMAGE_SECTION_HEADER) dwSecStart;

		if (lstrcmpi( (LPSTR) pSecHdr, ".rsrc") == 0)
		{
			dwBeginRsrc = pSecHdr->PointerToRawData;
		}

		dwSecStart += sizeof(IMAGE_SECTION_HEADER);
	}

	dwSecStart = (DWORD) pNtHdr;
	dwSecStart += 24;
	dwSecStart += wSizeO;

	pSecHdr = (PIMAGE_SECTION_HEADER) dwSecStart;

	dwRvaResources = pNtHdr->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE].VirtualAddress;

	dwResourceOffset = RvaToOffset(dwRvaResources, wNumSections, (LPVOID) pSecHdr);
	dwResourceOffset += (DWORD) lpMapping;

	pRsrcDir = (PIMAGE_RESOURCE_DIRECTORY) dwResourceOffset;
	dwCount = pRsrcDir->NumberOfIdEntries + pRsrcDir->NumberOfNamedEntries;

	dwResourceOffset += sizeof(IMAGE_RESOURCE_DIRECTORY);

	for (i = 0; i < dwCount; i++)
	{
		pRsrcEnt = (PIMAGE_RESOURCE_DIRECTORY_ENTRY) dwResourceOffset;

		if (pRsrcEnt->Id == 3) // ICON
		{
			if (pRsrcEnt->DataIsDirectory)
			{
				dwCalcAddr = (DWORD) lpMapping;
				dwCalcAddr += dwBeginRsrc;
				dwCalcAddr += pRsrcEnt->OffsetToDirectory;

				pRsrcDir = (PIMAGE_RESOURCE_DIRECTORY) dwCalcAddr;

				dwCountEnt = pRsrcDir->NumberOfIdEntries;
				dwCountEnt += pRsrcDir->NumberOfNamedEntries;
				dwCalcAddr += sizeof(IMAGE_RESOURCE_DIRECTORY);

				if (dwCountEnt > 1)
				{
					dwCalcAddr += sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY);
					dwCountEnt--;
				}

				for (x = 0; x < dwCountEnt; x++)
				{
					pRsrcEnt = (PIMAGE_RESOURCE_DIRECTORY_ENTRY) dwCalcAddr;
				
					if (pRsrcEnt->DataIsDirectory)
					{
						dwIconBox[0] = pRsrcEnt->Id;

						dwCalcAddr = (DWORD) lpMapping;
						dwCalcAddr += dwBeginRsrc;
						dwCalcAddr += pRsrcEnt->OffsetToDirectory;

						pRsrcDir = (PIMAGE_RESOURCE_DIRECTORY) dwCalcAddr;

						dwCountEntx = pRsrcDir->NumberOfIdEntries;
						dwCountEntx += pRsrcDir->NumberOfNamedEntries;

						dwCalcAddr += sizeof(IMAGE_RESOURCE_DIRECTORY);

						for (c = 0; c < dwCountEntx; c++)
						{
							pRsrcEnt = (PIMAGE_RESOURCE_DIRECTORY_ENTRY) dwCalcAddr;
						
							if (!pRsrcEnt->DataIsDirectory)
							{
								dwIconBox[1] = pRsrcEnt->Id;

								dwCalcFinalAddr = (DWORD) lpMapping;
								dwCalcFinalAddr += dwBeginRsrc;
								dwCalcFinalAddr += pRsrcEnt->OffsetToData;

								pRsrcData = (PIMAGE_RESOURCE_DATA_ENTRY) dwCalcFinalAddr;
								
								dwSizeIcon = pRsrcData->Size;
								lpIconAddr = VirtualAlloc(NULL, pRsrcData->Size, MEM_COMMIT, PAGE_READWRITE);
								dwCalcFinalAddr = (DWORD) lpMapping;
								dwCalcFinalAddr += RvaToOffset(pRsrcData->OffsetToData, wNumSections, (LPVOID) dwTrueSecBegin);
								memcpy(lpIconAddr, (void *) dwCalcFinalAddr, pRsrcData->Size); 
							}
						}
					}

					dwCalcAddr += sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY);
				}
			}
		}
		else if (pRsrcEnt->Id == 0xE)
		{
			if (pRsrcEnt->DataIsDirectory)
			{
				dwCalcAddr = (DWORD) lpMapping;
				dwCalcAddr += dwBeginRsrc;
				dwCalcAddr += pRsrcEnt->OffsetToDirectory;

				pRsrcDir = (PIMAGE_RESOURCE_DIRECTORY) dwCalcAddr;
			
				dwCountEnt = pRsrcDir->NumberOfIdEntries;
				dwCountEnt += pRsrcDir->NumberOfNamedEntries;
				dwCalcAddr += sizeof(IMAGE_RESOURCE_DIRECTORY);

				for (x = 0; x < dwCountEnt; x++)
				{
					pRsrcEnt = (PIMAGE_RESOURCE_DIRECTORY_ENTRY) dwCalcAddr;

					if (pRsrcEnt->DataIsDirectory)
					{
						dwCalcAddr = (DWORD) lpMapping;
						dwCalcAddr += dwBeginRsrc;
						dwCalcAddr += pRsrcEnt->OffsetToDirectory;

						dwGroupIconBox[0] = pRsrcEnt->Id;

						pRsrcDir = (PIMAGE_RESOURCE_DIRECTORY) dwCalcAddr;

						dwCountEntx = pRsrcDir->NumberOfIdEntries;
						dwCountEntx += pRsrcDir->NumberOfNamedEntries;

						dwCalcAddr += sizeof(IMAGE_RESOURCE_DIRECTORY);

						for (c = 0; c < dwCountEntx; c++)
						{
							pRsrcEnt = (PIMAGE_RESOURCE_DIRECTORY_ENTRY) dwCalcAddr;
						
							if (!pRsrcEnt->DataIsDirectory)
							{
								dwGroupIconBox[1] = pRsrcEnt->Id;

								dwCalcFinalAddr = (DWORD) lpMapping;
								dwCalcFinalAddr += dwBeginRsrc;
								dwCalcFinalAddr += pRsrcEnt->OffsetToData;
							
								pRsrcData = (PIMAGE_RESOURCE_DATA_ENTRY) dwCalcFinalAddr;
								
								dwSizeGroupIcon = pRsrcData->Size;
								lpGroupIconAddr = VirtualAlloc(NULL, pRsrcData->Size, MEM_COMMIT, PAGE_READWRITE);
								dwCalcFinalAddr = (DWORD) lpMapping;
								dwCalcFinalAddr += RvaToOffset(pRsrcData->OffsetToData, wNumSections, (LPVOID) dwTrueSecBegin);
								memcpy(lpGroupIconAddr, (void *) dwCalcFinalAddr, pRsrcData->Size); 
							}
						}
					}

					dwCalcAddr += sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY);
				}
			}
		}
		
		dwResourceOffset += sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY);
	}

	return 0;
}

int PluginAddItem(HWND hwndDlg)
{
	OPENFILENAME ofn;
	HINSTANCE hLoadPlugin;
	INFOPROC fProcInfo;
	PIB_PLUG_INFO pPlugInfo;
	LV_ITEM lvi;
	char szRing[256];
	char szOperFile[256];

	memset(&ofn, 0, sizeof(ofn));
	ofn.lStructSize = sizeof(ofn);
	ofn.hwndOwner = hwndDlg;
	ofn.lpstrFile = szOperFile;
	ofn.lpstrFile[0] = '\0';
	ofn.nMaxFile = 255;
	ofn.lpstrFilter = "Dynamic Link Libraries (*.DLL) \0*.DLL\0";
	ofn.nFilterIndex = 1;
	ofn.lpstrFileTitle = NULL;
	ofn.nMaxFileTitle = 0;
	ofn.lpstrInitialDir = NULL;
	ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST;

	if (GetOpenFileName(&ofn) == FALSE)
	{
		return -1;
	}

	hLoadPlugin = LoadLibrary(szOperFile);
	fProcInfo = (INFOPROC) GetProcAddress(hLoadPlugin, "PibInfo"); 

	if (fProcInfo == NULL)
	{
		MessageBox(0, "Invalid PIB Plugin", "Error", MB_ICONEXCLAMATION);
		return -1;
	}

	(fProcInfo) (&pPlugInfo);
	
	memset(&lvi, 0, sizeof(lvi));
	lvi.mask = LVIF_TEXT;
	lvi.cchTextMax = 256;
	lvi.iItem = 0;
	lvi.iSubItem = 0;
	lvi.pszText = pPlugInfo.szPluginName;

	ListView_InsertItem(GetDlgItem(hwndDlg, IDC_LISTPLUG), &lvi);

	wsprintf(szRing, "%d", pPlugInfo.dwRing);

	lvi.iItem = 0;
	lvi.iSubItem = 1;
	lvi.pszText = szRing;

	ListView_SetItem(GetDlgItem(hwndDlg, IDC_LISTPLUG), &lvi);

	lvi.iItem = 0;
	lvi.iSubItem = 2;
	lvi.pszText = pPlugInfo.szPluginDesc;

	ListView_SetItem(GetDlgItem(hwndDlg, IDC_LISTPLUG), &lvi);

	lstrcpy(lpPluginBlock[dwPluginCount], szOperFile);
	lstrcpy(lpPluginName[dwPluginCount], pPlugInfo.szPluginName);
	dwPluginCount++;

	return 0;
}

int PluginPrepList(HWND hwndDlg)
{
	HMODULE hLoadedLib;
	INFOPROC fProcInfo;
	PIB_PLUG_INFO pPlugInfo;
	LV_ITEM lvi;
	char szRing[256];
	int i;

	for (i = 0; i < 20; i++)
	{
		if (strncmp(lpPluginBlock[i]+1, ":\\", 2) != 0)
		{
			continue;
		}

		hLoadedLib = LoadLibrary(lpPluginBlock[i]);
	
		fProcInfo = (INFOPROC) GetProcAddress(hLoadedLib, "PibInfo"); 

		if (fProcInfo == NULL)
		{
			MessageBox(0, "Invalid PIB Plugin", "Error", MB_ICONEXCLAMATION);
			return -1;
		}

		(fProcInfo) (&pPlugInfo);
	
		memset(&lvi, 0, sizeof(lvi));
		lvi.mask = LVIF_TEXT;
		lvi.cchTextMax = 256;
		lvi.iItem = 0;
		lvi.iSubItem = 0;
		lvi.pszText = pPlugInfo.szPluginName;

		ListView_InsertItem(GetDlgItem(hwndDlg, IDC_LISTPLUG), &lvi);

		wsprintf(szRing, "%d", pPlugInfo.dwRing);

		lvi.iItem = 0;
		lvi.iSubItem = 1;
		lvi.pszText = szRing;

		ListView_SetItem(GetDlgItem(hwndDlg, IDC_LISTPLUG), &lvi);

		lvi.iItem = 0;
		lvi.iSubItem = 2;
		lvi.pszText = pPlugInfo.szPluginDesc;

		ListView_SetItem(GetDlgItem(hwndDlg, IDC_LISTPLUG), &lvi);
	}

	return 0;
}

int FileSelectionPopup(HWND hwndDlg)
{
	OPENFILENAME ofn;
	char szOperFile[256];

	memset(&ofn, 0, sizeof(ofn));
	ofn.lStructSize = sizeof(ofn);
	ofn.hwndOwner = hwndDlg;
	ofn.lpstrFile = szOperFile;
	ofn.lpstrFile[0] = '\0';
	ofn.nMaxFile = sizeof(szOperFile);
	ofn.lpstrFilter = "Executable Files (*.EXE) \0*.EXE\0Dynamic Link Libaries (*.DLL) \0*.DLL\0";
	ofn.nFilterIndex = 1;
	ofn.lpstrFileTitle = NULL;
	ofn.nMaxFileTitle = 0;
	ofn.lpstrInitialDir = NULL;
	ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST;

	if (GetOpenFileName(&ofn) == FALSE)
	{
		return -1;
	}

	SetDlgItemText(hwndDlg, IDC_OFILE, szOperFile);

	return 0;
}

DWORD PibInstallPlugins(DWORD dwCurrentPoint, DWORD dwBaseProduct, DWORD dwVirt, DWORD dwVirtAddr)
{
	HMODULE hLoadedLib;
	INFOPROC pInfFunc;
	PFUNC pActualFunc;
	PSIZEFUNC pSizeFunc;
	PCLIENT pClientFunc;
	PCLIENTFUNC pClientFuncActual;
	PIB_PLUG_INFO pInfPlug;
	DWORD dwSizeReturn=0;
	DWORD dwCurrentSize;
	DWORD dwCurrentCpyPt;
	DWORD dwRing0Index, dwRing3Index;
	DWORD dwCalcAddr;
	DWORD dwOldProt;
	int i;

	dwCurrentCpyPt = LSIZE_STUB +  dwCurrentPoint;
	dwRing0Index = 0;
	dwRing3Index = 0;

	for (i = 0; i < 20; i++)
	{
		if (strncmp(lpPluginBlock[i]+1, ":\\", 2) != 0)
		{
			continue;
		}

		hLoadedLib = LoadLibrary(lpPluginBlock[i]);
		hModuleCallback[i] = hLoadedLib;

		pInfFunc = (INFOPROC) GetProcAddress(hLoadedLib, "PibInfo");

		if (pInfFunc == NULL)
		{
			MessageBox(0, "Invalid pib Plugin", NULL, MB_ICONINFORMATION|MB_OK);
			continue;
		}

		pActualFunc = (PFUNC) GetProcAddress(hLoadedLib, "PibFunc");

		if (pActualFunc == NULL)
		{
			MessageBox(0, "Invalid pib Plugin", NULL, MB_ICONINFORMATION|MB_OK);
			continue;
		}

		pSizeFunc = (PSIZEFUNC) GetProcAddress(hLoadedLib, "PibSizeFunc");
		
		if (pSizeFunc == NULL)
		{
			MessageBox(0, "Invalid pib Plugin", NULL, MB_ICONINFORMATION|MB_OK);
			continue;
		}

		pClientFunc = (PCLIENT) GetProcAddress(hLoadedLib, "PibClient");
	
		if (pClientFunc == NULL)
		{
			MessageBox(0, "Invalid pib Plugin", NULL, MB_ICONINFORMATION|MB_OK);
			continue;
		}

		pClientFuncActual = (PCLIENTFUNC) GetProcAddress(hLoadedLib, "PibClientWrap");

		if (pClientFuncActual == NULL)
		{
			MessageBox(0, "Invalid pib Plugin", NULL, MB_ICONINFORMATION|MB_OK);
			continue;
		}
	
		(pInfFunc)(&pInfPlug);
		VirtualProtect(pActualFunc, 0x1000, PAGE_EXECUTE_READWRITE, &dwOldProt);
		(pClientFunc)();
		dwCurrentSize = (pSizeFunc)();

		memcpy( (void *) (dwBaseProduct + dwVirtAddr + dwCurrentCpyPt), pActualFunc, dwCurrentSize);

		if (pInfPlug.dwRing == 0)
		{
			dwCalcAddr = dwVirt;
			dwCalcAddr += dwCurrentCpyPt;

			memcpy( (void *) (dwBaseProduct + dwVirtAddr + LOFFSET_RING0 + dwRing0Index), &dwCalcAddr, 4);
		
			dwRing0Index += 4;
		}

		if (pInfPlug.dwRing == 3)
		{
			dwCalcAddr = dwVirt;
			dwCalcAddr += dwCurrentCpyPt;

			memcpy( (void *) (dwBaseProduct + dwVirtAddr + LOFFSET_RING3 + dwRing3Index), &dwCalcAddr, 4);
		
			dwRing3Index += 4;
		}

		dwCurrentCpyPt += dwCurrentSize;
		dwSizeReturn += dwCurrentSize;
	}

	return dwSizeReturn;
}

DWORD PibDealLoader(DWORD dwMapAddr, PIMAGE_SECTION_HEADER pSecHdr)
{
	IMAGE_RESOURCE_DIRECTORY ImgRsrcDir;
	IMAGE_RESOURCE_DIRECTORY_ENTRY ImgRsrcDirEnt;
	IMAGE_RESOURCE_DATA_ENTRY ImgDataEntry;
	PIMAGE_DOS_HEADER pDosHdr;
	PIMAGE_NT_HEADERS pNtHdr;
	HANDLE hFile, hMapping;
	LPVOID lpMapping;
	DWORD dwFileSize, dwMapping, dwBaseRVA, dwA;
	DWORD dwTlsBackupEntry, dwRelocationBackupEntry, dwOrigDesc, dwRsrcSize;
	DWORD dwRetAddCpy, dwFileTrackingVar, dwPassiveLookup, dwReloBack;
	DWORD dwExpAddr, dwExpSize;
	LONG lOffset;

	hFile = CreateFile(SMAIN, GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, 0);

 	if (hFile == INVALID_HANDLE_VALUE)
	{
		MessageBox(0, "Invalid Handle For Opening SMAIN", "", MB_OK|MB_ICONEXCLAMATION);
		return -1;
	}

	hMapping = CreateFileMapping(hFile, NULL, PAGE_READWRITE, 0, 0, "smainmap");

 	if (hMapping == NULL)
	{

	 	MessageBox(0, "Invalid Handle For Creating Mapping SMAIN", "", MB_OK|MB_ICONEXCLAMATION);
	 	return -1;
	}

 	lpMapping = MapViewOfFile(hMapping, FILE_MAP_ALL_ACCESS, 0, 0, 0);

 	if (lpMapping == NULL)
	{
	 	MessageBox(0, "Invalid Pointer for Mapping SMAIN", "", MB_OK|MB_ICONEXCLAMATION);
	 	return -1;
	}

	dwFileSize = GetFileSize(hFile, NULL);

	pDosHdr = (PIMAGE_DOS_HEADER) dwMapAddr;
	
	dwMapping = dwMapAddr;
	lOffset = pDosHdr->e_lfanew;

	dwMapping += lOffset;
	pNtHdr = (PIMAGE_NT_HEADERS) dwMapping;
	pNtHdr->OptionalHeader.AddressOfEntryPoint += 0x86;

	dwTlsBackupEntry = pNtHdr->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_TLS].VirtualAddress;
	dwRelocationBackupEntry = pNtHdr->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].VirtualAddress;
	dwOrigDesc = pNtHdr->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress;
	dwReloBack = pNtHdr->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE].VirtualAddress;
	dwRsrcSize = pNtHdr->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE].Size;
	dwExpAddr = pNtHdr->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress;
	dwExpSize = pNtHdr->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].Size;

	memset(pNtHdr->OptionalHeader.DataDirectory, 0, (pNtHdr->OptionalHeader.NumberOfRvaAndSizes*8));

	pNtHdr->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress = pSecHdr->VirtualAddress;
	pNtHdr->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].Size = 30;

	memcpy( (void *) (dwMapAddr + pSecHdr->PointerToRawData), lpMapping, dwFileSize);

	dwBaseRVA = dwMapAddr;
	dwBaseRVA += pSecHdr->PointerToRawData;

	memcpy( (void *) (dwBaseRVA + LOFFSET_ORIGDESC), &dwOrigDesc, 4);

	if (dwTlsBackupEntry != 0)
	{
		pNtHdr->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_TLS].VirtualAddress = (pSecHdr->VirtualAddress + LOFFSET_TLS);
		pNtHdr->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_TLS].Size = 30;
	
		memcpy( (void *) (dwBaseRVA + LOFFSET_TLSENTRY), &dwTlsBackupEntry, 4);
	}

	if (dwRelocationBackupEntry != 0)
	{
		memcpy( (void *) (dwBaseRVA + LOFFSET_BASERELOC), &dwRelocationBackupEntry, 4);
	}

	dwA = pSecHdr->VirtualAddress + LOFFSET_DLLNAME;
	memcpy( (void *) ( dwBaseRVA + LOFFSET_ONAME), &dwA, 4);

	dwA = pSecHdr->VirtualAddress + LOFFSET_AFTHUNK;
	memcpy( (void *) ( dwBaseRVA + LOFFSET_FTHUNK), &dwA, 4);

	dwA = pSecHdr->VirtualAddress + LOFFSET_FENTRY;
	memcpy( (void *) ( dwBaseRVA + LOFFSET_AFTHUNK), &dwA, 4);

	dwA = pSecHdr->VirtualAddress + LOFFSET_SENTRY;
	memcpy( (void *) ( dwBaseRVA + LOFFSET_ASTHUNK), &dwA, 4);

	dwA = pSecHdr->VirtualAddress + LOFFSET_AINDEX;
	dwA += pNtHdr->OptionalHeader.ImageBase;
	TlsDir.AddressOfIndex = dwA;

	dwA = pSecHdr->VirtualAddress + LOFFSET_ACALLBACKS;
	dwA += pNtHdr->OptionalHeader.ImageBase;
	TlsDir.AddressOfCallBacks = dwA;

	memcpy( (void *) ( dwBaseRVA + LOFFSET_RVATBL), &dwRvaTbl, 40);
	memcpy( (void *) ( dwBaseRVA + LOFFSET_SIZETBL), &dwSizeTbl, 40);
	memcpy( (void *) ( dwBaseRVA + LOFFSET_ENTRYPOINT), &dwOrigEntrypoint, 4);
	memcpy( (void *) ( dwBaseRVA + LOFFSET_RSRCENTRY), &dwOrigRsrcRVA, 4);
	memcpy( (void *) ( dwBaseRVA + LOFFSET_TLS), &TlsDir, sizeof(IMAGE_TLS_DIRECTORY));
	memcpy( (void *) ( dwBaseRVA + LOFFSET_EXP), &dwExpAddr, 4);
	memcpy( (void *) ( dwBaseRVA + LOFFSET_EXPSIZE), &dwExpSize, 4);
	

	if (boolPresRsrc == TRUE)
	{
		pNtHdr->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE].VirtualAddress = dwReloBack;
		pNtHdr->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE].Size = dwRsrcSize;
	}

	if (boolRsrc == TRUE)
	{
		dwFileTrackingVar = 0;
		dwRetAddCpy = dwFileSize;
		pNtHdr->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE].VirtualAddress = (dwSeperCalc + dwFileSize);
		pNtHdr->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE].Size = 50;

		memset(&ImgRsrcDir, 0, sizeof(IMAGE_RESOURCE_DIRECTORY));
		ImgRsrcDir.TimeDateStamp = 0x3022B2E8;
		ImgRsrcDir.NumberOfIdEntries = 2;

		memcpy( (void *) ( dwBaseRVA + dwFileSize), &ImgRsrcDir, sizeof(IMAGE_RESOURCE_DIRECTORY));
		dwFileSize += sizeof(IMAGE_RESOURCE_DIRECTORY);
		dwFileTrackingVar += sizeof(IMAGE_RESOURCE_DIRECTORY);
	
		ImgRsrcDirEnt.Id = 3;
		ImgRsrcDirEnt.DataIsDirectory = 1;
		ImgRsrcDirEnt.OffsetToDirectory = (dwFileTrackingVar + sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY) + sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY));
		memcpy( (void *) ( dwBaseRVA + dwFileSize), &ImgRsrcDirEnt, sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY));
		dwFileSize += sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY);
		dwFileTrackingVar += sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY);

		ImgRsrcDirEnt.Id = 0xE;
		ImgRsrcDirEnt.DataIsDirectory = 1;
		ImgRsrcDirEnt.OffsetToDirectory = 0;
		dwPassiveLookup = dwBaseRVA + dwFileSize;
		memcpy( (void *) ( dwBaseRVA + dwFileSize), &ImgRsrcDirEnt, sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY));
		dwFileSize += sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY);
		dwFileTrackingVar += sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY);

		ImgRsrcDir.NumberOfIdEntries = 1;
		ImgRsrcDir.NumberOfNamedEntries = 0;
		memcpy( (void *) ( dwBaseRVA + dwFileSize), &ImgRsrcDir, sizeof(IMAGE_RESOURCE_DIRECTORY));
		dwFileSize += sizeof(IMAGE_RESOURCE_DIRECTORY);
		dwFileTrackingVar += sizeof(IMAGE_RESOURCE_DIRECTORY);

		ImgRsrcDirEnt.Id = dwIconBox[0];
		ImgRsrcDirEnt.DataIsDirectory = 1;
		ImgRsrcDirEnt.OffsetToDirectory = (dwFileTrackingVar + sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY));
		memcpy( (void *) ( dwBaseRVA + dwFileSize), &ImgRsrcDirEnt, sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY));
		dwFileSize += sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY);
		dwFileTrackingVar += sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY);

		memcpy( (void *) ( dwBaseRVA + dwFileSize), &ImgRsrcDir, sizeof(IMAGE_RESOURCE_DIRECTORY));
		dwFileSize += sizeof(IMAGE_RESOURCE_DIRECTORY);
		dwFileTrackingVar += sizeof(IMAGE_RESOURCE_DIRECTORY);

		ImgRsrcDirEnt.Id = dwIconBox[1];
		ImgRsrcDirEnt.DataIsDirectory = 0;
		ImgRsrcDirEnt.OffsetToData = (dwFileTrackingVar + sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY));
		memcpy( (void *) ( dwBaseRVA + dwFileSize), &ImgRsrcDirEnt, sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY));
		dwFileSize += sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY);
		dwFileTrackingVar += sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY);

		memset(&ImgDataEntry, 0, sizeof(IMAGE_RESOURCE_DATA_ENTRY));
		ImgDataEntry.Size = dwSizeIcon;
		ImgDataEntry.OffsetToData = (dwSeperCalc + dwFileSize + sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY) + sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY));
		memcpy( (void *) ( dwBaseRVA + dwFileSize), &ImgDataEntry, sizeof(IMAGE_RESOURCE_DATA_ENTRY));
		dwFileSize += sizeof(IMAGE_RESOURCE_DATA_ENTRY);
		dwFileTrackingVar += sizeof(IMAGE_RESOURCE_DATA_ENTRY);

		memcpy( (void *) ( dwBaseRVA + dwFileSize), lpIconAddr, dwSizeIcon);
		dwFileSize += dwSizeIcon;
		dwFileTrackingVar += dwSizeIcon;

		ImgRsrcDirEnt.Id = 0xE;
		ImgRsrcDirEnt.DataIsDirectory = 1;
		ImgRsrcDirEnt.OffsetToDirectory = (dwFileTrackingVar + sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY));
		memcpy( (void *) dwPassiveLookup, &ImgRsrcDirEnt, sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY));
		dwFileSize += sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY);
		dwFileTrackingVar += sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY);
		
		memset(&ImgRsrcDir, 0, sizeof(IMAGE_RESOURCE_DIRECTORY));
		ImgRsrcDir.TimeDateStamp = 0x3022B2E8;
		ImgRsrcDir.NumberOfIdEntries = 1;

		memcpy( (void *) ( dwBaseRVA + dwFileSize), &ImgRsrcDir, sizeof(IMAGE_RESOURCE_DIRECTORY));
		dwFileSize += sizeof(IMAGE_RESOURCE_DIRECTORY);
		dwFileTrackingVar += sizeof(IMAGE_RESOURCE_DIRECTORY);

		ImgRsrcDirEnt.Id = dwGroupIconBox[0];
		ImgRsrcDirEnt.DataIsDirectory = 1;
		ImgRsrcDirEnt.OffsetToDirectory = (dwFileTrackingVar + sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY));
		memcpy( (void *) ( dwBaseRVA + dwFileSize), &ImgRsrcDirEnt, sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY));
		dwFileSize += sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY);
		dwFileTrackingVar += sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY);

		memcpy( (void *) ( dwBaseRVA + dwFileSize), &ImgRsrcDir, sizeof(IMAGE_RESOURCE_DIRECTORY));
		dwFileSize += sizeof(IMAGE_RESOURCE_DIRECTORY);
		dwFileTrackingVar += sizeof(IMAGE_RESOURCE_DIRECTORY);

		ImgRsrcDirEnt.Id = dwGroupIconBox[1];
		ImgRsrcDirEnt.DataIsDirectory = 0;
		ImgRsrcDirEnt.OffsetToData = (dwFileTrackingVar + sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY));
		memcpy( (void *) ( dwBaseRVA + dwFileSize), &ImgRsrcDirEnt, sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY));
		dwFileSize += sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY);
		dwFileTrackingVar += sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY);

		memset(&ImgDataEntry, 0, sizeof(IMAGE_RESOURCE_DATA_ENTRY));
		ImgDataEntry.Size = dwSizeGroupIcon;
		ImgDataEntry.OffsetToData = (dwSeperCalc + dwFileSize + sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY) + sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY));
		memcpy( (void *) ( dwBaseRVA + dwFileSize), &ImgDataEntry, sizeof(IMAGE_RESOURCE_DATA_ENTRY));
		dwFileSize += sizeof(IMAGE_RESOURCE_DATA_ENTRY);
		dwFileTrackingVar += sizeof(IMAGE_RESOURCE_DATA_ENTRY);

		memcpy( (void *) ( dwBaseRVA + dwFileSize), lpGroupIconAddr, dwSizeGroupIcon);
		dwFileSize += dwSizeGroupIcon;
		dwFileTrackingVar += dwSizeGroupIcon;

		dwRetAddCpy = (dwFileSize - dwRetAddCpy);
		return dwRetAddCpy;
	}

	UnmapViewOfFile(lpMapping);
	CloseHandle(hMapping);
	CloseHandle(hFile);

	return 0;
}

int BeginPib(HWND hwndDlg, HWND hwndDlgx)
{
	PIMAGE_DOS_HEADER pDosHdr;
	PIMAGE_NT_HEADERS pNtHdr;
	PIMAGE_SECTION_HEADER pSecHdr;
	IMAGE_SECTION_HEADER SecHdr;
	HANDLE hFile, hMapping;
	PCLIENTFUNC pClientFunc;
	HMODULE hLoadedLib;
	DWORD dwFileSize, dwMapping, dwSecStart, dwPointerNew, dwOldEP;
	DWORD dwCalcVal, dwUsingRound, dwRoundedSize, dwPluginSizeBack;
	DWORD dwFilePointer, dwCurrentPoint, dwFinalMap, dwBaseOffsetting;
	DWORD dwApacksize, dwA, dwB, dwX, dwTlsAddr, dwWrote, dwBaseOff;
	DWORD dwSizeWithIcons, dwChecksumOld, dwChecksumNew;
	WORD wNumSections, wSizeO;
	LONG lOffset, lAddrMov;
	LPVOID lpMapping, lpReMap, lpFinalMap, lpWorkMem, lpWorkBench;
	char szOperFile[256];
	char szTextInput[256];
	int i, x;

	GetDlgItemText(hwndDlg, IDC_OFILE, szOperFile, 255);

	if (lstrlen(szOperFile) < 3)
	{
		MessageBox(0, "No File Selected", "", MB_OK|MB_ICONEXCLAMATION);
		return -1;	
	}

	hFile = CreateFile(szOperFile, GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, 0);

 	if (hFile == INVALID_HANDLE_VALUE)
	{
		MessageBox(0, "Failed to get access to file", "", MB_OK|MB_ICONEXCLAMATION);
		return -1;
	}

	dwFileSize = GetFileSize(hFile, NULL);
	lpReMap = VirtualAlloc(NULL, dwFileSize+0x10000, MEM_COMMIT, PAGE_READWRITE);
	lpFinalMap = VirtualAlloc(NULL, dwFileSize+0x10000, MEM_COMMIT, PAGE_READWRITE);
	dwFinalMap = (DWORD) lpFinalMap;

	hMapping = CreateFileMapping(hFile, NULL, PAGE_READWRITE, 0, 0, "smainmap");

 	if (hMapping == NULL)
	{
	 	MessageBox(0, "Failed to map selected file", "", MB_OK|MB_ICONEXCLAMATION);
	 	return -1;
	}

 	lpMapping = MapViewOfFile(hMapping, FILE_MAP_ALL_ACCESS, 0, 0, 0);

 	if (lpMapping == NULL)
	{
	 	MessageBox(0, "Failed to map selected file", "", MB_OK|MB_ICONEXCLAMATION);
	 	return -1;
	}

	memcpy(lpReMap, lpMapping, dwFileSize);

	UnmapViewOfFile(lpMapping);
	CloseHandle(hMapping);
	CloseHandle(hFile);

	lpMapping = lpReMap;

	pDosHdr = (PIMAGE_DOS_HEADER) lpMapping;

	if (pDosHdr->e_magic != IMAGE_DOS_SIGNATURE)
	{
		MessageBox(0, "Missing MZ Signature, Exiting..", "Error", MB_OK|MB_ICONEXCLAMATION);
	 	return -1;
	}
	
	dwMapping = (DWORD) lpMapping;
	lOffset = pDosHdr->e_lfanew;

	dwMapping += lOffset;
	pNtHdr = (PIMAGE_NT_HEADERS) dwMapping;

	if (pNtHdr->OptionalHeader.LoaderFlags ==  IMAGE_PIB_SIG)
	{
		MessageBox(0, "File Already Packed by pib", "Error", MB_ICONEXCLAMATION|MB_OK);
		return -1;
	}

	pNtHdr->OptionalHeader.LoaderFlags = IMAGE_PIB_SIG;

	dwOrigEntrypoint = pNtHdr->OptionalHeader.AddressOfEntryPoint;
	dwOrigRsrcRVA = pNtHdr->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE].VirtualAddress;

	wNumSections = pNtHdr->FileHeader.NumberOfSections;
	wSizeO = pNtHdr->FileHeader.SizeOfOptionalHeader;

	dwSecStart = (DWORD) pNtHdr;
	dwSecStart += 24;
	dwSecStart += wSizeO;

	pSecHdr = (PIMAGE_SECTION_HEADER) dwSecStart;

	dwPointerNew = pSecHdr->PointerToRawData;
	dwPointerNew += (DWORD) lpMapping;

	dwSecStart += (sizeof(IMAGE_SECTION_HEADER) * wNumSections);
	dwSecStart += sizeof(IMAGE_SECTION_HEADER);

	if (dwSecStart >= dwPointerNew)
	{
		MessageBox(0, "Unable to Create New Section, Not Enough Room", "Error", MB_ICONEXCLAMATION|MB_OK);
		return -1;
	}

	dwSecStart -= sizeof(IMAGE_SECTION_HEADER);

	pSecHdr = (PIMAGE_SECTION_HEADER) (dwSecStart - sizeof(IMAGE_SECTION_HEADER));

	memcpy(&dwCalcVal, (void *) (((DWORD) pSecHdr) +8), 4);

	dwSeperCalc = dwCalcVal / 0x1000;
	dwSeperCalc = dwSeperCalc * 0x1000;

	dwCalcVal = dwCalcVal % 0x1000;

	if (dwCalcVal > 1)
	{
		dwSeperCalc += 0x1000;
	}

	dwSeperCalc += pSecHdr->VirtualAddress;

	SecHdr.VirtualAddress = dwSeperCalc;
	dwBaseOffsetting = dwSeperCalc;
	SecHdr.Characteristics = 0xE0000060;
	SecHdr.SizeOfRawData = 0x2000;
	
	dwUsingRound = (pSecHdr->SizeOfRawData / pNtHdr->OptionalHeader.FileAlignment);
	dwRoundedSize = (pSecHdr->SizeOfRawData % pNtHdr->OptionalHeader.FileAlignment);

	if (dwRoundedSize == 0)
	{
		dwRoundedSize = 0;
	}
	else
	{
		dwRoundedSize = pNtHdr->OptionalHeader.FileAlignment;
	}

	dwRoundedSize += (dwUsingRound * pNtHdr->OptionalHeader.FileAlignment);

	lAddrMov = pSecHdr->PointerToRawData + dwRoundedSize;
	SecHdr.PointerToRawData = lAddrMov;
	dwBaseOff = lAddrMov;

	dwCalcVal = 0x2000;
	memcpy(&SecHdr.Misc, &dwCalcVal, 4);

	lstrcpy( (LPSTR) SecHdr.Name, ASEC_NAME);

	memcpy( (void *) dwSecStart, &SecHdr, sizeof(IMAGE_SECTION_HEADER));
	pNtHdr->FileHeader.NumberOfSections++;
	dwOldEP = pNtHdr->OptionalHeader.AddressOfEntryPoint;
	pNtHdr->OptionalHeader.AddressOfEntryPoint = dwSeperCalc;
	pNtHdr->OptionalHeader.SizeOfImage += 0x2000;

	dwSecStart = (DWORD) pNtHdr;
	dwSecStart += 24;
	dwSecStart += wSizeO;

	pSecHdr = (PIMAGE_SECTION_HEADER) dwSecStart;

	dwCurrentPoint = pSecHdr->PointerToRawData;
	dwFilePointer = pSecHdr->PointerToRawData;

	if (pNtHdr->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_TLS].VirtualAddress != 0)
	{
		dwTlsAddr = RvaToOffset(pNtHdr->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_TLS].VirtualAddress, wNumSections, pSecHdr);

		memcpy(&TlsDir, (void *) ( ( (DWORD) lpMapping) + dwTlsAddr), sizeof(IMAGE_TLS_DIRECTORY)); 
	}
	
	pSecHdr = (PIMAGE_SECTION_HEADER) dwSecStart;

	for (i = 0; i <= wNumSections; i++)
	{
		pSecHdr = (PIMAGE_SECTION_HEADER) dwSecStart;
		pSecHdr->Characteristics = 0xE0000020;

		wsprintf(szTextInput, "Section: %s", (LPSTR) pSecHdr);
		SetDlgItemText(hwndDlgx, IDC_STATIC2, szTextInput);

		wsprintf(szTextInput, "Bytes: %d (0x%x)", pSecHdr->SizeOfRawData, pSecHdr->SizeOfRawData);
		SetDlgItemText(hwndDlgx, IDC_STATIC3, szTextInput);

		if (pSecHdr->SizeOfRawData == 0)
		 {
			dwSecStart += sizeof(IMAGE_SECTION_HEADER);

			continue;
		}

		if (lstrcmpi( (LPSTR) pSecHdr, ".rsrc") == 0)
		{
			if (dwFlags & FRSRC_GO)
			{
				if (dwFlags & FICON)
				{
					ParseAndBuildRsrc(lpMapping);
					boolRsrc = TRUE;
				}

				goto ValidRsrcCompress;
			}

			boolPresRsrc = TRUE;
			boolRsrc = FALSE;
			dwSecStart += sizeof(IMAGE_SECTION_HEADER);

			memcpy( (void *) (dwCurrentPoint + dwFinalMap), (void *) ( (DWORD) lpReMap + pSecHdr->PointerToRawData), pSecHdr->SizeOfRawData);
			
			pSecHdr->PointerToRawData = dwCurrentPoint;
			dwCurrentPoint += pSecHdr->SizeOfRawData;

			continue;
		}

		ValidRsrcCompress:

		if (lstrcmpi( (LPSTR) pSecHdr, ASEC_NAME) == 0)
		{
			pSecHdr->PointerToRawData = dwCurrentPoint;
			pSecHdr->SizeOfRawData = 0x2000;

			dwCurrentPoint += 0x2000;

			break;
		}

		lpWorkMem = VirtualAlloc(NULL, aP_workmem_size(pSecHdr->SizeOfRawData), MEM_COMMIT, PAGE_EXECUTE_READWRITE);
		lpWorkBench = VirtualAlloc(NULL, pSecHdr->SizeOfRawData+0x10000, MEM_COMMIT, PAGE_READWRITE);

		dwApacksize = aP_pack( (void *) ( (DWORD) lpReMap + pSecHdr->PointerToRawData), lpWorkBench, pSecHdr->SizeOfRawData, lpWorkMem, NULL, NULL); 

		if (dwApacksize > pSecHdr->SizeOfRawData)
		{
			memcpy( (void *) (dwCurrentPoint + dwFinalMap), (void *) ( (DWORD) lpReMap + pSecHdr->PointerToRawData), pSecHdr->SizeOfRawData);
		
			for (x = 0; x < 20; x++)
			{
				if (strncmp(lpPluginBlock[i]+1, ":\\", 2) != 0)
				{
					continue;
				}

				hLoadedLib = LoadLibrary(lpPluginBlock[i]);

				pClientFunc = (PCLIENTFUNC) GetProcAddress(hLoadedLib, "PibClientWrap");

				if (pClientFunc == NULL)
				{
					continue;
				}

				(pClientFunc)((dwCurrentPoint + dwFinalMap), pSecHdr->SizeOfRawData);
			}

			dwCurrentPoint += pSecHdr->SizeOfRawData;

			dwSecStart += sizeof(IMAGE_SECTION_HEADER);
			continue;
		}
		else
		{
			memcpy( (void *) (dwCurrentPoint + dwFinalMap), lpWorkBench, dwApacksize);
		
			for (x = 0; x < 20; x++)
			{
				if (strncmp(lpPluginBlock[i]+1, ":\\", 2) != 0)
				{
					continue;
				}

				hLoadedLib = LoadLibrary(lpPluginBlock[i]);

				pClientFunc = (PCLIENTFUNC) GetProcAddress(hLoadedLib, "PibClientWrap");

				if (pClientFunc == NULL)
				{
					continue;
				}

				(pClientFunc)((dwCurrentPoint + dwFinalMap), dwApacksize);
			}
		}

		VirtualFree(lpWorkBench, 0, MEM_RELEASE);
		dwRvaTbl[dwGlobalCount] = pSecHdr->VirtualAddress;
		memcpy(&dwX, (void *) ( (DWORD) pSecHdr + 8), 4);

		if (dwX >= pSecHdr->SizeOfRawData)
		{
			dwSizeTbl[dwGlobalCount] = pSecHdr->SizeOfRawData;
		}
		else
		{
			dwSizeTbl[dwGlobalCount] = dwX;
		}
		
		dwGlobalCount++;

		dwA = (dwApacksize / pNtHdr->OptionalHeader.FileAlignment);
		dwB = (dwApacksize % pNtHdr->OptionalHeader.FileAlignment);

		if (dwB > 0)
			dwA++;

		dwA = dwA * pNtHdr->OptionalHeader.FileAlignment;

		pSecHdr->PointerToRawData = dwCurrentPoint;
		pSecHdr->SizeOfRawData = dwA;

		dwCurrentPoint += dwA;

		VirtualFree(lpWorkMem, 0, MEM_RELEASE);
		dwSecStart += sizeof(IMAGE_SECTION_HEADER);
	}

	memcpy(lpFinalMap, lpMapping, dwFilePointer);

	dwSizeWithIcons = PibDealLoader( (DWORD) lpFinalMap, pSecHdr);
	DeleteFile(szOperFile);

	dwPluginSizeBack = PibInstallPlugins(dwSizeWithIcons, (DWORD) lpFinalMap, pSecHdr->VirtualAddress, pSecHdr->PointerToRawData);
	dwCurrentPoint += dwPluginSizeBack;
	hFile = CreateFile(szOperFile, GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ, NULL, CREATE_ALWAYS, 0, 0);

	pDosHdr = (PIMAGE_DOS_HEADER) lpFinalMap;
	pNtHdr = (PIMAGE_NT_HEADERS) ( (DWORD) lpFinalMap + pDosHdr->e_lfanew);

	if (dwFlags & FPIB_POLY)
	{
		PibPolyBuild(lpFinalMap, dwCurrentPoint, dwSizeWithIcons, pSecHdr, pNtHdr);
	}

	WriteFile(hFile, lpFinalMap, (dwCurrentPoint + dwSizeWithIcons), &dwWrote, NULL);
	CloseHandle(hFile);

	return 0;
}

int PibRecvOpt(HWND hwndDlg)
{
	dwFlags = 0;

	if (IsDlgButtonChecked(hwndDlg, IDC_CHECK1) == BST_CHECKED)
	{
		dwFlags += FPIB_POLY; 
	}
	
	if (IsDlgButtonChecked(hwndDlg, IDC_CHECK2) == BST_CHECKED)
	{
		dwFlags += FRSRC_GO;

		if (IsDlgButtonChecked(hwndDlg, IDC_CHECK3) == BST_CHECKED)
		{
			dwFlags += FICON;
		}
	}

	return 0;
}

int PluginAddColumns(HWND hwndDlg)
{
	LVCOLUMN lvc;
	
	memset(&lvc, 0, sizeof(lvc));
	lvc.mask = LVCF_TEXT|LVCF_WIDTH|LVCF_SUBITEM;
	lvc.cx = 60;
	lvc.iImage=0;
	lvc.pszText="Name";

	ListView_InsertColumn(GetDlgItem(hwndDlg, IDC_LISTPLUG), 0, &lvc);

	memset(&lvc, 0, sizeof(lvc));
	lvc.mask = LVCF_TEXT|LVCF_WIDTH|LVCF_SUBITEM;
	lvc.cx = 60;
	lvc.iImage=0;
	lvc.pszText="Priority";

	ListView_InsertColumn(GetDlgItem(hwndDlg, IDC_LISTPLUG), 1, &lvc);

	memset(&lvc, 0, sizeof(lvc));
	lvc.mask = LVCF_TEXT|LVCF_WIDTH|LVCF_SUBITEM;
	lvc.cx = 106;
	lvc.iImage=0;
	lvc.pszText="Description";

	ListView_InsertColumn(GetDlgItem(hwndDlg, IDC_LISTPLUG), 2, &lvc);

	return 0;
}

static BOOL CALLBACK PluginDlg(HWND hwndDlg, 
							 UINT msg, 
							 WPARAM     wParam, 
							 LPARAM     lParam)
{
	switch (msg) 
	{
		case WM_INITDIALOG:
			PluginAddColumns(hwndDlg);
			PluginPrepList(hwndDlg);
			return TRUE;

		case WM_NOTIFY:
			LPNMHDR l;

			l = (LPNMHDR) lParam;

			if (l->code == NM_RCLICK)
			{
				if (l->idFrom == IDC_LISTPLUG)
				{
					HMENU hMenu, hSubMenu;
					POINT p;
					int x;

					hMenu = LoadMenu(ghInstance, MAKEINTRESOURCE(IDR_MENUPLUG));
					hSubMenu = GetSubMenu(hMenu, 0);

					GetCursorPos(&p);

					x = TrackPopupMenu(hSubMenu, TPM_RETURNCMD|TPM_RIGHTBUTTON|TPM_LEFTBUTTON|TPM_NONOTIFY,p.x,p.y,0,hwndDlg,NULL);
					
					if (x == ID_FILE_ADD)
					{
						PluginAddItem(hwndDlg);
					}
					else if (x == ID_FILE_REMOVE)
					{
						PluginRemoveItem(hwndDlg);
					}
				}
			}
			return TRUE;
			break;

		case WM_CLOSE:
			EndDialog(hwndDlg,0);
			return TRUE;
	}

	return FALSE;
}

static BOOL CALLBACK OptDlg(HWND hwndDlg, 
							 UINT msg, 
							 WPARAM     wParam, 
							 LPARAM     lParam)
{
	switch (msg) 
	{
		case WM_INITDIALOG:
			return TRUE;
		break;

		case WM_COMMAND:
			switch (LOWORD(wParam))
			{
				case IDC_APPLY:
					PibRecvOpt(hwndDlg);
					MessageBox(0, "Updated Settings", "pib - update", MB_OK|MB_ICONINFORMATION);
				break;
			}
		return TRUE;

		case WM_CLOSE:
			EndDialog(hwndDlg,0);
			return TRUE;
		break;

	}

	return FALSE;
}

DWORD WINAPI ProgressFunc(LPVOID lpParam) 
{
	char szTextInput[256];

    Sleep(900);
	SetCurrentDirectory(szCurrentDir);
	lstrcpy(szTextInput, "Status: Working...");
	SetDlgItemText(hwndDlgSubA, IDC_WORK1, szTextInput);

	if (BeginPib(hwndDlgSubB, hwndDlgSubA) != -1)
	{
		MessageBox(0, "pib compressed file", "pib - info", MB_OK|MB_ICONINFORMATION);
	}

    return 0; 
}

static BOOL CALLBACK WorkDlg(HWND hwndDlg, 
							 UINT msg, 
							 WPARAM     wParam, 
							 LPARAM     lParam)
{
	DWORD dwTID;

	switch (msg) 
	{
		case WM_INITDIALOG:
			hwndDlgSubA = hwndDlg;
			CreateThread(NULL, 0, ProgressFunc, NULL, 0, &dwTID);
			return TRUE;

		case WM_CLOSE:
			EndDialog(hwndDlg,0);
			return TRUE;
	}
			
	return FALSE;
}

static BOOL CALLBACK MainDlg(HWND hwndDlg, 
							 UINT msg, 
							 WPARAM     wParam, 
							 LPARAM     lParam)
{
	switch (msg) 
	{
		case WM_INITDIALOG:
			return TRUE;

		case WM_COMMAND:
			switch (LOWORD(wParam))
			{
				case IDC_BUTTON3:
					MessageBox(0, "PIB - PackItBitch - Executable Packer/Protector - archphase 2004", "pib - about", MB_OK|MB_ICONINFORMATION);
				break;

				case IDC_GO:
					xmhwndDlg = hwndDlg;
					hwndDlgSubB = hwndDlg;
					DialogBox(ghInstance, MAKEINTRESOURCE(IDD_WORK), NULL, (DLGPROC) WorkDlg);
				break;

				case IDC_BUTTON4:
					DialogBox(ghInstance, MAKEINTRESOURCE(IDD_PLUGIN), NULL, (DLGPROC) PluginDlg);
				break;

				case IDC_PICKFILE:
					FileSelectionPopup(hwndDlg);
				break;

				case IDC_OPTBUT:
					DialogBox(ghInstance, MAKEINTRESOURCE(IDD_OPT), NULL, (DLGPROC) OptDlg);
			}
		return TRUE;
        
		case WM_CLOSE:
			EndDialog(hwndDlg,0);
			return TRUE;
	}

	return FALSE;
}

int APIENTRY WinMain(HINSTANCE hInstance,
                     HINSTANCE hPrevInstance,
                     LPSTR     lpCmdLine,
                     int       nCmdShow)
{
	int i;

	for (i = 0; i < 20; i++)
	{
		lpPluginBlock[i] = (char *) malloc(256);
		lpPluginName[i] = (char *) malloc(256);
	}

	GetCurrentDirectory(255, szCurrentDir);
	InitCommonControls();

	ghInstance = hInstance;
	DialogBox(hInstance, MAKEINTRESOURCE(IDD_MAIN), NULL, (DLGPROC) MainDlg);

	return 0;
}
