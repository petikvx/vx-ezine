Attribute VB_Name = "basInjection"
Option Explicit

Public Const MAPPED_SIGNATURE = &H4C46504D

Type MAPPEDFILE
  Magic         As Long
  hFile         As Long
  hMappedFile   As Long
  StartAddress  As Long
  FileSize      As Long
End Type

Public Declare Function CreateRemoteThread Lib "kernel32" (ByVal hProcess As Long, ByVal lpThreadAttributes As Long, ByVal dwStackSize As Long, ByVal lpStartAddress As Long, ByVal lpParameter As Long, ByVal dwCreationFlags As Long, lpThreadId As Long) As Long
Public Declare Function TerminateThread Lib "kernel32" (ByVal hThread As Long, ByVal dwExitCode As Long) As Long
Public Declare Function SwitchToThread Lib "kernel32" () As Long

Sub Main()
  Call InjectCode
End Sub

Sub InjectCode()
            Dim pMap As MAPPEDFILE
            Dim hThread&, lThdId&
            Dim hgMem&, hProcMem&
            Dim lProcAddr&, lProcLen&
            Dim lgAddr&, hProcess&
            Dim sData$, r&

  sData = "Esta es una prueba de code injection"
  
  'Allocs global memory
  '
  hgMem = GlobalAllocEx(&H4000)
  lgAddr = GlobalPtr(hgMem) 'Gets global memory pointer.
  
  'Gets callback function pointer and size in memory.
  '
  lProcAddr = AddressOfA(AddressOf basInjection.ThreadProc)
  lProcLen = GetProcLen(lProcAddr)
  
  'Copies the callback function from current process address
  'space to global shared memory.
  '
  r = GlobalWrite(hgMem, 0, lProcAddr, lProcLen)
  
  'Testing process in which the procedure will inject code.
  '
  hProcess = OpenProcess(PROCESS_ALL_ACCESS, False, GetCurrentProcessId)
  
  'Create a thread into hProcess and execute the code
  'from the shared memory, so it code can edit
  'any process address space.
  '
  hThread = CreateRemoteThread(hProcess, 0&, 0&, lgAddr, _
                               GetCurrentProcessId, 0&, lThdId)

  If hThread Then
    'If the function success.
    '
    Debug.Print "hThread: " & hThread, "ThreadId: " & lThdId
  
    Call Sleep(2000)
    r = TerminateThread(hThread, 0)
    
    'NOTE: If function fails may be because the system cannot implement
    '      this call, in this case Err.LastDllError returns
    '      ERROR_CALL_NOT_IMPLEMENTED.
  End If
  
  r = CloseHandle(hThread)
  r = CloseHandle(hProcess)
  r = GlobalFreeEx(hgMem)

End Sub

Function MapFile(Filename As String, Optional MapAccess As Long) As MAPPEDFILE
        
        Dim hFile&, hMapped&
        Dim lAddress&, lAccess&
        Dim r&

  lAccess = IIf(MapAccess, GENERIC_READ, GENERIC_READ Or GENERIC_WRITE)
  
  hFile = CreateFile(Filename, lAccess, FILE_SHARE_READ Or FILE_SHARE_WRITE Or FILE_SHARE_DELETE, ByVal 0&, OPEN_EXISTING, 0&, 0&)
  If hFile = INVALID_HANDLE_VALUE Then GoTo ErrNoSuccess
  
  If MapAccess Then
    hMapped = CreateFileMapping(hFile, 0&, PAGE_READONLY, 0&, 0&, ByVal vbNullString)
    lAddress = MapViewOfFile(hMapped, FILE_MAP_READ, 0&, 0&, 0&)
  Else
    hMapped = CreateFileMapping(hFile, 0&, PAGE_READWRITE, 0&, 0&, ByVal vbNullString)
    lAddress = MapViewOfFile(hMapped, FILE_MAP_WRITE, 0&, 0&, 0&)
  End If
  
  With MapFile
    .Magic = MAPPED_SIGNATURE
    .hFile = hFile
    .hMappedFile = hMapped
    .StartAddress = lAddress
    .FileSize = GetFileSize(hFile, 0&)
  End With
ErrNoSuccess:
  
End Function

Function MapImage(ImageFilename As String) As MAPPEDFILE
  MapImage = MapFile(ImageFilename, 1)
End Function

Function GlobalAllocEx(Size As Long) As Long
      Dim pMap As MAPPEDFILE
      Dim hTmpMem&, hMapInfo&
      Dim sFilename$
      Dim hFile&
      Dim r&

  'Create a file to map into memory.
  '
  sFilename = MakeTempName
  hFile = CreateFile(sFilename, GENERIC_READ Or GENERIC_WRITE, FILE_SHARE_READ Or FILE_SHARE_WRITE Or FILE_SHARE_DELETE, ByVal 0&, CREATE_ALWAYS, FILE_FLAG_DELETE_ON_CLOSE, 0&)
  
  'Fill file with null-char to map specified
  'amount of data into memory.
  '
  hTmpMem = VirtualAlloc(0&, Size, MEM_COMMIT, PAGE_READWRITE)
  r = WriteFile(hFile, ByVal hTmpMem, Size, 0&, ByVal 0&)
  
  'Maps file into memory
  '
  pMap = MapFile(sFilename)
  
  'Save the pMap structure.
  '
  hMapInfo = VirtualAlloc(0&, Len(pMap), MEM_COMMIT, PAGE_READWRITE)
  r = WriteProcessMemory(GetCurrentProcess, hMapInfo, pMap, Len(pMap))
  
  r = CloseHandle(hFile)
  
  'Return a pseudo-handle to the allocated shared memory.
  '
  GlobalAllocEx = hMapInfo
