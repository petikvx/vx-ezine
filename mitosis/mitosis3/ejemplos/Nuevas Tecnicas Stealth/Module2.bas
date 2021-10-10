Attribute VB_Name = "Module2"
Option Explicit
Private Type OSVERSIONINFO
    dwOSVersionInfoSize As Long
    dwMajorVersion As Long
    dwMinorVersion As Long
    dwBuildNumber As Long
    dwPlatformId As Long
    szCSDVersion As String * 128
End Type
Private Declare Function GetVersionEx Lib "kernel32" Alias "GetVersionExA" (LpVersionInformation As OSVERSIONINFO) As Long

'========= Win95/98/ME Shared memory staff===============
Private Declare Function CreateFileMapping Lib "kernel32" Alias "CreateFileMappingA" (ByVal hFile As Long, ByVal lpFileMappigAttributes As Long, ByVal flProtect As Long, ByVal dwMaximumSizeHigh As Long, ByVal dwMaximumSizeLow As Long, ByVal lpName As String) As Long
Private Declare Function MapViewOfFile Lib "kernel32" (ByVal hFileMappingObject As Long, ByVal dwDesiredAccess As Long, ByVal dwFileOffsetHigh As Long, ByVal dwFileOffsetLow As Long, ByVal dwNumberOfBytesToMap As Long) As Long
Private Declare Function UnmapViewOfFile Lib "kernel32" (lpBaseAddress As Any) As Long
Const STANDARD_RIGHTS_REQUIRED = &HF0000
Const SECTION_QUERY = &H1
Const SECTION_MAP_WRITE = &H2
Const SECTION_MAP_READ = &H4
Const SECTION_MAP_EXECUTE = &H8
Const SECTION_EXTEND_SIZE = &H10
Const SECTION_ALL_ACCESS = STANDARD_RIGHTS_REQUIRED Or SECTION_QUERY Or SECTION_MAP_WRITE Or SECTION_MAP_READ Or SECTION_MAP_EXECUTE Or SECTION_EXTEND_SIZE
Const FILE_MAP_ALL_ACCESS = SECTION_ALL_ACCESS

'============NT Shared memory staff======================
Private Declare Function OpenProcess Lib "kernel32" (ByVal dwDesiredAccess As Long, ByVal bInheritHandle As Long, ByVal dwProcessId As Long) As Long
Const PROCESS_VM_OPERATION = &H8
Const PROCESS_VM_READ = &H10
Const PROCESS_VM_WRITE = &H20
Const PROCESS_ALL_ACCESS = 0
Private Declare Function VirtualAllocEx Lib "kernel32" (ByVal hProcess As Long, ByVal lpAddress As Long, ByVal dwSize As Long, ByVal flAllocationType As Long, ByVal flProtect As Long) As Long
Private Declare Function VirtualFreeEx Lib "kernel32" (ByVal hProcess As Long, lpAddress As Any, ByVal dwSize As Long, ByVal dwFreeType As Long) As Long
Private Declare Function CloseHandle Lib "kernel32" (ByVal hObject As Long) As Long
Const MEM_COMMIT = &H1000
Const MEM_RESERVE = &H2000
Const MEM_DECOMMIT = &H4000
Const MEM_RELEASE = &H8000
Const MEM_FREE = &H10000
Const MEM_PRIVATE = &H20000
Const MEM_MAPPED = &H40000
Const MEM_TOP_DOWN = &H100000

'==========Memory access constants===========
Private Const PAGE_NOACCESS = &H1&
Private Const PAGE_READONLY = &H2&
Private Const PAGE_READWRITE = &H4&
Private Const PAGE_WRITECOPY = &H8&
Private Const PAGE_EXECUTE = &H10&
Private Const PAGE_EXECUTE_READ = &H20&
Private Const PAGE_EXECUTE_READWRITE = &H40&
Private Const PAGE_EXECUTE_WRITECOPY = &H80&
Private Const PAGE_GUARD = &H100&
Private Const PAGE_NOCACHE = &H200&

Public Function GetMemShared95(ByVal memSize As Long, hFile As Long) As Long
    hFile = CreateFileMapping(&HFFFFFFFF, 0, PAGE_READWRITE, 0, memSize, vbNullString)
    GetMemShared95 = MapViewOfFile(hFile, FILE_MAP_ALL_ACCESS, 0, 0, 0)
End Function

Public Sub FreeMemShared95(ByVal hFile As Long, ByVal lpMem As Long)
    UnmapViewOfFile lpMem
    CloseHandle hFile
End Sub

Public Function GetMemSharedNT(ByVal pid As Long, ByVal memSize As Long, hProcess As Long) As Long
    hProcess = OpenProcess(PROCESS_VM_OPERATION Or PROCESS_VM_READ Or PROCESS_VM_WRITE, False, pid)
    GetMemSharedNT = VirtualAllocEx(ByVal hProcess, ByVal 0&, ByVal memSize, MEM_RESERVE Or MEM_COMMIT, PAGE_READWRITE)
End Function

Public Sub FreeMemSharedNT(ByVal hProcess As Long, ByVal MemAddress As Long, ByVal memSize As Long)
   Call VirtualFreeEx(hProcess, ByVal MemAddress, memSize, MEM_RELEASE)
   CloseHandle hProcess
End Sub

Public Function IsWindowsNT() As Boolean
   Dim verinfo As OSVERSIONINFO
   verinfo.dwOSVersionInfoSize = Len(verinfo)
   If (GetVersionEx(verinfo)) = 0 Then Exit Function
   If verinfo.dwPlatformId = 2 Then IsWindowsNT = True
End Function
