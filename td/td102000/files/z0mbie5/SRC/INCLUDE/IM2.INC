
xx_first:

xxSetLastError          dd      ?
xxGetLastError          dd      ?
xxCreateFileA           dd      ?
xxCloseHandle           dd      ?
xxSetFilePointer        dd      ?
xxReadFile              dd      ?
xxWriteFile             dd      ?
xxGetTickCount          dd      ?
xxGetWindowsDirectoryA  dd      ?
xxGetEnvironmentVariableA dd    ?
xxGetDriveTypeA         dd      ?
xxFindFirstFileA        dd      ?
xxFindNextFileA         dd      ?
xxFindClose             dd      ?
xxCreateThread          dd      ?
xxSleep                 dd      ?
xxGetCurrentProcessId   dd      ?
xxVirtualProtect        dd      ?
xxExitProcess           dd      ?
xxExitThread            dd      ?
xxGetVersion            dd      ?
xxSetFileAttributesA    dd      ?
xxSetFileTime           dd      ?
xxCopyFileA             dd      ?
xxDeleteFileA           dd      ?
xxGetFileSize           dd      ?
xxGlobalFindAtomA       dd      ?
xxGlobalAddAtomA        dd      ?
xxGlobalDeleteAtom      dd      ?
xxGetCommandLineA       dd      ?
xxVirtualAlloc          dd      ?
xxCreateProcessA        dd      ?
xxWritePrivateProfileStringA dd ?
xxLoadLibraryA          dd      ?
xxGetProcAddress        dd      ?
xxGlobalAlloc           dd      ?
xxGetCurrentThread      dd      ?
xxGetThreadContext      dd      ?
xxSetThreadContext      dd      ?
xxGetThreadSelectorEntry dd     ?
IFDEF   DEBUG
xxAllocConsole          dd      ?
xxGetStdHandle          dd      ?
xxWriteConsoleA         dd      ?
xxReadConsoleA          dd      ?
xxFlushConsoleInputBuffer dd    ?
xxSetConsoleMode        dd      ?
xxFlushFileBuffers      dd      ?
ENDIF