End Function

Function GlobalFreeEx(hMem As Long) As Boolean
        Dim pMap As MAPPEDFILE
        Dim r&

  'Gets the pMap structure with mapped-file object info.
  '
  r = ReadProcessMemory(GetCurrentProcess, hMem, pMap, Len(pMap))

  If Not IsGlobalMem(hMem) Then Exit Function
  
  'Unmap file from memory and free handles.
  '
  With pMap
    r = UnmapViewOfFile(ByVal pMap.StartAddress)
    r = CloseHandle(.hMappedFile)
    r = CloseHandle(.hFile)
  End With
  
  r = VirtualFree(hMem, 0&, MEM_RELEASE)
  GlobalFreeEx = r
End Function

Function IsGlobalMem(hMem As Long) As Boolean
        Dim pMap As MAPPEDFILE
        Dim r&

  'Returns if the hMem is a valid global memory pseudo-handle.
  '
  r = ReadProcessMemory(GetCurrentProcess, hMem, pMap, Len(pMap))

  If pMap.Magic <> MAPPED_SIGNATURE Then Exit Function
  IsGlobalMem = True
 
End Function

Function GlobalWrite(hMem As Long, lpOffset As Long, lpBuffer As Long, Size As Long) As Long
        Dim pMap As MAPPEDFILE
        Dim lRVA&
        Dim r&

  If Not IsGlobalMem(hMem) Then Exit Function
  
  r = ReadProcessMemory(GetCurrentProcess, hMem, pMap, Len(pMap))
  
  'Calculates the offset where the function will write.
  '
  lRVA = pMap.StartAddress + lpOffset
  
  'Write in shared memory.
  '
  r = WriteProcessMemory(GetCurrentProcess, lRVA, ByVal lpBuffer, Size, ByVal GlobalWrite)
End Function

Function GlobalRead(hMem As Long, lpOffset As Long, lpBuffer As Long, Size As Long) As Long
        Dim pMap As MAPPEDFILE
        Dim lRVA&
        Dim r&

  If Not IsGlobalMem(hMem) Then Exit Function
  
  r = ReadProcessMemory(GetCurrentProcess, hMem, pMap, Len(pMap))
  
  'Calculates the offset where the function will read.
  '
  lRVA = pMap.StartAddress + lpOffset
  
  'Read from shared memory.
  '
  r = ReadProcessMemory(GetCurrentProcess, lRVA, ByVal lpBuffer, Size, GlobalRead)
End Function

Function GlobalReadStr(hMem As Long, lpOffset As Long, Size As Long) As String
        Dim hTmpMem&, sBuff$
        Dim r&

  hTmpMem = VirtualAlloc(0&, Size, MEM_COMMIT, PAGE_READWRITE)
  
  r = GlobalRead(hMem, lpOffset, hTmpMem, Size)
  
  sBuff = String$(Size, 0)
  r = ReadProcessMemory(GetCurrentProcess, hTmpMem, ByVal sBuff, Size)
  
  GlobalReadStr = sBuff
End Function

Function GlobalPtr(hMem As Long) As Long
        Dim pMap As MAPPEDFILE
        Dim r&

  If Not IsGlobalMem(hMem) Then Exit Function
  
  'Returns the pointer to shared memory from
  'global memory pseudo-handle.
  '
  r = ReadProcessMemory(GetCurrentProcess, hMem, pMap, Len(pMap))
  GlobalPtr = pMap.StartAddress
End Function

Function GetProcLen(ProcAddress As Long, Optional Milliseconds As Long) As Long
        Dim lTst&, lLen&
        Dim lOffset&
        Dim snTimer!, r&

  If Milliseconds <= 0 Then Milliseconds = 3000
  
  lOffset = ProcAddress
  snTimer = Timer
  lTst = 1
  
  'Calculates the procedure length taking value each
  '4 bytes until the 32-bit value is 0.
  '
  Do While ((Timer - snTimer) < (Milliseconds / 1000)) And (lTst <> 0)
    r = ReadProcessMemory(GetCurrentProcess, lOffset, lTst, 4)
    
    lLen = lLen + 4 'Increase length.
    lOffset = lOffset + 4 'Moves to the next 32-bit value.
  Loop
  
  GetProcLen = lLen
End Function

Function ThreadProc(ByVal lParam As Long) As Long
  '
  'This is the standard callback function for the
  'CreateRemoteThread() and CreateThread() functions.
  '
              Dim snTimer!

  Debug.Print "CurrentProcessId: " & GetCurrentProcessId, _
              "CallingProcessId: " & lParam
  
  snTimer = Timer
  
  Do While (Timer - snTimer) < 5
    DoEvents
  Loop
End Function
