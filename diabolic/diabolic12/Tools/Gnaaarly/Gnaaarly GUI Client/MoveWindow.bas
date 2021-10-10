Attribute VB_Name = "MoveWindow"
Option Explicit

Private Declare Function GetWindowLong Lib "user32" _
  Alias "GetWindowLongA" ( _
  ByVal hwnd As Long, ByVal nIndex As Long) As Long

Private Declare Function SetWindowLong Lib "user32" _
  Alias "SetWindowLongA" (ByVal hwnd As Long, _
  ByVal nIndex As Long, ByVal dwNewLong As Long) As Long

Private Const GWL_STYLE = (-16)
Private Const WS_CAPTION = &HC00000
Private Const WS_BORDER = &H800000

Public Sub MakeNoBorder_And_3D(ByVal fForm As Form)
  Dim nStyle As Long
  
  With fForm
    .Width = .ScaleWidth
    .Height = .ScaleHeight
  
    nStyle = GetWindowLong(.hwnd, GWL_STYLE)

    nStyle = nStyle And Not WS_CAPTION
    
    SetWindowLong .hwnd, GWL_STYLE, nStyle
  End With
End Sub

Public Sub MoveControl(ctrControl As Object, Button As Integer, _
  Shift As Integer, X As Single, Y As Single)

  Static OldX As Single
  Static OldY As Single
    
  If Not Button = 1 Then
    OldX = X
    OldY = Y
  Else
   
    ctrControl.Left = ctrControl.Left + (X - OldX)
    ctrControl.Top = ctrControl.Top + (Y - OldY)
  End If
End Sub

Public Sub SendCommand()
    With frmMain.txtReturn
        .SelStart = Len(.Text)
        .SelText = frmMain.txtSend.Text & vbCrLf
    End With
  
    If frmMain.cmdSend.Enabled = True Then
        frmMain.Winsock.SendData frmMain.txtSend.Text
    End If
End Sub
