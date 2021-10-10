VERSION 5.00
Begin VB.Form Form2 
   AutoRedraw      =   -1  'True
   BorderStyle     =   0  'None
   Caption         =   "Form2"
   ClientHeight    =   1770
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   1035
   LinkTopic       =   "Form2"
   ScaleHeight     =   1770
   ScaleWidth      =   1035
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
End
Attribute VB_Name = "Form2"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_MouseMove(Boton As Integer, Shift As Integer, X As Single, Y As Single)
Dim result
If Boton = 1 Then
  ReleaseCapture
  result = SendMessage(Me.hwnd, WM_SYSCOMMAND, SC_CLICKMOVE, 0)
  DoEvents
End If
End Sub
