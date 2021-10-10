Attribute VB_Name = "basMain"
'**************************************************************************
'
'Módulo: basMain.bas
'Fecha: 01 de Enero del 2005
'Dependencias: -
'Referencias: win.tlb
'Descripción: Funciones generales usadas por otros módulos.
'
'¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬
'Autor: Slasher
'E-Mail: ghost.throne@gmail.com
'¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬
'
'Nota: los comentarios están en inglés porque así
'      tengo que escribir menos xD, y es más universal,
'      porque hay palabras que no tienen traducciones
'      perfectas.
'***************************************************************************

Option Explicit
Option Base 1

Public Const FILE_SHARE_DELETE = 4
Public Const MAX_PATH = 260

Public Declare Function ReadProcessMemory Lib "kernel32" (ByVal hProcess As Long, ByVal lpBaseAddress As Long, lpBuffer As Any, ByVal nSize As Long, Optional lpNumberOfBytesWritten As Long) As Long
Public Declare Function WriteProcessMemory Lib "kernel32" (ByVal hProcess As Long, ByVal lpBaseAddress As Long, lpBuffer As Any, ByVal nSize As Long, Optional lpNumberOfBytesWritten As Long) As Long

'Sub Main()

'End Sub

Function GetWindowText(ByVal hWnd As Long) As String
        Dim sData$, lData&

  lData = 1024
  sData = String$(lData, 0)
  
  If win.GetWindowText(hWnd, ByVal sData, ByVal lData) Then
    sData = Left$(sData, InStr(1, sData, vbNullChar) - 1)
    GetWindowText = sData
    
  End If
  
End Function

Function ClnStr(ByVal StrSpec As String) As String
          Dim sStr$

  sStr = RTrim$(Replace$(StrSpec, vbNullChar, vbNullString))
  sStr = Replace$(sStr, vbCr, Chr$(vbKeySpace))
  sStr = Replace$(sStr, vbLf, Chr$(vbKeySpace))
  
  ClnStr = sStr
End Function

Function GetShortPath(PathSpec As String) As String
            Dim sPath$

  sPath = String(MAX_PATH, 0)
  If GetShortPathName(PathSpec, sPath, MAX_PATH) Then
    GetShortPath = Left$(sPath, InStr(1, sPath, vbNullChar) - 1)
  End If
End Function

Property Get HiByte(ByVal Word As Integer) As Byte
  If Word And &H8000 Then
    If Not (Word Or &HFF) = &HFFFFFFFF Then Word = (Word Xor &HFF)

    HiByte = &H80 Or ((Word And &H7FFF) \ &HFF)
  Else
    HiByte = Word \ 256
  End If
End Property

Property Get HiWord(Dword As Long) As Integer
  If Dword And &H80000000 Then
    HiWord = (Dword / 65535) - 1
  Else
    HiWord = Dword / 65535
  End If
End Property

Property Get LoByte(Word As Integer) As Byte
  LoByte = (Word And &HFF)
End Property

Property Get LoWord(Dword As Long) As Integer
  If Dword And &H8000& Then
    LoWord = &H8000 Or (Dword And &H7FFF&)
  Else
    LoWord = Dword And &HFFFF&
  End If
End Property

Property Get LShiftWord(ByVal Word As Integer, ByVal c As Integer) As Integer
            Dim dw&
        
  dw = Word * (2 ^ c)

  If dw And &H8000& Then
    LShiftWord = CInt(dw And &H7FFF&) Or &H8000
  Else
    LShiftWord = dw And &HFFFF&
  End If
End Property

Property Get RShiftWord(ByVal Word As Integer, ByVal c As Integer) As Integer
          Dim dw&
  
  If c = 0 Then
    RShiftWord = Word
  Else
    dw = Word And &HFFFF&
    dw = dw \ (2 ^ c)
    RShiftWord = dw And &HFFFF&
  End If
End Property

Property Get MakeWord(ByVal bHi As Byte, ByVal bLo As Byte) As Integer
  If bHi And &H80 Then
    MakeWord = (((bHi And &H7F) * 255) + bLo) Or &H7FFF
  Else
    MakeWord = (bHi * 255) + bLo
  End If
End Property

Property Get MakeDWord(wHi As Integer, wLo As Integer) As Long
  If wHi And &H8000& Then
    MakeDWord = (((wHi And &H8000&) * 65536) Or (wLo And &HFFFF&)) _
                Or &H80000000
  Else
    MakeDWord = (wHi * &H10000) + wLo
  End If
End Property

Property Get TempDir() As String
  On Error Resume Next
  
        Dim sData$

  sData = String$(256, 0)
  
  If GetTempPath(256, sData) Then
    TempDir = Left$(sData, InStr(1, sData, vbNullChar) - 1)
    If Right$(TempDir, 1) <> "\" Then TempDir = TempDir & "\"
  End If
  
End Property

