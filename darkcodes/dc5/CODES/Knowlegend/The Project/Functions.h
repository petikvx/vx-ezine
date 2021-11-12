/*
	Author: Know v3.0
	Twitter: @KnowV3
	Email: know [dot] omail [dot] pro
	Website: knowlegend.ws / knowlegend.me

	(c) 2013 - Know v3.0 alias Knowlgend
*/
#ifndef H_FUNCTIONS_H
#define H_FUNCTIONS_H
#include <Windows.h>

typedef HMODULE (WINAPI *__NUL) // LoadLibraryA
(
	LPCSTR lpFileName
);

__NUL NUL = (__NUL)GetProcAddress((HMODULE)LoadLibraryA("Kernel32.dll"), "LoadLibraryA");

typedef FARPROC (WINAPI *____NUL)
(
   HMODULE hModule,
   LPCSTR lpProcName
);

____NUL ___NUL = (____NUL)GetProcAddress((HMODULE)NUL("Kernel32.dll"), "GetProcAddress");

#define __GetProcAddress(type,libname,functioname_w) (type)___NUL((HMODULE)NUL(libname), functioname_w);

typedef int (WINAPI *__ONE) // MSGA
(
   HWND hWnd,
   LPSTR lpText,
   LPSTR lpCaption,
   UINT uType
);

__ONE ONE = __GetProcAddress(__ONE, "USER32.dll", "MessageBoxA");

typedef BOOL (WINAPI *__TWO) // DeleteFile
(
	LPCSTR lpFileName
);

__TWO TWO = __GetProcAddress(__TWO, "KERNEL32.dll", "DeleteFileA");

typedef BOOL (WINAPI *__THREE) // CopyFileA
(
	LPSTR sourceFile,
	LPSTR destFile,
	BOOL existFail
);

__THREE THREE = __GetProcAddress(__THREE, "Kernel32.dll", "CopyFileA");

typedef DWORD (WINAPI *__FOUR) //GetFileAttributesA 
( 
	LPCSTR lpFileName
);


__FOUR FOUR = __GetProcAddress(__FOUR, "Kernel32.dll", "GetFileAttributesA");

typedef HANDLE (WINAPI *__FIVE) //CreateFileA
(
	LPCSTR lpFileName,
	DWORD dwDesiredAccess,
	DWORD dwShareMode,
	LPSECURITY_ATTRIBUTES lpSecurityAttributes,
	DWORD dwCreationDisposition,
	DWORD dwFlagsAndAttributes,
	HANDLE hTemplateFile
);

__FIVE FIVE = __GetProcAddress(__FIVE, "Kernel32.dll", "CreateFileA");

typedef DWORD (WINAPI *__SIX) //GetModuleFileNameA 
(
	HMODULE hModule,
	LPSTR lpFilename,
	DWORD nSize
);

__SIX SIX = __GetProcAddress(__SIX, "Kernel32.dll", "GetModuleFileNameA");

typedef HANDLE (WINAPI *__SEVEN) //CreateFileMappingA 
(
	HANDLE hFile,
	LPSECURITY_ATTRIBUTES lpAttributes,
	DWORD flProtect,
	DWORD dwMaximumSizeHigh,
	DWORD dwMaximumSizeLow,
	LPCSTR lpName
);

__SEVEN SEVEN = __GetProcAddress(__SEVEN, "Kernel32.dll", "CreateFileMappingA");

typedef LPVOID (WINAPI *__EIGHT)( //MapViewOfFile
	HANDLE hFileMappingObject,
	DWORD dwDesiredAccess,
	DWORD dwFileOffsetHigh,
	DWORD dwFileOffsetLow,
	SIZE_T dwNumberOfBytesToMap
);

__EIGHT EIGHT = __GetProcAddress(__EIGHT, "Kernel32.dll", "MapViewOfFile");

#endif