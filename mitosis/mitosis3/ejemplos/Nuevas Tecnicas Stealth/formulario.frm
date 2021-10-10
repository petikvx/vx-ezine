VERSION 5.00
Begin VB.Form Form1 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "GEDZAC Technology"
   ClientHeight    =   1680
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   4335
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1680
   ScaleWidth      =   4335
   StartUpPosition =   3  'Windows Default
   Begin VB.Timer Timer1 
      Interval        =   1
      Left            =   1920
      Top             =   1110
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      Caption         =   "Stealth by Nemlim / GEDZAC"
      Height          =   255
      Left            =   60
      TabIndex        =   0
      Top             =   600
      Width           =   4185
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Timer1_Timer()
Timer1.Enabled = False
Call GetSysLVHwnd
Timer1.Enabled = True
End Sub
