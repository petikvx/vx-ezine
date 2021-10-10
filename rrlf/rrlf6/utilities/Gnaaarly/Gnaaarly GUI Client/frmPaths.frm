VERSION 5.00
Begin VB.Form frmPaths 
   BorderStyle     =   4  'Festes Werkzeugfenster
   Caption         =   "Gnaaarly Backdoor - Paths Commands"
   ClientHeight    =   5010
   ClientLeft      =   45
   ClientTop       =   285
   ClientWidth     =   5535
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5010
   ScaleWidth      =   5535
   StartUpPosition =   2  'Bildschirmmitte
   Begin VB.Frame fraSetDir 
      Caption         =   "SET CURRENT DIRECTORY"
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
      TabIndex        =   9
      Top             =   3360
      Width           =   5535
      Begin VB.CommandButton cmdSetDir 
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
         TabIndex        =   12
         Top             =   720
         Width           =   5295
      End
      Begin VB.TextBox txtSetDir 
         Appearance      =   0  '2D
         Height          =   285
         Left            =   1200
         TabIndex        =   11
         Text            =   "C:\"
         Top             =   360
         Width           =   4215
      End
      Begin VB.Label lblSetDir 
         Caption         =   "!setdirectory"
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
         TabIndex        =   10
         Top             =   360
         Width           =   1095
      End
   End
   Begin VB.Frame fraCurrentDir 
      Caption         =   "RETURN CURRENT DIRECTORY"
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
      TabIndex        =   7
      Top             =   2520
      Width           =   5535
      Begin VB.CommandButton cmdCurrentDir 
         Caption         =   "!getdirectory"
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
         TabIndex        =   8
         Top             =   240
         Width           =   5295
      End
   End
   Begin VB.Frame fraLocation 
      Caption         =   "RETURN SERVER LOCATION"
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
      TabIndex        =   5
      Top             =   1680
      Width           =   5535
      Begin VB.CommandButton cmdLocation 
         Caption         =   "!location"
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
         Top             =   240
         Width           =   5295
      End
   End
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
      TabIndex        =   4
      Top             =   4560
      Width           =   5295
   End
   Begin VB.Frame fraSystemPath 
      Caption         =   "RETURN SYSTEM DIRECTORY"
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
      TabIndex        =   2
      Top             =   840
      Width           =   5535
      Begin VB.CommandButton cmdSystemPath 
         Caption         =   "!systempath"
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
         TabIndex        =   3
         Top             =   240
         Width           =   5295
      End
   End
   Begin VB.Frame fraWindowsPath 
      Caption         =   "RETURN WINDOWS DIRECTORY"
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
      Begin VB.CommandButton cmdWindowsPath 
         Caption         =   "!windowspath"
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
Attribute VB_Name = "frmPaths"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdBack_Click()
    frmPaths.Hide
End Sub

Private Sub cmdCurrentDir_Click()
    frmMain.txtSend.Text = "!getdirectory"
    SendCommand
End Sub

Private Sub cmdLocation_Click()
    frmMain.txtSend.Text = "!location"
    SendCommand
End Sub

Private Sub cmdSetDir_Click()
    frmMain.txtSend.Text = "!setdirectory '" & txtSetDir.Text & "'"
    SendCommand
End Sub

Private Sub cmdSystemPath_Click()
    frmMain.txtSend.Text = "!systempath"
    SendCommand
End Sub

Private Sub cmdWindowsPath_Click()
    frmMain.txtSend.Text = "!windowspath"
    SendCommand
End Sub