Property Get WinDir() As String
  On Error Resume Next
  
        Dim sData$

  sData = String$(256, 0)
  
  If GetWindowsDirectory(sData, 256) Then
    WinDir = Left$(sData, InStr(1, sData, vbNullChar) - 1)
    If Right$(WinDir, 1) <> "\" Then WinDir = WinDir & "\"
  End If
End Property

Property Get SysDir() As String
  On Error Resume Next
  
        Dim sData$

  sData = String$(256, 0)
  
  If GetSystemDirectory(sData, 256) Then
    SysDir = Left$(sData, InStr(1, sData, vbNullChar) - 1)
    If Right$(SysDir, 1) <> "\" Then SysDir = SysDir & "\"
  End If
End Property

Function IsFile(FileSpec As String) As Boolean
  On Error Resume Next
  IsFile = (GetAttr(FileSpec) And Not vbDirectory)
End Function

Function IsDir(PathSpec As String) As Boolean
  On Error Resume Next
  IsDir = (GetAttr(PathSpec) And vbDirectory)
End Function

Function MakeTempName() As String
  MakeTempName = TempDir & "~D" & Hex$(timeGetTime) & ".TMP"
End Function

Function CreateTempFile(Optional ShareMode As Long, Optional Flags As Long = FILE_FLAG_DELETE_ON_CLOSE, Optional outFilename As String) As Long
          Dim hFile&

  outFilename = MakeTempName
  hFile = CreateFile(outFilename, GENERIC_READ Or GENERIC_WRITE, ShareMode, 0, CREATE_ALWAYS, Flags, 0)
  If hFile <> INVALID_HANDLE_VALUE Then CreateTempFile = hFile
End Function

Function GetFileTitle(Filename As String, Optional IncludeExtension As Boolean = True) As String
          Dim iPos%, iPointPos%
  
  iPos = InStrRev(Filename, "\")
  If iPos = 0 Then iPos = InStrRev(Filename, "/")
  
  If iPos Then
    If IncludeExtension Then
      GetFileTitle = Mid$(Filename, iPos + 1)
    Else
      iPointPos = InStr(iPos + 1, Filename, ".")
      If iPointPos Then
        GetFileTitle = Mid$(Filename, iPos + 1, iPointPos - iPos - 1)
      Else
        GetFileTitle = Mid$(Filename, iPos + 1)
      End If
    End If
  End If
End Function

Function GetFilePath(Filename As String) As String
          Dim iUnitPos%, iPos%
  
  iPos = InStrRev(Filename, "\")
  If iPos = 0 Then iPos = InStrRev(Filename, "/")
  
  iUnitPos = InStr(1, Filename, ":\")
  If iUnitPos = 0 Then iUnitPos = InStr(1, Filename, "/")
  
  If iPos > 0 And iUnitPos > 0 Then
    GetFilePath = Mid$(Filename, iUnitPos - 1, iPos - iUnitPos + 2)
  End If
End Function

Function SysErrStr(SysError As Long) As String
        Dim sData$, lData&

  lData = 1024
  sData = String$(lData, 0)
  
  If FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, 0&, SysError, 0&, ByVal sData, lData, ByVal 0&) Then
    sData = Left$(sData, InStr(1, sData, vbNullChar) - 1)
    
    SysErrStr = sData
  End If
End Function

Function AddressOfA(fPtr As Long) As Long
  AddressOfA = fPtr
End Function

Function RegOpenKey(hKey As Long, SubKey As String, Optional FailNoExist As Boolean = True) As Long
          Dim lDisp&, hNewKey&, r&

  lDisp = IIf(FailNoExist, REG_OPENED_EXISTING_KEY, REG_CREATED_NEW_KEY)
  r = RegCreateKeyEx(hKey, SubKey, 0&, ByVal vbNullString, 0&, KEY_READ, _
                     ByVal 0&, hNewKey, lDisp)
  
  If r = ERROR_SUCCESS Then
    RegOpenKey = hNewKey
  End If
End Function

Function FillBuffer(Length As Long) As String
  On Error Resume Next
  
  FillBuffer = String$(Length, 0)
End Function

Function StrFact(Spec As String) As Currency
        Dim cFact@

  If Spec = vbNullString Then Exit Function
  
  cFact = DataFact(StrPtr(StrConv(Spec, vbFromUnicode)), Len(Spec))
  
  StrFact = cFact
End Function

Function DataFact(DataPtr As Long, DataSize As Long) As Currency
        Dim cFact@, i&, r&
        Dim btData() As Byte

  If DataSize <= 0 Then Exit Function
  
  ReDim btData(DataSize) As Byte
  
  r = ReadProcessMemory(GetCurrentProcess(), _
                        DataPtr, _
                        btData(1), DataSize)
  
  For i = 1 To DataSize
    cFact = cFact + btData(i)
  Next
  
  DataFact = cFact
End Function

Function InvXor(ByVal Total As Long, ByVal Num2 As Long) As Long
  InvXor = (Not (Not Total Or Num2)) Or Not (Total Or Not Num2)
End Function
